//
//  ViewController.swift
//  DSMKit
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
import DSMKit
import Kingfisher
import KeychainSwift

protocol Item {
    var name: String { get }
    var isDirectory: Bool { get }
    var path: String { get }
    var time: Time? { get }
}

extension Share: Item {
    var isDirectory: Bool { return true }
    var time: Time? { return additional?.time }
}

extension File: Item {
    var time: Time? { return additional?.time }
}

private let placeholderWidth = 40

public func profiles() throws -> [Profile] {
    let environmentName = "TEST_PROFILES"
    guard let string = ProcessInfo.processInfo.environment[environmentName] else {
        print("environment variable '\(environmentName)' not set")
        return []
    }
    let transform: (String) throws -> Profile? = {
        let url = URL(string: $0)
        if url == nil {
            print("invalid url:", $0)
        }
        return try url.map { try Profile(url: $0) }
    }
    #if swift(>=4.1)
    return try string.components(separatedBy: ",").compactMap(transform)
    #else
    return try string.components(separatedBy: ",").flatMap(transform)
    #endif
}

public struct Profile {
    
    public enum Error: Swift.Error {
        case noAccount, noPassword, unknown
    }
    
    public static var main = try? Profile()
    
    public static let environment: [Profile] = (try? profiles()) ?? []
    
    public let url: URL
    
    public let account: String
    
    public let password: String
    
    public lazy var dsm: DSM = {
        return DSM(url: url)
    }()
    
    private enum Keys: String {
        case keychain = "io.github.kewlbear.dsmkit.profile"
    }
    
