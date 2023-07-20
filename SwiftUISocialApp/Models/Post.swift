//
//  Post.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 20/07/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    var postText : String
    var postImgURL : String
    var postImgReferenceID : String = ""
    var postPublishedDate : Date = Date()
    var postLikedIDS : [String] = []
    var postDisLikedIDS : [String] = []

    var userProfileName : String
    var userProfilePic : String
    var userUID : String
    
    enum Codingkeys : CodingKey {
        case id
        case postText
        case postImgURL
        case postImgReferenceID
        case postPublishedDate
        case postLikedIDS
        case postDisLikedIDS
        case userProfileName
        case userProfilePic
        case userUID
    }
}
