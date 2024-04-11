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

/// The APIKeyAuth class, user should provide the key.
@available(macOS 10.15, *)
public class APIKeyAuth: BaseAuth {
    // MARK: Lifecycle

    /// Initialize the APIKeyAuth with key.
    /// - Parameters:
    ///     - key: The key for the API key auth.
    public init(key: String) {
        self.key = key
    }

    deinit {}

    // MARK: Public

    /// default value is false
    public var needRequestBody: Bool { false }
    /// default value is false
    public var needResponseBody: Bool { false }

    public func authFlow(request: URLRequest?, lastResponse _: Response?) throws -> (URLRequest?, Bool) {
        if var request {
            request.setValue(
                key,
                forHTTPHeaderField: "x-api-key"
            )
            return (request, true)
        }
        throw AuthError.invalidRequest(message: "Request is nil in \(APIKeyAuth.self)")
    }

    // MARK: Private

    private var key: String
}
