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

// MARK: - HttpMethodsTests

internal final class HttpMethodsTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testDelete() throws {
        let url = "\(baseURL)/delete"
        let response = try HttpX.delete(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testGet() throws {
        let url = "\(baseURL)/get"
        let response = try HttpX.get(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testPatch() throws {
        let url = "\(baseURL)/patch"
        let response = try HttpX.patch(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testPost() throws {
        let url = "\(baseURL)/post"
        let response = try HttpX.post(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    internal func testPut() throws {
        let url = "\(baseURL)/put"
        let response = try HttpX.put(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(json["args"] as! [String: String], ["test": "ok"])
    }

    // MARK: Private

    private let baseURL: String = "https://httpbin.org"
}

// MARK: - AuthTests

internal final class AuthTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testBasicAuth() throws {
        let user = "user"
        let passwd = "passwd"

        // Successful authentication
        let url = "\(basicURL)/basic-auth/\(user)/\(passwd)"
        let auth = BasicAuth(username: user, password: passwd)
        let response = try HttpX.get(url: URLType.string(url), auth: AuthType.class(auth))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        // Failed authentication
        let url2 = "\(basicURL)/basic-auth/\(user)/\(passwd)"
        let auth2 = BasicAuth(username: user, password: "\(passwd)2")
        let response2 = try HttpX.get(url: URLType.string(url2), auth: AuthType.class(auth2))
        XCTAssertEqual(response2.URLResponse?.status.0, 401)
    }

    internal func testBearerAuth() throws {
        // Successful authentication
        let url = "\(basicURL)/bearer"
        let auth = OAuth(token: "123")
        let response = try HttpX.get(url: URLType.string(url), auth: AuthType.class(auth))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        // Failed authentication
        let url2 = "\(basicURL)/bearer"
        let response2 = try HttpX.get(url: URLType.string(url2))
        XCTAssertEqual(response2.URLResponse?.status.0, 401)
    }

    internal func testDigestAuth() throws {
        let user = "user"
        let passwd = "passwd"

        // Successful authentication
        let url = "\(basicURL)/digest-auth/auth/\(user)/\(passwd)"
        let response = try HttpX.get(url: URLType.string(url), auth: AuthType.class(DigestAuth(username: user, password: passwd)))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        // Failed authentication
        let url2 = "\(basicURL)/digest-auth/auth/\(user)/\(passwd)"
        let response2 = try HttpX.get(url: URLType.string(url2), auth: AuthType.class(DigestAuth(username: user, password: "\(passwd)2")))
        XCTAssertEqual(response2.URLResponse?.status.0, 401)
    }

    internal func testHiddenBasicAuth() throws {
        let user = "user"
        let passwd = "passwd"

        // Successful authentication
        let url = "\(basicURL)/hidden-basic-auth/\(user)/\(passwd)"
        let auth = BasicAuth(username: user, password: passwd)
        let response = try HttpX.get(url: URLType.string(url), auth: AuthType.class(auth))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        // Failed authentication
        let url2 = "\(basicURL)/hidden-basic-auth/\(user)/\(passwd)"
        let auth2 = BasicAuth(username: user, password: "\(passwd)2")
        let response2 = try HttpX.get(url: URLType.string(url2), auth: AuthType.class(auth2))
        XCTAssertEqual(response2.URLResponse?.status.0, 404)
    }

    // MARK: Private

    private let basicURL: String = "https://httpbin.org"
}

// MARK: - StatusCodeTests

internal final class StatusCodeTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testStatus() throws {
        let status = 200
        let url = "\(statusURL)/\(status)"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, status)

        let status2 = 400
        let url2 = "\(statusURL)/\(status2)"
        let response2 = try HttpX.get(url: URLType.string(url2))
        XCTAssertEqual(response2.URLResponse?.status.0, status2)
    }

    // MARK: Private

    private let statusURL: String = "https://httpbin.org/status"
}

// MARK: - RequestInspectionTests

internal final class RequestInspectionTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testHeaders() throws {
        let url = "\(inspectURL)/headers"
        let expectedHeaders = ["test": "ok"]
        let response = try HttpX.get(url: URLType.string(url), headers: HeadersType.dictionary(expectedHeaders))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let headers = json["headers"] as! [String: String]
        XCTAssertEqual(headers["Test"], "ok")
    }

    internal func testUserAgent() throws {
        let url = "\(inspectURL)/user-agent"
        let expectedUserAgent = "test"
        let response = try HttpX.get(url: URLType.string(url), headers: HeadersType.dictionary(["User-Agent": expectedUserAgent]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let userAgent = json["user-agent"] as! String
        XCTAssertEqual(userAgent, expectedUserAgent)
    }

    // MARK: Private

    private let inspectURL: String = "https://httpbin.org"
}

// MARK: - ResponseInspectionTests

internal final class ResponseInspectionTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testCache() throws {
        // Sets a Cache-Control header for n seconds.
        let url = "\(inspectURL)/cache/123"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Cache-Control"), "public, max-age=123")
    }

    internal func testEtag() throws {
        // Assumes the resource has the given etag and responds to If-None-Match and If-Match headers appropriately.
        let url = "\(inspectURL)/etag/123"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Etag"), "123")
    }

    internal func testGetResponseHeader() throws {
        // Returns a set of response headers from the query string.
        let url = "\(inspectURL)/response-headers"
        let response = try HttpX.get(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "test"), "ok")
    }

    internal func testPostResponseHeader() throws {
        // Returns a set of response headers from the query string.
        let url = "\(inspectURL)/response-headers"
        let response = try HttpX.post(url: URLType.string(url), params: QueryParamsType.array([("test", "ok")]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "test"), "ok")
    }

    // MARK: Private

    private let inspectURL: String = "https://httpbin.org"
}

// MARK: - ResponseFormatsTests

internal final class ResponseFormatsTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testBrotli() throws {
        let url = "\(formatURL)/brotli"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Encoding"), "br")

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let brotli = json["brotli"] as! Bool
        XCTAssertTrue(brotli)
    }

    internal func testDeflate() throws {
        let url = "\(formatURL)/deflate"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Encoding"), "deflate")

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let deflate = json["deflated"] as! Bool
        XCTAssertTrue(deflate)
    }

    internal func testDeny() throws {
        let url = "\(formatURL)/deny"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "text/plain")

        let data = response.data!
        let text = String(data: data, encoding: .utf8)!
        XCTAssertTrue(text.contains("YOU SHOULDN'T BE HERE"))
    }

    internal func testUtf8() throws {
        let url = "\(formatURL)/encoding/utf8"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "text/html; charset=utf-8")

        let data = response.data!
        let text = String(data: data, encoding: .utf8)!
        XCTAssertTrue(text.contains("UTF-8 encoded"))
    }

    internal func testGzip() throws {
        let url = "\(formatURL)/gzip"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Encoding"), "gzip")

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let gzip = json["gzipped"] as! Bool
        XCTAssertTrue(gzip)
    }

    internal func testHtml() throws {
        let url = "\(formatURL)/html"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "text/html; charset=utf-8")

        let data = response.data!
        let text = String(data: data, encoding: .utf8)!
        XCTAssertTrue(text.contains("<html>"))
    }

