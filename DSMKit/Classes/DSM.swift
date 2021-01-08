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

// MARK: DSM errors

public protocol DSMError: CustomNSError, RawRepresentable, CustomStringConvertible where RawValue == Int {
    associatedtype BaseError: DSMError
    
    var errors: [FileErrorDetail]? { get }
}

extension DSMError {
    public var errors: [FileErrorDetail]? { return nil }
    
    public var description: String { return localizedDescription }
}

struct FileError: CustomNSError {
    // FIXME: https://stackoverflow.com/a/43408193/2570853
//    static var errorDomain: String { return T.errorDomain }
    
    var error: Error
    
    var errors: [FileErrorDetail]?
    
    var errorCode: Int { return (error as? CustomNSError)?.errorCode ?? 0 }
    
    var errorUserInfo: [String : Any] {
        guard let errors = errors else {
            return [:]
        }
        return ["errors": errors]
    }
    
    var localizedDescription: String { return error.localizedDescription }
}

public enum APIError: Int, DSMError {
    public typealias BaseError = APIError
    
    /// Unknown error
    case unknown = 100
    /// No parameter of API, method or version
    case missingParameter = 101
    /// The requested API does not exist
    case apiNotFound = 102
    /// The requested method does not exist
    case methodNotFound = 103
    /// The requested version does not support the functionality
    case unsupportedVersion = 104
    /// The logged in session does not have permission
    case permission = 105
    /// Session timeout
    case sessionTimedOut = 106
    /// Session interrupted by duplicate login
    case duplicateLogin = 107
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .missingParameter:
            return "No parameter of API, method or version"
        case .apiNotFound:
            return "The requested API does not exist"
        case .methodNotFound:
            return "The requested method does not exist"
        case .unsupportedVersion:
            return "The requested version does not support the functionality"
        case .permission:
            return "The logged in session does not have permission"
        case .sessionTimedOut:
            return "Session timeout"
        case .duplicateLogin:
            return "Session interrupted by duplicate login"
        }
    }
}

public enum AuthError: Int, DSMError {
    public typealias BaseError = APIError
    
    /// No such account or incorrect password
    case invalidCredential = 400
    /// Account disabled
    case accountDisabled = 401
    /// Permission denied
    case authPermission = 402
    /// 2-step verification code required
    case missingTwoStepVerificationCode = 403
    /// Failed to authenticate 2-step verification code
    case invalidTwoStepVerificationCode = 404
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "No such account or incorrect password"
        case .accountDisabled:
            return "Account disabled"
        case .authPermission:
            return "Permission denied"
        case .missingTwoStepVerificationCode:
            return "2-step verification code required"
        case .invalidTwoStepVerificationCode:
            return "Failed to authenticate 2-step verification code"
        }
    }
}

public enum FileStationError: Int, DSMError {
    public typealias BaseError = APIError
    
    /// Invalid parameter of file operation
    case invalidFileOperationParameter = 400
    /// Unknown error of file operation
    case unknownFileOperationError = 401
    /// System is too busy
    case systemBusy = 402
    /// Invalid user does this file operation
    case invalidFileOperationUser = 403
    /// Invalid group does this file operation
    case invalidFileOperationGroup = 404
    /// Invalid user and group does this file operation
    case invalidFileOperationUserGroup = 405
    /// Can’t get user/group information fr the account server
    case userGroupUnavailableFromAccountServer = 406
    /// Operation not permitted
    case filePermission = 407
    /// No such file or directory
    case notFound = 408
    /// Non-supported file system
    case unsupportedFileSystem = 409
    /// Failed to connect internet-based file syst (ex: CIFS)
    case networkFileSystemNotConnected = 410
    /// Read-only file system
    case readOnlyFileSystem = 411
    /// Filename too long in the non-encrypted file system
    case filenameTooLong = 412
    /// Filename too long in the encrypted file system
    case filenameTooLongForEncryptedFileSystem = 413
    /// File already exists
    case exists = 414
    /// Disk quota exceeded
    case quota = 415
    /// No space left on device
    case full = 416
    /// Input/output error
    case inputOutput = 417
    /// Illegal name or path
    case illegalPath = 418
    /// Illegal file name
    case illegalFilename = 419
    /// Illegal file name on FAT file system
    case illegalFilenameFAT = 420
    /// Device or resource busy
    case deviceBusy = 421
    /// No such task of the file operation
    case taskNotFound = 599
}

