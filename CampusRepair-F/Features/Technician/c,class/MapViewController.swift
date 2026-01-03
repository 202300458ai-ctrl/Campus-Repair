//
//  MapViewController.swift
//  tech
//
//  Created by Macbook Pro on 28/11/2025.
//

import UIKit

final class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // // MARK: - Outlets
    // -------------------------
    @IBOutlet weak var serverRoomCountLabel: UILabel!
    @IBOutlet weak var computerLabCountLabel: UILabel!
    @IBOutlet weak var room306CountLabel: UILabel!
    @IBOutlet weak var room305CountLabel: UILabel!
    @IBOutlet weak var room304CountLabel: UILabel!
    @IBOutlet weak var room303CountLabel: UILabel!
    @IBOutlet weak var room302CountLabel: UILabel!
    
    @IBOutlet weak var room301CountLabel: UILabel!
    @IBOutlet weak var engineeringButton: UIButton!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var itButton: UIButton!
    @IBOutlet weak var dropdownArrowButton: UIButton!
    @IBOutlet weak var dropdownMenuView: UIView!
    @IBOutlet weak var buildingLabel: UILabel!
    
    @IBOutlet weak var room301View: UIView!
    @IBOutlet weak var room302View: UIView!
    @IBOutlet weak var room303View: UIView!
    @IBOutlet weak var room304View: UIView!
    @IBOutlet weak var room305View: UIView!
    @IBOutlet weak var room306View: UIView!
    
    @IBOutlet weak var computerLabView: UIView!
    @IBOutlet weak var serverRoomView: UIView!
    
    @IBOutlet weak var hallwayView: UIView!
    
    @IBOutlet weak var highDot: UIView!
    @IBOutlet weak var mediumDot: UIView!
    @IBOutlet weak var completeDot: UIView!
    
    @IBOutlet weak var issuesTableView: UITableView!
    //
    //  MapViewController.swift
    //  tech
    //
    //  Created by Macbook Pro on 28/11/2025.
    //
        // MARK: - State
        private var tasks: [Task] = []
        private var isDropdownOpen = false

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()

            buildingLabel.text = "Engineering – Floor 3"

            issuesTableView.delegate = self
            issuesTableView.dataSource = self
            issuesTableView.tableHeaderView = nil

            dropdownMenuView.isHidden = true
            view.bringSubviewToFront(dropdownMenuView)

            setupLegend()
            loadTasks()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            closeDropdown()
            loadTasks()
        }

        // MARK: - Load Tasks
        private func loadTasks() {
            // Only Engineering tasks + not completed (so map shows active tasks)
            tasks = TaskManager.shared.tasks.filter {
                $0.location.hasPrefix("Engineering") &&
                $0.status.uppercased() != "COMPLETED"
            }

            applyTasksToRooms()
            issuesTableView.reloadData()
        }

        // MARK: - Rooms Logic
        private func applyTasksToRooms() {
            let grouped = Dictionary(grouping: tasks) { $0.location }

            resetAllRooms()

            updateRoom(key: "Engineering - Room 301", view: room301View, label: room301CountLabel, grouped: grouped)
            updateRoom(key: "Engineering - Room 302", view: room302View, label: room302CountLabel, grouped: grouped)
            updateRoom(key: "Engineering - Room 303", view: room303View, label: room303CountLabel, grouped: grouped)
            updateRoom(key: "Engineering - Room 304", view: room304View, label: room304CountLabel, grouped: grouped)
            updateRoom(key: "Engineering - Room 305", view: room305View, label: room305CountLabel, grouped: grouped)
            updateRoom(key: "Engineering - Room 306", view: room306View, label: room306CountLabel, grouped: grouped)

            updateRoom(key: "Engineering - Computer Lab", view: computerLabView, label: computerLabCountLabel, grouped: grouped)
            updateRoom(key: "Engineering - Server Room", view: serverRoomView, label: serverRoomCountLabel, grouped: grouped)
        }

        private func resetAllRooms() {
            let rooms: [(UIView?, UILabel?)] = [
                (room301View, room301CountLabel),
                (room302View, room302CountLabel),
                (room303View, room303CountLabel),
                (room304View, room304CountLabel),
                (room305View, room305CountLabel),
                (room306View, room306CountLabel),
                (computerLabView, computerLabCountLabel),
                (serverRoomView, serverRoomCountLabel)
            ]

            rooms.forEach {
                $0.0?.backgroundColor = .systemGray5
                $0.1?.text = ""
            }
        }

        private func updateRoom(key: String, view: UIView?, label: UILabel?, grouped: [String: [Task]]) {
            guard let roomTasks = grouped[key], !roomTasks.isEmpty else { return }

            label?.text = "\(roomTasks.count)"

            let hasUrgent = roomTasks.contains { $0.priority.uppercased() == "HIGH" }
            let hasMedium = roomTasks.contains { $0.priority.uppercased() == "MEDIUM" }
            let hasLow = roomTasks.contains { $0.priority.uppercased() == "LOW" }

            if hasUrgent {
                view?.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
            } else if hasMedium {
                view?.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.7)
            } else if hasLow {
                view?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
            } else {
                view?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
            }
        }

        // MARK: - Legend
        private func setupLegend() {
            [highDot, mediumDot, completeDot].forEach {
                $0?.layer.cornerRadius = 5
                $0?.clipsToBounds = true
            }

            highDot.backgroundColor = .systemRed
            mediumDot.backgroundColor = .systemOrange
            completeDot.backgroundColor = .systemBlue
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "TaskDetailsVC"
        ) as! TaskDetailsViewController

        vc.task = task
        navigationController?.pushViewController(vc, animated: true)
    }
        // MARK: - TableView
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tasks.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
            let task = tasks[indexPath.row]

            cell.titleLable.text = task.title
            cell.priorityLabel.text = task.priority.uppercased()
            cell.timeLable.text = task.timeAgo
            cell.descriptionLabel.text = task.description
            cell.locationLabel.text = task.location
            cell.dueLabel.text = task.due
            cell.statusLabel.text = task.status

            // priority badge
            switch task.priority.uppercased() {
            case "HIGH":
                cell.priorityLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                cell.priorityLabel.textColor = .systemRed
            case "MEDIUM":
                cell.priorityLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
                cell.priorityLabel.textColor = .systemOrange
            case "LOW":
                cell.priorityLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                cell.priorityLabel.textColor = .systemBlue
            default:
                cell.priorityLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                cell.priorityLabel.textColor = .darkGray
            }
            cell.priorityLabel.layer.cornerRadius = 8
            cell.priorityLabel.clipsToBounds = true

            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 112
        }

        // MARK: - Dropdown
        @IBAction func dropdownArrowTapped(_ sender: UIButton) {
            isDropdownOpen.toggle()

            UIView.animate(withDuration: 0.25) {
                self.dropdownArrowButton.transform = self.isDropdownOpen ? CGAffineTransform(rotationAngle: .pi) : .identity
            }

            dropdownMenuView.isHidden = !isDropdownOpen
            view.bringSubviewToFront(dropdownMenuView)
        }

        private func closeDropdown() {
            isDropdownOpen = false
            dropdownMenuView.isHidden = true
            UIView.animate(withDuration: 0.25) {
                self.dropdownArrowButton.transform = .identity
            }
        }

        // MARK: - Floor Buttons
        @IBAction func engineeringTapped(_ sender: UIButton) {
            closeDropdown()
            // already here
        }

        @IBAction func itTapped(_ sender: UIButton) {
            closeDropdown()
            let vc = storyboard?.instantiateViewController(withIdentifier: "ITMapViewController") as! ITMapViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }

        @IBAction func businessTapped(_ sender: UIButton) {
            closeDropdown()
            let vc = storyboard?.instantiateViewController(withIdentifier: "BusinessMapViewController") as! BusinessMapViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
