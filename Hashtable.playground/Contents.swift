//: Playground - noun: a place where people can play

import Foundation

struct Hashtable<Key: Hashable, Value>: CustomStringConvertible, CustomDebugStringConvertible {
    private typealias Element = (key: Key, value: Value)
    private typealias Bucket = [Element]
    private var buckets: [Bucket]
    
    private(set) public var count = 0
    
    public var isEmpty: Bool { return count == 0 }
    
    public var description: String {
        let pairs = buckets.flatMap { $0.map { "\($0.key) = \($0.value)" } }
        return pairs.joined(separator: ", ")
    }
    
    public var debugDescription: String {
        var str = ""
        for (i, bucket) in buckets.enumerated() {
            let pairs = bucket.map { "\($0.key) = \($0.value)" }
            str += "bucket \(i): " + pairs.joined(separator: ", ") + "\n"
        }
        return str
    }
    
    public init(capacity: Int) {
        assert(capacity > 0)
        buckets = Array<Bucket>(repeatElement([], count: capacity))
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return getValue(forKey: key)
        }
        set {}
    }
    
    public func getValue(forKey key: Key) -> Value? {
        let index = self.index(forKey: key)
        for element in buckets[index] {
            if element.key == key {
                return element.value
            }
        }
        return nil
    }
    
    public mutating func setValue(_ value: Value, forKey key: Key) -> Value? {
        let semaphore = DispatchSemaphore(value: 0)
        defer { semaphore.signal() }
        
        let index = self.index(forKey: key)
        for (i, element) in buckets[index].enumerated() {
            if element.key == key {
                let oldValue = element.value
                buckets[index][i].value = value
                return oldValue
            }
            
        }
        buckets[index].append(Element(key: key, value: value))
        count += 1

        // Rehash
        if Float(count) / Float(buckets.count) > 0.75 {
            var rehashBuckets = Array<Bucket>(repeatElement([], count: buckets.count * 2)) // Twice current Element count.
            for bucket in buckets {
                guard let newHashValue = bucket.first?.key.hashValue else { continue }
                let index = abs(newHashValue) % rehashBuckets.count
                rehashBuckets[index] = bucket
            }
            buckets = rehashBuckets
        }
        return nil
    }
    
    public mutating func remove(forKey key: Key) -> Value? {
        let index = self.index(forKey: key)
        for (i, element) in buckets[index].enumerated() {
            if element.key == key {
                buckets[index].remove(at: i)
                count -= 1
                return element.value
            }
        }
        return nil
    }
    
    public mutating func removeAll() {
        buckets = Array<Bucket>(repeatElement([], count: 0))
        count = 0
    }
    
    private func index(forKey key: Key) -> Int {
        return abs(key.hashValue) % buckets.count
    }
}



/// Test

var table = Hashtable<String, Any>(capacity: 8)

table.setValue("aValue", forKey: "aKey")
table.setValue("bValue", forKey: "bKey")
table.setValue("cValue", forKey: "cKey")
table.setValue("dValue", forKey: "dKey")
table.setValue("dValue", forKey: "eKey")

table.setValue("fValue", forKey: "fKey")
table.setValue("hValue", forKey: "hKey")
table.setValue("iValue", forKey: "iKey")


debugPrint(table)






