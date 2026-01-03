//
//  assignTaskViewController.swift
//  CampusRepair-F
//
//  Created by BP-19-131-10 on 03/01/2026.
//

import UIKit

class assignTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct Reqs {
        let id: String
        let description: String
        let location: String
        let category: String
        let timeAgo: String
        let priority: String
        let status: String
    }

    // MARK: - Outlets
    @IBOutlet weak var Priority: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAssignTask: UIButton!
    @IBOutlet weak var seqButtons: UISegmentedControl!
    @IBOutlet weak var nameReq: UILabel!
    @IBOutlet weak var building: UILabel!
    @IBOutlet weak var catagory: UILabel!
    @IBOutlet weak var issueReq: UILabel!
    @IBOutlet weak var timeReq: UILabel!
    @IBOutlet weak var titleReq: UILabel!
    @IBOutlet weak var statusReq: UILabel!

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cata: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    // MARK: - Data
        var task: Task!   // passed from previous screen
    var reqs: Reqs!
        private var technicians: [Technician] = []
        private var filteredTechs: [Technician] = []
        private var selectedTechnician: Technician?

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.delegate = self
            tableView.dataSource = self

            configureTaskUI()
            loadTechnicians()
            applyFilter(index: 0)
        }

        // MARK: - Task UI
    private func configureTaskUI() {
        guard let reqs = reqs else { return }

        // Task ID / Title
        titleReq.text = "Request #\(reqs.id)"  // Assuming task.id is something like REQ-2024-0156

        // Time submitted
        timeReq.text = "Submitted \(reqs.timeAgo)"

        // Location & Category
        building.text = reqs.location
        catagory.text = reqs.category // Previously hardcoded as "HVAC"

        // Issue description
        issueReq.text = reqs.description

        // Status
        statusReq.text = reqs.status.capitalized
        statusReq.layer.cornerRadius = 8
        statusReq.clipsToBounds = true

        switch task.status.lowercased() {
        case "in progress":
            statusReq.backgroundColor = .systemOrange.withAlphaComponent(0.2)
        case "completed":
            statusReq.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        default:
            statusReq.backgroundColor = .systemGray.withAlphaComponent(0.2)
        }

        // Priority
        Priority.text = "Priority: \(task.priority)"
        Priority.layer.cornerRadius = 8
        Priority.clipsToBounds = true

        switch task.priority.lowercased() {
        case "high":
            Priority.backgroundColor = .systemRed.withAlphaComponent(0.2)
        case "medium":
            Priority.backgroundColor = .systemYellow.withAlphaComponent(0.2)
        default:
            Priority.backgroundColor = .systemGray.withAlphaComponent(0.2)
        }
    }
        // MARK: - Load Technicians
        private func loadTechnicians() {
            technicians = [
                Technician(name: "Mike Rodriguez", specialty: "HVAC", rating: 4.7, distance: 0.8, isAvailable: true),
                Technician(name: "Sarah Ahmed", specialty: "Electrical", rating: 4.5, distance: 1.2, isAvailable: true),
                Technician(name: "John Lee", specialty: "Network", rating: 4.2, distance: 2.1, isAvailable: false),
                Technician(name: "Ali Hassan", specialty: "HVAC", rating: 4.9, distance: 0.5, isAvailable: true)
            ]
        }

        // MARK: - Segmented Control
        @IBAction func segmentChanged(_ sender: UISegmentedControl) {
            applyFilter(index: sender.selectedSegmentIndex)
        }

        private func applyFilter(index: Int) {
            let titles = ["All", "HVAC", "Electrical", "Network", "General"]

            if index == 0 {
                filteredTechs = technicians.filter { $0.isAvailable }
            } else {
                filteredTechs = technicians.filter {
                    $0.specialty == titles[index] && $0.isAvailable
                }
            }

            tableView.reloadData()
        }

        // MARK: - TableView
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredTechs.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TechnicianCell",
                for: indexPath
            )

            let tech = filteredTechs[indexPath.row]

            cell.textLabel?.text = tech.name
            cell.detailTextLabel?.text =
            "\(tech.specialty) • ⭐️ \(tech.rating) • \(tech.distance) km"

            cell.accessoryType =
            (tech.name == selectedTechnician?.name) ? .checkmark : .none

            return cell
        }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let tech = filteredTechs[indexPath.row]
        selectedTechnician = tech
        updateTechnicianDetails(tech)

        tableView.reloadData()
    }

        // MARK: - Assign Task
        @IBAction func assignTapped(_ sender: UIButton) {
            guard let tech = selectedTechnician else {
                showAlert("Please select a technician first")
                return
            }

            statusReq.text = "In Progress"
            statusReq.backgroundColor = .systemOrange.withAlphaComponent(0.2)

            showAlert("Task assigned to \(tech.name)")
        }

        // MARK: - Alert
        private func showAlert(_ message: String) {
            let alert = UIAlertController(title: "Assign Task",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        // MARK: - Change details
        private func updateTechnicianDetails(_ tech: Technician) {
            name.text = tech.name
            cata.text = tech.specialty
            rate.text = "⭐️ \(tech.rating)"
            distance.text = "\(tech.distance) km"
        }
    }
