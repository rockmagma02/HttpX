# ``BasicAuth``

## Use Case

To use Basic Authentication, pass a tuple of the username and password to the `basic` case of the `AuthType` enum.

```swift
let auth = AuthType.basic("username", "password")
let response = HttpX.get(url: .string("https://www.example.com"), auth: auth)
```
