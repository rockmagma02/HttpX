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

class URLExtensionsTests: XCTestCase {
    func testIsAbsoluteURL() {
        let absoluteURL = URL(string: "https://www.example.com")!
        XCTAssertTrue(absoluteURL.isAbsoluteURL)

        let relativeURL = URL(string: "/path/to/resource")!
        XCTAssertFalse(relativeURL.isAbsoluteURL)
    }

    func testIsRelativeURL() {
        let absoluteURL = URL(string: "https://www.example.com")!
        XCTAssertFalse(absoluteURL.isRelativeURL)

        let relativeURL = URL(string: "/path/to/resource")!
        XCTAssertTrue(relativeURL.isRelativeURL)
    }

    func testMergeQueryItems() throws {
        var url = URL(string: "https://www.example.com?item1=value1")!
        let newItems = [URLQueryItem(name: "item2", value: "value2"), URLQueryItem(name: "item1", value: "newValue1")]
        try url.mergeQueryItems(newItems)

        XCTAssertTrue(url.query!.contains("item1=newValue1"))
        XCTAssertTrue(url.query!.contains("item2=value2"))
    }

    func testPortOrDefault() {
        let httpURL = URL(string: "http://www.example.com")!
        XCTAssertEqual(URL.portOrDefault(httpURL), 80)

        let httpsURL = URL(string: "https://www.example.com")!
        XCTAssertEqual(URL.portOrDefault(httpsURL), 443)

        let customPortURL = URL(string: "https://www.example.com:8080")!
        XCTAssertEqual(URL.portOrDefault(customPortURL), 8_080)

        let noSchemeURL = URL(string: "www.example.com")!
        XCTAssertNil(URL.portOrDefault(noSchemeURL))
    }

    func testSameOrigin() {
        let url1 = URL(string: "https://www.example.com")!
        let url2 = URL(string: "https://www.example.com/path/to/resource")!
        XCTAssertTrue(URL.sameOrigin(url1, url2))

        let url3 = URL(string: "https://www.example.com:8080")!
        XCTAssertFalse(URL.sameOrigin(url1, url3))
    }

    func testIsHttpsRedirect() {
        let httpURL = URL(string: "http://www.example.com")!
        let httpsURL = URL(string: "https://www.example.com")!
        XCTAssertTrue(URL.isHttpsRedirect(httpURL, location: httpsURL))

        let differentHostURL = URL(string: "https://www.anotherexample.com")!
        XCTAssertFalse(URL.isHttpsRedirect(httpURL, location: differentHostURL))
    }
}
