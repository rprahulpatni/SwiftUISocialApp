//
//  ProfileView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    @AppStorage("logStatus") var logStatus: Bool = false
    
    @State private var myProfile: UserData?
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = false

    var body: some View {
        NavigationStack{
            VStack {
                if myProfile != nil {
                    ReusableProfileView(myProfile: self.myProfile)
                        .refreshable {
                            self.myProfile = nil
                            await fetchUserDetails()
                        }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Button("Logout", action: {logoutUser()})
                        Button("Delete Account", role: .destructive, action: {deleteAccount()})
                    }, label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    })
                }
            }
        }
        .overlay(content: {
            LoadingView(showProgress: $isLoading)
        })
        .alert(errorMsg, isPresented: $showError, actions: {})
        .task {
            if myProfile != nil {
                return
            }
            await fetchUserDetails()
        }
    }
    
    func fetchUserDetails() async {
        do {
            guard let userUID = Auth.auth().currentUser?.uid else {return}
            let userData = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: UserData.self)
            await MainActor.run(body: {
//                self.userUID = userUID
//                self.userProfileName = userData.userName
//                self.userProfilePic = userData.userProfilePic
//                self.logStatus = true
                self.myProfile = userData
            })
        } catch {
            await setError(error)
        }
    }
    
    func logoutUser() {
        try? Auth.auth().signOut()
        self.logStatus = false
    }
    
    func deleteAccount() {
        self.isLoading = true
        Task{
            do {
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                let ref = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await ref.delete()
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                try await Auth.auth().currentUser?.delete()
                self.logStatus = false
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ err: Error) async {
        await MainActor.run(body: {
            self.errorMsg = err.localizedDescription
            self.showError.toggle()
            self.isLoading = false
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
