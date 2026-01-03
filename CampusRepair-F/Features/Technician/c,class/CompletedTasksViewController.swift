
import UIKit

class CompletedTasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    private var completedTasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // 🔥 AUTO HEIGHT FIX
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140

        tableView.separatorStyle = .none

        loadCompletedTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCompletedTasks()
    }

    private func loadCompletedTasks() {
        completedTasks = TaskManager.shared.tasks.filter {
            $0.status.uppercased() == "COMPLETED"
        }

        print("✅ Completed tasks count:", completedTasks.count)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedTasks.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let task = completedTasks[indexPath.row]

        cell.titleLable.text = task.title
        cell.priorityLabel.text = task.priority.uppercased()
        cell.timeLable.text = task.timeAgo
        cell.descriptionLabel.text = task.description
        cell.locationLabel.text = task.location
        cell.dueLabel.text = task.due
        cell.statusLabel.text = "COMPLETED"

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
}
