//
//  Copyright (c) 2018 Changbeom Ahn <kewlbear@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

enum ParameterName: String {
    case api
    case method
    case version
    case sessionId = "_sid"
}

public protocol Method {
    
    associatedtype Data: Decodable
    
    var api: String { get }
    
    var identifier: String { get }
    
    var version: ClosedRange<Int> { get }
    
    func parameters(version: Int) throws -> [String: String]
    
}

protocol Renamed {
    
}

public protocol Value {
    func stringValue(version: Version) -> String
    
    func value(version: Version) -> Self?
}

protocol UnversionedValue: Value {
    
}

extension UnversionedValue {
    public func stringValue(version: Version) -> String {
        return String(describing: self)
    }
    
    public func value(version: Version) -> Self? {
        return self
    }
}

extension String: UnversionedValue {
    
}

extension Int: UnversionedValue {
    
}

extension Bool: UnversionedValue {
    
}

extension Set: Value {
    public func stringValue(version: Int) -> String {
        return map { ($0 as? Value)?.stringValue(version: version) ?? "\($0)" }.joined(separator: ",")
    }
    
    public func value(version: Version) -> Set<Element>? {
        return self
    }
}

extension RawRepresentable where RawValue: Value {
    public func stringValue(version: Int) -> String {
        return rawValue.stringValue(version: version)
    }
    
    public func value(version: Version) -> Self? {
        return self
    }
}

let dateFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 0
    return formatter
}()

extension Date: UnversionedValue {
    public func stringValue(version: Int) -> String {
        let milliseconds = timeIntervalSince1970 * 1000
        return dateFormatter.string(from: NSNumber(value: milliseconds)) ?? "invalid number?"
    }
}

extension URL: UnversionedValue {
    public func stringValue(version: Int) -> String {
        return lastPathComponent
    }
}

struct BasicValue<T>: Value, CustomStringConvertible where T: Value {
    func value(version: Version) -> BasicValue<T>? {
        return values.first { $0.1.contains(version) }.map { BasicValue($0.0) }
    }
    
    let values: [(T, Availability)]
    
    var description: String {
        return values.first.map { "\($0.0)" } ?? "no value?"
    }
    
    init(_ value: T, availability: Availability = 1..., previousValues: [(T, Availability)]? = nil) {
        var values = previousValues ?? []
        values.insert((value, availability), at: 0)
        self.values = values
    }
    
    func stringValue(version: Version) -> String {
        return values.first { $0.1.contains(version) }.map { $0.0.stringValue(version: version) } ?? "no matching value"
    }
}

struct Path: Value {
    func value(version: Version) -> Path? {
        return self
    }
    
    let path: String // TODO: BasicValue?
    
    func stringValue(version: Version) -> String {
        let escaped = escape(path)
        return version > 1 && false ? "\"\(escaped)\"" : escaped
    }
}

/// Note all parameters need to be escaped. Commas ”,” are replaced by slashes " \", and slashes" \" are replaced by double-slashes "\\", because commas ”,” are used to separate multiple elements in a parameter. Password-relative parameters do not need to be escaped including passwd or password parameter.
func escape(_ string: String) -> String {
    return string.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: ",", with: "\\,")
}

struct Values: Value {
    func value(version: Version) -> Values? {
        return self
    }
    
    let values: [String]
    
    func stringValue(version: Int) -> String {
        return values.map { escape($0) }.joined(separator: ",")
    }
}

struct Parameter {
    typealias RangeType = PartialRangeFrom<Version>
    
    var versions = [(String, RangeType)]()

    init(name: String, availability: RangeType) {
        add(name: name, version: availability)
    }
    
    func name(version: Int) -> String? {
        return versions.first {
            $0.1.contains(version)
        }?.0
    }
    
    mutating func add(name: String, version: RangeType) {
        let index = versions.index {
            $0.1.contains(version.lowerBound)
        } ?? 0
        versions.insert((name, version), at: index)
    }
}

extension Parameter: Hashable {
    static func ==(lhs: Parameter, rhs: Parameter) -> Bool {
        return lhs.versions.first?.0 == rhs.versions.first?.0
    }
    
    var hashValue: Int {
        return (versions.first?.0 ?? "no version?").hashValue
    }
}

let API_PREFIX = "/webapi/"

open class DSM {
    
    open var url: URL
    
