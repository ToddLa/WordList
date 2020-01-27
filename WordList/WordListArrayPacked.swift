//
//  WordListArrayPacked.swift
//  WordList
//
//  Created by Todd Laney on 1/24/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//

import Foundation

struct WordListArrayPacked : WordList {
    var _array = [Int32]()
    var _data = [CChar]()
    var _inUpdate = false

    func contains(_ word: String) -> Bool {
        assert(!_inUpdate)
        return word.withCString {
             return self.bsearch($0).found
        }
    }
    mutating func beginUpdate() {
        assert(!_inUpdate)
        _inUpdate = true
    }
    mutating func endUpdate() {
        assert(_inUpdate)
        _inUpdate = false
        _data.withUnsafeBytes {buffer in
            let buffer = buffer.bindMemory(to: CChar.self).baseAddress!
            _array.sort { (lhs, rhs) -> Bool in
                return strcmp(buffer+Int(lhs),buffer+Int(rhs)) < 0
            }
        }
    }
    mutating func add(_ word: String) {
        if (_inUpdate) {
            _array.append(numericCast(_data.count))
            _data += Array(word.utf8CString)
        }
        else {
            let (index, found) = self.bsearch(word)
            if !found {
                _array.insert(numericCast(_data.count), at:index)
                _data += Array(word.utf8CString)
            }
        }
    }
    
    private func bsearch(_ word:UnsafePointer<CChar>) -> (index:Int, found:Bool) {
        
        _data.withUnsafeBytes {buffer in
            let buffer = buffer.bindMemory(to: CChar.self).baseAddress!

            var low = 0
            var high = _array.count - 1
            var mid = Int(high / 2)
            
            while low <= high {
                
                let str = buffer + Int(_array[mid])
                let cmp = strcmp(word, str)

                if cmp == 0 {
                    return (mid, true)
                }
                else if cmp < 0 {
                    high = mid - 1
                }
                else {
                    low = mid + 1
                }
                
                mid = (low + high) / 2
            }
            
            return (low, false)
        }
    }
}
