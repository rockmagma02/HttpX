# ``MultiPart``

## Use Case

You can send multipart form data by passing a `MultiPart` Object to the `multipart` case of the `Content` enum.

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

## Topics

### Initializer

- ``init(fromData:fromFile:boundary:)``

### Body and Headers

- ``contentLength``
- ``body``
- ``headers``

### File

- ``File``
