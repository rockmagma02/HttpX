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

// MARK: - AsyncHttpMethodsTests

internal final class AsyncHttpMethodsTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testDelete() async throws {
        let url = "\(baseURL)/delete"
        let response = try await HttpX.delete(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.statusCode, 200)
        let json = try await response.getJSON() as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testGet() async throws {
        let url = "\(baseURL)/get"
        let response = try await HttpX.get(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.statusCode, 200)
        let json = try await response.getJSON() as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testPatch() async throws {
        let url = "\(baseURL)/patch"
        let response = try await HttpX.patch(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.statusCode, 200)
        let json = try await response.getJSON() as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testPost() async throws {
        let url = "\(baseURL)/post"
        let response = try await HttpX.post(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.statusCode, 200)
        let json = try await response.getJSON() as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testPut() async throws {
        let url = "\(baseURL)/put"
        let response = try await HttpX.put(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.statusCode, 200)
        let json = try await response.getJSON() as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    // MARK: Private

    private let baseURL: String = "https://httpbin.org"
}

// MARK: - AsyncAuthTests

internal final class AsyncAuthTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testBasicAuth() async throws {
        let user = "user"
        let passwd = "passwd"

        // Successful authentication
        let url = "\(basicURL)/basic-auth/\(user)/\(passwd)"
        let auth = BasicAuth(username: user, password: passwd)
        let response = try await HttpX.get(url: URLType.string(url), auth: AuthType.class(auth))
        XCTAssertEqual(response.statusCode, 200)

        // Failed authentication
        let url2 = "\(basicURL)/basic-auth/\(user)/\(passwd)"
        let auth2 = BasicAuth(username: user, password: "\(passwd)2")
        let response2 = try await HttpX.get(url: URLType.string(url2), auth: AuthType.class(auth2))
        XCTAssertEqual(response2.statusCode, 401)
    }

    internal func testBearerAuth() async throws {
        // Successful authentication
        let url = "\(basicURL)/bearer"
        let auth = OAuth(token: "123")
        let response = try await HttpX.get(url: URLType.string(url), auth: AuthType.class(auth))
        XCTAssertEqual(response.statusCode, 200)

        // Failed authentication
        let url2 = "\(basicURL)/bearer"
        let response2 = try await HttpX.get(url: URLType.string(url2))
        XCTAssertEqual(response2.statusCode, 401)
    }

    internal func testDigestAuth() async throws {
        let user = "user"
        let passwd = "passwd"

        // Successful authentication
        let url = "\(basicURL)/digest-auth/auth/\(user)/\(passwd)"
        let response = try await HttpX.get(url: URLType.string(url), auth: AuthType.class(DigestAuth(username: user, password: passwd)))
        XCTAssertEqual(response.statusCode, 200)

        // Failed authentication
        let url2 = "\(basicURL)/digest-auth/auth/\(user)/\(passwd)"
        let response2 = try await HttpX.get(url: URLType.string(url2), auth: AuthType.class(DigestAuth(username: user, password: "\(passwd)2")))
        XCTAssertEqual(response2.statusCode, 401)
    }

    internal func testHiddenBasicAuth() async throws {
        let user = "user"
        let passwd = "passwd"

        // Successful authentication
        let url = "\(basicURL)/hidden-basic-auth/\(user)/\(passwd)"
        let auth = BasicAuth(username: user, password: passwd)
        let response = try await HttpX.get(url: URLType.string(url), auth: AuthType.class(auth))
        XCTAssertEqual(response.statusCode, 200)

        // Failed authentication
        let url2 = "\(basicURL)/hidden-basic-auth/\(user)/\(passwd)"
        let auth2 = BasicAuth(username: user, password: "\(passwd)2")
        let response2 = try await HttpX.get(url: URLType.string(url2), auth: AuthType.class(auth2))
        XCTAssertEqual(response2.statusCode, 404)
    }

    // MARK: Private

    private let basicURL: String = "https://httpbin.org"
}

// MARK: - AsyncStatusCodeTests

internal final class AsyncStatusCodeTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testStatus() async throws {
        let status = 200
        let url = "\(statusURL)/\(status)"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, status)

        let status2 = 400
        let url2 = "\(statusURL)/\(status2)"
        let response2 = try await HttpX.get(url: URLType.string(url2))
        XCTAssertEqual(response2.statusCode, status2)
    }

    // MARK: Private

    private let statusURL: String = "https://httpbin.org/status"
}

// MARK: - AsyncRequestInspectionTests

internal final class AsyncRequestInspectionTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testHeaders() async throws {
        let url = "\(inspectURL)/headers"
        let expectedHeaders = ["test": "ok"]
        let response = try await HttpX.get(url: URLType.string(url), headers: HeadersType.dictionary(expectedHeaders))
        XCTAssertEqual(response.statusCode, 200)

