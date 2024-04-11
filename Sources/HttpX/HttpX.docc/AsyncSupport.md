# Async Support

HttpX provides support for async/await, which allows you to write asynchronous code in swift ways.

## Why need asynchronous

When you send a request to a server, the server will take some time to process the request and return the response. If you use synchronous code to send the request, the code will block the main thread until the server returns the response. This will make the app unresponsive and slow.

For example, in a synchronous code, Your app will freeze to wait for the response from the server.

To solve this issues, asynchronous is useful. You can use async/await to write asynchronous code in a synchronous way. This will make the app responsive and fast.

## Async Top-Level Function API

HttpX provides async top-level function API to make it easier to send requests asynchronously.

```swift
let response = try await get(url: .string("https://www.example.com")
)
```

The async top-level function API is the same as the top-level function API, You can use all features documented in the [Getting Started](GettingStarted) page.

## Async Client

HttpX provides an async client to make it easier to send requests asynchronously.

```swift
let client = AsyncClient()
let response = try await client.request(
    method: .get,
    url: .string("https://www.example.com")
)
```

The async client is the same as the client, You can use all features documented in the [Client](Client) page.

## Async Stream

Async mode also supports streaming responses. You can use the `AsyncStream` property of the response to get the response data asynchronously.

```swift
let response = try await get(url: .string("https://www.example.com"))
let stream = response.asyncStream
for try await chunk in stream {
    print(chunk)
}
```
