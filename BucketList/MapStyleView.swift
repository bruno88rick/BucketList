//
//  MapStyleView.swift
//  BucketList
//
//  Created by Bruno Oliveira on 15/10/24.
//

import SwiftUI

struct MapStyleView: View {
    
    @Environment(\.dismiss) var dismiss
    
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
                        
                    } label: {
                        VStack {
                            Image(systemName: "map.fill")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                            Text("Standard")
                        }
                        .padding()
                    }
                    
                    Button {
                        
                    } label: {
                        VStack {
                            Image(systemName: "map.fill")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                            Text("Hybrid")
                        }
                        .padding()
                    }
                    
                    
                    Button {
                        
                    } label: {
                        VStack {
                            Image(systemName: "map.fill")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
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
                        Label("Exit", systemImage: "xmark")
                            .foregroundStyle(.black)
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
