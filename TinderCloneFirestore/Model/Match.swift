//
//  Match.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 09/04/21.
//

import Foundation

struct Match {
    let name, profileImageUrl, uid: String
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
