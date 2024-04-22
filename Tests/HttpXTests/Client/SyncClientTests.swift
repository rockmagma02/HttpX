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
@testable import HttpX
import XCTest

final class SyncClientTests: XCTestCase {
    lazy var client = SyncClient(
        maxRedirects: 1,
        baseURL: URLType.string("https://httpbin.org/")
    )

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    func testMaxRedirect() throws {
        XCTAssertThrowsError(
            try client.request(method: .get, url: URLType.string("/absolute-redirect/3"), followRedirects: true)
        ) {
            XCTAssertEqual($0 as? HttpXError, HttpXError.redirectError())
        }
    }

    func testEventHooks() throws {
        let eventHooks = EventHooks(
            request: [
                { $0.httpBody?.append("request".data(using: .utf8)!) },
            ],
            response: [
                { $0.defaultEncoding = .iso2022JP },
            ]
        )
        client.setEventHooks(eventHooks)

        let response = try client.request(
            method: .get,
            url: URLType.string("/get")
        )
        XCTAssertTrue(response.defaultEncoding == .iso2022JP)
    }

    func testSendSingleRequest() throws {
        // Timeout
        XCTAssertThrowsError(
            try client.sendSingleRequest(
                request: URLRequest(url: URL(string: "https://httpbin.org/delay/10")!, timeoutInterval: 1)
            )
        ) { error in
            XCTAssertEqual(error as? HttpXError, HttpXError.networkError(message: "", code: -1_001))
        }
    }
}