        let json = try await response.getJSON() as! [String: Any]
        let headers = json["headers"] as! [String: String]
        XCTAssertEqual(headers["Test"], "ok")
    }

    internal func testUserAgent() async throws {
        let url = "\(inspectURL)/user-agent"
        let expectedUserAgent = "test"
        let response = try await HttpX.get(url: URLType.string(url), headers: HeadersType.dictionary(["User-Agent": expectedUserAgent]))
        XCTAssertEqual(response.statusCode, 200)

        let json = try await response.getJSON() as! [String: Any]
        let userAgent = json["user-agent"] as! String
        XCTAssertEqual(userAgent, expectedUserAgent)
    }

    // MARK: Private

    private let inspectURL: String = "https://httpbin.org"
}

// MARK: - AsyncResponseInspectionTests

internal final class AsyncResponseInspectionTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testCache() async throws {
        // Sets a Cache-Control header for n seconds.
        let url = "\(inspectURL)/cache/123"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Cache-Control"), "public, max-age=123")
    }

    internal func testEtag() async throws {
        // Assumes the resource has the given etag and responds to If-None-Match and If-Match headers appropriately.
        let url = "\(inspectURL)/etag/123"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Etag"), "123")
    }

    internal func testGetResponseHeader() async throws {
        // Returns a set of response headers from the query string.
        let url = "\(inspectURL)/response-headers"
        let response = try await HttpX.get(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "test"), "ok")
    }

    internal func testPostResponseHeader() async throws {
        // Returns a set of response headers from the query string.
        let url = "\(inspectURL)/response-headers"
        let response = try await HttpX.post(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "test"), "ok")
    }

    // MARK: Private

    private let inspectURL: String = "https://httpbin.org"
}

// MARK: - AsyncResponseFormatsTests

internal final class AsyncResponseFormatsTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testBrotli() async throws {
        let url = "\(formatURL)/brotli"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Encoding"), "br")

        let json = try await response.getJSON() as! [String: Any]
        let brotli = json["brotli"] as! Bool
        XCTAssertTrue(brotli)
    }

    internal func testDeflate() async throws {
        let url = "\(formatURL)/deflate"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Encoding"), "deflate")

        let json = try await response.getJSON() as! [String: Any]
        let deflate = json["deflated"] as! Bool
        XCTAssertTrue(deflate)
    }

    internal func testDeny() async throws {
        let url = "\(formatURL)/deny"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "text/plain")

        let text = try await response.getText()
        XCTAssertTrue(text.contains("YOU SHOULDN'T BE HERE"))
    }

    internal func testUtf8() async throws {
        let url = "\(formatURL)/encoding/utf8"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "text/html; charset=utf-8")

        let text = try await response.getText()
        XCTAssertTrue(text.contains("UTF-8 encoded"))
    }

    internal func testGzip() async throws {
        let url = "\(formatURL)/gzip"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Encoding"), "gzip")

        let json = try await response.getJSON() as! [String: Any]
        let gzip = json["gzipped"] as! Bool
        XCTAssertTrue(gzip)
    }

    internal func testHtml() async throws {
        let url = "\(formatURL)/html"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "text/html; charset=utf-8")

        let text = try await response.getText()
        XCTAssertTrue(text.contains("<html>"))
    }

    internal func testJson() async throws {
        let url = "\(formatURL)/json"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "application/json")

        let json = try await response.getJSON()
        XCTAssertNotNil(json)
    }

    internal func testRobots() async throws {
        let url = "\(formatURL)/robots.txt"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "text/plain")

        let text = try await response.getText()
        XCTAssertTrue(text.contains("User-agent: *"))
    }

    internal func testXml() async throws {
        let url = "\(formatURL)/xml"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "application/xml")

        let text = try await response.getText()
        XCTAssertTrue(text.hasPrefix("<?xml"))
        XCTAssertTrue(text.hasSuffix("</slideshow>"))
    }

    // MARK: Private

    private let formatURL: String = "https://httpbin.org"
}

// MARK: - AsyncDynamicDataTests

