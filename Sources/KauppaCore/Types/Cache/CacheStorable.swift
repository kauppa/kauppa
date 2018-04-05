/// Protocol used by the cache in repositories. This ensures that the repositories
/// contain atmost "N" items at any time, so that we don't run out of memory.
/// Any future queries to the store pushes new elements to the dictionary.
protocol CacheStorable {
    associatedtype Key
    associatedtype Value

    /// Initialize after setting the maximum capacity for this cache.
    ///
    /// Note that this is different from the storage capacity (which indicates
    /// the allocated capacity for a collection, whereas this is the maximum
    /// limit imposed on the number of items in the collection).
    init(withCapacity size: Int)
    /// The capacity of this cache
    var capacity: Int { get }
    /// Return whether the cache is empty
    var isEmpty: Bool { get }
    /// Number of items in the cache
    var count: Int { get }
    /// Index this cache (get/set key/value pairs)
    subscript(key: Key) -> Value? { get set }
}
