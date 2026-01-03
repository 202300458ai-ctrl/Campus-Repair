//
//  ReportIssueViewController.swift
//  tech
//
//  Created by Macbook Pro on 18/12/2025.
//

import UIKit

class ReportIssueViewController: UIViewController {

    // MARK: - Outlets (CONNECT THESE IN STORYBOARD)
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    // MARK: - Simple State
    var selectedPriority: String = "MEDIUM"
    var selectedLocation: String = "Unknown Location"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Report Issue"
        view.backgroundColor = .systemBackground
    }

    // MARK: - Submit
    @IBAction func submitTapped(_ sender: UIButton) {

        // 1️⃣ Create task (your logic already exists)
        let newTask = Task(
            title: titleTextField.text ?? "New Issue",
            priority: selectedPriority,
            timeAgo: "Just now",
            description: descriptionTextView.text ?? "",
            location: selectedLocation,
            due: "Today",
            status: "ASSIGNED"
        )

        TaskManager.shared.tasks.append(newTask)

        // 2️⃣ Show success alert
        let alert = UIAlertController(
            title: "Report Sent ✅",
            message: "Your issue has been reported successfully.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            }
        )

        present(alert, animated: true)
    }
}
