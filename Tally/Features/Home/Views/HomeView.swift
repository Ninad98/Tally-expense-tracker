//
//  HomeView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello World System Font")
            
            Text("Hello World Custom from enum").font(
                .manrope(.bold, size: 18)
            )

        }
        .padding()
    }
}

#Preview {
    HomeView()
}
