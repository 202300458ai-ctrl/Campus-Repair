import UIKit

class MyTasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Outlets
    @IBOutlet weak var inProgress: UIButton!
    @IBOutlet weak var today: UIButton!
    @IBOutlet weak var urgent: UIButton!
    @IBOutlet weak var all: UIButton!

    @IBOutlet weak var inProgressCountLabel: UILabel!
    @IBOutlet weak var todayCountLabel: UILabel!
    @IBOutlet weak var urgentCountLabel: UILabel!
    @IBOutlet weak var allCountLabel: UILabel!

    @IBOutlet weak var header: UIView!
    @IBOutlet weak var tableView: UITableView!
        // 🔥 SINGLE SOURCE OF TRUTH
        var tasks: [Task] {
            TaskManager.shared.tasks
        }

        var filteredTasks: [Task] = []

        enum FilterType { case all, urgent, today, inProgress }
        var currentFilter: FilterType = .all

        // MARK: - Helpers
        func isTodayTask(_ task: Task) -> Bool {
            return task.due.lowercased().contains("today")
        }

        // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = nil
            // Dummy data (only once)
            if TaskManager.shared.tasks.isEmpty {
                TaskManager.shared.tasks = [
                    Task(
                        title: "AC Unit Malfunction",
                        priority: "URGENT",
                        timeAgo: "2h ago",
                        description: "The AC is leaking water continuously. Needs urgent maintenance.",
                        location: "Building A - 205",
                        due: "Today 5 PM",
                        status: "ASSIGNED"
                    ),
                    Task(
                        title: "Projector Not Working",
                        priority: "Medium",
                        timeAgo: "5h ago",
                        description: "Projector in classroom B-102 is not turning on.",
                        location: "Building B - 102",
                        due: "Tomorrow 10 AM",
                        status: "ASSIGNED"
                    ),
                    Task(
                        title: "Broken Chair",
                        priority: "Low",
                        timeAgo: "1d ago",
                        description: "One of the chairs in the library is unstable.",
                        location: "Library - 3rd Floor",
                        due: "This Week",
                        status: "ASSIGNED"
                    ),
                    Task(
                        title: "Network Down",
                        priority: "URGENT",
                        timeAgo: "10m ago",
                        description: "Network outage affecting multiple rooms.",
                        location: "IT Building - 101",
                        due: "Today 3 PM",
                        status: "ASSIGNED"
                    )
                ]
            }

            applyFilter(.all)
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if TaskManager.shared.inProgressTask() != nil {
                applyFilter(.inProgress)
            } else {
                applyFilter(currentFilter)
            }
        }

        // MARK: - TableView
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredTasks.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "taskCell",
                for: indexPath
            ) as! TaskTableViewCell

            let task = filteredTasks[indexPath.row]

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

        // MARK: - Swipe Actions
        func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {

            let task = filteredTasks[indexPath.row]
            let status = task.status.uppercased()
            var actions: [UIContextualAction] = []

            if status == "ASSIGNED" {
                let progress = UIContextualAction(style: .normal, title: "In Progress") {
                    [weak self] _, _, done in
                    self?.updateTaskState(task: task, newState: "IN-PROGRESS")
                    done(true)
                }
                progress.backgroundColor = .systemOrange
                actions.append(progress)
            }

            if status == "IN-PROGRESS" {
                let complete = UIContextualAction(style: .normal, title: "Complete") {
                    [weak self] _, _, done in
                    self?.updateTaskState(task: task, newState: "COMPLETED")
                    done(true)
                }
                complete.backgroundColor = .systemGreen
                actions.append(complete)
            }

            let config = UISwipeActionsConfiguration(actions: actions)
            config.performsFirstActionWithFullSwipe = false
            return config
        }

        // MARK: - Filter Button
        @IBAction func filterTapped(_ sender: UIButton) {

            resetButtons()

            if sender == all {
                applyFilter(.all)
                highlight(all)
            } else if sender == urgent {
                applyFilter(.urgent)
                highlight(urgent)
            } else if sender == today {
                applyFilter(.today)
                highlight(today)
            } else if sender == inProgress {
                applyFilter(.inProgress)
                highlight(inProgress)
            }
        }

        // MARK: - Filtering
        func applyFilter(_ filter: FilterType) {
            currentFilter = filter

            switch filter {
            case .all:
                filteredTasks = tasks.filter { $0.status.uppercased() != "COMPLETED" }

            case .urgent:
                filteredTasks = tasks.filter {
                    $0.priority.uppercased() == "HIGH" && $0.status.uppercased() != "COMPLETED"
                }

            case .today:
                filteredTasks = tasks.filter {
                    isTodayTask($0) && $0.status.uppercased() != "COMPLETED"
                }

            case .inProgress:
                filteredTasks = tasks.filter {
                    $0.status.uppercased() == "IN-PROGRESS"
                }
            }

            updateTaskCounts()
            tableView.reloadData()
        }

        // MARK: - Counts
        func updateTaskCounts() {

            let allCount = tasks.filter { $0.status.uppercased() != "COMPLETED" }.count
            let urgentCount = tasks.filter { $0.priority.uppercased() == "HIGH" && $0.status.uppercased() != "COMPLETED" }.count
            let todayCount = tasks.filter { isTodayTask($0) && $0.status.uppercased() != "COMPLETED" }.count
            let inProgressCount = tasks.filter { $0.status.uppercased() == "IN-PROGRESS" }.count

            allCountLabel.text = "\(allCount)"
            urgentCountLabel.text = "\(urgentCount)"
            todayCountLabel.text = "\(todayCount)"
            inProgressCountLabel.text = "\(inProgressCount)"

            // fade but don't hide
            inProgress.alpha = inProgressCount == 0 ? 0.4 : 1.0
            inProgress.isEnabled = true
        }

        // MARK: - Update Task State
        func updateTaskState(task: Task, newState: String) {

            // ✅ UPDATE GLOBAL SOURCE OF TRUTH
            if let index = TaskManager.shared.tasks.firstIndex(where: {
                $0.title == task.title &&
                $0.location == task.location &&
                $0.due == task.due
            }) {

                let old = TaskManager.shared.tasks[index]

                TaskManager.shared.tasks[index] = Task(
                    title: old.title,
                    priority: old.priority,
                    timeAgo: old.timeAgo,
                    description: old.description,
                    location: old.location,
                    due: old.due,
                    status: newState
                )
            }

            // ✅ No "tasks = ..." here (tasks is get-only)

            // 🔄 Refresh UI
            updateTaskCounts()
            applyFilter(currentFilter)

            // 🔔 Notify Home & other screens (progress bar / completed page)
            NotificationCenter.default.post(
                name: .tasksUpdated,
                object: nil
            )
        }

        // MARK: - UI Helpers
        func resetButtons() {
            [all, urgent, today, inProgress].forEach {
                $0?.backgroundColor = .clear
            }
        }

        func highlight(_ button: UIButton) {
            button.backgroundColor = UIColor.black.withAlphaComponent(0.08)
            button.layer.cornerRadius = 12
        }
    }
