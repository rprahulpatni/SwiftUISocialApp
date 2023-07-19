//
//  SignUpView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @State var userName: String = ""
    @State var userEmailId: String = ""
    @State var userPassword: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data? = nil
    
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
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
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            ViewThatFits(content: {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                HelperView()
            })
            //MARK:
            HStack{
                Text("Already have an account?")
                    .foregroundColor(.gray)
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Login Now")
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
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    do {
                        guard let imgData = try await newValue.loadTransferable(type: Data.self) else {return}
                        await MainActor.run(body: {
                            self.userProfilePicData = imgData
                        })
                    } catch {
                        
                    }
                }
            }
        }
        .alert(self.errorMsg, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView() ->some View {
        VStack(spacing: 16) {
            ZStack{
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            TextField("Name", text: $userName)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            TextField("Email", text: $userEmailId)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            SecureField("Password", text: $userPassword)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            TextField("About you", text: $userBio,axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            TextField("Bio Link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            Button(action: {
                registerUser()
            }, label: {
                Text("Sign UP")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            })
            .disbableWithOpacity(userName == "" || userEmailId == "" || userPassword == "" || userBio == "" || userProfilePicData == nil)
            .padding(.top, 10)
        }
    }
    
    func registerUser() {
        self.isLoading = true
        closeAllKeyboards()

        Task{
            do {
                try await Auth.auth().createUser(withEmail: self.userEmailId, password: self.userPassword)
                guard let userId = Auth.auth().currentUser?.uid else {return}
                guard let imgData = self.userProfilePicData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userId)
                let _ = try await storageRef.putDataAsync(imgData)
                let downloadUrl = try await storageRef.downloadURL()
//                let user = UserData(userName: self.userName, userBio: self.bio, userBioLink: self.bioLink, userUID: userId, userEmail: self.emailId, userProfilePic: downloadUrl)
                let updatedData: [String: Any] = [
                    "userName": self.userName,
                    "userBio": self.userBio,
                    "userBioLink": self.userBioLink,
                    "userUID": userId,
                    "userEmail": self.userEmailId,
                    "userProfilePic": downloadUrl.absoluteString
                ]
                let _ = try Firestore.firestore().collection("Users").document(userId).setData(updatedData, completion : {
                    err in
                    if err == nil {
                        print("Saved Successfully")
                        self.userUID = userId
                        self.userProfilePic = downloadUrl.absoluteString
                        self.userProfileName = self.userName
                        self.logStatus = true
                    }
                })
            } catch {
                try await Auth.auth().currentUser?.delete()
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
