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

/// All File Station APIs are required to login with SYNO.API.Auth and session=FileStation.
public enum FileStation: Namespace {
    
    public enum FileAdditional: String {
        /// return a real path in volume
        case real_path
        /// return file byte size
        case size
        /// return information about file owner including user name, group name, UID and GID
        case owner
        /// return information about time including last access time, last modified time, last change time and create time
        case time
        /// return information about file permission
        case perm
        /// return a type of a virtual file system of a mount point
        case mount_point_type
        /// return a file extension
        case type
    }
    
    public static let commonErrors = [
        400: "Invalid parameter of file operation",
        401: "Unknown error of file operation",
        402: "System is too busy",
        403: "Invalid user does this file operation",
        404: "Invalid group does this file operation",
        405: "Invalid user and group does this file operation",
        406: "Can’t get user/group information from the account server",
        407: "Operation not permitted",
        408: "No such file or directory",
        409: "Non-supported file system",
        410: "Failed to connect internet-based file system (ex: CIFS)",
        411: "Read-only file system",
        412: "Filename too long in the non-encrypted file system",
        413: "Filename too long in the encrypted file system",
        414: "File already exists",
        415: "Disk quota exceeded",
        416: "No space left on device",
        417: "Input/output error",
        418: "Illegal name or path",
        419: "Illegal file name",
        420: "Illegal file name on FAT file system",
        421: "Device or resource busy",
        599: "No such task of the file operation"
    ]
    
    public static let errors: [Int: String] = {
        var errors = commonErrors
        // TODO: ...
        errors.merge(Upload.errors, uniquingKeysWith: { _, new in new })
        return errors
    }()
    
    public enum Info: MethodContainer {
        
        public static func get() -> BasicRequestInfo<FileStationInfoData> {
            return BasicRequestInfo<FileStationInfoData>(api: api, availability: 2..., previousMethodNames: [("getinfo", 1...)], versions: 1...2) { encoder in
                
            }
        }
        
    }
    
    public enum List: MethodContainer {
        
            public enum ShareAdditional: String {
                /// return a real path in volume
                case real_path
                /// return file byte size
                case size
                /// return information about file owner including user name, group name, UID and GID
                case owner
                /// return information about time including last access time, last modified time, last change time and create time
                case time
                /// return information about file permission
                case perm
                /// return a type of a virtual file system of a mount point
                case mount_point_type
                /// return volume statuses including free space, total space and read-only status
                case volume_status
            }

            /// List all shared folders.
            /// - Parameters:
            ///   - offset: Specify how many shared folders are skipped before beginning to return listed shared folders.
            ///   - limit: Number of shared folders requested. 0 lists all shared folders.
            ///   - sortBy: Specify which file information to sort on.
            ///   - sortDirection: Specify to sort ascending or to sort descending.
            ///   - onlyWritable: “true”: List writable shared folders; “false”: List writable and read-only shared folders.
            ///   - additional: Additional requested file information. When an additional option is requested, responded objects will be provided in the specified additional option.
            public static func listShare(offset: Int? = nil, limit: Int? = nil, sortBy: SortBy? = nil, sortDirection: SortDirection? = nil, onlyWritable: Bool? = nil, additional: Set<ShareAdditional>? = nil) -> BasicRequestInfo<ShareList> {
                return BasicRequestInfo<ShareList>(api: api, method: "list_share", versions: 1...2) { encoder in
                    offset.map { encoder["offset"] = $0 }
                    limit.map { encoder["limit"] = $0 }
                    sortBy.map { encoder["sort_by"] = $0 }
                    sortDirection.map { encoder["sort_direction"] = $0 }
                    onlyWritable.map { encoder["onlywritable"] = $0 }
                    additional.map { encoder["additional"] = $0 }
                }
            }

