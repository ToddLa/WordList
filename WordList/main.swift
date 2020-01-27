//
//  main.swift
//  WordList
//
//  Created by Todd Laney on 1/13/20.
//  Copyright © 2020 Todd Laney. All rights reserved.
//

import Foundation

let testFile = ("~/Downloads/words.txt" as NSString).standardizingPath
//let testFile = ("~/Downloads/dictionary.txt" as NSString).standardizingPath
var testURL = URL(fileURLWithPath:testFile)

let argv = ProcessInfo.processInfo.arguments
let argc = argv.count

if argc > 1 {
    testURL = URL(fileURLWithPath:argv[1])
}

if !FileManager.default.fileExists(atPath: testURL.path) {
    print("CANT OPEN: \(testURL.path)")
    print("USAGE: \(URL(fileURLWithPath:argv[0]).lastPathComponent) [word list file]")
    exit(-1)
}


func malloc_info() -> malloc_statistics_t {
    var info = malloc_statistics_t()
    malloc_zone_statistics(malloc_default_zone(), &info)
    return info
}

func malloc_size_in_use() -> Int64 {
    return Int64(malloc_info().size_in_use)
}
func malloc_blocks_in_use() -> Int64 {
    return Int64(malloc_info().blocks_in_use)
}

func format(bytes:Int64) -> String {
    return ByteCountFormatter.string(fromByteCount:bytes, countStyle:.memory)
}
func format(time:TimeInterval, style:DateComponentsFormatter.UnitsStyle = .short, count:Int = 3) -> String {
    if time > 10.0 {
        let df = DateComponentsFormatter()
        df.unitsStyle = style
        df.maximumUnitCount = count
        df.allowedUnits = [.day, .hour, .minute, .second]
        return df.string(from:time) ?? ""
    }
    if time > 1.0 / 1_000.0 {
        return String(format:"%0.3f sec", time)
    }
    if time > 9.0 / 1_000_000.0 {
        return String(format:"%0.3f ms", time * 1_000.0)
    }
    if time > 1.0 / 1_000_000_000.0 {
        return String(format:"%0.3f μs", time * 1_000_000.0)
    }
    return String(format:"0.000 sec")
}
func format(number:Int, style:NumberFormatter.Style = .decimal) -> String {
    let nf = NumberFormatter()
    nf.numberStyle = style
    return nf.string(from: NSNumber(value:number)) ?? ""
}


func report_memory() {
    let mem = malloc_size_in_use()
    let blk = Int(malloc_blocks_in_use())
    print("Memory in use: \(format(bytes:mem)) \(format(number:blk)) blocks")
}

var foo:UInt8 = 0

func test<T>(_ name:String, _ count:Int = 1, block:()->T) -> (time:TimeInterval, memory:Int64, result:T) {
    var mem = malloc_size_in_use()
    var time = Date.timeIntervalSinceReferenceDate
    var result:T?
    for _ in 1...count {
        result = autoreleasepool {
            return block()
        }
    }
    time = Date.timeIntervalSinceReferenceDate - time
    mem = malloc_size_in_use() - mem

    // use the result, so does not get optimized away
    withUnsafeBytes(of: &result) {
        foo = $0.bindMemory(to:UInt8.self).baseAddress![0]
    }
    
    return (time / Double(count), mem, result!)
}

func test<T:WordList>(_ type:T.Type) {
    let words = (try! WordListArray(url:testURL))._array.shuffled()
    //let words = ["Wombat", "abc", "abcdef", "123", "😛😝😎", "Wombat-😛😝😎"]

    print("TESTING: \(type) \(format(number:words.count)) words")
    
    let load = test("Load") {() -> T in
        var list = type.init()
        try? list.load(testFile)
        return list
    }
    print("   Memory used: \(format(bytes:load.memory))")
    print("     Load Time: \(format(time:load.time))")
    
    var list = type.init()
    let add = test("Add") {
        list.beginUpdate()
        for word in words {
            list.add(word)
        }
        list.endUpdate()
    }
    print("      Add Time: \(format(time:add.time))")

    /*
    list = type.init()
    let sadd = test("(Slow)Add") {
        for word in words {
            list.add(word)
        }
    }
    print("(Slow)Add Time: \(format(time:sadd.time))")
    */

    /*
    let radd = test("(Re)Add") {
        for word in words {
            list.add(word)
        }
    }
    print("  (Re)Add Time: \(format(time:radd.time))")
    */
    
    var result = true
    let query = test("Query") {
        for word in words {
            result = result && list.contains(word)
        }
    }
    print("    Query Time: \(format(time:query.time / Double(words.count)))")
    print("        Result: \(result)")
    if (list is CustomStringConvertible) && words.count < 100 {
        print("\(list)")
    }
}


report_memory()
autoreleasepool {
    test(WordListNull.self)
    test(WordListSet.self)
    test(WordListDictionary.self)
    test(WordListArray.self)
    test(WordListArrayPacked.self)
    test(WordListTree.self)
    test(WordListTreeUnicodeScalar.self)
    test(WordListTreeUTF8.self)
    test(WordListTreeCString.self)
    test(WordListTreeCStringNoShare.self)
    test(WordListTreeClass.self)
    test(WordListTreeClassNoShare.self)
    test(WordListTreeData.self)
    test(WordListNull.self)
}
report_memory()


