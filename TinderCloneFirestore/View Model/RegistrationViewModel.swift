//
//  RegistrationViewModel.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 30/11/20.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    //Here we write simplified version of declaring observers. Hence we introduce the concept of bindable class
    //This is equivalent to var bindableIsRegistering:((Bool?) -> ())?
    var bindableIsRegistering = Bindable<Bool>()
    
    //This is equivalent to var bindableImage:((UIImage?) -> ())?
    var bindableImage = Bindable<UIImage>()
    
    //This is equivalent to var bindableIsFormValid:((Bool?) -> ())?
    var bindableIsFormValid = Bindable<Bool>()

    var fullName: String? { didSet { checkFormValidity() } }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        //This is equivalent to calling method bindableIsFormValid(isFormValid)
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegisteration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        //This is equivalent to calling method bindableIsRegistering(true)
        bindableIsRegistering.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
//                print("Error registering user:", error)
                completion(error)
                return
            }
            
            print("Successfully registered user:", result?.user.uid ?? "")
            
            self.saveImageToFirebase(completion: completion)
        }
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString //This will generate a unique string and we will use it as an image file name
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        
        ref.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print("Error uploading profile image:", error)
                completion(error)
                return
            }
            
            print("Finished uploading image to storage")
            ref.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting image download url:", error)
                    completion(error)
                    return
                }
                
                self.bindableIsRegistering.value = false
                print("Download url of image is:", url?.absoluteString ?? "")
                
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            }
        }
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["fullName": fullName ?? "", "uid": uid, "imageUrl1": imageUrl]
        
        //This will create users collection on firestore and store user data 
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
}
