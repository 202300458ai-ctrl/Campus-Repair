//
//  studentCreateRequest.swift
//  CampusRepair-F
//
//  Created by khalid on 29/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class studentCreateRequestVC: UIViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    
    // Map segments to actual values
    let categories = ["hvac", "electrical", "network", "plumbing", "general"]
    let priorities = ["low", "medium", "high", "critical"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // Style the text view
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.cornerRadius = 8
        
        // Set placeholder text
        descriptionTextView.text = "Describe the issue in detail..."
        descriptionTextView.textColor = .lightGray
        
        // Add tap to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        // 1. Validate all fields
        guard validateForm() else { return }
        
        // 2. Get the current user ID
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert("Error", "You must be logged in")
            return
        }
        
        // 3. Get values from UI
        let category = categories[categorySegment.selectedSegmentIndex]
        let priority = priorities[prioritySegment.selectedSegmentIndex]
        let title = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let location = locationTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 4. Create request data dictionary
        let requestData: [String: Any] = [
            "title": title,
            "description": description,
            "category": category,
            "priority": priority,
            "location": location,
            "createdBy": userId,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // 5. Save to Firestore
        Firestore.firestore().collection("requests").addDocument(data: requestData) { error in
            if let error = error {
                self.showAlert("Error", error.localizedDescription)
            } else {
                self.showAlert("Success", "Request submitted!") {
                    // Go back to previous screen
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func validateForm() -> Bool {
        // Check title
        if titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            showAlert("Missing Title", "Please enter a title for your request")
            return false
        }
        
        // Check location
        if locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            showAlert("Missing Location", "Please enter the location")
            return false
        }
        
        // Check description (make sure it's not placeholder text)
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if description.isEmpty || description == "Describe the issue in detail..." {
            showAlert("Missing Description", "Please describe the issue")
            return false
        }
        
        return true
    }
    
    func showAlert(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - TextView Placeholder Handling
extension studentCreateRequestVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Describe the issue in detail..."
            textView.textColor = .lightGray
        }
    }
}