    internal func testJson() throws {
        let url = "\(formatURL)/json"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "application/json")

        let data = response.data!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data, options: []))
    }

    internal func testRobots() throws {
        let url = "\(formatURL)/robots.txt"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "text/plain")

        let data = response.data!
        let text = String(data: data, encoding: .utf8)!
        XCTAssertTrue(text.contains("User-agent: *"))
    }

    internal func testXml() throws {
        let url = "\(formatURL)/xml"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "application/xml")

        let data = response.data!
        let xmlString = String(data: data, encoding: .utf8)!
        XCTAssertTrue(xmlString.hasPrefix("<?xml"))
        XCTAssertTrue(xmlString.hasSuffix("</slideshow>"))
    }

    // MARK: Private

    private let formatURL: String = "https://httpbin.org"
}

// MARK: - DynamicDataTests

internal final class DynamicDataTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testBase64() throws {
        let url = "\(dynamicURL)/base64/SFRUUEJJTiBpcyBhd2Vzb21l"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let text = String(data: data, encoding: .utf8)!
        XCTAssertEqual(text, "HTTPBIN is awesome")
    }

    internal func testBytes() throws {
        let url = "\(dynamicURL)/bytes/1024"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Length"), "1024")
        XCTAssertEqual(response.data?.count, 1_024)
    }

    internal func testDelay() throws {
        let url = "\(dynamicURL)/delay/3"
        let start = Date()
        let response = try HttpX.get(url: URLType.string(url))
        let end = Date()

        XCTAssertEqual(response.URLResponse?.status.0, 200)
        let interval = end.timeIntervalSince(start)
        XCTAssertTrue(interval > 3)
    }

    internal func testDrip() throws {
        let url = "\(dynamicURL)/drip?numbytes=1024&duration=2&delay=1"
        let start = Date()
        let response = try HttpX.get(url: URLType.string(url))
        let end = Date()

        XCTAssertEqual(response.URLResponse?.status.0, 200)
        let interval = end.timeIntervalSince(start)
        XCTAssertTrue(interval > 2)
        XCTAssertEqual(response.data?.count, 1_024)
    }

    internal func testLinks() throws {
        let url = "\(dynamicURL)/links/5/5"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let text = String(data: data, encoding: .utf8)!
        for idx in 0 ... 4 {
            XCTAssertTrue(text.contains("<a href='/links/5/\(idx)'>\(idx)</a>"))
        }
    }

    internal func testRange() throws {
        let url = "\(dynamicURL)/range/1024"
        let response = try HttpX.stream(method: .get, url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        response.readAllFormSyncStream()
        let data = response.data!
        XCTAssertEqual(data.count, 1_024)
    }

    internal func testStream() throws {
        let url = "\(dynamicURL)/stream-bytes/5000"
        let response = try HttpX.stream(method: .get, url: URLType.string(url), chunkSize: 1_024)
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        var dataLength: [Int] = []
        for chunk in response.syncStream! {
            dataLength.append(chunk.count)
        }
        XCTAssertEqual(dataLength.count, 5)
        XCTAssertEqual(dataLength, [1_024, 1_024, 1_024, 1_024, 904])
    }

    internal func testUUID() throws {
        let url = "\(dynamicURL)/uuid"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)

        let data = response.data!
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let uuidString = json["uuid"] as? String
        let uuid = UUID(uuidString: uuidString!)
        XCTAssertNotNil(uuid)
    }

    // MARK: Private

    private let dynamicURL: String = "https://httpbin.org"
}

