//
//  ITMapViewController.swift
//  tech
//

import UIKit

class ITMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // -------------------------
    // MARK: - Outlets
    // -------------------------
    
   

    
    // Rooms (same structure as Engineering screen)
    @IBOutlet weak var serverRoomCountLabel: UILabel!
    @IBOutlet weak var computerLabCountLabel: UILabel!
    @IBOutlet weak var room105CountLabel: UILabel!
    @IBOutlet weak var room104CountLabel: UILabel!
    @IBOutlet weak var room103CountLabel: UILabel!
    @IBOutlet weak var room102CountLabel: UILabel!
    @IBOutlet weak var room106CountLabel: UILabel!
    @IBOutlet weak var room101CountLabel: UILabel!
    @IBOutlet weak var engineeringButton: UIButton!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var itButton: UIButton!
    @IBOutlet weak var dropdownMenuView: UIView!
    @IBOutlet weak var dropdownArrowButton: UIButton!
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var room101View: UIView!
    @IBOutlet weak var room102View: UIView!
    @IBOutlet weak var room103View: UIView!
    @IBOutlet weak var room104View: UIView!
    @IBOutlet weak var room105View: UIView!
    @IBOutlet weak var room106View: UIView!
    
    @IBOutlet weak var computerLabView: UIView!
    @IBOutlet weak var serverRoomView: UIView!
    @IBOutlet weak var hallwayView: UIView!
    
    // Legend dots
    @IBOutlet weak var highDot: UIView!
    @IBOutlet weak var mediumDot: UIView!
    @IBOutlet weak var completeDot: UIView!
    
    // Issues table
    @IBOutlet weak var issuesTableView: UITableView!

  // MARK: - State

        private var tasks: [Task] = []
        private var isDropdownOpen = false

        // MARK: - Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()

            buildingLabel.text = "IT – Floor 1"

            issuesTableView.delegate = self
            issuesTableView.dataSource = self
            issuesTableView.tableHeaderView = nil

            dropdownMenuView.isHidden = true
            view.bringSubviewToFront(dropdownMenuView)
            view.bringSubviewToFront(issuesTableView)
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
            tasks = TaskManager.shared.tasks.filter {
                $0.location.hasPrefix("IT") &&
                $0.status.uppercased() != "COMPLETED"
            }

            applyTasksToRooms()
            issuesTableView.reloadData()
        }

        // MARK: - Rooms

        private func applyTasksToRooms() {
            let grouped = Dictionary(grouping: tasks) { $0.location }

            resetAllRooms()

            updateRoom(key: "IT - Room 101", view: room101View, label: room101CountLabel, grouped: grouped)
            updateRoom(key: "IT - Room 102", view: room102View, label: room102CountLabel, grouped: grouped)
            updateRoom(key: "IT - Room 103", view: room103View, label: room103CountLabel, grouped: grouped)
            updateRoom(key: "IT - Room 104", view: room104View, label: room104CountLabel, grouped: grouped)
            updateRoom(key: "IT - Room 105", view: room105View, label: room105CountLabel, grouped: grouped)
            updateRoom(key: "IT - Room 106", view: room106View, label: room106CountLabel, grouped: grouped)

            updateRoom(key: "IT - Computer Lab", view: computerLabView, label: computerLabCountLabel, grouped: grouped)
            updateRoom(key: "IT - Server Room", view: serverRoomView, label: serverRoomCountLabel, grouped: grouped)
        }

        private func resetAllRooms() {
            let rooms: [(UIView?, UILabel?)] = [
                (room101View, room101CountLabel),
                (room102View, room102CountLabel),
                (room103View, room103CountLabel),
                (room104View, room104CountLabel),
                (room105View, room105CountLabel),
                (room106View, room106CountLabel),
                (computerLabView, computerLabCountLabel),
                (serverRoomView, serverRoomCountLabel)
            ]

            rooms.forEach {
                $0.0?.backgroundColor = .systemGray5
                $0.1?.text = ""
            }
        }

        private func updateRoom(
            key: String,
            view: UIView?,
            label: UILabel?,
            grouped: [String: [Task]]
        ) {
            guard let roomTasks = grouped[key], !roomTasks.isEmpty else { return }

            label?.text = "\(roomTasks.count)"

            if roomTasks.contains(where: { $0.priority.uppercased() == "HIGH" }) {
                view?.backgroundColor = .systemRed.withAlphaComponent(0.7)
            } else if roomTasks.contains(where: { $0.priority.uppercased() == "MEDIUM" }) {
                view?.backgroundColor = .systemOrange.withAlphaComponent(0.7)
            } else {
                view?.backgroundColor = .systemBlue.withAlphaComponent(0.7)
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

        // MARK: - TableView

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tasks.count
        }

        func tableView(
            _ tableView: UITableView,
            cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "taskCell",
                for: indexPath
            ) as! TaskTableViewCell

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

        // MARK: - Dropdown

        @IBAction func dropdownArrowTapped(_ sender: UIButton) {
            isDropdownOpen.toggle()

            UIView.animate(withDuration: 0.25) {
                self.dropdownArrowButton.transform =
                    self.isDropdownOpen ? CGAffineTransform(rotationAngle: .pi) : .identity
            }

            dropdownMenuView.isHidden = !isDropdownOpen
            view.bringSubviewToFront(dropdownMenuView)
        }

        private func closeDropdown() {
            isDropdownOpen = false
            dropdownMenuView.isHidden = true
            dropdownArrowButton.transform = .identity
        }

        // MARK: - Floor Buttons

        @IBAction func engineeringTapped(_ sender: UIButton) {
            closeDropdown()
            dismiss(animated: true)
        }

        @IBAction func itTapped(_ sender: UIButton) {
            closeDropdown()
        }

        @IBAction func businessTapped(_ sender: UIButton) {
            closeDropdown()
            let vc = storyboard?.instantiateViewController(
                withIdentifier: "BusinessMapViewController"
            ) as! BusinessMapViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
