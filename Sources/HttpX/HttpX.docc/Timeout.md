# Timeout

HttpX supports setting a timeout for requests. This can be done by pass the `timeout` argument to the request method.

## Usage

To set a timeout for a request, pass the `timeout` argument to the request method. The `timeout` argument is of type `TimeInterval` and represents the number of seconds to wait before the request times out.

```swift
let response = try get(url: .string("https://www.example.com"), timeout: 10)
```
