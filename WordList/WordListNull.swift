//
//  WordListNull.swift
//  WordList
//
//  Created by Todd Laney on 1/13/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//
import Foundation

struct WordListNull : WordList {
    func contains(_ word: String) -> Bool {
        return false
    }
    func add(_ word: String) {
    }
}
