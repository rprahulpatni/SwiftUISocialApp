//
//  ReusableProfileView.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileView: View {
    var myProfile: UserData?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                HStack(spacing: 12) {
                    WebImage(url: URL(string: self.myProfile?.userProfilePic ?? "")).placeholder{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(myProfile?.userName ?? "")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text(myProfile?.userBio ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        if let bioLink = URL(string: self.myProfile?.userBioLink ?? "") {
                            Link(self.myProfile?.userBioLink ?? "", destination: bioLink)
                                .font(.callout)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                    }
                }
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
            }
        }
    }
}

struct ReusableProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ReusableProfileView()
    }
}