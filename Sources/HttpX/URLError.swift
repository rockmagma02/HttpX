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

/// URLError extension
public extension URLError {
    /// Receive a response with Informational status code.
    static var informationResponse: Self.Code { .InformationalResponse }

    /// Receive a response with Redirection status code.
    static var redirectionResponse: Self.Code { .RedirectionResponse }

    /// Receive a response with Client Error status code.
    static var clientErrorResponse: Self.Code { .ClientErrorResponse }

    /// Receive a response with Server Error status code.
    static var serverErrorResponse: Self.Code { .ServerErrorResponse }
}

/// URLError extension
public extension URLError.Code {
    // swiftlint:disable no_magic_numbers

    /// Receive a response with Informational status code.
    static let InformationalResponse = URLError.Code(rawValue: 1_000_001)

    /// Receive a response with Redirection status code.
    static let RedirectionResponse = URLError.Code(rawValue: 1_000_003)

    /// Receive a response with Client Error status code.
    static let ClientErrorResponse = URLError.Code(rawValue: 1_000_004)

    /// Receive a response with Server Error status code.
    static let ServerErrorResponse = URLError.Code(rawValue: 1_000_005)

    // swiftlint:enable no_magic_numbers
}
