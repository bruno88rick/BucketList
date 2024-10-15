//
//  ContentView.swift
//  BucketList
//
//  Created by Bruno Oliveira on 27/09/24.
//

///MVVM architecture - Views work best when they handle presentation of data, meaning that manipulation of data is a great candidate for code to move into a view model.

import MapKit
import SwiftUI

struct ContentView: View {
    
    // @State private var locations = [Location]() -> moved to ViewModel
    ///The way we’ve tackled sheets previously has meant creating a Boolean that determines whether the sheet is visible, then sending in some other data for the sheet to present or edit. This time, though, we’re going to take a different approach: we’re going to handle it all with one property. What we’re saying is that we might have a selected location, or we might not – and that’s all SwiftUI needs to know in order to present a sheet. As soon as we place a value into that optional we’re telling SwiftUI to show the sheet, and the value will automatically be set back to nil when the sheet is dismissed. Even better, SwiftUI automatically unwraps the optional for us, so when we’re creating the contents of our sheet we can be sure we have a real value to work with.
    //@State private var selectedPlace: Location? -> moved to ViewModel
    
    ///MVVM architecture
    @State private var viewModel = ViewModel()
    ///Tip: This is a good example of why placing view models inside extensions is helpful – we just say ViewModel and we automatically get the correct view model type for the current view. That will of course break a lot of code, but the fixes are easy – just add viewModel in various places. So, locations becomes $viewModel.locations, and selectedPlace becomes $viewModel.selectedPlace. Once you’ve added that everywhere your code will compile again, but you might wonder how this has helped – haven’t we just moved our code from one place to another? Well, yes, but there is an important distinction that will become clearer as your skills grow: having all this functionality in a separate class makes it much easier to write tests for your code.
    
    @State private var isAnimating = false
    
    @State private var showingMapStyleView = false
    
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack {
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .shadow(color: .gray, radius: 5, x: 5, y: 0)
                                    .onLongPressGesture() {
                                        print("I'm log pressing..")
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(MapStyle.standard)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            /*let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                             viewModel.locations.append(newLocation) -> Moved to ViewModel*/
                            viewModel.addLocation(at: coordinate)
                            
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        /*that passes the location into EditView, and also passes in a closure to run when the Save button is pressed. That accepts the new location, then looks up where the current location is and replaces it in the array. This will cause our map to update immediately with the new data.*/
                        EditView(location: place) { //newLocation in
                            
                            /*if let index = viewModel.locations.firstIndex(of: place) {
                             viewModel.locations[index] = newLocation -> Moved to ViewModel */
                            
                            viewModel.update(location: $0)
                            ///or
                            //viewModel.update(location: newLocation) -> so include newLocation in on closure EditView above
                        }
                    }
                    .sheet(isPresented: $showingMapStyleView) {
                        
                    }
                }
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isAnimating.toggle()
                                showingMapStyleView.toggle()
                            }
                        } label: {
                            Image(systemName: isAnimating ? "map.fill" : "map")
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .frame(width: 50, height: 50)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                        .padding()
                    }
                    Spacer()
                }
            }
        } else {
            Button ("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
    }
}

#Preview {
    ContentView()
}