extension FileStationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidFileOperationParameter:
            return "Invalid parameter of file operation"
        case .unknownFileOperationError:
            return "Unknown error of file operation"
        case .systemBusy:
            return "System is too busy"
        case .invalidFileOperationUser:
            return "Invalid user does this file operation"
        case .invalidFileOperationGroup:
            return "Invalid group does this file operation"
        case .invalidFileOperationUserGroup:
            return "Invalid user and group does this file operation"
        case .userGroupUnavailableFromAccountServer:
            return "Can’t get user/group information fr the account server"
        case .filePermission:
            return "Operation not permitted"
        case .notFound:
            return "No such file or directory"
        case .unsupportedFileSystem:
            return "Non-supported file system"
        case .networkFileSystemNotConnected:
            return "Failed to connect internet-based file syst (ex: CIFS)"
        case .readOnlyFileSystem:
            return "Read-only file system"
        case .filenameTooLong:
            return "Filename too long in the non-encrypted file system"
        case .filenameTooLongForEncryptedFileSystem:
            return "Filename too long in the encrypted file system"
        case .exists:
            return "File already exists"
        case .quota:
            return "Disk quota exceeded"
        case .full:
            return "No space left on device"
        case .inputOutput:
            return "Input/output error"
        case .illegalPath:
            return "Illegal name or path"
        case .illegalFilename:
            return "Illegal file name"
        case .illegalFilenameFAT:
            return "Illegal file name on FAT file system"
        case .deviceBusy:
            return "Device or resource busy"
        case .taskNotFound:
            return "No such task of the file operation"
        }
    }
}

public enum FavoriteError: Int, DSMError {
    public typealias BaseError = FileStationError
    
    /// A folder path of favorite folder is already added to user’s favorites.
    case favoriteExists = 800
    /// A name of favorite folder conflicts with an existing folder path in t user’s favorites.
    case favoriteFolderNameConflict = 801
    /// There are too many favorites to be added.
    case tooManyFavorites = 802
}

extension FavoriteError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .favoriteExists:
            return "A folder path of favorite folder is already added to user’s favorites."
        case .favoriteFolderNameConflict:
            return "A name of favorite folder conflicts with an existing folder path in t user’s favorites."
        case .tooManyFavorites:
            return "There are too many favorites to be added."
        }
    }
}

public enum CopyMoveError: Int, DSMError {
    public typealias BaseError = FileStationError
    
    /// Failed to copy files/folders. More information in <errors> object.
    case failedCopy = 1000
    /// Failed to move files/folders. More information in <errors> object.
    case failedMove = 1001
    /// An error occurred at the destination. More information in <errors> object.
    case copyDestination = 1002
    /// Cannot overwrite or skip the existing file because no overwrite parameter given.
    case copyExists = 1003
    /// File cannot overwrite a folder with the same name, or folder cannot overwrite file with the same name.
    case invalidOverwrite = 1004
    /// Cannot copy/move file/folder with special characters to a FAT32 file system.
    case invalidFAT32Filename = 1006
    /// Cannot copy/move a file bigger than 4G to a FAT32 file system.
    case copyTooBigForFAT32 = 1007
}

extension CopyMoveError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedCopy:
            return "Failed to copy files/folders. More information in <errors> object."
        case .failedMove:
            return "Failed to move files/folders. More information in <errors> object."
        case .copyDestination:
            return "An error occurred at the destination. More information in <errors> object."
        case .copyExists:
            return "Cannot overwrite or skip the existing file because no overwrite parameter given."
        case .invalidOverwrite:
            return "File cannot overwrite a folder with the same name, or folder cannot overwrite file with the same name."
        case .invalidFAT32Filename:
            return "Cannot copy/move file/folder with special characters to a FAT32 file system."
        case .copyTooBigForFAT32:
            return "Cannot copy/move a file bigger than 4G to a FAT32 file system."
        }
    }
}

public enum CreateFolderError: Int, DSMError {
    public typealias BaseError = FileStationError
    
    /// Failed to create a folder. More information in <errors> object.
    case failedCreateFolder = 1100
    /// The number of folders to the parent folder would exceed the system limitation.
    case tooManyFolders = 1101
}

extension CreateFolderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedCreateFolder:
            return "Failed to create a folder. More information in <errors> object."
        case .tooManyFolders:
            return "The number of folders to the parent folder would exceed the system limitation."
        }
    }
}

public enum RenameError: Int, DSMError {
    public typealias BaseError = FileStationError
    
