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

final class AsyncClientTests: XCTestCase {
    lazy var client = AsyncClient(
        maxRedirects: 1,
        baseURL: URLType.string("https://httpbin.org/")
    )

    func testRequest() async throws {
        class WrongAuth: BaseAuth {
            var needRequestBody = false
            var needResponseBody = false
            func authFlow(request _: URLRequest?, lastResponse _: Response?) throws -> (URLRequest?, Bool) {
                (nil, true)
            }
        }
        let expectation = expectation(description: "request")
        do {
            _ = try await client.request(
                method: .get,
                url: URLType.string("/get"),
                auth: AuthType.class(WrongAuth())
            )
        } catch {
            expectation.fulfill()
            XCTAssertEqual(error as? HttpXError, HttpXError.invalidRequest())
        }
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testNonAuth() async throws {
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

        let response = try await client.request(
            method: .get,
            url: URLType.string("/get"),
            auth: AuthType.class(NonAuth())
        )
        XCTAssertEqual(response.URLResponse?.status.0, 200)
    }

    func testMaxRedirect() async throws {
        let expectation = expectation(description: "maxRedirect")
        do {
            _ = try await client.request(method: .get, url: URLType.string("/absolute-redirect/3"), followRedirects: true)
        } catch {
            expectation.fulfill()
            XCTAssertEqual(error as? HttpXError, HttpXError.redirectError())
        }
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testEventHooks() async throws {
        let eventHooks = EventHooks(
            request: [
                { $0.httpBody?.append("request".data(using: .utf8)!) },
            ],
            response: [
                { $0.data?.append("response".data(using: .utf8)!) },
            ]
        )
        client.setEventHooks(eventHooks)

        let response = try await client.request(
            method: .post,
            url: URLType.string("/get")
        )
        XCTAssertTrue(String(data: response.data!, encoding: .utf8)!.contains("response"))
    }

    func testSendSingleRequest() async throws {
        // Timeout
        let expectation = expectation(description: "timeout")
        do {
            _ = try await client.sendSingleRequest(
                request: URLRequest(url: URL(string: "https://httpbin.org/delay/10")!, timeoutInterval: 1),
                stream: (false, nil)
            )
        } catch {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testSendSingleRequestAsync() async throws {
        // Timeout
        let expectation = expectation(description: "timeout")
        do {
            _ = try await client.sendSingleRequest(
                request: URLRequest(url: URL(string: "https://httpbin.org/delay/10")!, timeoutInterval: 1),
                stream: (true, nil)
            )
        } catch {
            XCTAssertEqual(error as? HttpXError, HttpXError.networkError(message: "", code: -1_001))
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5)
    }
}
