# Authentication

HttpX provides a flexible way to authenticate requests. You can use the `AuthType` enum to specify the authentication method you want to use.

## Basic Authentication

To use Basic Authentication, pass a tuple of the username and password to the `basic` case of the `AuthType` enum.

```swift
let auth = AuthType.basic("username", "password")
let response = HttpX.get(url: .string("https://www.example.com"), auth: auth)
```

## Other Built-in Authentication Methods

HttpX also provides other built-in authentication methods, such as `digest` and `oauth`. You can use these methods by passing the appropriate parameters to the corresponding case of the `AuthType` enum.

### Api-Key Authentication

For the Api-Key Authentication, You can create an instance of the <doc:APIKeyAuth>, and pass it to the `class` case of the `AuthType` enum.

```swift
let auth = APIKeyAuth(key: "your api key")
let response = HttpX.get(url: .string("https://www.example.com"), auth: .class(auth))
```

THe API-Key Auth will set the `x-api-key` header to the request.

### Digest Authentication

For the Digest Authentication, You can create an instance of the <doc:DigestAuth>, and pass it to the `class` case of the `AuthType` enum.

```swift
let auth = DigestAuth(username: "username", password: "password")
let response = HttpX.get(url: .string("https://www.example.com"), auth: .class(auth))
```

The Digest Auth will receive the `WWW-Authenticate` header from the server and send the `Authorization` header to the server.

### OAuth Authentication

For the OAuth Authentication, You can create an instance of the <doc:OAuth>, and pass it to the `class` case of the `AuthType` enum.

```swift
let auth = OAuthAuth(token: "your token")
let response = HttpX.get(url: .string("https://www.example.com"), auth: .class(auth))
```

The OAuth Auth will set the `Authorization` header as `Bearer token` to the request.

## Function-based Authentication

You can also use a function to authenticate requests. The function should take two parameters, a `URLRequest` and a `Response`, and return a tuple containing the modified `URLRequest` and a `Bool` value indicating whether the auth is done.

```swift
let auth = AuthType.func { request, response in
    var request = request
    request.addValue("Bearer token", forHTTPHeaderField: "Authorization")
    return (request, true)
}
```

Some time the auth need to use the response of the request to decide the next request. Like the Digest Auth, after you send the first request, the server will return the `WWW-Authenticate` header, and you need to use the header to generate the `Authorization` header for the next request. In this case, you can return `false` in the second value of the tuple to indicate the auth need to use the response.

## Custom Authentication

If you have a custom authentication method, you can create a class that conforms to the <doc:BaseAuth> protocol and pass an instance of that class to the `class` case of the `AuthType` enum.

```swift
class MyAuth: BaseAuth {
    needRequestBody = false
    needResponseBody = false

    func authFlow(request: URLRequest?, response: Response?) -> (URLRequest?, Bool) {
        var request = request
        request.addValue("Bearer token", forHTTPHeaderField: "Authorization")
        return (request, true)
    }
}
```

Then you can pass an instance of the `MyAuth` class to the `class` case of the `AuthType` enum.

```swift
let auth = MyAuth()
let response = HttpX.get(url: .string("https://www.example.com"), auth: .class(auth))
```

Similarly to the function-based authentication, you can return `false` in the second value of the tuple to indicate the auth need to use the response.
