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

import Dispatch
import Foundation

// MARK: - WeakRef

/// A generic class that holds a weak reference to an object.
internal class WeakRef<T: AnyObject> {
    // MARK: Lifecycle

    /// Initializes a `WeakRef` instance with the given value.
    /// - Parameter value: The object to hold a weak reference to.
    internal init(_ value: T) {
        self.value = value
    }

    deinit {}

    // MARK: Internal

    /// The weak reference to the object.
    internal weak var value: T?
}

// MARK: - WeakValueDictionary

/// A dictionary that holds weak references to its values.
internal class WeakValueDictionary<K: Hashable, V: AnyObject> {
    // MARK: Lifecycle

    deinit {}

    /// Initializes an empty `WeakValueDictionary` instance.
    internal init() {}

    /// Initializes a `WeakValueDictionary` instance with the given sequence of key-value pairs.
    /// - Parameter keysAndValues: A sequence of key-value pairs to initialize the dictionary with.
    internal init(uniqueKeysWithValues keysAndValues: some Sequence<(K, V)>) {
        for (key, value) in keysAndValues {
            dictionary[key] = WeakRef(value)
        }
    }

    // MARK: Internal

    /// Accesses the value associated with the given key for reading and writing.
    /// - Parameter key: The key to look up in the dictionary.
    internal subscript(key: K) -> V? {
        get {
            dictionary[key]?.value
        }
        set {
            dictionary[key] = newValue.map(WeakRef.init)
        }
    }

    // MARK: Private

    /// The underlying dictionary that holds the weak references to the values.
    private var dictionary: [K: WeakRef<V>] = [:]
}

internal func nameToEncoding(_ name: String) -> String.Encoding? {
    let nameToEncodingTuple: [String: String.Encoding] = [
        "ascii": .ascii,
        "nextstep": .nextstep,
        "japaneseEUC": .japaneseEUC,
        "utf-8": .utf8,
        "utf8": .utf8,
        "iso-8859-1": .isoLatin1,
        "isoLatin1": .isoLatin1,
        "symbol": .symbol,
        "nonLossyASCII": .nonLossyASCII,
        "shiftJIS": .shiftJIS,
        "iso-8859-2": .isoLatin2,
        "isoLatin2": .isoLatin2,
        "unicode": .unicode,
        "windowsCP1251": .windowsCP1251,
        "windowsCP1252": .windowsCP1252,
        "windowsCP1253": .windowsCP1253,
        "windowsCP1254": .windowsCP1254,
        "windowsCP1250": .windowsCP1250,
        "iso2022JP": .iso2022JP,
        "macOSRoman": .macOSRoman,
        "utf-16": .utf16,
        "utf16": .utf16,
        "utf-16be": .utf16BigEndian,
        "utf16BigEndian": .utf16BigEndian,
        "utf-16le": .utf16LittleEndian,
        "utf16LittleEndian": .utf16LittleEndian,
        "utf-32": .utf32,
        "utf32": .utf32,
        "utf-32be": .utf32BigEndian,
        "utf32BigEndian": .utf32BigEndian,
        "utf-32le": .utf32LittleEndian,
        "utf32LittleEndian": .utf32LittleEndian,
    ]
    return nameToEncodingTuple.first { $0.key.lowercased() == name.lowercased() }?.value
}

// MARK: - AsyncDispatchSemphore

internal actor AsyncDispatchSemphore {
    // MARK: Lifecycle

    deinit {}

    internal init(value: Int) {
        self.value = value
    }

    // MARK: Internal

    internal func wait() async {
        value -= 1
        if value < 0 {
            let task = Task<Void, Never> { [self] in
                _ = await withCheckedContinuation { continuation in
                    continuations.append((continuation, UUID()))
                }
            }
            await task.value
        }
    }

    internal func wait(timeout: DispatchTime) async -> DispatchTimeoutResult {
        await withCheckedContinuation { continuation in
            let id = UUID()
            if self.value >= 1 {
                self.value -= 1
                continuation.resume(returning: .success)
                return
            }

            value -= 1
            queue.asyncAfter(deadline: timeout) {
                Task { await self.removeContinuation(id: id, withResult: .timedOut) }
            }
            Task { await self.addContinuation(id: id, continuation: continuation) }
        }
    }

    internal func wait(wallTimeout: DispatchWallTime) async -> DispatchTimeoutResult {
        await withCheckedContinuation { continuation in
            let id = UUID()
            if self.value >= 1 {
                self.value -= 1
                continuation.resume(returning: .success)
                return
            }

            value -= 1
            queue.asyncAfter(wallDeadline: wallTimeout) {
                Task { await self.removeContinuation(id: id, withResult: .timedOut) }
            }
            Task { await self.addContinuation(id: id, continuation: continuation) }
        }
    }

    internal func signal() {
        value += 1
        if let continuation = continuations.first {
            continuations.removeFirst()
            continuation.continuation.resume(returning: .success)
        }
    }

    // MARK: Private

    private var value: Int
    private var continuations = [
        (
            continuation: CheckedContinuation<DispatchTimeoutResult, Never>,
            id: UUID
        ),
    ]()
    private var queue = DispatchQueue(label: "com.AsyncDispatchSemphore.\(UUID().uuidString)")

    private func addContinuation(
        id: UUID,
        continuation: CheckedContinuation<DispatchTimeoutResult, Never>
    ) async {
        continuations.append((continuation, id))
    }

    private func removeContinuation(id: UUID, withResult result: DispatchTimeoutResult?) async {
        if let index = continuations.firstIndex(where: { $0.id == id }) {
            value += 1
            let continuation = continuations.remove(at: index).continuation
            if let result {
                continuation.resume(returning: result)
            }
        }
    }
}
