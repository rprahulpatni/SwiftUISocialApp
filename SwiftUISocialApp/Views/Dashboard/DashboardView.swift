//
//  DashboardView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView{
            PostsView()
                .tabItem({
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                })
            ProfileView()
                .tabItem({
                    Image(systemName: "gear")
                    Text("Profile")
                })
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
