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

// MARK: - SyncStreamDelegate

// swiftlint:disable required_deinit

@available(macOS 10.15, *)
public class SyncStreamDelegate: HttpXDelegate, URLSessionDataDelegate {
    // MARK: Public

    // swiftlint:enable required_deinit

    public func urlSession(_: URLSession, didCreateTask task: URLSessionTask) {
        let res = Response()
        responseDictionary[task.taskIdentifier] = res
        weakResponseDictionary[task.taskIdentifier] = res
        weakResponseDictionary[task.taskIdentifier]?.syncStream = SyncResponseStream(chunkSize: chunkSize)
    }

    public func urlSession(
        _: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        weakResponseDictionary[dataTask.taskIdentifier]?.URLResponse = response
        completionHandler(.allow)
    }

    public func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        do {
            try weakResponseDictionary[dataTask.taskIdentifier]?.syncStream?.write(data)
        } catch {
            weakResponseDictionary[dataTask.taskIdentifier]?.error = error
        }
    }

    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error {
            weakResponseDictionary[task.taskIdentifier]?.error = error
        }
        weakResponseDictionary[task.taskIdentifier]?.syncStream?.close()
    }

    // MARK: Internal

    internal var chunkSize: Int = 1_024

    internal func removeResponse(forTaskIdentifier taskIdentifier: Int) {
        responseDictionary.removeValue(forKey: taskIdentifier)
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
}

// MARK: - SyncResponseStream

public class SyncResponseStream: IteratorProtocol, Sequence {
    // MARK: Lifecycle

    internal init(chunkSize: Int = kDefaultChunkSize) {
        self.chunkSize = chunkSize
        accessQueue = .init(label: "com.httpx.stream.syncStream.\(UUID().uuidString)")
        dataAvailableSemaphore = .init(value: 0)
        writingData = true
    }

    deinit {}

    // MARK: Public

    public func next() -> Data? {
        var noData = false
        accessQueue.sync {
            if !writingData, dataQueue.isEmpty {
                noData = true
            }
        }

        if noData {
            return nil
        }

        dataAvailableSemaphore.wait()

        var nextData: Data?
        accessQueue.sync {
            if !dataQueue.isEmpty {
                nextData = dataQueue.removeFirst()
            } else if !writingData {
                nextData = nil
            }
        }
        return nextData
    }

    public func makeIterator() -> SyncResponseStream {
        self
    }

    // MARK: Internal

    internal func write(_ data: Data) throws {
        try accessQueue.sync {
            if self.writingData {
                self.buffer.append(data)
                while self.buffer.count >= self.chunkSize {
                    self.dataQueue.append(self.buffer.prefix(self.chunkSize))
                    self.buffer.removeFirst(self.chunkSize)
                    self.dataAvailableSemaphore.signal()
                }
            } else {
                throw StreamError.streamHasClosed
            }
        }
    }

    internal func close() {
        accessQueue.sync {
            if !self.buffer.isEmpty {
                self.dataQueue.append(self.buffer)
                self.buffer = .init()
                self.dataAvailableSemaphore.signal()
            }

            self.writingData = false
            self.dataAvailableSemaphore.signal()
        }
    }

    // MARK: Private

    private var chunkSize: Int
    private var dataQueue = [Data]()
    private var buffer: Data = .init()
    private var accessQueue: DispatchQueue
    private var dataAvailableSemaphore: DispatchSemaphore
    private var writingData: Bool
}