// MARK: - ImagesTests

internal final class ImagesTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testImage() throws {
        let url = "\(imagesURL)/image"
        let response = try HttpX.get(url: URLType.string(url), headers: HeadersType.dictionary(["Accept": "image/webp"]))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "image/webp")

        let data = response.data!
        let riffHeader: [UInt8] = [0x52, 0x49, 0x46, 0x46] // 'RIFF'
        let webpFormat: [UInt8] = [0x57, 0x45, 0x42, 0x50] // 'WEBP'

        XCTAssertTrue(data.count > 12)
        XCTAssertTrue(data.prefix(4).elementsEqual(riffHeader))
        XCTAssertTrue(data.subdata(in: 8 ..< 12).elementsEqual(webpFormat))
    }

    internal func testJpeg() throws {
        let url = "\(imagesURL)/image/jpeg"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "image/jpeg")

        let data = response.data!
        let jpegHeader: [UInt8] = [0xFF, 0xD8, 0xFF]
        XCTAssertTrue(data.count > 3)
        XCTAssertTrue(data.prefix(3).elementsEqual(jpegHeader))
    }

    internal func testPng() throws {
        let url = "\(imagesURL)/image/png"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "image/png")

        let data = response.data!
        let pngHeader: [UInt8] = [0x89, 0x50, 0x4E, 0x47]
        XCTAssertTrue(data.count > 4)
        XCTAssertTrue(data.prefix(4).elementsEqual(pngHeader))
    }

    internal func testSvg() throws {
        let url = "\(imagesURL)/image/svg"
        let response = try HttpX.get(url: URLType.string(url))
        XCTAssertEqual(response.URLResponse?.status.0, 200)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Content-Type"), "image/svg+xml")

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

        let data = response.data!
        let parser = XMLParser(data: data)
        let svgDelegate = SVGXMLParserDelegate()
        parser.delegate = svgDelegate

        parser.parse()
        XCTAssertTrue(svgDelegate.foundSVGTag)
    }

    // MARK: Private

    private let imagesURL: String = "https://httpbin.org"
}

