# ``FunctionAuth``

## Use Case

You can also use a function to authenticate requests. The function should take two parameters, a `URLRequest` and a `Response`, and return a tuple containing the modified `URLRequest` and a `Bool` value indicating whether the auth is done.

```swift
let auth = AuthType.func { request, response in
    var request = request
    request.addValue("Bearer token", forHTTPHeaderField: "Authorization")
    return (request, true)
}
```

Some time the auth need to use the response of the request to decide the next request. Like the Digest Auth, after you send the first request, the server will return the `WWW-Authenticate` header, and you need to use the header to generate the `Authorization` header for the next request. In this case, you can return `false` in the second value of the tuple to indicate the auth need to use the response.
