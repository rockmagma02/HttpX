# Useful Types

**HttpX** offers various types that facilitate working with HTTP requests and responses. These types allow users to specify arguments in different ways, such as passing the `url` as either a `String` or a `URL`.

## URLType

The `URLType` type is an enum that allows users to specify the `url` argument in different ways. The `URLType` enum has three cases: `string`, `class`, `components`.

```swift
URLType.string(_: string)
URLType.class(_: Foundation.URL)
URLType.components(_: Foundation.URLComponents)
```

Usually, you can use the URLType object to pass to the API which HttpX provides. For example, you can pass the `URLType` object to the `get` method of the `HttpX` object.

```swift
let url = URLType.string("https://www.example.com")
let response = HttpX.get(url: url)
```

`URLType` can easily be converted to a `URL` object by using the `buildURL` method.

```swift
let urlType = URLType.string("https://www.example.com")
let url: FoundationURL = urlType.buildURL()
```

## QueryParamsType

The `QueryParamsType` type is an enum that allows users to specify the `query` argument in different ways. The `QueryParamsType` enum has three case: `class`, `dictionary`, `array`.

```swift
QueryParamsType.class(_: [URLQueryItem])
QueryParamsType.dictionary(_: [String: String])
QueryParamsType.array(_: [(String, String)])
```

You can choose one way to build a QueryParams to pass to the API which HttpX provides. For example, you can pass the `QueryParamsType` object to the `get` method of the `HttpX` object.

```swift
let query = QueryParamsType.dictionary(["key": "value"])
let response = HttpX.get(url: URLType.string("https://www.example.com"), query: query)
```

`QueryParamsType` can easily be converted to a `[URLQueryItem]` object by using the `buildQueryItems` method.

```swift
let queryParamsType = QueryParamsType.dictionary(["key": "value"])
let queryItems: [URLQueryItem] = queryParamsType.buildQueryItems()
```

## Content

The `Content` type is an enum that allows users to specify the `content` argument in different ways. The `Content` enum has five cases: `data`, `string`, `urlEncoded`, `multipart`, `json`.

For more information about the Content type, see the <doc:Content> page.

## HeadersType

The `HeadersType` type is an enum that allows users to specify the `headers` argument in different ways. The `HeadersType` enum has two cases: `array`, `dictionary`.

```swift
HeadersType.array(_: [(String, String)])
HeadersType.dictionary(_: [String: String])
```

You can choose one way to build a Headers to pass to the API which HttpX provides. For example, you can pass the `HeadersType` object to the `get` method of the `HttpX` object.

```swift
let headers = HeadersType.dictionary(["key": "value"])
let response = HttpX.get(url: URLType.string("https://www.example.com"), headers: headers)
```

`HeadersType` can easily be converted to a `[(String, String)]` object by using the `buildHeaders` method.

```swift
let headersType = HeadersType.dictionary(["key": "value"])
let headers: [(String, String)] = headersType.buildHeaders()
```

## CookiesType

The `CookiesType` type is an enum that allows users to specify the `cookies` argument in different ways. The `CookiesType` enum has three cases: `array`, `cookieArray`, `storage`.

```swift
CookiesType.array(_: [(String, String, String, String)]) // (name, value, domain, path)
CookiesType.cookieArray(_: [Foundation.HTTPCookie])
CookiesType.storage(_: Foundation.HTTPCookieStorage)
```

You can choose one way to build a Cookies to pass to the API which HttpX provides. For example, you can pass the `CookiesType` object to the `get` method of the `HttpX` object.

```swift
let cookies = CookiesType.array([("name", "value", "domain", "path")])
let response = HttpX.get(url: URLType.string("https://www.example.com"), cookies: cookies)
```

`CookiesType` can easily be converted to a `[HTTPCookie]` object by using the `buildCookies` method.

```swift
let cookiesType = CookiesType.array([("name", "value", "domain", "path")])
let cookies: [HTTPCookie] = cookiesType.buildCookies()
```

## AuthType

The `AuthType` type is an enum that allows users to specify the `auth` argument in different ways. The `AuthType` enum has two cases: `class`, `func`, `basic`

```swift
AuthType.class(_: any BaseAuth)
AuthType.func(_: (URLRequest?, Response?) -> (URLRequest, Bool))
AuthType.basic(_: (String, String)) // (username, password)
```

You can choose one way to build a Auth to pass to the API which HttpX provides. For example, you can pass the `AuthType` object to the `get` method of the `HttpX` object.

```swift
let auth = AuthType.basic("username", "password")
let response = HttpX.get(url: URLType.string("https://www.example.com"), auth: auth)
```

For more information about the `BaseAuth` protocol, and Function-based authentication, see the <doc:Authentication>

`AuthType` can easily be converted to a `BaseAuth` object by using the `buildAuth` method.

```swift
let authType = AuthType.basic("username", "password")
let auth: BaseAuth = authType.buildAuth()
```