            /// Enumerate files in a given folder
            /// - Parameters:
            ///   - folderPath: A listed folder path started with a shared folder.
            ///   - offset: Specify how many files are skipped before beginning to return listed files.
            ///   - limit: Number of files requested. 0 indicates to list all files with a given folder.
            ///   - sortBy: Specify which file information to sort on.
            ///   - sortDirection: Specify to sort ascending or to sort descending
            ///   - pattern: Glob patterns
            ///     find files whose names and extensions match a case- insensitive glob pattern.
            ///     Note:
            ///       1. If the pattern doesn’t contain any glob syntax (? and *), * of glob syntax will be added at begin and end of the string automatically for partially matching the pattern.
            ///       2. You can use ”,” to separate multiple glob patterns.
            ///   - gotoPath: Folder path started with a shared folder. Return all files and sub-folders within folder_path path until goto_path path recursively.
            ///   - additional: Additional requested file information. When an additional option is requested, responded objects will be provided in the specified additional option.
            public static func list(folderPath: String, offset: Int? = nil, limit: Int? = nil, sortBy: SortBy? = nil, sortDirection: SortDirection? = nil, pattern: String? = nil, fileType: FileType? = nil, gotoPath: String? = nil, additional: Set<FileAdditional>? = nil) -> BasicRequestInfo<FileList> {
                return BasicRequestInfo<FileList>(api: api, versions: 1...2) { encoder in
                    encoder["folder_path"] = Path(path: folderPath)
                    offset.map { encoder["offset"] = $0 }
                    limit.map { encoder["limit"] = $0 }
                    sortBy.map { encoder["sort_by"] = $0 }
                    sortDirection.map { encoder["sort_direction"] = $0 }
                    pattern.map { encoder["pattern"] = $0 }
                    fileType.map { encoder["filetype"] = $0 }
                    gotoPath.map { encoder["goto_path"] = $0 }
                    additional.map { encoder["additional"] = $0 }
                }
            }

    }
    
    public enum Favorite: MethodContainer {
        public static let errors = [
            800: "A folder path of favorite folder is already added to user’s favorites.",
            801: "A name of favorite folder conflicts with an existing folder path in the user’s favorites.",
            802: "There are too many favorites to be added."
        ]
    }
    
    /// Get a thumbnail of a file.
    /// 1. Supported image formats: jpg, jpeg, jpe, bmp, png, tif, tiff, gif, arw, srf, sr2, dcr, k25, kdc, cr2, crw, nef, mrw, ptx, pef, raf, 3fr, erf, mef, mos, orf, rw2, dng, x3f, raw
    /// 2. Supported video formats in an indexed folder: 3gp, 3g2, asf, dat, divx, dvr-ms, m2t, m2ts, m4v, mkv, mp4, mts, mov, qt, tp, trp, ts, vob, wmv, xvid, ac3, amr, rm, rmvb, ifo, mpeg, mpg, mpe, m1v, m2v, mpeg1, mpeg2, mpeg4, ogv, webm, flv, f4v, avi, swf, vdr, iso
    ///   PS: Video thumbnails exist only if video files are placed in the “photo” shared folder or users' home folders.
    public enum Thumb: MethodContainer {
        public enum Size: String {
            case small, medium, large, original
        }

        public enum Rotation: Int {
            /// Do not rotate
            case none
            
            /// Rotate 90°
            case degrees90
            
            /// Rotate 180°
            case degrees180
            
            /// Rotate 270°
            case degrees270
        
            /// Rotate 360°
            case degrees360
        }
        
        /// Get a thumbnail of a file.
        /// - Parameters:
        ///   - path: A file path started with a shared folder.
        ///   - size: Return different size thumbnail. (404 if missing for DSM 6)
        ///   - rotate: Return rotated thumbnail.
        public static func get(path: String, size: Size, rotate: Rotation? = nil) -> VanillaRequestInfo {
            return VanillaRequestInfo(api: api, versions: 1...2) { params in
                params["path"] = Path(path: path)
                params["size"] = size.rawValue
                rotate.map { params["rotate"] = $0.rawValue }
            }
        }
    }
    
    public enum Upload: MethodContainer {
        
        public static func upload(path: String, createParents: Bool, overwrite: Bool? = nil, mtime: Date? = nil, crtime: Date? = nil, atime: Date? = nil, file: URL) -> BasicRequestInfo<UploadData> {
            return BasicRequestInfo<UploadData>(api: api, versions: 1...2) {
                let kPath = BasicValue("path", availability: 2..., previousValues: [("dest_folder_path", 1...)])
                $0[kPath] = path//, versions: 1...1)
                $0["create_parents"] = createParents
                // TODO: ...
                $0["file"] = file
            }
        }
        
