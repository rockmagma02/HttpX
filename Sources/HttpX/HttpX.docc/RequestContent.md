# Request Content

HttpX provides some common Request Content types to make it easier to send requests with different types of content, Or User also can encode the content by themselves.

## Binary Data

You can send binary data by passing a `Data` object to the `data` case of the `Content` enum.

This situation is useful when you want to send a file or binary data in the request body. Don't forget to set the `Content-Type` header to the appropriate value.

```swift
let data = Data("Hello, World!".utf8)
let response = try post(
    url: .string("https://www.example.com"),
    content: .data(data),
    headers: .dictionary(["Content-Type": "text/plain"]
  )
```

## Text

You can send text data by passing a `String` object to the `text` case of the `Content` enum.

This situation is useful when you want to send text data in the request body. Don't forget to set the `Content-Type` header to the appropriate value.

```swift
let response = try post(
    url: .string("https://www.example.com"),
    content: .text("Hello, World!"),
    headers: .dictionary(["Content-Type": "text/plain"]
  )
```

## URL Encoded Form

You can send URL-encoded form data by passing a dictionary to the `urlEncoded` case of the `Content` enum.

This situation is useful when you want to send form data in the request body. The Content-Type header will be set to `application/x-www-form-urlencoded`.

```swift
let response = try post(
    url: .string("https://www.example.com"),
    content: .urlEncoded(["key": "value"])
)
```

## Multipart Form

You can send multipart form data by passing a <doc:MultiPart> Object to the `multipart` case of the `Content` enum.

This situation is useful when you want to send form data and files in the request body. The Content-Type header will be set to `multipart/form-data`.

```swift
let multipart = MultiPart(
    fromData: ["key": "value"],
    fromFile: ["file": .init(path: url, filename: "file.txt", contentType: "text/plain")]
)

let response = try post(
    url: .string("https://www.example.com"),
    content: .multipart(multipart)
)
```

## JSON

You can send JSON data by passing a any object to the `json` case of the `Content` enum, if the object can't be encoded to JSON, the request will fail.

This situation is useful when you want to send JSON data in the request body. The Content-Type header will be set to `application/json`.

```swift
let response = try post(
    url: .string("https://www.example.com"),
    content: .json(["key": "value"])
)
```
