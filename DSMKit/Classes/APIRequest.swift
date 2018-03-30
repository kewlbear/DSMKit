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

public enum API: Namespace {
    
    public static let commonErrors = [
        100: "Unknown error",
        101: "No parameter of API, method or version",
        102: "The requested API does not exist",
        103: "The requested method does not exist",
        104: "The requested version does not support the functionality",
        105: "The logged in session does not have permission",
        106: "Session timeout",
        107: "Session interrupted by duplicate login"
    ]
    
    public enum Info: MethodContainer {
        
        public static func query(query: Set<String>? = nil) -> BasicRequestInfo<APIInfoData> {
            return BasicRequestInfo<APIInfoData>(api: api, versions: 1...1) { encoder in
                query.map { encoder["query"] = $0 }
            }
        }
        
    }
    
    public enum Auth: MethodContainer {
        
        public static let errors = [
            400: "No such account or incorrect password",
            401: "Account disabled",
            402: "Permission denied",
            403: "2-step verification code required",
            404: "Failed to authenticate 2-step verification code"
        ]
        
        /// Returned format of session ID
        public enum Format: String {
            /// The login session ID will be set to “id” key in cookie of HTTP/HTTPS header of response.
            case cookie
            /// The login sid will only be returned as response JSON data and “id” key will not be set in cookie.
            case sid
        }
        
        /// - Parameters:
        ///   - account: Login account name
        ///   - password: Login account password
        ///   - session: Login session name
        ///   - format: Returned format of session ID. Following are the two possible options and the default value is cookie.
        ///   - otpCode: Reserved key. DSM 4.2 and later support a 2-step verification option with an OTP code. If it’s enabled, the user requires a verification code to log into DSM sessions. However, WebAPI doesn’t support it yet.
        public static func login(account: String, password: String, session: String, format: Format, otpCode: String? = nil) -> BasicRequestInfo<APILoginData> {
            return BasicRequestInfo<APILoginData>(api: api, versions: 1...3) { encoder in
                encoder["account"] = account
                encoder["passwd"] = password
                encoder["session"] = session
                encoder.add(parameter: "format", value: format.rawValue, availability: 2...)
                otpCode.map { encoder.add(parameter: "otp_code", value: $0, availability: 3...) }
            }
        }
            
    }
    
}