    public init(url: URL) throws {
        guard let account = url.user, !account.isEmpty else {
            throw Error.noAccount
        }
        guard let password = url.password, !password.isEmpty else {
            throw Error.noPassword
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.user = nil
        components?.password = nil
        guard let url = components?.url else {
            throw Error.unknown
        }
        self.url = url
        self.account = account
        self.password = password
    }
    
    init() throws {
        let keychain = KeychainSwift()
        guard let string = keychain.get(Keys.keychain.rawValue),
            keychain.lastResultCode == noErr else
        {
            print(#function, "keychain error:", keychain.lastResultCode)
            throw Error.unknown
        }
        
        guard let url = URL(string: string) else {
            print(#function, "invalid URL?", string)
            throw Error.unknown
        }
        
        try self.init(url: url)
    }
    
    func save() throws {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error.unknown
        }
        components.user = account
        components.password = password
        guard let url = components.url else {
            throw Error.unknown
        }
        
        let keychain = KeychainSwift()
        keychain.set(url.absoluteString, forKey: Keys.keychain.rawValue)
        if keychain.lastResultCode != noErr {
            print(#function, "keychain error:", keychain.lastResultCode)
            throw Error.unknown
        }
    }
    
}

class ViewController: UITableViewController {

    enum AppError: String, Error {
        case unexpected
    }
    
    var item: Item? {
        didSet {
            item.map { navigationItem.title = $0.name }
        }
    }
    
    var contents = [Item]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    lazy var placeholderImage = UIGraphicsImageRenderer(size: CGSize(width: placeholderWidth, height: placeholderWidth)).image { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        if navigationController?.viewControllers.first == self {
//            if dsm == nil {
//                guard var profile = Profile.main else {
//                    showProfileInputForm(message: "Please enter the following", address: nil, account: nil, password: nil)
//                    return
//                }
//                self.dsm = profile.dsm
//            }
            // TODO: loadShares
            login {
                if let error = $0 {
                    self.handle(error: error) // TODO: showProfileInputForm?
                }
            }
        } else {
            loadFiles()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let child = contents[indexPath.row]
        cell.textLabel?.text = child.name
        let formattedDate = child.time.map { string(from: $0.created) }
        cell.detailTextLabel?.text = "\(formattedDate ?? "N/A")"
        cell.accessoryType = child.isDirectory ? .disclosureIndicator : .none
        cell.imageView?.image = nil
        if URL(fileURLWithPath: child.name).pathExtension.lowercased() == "jpg",
            let dsm = Profile.main?.dsm {
            do {
                let url = try FileStation.Thumb.get(path: child.path, size: .small).url(builder: dsm)
                cell.imageView?.kf.setImage(with: url, placeholder: placeholderImage) { image, error, cacheType, url in
                    print(#function, image ?? "no image", error ?? "no error", cacheType, url ?? "no url?")
                }
            }
            catch {
                print(#function, error)
            }
        }
        return cell
    }
    
    
    // MARK: table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let child = contents[indexPath.row]
        if child.isDirectory {
            guard let viewController = storyboard?.instantiateViewController(withIdentifier: "container") as? ViewController else {
                handle(error: AppError.unexpected)
                return
            }
            viewController.item = child
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            // TODO: ...
            if child.name.lowercased().hasSuffix(".jpg") {
                Profile.main?.dsm.get(FileStation.Thumb.get(path: child.path, size: .small)) { data, response, error in
                    data.map { print(#function, UIImage(data: $0) ?? "not an image", response ?? "no response", error ?? "no error") }
                }
            }
        }
    }
    
}

extension ViewController {
    
    func login(completion: @escaping (Error?) -> Void) {
        guard let profile = Profile.main else {
            completion(AppError.unexpected)
            return
        }
        get(API.Auth.login(account: profile.account, password: profile.password, session: "DSMKitExample", format: .sid)) { [weak self] data in
            do {
                try Profile.main?.save()
            }
            catch {
                completion(error)
            }
            
            Profile.main?.dsm.sessionId = data.sessionId
            
            self?.loadInfo()
            self?.loadShares()
            
            completion(nil)
        }
    }
    
    func loadInfo() {
        get(FileStation.Info.get()) { [weak self] data in
            DispatchQueue.main.async {
                self?.navigationItem.title = data.hostname
            }
        }
    }
    
    func loadShares() {
        get(FileStation.List.listShare(additional: [.time])) { [weak self] data in
            DispatchQueue.main.async {
                self?.contents = data.shares
            }
        }
    }
    
    func loadFiles() {
        guard let path = item?.path else {
            handle(error: AppError.unexpected)
            return
        }
        get(FileStation.List.list(folderPath: path, additional: [.time])) { [weak self] data in
            DispatchQueue.main.async {
                self?.contents = data.files
            }
        }
    }
    
    func get<T>(_ info: T?, caller: String = #function, completion: @escaping (T.DataType) -> Void) where T: DecodableRequestInfo {
        guard let dsm = Profile.main?.dsm, let info = info else {
            // TODO: ?
            print(#function, "\(caller): dsm or info is nil")
            return
        }
        print(#function, "\(caller):", info)
        dsm.get(info) { [weak self] (data, error) in
            guard let data = data else {
                self?.handle(error: error ?? AppError.unexpected)
                return
            }
            completion(data)
        }
    }
    
    func handle(error: Error) {
        let error = error as NSError
        print(FileStation.errors[error.code] ?? API.commonErrors[error.code] ?? "unknown")
        let profile = Profile.main
        showProfileInputForm(message: "Please enter the follwing", address: profile?.url.absoluteString, account: profile?.account, password: profile?.password)
//        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
    }
    
    func string(from time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        return dateFormatter.string(from: date)
    }
    
    func showProfileInputForm(message: String, address: String?, account: String?, password: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addTextField {
            $0.text = address
            $0.placeholder = "http://192.168.1.1:5000"
        }
        alert.addTextField {
            $0.text = account
            $0.placeholder = "Account"
        }
        alert.addTextField {
            $0.text = password
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let textFields = alert.textFields,
                textFields.count > 2 else
            {
                self.handle(error: AppError.unexpected)
                assertionFailure()
                return
            }
            self.validate(address: textFields[0].text, account: textFields[1].text, password: textFields[2].text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func validate(address: String?, account: String?, password: String?) {
        guard var components = URLComponents(string: address ?? "no address") else
        {
            showProfileInputForm(message: "Please verify your input", address: address, account: account, password: password)
            return
        }
        components.user = account
        components.password = password
        do {
            Profile.main = try components.url.map { try Profile(url: $0) }
            login {
                if let error = $0 {
                    self.showProfileInputForm(message: error.localizedDescription, address: address, account: account, password: password)
                }
            }
        }
        catch {
            showProfileInputForm(message: "Please verify your input", address: address, account: account, password: password)
        }
    }
    
}
