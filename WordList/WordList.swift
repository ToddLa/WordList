//
//  WordList.swift
//  WordList
//
//  Created by Todd Laney on 1/13/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//

import Foundation
import Darwin           // FILE* fopen, fread, fclose

protocol WordList {
    init()
    func contains(_ word:String) -> Bool
    mutating func add(_ word:String)
    mutating func beginUpdate()
    mutating func endUpdate()
    mutating func load(_ path:String) throws
    mutating func load(_ url:URL) throws
}

extension WordList {
    init(url:URL) throws {
        self.init()
        try load(url)
    }
    mutating func beginUpdate() {
    }
    mutating func endUpdate() {
    }
    mutating func load(_ url:URL) throws {
        guard url.isFileURL else {throw CocoaError(.featureUnsupported)}
        try load(url.path)
    }
    mutating func load(_ path:String) throws {
        guard let file = fopen(path, "r") else {throw CocoaError(.fileNoSuchFile)}
        defer {fclose(file)}
        
        let MAX_LINE = 1024
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity:MAX_LINE)
        defer {buffer.deallocate()}
        
        self.beginUpdate()
        defer {self.endUpdate()}

        while (fgets(buffer, Int32(MAX_LINE), file) != nil) {
            try autoreleasepool {
                guard let line = String(cString:buffer, encoding:.utf8) else {throw CocoaError(.fileReadCorruptFile)}
                let word = line.trimmingCharacters(in:.whitespacesAndNewlines)
                self.add(word)
            }
        }
    }
}



