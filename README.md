# HttpX

**HttpX** is a Swift package that provides easy-to-use HTTP client APIs,
closely modeled after the API of the Python package **httpx**.

## Overview

**HttpX** is a feature-rich HTTP client that build on the top of `URLSession` from the Swift Foundation framework but with a more user-friendly API. It offers both synchronous and asynchronous methods for sending HTTP requests with minimal code. Additionally, **HttpX** simplifies handling authentication, redirects, proxies, cookies, and other features in just a few lines of code.

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

## Quick Picks

```swift
import HttpX

let response = try get(url: URLType.string("https://www.example.org/"))
print(response)
// <Response [200 no error]>
print(response.data!)
// 1256 bytes
print(String(data: response.data!, encoding: .utf8)!)
// <!doctype html><html>...</html>
```

## Documentation

For more information, please refer to the [documentation].

## Features

- [x] Well-established API
- [x] Support for async/await
- [x] Redirects and history
- [x] Easy access to request and response headers, Cookies, and more
- [x] Support for Swift Cookie Identifiers
- [x] Easy Authentication, Basic, Digest, and OAuth
- [x] Common Request body types, JSON, Form, and more
- [x] Uploading files via multipart/form-data
- [x] Streaming Responses
- [ ] Automatic decide DataTask, UploadTask, and DownloadTask
- [ ] pass the URLSessionConfiguration
- [ ] Proxy Support
- [ ] Common Response Content Types Decoding, JSON, HTML, and more

## Thanks For

HttpX is inspired by the Python package [httpx](https://www.python-httpx.org/).
We bring their easy-to-use API to Swift,
making HttpX serves as an adapter to Swift Foundation's URLSession.

We Keep [httpx](https://www.python-httpx.org/)'s
 [license](https://github.com/encode/httpx/blob/master/LICENSE.md) in
our github repository.

## Contribution

We welcome contributions to HttpX by opening a pull request on GitHub.

## License

HttpX is released under the  Apache License, Version 2.0.