        public static let errors = [
            1800: "There is no Content-Length information in the HTTP header or the received size doesn’t match the value of Content-Length information in the HTTP header.",
            1801: "Wait too long, no date can be received from client (Default maximum wait time is 3600 seconds).",
            1802: "No filename information in the last part of file content.",
            1803: "Upload connection is cancelled.",
            1804: "Failed to upload too big file to FAT file system.",
            1805: "Can’t overwrite or skip the existed file, if no overwrite parameter is given."
        ]
        
//            init(path: String, createParents: Bool, overwrite: Bool? = nil, mtime: Date? = nil, crtime: Date? = nil, atime: Date? = nil, url: URL) {
//                super.init()
//                add(parameter: "path", value: path, availability: 1...) // TODO: dest_folder_path (v1)
//                add(parameter: "create_parents", value: createParents, availability: 1...)
//                overwrite.map { add(parameter: "overwrite", value: $0, availability: 1...) }
//                mtime.map { add(parameter: "mtime", value: $0, availability: 1...) }
//                crtime.map { add(parameter: "crtime", value: $0, availability: 1...) }
//                atime.map { add(parameter: "atime", value: $0, availability: 1...) }
//                add(parameter: "filename", value: url, availability: 1...)
//            }
            
    }
    
    public enum Download: MethodContainer {
        
        public enum Mode: String {
            case open
            case download
        }
        
        // TODO: ...
        public static func download(path: String, mode: Mode) -> BasicRequestInfo<Data> {
            return BasicRequestInfo<Data>(api: api, versions: 1...1) {
                $0["path"] = path//, versions: 2...)
                $0["mode"] = mode.rawValue
            }
        }

    }

    public enum Sharing: MethodContainer {
        public static let errors = [
            2000: "Sharing link does not exist.",
            2001: "Cannot generate sharing link because too many sharing links exist.",
            2002: "Failed to access sharing links."
        ]
    }

    public enum CreateFolder: MethodContainer {
        public static let errors = [
            1100: "Failed to create a folder. More information in <errors> object.",
            1101: "The number of folders to the parent folder would exceed the system limitation."
        ]
        
        public struct Item {
            let folderPath: String
            let name: String
            
            public init(folderPath: String, name: String) {
                self.folderPath = folderPath
                self.name = name
            }
        }
        
        public static func create(items: [Item], forceParent: Bool? = nil, additional: Set<FileAdditional>? = nil) -> BasicRequestInfo<CreateFolderData> {
            return BasicRequestInfo<CreateFolderData>(api: api, versions: 1...2) { encoder in
                var paths = [String]()
                var names = [String]()
                for item in items {
                    paths.append(item.folderPath)
                    names.append(item.name)
                }
                encoder["folder_path"] = Values(values: paths)
                encoder["name"] = Values(values: names)
                forceParent.map { encoder["force_parent"] = $0 }
                additional.map { encoder["additional"] = $0 }
            }
        }
    }
    
    public enum Rename: MethodContainer {
        public static let errors = [
            1200: "Failed to rename it. More information in <errors> object."
        ]
        
        public struct Item {
            /// path of a file/folder to be renamed
            let path: String
            
            /// new name
            let name: String
            
            public init(path: String, name: String) {
                self.path = path
                self.name = name
            }
        }

        /// Rename a file/folder
        /// - Parameters:
        ///   - items: One or more items to be renamed.
        ///   - additional: Additional requested file information. When an additional option is requested, responded objects will be provided in the specified additional option.
        ///   - searchTaskId: A unique ID for the search task which is obtained from start method. It is used to update the renamed file in the search result.
        public static func rename(items: [Item], additional: Set<FileAdditional>? = nil, searchTaskId: String? = nil) -> BasicRequestInfo<RenameData> {
            return BasicRequestInfo<RenameData>(api: api, versions: 1...2) { encoder in
                var paths = [String]()
                var names = [String]()
                for item in items {
                    paths.append(item.path)
                    names.append(item.name)
                }
                encoder["path"] = Values(values: paths)
                encoder["name"] = Values(values: names)
                additional.map { encoder["additional"] = $0 }
                searchTaskId.map { encoder["search_taskid"] = $0 }
            }
        }
    }
    
    public enum CopyMove: MethodContainer {
        public static let errors = [
            1000: "Failed to copy files/folders. More information in <errors> object.",
            1001: "Failed to move files/folders. More information in <errors> object.",
            1002: "An error occurred at the destination. More information in <errors> object.",
            1003: "Cannot overwrite or skip the existing file because no overwrite parameter is given.",
            1004: "File cannot overwrite a folder with the same name, or folder cannot overwrite a file with the same name.",
            1006: "Cannot copy/move file/folder with special characters to a FAT32 file system.",
            1007: "Cannot copy/move a file bigger than 4G to a FAT32 file system."
        ]
        
