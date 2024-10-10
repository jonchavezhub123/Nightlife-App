//
//  NightlifeApp.swift
//  Nightlife
//
//  Created by Jhon Chavez on 10/7/24.
//

import SwiftUI


@main
struct NightlifeAppApp: App {
    @State var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            //ContentView(modelData: modelData)
            ContentView(visibleBars: modelData.bars)
           // ContentView()
        }
    }
}

