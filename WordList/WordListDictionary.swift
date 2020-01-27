//
//  WordListDictionary.swift
//  WordList
//
//  Created by Todd Laney on 1/23/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//

import Foundation

struct WordListDictionary : WordList {
    var _storage = [String:Void]()

    func contains(_ word: String) -> Bool {
        return _storage[word] != nil
    }
    
    mutating func add(_ word: String) {
        _storage[word] = ()
    }
}

