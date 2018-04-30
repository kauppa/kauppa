import Foundation

/// Array that behaves like a set. This is useful for very small collections,
/// for which hashing the items may take more time than it takes for addressing
/// them in an array.
public struct ArraySet<Element>: Mappable
    where Element: Hashable
{
    var inner = [Element]()

    /// Checks if the array is empty
    public var isEmpty: Bool {
        return self.inner.isEmpty
    }

    /// Returns the number of items in this collection.
    public var count: Int {
        return self.inner.count
    }

    /// Initialize an empty `ArraySet`
    public init() {}

    /// Initialize this collection with a sequence of elements.
    public init<S>(_ sequence: S) where S : Sequence, Element == S.Element {
        for element in sequence {
            if !self.inner.contains(element) {
                self.inner.append(element)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        try self.inner.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        let array = try Array<Element>(from: decoder)
        self.init(array)
    }

    /// Insert an element into this collection.
    ///
    /// - Parameters:
    ///   - The element to be inserted.
    /// - Returns: `true` if the element existed before, and `false` if it didn't.
    @discardableResult public mutating func insert(_ element: Element) -> Bool {
        if self.inner.contains(element) {
            return true
        }

        self.inner.append(element)
        return false
    }

    /// Index the array inside this `ArraySet` - this simply calls the `get` method.
    ///
    /// - Returns: The element (if it exists) or `nil`
    public subscript(i: Int) -> Element? {
        get {
            return get(from: i)
        }
    }

    /// Checks whether an element exists in this collection.
    ///
    /// - Parameters:
    ///   - The element to be searched.
    /// - Returns: `true` if the element exists and `false` if it doesn't.
    public func contains(_ element: Element) -> Bool {
        return self.inner.contains(element)
    }

    /// Index this collection (i.e., get the element if it exists at the index).
    ///
    /// - Parameters:
    ///   - from: The index of the element.
    /// - Returns: The element (if it exists) or `nil`
    public func get(from index: Int) -> Element? {
        return (index < self.inner.count) ? self.inner[index] : nil
    }

    /// Get the item matching the given predicate.
    ///
    /// - Parameters:
    ///   - matching: The predicate function used for matching the element.
    /// - Returns: The element (if it exists) or `nil`
    public func get(matching: (Element) -> Bool) -> Element? {
        return inner.first(where: matching)
    }

    /// Mutate the first element matching the given predicate.
    ///
    /// - Parameters:
    ///   - matching: The predicate function used for matching an element.
    ///   - with: The function to which the mutable element is provided.
    ///   - defaultValue: Optional default value if the element doesn't exist.
    ///
    /// If no element is matched and `defaultValue` is given,
    /// then that value is appended to this collection.
    public mutating func mutateOnce(matching: (Element) -> Bool,
                                    with call: (inout Element) -> Void,
                                    defaultValue: Element? = nil)
    {
        for i in 0..<inner.count {
            if matching(inner[i]) {
                return call(&inner[i])
            }
        }

        // No match has occurred, or the collection is empty. Append the default
        // value and call it.
        if let value = defaultValue {
            inner.append(value)
            call(&inner[inner.count - 1])
        }
    }

    /// Create a new instance with a mapping function applied over all the elements.
    ///
    /// - Parameters:
    ///   - The mapping closure that creates an element using the iterated element.
    /// - Returns: The mapped `ArraySet`
    public func map<E>(_ decorator: (Element) -> E) -> ArraySet<E>
        where E: Hashable
    {
        var arraySet = ArraySet<E>()
        arraySet.inner = self.inner.map(decorator)
        return arraySet
    }

    /// Remove and return the element (if it exists) at the given index.
    ///
    /// - Parameters:
    ///   - at: The index to be removed.
    /// - Returns: The removed element (if it exists) or `nil`
    @discardableResult public mutating func remove(at index: Int) -> Element? {
        return (index < self.inner.count) ? self.inner.remove(at: index) : nil
    }

    /// Remove the element (if it exists) in the collection.
    ///
    /// - Parameters:
    ///   - The element to be removed.
    /// - Returns: `true` if it has been removed, and `false` if it doesn't exist.
    @discardableResult public mutating func remove(_ element: Element) -> Bool {
        guard let index = self.inner.index(of: element) else {
            return false
        }

        self.inner.remove(at: index)
        return true
    }
}

extension ArraySet: Sequence {
    public typealias Iterator = IndexingIterator<Array<Element>>

    public func makeIterator() -> Iterator {
        return inner.makeIterator()
    }
}
