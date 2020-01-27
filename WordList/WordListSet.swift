//
//  WordListSet.swift
//  WordList
//
//  Created by Todd Laney on 1/13/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//
import Foundation

struct WordListSet : WordList {
     var _set:Set<String> = []

    func contains(_ word: String) -> Bool {
        return _set.contains(word)
    }
    
    mutating func add(_ word: String) {
        _set.insert(word)
    }
}
