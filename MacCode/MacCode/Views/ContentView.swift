//
//  ContentView.swift
//  MacYoudobe
//
//  Created by Yurii Samoienko on 28.04.2022.
//

import SwiftUI

public struct ContentView: View {
    
    // MARK: Public Properties
    
    public var body: some View {
        Text("Hello, world!")
            .padding()
            .foregroundColor(.pink)
    }
    
    // MARK: Public Functions
    
    public init() {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
