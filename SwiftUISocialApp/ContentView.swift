//
//  ContentView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("logStatus") var logStatus: Bool = false

    var body: some View {
        VStack {
            if logStatus == true {
                DashboardView()
            } else {
                LoginView()
            }
        }
        //.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
