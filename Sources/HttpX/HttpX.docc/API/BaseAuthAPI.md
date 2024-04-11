# ``BaseAuth``

It provides a method to handle authentication flow based on the request and the last response.

## Custom Authentication

When you create a custom authentication method, you need to implement the `authFlow` method. The method should take two parameters, a `URLRequest` and a `Response`, and return a tuple containing the modified `URLRequest` and a `Bool` value indicating whether the auth is done.

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

In some situation, the auth need to use the response of the request to decide the next request. Like the Digest Auth, after you send the first request, the server will return the `WWW-Authenticate` header, and you need to use the header to generate the `Authorization` header for the next request. In this case, you can return `false` in the second value of the tuple to indicate the auth need to use the response.

## Refer

For more information, you can check <doc:Authentication>

## Topics
