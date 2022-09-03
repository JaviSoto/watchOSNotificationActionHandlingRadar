//
//  ContentView.swift
//  watchOSNotificationActionHandlingRadar Watch App
//
//  Created by Javier Soto on 9/3/22.
//

import SwiftUI

struct ContentView: View {
    @Binding
    var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
            Button("Push detail screen") {
                navigationPath.append(1)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(navigationPath: .constant(.init()))
    }
}
