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

import Foundation
import SyncStream

/// The BasicAuth class, user should provide the username and password.
public class BasicAuth: BaseAuth {
    // MARK: Lifecycle

    /// Initialize the BasicAuth with username and password.
    /// - Parameters:
    ///     - username: The username for the basic auth.
    ///     - password: The password for the basic auth.
    public init(username: String, password: String) {
        self.username = username
        self.password = password
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
        request.setValue(
            buildAuthHeader(username: username, password: password),
            forHTTPHeaderField: "Authorization"
        )
        continuation.yield(request)
        continuation.return(NoneType())
    }

    public func authFlow(
        _ request: URLRequest,
        continuation: BidirectionalAsyncStream<URLRequest, Response, NoneType>.Continuation
    ) async {
        var request = request
        request.setValue(
            buildAuthHeader(username: username, password: password),
            forHTTPHeaderField: "Authorization"
        )
        await continuation.yield(request)
        await continuation.return(NoneType())
    }

    // MARK: Private

    private var username: String
    private var password: String

    private func buildAuthHeader(username: String, password: String) -> String {
        let credentialData = "\(username):\(password)".data(using: .utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        return "Basic \(base64Credentials)"
    }
}
