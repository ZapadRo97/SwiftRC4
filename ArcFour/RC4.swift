//
//  RC4.swift
//  ArcFour
//
//  Created by Florin Daniel on 02/05/2020.
//  Copyright © 2020 Florin Daniel. All rights reserved.
//

import Cocoa

//swift stuff for string manipulation
extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

class RC4: NSObject {
    
    var permutation : [UInt8]
    //var key : String
    var i = 0
    var j = 0
    
    init(key : String) {
        permutation = [UInt8]()
        //we need a key of 256 characters for permutation
        var keyArray = [UInt8]()
        for i in 0...255 {
            permutation.append(UInt8(i))
            //the key can have different length than 256
            keyArray.append((key[i % key.count]).asciiValue!)
        }
        
        //scramble the permutation to correspont to key
        var j = 0 //shadowing class declaration
        for i in 0...255 {
            j = (j + Int(permutation[i]) + Int(keyArray[i])) % 256
            permutation.swapAt(i, j)
        }
    }
    
    func nextNumber() -> UInt8 {
        
        i = (i + 1) % 256
        j = (j + Int(permutation[i])) % 256
        permutation.swapAt(i, j)
        let index = (Int(permutation[i]) + Int(permutation[j])) % 256
        let keyStreamNumber = permutation[index]
        
        return UInt8(keyStreamNumber)
    }
}
