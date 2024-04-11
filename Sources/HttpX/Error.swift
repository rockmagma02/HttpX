// Copyright 2024-2024 Ruiyang Sun. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// MARK: - AuthError

/// Errors that can be thrown by the `Auth` module.
public enum AuthError: Error, Equatable {
    /// The digest authentication is invalid.
    case invalidDigestAuth(message: String = "")
    /// The request is invalid.
    case invalidRequest(message: String = "")
    /// The qop from digest authentication is not supported yet.
    case qopNotSupported(message: String = "")

    // MARK: Public

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case
            (.invalidDigestAuth, .invalidDigestAuth),
            (.invalidRequest, .invalidRequest),
            (.qopNotSupported, .qopNotSupported):
            true

        default:
            false
        }
    }
}

// MARK: - StreamError

/// Errors that can be thrown by the ``SyncResponseStream``
public enum StreamError: Error, Equatable {
    /// The stream has closed, but the data hasn't been fully written.
    case streamHasClosed
}

// MARK: - ContentError

/// Errors that can be thrown by the `Content` module.
public enum ContentError: Error {
    /// The FIle URL cat't be found.
    case pathNotFound
}

// MARK: - HttpXError

/// Errors that can be thrown by the `HttpX` module.
public enum HttpXError: Error, Equatable {
    /// The request is invalid.
    case invalidRequest(message: String = "")
    /// The response is invalid.
    case invalidResponse(message: String = "")
    /// The URL is invalid.
    case invalidURL(message: String = "")
    /// The network error occurred, The Code is form `Foundation.URLError`
    case networkError(message: String = "", code: Int = 0)
    /// The redirect error occurred.
    case redirectError(message: String = "")

    // MARK: Public

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case
            (.invalidRequest, .invalidRequest),
            (.invalidResponse, .invalidResponse),
            (.invalidURL, .invalidURL),
            (.redirectError, .redirectError):
            true

        case let (.networkError(_, lhsCode), .networkError(_, rhsCode)):
            lhsCode == rhsCode

        default:
            false
        }
    }
}

internal func buildError(_ error: any Error) -> any Error {
    if let error = (error as? URLError) {
        return HttpXError.networkError(message: error.localizedDescription, code: error.errorCode)
    }

    return error
}
