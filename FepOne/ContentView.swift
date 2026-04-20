//
//  ContentView.swift
//  FepOne
//
//  Created by Michael Hayrapetyan on 24.01.26.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .padding(20)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            Image (systemName:"globe")
        }
    }
}

//func helovu() -> Text{
  //  return Text("Hellovu123")
//}


#Preview{
    ContentView()
}
