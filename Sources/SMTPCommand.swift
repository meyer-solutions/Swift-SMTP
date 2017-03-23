/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

enum SMTPCommand {
    case connect
    case helo(String)
    case ehlo(String)
    case starttls
    case auth(SMTP.AuthMethod, String?)
    case authUser(String)
    case authPassword(String)
    case mail(String)
    case rcpt(String)
    case data
    case dataEnd
    case quit
    
    var text: String {
        switch self {
        case .connect: return ""
        case .helo(let domain): return "HELO \(domain)"
        case .ehlo(let domain): return "EHLO \(domain)"
        case .starttls: return "STARTTLS"
        case .auth(let method, let credentials):
            if let credentials = credentials { return "AUTH \(method.rawValue) \(credentials)" }
            else { return "AUTH \(method.rawValue)" }
        case .authUser(let user): return user
        case .authPassword(let password): return password
        case .mail(let from): return "MAIL FROM: <\(from)>"
        case .rcpt(let to): return "RCPT TO: <\(to)>"
        case .data: return "DATA"
        case .dataEnd: return "\(CRLF)."
        case .quit: return "QUIT"
        }
    }
        
    var expectedCodes: [SMTPResponseCode] {
        switch self {
        case .connect: return [.serviceReady]
        case .starttls: return [.serviceReady]
        case .auth(let method, _):
            switch method {
            case .cramMD5: return [.containingChallenge]
            case .login: return [.containingChallenge]
            case .plain: return [.authSucceeded]
            case .xoauth2: return [.authSucceeded]
            }
        case .authUser(_): return [.containingChallenge]
        case .authPassword: return [.authSucceeded]
        case .rcpt(_): return [.commandOK, .willForward]
        case .data: return [.startMailInput]
        case .quit: return [.connectionClosing, .commandOK]
        default: return [.commandOK]
        }
    }
}
