//
//  ViewController.swift
//  CampusRepair-F
//
//  Created by khalid on 14/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        emailTextField.text = "student1@example.com"
        passwordTextField.text = "password123"
    }

    @IBAction func singInClicked(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Enter email and password")
            return
        }
        
        // Sign in with Firebase
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            // Get user role from Firestore
            self.getUserRole()
        }
    }
    
    func getUserRole() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let role = data["role"] as? String else {
                print("No role found")
                return
            }
            
            print("User role: \(role)")
            self.goToScreenForRole(role)
        }
    }
    
    func goToScreenForRole(_ role: String) {
        switch role {
        case "student":
            goToStudentHome()
        case "technician":
            goToTechnicianHome()
        case "admin":
            goToAdminHome()
        default:
            print("Unknown role: \(role)")
        }
    }
    
    func goToStudentHome() {
        let storyboard = UIStoryboard(name: "studentHome", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "studentTabBarController") as? UITabBarController else {
            print("Failed to load student home")
            return
        }
        
        // Change root view controller
        if let window = view.window {
            window.rootViewController = tabBarController
        }
    }
    
    func goToTechnicianHome() {
        let storyboard = UIStoryboard(name: "TechMain", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "techTabBarController") as? UITabBarController else {
            print("Failed to load student home")
            return
        }
        
        // Change root view controller
        if let window = view.window {
            window.rootViewController = tabBarController
        }
    }
    
    func goToAdminHome() {
        let storyboard = UIStoryboard(name: "AdminMain", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "AdminTabBarController") as? UITabBarController else {
            print("Failed to load student home")
            return
        }
        
        // Change root view controller
        if let window = view.window {
            window.rootViewController = tabBarController
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