    open var sessionId: String?
    
    var apiInfo = ["SYNO.API.Info": APIInfo(path: "query.cgi", minVersion: 1, maxVersion: 1)]
    
    var shouldQueryAPIInfo = true // TODO: ?
    
    var pendingCompletion: ((Data?, URLResponse?, Swift.Error?) -> Void)?
    
    func queryAPIInfo(completion: @escaping (Swift.Error?) -> Void) {
        shouldQueryAPIInfo = false
        get(API.Info.query()) { [weak self] (data, error) in
            guard let data = data else {
                completion(error)
                return
            }
            // TODO: validate?
            self?.apiInfo = data
            completion(nil)
        }
    }
    
    // TODO: ...
    enum Error: String, Swift.Error {
        case apiInfoNotFound
        case unsupportedVersion
        case invalidResponse
        case invalidURL
        
        static let domain = "error"
    }
    
    class ParameterEncoder: Encoding {
        let version: Version
        
        var parameterStore: ParameterStore
        
        init(version: Version, parameterStore: ParameterStore = URLQueryItems()) {
            self.version = version
            self.parameterStore = parameterStore
        }
        
        func add(parameter: Value, value: Value, availability: Availability) {
            if availability.contains(version) {
                struct V: ParameterValue {
                    let v: Value
                    let version: Version
                    
                    var string: String {
                        return v.stringValue(version: version)
                    }
                    
                    var value: Value {
                        return v
                    }
                }

                guard let v = value.value(version: version) else {
                    assertionFailure()
                    return
                }
                parameterStore.add(name: parameter.stringValue(version: version), value:
                    V(v: v, version: version))
            }
        }
    }
    
    open lazy var urlSession = URLSession.shared
    
    open func get<T>(_ method: T, completion: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) where T: RequestInfo {
        do {
            let url = try buildURL(info: method)

            var task: URLSessionTask?
            
            if urlSession.delegate == nil {
                task = urlSession.dataTask(with: url) { (data, response, error) in
                    completion(data, response, error)
                }
            } else {
                task = urlSession.dataTask(with: url)
                assert(pendingCompletion == nil)
                print("pending:", url)
                pendingCompletion = completion
            }
            print(">", url)
            task?.resume()
        }
        catch {
            if error as? Error == Error.apiInfoNotFound && shouldQueryAPIInfo {
                queryAPIInfo { [weak self] error in
                    if error == nil {
                        self?.get(method, completion: completion)
                    } else {
                        completion(nil, nil, error)
                    }
                }
            } else {
                completion(nil, nil, error)
            }
        }
    }

    open func finish(data: Data?, response: URLResponse?, error: Swift.Error?) {
        assert(pendingCompletion != nil)
        pendingCompletion?(data, response, error)
        print("reset pending")
        pendingCompletion = nil
    }
    
    open func get<T>(_ method: T, completion: @escaping (T.DataType?, Swift.Error?) -> Void) where T: DecodableRequestInfo {
        get(method) { (data, response, error) in
            print("<", method.api)
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                completion(try decode(data: data), nil)
            }
            catch {
                print(#function, String(data: data, encoding: .utf8) ?? "not utf8?")
                completion(nil, error)
            }
        }
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public convenience init?(isHTTPS: Bool = false, host: String, port: Int? = nil) {
        var urlComponents = URLComponents()
        urlComponents.scheme = isHTTPS ? "https" : "http"
        urlComponents.host = host
        urlComponents.port = port ?? (isHTTPS ? 5001 : 5000)
        guard let url = urlComponents.url else {
            return nil
        }
        self.init(url: url)
    }
    
    open func info(for api: String) -> APIInfo? {
        return apiInfo[api]
    }
    
}

extension DSM: URLBuilder {
    public func buildURL<T>(info: T) throws -> URL where T : RequestInfo {
        guard let api = apiInfo[info.api],
            api.supportedVersion.overlaps(info.versions),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else
        {
            if shouldQueryAPIInfo {
                let group = DispatchGroup()
                group.enter()
                queryAPIInfo { (error) in
                    group.leave()
                }
                group.wait()
                return try buildURL(info: info)
            }
            throw apiInfo.keys.contains(info.api) ? Error.unsupportedVersion : Error.apiInfoNotFound
        }
        
        let version = info.versions.clamped(to: api.supportedVersion).upperBound
        
        let encoder = ParameterEncoder(version: version)
        info.encode(encoder: encoder)
        
        urlComponents.dsm_apiPath = api.path
        
        urlComponents.queryItems = (encoder.parameterStore as? URLQueryItems)?.queryItems
        
        urlComponents.dsm_addQueryItems(api: info.api, version: version, sessionId: sessionId)
        
//        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "/").inverted)
        
        guard let url = urlComponents.url else {
            throw Error.invalidURL
        }
        return url
    }
}

extension DSM: MultipartFormDataBuilder {

