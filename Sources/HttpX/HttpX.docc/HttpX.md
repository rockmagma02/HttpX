# ``HttpX``

**HttpX** is a Swift package that provides easy-to-use HTTP client APIs,
closely modeled after the API of the Python package **httpx**.

## Overview

**HttpX** is a feature-rich HTTP client that build on the top of `URLSession` from the Swift Foundation framework but with a more user-friendly API. It offers both synchronous and asynchronous methods for sending HTTP requests with minimal code. Additionally, **HttpX** simplifies handling authentication, redirects, proxies, cookies, and other features in just a few lines of code.

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

## Topics

### Getting Started

- <doc:GettingStarted>

### Advanced Usage

- <doc:UsefulTypes>
- <doc:Client>
- <doc:RequestContent>
- <doc:Authentication>
- <doc:AsyncSupport>
- <doc:Timeout>
- <doc:EventHooks>

### API Reference

- <doc:TopLevelAPI>
- <doc:ClientAPI>
- <doc:AuthAPI>
- <doc:ContentAPI>
- <doc:TypeAPI>
- ``Foundation/URL``
- <doc:ResponseAPI>
- <doc:ErrorAPI>
- <doc:StreamAPI>
