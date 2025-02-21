//
//  ContentView.swift
//  MatchMate
//
//  Created by Mohammed.10824935 on 20/02/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MatchListView()
            .background(Color(UIColor.systemGroupedBackground)) // Adds a clean background
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
