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

// MARK: - BaseAuth

/// Protocol defining the base authentication flow.
@available(macOS 10.15, *)
public protocol BaseAuth {
    /// Indicates if the request body is needed for authentication.
    var needRequestBody: Bool { get }
    /// Indicates if the response body is needed for authentication.
    var needResponseBody: Bool { get }

    /// Handles the authentication flow for a given request and last response.
    /// - Parameters:
    ///   - request: The current URLRequest that needs authentication.
    ///   - lastResponse: The last URLResponse received from the server.
    /// - Returns: A tuple containing the modified URLRequest and a Bool indicating if auth flow is done.
    ///
    /// When you create a custom authentication method, you need to implement the `authFlow` method.
    /// The method should take two parameters, a `URLRequest` and a `Response`, and return a tuple
    /// containing the modified `URLRequest` and a `Bool` value indicating whether the auth is done.
    ///
    /// In some situation, the auth need to use the response of the request to decide the next request.
    ///  Like the Digest Auth, after you send the first request, the server will return the
    /// `WWW-Authenticate` header, and you need to use the header to generate the `Authorization`
    /// header for the next request. In this case, you can return `false` in the second value of
    /// the tuple to indicate the auth need to use the response.
    func authFlow(request: URLRequest?, lastResponse: Response?) throws -> (URLRequest?, Bool)
}

@available(macOS 10.15, *)
extension BaseAuth {
    /// Synchronously handles the authentication flow for a given request and last response.
    /// This method ensures that if the request body is needed, it is converted from a stream to data.
    /// - Parameters:
    ///   - request: The current URLRequest that needs authentication.
    ///   - lastResponse: The last URLResponse received from the server.
    /// - Returns: A tuple containing the modified URLRequest and a Bool indicating if auth flow is done.
    func syncAuthFlow( // swiftlint:disable:this explicit_acl
        request: URLRequest?, lastResponse: Response?
    ) throws -> (URLRequest?, Bool) {
        var request = request
        let lastResponse = lastResponse
        if needRequestBody, request != nil {
            if let stream = request!.httpBodyStream {
                // read all data from the stream
                let data = stream.readAllData()
                request!.httpBodyStream = nil
                request!.httpBody = data
            }
        }

        if needResponseBody, lastResponse != nil {
            _ = lastResponse?.getData()
        }

        return try authFlow(request: request, lastResponse: lastResponse)
    }

    func asyncAuthFlow( // swiftlint:disable:this explicit_acl
        request: URLRequest?, lastResponse: Response?
    ) async throws -> (URLRequest?, Bool) {
        var request = request
        let lastResponse = lastResponse
        if needRequestBody, request != nil {
            if let stream = request!.httpBodyStream {
                // read all data from the stream
                let data = stream.readAllData()
                request!.httpBodyStream = nil
                request!.httpBody = data
            }
        }

        if needResponseBody, lastResponse != nil {
            _ = try await lastResponse?.getData()
        }

        return try authFlow(request: request, lastResponse: lastResponse)
    }
}
