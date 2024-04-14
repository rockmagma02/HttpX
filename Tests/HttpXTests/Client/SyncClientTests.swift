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

    func testRequest() throws {
        class WrongAuth: BaseAuth {
            var needRequestBody = false
            var needResponseBody = false
            func authFlow(request _: URLRequest?, lastResponse _: Response?) throws -> (URLRequest?, Bool) {
                (nil, true)
            }
        }

        XCTAssertThrowsError(try client.request(
            method: .get,
            url: URLType.string("/get"),
            auth: AuthType.class(WrongAuth()),
            followRedirects: nil
        )) {
            XCTAssertEqual($0 as? HttpXError, HttpXError.invalidRequest())
        }
    }

    func testNonAuth() throws {
        // This Auth will stop when need to send request body secondly
        class NonAuth: BaseAuth {
            var needRequestBody = false
            var needResponseBody = false
            func authFlow(request: URLRequest?, lastResponse: Response?) throws -> (URLRequest?, Bool) {
                if let request, lastResponse == nil {
                    (request, false)
                } else {
                    (nil, false)
                }
            }
        }

        let response = try client.request(
            method: .get,
            url: URLType.string("/get"),
            auth: AuthType.class(NonAuth())
        )
        XCTAssertEqual(response.URLResponse?.status.0, 200)
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
                { $0.data?.append("response".data(using: .utf8)!) },
            ]
        )
        client.setEventHooks(eventHooks)

        let response = try client.request(
            method: .post,
            url: URLType.string("/get")
        )
        XCTAssertTrue(String(data: response.data!, encoding: .utf8)!.contains("response"))
    }

    func testSendSingleRequest() throws {
        // Timeout
        XCTAssertThrowsError(
            try client.sendSingleRequest(
                request: URLRequest(url: URL(string: "https://httpbin.org/delay/10")!, timeoutInterval: 1),
                stream: (true, nil)
            )
        ) { error in
            XCTAssertEqual(error as? HttpXError, HttpXError.networkError(message: "", code: -1_001))
        }
    }
}
