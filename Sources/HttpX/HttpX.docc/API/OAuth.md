# ``OAuth``

## Use Case

For the OAuth Authentication, You can create an instance of the OAuth, and pass it to the `class` case of the `AuthType` enum.

```swift
let auth = OAuthAuth(token: "your token")
let response = HttpX.get(url: .string("https://www.example.com"), auth: .class(auth))
```

The OAuth Auth will set the `Authorization` header as `Bearer token` to the request.
