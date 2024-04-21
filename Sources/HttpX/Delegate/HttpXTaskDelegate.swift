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

import Dispatch
import Foundation

// swiftlint:disable required_deinit
public class HttpXTaskDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    // MARK: Public

    // swiftlint:enable required_deinit

    public func urlSession(
        _: URLSession,
        task _: URLSessionTask,
        didReceive _: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        // Make sure URLSession will not automatically handle the challenge
        (.useCredential, nil)
    }

    public func urlSession(
        _: URLSession,
        task _: URLSessionTask,
        willPerformHTTPRedirection _: HTTPURLResponse,
        newRequest _: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // Make sure URLSession will not automatically follow the redirection
        completionHandler(nil)
    }

    public func urlSession(
        _: URLSession,
        dataTask _: URLSessionDataTask,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        if self.response == nil, let response = (response as? HTTPURLResponse) {
            self.response = .init(HTTPURLResponse: response)
            syncDispatchSemaphore.signal()
            await asyncDispatchSemaphore.signal()
        }
        return .allow
    }

    public func urlSession(
        _: URLSession,
        dataTask _: URLSessionDataTask,
        didReceive data: Data
    ) {
        buffer.append(data)

        if chunkSize == nil {
            response?.writeData(buffer)
            buffer = .init()
        } else {
            while buffer.count >= chunkSize! {
                let chunk = buffer.prefix(chunkSize!)
                buffer.removeFirst(chunkSize!)
                response?.writeData(chunk)
            }
        }
    }

    public func urlSession(
        _: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        if let error {
            if response == nil {
                if let url = task.originalRequest?.url {
                    response = .init(url: url, error: error)
                    syncDispatchSemaphore.signal()
                    Task { await self.asyncDispatchSemaphore.signal() }
                }
            } else {
                response?.error = error
            }
        }
        if !buffer.isEmpty {
            response?.writeData(buffer)
            buffer = .init()
        }
        response?.close()
    }

    // MARK: Internal

    internal var chunkSize: Int?

    internal func getResponse() -> Response {
        syncDispatchSemaphore.wait()
        let response = response!
        syncDispatchSemaphore.signal()
        return response
    }

    internal func getResponse() async -> Response {
        await asyncDispatchSemaphore.wait()
        let response = response!
        await asyncDispatchSemaphore.signal()
        return response
    }

    // MARK: Private

    private var syncDispatchSemaphore = DispatchSemaphore(value: 0)
    private var asyncDispatchSemaphore = AsyncDispatchSemphore(value: 0)

    private var response: Response?
    private var buffer = Data()
}
