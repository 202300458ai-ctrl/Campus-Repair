//
//  SignUpViewController.swift
//  CampusRepair-F
//
//  Created by Guest User on 03/01/2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
    }
    
    // MARK: - Setup
    private func setupUI() {

        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFields() {
        // Set delegates for keyboard dismissal
        nameText.delegate = self
        emailText.delegate = self
        passwordText.delegate = self
        
        // Setup text field appearance
        setupTextField(nameText, placeholder: "Full Name")
        setupTextField(emailText, placeholder: "Email Address")
        setupTextField(passwordText, placeholder: "Password (min. 6 characters)")
        
        // Make password field secure
        passwordText.isSecureTextEntry = true
        
        // Set return key types
        nameText.returnKeyType = .next
        emailText.returnKeyType = .next
        passwordText.returnKeyType = .done
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func signUpClicked(_ sender: Any) {
        createUserAccount()
    }
    
    @IBAction func backToSignInTapped(_ sender: UIButton) {
        // Navigate back to sign in screen
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Firebase Sign Up
    private func createUserAccount() {
        // Validate inputs
        guard let name = nameText.text, !name.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter your full name")
            return
        }
        
        guard let email = emailText.text, !email.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter your email address")
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        
        guard let password = passwordText.text, !password.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter a password")
            return
        }
        
        guard password.count >= 6 else {
            showAlert(title: "Password Too Short", message: "Password must be at least 6 characters")
            return
        }
        
        // Determine role based on segmented control
        let role: String
        role = "student"
        
        // Show loading indicator
        showLoadingIndicator(message: "Creating account...")
        
        // Step 1: Create user in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.hideLoadingIndicator()
                self.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                self.hideLoadingIndicator()
                self.showAlert(title: "Sign Up Failed", message: "Failed to create user account")
                return
            }
            
            print("✅ Firebase Authentication user created: \(user.uid)")
            
            // Step 2: Create user document in Firestore
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "name": name,
                "role": role,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            // Add role-specific fields
            var finalUserData = userData
            if role == "student" {
                // Generate student ID
                let studentID = "S\(Int(Date().timeIntervalSince1970))"
                finalUserData["studentId"] = studentID
                finalUserData["year"] = "Freshman"
                finalUserData["major"] = "Undecided"
                finalUserData["dormRoom"] = "Not Assigned"
            } else if role == "technician" {
                // Generate technician ID
                let technicianID = "T-\(Int(Date().timeIntervalSince1970))"
                finalUserData["technicianId"] = technicianID
                finalUserData["badgeNumber"] = technicianID
                finalUserData["skills"] = ["general"]
                finalUserData["rating"] = 0.0
                finalUserData["available"] = true
                finalUserData["department"] = "Maintenance"
                finalUserData["experience"] = "New Technician"
                finalUserData["totalTasks"] = 0
            } else if role == "admin" {
                finalUserData["department"] = "Administration"
                finalUserData["title"] = "Administrator"
            }
            
            // Save user data to Firestore
            Firestore.firestore().collection("users").document(user.uid).setData(finalUserData) { error in
                self.hideLoadingIndicator()
                
                if let error = error {
                    self.showAlert(title: "Data Save Failed", message: "Failed to save user profile: \(error.localizedDescription)")
                    return
                }
                
                print("✅ Firestore user document created successfully")
                
                // Show success message
                let successMessage = """
                Account created successfully!
                
                Role: \(role.capitalized)
                Email: \(email)
                
                You can now sign in with your credentials.
                """
                
                let alert = UIAlertController(
                    title: "🎉 Success!",
                    message: successMessage,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Sign In", style: .default) { _ in
                    // Go back to sign in screen
                    self.navigationController?.popViewController(animated: true)
                })
                
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showLoadingIndicator(message: String = "Loading...") {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func hideLoadingIndicator() {
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameText:
            emailText.becomeFirstResponder()
        case emailText:
            passwordText.becomeFirstResponder()
        case passwordText:
            passwordText.resignFirstResponder()
            createUserAccount()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
