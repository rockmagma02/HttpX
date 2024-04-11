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

public class AsyncStreamDelegate: HttpXDelegate, URLSessionDataDelegate {
    // MARK: Public

    // swiftlint:enable required_deinit

    public func urlSession(_: URLSession, didCreateTask task: URLSessionTask) {
        continuationSignalDictionary[task.taskIdentifier] = DispatchSemaphore(value: 0)
        let res = Response()
        responseDictionary[task.taskIdentifier] = res
        weakResponseDictionary[task.taskIdentifier] = res
        bufferDictionary[task.taskIdentifier] = Data()
    }

    public func urlSession(
        _: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        waitForContinuation(taskIdentifier: dataTask.taskIdentifier)
        weakResponseDictionary[dataTask.taskIdentifier]?.URLResponse = response
        completionHandler(.allow)
    }

    public func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let continuation = continuationDictionary[dataTask.taskIdentifier] {
            var buffer = bufferDictionary[dataTask.taskIdentifier]!
            buffer.append(data)
            while buffer.count >= chunkSize {
                let chunk = buffer.prefix(chunkSize)
                buffer = buffer.dropFirst(chunkSize)
                continuation.yield(chunk)
            }
            bufferDictionary[dataTask.taskIdentifier] = buffer
        }
    }

    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error {
            weakResponseDictionary[task.taskIdentifier]?.error = error
        }
        let buffer = bufferDictionary[task.taskIdentifier]
        if let buffer, !buffer.isEmpty {
            continuationDictionary[task.taskIdentifier]?.yield(buffer)
        }

        continuationDictionary[task.taskIdentifier]?.finish()
        continuationDictionary.removeValue(forKey: task.taskIdentifier)
        continuationSignalDictionary.removeValue(forKey: task.taskIdentifier)
        bufferDictionary.removeValue(forKey: task.taskIdentifier)
    }

    // MARK: Internal

    internal var chunkSize: Int = 1_024

    internal func putContinuation(taskIdentifier: Int, continuation: AsyncStream<Data>.Continuation) {
        continuationDictionary[taskIdentifier] = continuation
        if let signal = continuationSignalDictionary[taskIdentifier] {
            signal.signal()
        }
    }

    internal func getResponse(forTaskIdentifier taskIdentifier: Int) -> Response? {
        if let response = responseDictionary[taskIdentifier] {
            response.waitForErrorAndResponse()
            responseDictionary.removeValue(forKey: taskIdentifier)
            return response
        }
        return nil
    }

    // MARK: Private

    private var responseDictionary: [Int: Response] = [:]
    private var weakResponseDictionary: WeakValueDictionary<Int, Response> = .init()
    private var bufferDictionary: [Int: Data] = [:]
    private var continuationDictionary: [Int: AsyncStream<Data>.Continuation] = [:]
    private var continuationSignalDictionary: [Int: DispatchSemaphore] = [:]

    private func waitForContinuation(taskIdentifier: Int) {
        if let signal = continuationSignalDictionary[taskIdentifier] {
            if continuationDictionary[taskIdentifier] == nil {
                signal.wait()
            }
        }
    }
}
