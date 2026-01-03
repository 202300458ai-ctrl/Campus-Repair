import UIKit

enum RequestStatus: String {
    case inProgress = "In Progress"
    case pending = "Pending"
    case completed = "Completed"
}

struct Request {
    let title: String
    let location: String
    let description: String
    let timeAgo: String
    let priority: String
    let status: RequestStatus
}

class RequestsViewController: UIViewController,
                              UITableViewDataSource,
                              UITableViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

        // MARK: - Data
        private var requests: [Request] = []
        private var filteredRequests: [Request] = []

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.dataSource = self
            tableView.delegate = self

            // DO NOT register cell in code if using storyboard cell
            // tableView.register(UITableViewCell.self, forCellReuseIdentifier: "requestCell")

            seedData()
            applyFilter(index: 0)
        }

        // MARK: - Dummy Data
        private func seedData() {
            requests = [
                Request(
                    title: "Broken AC Unit",
                    location: "Engineering Building, Room 204",
                    description: "AC not working",
                    timeAgo: "2 days ago",
                    priority: "Urgent",
                    status: .inProgress
                ),
                Request(
                    title: "Projector Issue",
                    location: "Building A, Room 102",
                    description: "Projector not turning on",
                    timeAgo: "1 day ago",
                    priority: "Normal",
                    status: .pending
                ),
                Request(
                    title: "Door Lock Broken",
                    location: "Library Entrance",
                    description: "Main door lock broken",
                    timeAgo: "3 hours ago",
                    priority: "Urgent",
                    status: .pending
                )
            ]
        }

        // MARK: - Segmented Control
        @IBAction func statusChanged(_ sender: UISegmentedControl) {
            applyFilter(index: sender.selectedSegmentIndex)
        }

        private func applyFilter(index: Int) {
            switch index {
            case 0: filteredRequests = requests          // All
            case 1: filteredRequests = requests.filter { $0.status == .inProgress }
            case 2: filteredRequests = requests.filter { $0.status == .pending }
            case 3: filteredRequests = requests.filter { $0.status == .completed }
            default: filteredRequests = requests
            }
            tableView.reloadData()
        }

        // MARK: - TableView DataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredRequests.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            // Use the storyboard cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell") else {
                fatalError("Cell identifier 'requestCell' not found in storyboard")
            }

            let request = filteredRequests[indexPath.row]

            // Main title
            cell.textLabel?.text = request.title
            cell.textLabel?.numberOfLines = 1

            // Subtitle: location + status + time
            cell.detailTextLabel?.text = "\(request.location) • \(request.status.rawValue) • \(request.timeAgo)"
            cell.detailTextLabel?.numberOfLines = 2

            // Priority color
            switch request.priority.lowercased() {
            case "urgent":
                cell.textLabel?.textColor = .systemRed
            default:
                cell.textLabel?.textColor = .label
            }

            // Disable selection
            cell.selectionStyle = .none

            return cell
        }
    }
