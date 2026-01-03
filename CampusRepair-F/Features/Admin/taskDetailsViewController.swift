//
//  taskDetailsViewController.swift
//  CampusRepair-F
//
//  Created by [Your Name] on [Date]
//

import UIKit
import FirebaseFirestore

class taskDetailsViewController: UIViewController {
    
    @IBOutlet weak var techName: UILabel!
    @IBOutlet weak var StudentName: UILabel!
    @IBOutlet weak var reqCategory: UILabel!
    @IBOutlet weak var problemDescription: UILabel!
    @IBOutlet weak var requestLocation: UILabel!
    @IBOutlet weak var requestDate: UILabel!
    @IBOutlet weak var reqLabel: UILabel!
    @IBOutlet weak var priority: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // Firebase
    private let db = Firestore.firestore()
    
    // This will be passed from the previous screen
    var requestId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRequestDetails()
    }
    
    private func fetchRequestDetails() {
        guard let requestId = requestId else {
            print("No request ID provided")
            return
        }
        
        // Show loading indicator
        showLoading()
        
        db.collection("requests").document(requestId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.hideLoading()
            
            if let error = error {
                print("Error fetching request details: \(error)")
                self.showAlert(title: "Error", message: "Failed to load request details")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found for request")
                self.showAlert(title: "Error", message: "Request not found")
                return
            }
            
            // Update UI with request data
            self.updateUI(with: data)
            
            // If technician is assigned, fetch technician name
            if let technicianId = data["assignedTo"] as? String {
                self.fetchTechnicianName(technicianId: technicianId)
            }
            
            // If we don't have student name, fetch it
            if let studentId = data["createdBy"] as? String,
               let studentName = data["createdByName"] as? String, studentName.isEmpty {
                self.fetchStudentName(studentId: studentId)
            }
        }
    }
    
    private func updateUI(with data: [String: Any]) {
        // Update all labels with data
        reqLabel.text = data["title"] as? String ?? "No Title"
        problemDescription.text = data["description"] as? String ?? "No Description"
        requestLocation.text = data["location"] as? String ?? "No Location"
        reqCategory.text = data["category"] as? String ?? "General"
        
        // Priority with color coding
        let priorityText = data["priority"] as? String ?? "low"
        priority.text = priorityText.uppercased()
        
        switch priorityText.lowercased() {
        case "high":
            priority.textColor = .red
        case "medium":
            priority.textColor = .orange
        case "low":
            priority.textColor = .green
        default:
            priority.textColor = .gray
        }
        
        // Status with color coding
        let statusText = data["status"] as? String ?? "pending"
        statusLabel.text = statusText.uppercased()
        
        switch statusText.lowercased() {
        case "completed":
            statusLabel.textColor = .systemGreen
        case "in-progress", "processing":
            statusLabel.textColor = .systemBlue
        case "pending":
            statusLabel.textColor = .systemOrange
        default:
            statusLabel.textColor = .gray
        }
        
        // Date formatting
        if let timestamp = data["createdAt"] as? Timestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            requestDate.text = dateFormatter.string(from: timestamp.dateValue())
        } else if let date = data["createdAt"] as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            requestDate.text = dateFormatter.string(from: date)
        } else {
            requestDate.text = "Unknown date"
        }
        
        // Student name (from request data or fetch)
        StudentName.text = data["createdByName"] as? String ?? "Loading..."
        
        // Technician name
        if let techNameData = data["assignedToName"] as? String {
            techName.text = techNameData
        } else if let _ = data["assignedTo"] as? String {
            techName.text = "Loading..."
        } else {
            techName.text = "Not assigned"
        }
    }
    
    private func fetchTechnicianName(technicianId: String) {
        db.collection("users").document(technicianId).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(),
               let technicianName = data["name"] as? String {
                DispatchQueue.main.async {
                    self?.techName.text = technicianName
                }
            }
        }
    }
    
    private func fetchStudentName(studentId: String) {
        db.collection("users").document(studentId).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(),
               let studentName = data["name"] as? String {
                DispatchQueue.main.async {
                    self?.StudentName.text = studentName
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        activityIndicator.tag = 999
        view.addSubview(activityIndicator)
    }
    
    private func hideLoading() {
        DispatchQueue.main.async {
            if let activityIndicator = self.view.viewWithTag(999) as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
