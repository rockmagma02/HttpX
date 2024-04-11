# ``DigestAuth``

## Use Case

For the Digest Authentication, You can create an instance of the DigestAuth, and pass it to the `class` case of the `AuthType` enum.

```swift
let auth = DigestAuth(username: "username", password: "password")
let response = HttpX.get(url: .string("https://www.example.com"), auth: .class(auth))
```

The Digest Auth will receive the `WWW-Authenticate` header from the server and send the `Authorization` header to the server.
