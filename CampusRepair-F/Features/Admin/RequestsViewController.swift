import UIKit

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnsStatus: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var problemLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priorityButton: UIButton!
    
    @IBOutlet weak var statusButton: UIButton!
    
    var requests: [Request] = []
    var filteredRequests: [Request] = []

    enum FilterType {
        case all, inProgress, pending, completed
    }

    var currentFilter: FilterType = .all

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        seedData()
        applyFilter(.all)
    }

    // MARK: - Dummy Data
    func seedData() {
        requests = [
            Request(
                title: "Broken AC Unit",
                location: "Engineering Building, Room 204",
                description: "Air conditioning not working, room temperature is very high",
                timeAgo: "Submitted 2 days ago",
                priority: "High",
                status: "In Progress"
            )
        ]
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRequests.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "requestCell",
            for: indexPath
        ) as! RequestTableViewCell

        let request = filteredRequests[indexPath.row]
        cell.taskTitleLabel.text = request.title
        cell.locationLabel.text = request.location
        cell.problemLabel.text = request.description
        cell.timeLabel.text = request.timeAgo
        cell.priorityButton.setTitle(request.priority, for: .normal)
        cell.statusButton.setTitle(request.status, for: .normal)

        stylePriority(cell.priorityButton, priority: request.priority)
        styleStatus(cell.statusButton, status: request.status)

        return cell
    }

    // MARK: - Segmented Control
    @IBAction func statusChanged(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0: applyFilter(.all)
        case 1: applyFilter(.inProgress)
        case 2: applyFilter(.pending)
        case 3: applyFilter(.completed)
        default: break
        }
    }

    // MARK: - Filtering
    func applyFilter(_ filter: FilterType) {
        currentFilter = filter

        switch filter {
        case .all:
            filteredRequests = requests
        case .inProgress:
            filteredRequests = requests.filter { $0.status == "In Progress" }
        case .pending:
            filteredRequests = requests.filter { $0.status == "Pending" }
        case .completed:
            filteredRequests = requests.filter { $0.status == "Completed" }
        }

        tableView.reloadData()
    }

    // MARK: - Styling
    func stylePriority(_ button: UIButton, priority: String) {
        button.layer.cornerRadius = 8
        button.clipsToBounds = true

        switch priority.uppercased() {
        case "HIGH":
            button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            button.setTitleColor(.systemRed, for: .normal)
        case "MEDIUM":
            button.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            button.setTitleColor(.systemOrange, for: .normal)
        default:
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            button.setTitleColor(.systemBlue, for: .normal)
        }
    }

    func styleStatus(_ button: UIButton, status: String) {
        button.layer.cornerRadius = 8
        button.clipsToBounds = true

        switch status.uppercased() {
        case "IN PROGRESS":
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        case "PENDING":
            button.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
        case "COMPLETED":
            button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        default:
            button.backgroundColor = .clear
        }
    }
}
