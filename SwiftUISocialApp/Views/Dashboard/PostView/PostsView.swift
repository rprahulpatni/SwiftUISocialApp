//
//  PostsView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 20/07/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct PostsView: View {
    @State private var recentPostData: [Post] = []
    @State private var createNewPost: Bool = false
    var body: some View {
        NavigationStack {
            ReusablePostsView(postData: $recentPostData)
                .hAlign(.center)
                .vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button(action: {
                        createNewPost.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(.blue, in: Circle())
                    })
                    .padding(15)
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.blue)
                                .scaleEffect(0.9)
                        }
                    }
                }
                .navigationTitle("Post's")
        }
        .fullScreenCover(isPresented: $createNewPost, content: {
            CreateNewPost { post in
                self.recentPostData.insert(post, at: 0)
            }
        })
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
