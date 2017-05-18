//
//  LoginController+handle.swift
//  MyChat
//
//  Created by Nguyen Duy Khanh on 5/17/17.
//  Copyright © 2017 Nguyen Duy Khanh. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func handleRegister() {
        print("Register")
        
        //Handle register process
        guard let email = emailTextfield.text, let password = passwordTextfield.text, let name = nameTextfield.text else {
            print("invalid form")
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {(user:FIRUser?, error) in
            
            //check items if blank or not
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //create a reference to Firebase storage
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
            
            
            //upload the image to storage
                    if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                    }
                    
                    //return the object from result and register user to database.
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["name":name,"email":email, "profileImageUrl":profileImageURL]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])

                    }
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid:String, values:[String:AnyObject]) {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(fromURL: "https://mychat-60681.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err,ref) in
            if err != nil {
                print(err!)
                return
            }
            self.messageController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
            print("save user successful")
        })
    }
    
    func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        var selectedImageFromPicker:UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        }
        if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel picker")
    }
}
