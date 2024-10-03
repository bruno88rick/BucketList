//
//  EditView.swift
//  BucketList
//
//  Created by Bruno Oliveira on 28/09/24.
//

import SwiftUI

struct EditView: View {
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) var dismiss
    
    var location: Location
    
    ///when we’re done editing the location, how can we pass the new location data back? We could use something like @Binding to pass in a remote value, but that creates problems with our optional in ContentView – we want EditView to be bound to a real value rather than an optional value, because otherwise it would get confusing. We’re going to take simplest solution we can: we’ll require a function to call where we can pass back whatever new location we want. This means any other SwiftUI can send us some data, and get back some new data to process however we want.
    ///That asks for a function that accepts a single location and returns nothing, which is perfect for our usage.
    
    var onSave: (Location) -> Void
    
    @State private var name: String
    @State private var description: String
    
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $name)
                    TextEditor(text: $description)
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                }
                
                Section("Nearby...") {
                    
                    switch loadingState {
                
                    case .loading:
                        Text("Loading...")
                        ProgressView()
                        
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                        
                    case .failed:
                        Text("Please try again later.")
                    }
                    
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                ///Speaking of which, we need to update that Save button to create a new location with the modified details, and send it back with onSave():
                Button("Save") {
                    var newLocation = location
                    ///And now we can adjust that UUID on the "newLocation" to change the UUDI to other value when we create/update the value for the ˜new locations˜:
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    
                    onSave(newLocation)
                    dismiss()
                    ///So, that passes the location into EditView, and also passes in a closure to run when the Save button is pressed. That accepts the new location, then looks up where the current location is and replaces it in the array. This will cause our map to update immediately with the new data.
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            loadingState = .failed
            return
        }
        
        print(url)
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            //we got some data back!
            let items = try JSONDecoder().decode(Result.self, from: data)
            
            //success - convert the array values to our pages array
            
            //pages = items.query.pages.values.sorted { $0.title < $1.title}
            ///Wikipedia’s results come back to us in an order that probably seems random, but it’s actually sorted according to their internal page ID. That doesn’t help us though, which is why we’re sorting results using a custom closure like above. There are lots of times when using a custom sorting function is exactly what you need, but more often than not there is one natural order to your data – maybe showing news stories newest first, or contacts last name first, etc. So, rather than just provide an inline closure to sorted() we are instead going to make our Page struct conform to Comparable. This is actually pretty easy to do, because we already have the sorting code written – it’s just a matter of moving it across to our Page struct. So instead, making Page Struct comparable, now that Swift understands how to sort pages, it will automatically gives us a parameter-less sorted() method on page arrays. This means when we set self.pages in fetchNearbyPlaces() we can now add sorted() to the end, like this:
            
            pages = items.query.pages.values.sorted()
            
            loadingState = .loaded
            
        } catch {
            //if we're still here it means the request failed somehow
            loadingState = .failed
        }
    }
    
    /*what initial values should we use for the name and description properties? Previously we’ve used @State with initial values, but we can’t do that here – their initial values should come from what location is being passed in, so the user sees the saved data.
     
     The solution is to create a new initializer that accepts a location, and uses that to create State structs using the location’s data. This uses the same underscore approach we used when creating a SwiftData query inside an initializer, which allows us to create an instance of the property wrapper not the data inside the wrapper.

     So, to solve our problem we need to add this initializer to EditView:*/
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    ///That @escaping part is important, and means the function is being stashed away for user later on, rather than being called immediately, and it’s needed here because the onSave function will get called only when the user presses Save.
    
}

#Preview {
    ///Don’t forget to update your preview code too – just passing in a placeholder closure is fine here: { _ in }
    EditView(location: .example) { _ in }
}
