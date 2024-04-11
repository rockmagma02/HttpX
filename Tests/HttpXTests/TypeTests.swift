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

// MARK: - URLTypeTests

class URLTypeTests: XCTestCase {
    func testBuildURLWithClass() {
        let expectedURL = URL(string: "https://www.example.com")!
        let urlType = URLType.class(expectedURL)
        XCTAssertEqual(urlType.buildURL(), expectedURL)
    }

    func testBuildURLWithComponents() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.example.com"
        let expectedURL = components.url!
        let urlType = URLType.components(components)
        XCTAssertEqual(urlType.buildURL(), expectedURL)
    }

    func testBuildURLWithString() {
        let urlString = "https://www.example.com"
        let expectedURL = URL(string: urlString)!
        let urlType = URLType.string(urlString)
        XCTAssertEqual(urlType.buildURL(), expectedURL)
    }

    func testBuildURLWithStringFailure() {
        let urlString = ""
        let urlType = URLType.string(urlString)
        XCTAssertNil(urlType.buildURL())
    }
}

// MARK: - QueryParamsTypeTests

class QueryParamsTypeTests: XCTestCase {
    func testBuildQueryItemsWithClass() {
        let queryItems = [URLQueryItem(name: "key1", value: "value1"), URLQueryItem(name: "key2", value: "value2")]
        let queryParams = QueryParamsType.class(queryItems)
        let result = queryParams.buildQueryItems()
        XCTAssertEqual(result, queryItems)
    }

    func testBuildQueryItemsWithArray() {
        let array = [("key1", "value1"), ("key2", "value2")]
        let queryParams = QueryParamsType.array(array)
        let result = queryParams.buildQueryItems()
        XCTAssertEqual(result, [URLQueryItem(name: "key1", value: "value1"), URLQueryItem(name: "key2", value: "value2")])
    }

    func testBuildQueryItemsWithDictionary() {
        let dictionary = ["key1": "value1", "key2": "value2"]
        let queryParams = QueryParamsType.dictionary(dictionary)
        let result = queryParams.buildQueryItems()
        XCTAssertEqual(Set(result), Set([URLQueryItem(name: "key1", value: "value1"), URLQueryItem(name: "key2", value: "value2")]))
    }
}

// MARK: - HeadersTypeTests

class HeadersTypeTests: XCTestCase {
    func testBuildHeaders_withArray() {
        // Given
        let headersArray: [(String, String)] = [("Content-Type", "application/json"), ("Accept", "application/json")]
        let headersType = HeadersType.array(headersArray)

        // When
        let result = headersType.buildHeaders()

        // Then
        XCTAssertTrue(result[0].0 == "Content-Type" && result[0].1 == "application/json" && result[1].0 == "Accept" && result[1].1 == "application/json")
    }

    func testBuildHeaders_withDictionary() {
        // Given
        let headersDictionary: [String: String] = ["Content-Type": "application/json", "Accept": "application/json"]
        let headersType = HeadersType.dictionary(headersDictionary)

        // When
        var result = headersType.buildHeaders()
        result.sort { $0.0 > $1.0 }

        // Then
        XCTAssertTrue(result[0].0 == "Content-Type" && result[0].1 == "application/json" && result[1].0 == "Accept" && result[1].1 == "application/json")
    }
}

// MARK: - CookiesTypeTests

class CookiesTypeTests: XCTestCase {
    func testBuildCookiesWithArray() {
        let cookiesType = CookiesType.array([("name1", "value1", "example.com", "/"), ("name2", "value2", "example.com", nil)])
        let cookies = cookiesType.buildCookies()

        XCTAssertEqual(cookies.count, 2)
        XCTAssertEqual(cookies.first?.name, "name1")
        XCTAssertEqual(cookies.first?.value, "value1")
        XCTAssertEqual(cookies.last?.name, "name2")
        XCTAssertEqual(cookies.last?.value, "value2")
    }

    func testBuildCookiesWithCookieArray() {
        let cookie1 = HTTPCookie(properties: [.name: "name1", .value: "value1", .domain: "example.com", .path: "/"])!
        let cookie2 = HTTPCookie(properties: [.name: "name2", .value: "value2", .domain: "example.com", .path: "/"])!
        let cookiesType = CookiesType.cookieArray([cookie1, cookie2])
        let cookies = cookiesType.buildCookies()

        XCTAssertEqual(cookies.count, 2)
        XCTAssertTrue(cookies.contains(where: { $0.name == "name1" && $0.value == "value1" }))
        XCTAssertTrue(cookies.contains(where: { $0.name == "name2" && $0.value == "value2" }))
    }

    func testBuildCookiesWithStorage() {
        let storage = HTTPCookieStorage.shared

        let emptyCookiesType = CookiesType.storage(storage)
        let emptyCookies = emptyCookiesType.buildCookies()
        XCTAssertEqual(emptyCookies.count, 0)

        let cookie = HTTPCookie(properties: [.name: "name", .value: "value", .domain: "example.com", .path: "/"])!
        storage.setCookie(cookie)

        let cookiesType = CookiesType.storage(storage)
        let cookies = cookiesType.buildCookies()

        XCTAssertNotNil(cookies.first(where: { $0.name == "name" && $0.value == "value" }))

        // Clean up
        storage.deleteCookie(cookie)
    }

    func testEmptyStroage() {
        let storage = HTTPCookieStorage()

        let emptyCookiesType = CookiesType.storage(storage)
        let emptyCookies = emptyCookiesType.buildCookies()
        XCTAssertEqual(emptyCookies.count, 0)
    }
}

// MARK: - AuthTypeTests

class AuthTypeTests: XCTestCase {
    func testBuildAuthWithClass() {
        let mockAuth = BasicAuth(username: "user", password: "pass")
        let authType = AuthType.class(mockAuth)
        let result = authType.buildAuth()
        XCTAssertTrue(result is BasicAuth)
    }

    func testBuildAuthWithBasic() {
        let username = "user"
        let password = "pass"
        let authType = AuthType.basic((username, password))
        let result = authType.buildAuth()
        XCTAssertTrue(result is BasicAuth)
    }

    func testBuildAuthWithFunc() throws {
        let authFunction: (URLRequest?, Response?) -> (URLRequest, Bool) = { _, _ in
            (URLRequest(url: URL(string: "https://example.com")!), true)
        }
        let authType = AuthType.func(authFunction)
        let result = authType.buildAuth()
        _ = try result.authFlow(request: nil, lastResponse: nil)
        XCTAssertTrue(result is FunctionAuth)
    }
}
