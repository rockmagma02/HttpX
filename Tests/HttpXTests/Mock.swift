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

import CryptoKit
import Dispatch
import Foundation
@testable import HttpX

func mockStop() {
    Mock.stop()
}

/// mock for httpbin
func mock() {
    let bundle = Bundle.module
    let network = "httpbin.org:443"

    Mock.start(nil)
    let mock = Mock.getNowUsing()!

    mock.addRoute(networkLocation: network, path: "/delete", method: .delete) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        return MockResponse(
            request: request,
            data: body,
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/get", method: .get) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems ?? []
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        return MockResponse(
            request: request,
            data: body,
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/patch", method: .patch) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        return MockResponse(
            request: request,
            data: body,
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/post", method: .post) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        return MockResponse(
            request: request,
            data: body,
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/put", method: .put) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        return MockResponse(
            request: request,
            data: body,
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/basic-auth") { request, paths in
        let username = paths[0]
        let password = paths[1]

        let expectAuth = "Basic " + Data("\(username):\(password)".utf8).base64EncodedString()
        if let auth = request.value(forHTTPHeaderField: "Authorization"), auth == expectAuth {
            return MockResponse(
                request: request,
                data: nil,
                statusCode: 200,
                headers: [:]
            )
        } else {
            return MockResponse(
                request: request,
                data: nil,
                statusCode: 401,
                headers: [:]
            )
        }
    }

    mock.addRoute(networkLocation: network, path: "/hidden-basic-auth") { request, paths in
        let username = paths[0]
        let password = paths[1]

        let expectAuth = "Basic " + Data("\(username):\(password)".utf8).base64EncodedString()
        if let auth = request.value(forHTTPHeaderField: "Authorization"), auth == expectAuth {
            return MockResponse(
                request: request,
                data: nil,
                statusCode: 200,
                headers: [:]
            )
        } else {
            return MockResponse(
                request: request,
                data: nil,
                statusCode: 404,
                headers: [:]
            )
        }
    }

    mock.addRoute(networkLocation: network, path: "/bearer") { request, _ in
        if let _ = request.value(forHTTPHeaderField: "Authorization") {
            MockResponse(
                request: request,
                data: nil,
                statusCode: 200,
                headers: [:]
            )
        } else {
            MockResponse(
                request: request,
                data: nil,
                statusCode: 401,
                headers: [:]
            )
        }
    }

    mock.addRoute(networkLocation: network, path: "digest-auth") { request, paths in
        func md5(_ string: String) -> String {
            let digest = Insecure.MD5.hash(data: string.data(using: .utf8)!)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }

        let username = paths[1]
        let password = paths[2]

        if let auth = request.value(forHTTPHeaderField: "Authorization") {
            let authDict = Dictionary(
                uniqueKeysWithValues: auth.replacingOccurrences(of: "Digest ", with: "").components(separatedBy: ", ").map {
                    let parts = $0.components(separatedBy: "=")
                    return (parts[0], parts[1])
                }
            )

            let a1 = [username, "me@kennethreitz.com", password].joined(separator: ":")
            let path = request.url!.path(percentEncoded: true)
            let a2 = [request.httpMethod!, path].joined(separator: ":")
            let ha2 = md5(a2)
            let ncValue = authDict["nc"]!.replacingOccurrences(of: "\"", with: "")
            let cnonce = authDict["cnonce"]!.replacingOccurrences(of: "\"", with: "")
            let ha1 = md5(a1)
            let digestData = [ha1, "217835d0c4eab341b22724d842df4640", ncValue, cnonce, "auth", ha2]
            let response = md5(digestData.joined(separator: ":"))

            if response == authDict["response"]!.replacingOccurrences(of: "\"", with: "") {
                return MockResponse(
                    request: request,
                    data: nil,
                    statusCode: 200,
                    headers: [:]
                )
            } else {
                return MockResponse(
                    request: request,
                    data: nil,
                    statusCode: 401,
                    headers: [:]
                )
            }
        } else {
            return MockResponse(
                request: request,
                data: nil,
                statusCode: 401,
                headers: ["Www-Authenticate": "Digest realm=\"me@kennethreitz.com\", nonce=\"217835d0c4eab341b22724d842df4640\", qop=\"auth\", opaque=\"1516e76fc8027c4d6cd60a8d7071bd07\", algorithm=MD5, stale=FALS"]
            )
        }
    }

    mock.addRoute(networkLocation: network, path: "/status") { request, paths in
        MockResponse(
            request: request,
            data: nil,
            statusCode: Int(paths[0])!,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/headers") { request, _ in
        let headers = request.allHTTPHeaderFields!

        var newHeaders = [String: String]()
        for (key, value) in headers {
            newHeaders[key.capitalized] = value
        }
        let json: [String: Any] = [
            "headers": newHeaders,
        ]

        return MockResponse(
            request: request,
            data: try! JSONSerialization.data(withJSONObject: json, options: []),
            statusCode: 200,
            headers: headers
        )
    }

    mock.addRoute(networkLocation: network, path: "/user-agent") { request, _ in
        let userAgent = request.value(forHTTPHeaderField: "User-Agent")!

        let json: [String: Any] = [
            "user-agent": userAgent,
        ]

        return MockResponse(
            request: request,
            data: try! JSONSerialization.data(withJSONObject: json, options: []),
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/cache") { request, paths in
        MockResponse(
            request: request,
            data: nil,
            statusCode: 200,
            headers: ["Cache-Control": "public, max-age=\(paths[0])"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/etag") { request, paths in
        MockResponse(
            request: request,
            data: nil,
            statusCode: 200,
            headers: ["Etag": paths[0]]
        )
    }

    mock.addRoute(networkLocation: network, path: "/response-headers") { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
        let headers = components?.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
        return MockResponse(
            request: request,
            data: nil,
            statusCode: 200,
            headers: headers!
        )
    }

    mock.addRoute(networkLocation: network, path: "/response-headers", method: .post) { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
        let headers = components?.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
        return MockResponse(
            request: request,
            data: nil,
            statusCode: 200,
            headers: headers!
        )
    }

    mock.addRoute(networkLocation: network, path: "/brotli", method: .get) { request, _ in
        let json: [String: Any] = [
            "brotli": true,
        ]

        return MockResponse(
            request: request,
            data: try! JSONSerialization.data(withJSONObject: json, options: []),
            statusCode: 200,
            headers: ["Content-Encoding": "br"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/deflate", method: .get) { request, _ in
        let json: [String: Any] = [
            "deflated": true,
        ]
        return MockResponse(
            request: request,
            data: try! JSONSerialization.data(withJSONObject: json, options: []),
            statusCode: 200,
            headers: ["Content-Encoding": "deflate"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/deny", method: .get) { request, _ in
        MockResponse(
            request: request,
            data: "YOU SHOULDN'T BE HERE, GO AWAY!".data(using: .utf8),
            statusCode: 200,
            headers: ["Content-Type": "text/plain"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/encoding/utf8", method: .get) { request, _ in
        MockResponse(
            request: request,
            data: "<html><body>👋 UTF-8 encoded</body></html>".data(using: .utf8),
            statusCode: 200,
            headers: ["Content-Type": "text/html; charset=utf-8"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/gzip", method: .get) { request, _ in
        let json: [String: Any] = [
            "gzipped": true,
        ]
        return MockResponse(
            request: request,
            data: try! JSONSerialization.data(withJSONObject: json, options: []),
            statusCode: 200,
            headers: ["Content-Encoding": "gzip"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/html", method: .get) { request, _ in
        MockResponse(
            request: request,
            data: "<html><body>👋 UTF-8 encoded</body></html>".data(using: .utf8),
            statusCode: 200,
            headers: ["Content-Type": "text/html; charset=utf-8"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/json", method: .get) { request, _ in
        let json: [String: Any] = [
            "json": true,
        ]
        return MockResponse(
            request: request,
            data: try! JSONSerialization.data(withJSONObject: json, options: []),
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/robots.txt", method: .get) { request, _ in
        MockResponse(
            request: request,
            data: "User-agent: \(request.value(forHTTPHeaderField: "User-agent") ?? "*")".data(using: .utf8),
            statusCode: 200,
            headers: ["Content-Type": "text/plain"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/xml", method: .get) { request, _ in
        MockResponse(
            request: request,
            data:
            """
            <?xml version="1.0" encoding="UTF-8"?>
            .....
            </slideshow>
            """.data(using: .utf8),
            statusCode: 200,
            headers: ["Content-Type": "application/xml"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/base64") { request, paths in
        let base64 = paths[0]
        return MockResponse(
            request: request,
            data: Data(base64Encoded: base64),
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/bytes") { request, paths in
        let length = Int(paths[0])!
        return MockResponse(
            request: request,
            data: Data((0 ..< length).map { _ in UInt8.random(in: 0 ... UInt8.max) }),
            statusCode: 200,
            headers: ["Content-Length": String(length)]
        )
    }

    mock.addRoute(networkLocation: network, path: "/delay") { request, paths in
        if let times = Int(paths[0]) {
            sleep(UInt32(times))
        }
        return MockResponse(
            request: request,
            data: nil,
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/drip") { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!
        let queryItems = components.queryItems!
        let numbytes = Int(queryItems.first(where: { $0.name == "numbytes" })!.value!)!
        let duration = Int(queryItems.first(where: { $0.name == "duration" })!.value!)!
        let delay = Int(queryItems.first(where: { $0.name == "delay" })!.value!)!

        sleep(UInt32(delay))

        let halfbytes = Int(numbytes / 2)
        let restbytes = numbytes - halfbytes
        return MockResponse(
            request: request,
            dataStream: .init { continuation in
                continuation.yield(Data(repeating: 0, count: halfbytes))
                sleep(UInt32(duration))
                continuation.yield(Data(repeating: 0, count: restbytes))
                continuation.finish()
            },
            statusCode: 200,
            headers: [:]
        )
    }

    // <html><head> < title > Links </ title ></ head >< body >< a href = '/links/5/0'>0</a> <a href = '/links/5/1'>1</a> <a href = '/links/5/2'>2</a> <a href = '/links/5/3'>3</a> <a href = '/links/5/4'>4</a> </body ></ html>

    mock.addRoute(networkLocation: network, path: "/links") { request, paths in
        let n = Int(paths[0])!

        let links = (0 ..< n).map { i in
            "<a href='/links/\(n)/\(i)'>\(i)</a>"
        }.joined(separator: " ")
        return MockResponse(
            request: request,
            data: "<html><head><title>Links</title></head><body>\(links)</body></html>".data(using: .utf8),
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/stream-bytes") { request, paths in
        let numbytes = Int(paths[0])!
        return MockResponse(
            request: request,
            data: Data(repeating: 0, count: numbytes),
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/range") { request, paths in
        let numbytes = Int(paths[0])!
        return MockResponse(
            request: request,
            data: Data(repeating: 0, count: numbytes),
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/uuid", method: .get) { request, _ in
        let json: [String: Any] = [
            "uuid": UUID().uuidString,
        ]
        return MockResponse(
            request: request,
            data: try! JSONSerialization.data(withJSONObject: json, options: []),
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/image", method: .get) { request, _ in
        let webp = bundle.url(forResource: "testImage", withExtension: "webp")
        return MockResponse(
            request: request,
            data: InputStream(url: webp!)?.readAllData(),
            statusCode: 200,
            headers: ["Content-Type": "image/webp"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/image/jpeg", method: .get) { request, _ in
        let jpg = bundle.url(forResource: "testImage", withExtension: "jpg")
        return MockResponse(
            request: request,
            data: InputStream(url: jpg!)?.readAllData(),
            statusCode: 200,
            headers: ["Content-Type": "image/jpeg"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/image/png", method: .get) { request, _ in
        let png = bundle.url(forResource: "testImage", withExtension: "png")
        return MockResponse(
            request: request,
            data: InputStream(url: png!)?.readAllData(),
            statusCode: 200,
            headers: ["Content-Type": "image/png"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/image/svg", method: .get) { request, _ in
        let svg = bundle.url(forResource: "testImage", withExtension: "svg")
        return MockResponse(
            request: request,
            data: InputStream(url: svg!)?.readAllData(),
            statusCode: 200,
            headers: ["Content-Type": "image/svg+xml"]
        )
    }

    mock.addRoute(networkLocation: network, path: "/absolute-redirect") { request, paths in
        let nums = Int(paths[0])!
        return MockResponse(
            request: request,
            data: nil,
            statusCode: 302,
            headers: ["Location": "http://httpbin.org/absolute-redirect/\(nums - 1)"]
        )
    }

    mock.addRoute(networkLocation: "httpbin.org:80", path: "/absolute-redirect") { request, paths in
        let nums = Int(paths[0])!
        if nums <= 1 {
            return MockResponse(
                request: request,
                data: nil,
                statusCode: 302,
                headers: ["Location": "http://httpbin.org/get"]
            )
        }
        return MockResponse(
            request: request,
            data: nil,
            statusCode: 302,
            headers: ["Location": "http://httpbin.org/absolute-redirect/\(nums - 1)"]
        )
    }

    mock.addRoute(networkLocation: "httpbin.org:80", path: "/get", method: .get) { request, _ in
        let results: [String: Any] = ["args": []]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        return MockResponse(
            request: request,
            data: body,
            statusCode: 200,
            headers: [:]
        )
    }

    mock.addRoute(networkLocation: network, path: "/redirect-to") { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!
        let location = components.queryItems!.first(where: { $0.name == "url" })!.value!
        return MockResponse(
            request: request,
            data: nil,
            statusCode: 302,
            headers: ["Location": location]
        )
    }

    mock.addRoute(networkLocation: network, path: "/relative-redirect") { request, paths in
        let nums = Int(paths[0])!
        if nums <= 1 {
            return MockResponse(
                request: request,
                data: nil,
                statusCode: 302,
                headers: ["Location": "/get"]
            )
        }
        return MockResponse(
            request: request,
            data: nil,
            statusCode: 302,
            headers: ["Location": "/relative-redirect/\(nums - 1)"]
        )
    }
}
