//
//  Location.swift
//  BucketList
//
//  Created by Bruno Oliveira on 27/09/24.
//

import Foundation
import MapKit

struct Location: Codable, Equatable, Identifiable {
    
    ///Go ahead and give the app a try – see if you spot a problem with our code. Hopefully it’s rather glaring: renaming doesn’t actually work! The problem here is that we told SwiftUI that two places were identical if their IDs were identical, and that isn’t true any more – when we update a marker so it has a different name, SwiftUI will compare the old marker and new one, see that their IDs are the same, and therefore not bother to change the map. The fix here is to make the id property mutable, like this:
    var id: UUID
    var name: String
    var description: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
    }
    
#if DEBUG
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "Lit by over 100,000 candles, Buckingham Palace is a historic palace in London, England. It is one of the Seven Wonders of the World and is often referred to as the 'White House of Europe'.", latitude: 51.501, longitude: -0.141)
#endif
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
}