// MARK: - RedirectsTests

internal final class RedirectsTests: XCTestCase {
    // MARK: Internal

    override class func tearDown() {
        super.tearDown()
        mockStop()
    }

    override func setUp() {
        super.setUp()
        mock()
    }

    internal func testAbsoluteRedirect() throws {
        let url = "\(redirectsURL)/absolute-redirect/3"
        let response = try HttpX.get(url: URLType.string(url), followRedirects: false)
        XCTAssertEqual(response.URLResponse?.status.0, 302)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Location"), "http://httpbin.org/absolute-redirect/2")
        XCTAssertEqual(response.nextRequest?.url?.absoluteString, "http://httpbin.org/absolute-redirect/2")

        let response2 = try HttpX.get(url: URLType.string(url), followRedirects: true)
        XCTAssertEqual(response2.URLResponse?.status.0, 200)
        XCTAssertEqual(response2.history.count, 3)
    }

    internal func testRedirectTo() throws {
        let url = "\(redirectsURL)/redirect-to"
        let response = try HttpX.get(url: URLType.string(url), params: QueryParamsType.dictionary(["url": "https://httpbin.org/"]), followRedirects: false)
        XCTAssertEqual(response.URLResponse?.status.0, 302)
        XCTAssertEqual(response.nextRequest?.url?.absoluteString, "https://httpbin.org/")
    }

    internal func testRelativeRedirect() throws {
        let url = "\(redirectsURL)/relative-redirect/3"
        let response = try HttpX.get(url: URLType.string(url), headers: HeadersType.array([("test", "value")]), followRedirects: false)
        XCTAssertEqual(response.URLResponse?.status.0, 302)
        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Location"), "/relative-redirect/2")
        XCTAssertEqual(response.nextRequest?.url?.absoluteString, "https://httpbin.org/relative-redirect/2")

        let response2 = try HttpX.get(url: URLType.string(url), followRedirects: true)
        XCTAssertEqual(response2.URLResponse?.status.0, 200)
        XCTAssertEqual(response2.history.count, 3)
    }

    // MARK: Private

    private let redirectsURL: String = "https://httpbin.org"
}

// MARK: - OnlineTest

//
// internal final class OnlineTest: XCTestCase {
//    // MARK: Internal
//
//    internal func testRelativeRedirect() throws {
//        let url = "\(baseURL)/relative-redirect/2"
//        let response = try HttpX.get(url: URLType.string(url), headers: HeadersType.array([("test", "value")]), followRedirects: false)
//        XCTAssertEqual(response.URLResponse?.status.0, 302)
//        XCTAssertEqual(response.URLResponse?.getHeaderValue(forHTTPHeaderField: "Location"), "/relative-redirect/1")
//        XCTAssertEqual(response.nextRequest?.url?.absoluteString, "https://httpbin.org/relative-redirect/1")
//
//        let response2 = try HttpX.get(url: URLType.string(url), followRedirects: true)
//        XCTAssertEqual(response2.URLResponse?.status.0, 200)
//        XCTAssertEqual(response2.history.count, 2)
//    }
//
//    internal func testStream() throws {
//        let url = "\(baseURL)/stream-bytes/5000"
//        let response = try HttpX.stream(method: .get, url: URLType.string(url))
//        XCTAssertEqual(response.URLResponse?.status.0, 200)
//
//        var dataLength: [Int] = []
//        for chunk in response.syncStream! {
//            dataLength.append(chunk.count)
//        }
//        XCTAssertEqual(dataLength.count, 5)
//        XCTAssertEqual(dataLength, [1_024, 1_024, 1_024, 1_024, 904])
//    }
//
//    func testSendSingleRequest() throws {
//        // Timeout
//        let client = SyncClient()
//        XCTAssertThrowsError(
//            try client.sendSingleRequest(
//                request: URLRequest(url: URL(string: "https://httpbin.org/delay/10")!, timeoutInterval: 1),
//                stream: (true, nil)
//            )
//        ) { error in
//            XCTAssertEqual(error as? HttpXError, HttpXError.networkError(message: "", code: -1_001))
//        }
//    }
//
//    // MARK: Private
//
//    private let baseURL: String = "https://httpbin.org"
// }
