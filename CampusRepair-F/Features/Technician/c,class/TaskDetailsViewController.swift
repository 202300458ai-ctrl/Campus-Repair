//
//  TaskDetailsViewController.swift
//  tech
//
//  Created by Macbook Pro on 28/11/2025.
//

import UIKit

class TaskDetailsViewController: UIViewController {

    // MARK: - Header
    @IBOutlet weak var statusBadgeLabel: UILabel!      // In Progress
    @IBOutlet weak var priorityBadgeLabel: UILabel!    // Priority: High

    // MARK: - Main Info
    @IBOutlet weak var titleLabel: UILabel!             // Broken AC Unit
    @IBOutlet weak var requestIdLabel: UILabel!         // REQ-2024-0156
    @IBOutlet weak var assignedLabel: UILabel!          // Assigned
    @IBOutlet weak var timeAgoLabel: UILabel!            // 2 hours ago

    // MARK: - Location
    @IBOutlet weak var locationLabel: UILabel!           // Engineering - Room 301

    // MARK: - Description
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: - Category & Urgency
    @IBOutlet weak var categoryLabel: UILabel!           // HVAC
    @IBOutlet weak var urgencyLabel: UILabel!            // High


    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    // MARK: - Data
    var task: Task!
    override func viewDidLoad() {
            super.viewDidLoad()
            configureUI()
        }

        private func configureUI() {
            guard let task = task else { return }

            // Text
            titleLabel.text = task.title
            requestIdLabel.text = "REQ-\(UUID().uuidString.prefix(8))"
            timeAgoLabel.text = task.timeAgo
            locationLabel.text = task.location
            descriptionLabel.text = task.description
            categoryLabel.text = "HVAC" // static for now
            urgencyLabel.text = task.priority.capitalized
            assignedLabel.text = task.status.capitalized

            // Status Badge
            statusBadgeLabel.text = task.status.capitalized
            statusBadgeLabel.layer.cornerRadius = 8
            statusBadgeLabel.clipsToBounds = true

            // Priority Badge
            priorityBadgeLabel.text = "Priority: \(task.priority.capitalized)"
            priorityBadgeLabel.layer.cornerRadius = 8
            priorityBadgeLabel.clipsToBounds = true

            applyColors(for: task)
        }

        private func applyColors(for task: Task) {
            switch task.priority.uppercased() {
            case "HIGH":
                priorityBadgeLabel.backgroundColor = .systemRed.withAlphaComponent(0.2)
                urgencyLabel.textColor = .systemRed
            case "MEDIUM":
                priorityBadgeLabel.backgroundColor = .systemOrange.withAlphaComponent(0.2)
                urgencyLabel.textColor = .systemOrange
            default:
                priorityBadgeLabel.backgroundColor = .systemBlue.withAlphaComponent(0.2)
                urgencyLabel.textColor = .systemBlue
            }

            if task.status.uppercased() == "IN-PROGRESS" {
                statusBadgeLabel.backgroundColor = .systemOrange.withAlphaComponent(0.2)
            } else if task.status.uppercased() == "COMPLETED" {
                statusBadgeLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            } else {
                statusBadgeLabel.backgroundColor = .systemGray.withAlphaComponent(0.2)
            }
        }
    }
