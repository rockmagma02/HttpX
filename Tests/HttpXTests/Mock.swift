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
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return Response(URLResponse: urlResponse, data: body)
    }

    mock.addRoute(networkLocation: network, path: "/get", method: .get) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return Response(URLResponse: urlResponse, data: body)
    }

    mock.addRoute(networkLocation: network, path: "/patch", method: .patch) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return Response(URLResponse: urlResponse, data: body)
    }

    mock.addRoute(networkLocation: network, path: "/post", method: .post) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return Response(URLResponse: urlResponse, data: body)
    }

    mock.addRoute(networkLocation: network, path: "/put", method: .put) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems!
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return Response(URLResponse: urlResponse, data: body)
    }

    mock.addRoute(networkLocation: network, path: "/basic-auth") { request, paths in
        guard paths.count == 2 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        let username = paths[0]
        let password = paths[1]

        let expectAuth = "Basic " + Data("\(username):\(password)".utf8).base64EncodedString()
        if let auth = request.value(forHTTPHeaderField: "Authorization"), auth == expectAuth {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                data: nil
            )
        } else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }
    }

    mock.addRoute(networkLocation: network, path: "/hidden-basic-auth") { request, paths in
        guard paths.count == 2 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        let username = paths[0]
        let password = paths[1]

        let expectAuth = "Basic " + Data("\(username):\(password)".utf8).base64EncodedString()
        if let auth = request.value(forHTTPHeaderField: "Authorization"), auth == expectAuth {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                data: nil
            )
        } else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }
    }

    mock.addRoute(networkLocation: network, path: "/bearer") { request, _ in
        if let _ = request.value(forHTTPHeaderField: "Authorization") {
            Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                data: nil
            )
        } else {
            Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }
    }

    mock.addRoute(networkLocation: network, path: "digest-auth") { request, paths in
        guard paths.count == 3 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

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
            var path = request.url!.path(percentEncoded: true)
            if path.isEmpty {
                path = "/"
            }
            let query = request.url?.query(percentEncoded: true) ?? ""
            if !query.isEmpty {
                path += "?" + query
            }
            let a2 = [request.httpMethod!, path].joined(separator: ":")
            let ha2 = md5(a2)
            let ncValue = authDict["nc"]!.replacingOccurrences(of: "\"", with: "")
            let cnonce = authDict["cnonce"]!.replacingOccurrences(of: "\"", with: "")
            let ha1 = md5(a1)
            let digestData = [ha1, "217835d0c4eab341b22724d842df4640", ncValue, cnonce, "auth", ha2]
            let response = md5(digestData.joined(separator: ":"))

            if response == authDict["response"]!.replacingOccurrences(of: "\"", with: "") {
                return Response(
                    URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                    data: nil
                )
            } else {
                return Response(
                    URLResponse: HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil),
                    data: nil
                )
            }
        } else {
            let res = HTTPURLResponse(
                url: request.url!, statusCode: 401, httpVersion: nil,
                headerFields: ["Www-Authenticate": "Digest realm=\"me@kennethreitz.com\", nonce=\"217835d0c4eab341b22724d842df4640\", qop=\"auth\", opaque=\"1516e76fc8027c4d6cd60a8d7071bd07\", algorithm=MD5, stale=FALS"]
            )
            return Response(URLResponse: res, data: nil)
        }
    }

    mock.addRoute(networkLocation: network, path: "/status") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: Int(paths[0])!, httpVersion: nil, headerFields: nil),
            data: nil
        )
    }

    mock.addRoute(networkLocation: network, path: "/headers") { request, _ in
        let headers = request.allHTTPHeaderFields ?? [:]
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: request.allHTTPHeaderFields)

        var newHeaders = [String: String]()
        for (key, value) in headers {
            newHeaders[key.capitalized] = value
        }
        let json: [String: Any] = [
            "headers": newHeaders,
        ]

        return Response(
            URLResponse: res,
            data: try! JSONSerialization.data(withJSONObject: json, options: [])
        )
    }

    mock.addRoute(networkLocation: network, path: "/user-agent") { request, _ in
        let userAgent = request.value(forHTTPHeaderField: "User-Agent") ?? ""
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: request.allHTTPHeaderFields)

        let json: [String: Any] = [
            "user-agent": userAgent,
        ]

        return Response(
            URLResponse: res,
            data: try! JSONSerialization.data(withJSONObject: json, options: [])
        )
    }

    mock.addRoute(networkLocation: network, path: "/cache") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Cache-Control": "public, max-age=\(paths[0])"]),
            data: nil
        )
    }

    mock.addRoute(networkLocation: network, path: "/etag") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Etag": paths[0]]),
            data: nil
        )
    }

    mock.addRoute(networkLocation: network, path: "/response-headers") { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
        let headers = components?.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        } ?? [:]
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: headers)

        return Response(
            URLResponse: res,
            data: nil
        )
    }

    mock.addRoute(networkLocation: network, path: "/response-headers", method: .post) { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
        let headers = components?.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        } ?? [:]
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: headers)

        return Response(
            URLResponse: res,
            data: nil
        )
    }

    mock.addRoute(networkLocation: network, path: "/brotli", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Encoding": "br"])

        let json: [String: Any] = [
            "brotli": true,
        ]

        return Response(
            URLResponse: res,
            data: try! JSONSerialization.data(withJSONObject: json, options: [])
        )
    }

    mock.addRoute(networkLocation: network, path: "/deflate", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Encoding": "deflate"])

        let json: [String: Any] = [
            "deflated": true,
        ]

        return Response(
            URLResponse: res,
            data: try! JSONSerialization.data(withJSONObject: json, options: [])
        )
    }

    mock.addRoute(networkLocation: network, path: "/deny", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/plain"])

        return Response(
            URLResponse: res,
            data: "YOU SHOULDN'T BE HERE, GO AWAY!".data(using: .utf8)
        )
    }

    mock.addRoute(networkLocation: network, path: "/encoding/utf8", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/html; charset=utf-8"])

        return Response(
            URLResponse: res,
            data: "<html><body>👋 UTF-8 encoded</body></html>".data(using: .utf8)
        )
    }

    mock.addRoute(networkLocation: network, path: "/gzip", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Encoding": "gzip"])

        let json: [String: Any] = [
            "gzipped": true,
        ]

        return Response(
            URLResponse: res,
            data: try! JSONSerialization.data(withJSONObject: json, options: [])
        )
    }

    mock.addRoute(networkLocation: network, path: "/html", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/html; charset=utf-8"])

        return Response(
            URLResponse: res,
            data: "<html><body>👋 UTF-8 encoded</body></html>".data(using: .utf8)
        )
    }

    mock.addRoute(networkLocation: network, path: "/json", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])

        let json: [String: Any] = [
            "json": true,
        ]

        return Response(
            URLResponse: res,
            data: try! JSONSerialization.data(withJSONObject: json, options: [])
        )
    }

    mock.addRoute(networkLocation: network, path: "/robots.txt", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/plain"])

        return Response(
            URLResponse: res,
            data: "User-agent: \(request.value(forHTTPHeaderField: "User-agent") ?? "*")".data(using: .utf8)
        )
    }

    mock.addRoute(networkLocation: network, path: "/xml", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/xml"])

        return Response(
            URLResponse: res,
            data:
            """
            <?xml version="1.0" encoding="UTF-8"?>
            .....
            </slideshow>
            """.data(using: .utf8)
        )
    }

    mock.addRoute(networkLocation: network, path: "/base64") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        let base64 = paths[0]
        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            data: Data(base64Encoded: base64)
        )
    }

    mock.addRoute(networkLocation: network, path: "/bytes") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        let length = Int(paths[0])!
        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Length": String(length)]),
            data: Data((0 ..< length).map { _ in UInt8.random(in: 0 ... UInt8.max) })
        )
    }

    mock.addRoute(networkLocation: network, path: "/delay") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        if let times = Int(paths[0]) {
            let requestTimeout = request.timeoutInterval
            if Int(requestTimeout) <= times {
                let res = Response()
                res.error = HttpXError.networkError(message: "time out", code: -1_001)
                return res
            }

            sleep(UInt32(times))
        }
        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            data: nil
        )
    }

    mock.addRoute(networkLocation: network, path: "/drip") { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!
        let queryItems = components.queryItems!
        let numbytes = Int(queryItems.first(where: { $0.name == "numbytes" })?.value ?? "10")!
        let duration = Int(queryItems.first(where: { $0.name == "duration" })?.value ?? "2")!
        let delay = Int(queryItems.first(where: { $0.name == "delay" })?.value ?? "0")!

        sleep(UInt32(delay))

        let halfbytes = Int(numbytes / 2)
        let restbytes = numbytes - halfbytes

        let syncQueue = DispatchQueue(label: "com.httpx.mock.drip.\(UUID().uuidString)")
        let syncResponseStream = SyncResponseStream()
        syncQueue.sync {
            do {
                try syncResponseStream.write(Data(repeating: 0, count: halfbytes))
                sleep(UInt32(duration))
                try syncResponseStream.write(Data(repeating: 0, count: restbytes))
                syncResponseStream.close()
            } catch {
                print("Error: \(error)")
            }
        }

        let asyncQueue = DispatchQueue(label: "com.httpx.mock.drip.\(UUID().uuidString)")
        let asyncResponseStream = AsyncStream<Data> { continuation in
            asyncQueue.sync {
                continuation.yield(Data(repeating: 0, count: halfbytes))
                sleep(UInt32(duration))
                continuation.yield(Data(repeating: 0, count: restbytes))
                continuation.finish()
            }
        }

        sleep(UInt32(duration))

        let response = Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            data: Data(repeating: 0, count: numbytes)
        )
        response.syncStream = syncResponseStream
        response.asyncStream = asyncResponseStream
        return response
    }

    // <html><head> < title > Links </ title ></ head >< body >< a href = '/links/5/0'>0</a> <a href = '/links/5/1'>1</a> <a href = '/links/5/2'>2</a> <a href = '/links/5/3'>3</a> <a href = '/links/5/4'>4</a> </body ></ html>

    mock.addRoute(networkLocation: network, path: "/links") { request, paths in
        let n = Int(paths[0])!

        let links = (0 ..< n).map { i in
            "<a href='/links/\(n)/\(i)'>\(i)</a>"
        }.joined(separator: " ")
        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            data: "<html><head><title>Links</title></head><body>\(links)</body></html>".data(using: .utf8)
        )
    }

    mock.addRoute(networkLocation: network, path: "/stream-bytes") { request, paths in
        let numbytes = Int(paths[0])!

        let syncQueue = DispatchQueue(label: "com.httpx.mock.drip.\(UUID().uuidString)")
        let syncResponseStream = SyncResponseStream()
        syncQueue.sync {
            do {
                try syncResponseStream.write(Data(repeating: 0, count: numbytes))
                syncResponseStream.close()
            } catch {
                print("Error: \(error)")
            }
        }

        let asyncQueue = DispatchQueue(label: "com.httpx.mock.drip.\(UUID().uuidString)")
        let asyncResponseStream = AsyncStream<Data> { continuation in
            asyncQueue.sync {
                continuation.yield(Data(repeating: 0, count: 1_024))
                continuation.yield(Data(repeating: 0, count: 1_024))
                continuation.yield(Data(repeating: 0, count: 1_024))
                continuation.yield(Data(repeating: 0, count: 1_024))
                continuation.yield(Data(repeating: 0, count: 904))
                continuation.finish()
            }
        }

        let response = Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            data: nil
        )
        response.syncStream = syncResponseStream
        response.asyncStream = asyncResponseStream
        return response
    }

    mock.addRoute(networkLocation: network, path: "/range") { request, paths in
        let numbytes = Int(paths[0])!

        let syncQueue = DispatchQueue(label: "com.httpx.mock.drip.\(UUID().uuidString)")
        let syncResponseStream = SyncResponseStream()
        syncQueue.sync {
            do {
                try syncResponseStream.write(Data(repeating: 0, count: numbytes))
                syncResponseStream.close()
            } catch {
                print("Error: \(error)")
            }
        }

        let asyncQueue = DispatchQueue(label: "com.httpx.mock.drip.\(UUID().uuidString)")
        let asyncResponseStream = AsyncStream<Data> { continuation in
            asyncQueue.sync {
                continuation.yield(Data(repeating: 0, count: numbytes))
                continuation.finish()
            }
        }

        let response = Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            data: nil
        )
        response.syncStream = syncResponseStream
        response.asyncStream = asyncResponseStream
        return response
    }

    mock.addRoute(networkLocation: network, path: "/uuid", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let json: [String: Any] = [
            "uuid": UUID().uuidString,
        ]

        return Response(
            URLResponse: res,
            data: try! JSONSerialization.data(withJSONObject: json, options: [])
        )
    }

    mock.addRoute(networkLocation: network, path: "/image", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/webp"])

        let webp = bundle.url(forResource: "testImage", withExtension: "webp")

        return Response(
            URLResponse: res,
            data: InputStream(url: webp!)?.readAllData()
        )
    }

    mock.addRoute(networkLocation: network, path: "/image/jpeg", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/jpeg"])

        let jpg = bundle.url(forResource: "testImage", withExtension: "jpg")

        return Response(
            URLResponse: res,
            data: InputStream(url: jpg!)?.readAllData()
        )
    }

    mock.addRoute(networkLocation: network, path: "/image/png", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/png"])

        let png = bundle.url(forResource: "testImage", withExtension: "png")

        return Response(
            URLResponse: res,
            data: InputStream(url: png!)?.readAllData()
        )
    }

    mock.addRoute(networkLocation: network, path: "/image/svg", method: .get) { request, _ in
        let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/svg+xml"])

        let svg = bundle.url(forResource: "testImage", withExtension: "svg")

        return Response(
            URLResponse: res,
            data: InputStream(url: svg!)?.readAllData()
        )
    }

    mock.addRoute(networkLocation: network, path: "/absolute-redirect") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        let nums = Int(paths[0])!
        if nums <= 1 {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil, headerFields: ["Location": "http://httpbin.org/get"]),
                data: nil
            )
        }

        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil, headerFields: ["Location": "http://httpbin.org/absolute-redirect/\(nums - 1)"]),
            data: nil
        )
    }

    mock.addRoute(networkLocation: "httpbin.org:80", path: "/absolute-redirect") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        let nums = Int(paths[0])!
        if nums <= 1 {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil, headerFields: ["Location": "http://httpbin.org/get"]),
                data: nil
            )
        }

        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil, headerFields: ["Location": "http://httpbin.org/absolute-redirect/\(nums - 1)"]),
            data: nil
        )
    }

    mock.addRoute(networkLocation: "httpbin.org:80", path: "/get", method: .get) { request, _ in
        let queries = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!.queryItems ?? []
        var args = [String: String]()
        for query in queries {
            args[query.name] = query.value
        }
        let results: [String: Any] = ["args": args]
        let body = try! JSONSerialization.data(withJSONObject: results, options: [])
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return Response(URLResponse: urlResponse, data: body)
    }

    mock.addRoute(networkLocation: network, path: "/redirect-to") { request, _ in
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!
        let location = components.queryItems!.first(where: { $0.name == "url" })!.value!

        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil, headerFields: ["Location": location]),
            data: nil
        )
    }

    mock.addRoute(networkLocation: network, path: "/relative-redirect") { request, paths in
        guard paths.count == 1 else {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                data: nil
            )
        }

        let nums = Int(paths[0])!
        if nums <= 1 {
            return Response(
                URLResponse: HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil, headerFields: ["Location": "http://httpbin.org/get"]),
                data: nil
            )
        }

        return Response(
            URLResponse: HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil, headerFields: ["Location": "/relative-redirect/\(nums - 1)"]),
            data: nil
        )
    }
}
