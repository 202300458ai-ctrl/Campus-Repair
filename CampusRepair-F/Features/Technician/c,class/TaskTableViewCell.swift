//
//  TaskTableViewCell.swift
//  tech
//
//  Created by Macbook Pro on 28/11/2025.
//

import UIKit
class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var timeLable: UILabel!
    
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
     override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            titleLable.text = nil
            priorityLabel.text = nil
            timeLable.text = nil
            descriptionLabel.text = nil
            locationLabel.text = nil
            dueLabel.text = nil
            statusLabel.text = nil
        }

        // MARK: - UI Setup
    private func setupUI() {

        // 🔹 Labels that can grow
        titleLable.numberOfLines = 0

        // 🔹 UITextView setup
        descriptionLabel.isScrollEnabled = false
        descriptionLabel.isEditable = false
        descriptionLabel.isSelectable = false
        descriptionLabel.textContainerInset = .zero
        descriptionLabel.textContainer.lineFragmentPadding = 0

        // 🔹 Auto Layout priority
        titleLable.setContentHuggingPriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)

        // 🔹 Priority pill styling
        priorityLabel.textAlignment = .center
        priorityLabel.layer.cornerRadius = 8
        priorityLabel.clipsToBounds = true

        // 🔹 Status label
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)

        selectionStyle = .none
    }

        // MARK: - Configure
        func configure(with task: Task) {

            titleLable.text = task.title
            priorityLabel.text = task.priority.uppercased()
            timeLable.text = task.timeAgo
            descriptionLabel.text = task.description
            locationLabel.text = task.location
            dueLabel.text = task.due
            statusLabel.text = task.status

            // Priority color logic
            switch task.priority.uppercased() {
            case "URGENT":
                priorityLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                priorityLabel.textColor = .systemRed

            case "MEDIUM":
                priorityLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
                priorityLabel.textColor = .systemOrange

            case "LOW":
                priorityLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                priorityLabel.textColor = .systemBlue

            default:
                priorityLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                priorityLabel.textColor = .darkGray
            }

            // Status color
            switch task.status.uppercased() {
            case "COMPLETED":
                statusLabel.textColor = .systemGreen
            case "IN-PROGRESS":
                statusLabel.textColor = .systemOrange
            default:
                statusLabel.textColor = .secondaryLabel
            }
        }
    }


