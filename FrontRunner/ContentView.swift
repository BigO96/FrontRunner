//
//  ContentView.swift
//  FrontRunner
//
//  Created by Oscar Epp on 4/21/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            
            RunningView()
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }
            
            RunsView()
                .tabItem {
                    Label("Run", systemImage: "figure.run")
                    
                }
            
            Text("Leaderboard")
                .tabItem {
                    Label("Leaderboard", systemImage: "crown.fill")
                }
            
    
            
        }
    }
}

#Preview {
    ContentView()
}
