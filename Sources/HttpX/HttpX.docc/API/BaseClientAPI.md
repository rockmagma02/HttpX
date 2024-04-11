# ``BaseClient``

The `BaseClient` class provides a simple interface for making requests and handling responses. It is the base class for the `SyncClient` and `AsyncClient` classes. All Configuration and Session Management are handled by the `BaseClient` class.

## Refer

For more information about Client Usage, see the <doc:Client>

## Topics

### Initializers

- ``init(auth:params:headers:cookies:cookieIdentifier:timeout:followRedirects:maxRedirects:eventHooks:baseURL:defaultEncoding:)``

### Refer Configuration

- ``auth``
- ``baseURL``
- ``cookies``
- ``defaultEncoding``
- ``eventHooks``
- ``followRedirects``
- ``headers``
- ``maxRedirects``
- ``timeout``
- ``params``

### Set Configuration

- ``setAuth(_:)``
- ``setBaseURL(_:)``
- ``setCookies(_:)``
- ``setDefaultEncoding(_:)``
- ``setEventHooks(_:)``
- ``setRedirects(follow:max:)``
- ``setHeaders(_:)``
- ``setTimeout(_:)``
- ``setParams(_:)``
