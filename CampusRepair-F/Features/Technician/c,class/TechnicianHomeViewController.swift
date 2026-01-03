//
//  HomeViewController.swift
//  tech
//
//  Created by Macbook Pro on 28/11/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TechnicianHomeViewController: UIViewController {

    // MARK: - Header Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var technicianIdLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var completedCountLabel: UILabel!
    
    @IBOutlet weak var highPriorityCountLabel: UILabel!
    @IBOutlet weak var assignedCountLabel: UILabel!
    // MARK: - Stats Card Outlets
    @IBOutlet weak var statsCardView: UIView!
    @IBOutlet weak var statsCardView2: UIView!
    @IBOutlet weak var statsCardView3: UIView!
    @IBOutlet weak var statsCardView4: UIView!
    
    @IBOutlet weak var assignedTitleLabel: UILabel!
    @IBOutlet weak var completedTitleLabel: UILabel!
    @IBOutlet weak var highPriorityTitleLabel: UILabel!
    @IBOutlet weak var resolutionTitleLabel: UILabel!
    
    // MARK: - TableView
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var todayProgressView: UIProgressView!
    // MARK: - Data Models
    @IBOutlet weak var todayProgressLabel: UILabel!
    
    // Firebase
    private let db = Firestore.firestore()
    private var recentActivities: [RecentActivity] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAllStats()
    }

    // MARK: - Setup
    private func setupUI() {
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .gray
        profileImageView.layer.cornerRadius = 22
        profileImageView.clipsToBounds = true
        
        [statsCardView, statsCardView2, statsCardView3, statsCardView4].forEach {
            $0?.layer.cornerRadius = 16
            $0?.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            $0?.layer.shadowOpacity = 0.3
            $0?.layer.shadowOffset = CGSize(width: 0, height: 3)
            $0?.layer.shadowRadius = 6
        }

        todayProgressView.layer.cornerRadius = 6
        todayProgressView.clipsToBounds = true

        assignedTitleLabel.text = "Assigned Tasks"
        completedTitleLabel.text = "Completed"
        highPriorityTitleLabel.text = "High Priority"
        resolutionTitleLabel.text = "Resolution Time"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    private func loadData() {
        // Set temporary data
        nameLabel.text = "Hi, Technician"
        technicianIdLabel.text = "Loading ID..."
        
        // Fetch from Firebase
        fetchUserData()
        fetchTasks()
    }
    
    // MARK: - Firebase Simple Fetch
    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    if let name = data["name"] as? String {
                        self.nameLabel.text = "Hi, \(name)"
                    }
                    
                    if let techId = data["technicianId"] as? String {
                        self.technicianIdLabel.text = "ID: \(techId)"
                    } else if let email = data["email"] as? String {
                        self.technicianIdLabel.text = "Email: \(email)"
                    }
                }
            }
        }
    }
    
    private func fetchTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("requests")
            .whereField("assignedTo", isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                // Update stats
                self.updateStats(documents: documents)
                
                // Update recent activities
                self.updateRecentActivities(documents: documents)
                
                // Update TaskManager
                self.updateTaskManager(documents: documents)
            }
    }
    
    private func updateStats(documents: [QueryDocumentSnapshot]) {
        var assigned = 0
        var completed = 0
        var highPriority = 0
        
        for doc in documents {
            let data = doc.data()
            let status = (data["status"] as? String ?? "").lowercased()
            let priority = (data["priority"] as? String ?? "").lowercased()
            
            if status == "completed" {
                completed += 1
            } else {
                assigned += 1
                if priority == "high" {
                    highPriority += 1
                }
            }
        }
        
        DispatchQueue.main.async {
            self.assignedCountLabel.text = "\(assigned)"
            self.completedCountLabel.text = "\(completed)"
            self.highPriorityCountLabel.text = "\(highPriority)"
        }
    }
    
    private func updateRecentActivities(documents: [QueryDocumentSnapshot]) {
        recentActivities.removeAll()
        
        // Take only first 3 documents for recent activities
        let recentDocs = Array(documents.prefix(3))
        
        for (index, doc) in recentDocs.enumerated() {
            let data = doc.data()
            
            let title = data["title"] as? String ?? "Untitled"
            let location = data["location"] as? String ?? "Unknown"
            let status = (data["status"] as? String ?? "assigned").lowercased()
            
            // Create simple RecentActivity
            let activity = RecentActivity(
                id: "A\(index + 1)",
                title: title,
                subtitle: location,
                timeText: "Today",
                status: status == "completed" ? .done : (status == "in-progress" ? .inProgress : .assigned)
            )
            
            recentActivities.append(activity)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func updateTaskManager(documents: [QueryDocumentSnapshot]) {
        // Clear existing tasks
        TaskManager.shared.tasks.removeAll()
        
        for doc in documents {
            let data = doc.data()
            
            // Map Firestore fields to your Task struct fields
            let title = data["title"] as? String ?? ""
            let description = data["description"] as? String ?? ""
            let priority = data["priority"] as? String ?? "low"
            let status = data["status"] as? String ?? "assigned"
            let location = data["location"] as? String ?? ""
            let due = data["due"] as? String ?? "Today"
            
            // Provide a value for timeAgo (fallback if not present)
            let timeAgo = data["timeAgo"] as? String ?? "Just now"
            
            // Create Task object matching Task struct initializer
            let task = Task(
                title: title,
                priority: priority,
                timeAgo: timeAgo,
                description: description,
                location: location,
                due: due,
                status: status
            )
            
            TaskManager.shared.tasks.append(task)
        }
        
        DispatchQueue.main.async {
            self.updateAllStats()
        }
    }

    // MARK: - MASTER UPDATE
    private func updateAllStats() {
        updateTaskStats()
        updateTodaysProgress()
    }

    // MARK: - Task Stats Logic (use TaskManager)
    private func updateTaskStats() {
        let tasks = TaskManager.shared.tasks

        let assigned = tasks.filter { $0.status.uppercased() != "COMPLETED" }.count
        let completed = tasks.filter { $0.status.uppercased() == "COMPLETED" }.count
        let highPriority = tasks.filter {
            $0.priority.uppercased() == "HIGH" &&
            $0.status.uppercased() != "COMPLETED"
        }.count

        assignedCountLabel.text = "\(assigned)"
        completedCountLabel.text = "\(completed)"
        highPriorityCountLabel.text = "\(highPriority)"
    }

    // MARK: - Today Progress
    private func updateTodaysProgress() {
        let tasks = TaskManager.shared.tasks

        let todayTasks = tasks.filter { $0.due.lowercased().contains("today") }
        let completedToday = todayTasks.filter {
            $0.status.uppercased() == "COMPLETED"
        }

        if todayTasks.isEmpty {
            todayProgressLabel.text = "No tasks today 🎉"
            todayProgressView.progress = 0
        } else {
            todayProgressLabel.text = "\(completedToday.count) of \(todayTasks.count) completed"
            todayProgressView.progress =
                Float(completedToday.count) / Float(todayTasks.count)
        }
    }

    // MARK: - Actions
    @IBAction func completedTasksTapped(_ sender: UIButton) {
        print("Completed tasks tapped")
    }
    
    @IBAction func reportIssueTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ReportIssueVC")
        present(vc, animated: true)
    }

    @IBAction func continueTaskTapped(_ sender: UIButton) {
        tabBarController?.selectedIndex = 2
    }
}

// MARK: - TableView
extension TechnicianHomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentActivities.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActivityCell",
            for: indexPath
        ) as! ActivityTableViewCell

        cell.configure(with: recentActivities[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
