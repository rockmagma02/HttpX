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

/// The FunctionAuth class, user should provide an auth function.
public class FunctionAuth: BaseAuth {
    // MARK: Lifecycle

    /// Initialize the FunctionAuth with an auth function.
    ///
    /// - Parameters:
    ///     - authFunction: The auth function for the function auth.
    ///
    /// Functional authentication assumes that the authentication will simply modify
    /// the request once. Simple authentication methods, such as adding a header or
    /// changing the request method, can be implemented using this approach.
    public init(authFunction: @escaping (URLRequest) -> URLRequest) {
        self.authFunction = authFunction
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
        continuation.yield(authFunction(request))
        continuation.return(NoneType())
    }

    public func authFlow(
        _ request: URLRequest,
        continuation: BidirectionalAsyncStream<URLRequest, Response, NoneType>.Continuation
    ) async {
        await continuation.yield(authFunction(request))
        await continuation.return(NoneType())
    }

    // MARK: Private

    private var authFunction: (URLRequest) -> URLRequest
}
