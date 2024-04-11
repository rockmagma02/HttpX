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

@testable import HttpX
import XCTest

final class WeakRefAndWeakValueDictionaryTests: XCTestCase {
    func testWeakRefHoldsWeakReference() {
        // Given
        class TestClass {}
        var instance: TestClass? = TestClass()
        let weakRef = WeakRef(instance!)

        // When
        instance = nil

        // Then
        XCTAssertNil(weakRef.value)
    }

    func testWeakValueDictionaryInsertsAndRetrievesValues() {
        // Given
        class TestClass {}
        let key = "testKey"
        let value = TestClass()
        let dictionary = WeakValueDictionary<String, TestClass>()

        // When
        dictionary[key] = value

        // Then
        XCTAssertNotNil(dictionary[key])

        // When value is deallocated
        dictionary[key] = nil

        // Then
        XCTAssertNil(dictionary[key])
    }

    func testWeakValueDictionaryInitializesWithSequence() {
        // Given
        class TestClass {}
        let sequence: [(String, TestClass)] = [("key1", TestClass()), ("key2", TestClass())]
        let dictionary = WeakValueDictionary(uniqueKeysWithValues: sequence)

        // Then
        XCTAssertNotNil(dictionary["key1"])
        XCTAssertNotNil(dictionary["key2"])
    }
}
