//
//  WordListArray.swift
//  WordList
//
//  Created by Todd Laney on 1/22/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//

import Foundation

struct WordListArray : WordList {
    var _array:Array<String> = []
    var _inUpdate = false

    func contains(_ word: String) -> Bool {
        assert(!_inUpdate)
        return _array.bsearch(word).found
    }
    
    mutating func beginUpdate() {
        assert(!_inUpdate)
        _inUpdate = true
    }
    mutating func endUpdate() {
        assert(_inUpdate)
        _inUpdate = false
        _array = _array.sorted()
    }
    mutating func add(_ word: String) {
        if (_inUpdate) {
            _array.append(word)
        }
        else {
            let (index, found) = _array.bsearch(word)
            if !found {
                _array.insert(word, at:index)
            }
        }
    }
}

private extension Array where Element: Comparable {
    
    func bsearch(_ element:Element) -> (index:Int, found:Bool) {
        var low = 0
        var high = self.count - 1
        var mid = Int(high / 2)
        
        while low <= high {
            
            let midElement = self[mid]
            
            if element == midElement {
                return (mid, true)
            }
            else if element < midElement {
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
