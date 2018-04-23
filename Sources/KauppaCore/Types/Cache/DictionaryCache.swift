
extension Dictionary {
    /// Extension to index the key-value pairs in a dictionary.
    subscript(i: Int) -> (key: Key, value: Value) {
        get {
            return self[index(startIndex, offsetBy: i)]
        }
    }
}

/// Wrapper around the dictionary in standard library to
/// support capacity-based clamping on the collection items.
/// This holds `capacity` items at any time and removes values
/// when they overflow.
public struct DictionaryCache<K: Hashable, V>: CacheStorable {
    public typealias Key = K
    public typealias Value = V

    private var inner = [Key: Value]()

    public var capacity: Int

    public var isEmpty: Bool {
        return inner.isEmpty
    }

    public var count: Int {
        return inner.count
    }

    public init(with capacity: Int) {
        self.capacity = capacity
    }

    public subscript(key: Key) -> Value? {
        get {
            return inner[key]
        }

        set(value) {
            // Remove a key/value pair whenever we go beyond the specified capacity.
            //
            // Note that this depends on the built-in hasher, type of the value,
            // allocated capacity of this dictionary, etc. So, it may not be consistent
            // and can remove any pair.
            while inner.count >= capacity {
                let (someKey, _) = inner[inner.count / 2]
                inner.removeValue(forKey: someKey)
            }

            inner[key] = value
        }
    }
}
