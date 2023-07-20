//
//  CreateNewPost.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 20/07/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct CreateNewPost: View {
    var callBackCreatePost: (Post)->()
    @State var postText: String = ""
    @State var postImgData: Data?
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = false
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @FocusState private var showKeyboard: Bool
    
    //UserDefaults
    @AppStorage("userUID") var userUID : String = ""
    @AppStorage("userProfilePic") var userProfilePic : String = ""
    @AppStorage("userProfileName") var userProfileName : String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.red)
                })
                Spacer()
                Button(action: {
                    self.createPost()
                }, label: {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal,15)
                        .padding(.vertical,10)
                        .background(.black, in: Capsule())
                })
                .disbableWithOpacity(self.postText == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField("What's happening?", text: $postText, axis: .vertical)
                        .focused($showKeyboard)
                    if let postImgData, let img = UIImage(data: postImgData) {
                        GeometryReader{
                            let size = $0.size
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(alignment: .topTrailing, content: {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            self.postImgData = nil
                                        }
                                    }, label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    })
                                    .padding(20)
                                })
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }.padding(15)
            }
            Divider()
            HStack{
                Button(action: {
                    self.showImagePicker.toggle()
                }, label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                })
                .hAlign(.leading)
                Button(action: {
                    self.showKeyboard = false
                }, label: {
                    Text("Done")
                })
                .hAlign(.trailing)
            }
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .vAlign(.top)
            .overlay(content: {
                LoadingView(showProgress: $isLoading)
            })
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem) { newValue in
                if let newValue {
                    Task {
                        do {
                            if let imgData = try await newValue.loadTransferable(type: Data.self), let img = UIImage(data: imgData), let compressedImgData = img.jpegData(compressionQuality: 0.5) {
                                await MainActor.run(body: {
                                    self.postImgData = compressedImgData
                                    self.photoItem = nil
                                })
                            }
                        } catch {
                            
                        }
                    }
                }
            }
            .alert(self.errorMsg, isPresented: $showError, actions: {})
    }
    
    func createPost() {
        self.isLoading = true
        showKeyboard = false
        Task{
            do{
                let imgReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imgReferenceID)
                if let postImgData {
                    let _ = try await storageRef.putDataAsync(postImgData)
                    let downloadURL = try await storageRef.downloadURL().absoluteString
                    let postData = Post(postText: self.postText, postImgURL: downloadURL, userProfileName: self.userProfileName, userProfilePic: self.userProfilePic, userUID: self.userUID)
                    try await createDocumentAtFirebase(postData)
                } else {
                    let postData = Post(postText: self.postText, postImgURL: "", userProfileName: self.userProfileName, userProfilePic: self.userProfilePic, userUID: self.userUID)
                    try await createDocumentAtFirebase(postData)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase(_ postData: Post) async throws {
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: postData, completion : { err in
            if err == nil {
                self.isLoading = false
                var updatedPost = postData
                updatedPost.id = doc.documentID
                self.callBackCreatePost(updatedPost)
                self.dismiss()
            }
        })
    }
    func setError(_ err: Error) async {
        await MainActor.run(body: {
            self.errorMsg = err.localizedDescription
            self.showError.toggle()
            self.isLoading = false
        })
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost{ _ in
            
        }
    }
}
