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

@testable import HttpX
import XCTest

final class SyncResponceStreamTests: XCTestCase {
    lazy var session = URLSession.shared
    lazy var delegate = SyncStreamDelegate()

    func testWrongGetResponse() {
        let response = delegate.getResponse(forTaskIdentifier: 999)
        XCTAssertNil(response)
    }

    func testThreadSafety() {
        let exception = expectation(description: "SyncResponseStream should be thread safe")

        let stream = SyncResponseStream(chunkSize: 13)
        let dataToWrite = String(repeating: "hello HttpX", count: 10).data(using: .utf8)!
        let writeQueue = DispatchQueue(label: "writeQueue.\(UUID().uuidString)")
        let readQueue = DispatchQueue(label: "readQueue.\(UUID().uuidString)")

        var readData = Data()

        readQueue.async {
            for chunk in stream {
                readData.append(chunk)
            }
            exception.fulfill()
        }

        writeQueue.async {
            try! stream.write(dataToWrite)
            stream.close()
        }

        wait(for: [exception], timeout: 20)
        XCTAssertEqual(readData, dataToWrite)
    }

    func testSyncResponseStreamInvalidWrite() {
        let stream = SyncResponseStream()
        stream.close()

        XCTAssertThrowsError(try stream.write(Data())) { error in
            XCTAssertEqual(error as! StreamError, StreamError.streamHasClosed)
        }
    }

    func testDelegateInvalidWritingData() {
        let task = session.dataTask(with: URL(string: "https://www.google.com")!)
        delegate.urlSession(session, didCreateTask: task)

        // assume complete
        delegate.urlSession(session, task: task, didCompleteWithError: nil)

        // write data after complete
        delegate.urlSession(session, dataTask: task, didReceive: "Hello HttpX".data(using: .utf8)!)

        let response = delegate.getResponse(forTaskIdentifier: task.taskIdentifier)!
        XCTAssertEqual(response.error as! StreamError, StreamError.streamHasClosed)
    }
}
