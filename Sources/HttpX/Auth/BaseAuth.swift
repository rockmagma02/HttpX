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

// MARK: - BaseAuth

// swiftlint:disable closure_body_length

/// Protocol defining the base authentication flow.
public protocol BaseAuth {
    /// Indicates if the request body is needed for authentication.
    var needRequestBody: Bool { get }
    /// Indicates if the response body is needed for authentication.
    var needResponseBody: Bool { get }

    /// The authentication flow. Bidirectional communication with the Client.
    ///
    /// - Parameters:
    ///     - request: The initial request to be authenticated.
    ///     - continuation: The continuation of the stream, which will communicate with
    ///         the client. Having method `yield(_:)`, `return(_:)`, `throw(_:)`.
    ///
    /// Basically, The Client will give the initial request to the flow, and the flow can
    /// add auth header or do other something, than `yield(_:)` it back to the client.
    /// The Client will send the request to the server, and fetch the response back, then
    /// send it back to the flow, i.d. the `yield(_:)` will return the response. If the
    /// auth progress is over, authFlow can invoke `return(NoneType())` to end the flow,
    /// or continue the flow by `yield(_:)` the modified request back to the client. If
    /// any error occurred, the flow can throw the error to the client by `throw(_:)`.
    ///
    /// When you creat a custom authentication method, The `authFlow(_:, continuation:)`
    /// method should be implemented.
    func authFlow(
        _ request: URLRequest,
        continuation: BidirectionalSyncStream<URLRequest, Response, NoneType>.Continuation
    )

    /// The Async Version authentication flow. Bidirectional communication with the Client.
    ///
    /// - Parameters:
    ///     - request: The initial request to be authenticated.
    ///     - continuation: The continuation of the stream, which will communicate with
    ///         the client. Having method `yield(_:)`, `return(_:)`, `throw(_:)`.
    ///
    /// Have the same behavior as the sync version, but the method is async, all interactions
    /// with the `continuation` should be `await`. For the custom authentication method, you
    /// can simplily copy the sync version `authFlow(_:, continuation:)` to the async version,
    /// but add the `await` keyword before the `yield(_:)`, `return(_:)`, `throw(_:)`.
    func authFlow(
        _ request: URLRequest,
        continuation: BidirectionalAsyncStream<URLRequest, Response, NoneType>.Continuation
    ) async
}

extension BaseAuth {
    func authFlowAdapter( // swiftlint:disable:this explicit_acl
        _ request: URLRequest
    ) -> BidirectionalSyncStream<URLRequest, Response, NoneType> {
        BidirectionalSyncStream<URLRequest, Response, NoneType> { continuation in
            var request = request
            var response: Response
            if needRequestBody {
                if let stream = request.httpBodyStream {
                    // read all data from the stream
                    let data = stream.readAllData()
                    request.httpBodyStream = nil
                    request.httpBody = data
                }
            }
            let streamAdapter = BidirectionalSyncStream<URLRequest, Response, NoneType> { continuationAdapter in
                self.authFlow(request, continuation: continuationAdapter)
            }
            do {
                request = try streamAdapter.next()
            } catch {
                continuation.throw(error: error)
                return
            }
            while true {
                response = continuation.yield(request)
                if needResponseBody {
                    _ = response.getData()
                }
                do {
                    request = try streamAdapter.send(response)
                } catch {
                    if error is StopIteration<NoneType> {
                        break
                    }
                    continuation.throw(error: error)
                    return
                }
            }
            continuation.return(NoneType())
        }
    }

    func authFlowAdapter( // swiftlint:disable:this explicit_acl
        _ request: URLRequest
    ) async -> BidirectionalAsyncStream<URLRequest, Response, NoneType> {
        BidirectionalAsyncStream<URLRequest, Response, NoneType> { continuation in
            var request = request
            var response: Response
            if needRequestBody {
                if let stream = request.httpBodyStream {
                    // read all data from the stream
                    let data = stream.readAllData()
                    request.httpBodyStream = nil
                    request.httpBody = data
                }
            }
            let streamAdapter = BidirectionalAsyncStream<URLRequest, Response, NoneType> { continuaitonAdapter in
                await self.authFlow(request, continuation: continuaitonAdapter)
            }
            do {
                request = try await streamAdapter.next()
            } catch {
                await continuation.throw(error: error)
            }
            while true {
                response = await continuation.yield(request)
                if needResponseBody {
                    do {
                        _ = try await response.getData()
                    } catch {
                        await continuation.throw(error: error)
                    }
                }
                do {
                    request = try await streamAdapter.send(response)
                } catch {
                    if error is StopIteration<NoneType> {
                        break
                    }
                    await continuation.throw(error: error)
                }
            }
            await continuation.return(NoneType())
        }
    }
}

// swiftlint:enable closure_body_length