        public static func start(path: [String], destFolderPath: String, overwrite: Bool? = nil, removeSrc: Bool? = nil, accurateProgress: Bool? = nil, searchTaskId: String? = nil) -> BasicRequestInfo<CopyMoveData> {
            return BasicRequestInfo<CopyMoveData>(api: api, versions: 1...1) { encoder in
                encoder["path"] = Values(values: path) //, versions: 2...)
                encoder["dest_folder_path"] = Path(path: destFolderPath)
                overwrite.map { encoder["overwrite"] = $0 }
                removeSrc.map { encoder["remove_src"] = $0 }
                accurateProgress.map { encoder["accurate_progress"] = $0 }
                searchTaskId.map { encoder["search_taskid"] = $0 }
            }
        }
        
        public static func status(taskId: String) -> BasicRequestInfo<CopyMoveStatusData> {
            return BasicRequestInfo<CopyMoveStatusData>(api: api, versions: 1...1) {
                $0["taskid"] = taskId//, versions: 2...)
            }
        }
        
        // TODO: stop()
    }
    
    public enum Delete: MethodContainer {
        public static let errors = [
            900: "Failed to delete file(s)/folder(s). More information in <errors> object."
        ]
        
        public static func start(path: [String], accurateProgress: Bool? = nil, recursive: Bool? = nil, searchTaskId: String? = nil) -> BasicRequestInfo<DeleteData> {
            return BasicRequestInfo<DeleteData>(api: api, versions: 1...1) { encoder in
                encoder["path"] = Values(values: path) //, versions: 2...)
                accurateProgress.map { encoder["accurate_progress"] = $0 }
                recursive.map { encoder["recursive"] = $0 }
                searchTaskId.map { encoder["search_taskid"] = $0 }
            }
        }

        public static func status(taskId: String) -> BasicRequestInfo<DeleteStatusData> {
            return BasicRequestInfo<DeleteStatusData>(api: api, versions: 1...1) {
                $0["taskid"] = taskId//, versions: 2...)
            }
        }
        
        // TODO: stop(), delete()
    }
    
    public enum Extract: MethodContainer {
        public static let errors = [
            1400: "Failed to extract files.",
            1401: "Cannot open the file as archive.",
            1402: "Failed to read archive data error",
            1403: "Wrong password.",
            1404: "Failed to get the file and dir list in an archive.",
            1405: "Failed to find the item ID in an archive file."
        ]
    }
    
    public enum Compress: MethodContainer {
        public static let errors = [
            1300: "Failed to compress files/folders.",
            1301: "Cannot create the archive because the given archive name is too long."
        ]
    }
    
    // TODO: ...
    
}

//extension Set where Element == FileStation.List.ListShare.Additional {
//    public static var all: Set<FileStation.List.ListShare.Additional> {
//        return [
//            .real_path, .size, .owner, .time, .perm, .mount_point_type, .volume_status
//        ]
//    }
//}

/// Specify which file information to sort on
public enum SortBy: String, Value {
    /// file name
    case name
    /// file size
    case size
    /// file owner
    case user
    /// file group
    case group
    /// last modified time
    case mtime
    /// last access time
    case atime
    /// last change time
    case ctime
    /// create time
    case crtime
    /// POSIX permission
    case posix
    /// file extension
    case type
}

/// Specify to sort ascending or to sort descending
public enum SortDirection: String, Value {
    /// sort ascending
    case asc
    /// sort descending
    case desc
}

public enum FileType: String, Value {
    /// only enumerate regular files
    case file
    /// only enumerate folders
    case dir
    /// enumerate regular files and folders
    case all
}

public struct FileStationInfoData {
    
    /// If the logged-in user is an administrator.
    public let isManager: Bool
    
    /// Types of virtual file systems which the logged user is able to mount. DSM 6.0 supports CIFS, NFS, and ISO virtual file systems. Different types are separated with a comma, for example: cifs,nfs,iso.
    public var supportedVirtualFileSystems: [String]

    public struct SupportVirtual: Codable {
        let enable_iso_mount: Bool
        let enable_remote_mount: Bool
    }
    
