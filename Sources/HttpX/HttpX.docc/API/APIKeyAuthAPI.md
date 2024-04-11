# ``APIKeyAuth``

## Use Case

For the Api-Key Authentication, You can create an instance of the APIKeyAuth, and pass it to the `class` case of the `AuthType` enum.

```swift
let auth = APIKeyAuth(key: "your api key")
let response = HttpX.get(url: .string("https://www.example.com"), auth: .class(auth))
```

THe API-Key Auth will set the `x-api-key` header to the request.
