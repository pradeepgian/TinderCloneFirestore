//
//  SettingsController.swift
//  TinderCloneFirestore
//
//  Created by Pradeep Gianchandani on 05/12/20.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class SettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var delegate: SettingsControllerDelegate?
    
    //MARK:- Instance Properies
    // Since we are accessing the createButton method while initilising the variable,
    // we declare the variable as lazy
    // This will make sure that imageButton object is not accessed on nil instance
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    @objc func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        
        //Upload the image
        //Once the image is uploaded, retrieve the download url and set it on user model
        //When save is tapped, user model is saved in firestore
        ref.putData(uploadData, metadata: nil) { (_, error) in
            
            if let error = error {
                hud.dismiss()
                print("Failed to upload image to storage:", error)
                return
            }
            
            print("Finished uploading image")
            ref.downloadURL { (url, error) in
                hud.dismiss()
                
                if let error = error {
                    print("Failed to retrieve download URL:", error)
                    return
                }
                
                print("Finished getting download url:", url?.absoluteString ?? "")
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
                
            }
        }
    }
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItems()
        
        //Create table view with light gray color
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        //Blank Footer view will remove the lines in UITableView
        tableView.tableFooterView = UIView()
        
        // This will dismiss the keyboard when table view scrolling begins
        // Keyboard will be interactive with scrollview of the table
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
    }
    
    deinit {
        print("Object is destroying itself properly, no retain cycles or any other memory related issues. Memory being reclaimed properly")
    }
    
    fileprivate func setupNavigationItems() {
        //This will create large "Settings" title (left aligned)
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Create left and right aligned buttons on navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        ]
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }

    // MARK:- Header
    lazy var header: UIView = {
        let header = UIView()
        
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        //set the width of image1 button 45% of the total width
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        //image2 and image3 button should be distributed equally in vertical stackview
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        
        return header
    }()
    
    class HeaderLabel: UILabel {
        //Here we override the drawText to add some padding on left side of text
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        headerLabel.font = .systemFont(ofSize: 16, weight: .bold)
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //First section will display the images we can set
        if section == 0 {
            return 300
        }
        return 40
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Here we will return zero rows for first section
        return section == 0 ? 0 : 1
    }
    
    // MARK:- Table view delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    static let defaultMinSeekingAge = 18
    static let defaultMaxSeekingAge = 50
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Age Range Cell
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            
            
            // Here we add default min and max seeking age
            let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
            let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
            
            ageRangeCell.minLabel.text = "Min \(minAge)"
            ageRangeCell.minSlider.value = Float(minAge)
            ageRangeCell.maxLabel.text = "Max \(maxAge)"
            ageRangeCell.maxSlider.value = Float(maxAge)
            return ageRangeCell
        }
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Enter Age"
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
            if let age = user?.age {
                cell.textField.text = String(age)
            }
        default:
            cell.textField.placeholder = "Enter Bio"
        }
        return cell
    }
    
    @objc func handleNameChange(textField: UITextField) {
        user?.name = textField.text
    }
    
    @objc func handleProfessionChange(textField: UITextField) {
        user?.profession = textField.text
    }
    
    @objc func handleAgeChange(textField: UITextField) {
        user?.age = Int(textField.text ?? "")
    }
    
    @objc fileprivate func handleMinAgeChange(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        if slider.value >= ageRangeCell.maxSlider.value {
            ageRangeCell.maxSlider.value = slider.value
        }
        ageRangeCell.minLabel.text = "Min \(Int(slider.value))"
        ageRangeCell.maxLabel.text = "Max \(Int(ageRangeCell.maxSlider.value))"
        
        self.user?.minSeekingAge = Int(slider.value)
    }
    
    @objc fileprivate func handleMaxAgeChange(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        if slider.value <= ageRangeCell.minSlider.value {
            ageRangeCell.minSlider.value = slider.value
        }
        ageRangeCell.maxLabel.text = "Max \(Int(slider.value))"
        ageRangeCell.minLabel.text = "Min \(Int(ageRangeCell.minSlider.value))"
        
        self.user?.maxSeekingAge = Int(slider.value)
    }
    
    // MARK:- Firebase functions
    var user: User?
    
    fileprivate func fetchCurrentUser() {
        // fetch current user's data from firestore based on uid
        Firestore.firestore().fetchCurrentUser { (user, error) in
            if let error = error {
                print("Error retreving current user info:", error)
                return
            }
            
            self.user = user
            self.loadUserPhotos()
            
            self.tableView.reloadData()
        }
    }
    
    fileprivate func loadUserPhotos() {
        //SDWebImage library is used to load the images from cache which we have downloaded already
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    @objc fileprivate func handleSave() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Pass the user data dictionary to firestore
        let docData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            hud.dismiss()
            
            if let error = error {
                print("Failed to save user settings:", error)
                hud.textLabel.text = "Failed to save data"
                hud.detailTextLabel.text = error.localizedDescription
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 5, animated: true)
                return
            }
            
            print("Finished saving user info")
            self.dismiss(animated: true) {
                print("Dismissal complete")
                //We will refetch the cards inside our home view
                self.delegate?.didSaveSettings()
            }
        }
    }
    
    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true)
    }
}

class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}
