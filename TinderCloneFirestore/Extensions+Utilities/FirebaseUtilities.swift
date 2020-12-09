//
//  FirebaseUtilities.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 05/12/20.
//

import Foundation
import Firebase

extension Firestore {
    
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
        //get uid of current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //fetch user information from firestore based on his/her uid
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user, nil)
        }
    }
}

