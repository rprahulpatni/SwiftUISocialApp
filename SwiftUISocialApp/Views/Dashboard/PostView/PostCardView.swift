//
//  PostCardView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 20/07/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseStorage

struct PostCardView: View {
    var postData: Post
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    @AppStorage("userUID") private var userUID : String = ""
    @State private var docListner: ListenerRegistration?
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            WebImage(url: URL(string: postData.userProfilePic))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(postData.userProfileName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(postData.postPublishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(postData.postText)
                    .textSelection(.enabled)
                    .padding(.vertical, 10)
                
                if let postImgURL = postData.postImgURL, postImgURL != "" {
                    GeometryReader{
                        let size = $0.size
                            WebImage(url: URL(string: postImgURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                PostInteraction()
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing) {
            if postData.userUID == userUID {
                Button(action: {
                    self.deletePost()
                }, label: {
                    Image(systemName: "trash")
                        .fontWeight(.bold)
                        .tint(.red)
                })
            }
        }
        .onAppear{
            if docListner == nil {
                guard let postID = postData.id else {return}
                docListner = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, err in
                    if let snapshot {
                        if snapshot.exists {
                            if let updatedPost = try? snapshot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                        } else {
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear{
            if docListner != nil {
                docListner?.remove()
                docListner = nil
            }
        }
    }
    
    @ViewBuilder
    func PostInteraction()-> some View {
        HStack(spacing: 5) {
            Button(action: {
                self.likePost()
            }, label: {
                Image(systemName: postData.postLikedIDS.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            })
            Text("\(postData.postLikedIDS.count)")
                .font(.caption)
                .foregroundColor(.gray)
            Button(action: {
                self.dislikePost()
            }, label: {
                Image(systemName: postData.postDisLikedIDS.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            })
            .padding(.leading, 25)
            Text("\(postData.postDisLikedIDS.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(.vertical, 10)
    }
    
    func likePost() {
        Task{
            guard let postId = postData.id else {return}
            if postData.postLikedIDS.contains(userUID) {
                try await Firestore.firestore().collection("Posts").document(postId).updateData([
                    "postLikedIDS" : FieldValue.arrayRemove([userUID])
                ])
            } else {
                try await Firestore.firestore().collection("Posts").document(postId).updateData([
                    "postLikedIDS" : FieldValue.arrayUnion([userUID]),
                    "postDisLikedIDS" : FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    func dislikePost() {
        Task{
            guard let postId = postData.id else {return}
            if postData.postDisLikedIDS.contains(userUID) {
                try await Firestore.firestore().collection("Posts").document(postId).updateData([
                    "postDisLikedIDS" : FieldValue.arrayRemove([userUID])
                ])
            } else {
                try await Firestore.firestore().collection("Posts").document(postId).updateData([
                    "postLikedIDS" : FieldValue.arrayRemove([userUID]),
                    "postDisLikedIDS" : FieldValue.arrayUnion([userUID])
                ])
            }
        }
    }
    
    func deletePost() {
        Task {
            do {
                if postData.postImgReferenceID != "" {
                    try await Storage.storage().reference().child("Post_Images").child(postData.postImgReferenceID).delete()
                }
                guard let postId = postData.id else {return}
                try await Firestore.firestore().collection("Posts").document(postId).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