    /// Failed to rename it. More information in <errors> object
    case failedRename = 1200
}

extension RenameError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedRename:
            return "Failed to rename it. More information in <errors> object"
        }
    }
}

public enum CompressError: Int, CustomNSError {
    /// Failed to compress files/folders.
    case filedCompress = 1300
    /// Cannot create the archive because the given archive name is too long.
    case archiveNameTooLong = 1301
}

extension CompressError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .filedCompress:
            return "Failed to compress files/folders."
        case .archiveNameTooLong:
            return "Cannot create the archive because the given archive name is too long."
        }
    }
}

public enum ExtractError: Int, CustomNSError {
    /// Failed to extract files.
    case failedExtract = 1400
    /// Cannot open the file as archive.
    case notArchive = 1401
    /// Failed to read archive data error
    case readArchive = 1402
    /// Wrong password.
    case incorrectPassword = 1403
    /// Failed to get the file and dir list in an archive.
    case listArchive = 1404
    /// Failed to find the item ID in an archive file.
    case itemID = 1405
}

extension ExtractError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedExtract:
            return "Failed to extract files."
        case .notArchive:
            return "Cannot open the file as archive."
        case .readArchive:
            return "Failed to read archive data error"
        case .incorrectPassword:
            return "Wrong password."
        case .listArchive:
            return "Failed to get the file and dir list in an archive."
        case .itemID:
            return "Failed to find the item ID in an archive file."
        }
    }
}

public enum UploadError: Int, DSMError {
    public typealias BaseError = FileStationError
    
    /// There is no Content-Length information in the HTTP header or the received size doesn’t match the value of Content-Length information in the HTTP header.
    case invalidContentLength = 1800
    /// Wait too long, no date can be received from client (Default maximum wait time is 3600 seconds).
    case uploadTimedOut = 1801
    /// No filename information in the last part of file content.
    case noFilename = 1802
    /// Upload connection is cancelled.
    case connectionCancelled = 1803
    /// Failed to upload too big file to FAT file system.
    case uploadTooBigForFAT = 1804
    /// Can’t overwrite or skip the existed file, if no overwrite parameter is given.
    case uploadFileExists = 1805
}

extension UploadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidContentLength:
            return "There is no Content-Length information in the HTTP header or the received size doesn’t match the value of Content-Length information in the HTTP header."
        case .uploadTimedOut:
            return "Wait too long, no date can be received from client (Default maximum wait time is 3600 seconds)."
        case .noFilename:
            return "No filename information in the last part of file content."
        case .connectionCancelled:
            return "Upload connection is cancelled."
        case .uploadTooBigForFAT:
            return "Failed to upload too big file to FAT file system."
        case .uploadFileExists:
            return "Can’t overwrite or skip the existed file, if no overwrite parameter is given."
        }
    }
}

public enum SharingError: Int, CustomNSError {
    /// Sharing link does not exist.
    case linkNotFound = 2000
    /// Cannot generate sharing link because too many sharing links exist.
    case tooManyLinks = 2001
    /// Failed to access sharing links.
    case inaccessibleLink = 2002
}

extension SharingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .linkNotFound:
            return "Sharing link does not exist."
        case .tooManyLinks:
            return "Cannot generate sharing link because too many sharing links exist."
        case .inaccessibleLink:
            return "Failed to access sharing links."
        }
    }
}

// MARK: Foundation extensions

extension URLQueryItem {
    
    init(parameter: ParameterName, value: String) {
        self.init(name: parameter.rawValue, value: value)
    }
    
}

extension URLComponents {
    
    public var dsm_apiPath: String {
        get { return path.replacingOccurrences(of: API_PREFIX, with: "") }
        set { path = "\(API_PREFIX)\(newValue)" }
    }
    
    mutating func dsm_addQueryItems(api: String, version: Version, sessionId: String? = nil) {
        let newItems = [
            URLQueryItem(parameter: .api, value: api),
            URLQueryItem(parameter: .version, value: "\(version)")
        ]
        var queryItems = self.queryItems ?? []
        queryItems.append(contentsOf: newItems)
        sessionId.map { queryItems.append(URLQueryItem(parameter: .sessionId, value: $0)) }
        self.queryItems = queryItems
    }
    
}

func makeError<T>(code: Int, type: T.Type) -> Error? where T: DSMError {
    if let error = T(rawValue: code) {
        return error
    }
    guard T.BaseError.self != type else {
        return nil
    }
    return makeError(code: code, type: T.BaseError.self)
}