internal final class AsyncDynamicDataTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testBase64() async throws {
        let url = "\(dynamicURL)/base64/SFRUUEJJTiBpcyBhd2Vzb21l"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)

        let text = try await response.getText()
        XCTAssertEqual(text, "HTTPBIN is awesome")
    }

    internal func testBytes() async throws {
        let url = "\(dynamicURL)/bytes/1024"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Length"), "1024")
        let data = try await response.getData()
        XCTAssertEqual(data.count, 1_024)
    }

    internal func testDelay() async throws {
        let url = "\(dynamicURL)/delay/3"
        let start = Date()
        let response = try await HttpX.get(url: URLType.string(url))
        let end = Date()

        XCTAssertEqual(response.statusCode, 200)
        let interval = end.timeIntervalSince(start)
        XCTAssertTrue(interval > 3)
    }

    internal func testDrip() async throws {
        let url = "\(dynamicURL)/drip?numbytes=1024&duration=2&delay=1"
        let start = Date()
        let response = try await HttpX.get(url: URLType.string(url))

        XCTAssertEqual(response.statusCode, 200)
        let data = try await response.getData()
        let end = Date()
        let interval = end.timeIntervalSince(start)
        XCTAssertTrue(interval > 2)
        XCTAssertEqual(data.count, 1_024)
    }

    internal func testLinks() async throws {
        let url = "\(dynamicURL)/links/5/5"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)

        let text = try await response.getText()
        for idx in 0 ... 4 {
            XCTAssertTrue(text.contains("<a href='/links/5/\(idx)'>\(idx)</a>"))
        }
    }

    internal func testRange() async throws {
        let url = "\(dynamicURL)/range/1024"
        let response = try await HttpX.request(method: .get, url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)

        let data = try await response.getData()
        XCTAssertEqual(data.count, 1_024)
    }

    internal func testStream() async throws {
        let url = "\(dynamicURL)/stream-bytes/5000"
        let response = try await HttpX.request(method: .get, url: URLType.string(url), chunkSize: 1_024)
        XCTAssertEqual(response.statusCode, 200)

        var dataLength: [Int] = []
        for try await chunk in response {
            dataLength.append(chunk.count)
        }
        XCTAssertEqual(dataLength.count, 5)
        XCTAssertEqual(dataLength, [1_024, 1_024, 1_024, 1_024, 904])
    }

    internal func testUUID() async throws {
        let url = "\(dynamicURL)/uuid"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)

        let json = try await response.getJSON() as! [String: Any]
        let uuidString = json["uuid"] as? String
        let uuid = UUID(uuidString: uuidString!)
        XCTAssertNotNil(uuid)
    }

    // MARK: Private

    private let dynamicURL: String = "https://httpbin.org"
}

// MARK: - AsyncImagesTests

internal final class AsyncImagesTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testImage() async throws {
        let url = "\(imagesURL)/image"
        let response = try await HttpX.get(url: URLType.string(url), headers: HeadersType.dictionary(["Accept": "image/webp"]))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "image/webp")

        let data = try await response.getData()
        let riffHeader: [UInt8] = [0x52, 0x49, 0x46, 0x46] // 'RIFF'
        let webpFormat: [UInt8] = [0x57, 0x45, 0x42, 0x50] // 'WEBP'

        XCTAssertTrue(data.count > 12)
        XCTAssertTrue(data.prefix(4).elementsEqual(riffHeader))
        XCTAssertTrue(data.subdata(in: 8 ..< 12).elementsEqual(webpFormat))
    }

    internal func testJpeg() async throws {
        let url = "\(imagesURL)/image/jpeg"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "image/jpeg")

        let data = try await response.getData()
        let jpegHeader: [UInt8] = [0xFF, 0xD8, 0xFF]
        XCTAssertTrue(data.count > 3)
        XCTAssertTrue(data.prefix(3).elementsEqual(jpegHeader))
    }

    internal func testPng() async throws {
        let url = "\(imagesURL)/image/png"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "image/png")

        let data = try await response.getData()
        let pngHeader: [UInt8] = [0x89, 0x50, 0x4E, 0x47]
        XCTAssertTrue(data.count > 4)
        XCTAssertTrue(data.prefix(4).elementsEqual(pngHeader))
    }

    internal func testSvg() async throws {
        let url = "\(imagesURL)/image/svg"
        let response = try await HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Content-Type"), "image/svg+xml")

        // Custom XMLParser delegate to detect SVG tags
        class SVGXMLParserDelegate: NSObject, XMLParserDelegate {
            var foundSVGTag: Bool = false

            func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes _: [String: String] = [:]) {
                if elementName == "svg" {
                    foundSVGTag = true
                    // Once an SVG tag is found, no need to continue parsing
                    parser.abortParsing()
                }
            }
        }

        let data = try await response.getData()
        let parser = XMLParser(data: data)
        let svgDelegate = SVGXMLParserDelegate()
        parser.delegate = svgDelegate

        parser.parse()
        XCTAssertTrue(svgDelegate.foundSVGTag)
    }

    // MARK: Private

    private let imagesURL: String = "https://httpbin.org"
}

