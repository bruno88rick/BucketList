//
//  Result.swift
//  BucketList
//
//  Created by Bruno Oliveira on 01/10/24.
//

import Foundation

struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    
    ///Before we’re done with this screen, we need to replace the Text("Page description here") view with something real. Wikipedia’s JSON data does contain a description, but it’s buried: the terms dictionary might not be there, and if it is there it might not have a description key, and if it has a description key it might be an empty array rather than an array with some text inside. We don’t want this mess to plague our SwiftUI code, so again the best thing to do is make a computed property that returns the description if it exists, or a fixed string otherwise. Add this to the Page struct to finish it off:
    ///
    
    var description: String {
        terms?["description"]?.first ?? "No description available"
    }
    
    static func < (lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
    
}
