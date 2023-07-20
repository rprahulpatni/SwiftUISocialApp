//
//  ReusablePostsView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 20/07/23.
//

import SwiftUI
import Firebase

struct ReusablePostsView: View {
    var basedOnUID: Bool = false
    var uid : String = ""
    @Binding var postData: [Post]
    @State private var isFetching: Bool = true
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                if isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if postData.isEmpty {
                        Text("No Post's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    } else {
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            guard !basedOnUID else {return}
            self.isFetching = true
            self.postData = []
            self.paginationDoc = nil
            await fetchingPost()
        }
        .task {
            guard postData.isEmpty else {return}
            await self.fetchingPost()
        }
    }
    
    @ViewBuilder
    func Posts()-> some View {
        ForEach(postData) { post in
            PostCardView(postData: post) { updatedPost in
                if let index = postData.firstIndex(where: { post in
                    post.id == updatedPost.id
                }) {
                    postData[index].postLikedIDS = updatedPost.postLikedIDS
                    postData[index].postDisLikedIDS = updatedPost.postDisLikedIDS
                }
            } onDelete: {
                withAnimation(.easeIn(duration: 0.25)) {
                    self.postData.removeAll {post.id == $0.id}
                }
            }
            .onAppear{
                if post.id == postData.last?.id && paginationDoc != nil {
                    Task{
                        await fetchingPost()
                    }
                }
            }
            Divider()
                .padding(.horizontal, -15)
        }
    }
    func fetchingPost() async {
        do {
            var query : Query!
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts").order(by: "postPublishedDate", descending: true).start(afterDocument: paginationDoc).limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts").order(by: "postPublishedDate", descending: true).limit(to: 20)
            }
            if basedOnUID {
                query = query.whereField("userUID", isEqualTo: uid)
            }
            let docs = try await query.getDocuments()
            let fetchedData = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                self.postData.append(contentsOf: fetchedData)
                self.paginationDoc = docs.documents.last
                self.isFetching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}

struct ReusablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ReusablePostsView(postData: .constant([]))
    }
}