// MARK: - AsyncRedirectsTests

internal final class AsyncRedirectsTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testAbsoluteRedirect() async throws {
        let url = "\(redirectsURL)/absolute-redirect/3"
        let response = try await HttpX.get(url: URLType.string(url), followRedirects: false)
        XCTAssertEqual(response.statusCode, 302)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Location"), "http://httpbin.org/absolute-redirect/2")
        XCTAssertEqual(response.nextRequest?.url?.absoluteString, "http://httpbin.org/absolute-redirect/2")

        let response2 = try await HttpX.get(url: URLType.string(url), followRedirects: true)
        XCTAssertEqual(response2.statusCode, 200)
        XCTAssertEqual(response2.history.count, 3)
    }

    internal func testRedirectTo() async throws {
        let url = "\(redirectsURL)/redirect-to"
        let response = try await HttpX.get(url: URLType.string(url), params: QueryParamsType.dictionary(["url": "https://httpbin.org/"]), followRedirects: false)
        XCTAssertEqual(response.statusCode, 302)
        XCTAssertEqual(response.nextRequest?.url?.absoluteString, "https://httpbin.org/")
    }

    internal func testRelativeRedirect() async throws {
        let url = "\(redirectsURL)/relative-redirect/3"
        let response = try await HttpX.get(url: URLType.string(url), followRedirects: false)
        XCTAssertEqual(response.statusCode, 302)
        XCTAssertEqual(response.value(forHTTPHeaderField: "Location"), "/relative-redirect/2")
        XCTAssertEqual(response.nextRequest?.url?.absoluteString, "https://httpbin.org/relative-redirect/2")

        let response2 = try await HttpX.get(url: URLType.string(url), followRedirects: true)
        XCTAssertEqual(response2.statusCode, 200)
        XCTAssertEqual(response2.history.count, 3)
    }

    // MARK: Private

    private let redirectsURL: String = "https://httpbin.org"
}

// MARK: - AsyncOnlineTest

// internal final class AsyncOnlineTest: XCTestCase {
//    // MARK: Internal
//
//    internal func testStream() async throws {
//        let url = "\(baseURL)/stream-bytes/5000"
//        let response = try await HttpX.request(method: .get, url: URLType.string(url), chunkSize: 1_024)
//        XCTAssertEqual(response.statusCode, 200)
//
//        var dataLength: [Int] = []
//        for try await chunk in response {
//            dataLength.append(chunk.count)
//        }
//        XCTAssertEqual(dataLength.count, 5)
//        XCTAssertEqual(dataLength, [1_024, 1_024, 1_024, 1_024, 904])
//    }
//
//    func testSendSingleRequest() async throws {
//        // Timeout
//        let client = AsyncClient()
//        let expectation = expectation(description: "timeout")
//        do {
//            _ = try await client.sendSingleRequest(
//                request: URLRequest(url: URL(string: "https://httpbin.org/delay/10")!, timeoutInterval: 1)
//            )
//        } catch {
//            XCTAssertEqual((error as? URLError)?.code, URLError(.timedOut).code)
//            expectation.fulfill()
//        }
//        await fulfillment(of: [expectation], timeout: 5)
//    }
//
//    func testSendSingleRequestAsync() async throws {
//        // Timeout
//        let client = AsyncClient()
//        let expectation = expectation(description: "timeout")
//        do {
//            _ = try await client.sendSingleRequest(
//                request: URLRequest(url: URL(string: "https://httpbin.org/delay/10")!, timeoutInterval: 1)
//            )
//        } catch {
//            XCTAssertEqual((error as? URLError)?.code, URLError(.timedOut).code)
//            expectation.fulfill()
//        }
//        await fulfillment(of: [expectation], timeout: 5)
//    }
//
//    // MARK: Private
//
//    private let baseURL: String = "https://httpbin.org"
// }
