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

import Foundation

public struct FileErrorDetail: Codable {
    
    public let code: Int
    
    public let path: String
    
}

extension FileErrorDetail {
    var error: Error? { return makeError(code: code, type: FileStationError.self) }
}

extension FileErrorDetail: CustomStringConvertible {
    public var description: String {
        return [
            error?.localizedDescription
                ?? "error \(code)",
            path,
            ].joined(separator: ": ")
    }
}

/// All API responses are encoded in the JSON format, and the JSON response contains elements as follows:
public struct Response<T: Decodable>: Decodable {
    
    /// “true”: the request finishes successfully; “false”: the request fails with an error data.
    public let success: Bool
    
    /// The data object contains all response information described in each method.
    public let data: T?
    
    /// The data object contains error information when a request fails. The basic elements are described in the next table.
    public struct Error: Decodable {
        
        /// An error code will be returned when a request fails. There are two kinds of error codes: a common error code which is shared between all APIs; the other is a specific API error code (described under the corresponding API spec).
        public let code: Int
        
        /// The array contains detailed error information of each file. Each element within errors is a JSON-Style Object which contains an error code and other information, such as a file path or name.
        /// - Note: When there is no detailed information, this error element won’t be responded.
        public let errors: [FileErrorDetail]?
    
    }
    
    public let error: Error?
    
}

extension Response.Error: Error {
    
}

public func decode<T>(data: Data) throws -> T where T: Decodable & ErrorInfo {
    let response = try JSONDecoder().decode(Response<T>.self, from: data)
//    print(response)
    if response.success,
        let data = response.data
    {
        return data
    } else {
//        print(response)
        if let error = response.error {
            let e = makeError(code: error.code, type: T.ErrorType.self)
            throw e.map({ FileError(error: $0, errors: error.errors)})
                ?? NSError(domain: DSM.Error.domain, code: error.code, userInfo:["errors": error.errors ?? []])
        } else {
            print(#function, String(data: data, encoding: .utf8) ?? "not utf8?")
            throw DSM.Error.invalidResponse
        }
    }
}

/// Contains API description objects.
public struct APIInfo: Codable {
    
    /// API path.
    public let path: String
    
    /// Minimum supported API version.
    public let minVersion: Int
    
    /// Maximum supported API version.
    public let maxVersion: Int
    
    public var supportedVersion: ClosedRange<Int> {
        return minVersion...maxVersion
    }
    
    var fullPath: String { return "\(API_PREFIX)\(path)" }
    
}

public typealias APIInfoData = [String: APIInfo]

// FIXME: ugly
extension APIInfoData: ErrorInfo {
    public typealias ErrorType = APIError
}

public struct APILoginData: Codable, ErrorInfo {
    public typealias ErrorType = AuthError
    
    /// Authorized session ID. When the user log in with format=sid, cookie will not be set and each API request should provide a request parameter _sid=< sid> along with other parameters.
    public let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "sid"
    }
}

// TODO: APILogoutData

