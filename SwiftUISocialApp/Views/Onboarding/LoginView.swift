//
//  LoginView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct LoginView: View {
    
    @State var emailId: String = ""
    @State var password: String = ""
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = false
    //UserDefaults
    @AppStorage("logStatus") var logStatus : Bool = false
    @AppStorage("userUID") var userUID : String = ""
    @AppStorage("userProfilePic") var userProfilePic : String = ""
    @AppStorage("userProfileName") var userProfileName : String = ""
    
    var body: some View {
        VStack(spacing: 10){
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            Text("Welcome Back,\nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            VStack(spacing: 16) {
                TextField("Email", text: $emailId)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.7))
                    .padding(.top, 25)
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.7))
                Button("Reset Password", action: {
                    resetPassword()
                })
                .font(.callout)
                .tint(.black)
                .hAlign(.trailing)
                
                Button(action: {
                    loginUser()
                }, label: {
                    Text("Sign IN")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                })
            }
            
            //MARK:
            HStack{
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                Button(action: {
                    createAccount.toggle()
                }, label: {
                    Text("Register Now")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                })
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(showProgress: $isLoading)
        })
        .fullScreenCover(isPresented: $createAccount, content: {
            SignUpView()
        })
        .alert(errorMsg, isPresented: $showError, actions: {})
    }
    
    func loginUser() {
        self.isLoading = true
        closeAllKeyboards()
        Task{
            do {
                try await Auth.auth().signIn(withEmail: self.emailId, password: self.password)
                try await fetchUserDetails()
            } catch {
                await setError(error)
            }
        }
    }
    
    func resetPassword() {
        Task{
            do {
                try await Auth.auth().sendPasswordReset(withEmail: self.emailId)
            } catch {
                await setError(error)
            }
        }
    }
    
    func fetchUserDetails() async throws{
        do {
            guard let userUID = Auth.auth().currentUser?.uid else {return}
            let userData = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: UserData.self)
            await MainActor.run(body: {
                self.userUID = userUID
                self.userProfileName = userData.userName
                self.userProfilePic = userData.userProfilePic
                self.logStatus = true
            })
        } catch {
            await setError(error)
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
