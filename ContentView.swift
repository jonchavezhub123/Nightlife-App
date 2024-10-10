//
//  ContentView.swift
//  Nightlife
//
//  Created by Jhon Chavez on 10/7/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedBar: Bar?
    @State private var isPopupPresented = false
    let visibleBars: [Bar]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(region: $locationManager.region, visiblebars: visibleBars, selectedBar: $selectedBar)
                .edgesIgnoringSafeArea(.all)
                .onChange(of: selectedBar) { newValue in
                    print("ContentView: selectedBar changed to \(newValue?.name ?? "nil")")
                    if newValue != nil {
                        // Always show the popup when a bar is selected
                        withAnimation(.spring(duration: 0.3)) {
                            isPopupPresented = true
                        }
                    }
                }
            
            if let bar = selectedBar {
                BarDetailPopup(bar: bar) {
                    withAnimation(.spring(duration: 0.3)) {
                        print("ContentView: Closing popup for \(bar.name)")
                        isPopupPresented = false
                        selectedBar = nil
                        print("ContentView: selectedBar set to nil")
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(isPopupPresented ? 1 : 0) // Ensure popup is above the map
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
}

