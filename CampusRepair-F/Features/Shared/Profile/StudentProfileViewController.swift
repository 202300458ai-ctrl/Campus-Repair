//
//  ProfileViewController.swift
//  CampusRepair-F
//
//  Created by khalid on 02/01/2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class StudentProfileViewController: UIViewController {
    @IBOutlet weak var totalCompletedLabel: UILabel!
    @IBOutlet weak var totalPendingLabel: UILabel!
    @IBOutlet weak var totalRequestsLabel: UILabel!
    @IBOutlet weak var IdLabel: UILabel!
    @IBOutlet weak var RoleLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    
    private let db = Firestore.firestore()
    private var userUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
        fetchRequestStats()
    }
    
    private func setupUI() {
        // Set initial placeholders
        NameLabel.text = "Loading..."
        RoleLabel.text = "Loading..."
        IdLabel.text = "Loading..."
        totalRequestsLabel.text = "0"
        totalPendingLabel.text = "0"
        totalCompletedLabel.text = "0"
    }
    
    private func loadUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            // User not logged in, handle accordingly
            print("No user logged in")
            return
        }
        
        userUID = currentUser.uid
        
        // Display basic info from Auth
        NameLabel.text = currentUser.displayName ?? "No Name"
        IdLabel.text = currentUser.email ?? "No Email"
        
        // Fetch additional user data from Firestore
        db.collection("users").document(currentUser.uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to load user data")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                // Update name if available from Firestore (overrides Auth display name)
                if let name = data?["name"] as? String {
                    self.NameLabel.text = name
                }
                
                // Update role
                if let role = data?["role"] as? String {
                    self.RoleLabel.text = role.capitalized
                } else {
                    self.RoleLabel.text = "User"
                }
                
                // Update ID/Email if available
                if let email = data?["email"] as? String {
                    self.IdLabel.text = email
                }
            }
        }
    }
    
    private func fetchRequestStats() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let requestsRef = db.collection("requests")
        
        // Fetch all requests for this user
        requestsRef.whereField("createdBy", isEqualTo: userUID).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching requests: \(error.localizedDescription)")
                return
            }
            
            var totalCount = 0
            var pendingCount = 0
            var completedCount = 0
            
            if let documents = querySnapshot?.documents {
                totalCount = documents.count
                
                for document in documents {
                    let data = document.data()
                    if let status = data["status"] as? String {
                        switch status.lowercased() {
                        case "pending":
                            pendingCount += 1
                        case "completed":
                            completedCount += 1
                        default:
                            break
                        }
                    }
                }
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.totalRequestsLabel.text = "\(totalCount)"
                self.totalPendingLabel.text = "\(pendingCount)"
                self.totalCompletedLabel.text = "\(completedCount)"
            }
        }
    }
    
    @IBAction func pushNotificationSwitch(_ sender: Any) {
        // Will be implemented later
    }
    
    @IBAction func editPersonalDetailClicked(_ sender: Any) {
        showEditNamePopup()
    }
    
    @IBAction func changePasswordClicked(_ sender: Any) {
        // Will be implemented later
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        showSignOutConfirmation()
    }
    
    // MARK: - Edit Name Popup
    
    private func showEditNamePopup() {
        // Create alert controller
        let alert = UIAlertController(
            title: "Edit Name",
            message: "Enter your new name",
            preferredStyle: .alert
        )
        
        // Add text field with current name
        alert.addTextField { textField in
            textField.placeholder = "Your name"
            textField.text = self.NameLabel.text != "Loading..." ? self.NameLabel.text : ""
            textField.autocapitalizationType = .words
        }
        
        // Add actions
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            if let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if newName.isEmpty {
                    self.showAlert(title: "Error", message: "Name cannot be empty")
                } else {
                    self.updateUserName(newName: newName)
                }
            }
        }))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    private func updateUserName(newName: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Show loading indicator
        showLoading()
        
        // Update in Firestore
        db.collection("users").document(currentUser.uid).updateData([
            "name": newName,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            guard let self = self else { return }
            
            self.hideLoading()
            
            if let error = error {
                print("Error updating name: \(error)")
                self.showAlert(title: "Error", message: "Failed to update name: \(error.localizedDescription)")
                return
            }
            
            // Update in Firebase Auth (optional)
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.displayName = newName
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating Auth display name: \(error)")
                    // We still updated Firestore, so continue
                }
            }
            
            // Update UI
            self.NameLabel.text = newName
            
            // Show success message
            self.showAlert(title: "Success", message: "Name updated successfully!")
            
            print("Name updated to: \(newName)")
        }
    }
    
    // MARK: - Sign Out
    
    private func showSignOutConfirmation() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            self.performSignOut()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func performSignOut() {
        do {
            try Auth.auth().signOut()
            
            // Navigate to login screen
            navigateToLoginScreen()
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showAlert(title: "Sign Out Failed", message: signOutError.localizedDescription)
        }
    }
    
    private func navigateToLoginScreen() {
        // Get the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate the login view controller
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        
        // Get the window and set root view controller
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = loginVC
        
        // Optional animation
        UIView.transition(with: window,
                         duration: 0.3,
                         options: .transitionCrossDissolve,
                         animations: nil,
                         completion: nil)
    }
    
    // MARK: - Helper Methods
    
    private func showLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        activityIndicator.tag = 999
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading() {
        DispatchQueue.main.async {
            if let activityIndicator = self.view.viewWithTag(999) as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
