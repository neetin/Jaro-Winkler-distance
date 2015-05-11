/*
* Licensed to the Apache Software Foundation (ASF) under one or more
* contributor license agreements.  See the NOTICE file distributed with
* this work for additional information regarding copyright ownership.
* The ASF licenses this file to You under the Apache License, Version 2.0
* (the "License"); you may not use this file except in compliance with
* the License.  You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/



// JaroWinklerDistance.playground
// Jaro–Winkler distance Algorithm Implementation on swift
// Algorithm: http://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance
// Reference: http://commons.apache.org/proper/commons-lang/apidocs/src-html/org/apache/commons/lang3/StringUtils.html
// Created by Neetin Sharma on 5/5/15.
//


import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

class JaroDistance {
    
    let INDEX_NOT_FOUND = -1
    let EMPTY = ""
    let SPACE = " "
    
    
    func getJaroWinklerDistance(#firstWord : String, secondWord : String) -> Float {
        
        let defaultScalingFactor : Float = 0.1
        
        let jaro = Float(self.score(firstString: firstWord, secondString: secondWord))
        let cp = Float(self.commonPrefixLength(first: firstWord, second: secondWord))
        
        let matchScore : Float = jaro + defaultScalingFactor * Float(cp) * Float(1 - jaro)
        return matchScore
    }
    
    
    /**
    * Calculates the number of characters from the beginning of the strings that match exactly one-to-one,
    * up to a maximum of four (4) characters.
    * returns A number between 0 to 4
    
    */
    
    func commonPrefixLength(#first : String, second: String) -> Int {
        let result = count(self.getCommonPrefix(first, second: second))
        
        // Limit the result to 4.
        return result > 4 ? 4 : result
    }
    
    func getCommonPrefix(first: String, second: String) -> String {
        
        if first == "" {
            return EMPTY
        }
        
        let smallestIndexOfDiff = self.indexOfDifference(first: first, second: second)
        
        if smallestIndexOfDiff == INDEX_NOT_FOUND {
            // ALL STRINGS WERE IDENTICAL
            if first == "" {
                return EMPTY
            }
            return first
        }
        else if smallestIndexOfDiff == 0 {
            // there were no common initial characters
            return EMPTY
        }
        else {
            // we found a common initial character sequence
            
            let str = first
            return str.substringWithRange(Range<String.Index>(start: str.startIndex, end: advance(str.startIndex, smallestIndexOfDiff)))
        }
    }
    
    
    func indexOfDifference(#first : String, second: String) -> Int {
        
        if first == second {
            return INDEX_NOT_FOUND
        }
        var i = 0
        while i < count(first) &&  i < count(second) {
            
            if String(Array(first)[i]) != String(Array(second)[i]) {
                break
            }
            i++
        }
        
        if i < count(first) || i < count(second) {
            return i
        }
        
        return INDEX_NOT_FOUND
    }
    
    func score(#firstString : String, secondString : String) -> Float {
        
        var shorter : String!
        var longer : String!
        
        // Determine which String is longer.
        if count(firstString) > count(secondString) {
            longer = firstString.lowercaseString
            shorter = secondString.lowercaseString
        }
        else {
            longer = secondString.lowercaseString
            shorter = firstString.lowercaseString
        }
        
        // Calculate the half length() distance of the shorter String.
        let halfLength = Int(count(shorter)) / 2 + 1
        
        // Find the set of matching characters between the shorter and longer strings. Note that
        // the set of matching characters may be different depending on the order of the strings.
        
        let m1 = self.getSetOfMatchingCharacterWithin(first: shorter, second: longer, limit: halfLength)
        
        let m2 = self.getSetOfMatchingCharacterWithin(first: longer, second: shorter, limit: halfLength)
        
        // If one or both of the sets of common characters is empty, then
        // there is no similarity between the two strings.
        
        if count(m1) == 0 || count(m2) == 0 {
            return 0.0
        }
        
        // If the set of common characters is not the same size, then
        // there is no similarity between the two strings, either.
        
        if count(m1) != count(m2) {
            return 0.0
        }
        
        // Calculate the number of transposition between the two sets
        // of common characters.
        
        let transpositions = self.transpositions(m1 :m1, m2: m2)
        
        // Calculate the distance.
        
        let c1 = Float(count(m1)) / Float(count(shorter))
        let c2 = Float(count(m2)) / Float(count(longer))
        let c3 = Float((count(m1) - transpositions)) / Float(count(m1))
        
        let dist = (c1 + c2 + c3) / 3
        
        return dist
    }
    
    
    func getSetOfMatchingCharacterWithin(#first : String, second : String, limit : Int ) -> String {
        
        var common = ""
        var copy = second.copy() as! String
        
        for i in 0 ..< count(first) {
            let ch = String(Array(first)[i])
            
            // See if the character is within the limit positions away from the original position of that character.
            let jStart = max(0, i - limit)
            let jEnd = min(i + limit, count(second))
            
            if jStart < jEnd {
                for j in jStart ..< jEnd {
                    if String(Array(copy)[j]) == ch {
                        common = common + ch
                        let nsRange : NSRange = NSRange(location: j, length: 1)
                        let copy = (copy as NSString).stringByReplacingCharactersInRange(nsRange, withString: "*")
                        break
                    }
                }
            }
        }
        
        return common
    }
    
    
    func transpositions(#m1 : String, m2 : String) -> Int {
        
        var transpositions = 0
        
        for i in 0 ..< count(m1) {
            if String(Array(m1)[i]) != String(Array(m2)[i]) {
                transpositions++
            }
        }
        
        return transpositions/2
    }
    
}


let jaro = JaroDistance()
let d = jaro.getJaroWinklerDistance(firstWord: "martha", secondWord: "marhta")
println("distance : \(d)")   // distance: 0.9611

let d1 = jaro.getJaroWinklerDistance(firstWord: "Hello", secondWord: "hey")
println("distance : \(d1)") // distance: 0.688


