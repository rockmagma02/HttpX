// Copyright 2024-2024 Ruiyang Sun. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CryptoKit
import Foundation
import SyncStream

// MARK: - DigestAuth

/// The DigestAuth class, user should provide the username and password.
public class DigestAuth: BaseAuth {
    // MARK: Lifecycle

    /// Initialize the DigestAuth with username and password.
    ///
    /// - Parameters:
    ///     - username: The username for the DigestAuth.
    ///     - password: The password for the DigestAuth.
    public init(username: String, password: String) {
        self.username = username
        self.password = password
        nonceCount = 0
        lastChallenge = nil
    }

    deinit {}

    // MARK: Public

    /// default value is false
    public var needRequestBody: Bool { false }

    /// default value is false
    public var needResponseBody: Bool { false }

    public func authFlow(
        _ request: URLRequest,
        continuation: BidirectionalSyncStream<URLRequest, Response, NoneType>.Continuation
    ) {
        var request = request
        if let lastChallenge {
            do {
                try request.addValue(
                    buildAuthHeader(request: request, challenge: lastChallenge),
                    forHTTPHeaderField: "Authorization"
                )
            } catch {
                continuation.throw(error: error)
                return
            }
        }

        let response = continuation.yield(request)

        if response.statusCode != needAuthStatusCode {
            continuation.return(NoneType())
            return
        }

        let authHeader = response.value(forHTTPHeaderField: "Www-Authenticate")
        guard let authHeader, authHeader.lowercased().hasPrefix("digest ") else {
            continuation.return(NoneType())
            return
        }

        do {
            lastChallenge = try parseChallenge(authHeader: authHeader)
        } catch {
            continuation.throw(error: error)
            return
        }
        nonceCount = 1

        do {
            try request.addValue(
                buildAuthHeader(request: request, challenge: lastChallenge!),
                forHTTPHeaderField: "Authorization"
            )
        } catch {
            continuation.throw(error: error)
            return
        }

        continuation.yield(request)
        continuation.return(NoneType())
    }

    public func authFlow(
        _ request: URLRequest,
        continuation: BidirectionalAsyncStream<URLRequest, Response, NoneType>.Continuation
    ) async {
        var request = request
        if let lastChallenge {
            do {
                try request.addValue(
                    buildAuthHeader(request: request, challenge: lastChallenge),
                    forHTTPHeaderField: "Authorization"
                )
            } catch {
                await continuation.throw(error: error)
                return
            }
        }

        let response = await continuation.yield(request)

        if response.statusCode != needAuthStatusCode {
            await continuation.return(NoneType())
            return
        }

        let authHeader = response.value(forHTTPHeaderField: "Www-Authenticate")
        guard let authHeader, authHeader.lowercased().hasPrefix("digest ") else {
            await continuation.return(NoneType())
            return
        }

        do {
            lastChallenge = try parseChallenge(authHeader: authHeader)
        } catch {
            await continuation.throw(error: error)
            return
        }
        nonceCount = 1

        do {
            try request.addValue(
                buildAuthHeader(request: request, challenge: lastChallenge!),
                forHTTPHeaderField: "Authorization"
            )
        } catch {
            await continuation.throw(error: error)
            return
        }

        await continuation.yield(request)
        await continuation.return(NoneType())
    }

    // MARK: Private

    private var username: String
    private var password: String

    private var needAuthStatusCode = 401

    private var nonceCount: Int
    private var lastChallenge: DigestAuthChallenge?

    private var algorithmsToHashFunction: [String: (String) -> String] = [
        "MD5": HashAlgorithms.md5,
        "MD5-SESS": HashAlgorithms.md5,
        "SHA": HashAlgorithms.sha1,
        "SHA-SESS": HashAlgorithms.sha1,
        "SHA-256": HashAlgorithms.sha256,
        "SHA-256-SESS": HashAlgorithms.sha256,
        "SHA-512": HashAlgorithms.sha512,
        "SHA-512-SESS": HashAlgorithms.sha512,
    ]
}

private extension DigestAuth {
    enum HashAlgorithms {
        fileprivate static func md5(_ string: String) -> String {
            let digest = Insecure.MD5.hash(data: string.data(using: .utf8)!)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }

        fileprivate static func sha1(_ string: String) -> String {
            let digest = Insecure.SHA1.hash(data: string.data(using: .utf8)!)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }

        fileprivate static func sha256(_ string: String) -> String {
            let digest = SHA256.hash(data: string.data(using: .utf8)!)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }

        fileprivate static func sha512(_ string: String) -> String {
            let digest = SHA512.hash(data: string.data(using: .utf8)!)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }
    }

    struct DigestAuthChallenge {
        fileprivate var realm: String
        fileprivate var nonce: String
        fileprivate var algorithm: String
        fileprivate var opaque: String?
        fileprivate var qop: String?
    }

