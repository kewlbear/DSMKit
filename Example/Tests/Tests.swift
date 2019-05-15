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

import UIKit
import XCTest
@testable
import DSMKit
import DSMKit_Example

class Tests: XCTestCase {
    
    let directory = "/Development/안창범"

    lazy var profile = Profile.main ?? Profile.environment[0]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAPIInfo() {
        get(API.Info.query())
    }
    
    func testLogin() {
        get(API.Auth.login(account: profile.account, password:
            profile.password
//            ""
            , session: "dsmkit", format: .cookie))
    }

    func testFileStationGetInfo() {
        get(FileStation.Info.get())
    }

    func testShareList() {
        get(FileStation.List.listShare())
    }

    func testFileList() {
        var share: Share?
        get(FileStation.List.listShare()) { data, error in
            share = data?.shares.first
        }
        share.map { get(FileStation.List.list(folderPath:
//            "xx" +
            $0.path
            , offset: 1, limit: 2, sortBy: .crtime, sortDirection: .asc, pattern: " ", fileType: .dir, gotoPath: "xxx", additional: [.time])) }
    }
    
    func testCreateFolder() {
        typealias Item = FileStation.CreateFolder.Item
        let items = [
            Item(folderPath:
//                "xx" +
                "\(directory)/aa", name: "a,a"),
            Item(folderPath: "\(directory)/b,b", name: "bb"),
        ]
        get(FileStation.CreateFolder.create(items: items)) { (data, error) in
            print(data ?? "no data", error ?? "no error")
        }
    }
    
    func testRename() {
        typealias Item = FileStation.Rename.Item
        let items = [
            Item(path: "\(directory)/aa", name: "a,a"),
            Item(path: "\(directory)/b,b", name: "bb"),
            ]
        get(FileStation.Rename.rename(items: items)) { (data, error) in
            print(data ?? "no data", error ?? "no error")
        }
    }
    
    func testCopyMove() {
        let paths = [
            "\(directory)/x.zip",
            "\(directory)/folder"
        ]
        let to = "\(directory)/co,py"
        var taskId: String?
        get(FileStation.CopyMove.start(path: paths, destFolderPath: to)) { data, error in
            print(data?.taskId ?? "no data", error ?? "no error")
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            
            taskId = data?.taskId
        }
        get(FileStation.CopyMove.status(taskId: taskId ?? "nil")) { data, error in
            print(data ?? "no data", error ?? "no error")
            XCTAssertNotNil(data)
            XCTAssertNil(error)
        }
    }
    
    func testDelete() {
        let paths = [
            "\(directory)/bb.mkv",
            "\(directory)/bb.smi"
        ]
        var taskId: String?
        get(FileStation.Delete.start(path: paths)) { data, error in
            print(data?.taskId ?? "no data", error ?? "no error")
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            
            taskId = data?.taskId
        }
        get(FileStation.Delete.status(taskId: taskId ?? "nil")) { data, error in
            print(data ?? "no data", error ?? "no error")
            XCTAssertNotNil(data)
            XCTAssertNil(error)
        }
    }
    
    func testError() {
        let errors = [
            makeError(code: 1100, type: CreateFolderError.self),
            makeError(code: 408, type: CreateFolderError.self),
            makeError(code: 104, type: CreateFolderError.self),
        ]
        for error in errors {
            XCTAssertNotNil(error)
        }
        
        XCTAssertNil(makeError(code: 0, type: CreateFolderError.self))
    }
    
    func get<T>(_ info: T?, completion: ((T.DataType?, Error?) -> Void)? = nil) where T: DecodableRequestInfo {
        let done = expectation(description: "done")
        info.map {
        profile.dsm.get($0) { data, error in
//            XCTAssertNotNil(data)
            XCTAssertNil(error)
            completion?(data, error)
            done.fulfill()
        }
        }
        wait(for: [done], timeout: 30)
    }
    
}
