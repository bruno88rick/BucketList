//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Bruno Oliveira on 03/10/24.
//

///We’re going to use this to create a new class that manages our data, and manipulates it on behalf of the ContentView struct so that our view doesn’t really care how the underlying data system works.We’re going to start with two trivial things, then build our way up from there. First, create a new class that uses the Observable macro, so we’re able to report changes back to any SwiftUI view that’s watching:

import CoreLocation
import Foundation
import LocalAuthentication
import MapKit


///Now we’re saying this isn’t just any view model, it’s the view model for ContentView. I get lots of questions about why I place my view models into view extensions, so I'd like to take a moment to explain why. This is a small app, but think about how this would look when you have 10 views, or 50 views, or even 500 views. If you use extensions like this, the view model for your current view is always just called ViewModel, and not EditMapLocationViewModel or similar – it's much shorter, and avoids cluttering up your code with lots of different class names!
///Now that we have our class in place, we get to choose which pieces of state from our view should be moved into the view model. Some people will tell you to move all of it, others will be more selective, and that’s okay – again, there is no single definition of what MVVM looks like, so I’m going to provide you with the tools and knowledge to experiment yourself. Let’s start with the easy stuff: move both @State properties in ContentView over to its view model, removing the @State private parts because they aren't needed any more:

extension ContentView {
    
    @Observable
    class ViewModel {
        
        ///Reading data from a view model’s properties is usually fine, but writing it isn’t because the whole point of this exercise is to separate logic from layout. You can find these two places immediately if we clamp down on writing view model data – modify the locations property in your view model from var locations = [Location]() to this:
        private(set) var locations: [Location] ///No more  needs to be initialized to an empty array here (private(set) var locarions = [Location]()), because that’s handled by the initializer.
        ///Now we’ve said that reading locations is fine, but only the class itself can write locations. Immediately Xcode will point out the two places where we need to get code out of the view: adding a new location, and updating an existing one.
    
        var selectedPlace: Location?
        
        ///we can upgrade it to support loading and saving of data. This will look in the documents directory for a particular file, then use either JSONEncoder or JSONDecoder to convert it ready for use. Previously I showed you how to locate your app's documents directory and create filenames inside there, but I don’t want to do that when both loading and saving files because it means if we ever change our save location we need to remember to update both places. So, a better idea is to add a new property to our view model to store the location we’re saving to
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        ///to use biometrics unlock
        var isUnlocked = true
        
        ///challenge 1
       // private(set) var mapType: MapStyle = MapStyle.standard
        var isAnimating = false
        var showingMapStyleView = false
    
        ///we can start by adding a new method to the view model to handle adding a new location. First, add an import for CoreLocation to the top, then add this method to the class: That can then be used from the tap gesture in ContentView:
        func addLocation(at point: CLLocationCoordinate2D) {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: point.latitude, longitude: point.longitude)
            locations.append(newLocation)
            save()
        }
        
        ///function to update locations data
        func update(location: Location) {
            guard let selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
            
        }
        
        ///As for saving, previously I showed you how to write a string to disk, but the Data version is even better because it lets us do something quite amazing in just one line of code: we can ask iOS to ensure the file is written with encryption so that it can only be read once the user has unlocked their device. This is in addition to requesting atomic writes – iOS does almost all the work for us
        ///
        ///function to save locations on the savePath on documentsDirectory
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
                ///Yes, all it takes to ensure that the file is stored with strong encryption is to add .completeFileProtection to the data writing options.
            } catch {
                print("Unable to save data: \(error.localizedDescription).")
            }
        }
        ///Using this approach we can write any amount of data in any number of files – it’s much more flexible than UserDefaults, and also allows us to load and save data as needed rather than immediately when the app launches as with UserDefaults
        
        /*And now for the hard part. If you recall, the code for biometric authentication was a teensy bit unpleasant because of its Objective-C roots, so it’s always a good idea to get it far away from the neatness of SwiftUI. So, we’re going to write a dedicated authenticate() method that handles all the biometric work:
         
         - Creating an LAContext so we have something that can check and perform biometric authentication.
         - Ask it whether the current device is capable of biometric authentication.
         - If it is, start the request and provide a closure to run when it completes.
         - When the request finishes, check the result.
         - If it was successful, we’ll set isUnlocked to true so we can run our app as normal.*/
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                    if success {
                        self.isUnlocked = true
                    } else {
                        //error
                    }
                }
            } else {
                //no biometrics
            }
        }
        
        init() {
            ///trying to load savedPlaces from savePath on DocumentsDirectory
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        
    }
    
}