    func buildAuthHeader(request: URLRequest, challenge: DigestAuthChallenge) throws -> String {
        let hashFunction = algorithmsToHashFunction[challenge.algorithm.uppercased()]!

        let a1 = [username, challenge.realm, password].joined(separator: ":")

        var path = request.url!.path(percentEncoded: true)
        if path.isEmpty {
            path = "/"
        }
        let query = request.url?.query(percentEncoded: true) ?? ""
        if !query.isEmpty {
            path += "?" + query
        }
        let a2 = [request.httpMethod!, path].joined(separator: ":")
        let ha2 = hashFunction(a2)

        let ncValue = String(format: "%08x", nonceCount)
        let cnonce = getClientNonce(nonceCount: nonceCount, nonce: challenge.nonce)
        nonceCount += 1

        var ha1 = hashFunction(a1)
        if challenge.algorithm.lowercased().hasSuffix("sess") {
            ha1 = hashFunction([ha1, challenge.nonce, cnonce].joined(separator: ":"))
        }

        let qop = try resolveQop(qop: challenge.qop, request: request)
        let digestData: [String] =
            if let qop {
                [ha1, challenge.nonce, ncValue, cnonce, qop, ha2]
            } else {
                [ha1, challenge.nonce, ha2]
            }

        var headersField = [
            "username": username,
            "realm": challenge.realm,
            "nonce": challenge.nonce,
            "uri": path,
            "response": hashFunction(digestData.joined(separator: ":")),
            "algorithm": challenge.algorithm,
        ]
        if let opaque = challenge.opaque {
            headersField["opaque"] = opaque
        }
        if let qop {
            headersField["qop"] = qop
            headersField["nc"] = ncValue
            headersField["cnonce"] = cnonce
        }

        return "Digest \(getHeaderValue(headerFields: headersField))"
    }

    func parseChallenge(authHeader: String) throws -> DigestAuthChallenge {
        var fields: String
        let parts = authHeader.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        fields = String(parts[1])

        var headerDict: [String: String] = [:]
        for var field in parseHttpList(fields) {
            field = field.trimmingCharacters(in: .whitespacesAndNewlines)
            let parts = field.components(separatedBy: "=")
            let (key, value) = (parts[0], parts[1])
            headerDict[key] = unquote(value)
        }

        guard
            let realm = headerDict["realm"],
            let nonce = headerDict["nonce"]
        else {
            throw URLError(
                .userCancelledAuthentication,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "The auth is canceled because the realm or nonce is missing in the header",
                ]
            )
        }

        let opaque = headerDict["opaque"]
        let qop = headerDict["qop"]
        let algorithm = headerDict["algorithm"] ?? "MD5"
        guard algorithmsToHashFunction.keys.contains(algorithm.uppercased()) else {
            throw URLError(
                .userCancelledAuthentication,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "The auth is canceled because the algorithm in the header is not supported",
                ]
            )
        }
        return DigestAuthChallenge(realm: realm, nonce: nonce, algorithm: algorithm, opaque: opaque, qop: qop)
    }

    func parseHttpList(_ string: String) -> [String] {
        var result: [String] = []
        var part = ""

        var escaped = false; var quote = false
        var current: String
        for currentChar in string {
            current = String(currentChar)
            if escaped {
                part += current
                escaped = false
                continue
            }
            if quote {
                if current == "\\" {
                    escaped = true
                    continue
                } else if current == "\"" {
                    quote = false
                }
                part += current
                continue
            }

            if current == "," {
                result.append(part.trimmingCharacters(in: .whitespacesAndNewlines))
                part = ""
                continue
            }

            if current == "\"" {
                quote = true
            }

            part += current
        }

        if !part.isEmpty {
            result.append(part.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return result
    }

    func unquote(_ string: String) -> String {
        if string.first == "\"", string.last == "\"" {
            return String(string.dropFirst().dropLast())
        }

        return string
    }

    func getClientNonce(nonceCount: Int, nonce: String) -> String {
        var string = String(nonceCount) + nonce
        string += String(Date().timeIntervalSince1970)
        var randomBytes = [UInt8](repeating: 0, count: 8) // swiftlint:disable:this no_magic_numbers
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        string += randomBytes.reduce(into: "") { $0 += String(format: "%02x", $1) }

        string = algorithmsToHashFunction["SHA"]!(string)
        let startIndex = string.index(string.startIndex, offsetBy: 0)
        let endIndex = string.index(string.startIndex, offsetBy: 16) // swiftlint:disable:this no_magic_numbers
        return String(string[startIndex ..< endIndex])
    }

    func resolveQop(qop: String?, request _: URLRequest) throws -> String? {
        guard let qop else {
            return nil
        }

        let qops = qop.components(separatedBy: ", ?")
        if qops.contains("auth") {
            return "auth"
        }

        if qops.contains("auth-int") {
            throw URLError(
                .userCancelledAuthentication, userInfo: [
                    NSLocalizedDescriptionKey: "The auth is canceled because the qop \"auth-int\" is not supported yet",
                ]
            )
        }

        throw URLError(
            .userCancelledAuthentication, userInfo: [
                NSLocalizedDescriptionKey: "The auth is canceled because the qop in the header is invalid",
            ]
        )
    }

    func getHeaderValue(headerFields: [String: String]) -> String {
        let nonQuotedFields = ["algorithms", "qop", "nc"]
        var headerValue = ""
        for (idx, (key, value)) in headerFields.enumerated() {
            if idx > 0 {
                headerValue += ", "
            }
            if nonQuotedFields.contains(key) {
                headerValue += "\(key)=\(value)"
            } else {
                headerValue += "\(key)=\"\(value)\""
            }
        }
        return headerValue
    }
}
