//
//  WordListTree.swift
//  WordList
//
//  Created by Todd Laney on 1/24/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//

import Foundation

struct WordListTree : WordList {
    
    static let leaf = WordListTree(_children:[:])

    var _children = [Character:WordListTree]()

    func contains(_ word: String) -> Bool {
        return self.contains(word[...])
    }
    mutating func add(_ word: String) {
        return self.add(word[...])
    }

    private func contains<S:StringProtocol>(_ word:S) -> Bool {
        if let first = word.first {
            if let child = _children[first] {
                return child.contains(word.dropFirst())
            }
            else {
                return false
            }
        }
        return _children[Character(UnicodeScalar(0))] != nil
    }
    private mutating func add<S:StringProtocol>(_ word: S) {
        if let first = word.first {
            _children[first, default:WordListTree()].add(word.dropFirst())
        }
        else {
            _children[Character(UnicodeScalar(0))] = WordListTree.leaf
        }
    }
}

struct WordListTreeUnicodeScalar : WordList {
    static let empty = Self()
    static let leaf = Self(_children: [UnicodeScalar(0):Self.empty])

    var _children = [UnicodeScalar:Self]()

    func contains(_ word: String) -> Bool {
        return self.contains(word[...].unicodeScalars)
    }
    mutating func add(_ word: String) {
        return self.add(word[...].unicodeScalars)
    }

    private func contains(_ word:Substring.UnicodeScalarView) -> Bool {
        if let first = word.first {
            return _children[first]?.contains(word.dropFirst()) ?? false
        }
        return _children[UnicodeScalar(0)] != nil
    }
    private mutating func add(_ word:Substring.UnicodeScalarView) {
        if let first = word.first {
            var child = _children[first]
            if child != nil {
                _children[first] = nil
                child!.add(word.dropFirst())
            }
            else if word.count == 1 {
                child = Self.leaf
            }
            else {
                child = Self()
                child!.add(word.dropFirst())
            }
            _children[first] = child
        }
        else {
            _children[UnicodeScalar(0)] = Self.empty
        }
    }
}

struct WordListTreeUTF8 : WordList {
    static let empty = Self()
    static let leaf = Self(_children: [UInt8(0):Self.empty])

    var _children = [UInt8:Self]()

    func contains(_ word: String) -> Bool {
        return self.contains(word[...].utf8)
    }
    mutating func add(_ word: String) {
        return self.add(word[...].utf8)
    }

    private func contains(_ word:Substring.UTF8View) -> Bool {
        if let first = word.first {
            return _children[first]?.contains(word.dropFirst()) ?? false
        }
        return _children[UInt8(0)] != nil
    }
    private mutating func add(_ word:Substring.UTF8View) {
        if let first = word.first {
            var child = _children[first]
            if child != nil {
                _children[first] = nil  // prevent CoW
                child!.add(word.dropFirst())
            }
            else if word.count == 1 {
                child = Self.leaf
            }
            else {
                child = Self()
                child!.add(word.dropFirst())
            }
            _children[first] = child
        }
        else {
            _children[UInt8(0)] = Self.empty
        }
    }
}

struct WordListTreeCString : WordList {
    static let empty = Self()
    static let leaf = Self(_children: [CChar(0):Self.empty])

    var _children = [CChar:Self]()

    func contains(_ word: String) -> Bool {
        return word.withCString {
            return self.contains($0)
        }
    }
    mutating func add(_ word: String) {
        word.withCString {
            self.add($0)
        }
    }

    private func contains(_ word:UnsafePointer<CChar>) -> Bool {
        if word.pointee != 0 {
            return _children[word.pointee]?.contains(word+1) ?? false
        }
        return _children[CChar(0)] != nil
    }
    private mutating func add(_ word:UnsafePointer<CChar>) {
        let first = word.pointee
        if first != 0 {
            var child = _children[first]
            if child != nil {
                _children[first] = nil  // prevent CoW
                child!.add(word+1)
            }
            else if (word+1).pointee == 0 {
                child = Self.leaf
            }
            else {
                child = Self()
                child!.add(word+1)
            }
            _children[first] = child
        }
        else {
            _children[CChar(0)] = Self.empty
        }
    }
}

struct WordListTreeCStringNoShare : WordList {
    
    var _children = [CChar:Self]()

    func contains(_ word: String) -> Bool {
        return word.withCString {
            return self.contains($0)
        }
    }
    mutating func add(_ word: String) {
        word.withCString {
            self.add($0)
        }
    }

    private func contains(_ word:UnsafePointer<CChar>) -> Bool {
        if word.pointee != 0 {
            return _children[word.pointee]?.contains(word+1) ?? false
        }
        return _children[CChar(0)] != nil
    }
    private mutating func add(_ word:UnsafePointer<CChar>) {
        let first = word.pointee
        if first != 0 {
            var child = _children[first]
            if child != nil {
                _children[first] = nil  // prevent CoW
                child!.add(word+1)
            }
            else {
                child = Self()
                child!.add(word+1)
            }
            _children[first] = child
        }
        else {
            _children[CChar(0)] = Self()
        }
    }
}

class WordListTreeClass : WordList {
    static let empty = WordListTreeClass()
    static let leaf = WordListTreeClass(_children: [CChar(0):WordListTreeClass.empty])
    
    var _children:[CChar:WordListTreeClass]
    
    required init() {
        self._children = [:]
    }
    required init(_children:[CChar:WordListTreeClass]) {
        self._children = _children
    }