    public func buildMultipartFormData<T>(info: T, to store: ParameterStore) throws where T : RequestInfo {
        guard let api = apiInfo[info.api],
            api.supportedVersion.overlaps(info.versions) else
        {
            if shouldQueryAPIInfo {
                let group = DispatchGroup()
                group.enter()
                queryAPIInfo { (error) in
                    group.leave()
                }
                group.wait()
                try buildMultipartFormData(info: info, to: store)
                return
            }
            throw apiInfo.keys.contains(info.api) ? Error.unsupportedVersion : Error.apiInfoNotFound
        }
        
        let version = info.versions.clamped(to: api.supportedVersion).upperBound

        let encoder = ParameterEncoder(version: version, parameterStore: store)
        
        encoder["api"] = info.api
        encoder["version"] = version
        
        info.encode(encoder: encoder)
    }
    
}

/// The type (usually an `enum`) conforming to this protocol is used as a namespace,
/// because Swift does not provide it currently.
public protocol Namespace {
    
}

public protocol MethodContainer: Namespace {
    
}

extension MethodContainer {
    static var api: String {
        let components = String(reflecting: self).components(separatedBy: ".").dropFirst()
        return "SYNO." + components.joined(separator: ".")
    }
}

public typealias Version = Int

public typealias Availability = PartialRangeFrom<Version>

public protocol Encoding: AnyObject {
    
    func add(parameter: Value, value: Value, availability: Availability)
    
}

extension Encoding {
    
    subscript(parameter: Value) -> Value {
        get {
            return "" // TODO: ?
        }
        set {
            add(parameter: parameter, value: newValue, availability: 1...)
        }
    }

}

public protocol ParameterValue {
    
    associatedtype ValueType
    
    var string: String { get }
    
    var value: ValueType { get }
    
}

public protocol ParameterStore {
    
    mutating func add<T>(name: String, value: T) where T: ParameterValue
    
}

public struct URLQueryItems: ParameterStore {
    
    var queryItems = [URLQueryItem]()
    
    public mutating func add<T>(name: String, value: T) where T: ParameterValue {
        queryItems.append(URLQueryItem(name: name, value: value.string))
    }
    
}

public protocol RequestInfo {
    
    var api: String { get }
    
    var versions: ClosedRange<Version> { get }
    
    func encode(encoder: Encoding)

}

extension RequestInfo {
    
    public func url(builder: URLBuilder) throws -> URL {
        return try builder.buildURL(info: self)
    }

}

public protocol URLBuilder {
    
    func buildURL<T>(info: T) throws -> URL where T: RequestInfo
    
}

public protocol MultipartFormDataBuilder {
    
    func buildMultipartFormData<T>(info: T, to: ParameterStore) throws where T: RequestInfo
    
}

public protocol DecodableRequestInfo: RequestInfo {
    
    associatedtype DataType: Decodable
    
}

public class VanillaRequestInfo: RequestInfo {
    
    public var api: String
    
    public var method: Value
    
    public var versions: ClosedRange<Version>
    
    public var encodeBlock: (Encoding) -> Void
    
    public func encode(encoder: Encoding) {
        encoder["method"] = method

        encodeBlock(encoder)
    }
    
    init(api: String, method: String = #function, availability: Availability = 1..., previousMethodNames: [(String, Availability)]? = nil, versions: ClosedRange<Version>, encode: @escaping (Encoding) -> Void) {
        self.api = api
        self.method = BasicValue(method.components(separatedBy: "(").first ?? "no function name?", availability: availability, previousValues: previousMethodNames)
        self.versions = versions
        self.encodeBlock = encode
    }

}

public class BasicRequestInfo<T>: VanillaRequestInfo, DecodableRequestInfo where T: Decodable {
    
    public typealias DataType = T
    
}
