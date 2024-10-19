//
//  MapStyleView.swift
//  BucketList
//
//  Created by Bruno Oliveira on 15/10/24.
//

import SwiftUI

struct MapStyleView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var mapType = UserDefaults.standard.string(forKey: "mapType")
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("Choose a Map Style")
                    .font(.bold(.title3)())
                    .foregroundStyle(.black)
                    .padding()
                Spacer()
            }
            
            VStack {
                HStack {
                    Button {
                        UserDefaults.standard.set("standard", forKey: "mapType")
                        dismiss()
                    } label: {
                        VStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 62, height: 46)
                                    .foregroundStyle(.yellow)
                                    .clipShape(.capsule)
                                    .opacity(0.9)
                                    .blur(radius: 5)
                                Image(.standardMap)
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 60, height: 44)
                                    .background(.white)
                                    .clipShape(.capsule)
                            }
                            Text("Standard")
                        }
                        .padding()
                    }
                    
                    Button {
                        UserDefaults.standard.set("hybrid", forKey: "mapType")
                        dismiss()
                    } label: {
                        VStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 62, height: 46)
                                    .foregroundStyle(.blue)
                                    .clipShape(.capsule)
                                    .opacity(0.9)
                                    .blur(radius: 5)
                                Image(.hybridMap)
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 60, height: 44)
                                    .background(.white)
                                    .clipShape(.capsule)
                            }
                            Text("Hybrid")
                        }
                        .padding()
                    }
                    
                    
                    Button {
                        UserDefaults.standard.set("sattelite", forKey: "mapType")
                        dismiss()
                    } label: {
                        VStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 62, height: 46)
                                    .foregroundStyle(.brown)
                                    .clipShape(.capsule)
                                    .opacity(0.9)
                                    .blur(radius: 10)
                                Image(.satteliteMap)
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 60, height: 44)
                                    .background(.white)
                                    .clipShape(.capsule)
                            }
                            Text("Satellite")
                        }
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                        
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 33, height: 33)
                            .background(.gray)
                            .opacity(0.4)
                            .clipShape(.circle)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MapStyleView()
}