    func contains(_ word: String) -> Bool {
        return word.withCString {
            return self.contains($0)
        }
    }
    func add(_ word: String) {
        word.withCString {
            self.add($0)
        }
    }

    private func contains(_ word:UnsafePointer<CChar>) -> Bool {
        if word.pointee != 0 {
            return _children[word.pointee]?.contains(word+1) ?? false
        }
        return _children[CChar(0)] != nil
    }
    private func add(_ word:UnsafePointer<CChar>) {
        let first = word.pointee
        if first != 0 {
            var child = _children[first]
            if child != nil {
                _children[first] = nil  // prevent CoW
                if child === Self.empty {
                    child = Self()
                }
                if child === Self.leaf {
                    child = Self(_children:[CChar(0):Self.empty])
                }
                child!.add(word+1)
            }
            else if (word+1).pointee == 0 {
                child = Self.leaf
            }
            else {
                child = Self()
                child!.add(word+1)
            }
            _children[first] = child
        }
        else {
            _children[CChar(0)] = Self.empty
        }
    }
}

class WordListTreeClassNoShare : WordList {
    
    var _children:[CChar:WordListTreeClassNoShare]
    
    required init() {
        self._children = [:]
    }
    required init(_children:[CChar:WordListTreeClassNoShare]) {
        self._children = _children
    }

    func contains(_ word: String) -> Bool {
        return word.withCString {
            return self.contains($0)
        }
    }
    func add(_ word: String) {
        word.withCString {
            self.add($0)
        }
    }

    private func contains(_ word:UnsafePointer<CChar>) -> Bool {
        if word.pointee != 0 {
            return _children[word.pointee]?.contains(word+1) ?? false
        }
        return _children[CChar(0)] != nil
    }
    private func add(_ word:UnsafePointer<CChar>) {
        let first = word.pointee
        if first != 0 {
            var child = _children[first]
            if child != nil {
                _children[first] = nil  // prevent CoW
                child!.add(word+1)
            }
            else {
                child = Self()
                child!.add(word+1)
            }
            _children[first] = child
        }
        else {
            _children[CChar(0)] = Self()
        }
    }
}

class WordListTreeData : WordList {
    
    var _data:[UInt32]? = nil
    var _tree:WordListTreeClass? = nil
    
    required init() {
    }
    
    func beginUpdate() {
        assert(_tree == nil)
        _tree = WordListTreeClass()
    }
    func endUpdate() {
        assert(_tree != nil)
        _data = tree_data(_tree!)
        _tree = nil
    }
    
    func contains(_ word: String) -> Bool {
        guard let data = _data else {return false}
        return word.withCString {
            return contains(data, $0)
        }
    }
    func add(_ word: String) {
        assert(_tree != nil)
        _tree?.add(word)
    }

    //
    // the packed Data format is an array of UInt32
    // offsets are relative to the start of the current tree
    // offsets are sorted by the character values.
    //      8bits for character, 1bit for EOL, 23bits for offset (32MB total size)
    //
    // +----+-+--------------------+
    // |char|0|   offset to child 1|
    // +----+-+--------------------+
    // |char|0|   offset to child 2|
    // +----+-+--------------------+
    //          ......
    // +----+-+--------------------+
    // |char|1|   offset to child N|
    // +---------------------------+
    // |     data for child 1      |
    // +---------------------------+
    // |     data for child 2      |
    // +---------------------------+
    //          ......
    // +---------------------------+
    // |     data for child N      |
    // +---------------------------+
    //
    // special values
    // +----+-+--------------------+
    // |char|x|  0x000000          |  - leaf/empty node
    // +----+-+--------------------+

    private func tree_data(_ tree:WordListTreeClass) -> [UInt32] {
        if tree._children.count == 0 {
            return []
        }
        let keys = tree._children.keys.sorted()
        var data = [UInt32](repeating:0, count:keys.count)
        
        for (i,key) in keys.enumerated() {
            let child = tree._children[key]!
            var offset:Int
            if child._children.count == 0 || (child._children.count == 1 && child._children[0] != nil) {
                offset = 0
            }
            else {
                offset = data.count
                data += tree_data(child)
            }
            let char = UInt8(bitPattern:key)
            let eol = (i == keys.count-1) ? 1 : 0
            assert(offset <= 0x7FFFFF)
            data[i] = (UInt32(char) << 24) | (UInt32(eol) << 23) | UInt32(offset)
        }
        return data
    }

    private func contains(_ data:[UInt32], _ word:UnsafePointer<CChar>) -> Bool {
        if data.count == 0 {return false}
        
        let charShift  = 24
        let charMask   = UInt32(0xFF000000)
        let eolMask    = UInt32(0x00800000)
        let offsetMask = UInt32(0x007FFFFF)

        var word = word
        var base = 0
        var dw:UInt32 = 0
        
        while word.pointee != 0 {
            // find the child tree for this character
            for i in 0... {
                dw = data[base+i]
                if (dw >> charShift) == UInt8(bitPattern:word.pointee) {
                    break
                }
                if (dw & eolMask) != 0 {
                    return false
                }
            }
            let offset = (dw & offsetMask)
            if offset == 0 {
                return (word+1).pointee == 0
            }
            base = base + Int(offset)
            word += 1
        }
        
        return (data[base+0] & charMask) == 0
    }
}

private extension Dictionary {
    func jsonString() -> String {
        let data = (try? JSONSerialization.data(withJSONObject:self, options:.prettyPrinted)) ?? Data()
        return String(data:data, encoding:.utf8)!
    }
}

