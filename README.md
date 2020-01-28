#  WordList

project to test different versions of code to handle large word lists (like a dictionary) with a fast lookup.

## Baseline
results are compared to just a plain Swift standard libaray Set and Dictionary.  

```
TESTING: WordListSet 466,551 words
   Memory used: 21.8 MB
     Load Time: 0.943 sec
    Query Time: 0.284 μs
TESTING: WordListDictionary 466,551 words
   Memory used: 22.8 MB
     Load Time: 0.864 sec
    Query Time: 0.314 μs
```

## Array using binary search
just a plain Swift array of strings sorted and searched with bsearch.  and a packed version where all strings are stored in a single data buffer.

```
TESTING: WordListArray 466,551 words
   Memory used: 21.8 MB
     Load Time: 0.738 sec
    Query Time: 1.615 μs
TESTING: WordListArrayPacked 466,551 words
   Memory used: 9 MB
     Load Time: 0.769 sec
    Query Time: 0.946 μs
```

## N-ary tree
tested two versions of a n-ary tree, where each node is a struct or a class.
and did a Share and NoShare version.  in the Share version the leaf/empty nodes are optimized to share a singleton.

```
TESTING: WordListTreeCString 466,551 words
   Memory used: 102.4 MB
     Load Time: 1.436 sec
    Query Time: 1.335 μs
TESTING: WordListTreeCStringNoShare 466,551 words
   Memory used: 136.3 MB
     Load Time: 1.562 sec
    Query Time: 1.356 μs
TESTING: WordListTreeClass 466,551 words
   Memory used: 134.4 MB
     Load Time: 1.779 sec
    Query Time: 1.937 μs
TESTING: WordListTreeClassNoShare 466,551 words
   Memory used: 193.9 MB
     Load Time: 1.887 sec
    Query Time: 2.044 μs
```

## Packed Data Tree

the packed Data format is an array of UInt32, offsets are relative to the start of the current tree. offsets are sorted by the character values. 8bits for character, 1bit for EOL, 23bits for offset

```
+----+-+--------------------+
|char|0|   offset to child 1|
+----+-+--------------------+
|char|0|   offset to child 2|
+----+-+--------------------+
         ......
+----+-+--------------------+
|char|1|   offset to child N|
+---------------------------+
|     data for child 1      |
+---------------------------+
|     data for child 2      |
+---------------------------+
         ......
+---------------------------+
|     data for child N      |
+---------------------------+

special values
+----+-+--------------------+
|char|x|  0x000000          |  - leaf/empty node
+----+-+--------------------+
```

```
TESTING: WordListTreeData 466,551 words
    Memory used: 6 MB
    Load Time: 3.215 sec
    Query Time: 0.490 μs
```

## Summary
The PackedArray and PackedTree use the least memory (9MB and 6MB) but are 2-3x slower look up than the system Set/Dictionary! 


## All Results
```
Memory in use: 1.2 MB 16,482 blocks
TESTING: WordListNull 466,551 words
   Memory used: -4 KB
     Load Time: 0.625 sec
      Add Time: 2.027 μs
    Query Time: 0.000 sec
        Result: false
TESTING: WordListSet 466,551 words
   Memory used: 21.8 MB
     Load Time: 0.943 sec
      Add Time: 0.271 sec
    Query Time: 0.284 μs
        Result: true
TESTING: WordListDictionary 466,551 words
   Memory used: 22.8 MB
     Load Time: 0.864 sec
      Add Time: 0.258 sec
    Query Time: 0.314 μs
        Result: true
TESTING: WordListArray 466,551 words
   Memory used: 21.8 MB
     Load Time: 0.738 sec
      Add Time: 0.476 sec
    Query Time: 1.615 μs
        Result: true
TESTING: WordListArrayPacked 466,551 words
   Memory used: 9 MB
     Load Time: 0.769 sec
      Add Time: 0.284 sec
    Query Time: 0.946 μs
        Result: true
TESTING: WordListTree 466,551 words
   Memory used: 191.6 MB
     Load Time: 2.069 sec
      Add Time: 1.779 sec
    Query Time: 2.875 μs
        Result: true
TESTING: WordListTreeUnicodeScalar 466,551 words
   Memory used: 107 MB
     Load Time: 1.812 sec
      Add Time: 1.535 sec
    Query Time: 1.792 μs
        Result: true
TESTING: WordListTreeUTF8 466,551 words
   Memory used: 102.4 MB
     Load Time: 1.595 sec
      Add Time: 1.352 sec
    Query Time: 1.678 μs
        Result: true
TESTING: WordListTreeCString 466,551 words
   Memory used: 102.4 MB
     Load Time: 1.436 sec
      Add Time: 1.255 sec
    Query Time: 1.335 μs
        Result: true
TESTING: WordListTreeCStringNoShare 466,551 words
   Memory used: 136.3 MB
     Load Time: 1.562 sec
      Add Time: 1.350 sec
    Query Time: 1.356 μs
        Result: true
TESTING: WordListTreeClass 466,551 words
   Memory used: 134.4 MB
     Load Time: 1.779 sec
      Add Time: 1.685 sec
    Query Time: 1.937 μs
        Result: true
TESTING: WordListTreeClassNoShare 466,551 words
   Memory used: 193.9 MB
     Load Time: 1.887 sec
      Add Time: 1.923 sec
    Query Time: 2.044 μs
        Result: true
TESTING: WordListTreeData 466,551 words
   Memory used: 6 MB
     Load Time: 3.215 sec
      Add Time: 3.704 sec
    Query Time: 0.490 μs
        Result: true
TESTING: WordListNull 466,551 words
   Memory used: 992 bytes
     Load Time: 0.542 sec
      Add Time: 0.000 sec
    Query Time: 0.000 sec
        Result: false
Memory in use: 1.4 MB 31,774 blocks
```
