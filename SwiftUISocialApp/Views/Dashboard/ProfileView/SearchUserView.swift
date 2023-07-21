//
//  SearchUserView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 20/07/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct SearchUserView: View {
    @State private var fetchedUsers: [UserData] = []
    @State private var searchText: String = ""
    
    var body: some View {
        List{
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    ReusableProfileView(user: user, isFromMyProfile: false)
                } label: {
                    Text(user.userName)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            Task{
                await searchUsers()
            }
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                self.fetchedUsers = []
            }
        })
    }
    
    func searchUsers() async {
        do{
            let doc = try await Firestore.firestore().collection("Users").whereField("userName", isGreaterThanOrEqualTo: searchText).whereField("userName", isLessThanOrEqualTo: "\(searchText)\u{f8ff}").getDocuments()
            
            let users = try doc.documents.compactMap { doc -> UserData? in
                try doc.data(as: UserData.self)
            }
            await MainActor.run(body: {
                self.fetchedUsers = users
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
