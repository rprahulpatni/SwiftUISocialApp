//
//  UsersData.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserData: Identifiable, Codable {
    @DocumentID var id: String?
    var userName : String
    var userBio : String
    var userBioLink : String
    var userUID : String
    var userEmail : String
    var userProfilePic : String

    enum Codingkeys : CodingKey {
        case id
        case userName
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case userProfilePic
    }
}

extension Dictionary {
    func convertToDictionary<T: Codable>(_ object: T) -> [String: Any]? {
        do {
            let jsonData = try JSONEncoder().encode(object)
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return jsonObject
            }
        } catch {
            print("Error converting to dictionary: \(error)")
        }
        return nil
    }
}

