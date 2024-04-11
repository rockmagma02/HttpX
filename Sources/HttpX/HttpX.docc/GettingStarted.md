# GettingStarted

This Article will guide you on how to get started with HttpX.

## Installation

### Swift Package Manager

The [Swift Package Manager](https://github.com/apple/swift-package-manager) is a tool that manages the distribution of Swift code by automating the process of downloading, compiling, and linking dependencies through integration with the Swift build system.

If your project uses the Swift Package Manager, you can add **HttpX** to it by including the following code in the `Package.swift` file located in your project's root folder.

``` swift
dependencies: [
    .package(url: ""),
]
```

You can now add dependencies to your target as shown below:

``` swift
.target(
    name: "SomeProjects",
    dependencies: ["HttpX"],
)
```

## Quick Use

The code below imports `HttpX` and uses the `get` function to retrieve a web page.

```swift
let response = try get(url: URLType.string("https://www.example.org"))
print(response)
// <Response [200 no error]>
```

Similarly, you can use the `post` function to send a POST request.

```swift
let response = try post(
    url: URLType.string("https://www.example.org"),
    content: Content.json(["key": "value"])
)
print(response)
// <Response [200 no error]>
```

For other common request type, we also provide direct-to-use functions as
shown below.

```swift
let response = try put(
    url: URLType.string("https://www.example.org"),
    content: Content.json(["key": "value"])
)
let response = try patch(url: URLType.string("https://www.example.org"))
let response = try delete(url: URLType.string("https://www.example.org"))
```

Other request types are also supported, you can use them by function `request`:

```swift
let response = try request(
    method: .head,
    url: URLType.string("https://www.example.org"),
)
```

## Pass Query Parameters

When using `HttpX`, there is no need to manually parse the query parameters
into the URL. It is more recommended to pass the `params` directly
to the function.

```swift
let response = try get(
    url: URLType.string("https://httpbin.org/get"),
    params: QueryParamsType.array([("key1", "value1"), ("key2", "value2")])
)
print(response.URLResponse?.url?.absoluteString ?? "")
// https://httpbin.org/get?key1=value1&key2=value2
```

## Retrieve Response Data

You can retrieve the response data by accessing the `data` property of
the response object. The data is returned as a `Data` object.

```swift
let url = "https://httpbin.org/json"
let response = try HttpX.get(url: URLType.string(url))

let data = response.data!
let jsonString = String(data: data, encoding: .utf8)!
let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
```

## Custom Headers

You can pass custom headers to the request by passing a `HeadersType` object.

```swift
let response = try get(
    url: URLType.string("https://httpbin.org/get"),
    headers: HeadersType.dictionary(["key1": "value1", "key2": "value2"]),
)
```

## Add Authentication

**HttpX** Support many common Authentication methods, Like `Basic`,
`Bearer`, `Digest`, etc. You can pass a `AuthType` object to request
to add authentication.

```swift
let user = "user"
let passwd = "passwd"

// Successful authentication
let url = "https://httpbin.org/basic-auth/\(user)/\(passwd)"
let auth = BasicAuth(username: user, password: passwd)
let response = try HttpX.get(url: URLType.string(url), auth: AuthType.class(auth))
```

**HttpX** also support custom Authentication methods, You can see
<doc:Authentication> for more information.

## Streaming Response

You can stream the response data by using the `stream` function. The function
still return a `Response` object, but the `data` property is `nil`. Instead,
you can use the `SyncStream` or `AsyncStream` object to read the data, which
conforms to the `Sequence` protocol.

```swift
let url = "https://httpbin.org/stream-bytes/5000"
let response = try HttpX.stream(method: .get, url: URLType.string(url), chunkSize: 1_024)
XCTAssertEqual(response.URLResponse?.status.0, 200)

var dataLength: [Int] = []
for chunk in response.syncStream! {
    dataLength.append(chunk.count)
}
print(dataLength)
// [1024, 1024, 1024, 1024, 904]
```
