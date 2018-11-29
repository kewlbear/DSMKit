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
        guard var profile = Profile.main ?? Profile.environment.first else {
            XCTFail()
            return
        }
        let dsm = profile.dsm
        let query = expectation(description: "query")
        let request = API.Auth.login(account: profile.account, password: profile.password, session: "dsmalamo", format: .cookie)
        do {
            print("> login")
            Alamofire.request(try request.url(builder: dsm))
                .responseData {
                    print($0)
                    defer {
                        query.fulfill()
                    }
                    guard let data = $0.data else {
                        // TODO: ...
                        print($0.error ?? "no error??")
                        return
                    }
                    do {
                        let _: APILoginData? = try decode(data: data)
                    }
                    catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            wait(for: [query], timeout: 100)

            let finish = expectation(description: "finish")
            let path = "/Development/안창범/aa"
            let file = Bundle(for: type(of: self)).url(forResource: "TheSwiftProgrammingLanguage(Swift4.1)", withExtension: "epub") ?? URL(fileURLWithPath: "error")
            let upload = FileStation.Upload.upload(path: path, createParents: false, file: file)
            var components = URLComponents(url: try upload.url(builder: dsm), resolvingAgainstBaseURL: false)
            components?.query = nil
            let url = components?.url ?? URL(fileURLWithPath: "")
            print("> upload")
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    try? dsm.buildMultipartFormData(info: upload, to: multipartFormData)
            },
                to: url,
                encodingCompletion: { encodingResult in
                    print("encoding result", encodingResult)
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseData {
                            print("upload response", $0)
                            guard let data = $0.data else {
                                XCTFail()
                                return
                            }
//                            do {
//                                let response = try JSONDecoder().decode(Response<T>.self, from: data)
//                                print("<", response)
//                                if !response.success {
//                                    let error = response.error
//                                    print(error ?? "no error?")
//                                    XCTFail()
//                                }
//                            }
//                            catch {
                                print("<upload",
//                                      error,
                                      String(data: data, encoding: .utf8) ?? "not utf8?")
//                                XCTFail()
//                            }
                            finish.fulfill()
                        }
                    case .failure(let encodingError):
                        print("encoding error", encodingError)
                        XCTFail()
                        finish.fulfill()
                    }
            }
            )
            wait(for: [finish], timeout: 100)
        }
        catch {
            XCTFail(error.localizedDescription)
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
    }
    
}

extension MultipartFormData: ParameterStore {
    public func add<T>(name: String, value: T) where T : ParameterValue {
        if let url = value.value as? URL {
            print(name, url)
            append(url, withName: name, fileName: url.lastPathComponent, mimeType: "application/octet-stream")
        } else {
            guard let data = value.string.data(using: .utf8) else {
                assertionFailure()
                return
            }
            print(name, value.string)
            append(data, withName: name)
        }
    }
}
