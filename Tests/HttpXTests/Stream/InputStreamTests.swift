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

class InputStreamExtensionsTests: XCTestCase {
    /// MockInputStream to simulate reading and errors
    class MockInputStream: InputStream {
        // MARK: Lifecycle

        override init(data: Data) {
            self.data = data
            super.init(data: data)
        }

        // MARK: Internal

        var errorOnRead: Bool = false

        override var hasBytesAvailable: Bool {
            readOffset < data.count
        }

        override func read(_: UnsafeMutablePointer<UInt8>, maxLength _: Int) -> Int {
            -1
        }

        override func open() {
            // No-op
        }

        override func close() {
            // No-op
        }

        // MARK: Private

        private let data: Data
        private var readOffset = 0
    }

    func testReadAllDataWithDefaultBufferSize() {
        let testData = "Hello, World!".data(using: .utf8)!
        let inputStream = InputStream(data: testData)

        let resultData = inputStream.readAllData()

        XCTAssertEqual(resultData, testData)
    }

    func testReadAllDataWithCustomBufferSize() {
        let testData = "Hello, Swift!".data(using: .utf8)!
        let bufferSize = 4 // Custom buffer size smaller than data length
        let inputStream = InputStream(data: testData)

        let resultData = inputStream.readAllData(bufferSize: bufferSize)

        XCTAssertEqual(resultData, testData)
    }

    func testReadAllDataWhenStreamIsEmpty() {
        let testData = Data() // Empty data
        let inputStream = InputStream(data: testData)

        let resultData = inputStream.readAllData()

        XCTAssertTrue(resultData.isEmpty)
    }

    func testReadAllDataHandlesReadError() {
        // Assuming `MockInputStream` is a mock that simulates an error during reading
        // You would need to implement this part based on your testing framework or mocking library
        let mockInputStream = MockInputStream(data: "Hello, Error!".data(using: .utf8)!)

        let resultData = mockInputStream.readAllData()

        // The result should be empty since reading fails
        XCTAssertTrue(resultData.isEmpty)
    }
}