    public let support_virtual: SupportVirtual?
    
    /// Whether the logged-in user can share file(s)/folder(s) or not.
    public let isSharingSupported: Bool
    
    /// DSM hostname.
    public let hostname: String
    
    enum CodingKeys: String, CodingKey {
        case isManager = "is_manager"
        case supportedVirtualFileSystems = "support_virtual_protocol"
        case support_virtual
        case isSharingSupported = "support_sharing"
        case hostname
    }
    
}

extension FileStationInfoData: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isManager = try container.decode(Bool.self, forKey: .isManager)
        if container.contains(.supportedVirtualFileSystems) {
            supportedVirtualFileSystems = try container.decode([String].self, forKey: .supportedVirtualFileSystems)
            support_virtual = try container.decode(SupportVirtual.self, forKey: .support_virtual)
        } else {
            supportedVirtualFileSystems = try container.decode(String.self, forKey: .support_virtual).components(separatedBy: ",")
            support_virtual = nil
        }
        isSharingSupported = try container.decode(Bool.self, forKey: .isSharingSupported)
        hostname = try container.decode(String.self, forKey: .hostname)
        // TODO: ?
    }
}

public struct FileList: Codable {
    /// Total number of files.
    public let total: Int
    
    /// Requested offset.
    public let offset: Int
    
    /// Array of <file> objects.
    public let files: [File]
}

public struct ShareList: Codable {
    /// Total number of shared folders.
    public let total: Int
    
    /// Requested offset.
    public let offset: Int
    
    /// Array of <shared folder> objects.
    public let shares: [Share]
}

public struct Share: Codable {
    /// Path of a shared folder.
    public let path: String
    
    /// Name of a shared folder.
    public let name: String
    
    /// Shared-folder additional object.
    public struct Additional: Codable {
        /// Real path of a shared folder in a volume space.
        public let realPath: String?
        
        /// File owner information including user name, group name, UID and GID.
        public let owner: Owner?
        
        /// Time information of file including last access time, last modified time, last change time, and creation time.
        public let time: Time?
        
        /// File permission information.
        public struct Permission: Codable {
            
            /// “RW: The shared folder is writable; “RO”: the shared folder is read-only.
            public let shareRight: String
            
            /// POSIX file permission, For example, 777 means owner, group or other has all permission; 764 means owner has all permission, group has read/write permission, other has read permission.
            public let posix: Int
            
            /// Specail privelge of the shared folder.
            public struct AdvancedRight: Codable {
                
                /// If a non-administrator user can download files in this shared folder through SYNO.FileStation.Download API or not.
                public let disableDownload: Bool
                
                /// If a non-administrator user can enumerate files in this shared folder though SYNO.FileStation.List API with list method or not.
                public let disableList: Bool
                
                /// If a non-administrator user can modify or overwrite files in this shared folder or not.
                public let disableModify: Bool
                
                enum CodingKeys: String, CodingKey {
                    case disableDownload = "disable_download"
                    case disableList = "disable_list"
                    case disableModify = "disable_modify"
                }
            }
            
            public let advancedRight: AdvancedRight
            
            /// If the configure of Windows ACL privilege of the shared folder is enabled or not.
            public let aclEnable: Bool
            
            /// “true”: The privilege of the shared folder is set to be ACL-mode. “false”: The privilege of the shared folder is set to be POSIX-mode.
            public let isACLMode: Bool
            
            /// Windows ACL privilege. If a shared folder is set to be POSIX-mode, these values of Windows ACL privileges are derived from the POSIX privilege.
            public let acl: ACL
            
            enum CodingKeys: String, CodingKey {
                case shareRight = "share_right"
                case posix
                case advancedRight = "adv_right"
                case aclEnable = "acl_enable"
                case isACLMode = "is_acl_mode"
                case acl
            }
        }
        
        public let permission: Permission?
        
        /// Type of a virtual file system of a mount point.
        public let mountPointType: String?
        
        /// Volume status including free space, total space and read-only status.
        public struct VolumeStatus: Codable {
            
            /// Byte size of free space of a volume where a shared folder is located.
            public let freeSpace: Int
            
            /// Byte size of total space of a volume where a shared folder is located.
            public let totalSpace: Int
            
            /// “true”: A volume where a shared folder is located is read-only; “false”: It’s writable.
            public let readOnly: Bool
            
