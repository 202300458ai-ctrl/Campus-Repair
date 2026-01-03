//
//  BusinessMapViewController.swift
//  tech
//

import UIKit

class BusinessMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var dropdownMenuView: UIView!
    @IBOutlet weak var dropdownArrowButton: UIButton!
    @IBOutlet weak var engineeringButton: UIButton!
    @IBOutlet weak var itButton: UIButton!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var buildingLabel: UILabel!
    
    @IBOutlet weak var room201View: UIView!
    @IBOutlet weak var room202View: UIView!
    @IBOutlet weak var room203View: UIView!
    @IBOutlet weak var room204View: UIView!
    @IBOutlet weak var room205View: UIView!
    @IBOutlet weak var room206View: UIView!
    
    @IBOutlet weak var meetingRoomAView: UIView!
    @IBOutlet weak var lectureHall1View: UIView!
    
    @IBOutlet weak var room201CountLabel: UILabel!
    @IBOutlet weak var room202CountLabel: UILabel!
    @IBOutlet weak var room203CountLabel: UILabel!
    @IBOutlet weak var room204CountLabel: UILabel!
    @IBOutlet weak var room205CountLabel: UILabel!
    @IBOutlet weak var room206CountLabel: UILabel!
    
    @IBOutlet weak var meetingRoomACountLabel: UILabel!
    @IBOutlet weak var lectureHall1CountLabel: UILabel!
    
    @IBOutlet weak var issuesTableView: UITableView!

        // MARK: - State
        private var tasks: [Task] = []
        private var isDropdownOpen = false

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()

            buildingLabel.text = "Business – Floor 2"

            issuesTableView.delegate = self
            issuesTableView.dataSource = self
            issuesTableView.tableHeaderView = nil

            dropdownMenuView.isHidden = true
            view.bringSubviewToFront(dropdownMenuView)
            view.bringSubviewToFront(issuesTableView)
            loadTasks()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            closeDropdown()
            loadTasks()
        }

        // MARK: - Load Tasks
        private func loadTasks() {
            tasks = TaskManager.shared.tasks.filter {
                $0.location.hasPrefix("Business") &&
                $0.status.uppercased() != "COMPLETED"
            }

            applyTasksToRooms()
            issuesTableView.reloadData()
        }
   
        // MARK: - Rooms
        private func applyTasksToRooms() {
            let grouped = Dictionary(grouping: tasks) { $0.location }

            resetAllRooms()

            updateRoom(key: "Business - Room 201", view: room201View, label: room201CountLabel, grouped: grouped)
            updateRoom(key: "Business - Room 202", view: room202View, label: room202CountLabel, grouped: grouped)
            updateRoom(key: "Business - Room 203", view: room203View, label: room203CountLabel, grouped: grouped)
            updateRoom(key: "Business - Room 204", view: room204View, label: room204CountLabel, grouped: grouped)
            updateRoom(key: "Business - Room 205", view: room205View, label: room205CountLabel, grouped: grouped)
            updateRoom(key: "Business - Room 206", view: room206View, label: room206CountLabel, grouped: grouped)

            updateRoom(key: "Business - Meeting Room A", view: meetingRoomAView, label: meetingRoomACountLabel, grouped: grouped)
            updateRoom(key: "Business - Lecture Hall 1", view: lectureHall1View, label: lectureHall1CountLabel, grouped: grouped)
        }

        private func resetAllRooms() {
            let rooms: [(UIView?, UILabel?)] = [
                (room201View, room201CountLabel),
                (room202View, room202CountLabel),
                (room203View, room203CountLabel),
                (room204View, room204CountLabel),
                (room205View, room205CountLabel),
                (room206View, room206CountLabel),
                (meetingRoomAView, meetingRoomACountLabel),
                (lectureHall1View, lectureHall1CountLabel)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let task = tasks[indexPath.row]
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "TaskDetailsVC"
        ) as! TaskDetailsViewController

        vc.task = task

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
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
            dismiss(animated: true)
        }

        @IBAction func itTapped(_ sender: UIButton) {
            closeDropdown()
            let vc = storyboard?.instantiateViewController(withIdentifier: "ITMapViewController") as! ITMapViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }

        @IBAction func businessTapped(_ sender: UIButton) {
            closeDropdown()
            // already here
        }
    }
