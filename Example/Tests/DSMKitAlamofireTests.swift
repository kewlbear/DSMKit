//
//  DSMKitAlamofireTests.swift
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

import XCTest
import Alamofire
import DSMKit
import DSMKit_Example

class AlamofireTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpload() {
//        class AlamofireMultipartHandler: RequestHandler {
//
//            struct Builder: RequestBuilder {
//                let multipartFormData: MultipartFormData
//
//                let version: Int
//
//                func add<T>(parameter: String, value: Value, versions: T) where T: RangeExpression, T.Bound == Int {
//                    guard versions.contains(version) else {
//                        // TODO: fail?
//                        print(#function, "skipping", parameter, ": doesn't support version", version, "; supports", versions)
//                        return
//                    }
//                    // TODO: ...
//                    value.value(version: version).data(using: .utf8).map {
//                        if let url = value as? URL {
//                            multipartFormData.append(url, withName: parameter)
//                        } else {
//                            multipartFormData.append($0, withName: parameter)
//                        }
//                    }
//                }
//            }
//
//            let dsm: D
//
//            init(dsm: D) {
//                self.dsm = dsm
//                super.init()
//            }
//
//            override func withRequestBuilder<T>(api: String, method: String = #function, version: ClosedRange<Int>, _ completion: @escaping (T?, Error?) -> Void, _ apply: @escaping (RequestBuilder) throws -> Void) where T : Decodable {
//
//                guard let info = dsm.info(for: api),
//                    info.supportedVersion.overlaps(version),
//                    var urlComponents = URLComponents(url: dsm.url, resolvingAgainstBaseURL: false) else
//                {
//                    // TODO: ...
//                    completion(nil, DSM.Error.todo)
//                    return
//                }
//                urlComponents.dsm_apiPath = info.path
//                guard let url = urlComponents.url else {
//                    completion(nil, DSM.Error.todo)
//                    return
//                }
//                print(">", url)
//                Alamofire.upload(
//                    multipartFormData: { multipartFormData in
//                        let builder = Builder(multipartFormData: multipartFormData, version: version.clamped(to: info.supportedVersion).upperBound)
//                        builder.add(parameter: "api", value: api)
//                        builder.add(parameter: "method", value: method.components(separatedBy: "(").first ?? "no method name??")
//                        builder.add(parameter: "version", value: builder.version)
//                        do {
//                            try apply(builder)
//                        }
//                        catch {
//                            print(error)
//                        }
//                        //                multipartFormData.append(unicornImageURL, withName: "unicorn")
//                        //                multipartFormData.append(rainbowImageURL, withName: "rainbow")
//                    },
//                    to: url,
//                    encodingCompletion: { encodingResult in
//                        switch encodingResult {
//                        case .success(let upload, _, _):
//                            upload.responseData {
//                                guard let data = $0.data else {
//                                    completion(nil, DSM.Error.todo)
//                                    return
//                                }
//                                do {
//                                    let response = try JSONDecoder().decode(Response<T>.self, from: data)
//                                    print("<", response)
//                                    if response.success {
//                                        completion(response.data, nil)
//                                    } else {
//                                        let error = response.error
//                                        print(error.map {
//                                            FileStation.errors[$0.code] ?? API.commonErrors[$0.code] ?? "unknown error"
//                                        } ?? "nil?", error ?? "no error?")
//                                        completion(nil, error)
//                                    }
//                                }
//                                catch {
//                                    print("<", error, String(data: data, encoding: .utf8) ?? "not utf8?")
//                                    completion(nil, error)
//                                }
//                            }
//                        case .failure(let encodingError):
//                            print(encodingError)
//                        }
//                    }
//                    )
//
//            }
//
//        }
        
        var profile = Profile.environment.first
        guard let dsm = profile?.dsm else {
            XCTFail()
            return
        }
        let query = expectation(description: "query")
        let request = API.Info.query()
        do {
            Alamofire.request(try request.url(builder: dsm))
                .responseData {
                    defer { query.fulfill() }
                    guard let data = $0.data else {
                        // TODO: ...
                        print($0.error ?? "no error??")
                        return
                    }
                    do {
                        let _: APIInfoData? = try decode(data: data)
                    }
                    catch {
                        XCTFail(error.localizedDescription)
                    }
            }
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        struct X {
            
        }
//        dsm.fileStation.copyMove.start() { _,_ in // TODO: ugly trick to update apiInfo
//            dsm.multiPartHandler = AlamofireMultipartHandler(dsm: dsm)
//            let url = Bundle(for: type(of: self)).url(forResource: "TheSwiftProgrammingLanguage(Swift4.1)", withExtension: "epub")
//            url.map {
//                dsm.get(dsm.fileStation.upload.upload(path: "/Development", createParents: false, file: $0)) { x, y in }
////                { (data, error) in
////                    print(data ?? "no data?", error ?? "no error")
////                    query.fulfill()
////                }
//            }
//        }
        wait(for: [query], timeout: 100)
    }
    
}