            enum CodingKeys: String, CodingKey {
                case freeSpace = "freespace"
                case totalSpace = "totalspace"
                case readOnly = "readonly"
            }
        }
        
        public let volumeStatus: VolumeStatus?
        
        enum CodingKeys: String, CodingKey {
            case realPath = "real_path"
            case owner
            case time
            case permission = "perm"
            case mountPointType = "mount_point_type"
            case volumeStatus = "volume_status"
        }
    }
    
    public let additional: Additional?
}

public struct ACL: Codable {
    
    /// If a logged-in user has a privilege to append data or create folders within this folder or not.
    public let append: Bool
    
    /// If a logged-in user has a privilege to delete a file/a folder within this folder or not.
    public let del: Bool
    
    /// If a logged-in user has a privilege to execute files/traverse folders within this folder or not.
    public let exec: Bool
    
    /// If a logged-in user has a privilege to read data or list folder within this folder or not.
    public let read: Bool
    
    /// If a logged-in user has a privilege to write data or create files within this folder or not.
    public let write: Bool
    
}

public struct CopyMoveData: Codable {
    public let taskId: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "taskid"
    }
}

public struct CopyMoveStatusData: Codable {
    public let processedSize: Int?
    public let total: Int?
    public let path: String?
    public let finished: Bool
    public let progress: Double?
    public let destFolderPath: String

    public struct Error: Codable {
        public let code: Int
        public let path: String
    }
    
    public let errors: [Error]?

    enum CodingKeys: String, CodingKey {
        case processedSize = "processed_size"
        case total
        case path
        case finished
        case progress
        case destFolderPath = "dest_folder_path"
        case errors
    }
}

public struct DeleteData: Codable {
    public let taskId: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "taskid"
    }
}

public struct DeleteStatusData: Codable {
    public let processedCount: Int
    public let total: Int
    public let path: String
    public let processingPath: String
    public let finished: Bool
    public let progress: Double
    
    enum CodingKeys: String, CodingKey {
        case processedCount = "processed_num"
        case total
        case path
        case processingPath = "processing_path"
        case finished
        case progress
    }
}

public struct File: Codable {
    public let path: String
    public let name: String
    public let isDirectory: Bool
    //        public var children: Children? { return Children(info: info["children"] as? [String: Any]) }
    
    public struct Additional: Codable {
        public let realPath: String?
        public let size: Int64?
        public let owner: Owner?
        public let time: Time?
        
        public struct Permission: Codable {
            public let posix: Int
            public let isACLMode: Bool
            public let acl: ACL
            
            enum CodingKeys: String, CodingKey {
                case posix
                case isACLMode = "is_acl_mode"
                case acl
            }
        }
        
        public let permission: Permission?
        public let mountPointType: String?
        public let type: String?
        
        enum CodingKeys: String, CodingKey {
            case realPath = "real_path"
            case size
            case owner
            case time
            case permission = "perm"
            case mountPointType = "mount_point_type"
            case type
        }
    }
    
    public let additional: Additional?
    
    enum CodingKeys: String, CodingKey {
        case path
        case name
        case isDirectory = "isdir"
        case additional
    }
}

public struct Owner: Codable {
    
    /// User name of file owner.
    public let user: String
    
    /// Group name of file group.
    public let group: String
    
    /// File UID.
    public let uid: Int
    
    /// File GID.
    public let gid: Int
    
}

/// - Note: Linux timestamp in second, defined as the number of seconds that have elapsed since 00:00:00 Coordinated Universal Time (UTC), Thursday, 1 January 1970.
public struct Time: Codable {
    
    /// Linux timestamp of last access in second.
    public let accessed: Int
    
    /// Linux timestamp of last modification in second.
    public let modified: Int
    
    /// Linux timestamp of last change in second.
    public let changed: Int
    
    /// Linux timestamp of create time in second.
    public let created: Int
    
    enum CodingKeys: String, CodingKey {
        case accessed = "atime"
        case modified = "mtime"
        case changed = "ctime"
        case created = "crtime"
    }
}

/// No specific response. It returns an empty success response if completed without error.
public struct UploadData: Codable {
    public let blSkip: Bool?
    public let file: String?
    public let pid: Int?
    public let progress: Int?
}

public struct RenameData: Codable {
    /// Array of <file> objects.
    public let files: [File]
}

public struct CreateFolderData: Codable {
    /// Array of <file> objects.
    public let folders: [File]
}
