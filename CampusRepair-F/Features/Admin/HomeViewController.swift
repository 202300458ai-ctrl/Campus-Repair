//
//  HomeViewController.swift
//  Admin
//
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    @IBOutlet weak var prioReq2Priority: UILabel!
    @IBOutlet weak var prioReq2userName: UILabel!
    @IBOutlet weak var prioReq2Location: UILabel!
    @IBOutlet weak var prioReq2Title: UILabel!
    @IBOutlet weak var prioReq1Priority: UILabel!
    @IBOutlet weak var prioReq1Name: UILabel!
    @IBOutlet weak var prioReq1Location: UILabel!
    @IBOutlet weak var prioReq1Title: UILabel!
    @IBOutlet weak var manageTech: UIButton!
    @IBOutlet weak var viewAllReq: UIButton!
    @IBOutlet weak var urgent: UITextField!
    @IBOutlet weak var inProgressTask: UITextField!
    @IBOutlet weak var completedTask: UITextField!
    @IBOutlet weak var totalRequests: UITextField!
    @IBOutlet weak var notification: UIImageView!
    @IBOutlet weak var photoAdmin: UIImageView!
    @IBOutlet weak var schedule: UIButton!
    @IBOutlet weak var report: UIButton!
    @IBOutlet weak var tech: UIButton!
    @IBOutlet weak var assignTask: UIButton!
    
    // Firebase
    private let db = Firestore.firestore()
    private var requests: [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAdminPhoto()
        fetchDashboardData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when view appears
        fetchDashboardData()
    }
    
    func setupAdminPhoto() {
        photoAdmin.image = UIImage(named: "admin_photo")
        photoAdmin.layer.cornerRadius = photoAdmin.frame.width / 2
        photoAdmin.clipsToBounds = true
        photoAdmin.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        photoAdmin.addGestureRecognizer(tap)
    }
    
    @objc func changePhotoTapped() {
        print("Photo tapped")
    }
    
    // MARK: - Firebase Data Fetching
    
    func fetchDashboardData() {
        // Fetch all requests
        db.collection("requests")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching requests: \(error)")
                    return
                }
                
                // Clear existing data
                self.requests.removeAll()
                
                // Process each document
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    let request = Request(
                        id: document.documentID,
                        title: data["title"] as? String ?? "No Title",
                        description: data["description"] as? String ?? "",
                        category: data["category"] as? String ?? "general",
                        priority: data["priority"] as? String ?? "low",
                        location: data["location"] as? String ?? "Unknown Location",
                        status: data["status"] as? String ?? "pending",
                        createdBy: data["createdBy"] as? String ?? "",
                        createdByName: data["createdByName"] as? String ?? "Unknown User",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    self.requests.append(request)
                }
                
                // Update UI with fetched data
                self.updateDashboardCounts()
                self.updatePriorityRequests()
            }
    }
    
    // MARK: - Update UI
    
    func updateDashboardCounts() {
        // Update counts
        totalRequests.text = "\(requests.count)"
        
        let completedCount = requests.filter { $0.status.lowercased() == "completed" }.count
        let inProgressCount = requests.filter { $0.status.lowercased() == "in-progress" }.count
        let urgentCount = requests.filter { $0.priority.lowercased() == "high" }.count
        
        completedTask.text = "\(completedCount)"
        inProgressTask.text = "\(inProgressCount)"
        urgent.text = "\(urgentCount)"
        
        // Make text fields uneditable and center text
        [totalRequests, completedTask, inProgressTask, urgent].forEach { textField in
            textField?.isUserInteractionEnabled = false
            textField?.textAlignment = .center
        }
    }
    
    func updatePriorityRequests() {
        // Get high priority pending requests (most recent first)
        let highPriorityRequests = requests
            .filter { $0.priority.lowercased() == "high" && $0.status.lowercased() == "pending" }
            .sorted { $0.createdAt > $1.createdAt } // Most recent first
        
        // Update first priority request
        if let firstRequest = highPriorityRequests.first {
            prioReq1Title.text = firstRequest.title
            prioReq1Location.text = firstRequest.location
            prioReq1Name.text = firstRequest.createdByName
            prioReq1Priority.text = firstRequest.priority.uppercased()
            prioReq1Priority.textColor = .red
        } else {
            prioReq1Title.text = "No urgent requests"
            prioReq1Location.text = "-"
            prioReq1Name.text = "-"
            prioReq1Priority.text = "-"
        }
        
        // Update second priority request
        if highPriorityRequests.count > 1 {
            let secondRequest = highPriorityRequests[1]
            prioReq2Title.text = secondRequest.title
            prioReq2Location.text = secondRequest.location
            prioReq2userName.text = secondRequest.createdByName
            prioReq2Priority.text = secondRequest.priority.uppercased()
            prioReq2Priority.textColor = .red
        } else {
            prioReq2Title.text = "No urgent requests"
            prioReq2Location.text = "-"
            prioReq2userName.text = "-"
            prioReq2Priority.text = "-"
        }
    }
    
    // MARK: - Simple Request Model
    
    struct Request {
        let id: String
        let title: String
        let description: String
        let category: String
        let priority: String
        let location: String
        let status: String
        let createdBy: String
        let createdByName: String
        let createdAt: Date
        let updatedAt: Date
    }
    
    // MARK: - IBActions (Connect these in Storyboard)
    
    @IBAction func assignTaskNew(_ sender: Any) {
        performSegue(withIdentifier: "goToAssignTask", sender: self)
        print("assign tapped")
        let storyboard = UIStoryboard(name: "AdminMain", bundle: nil)
        if let assignVC = storyboard.instantiateViewController(withIdentifier: "AssignTaskViewController") as? UIViewController {
            present(assignVC, animated: true, completion: nil)

            // Use assignVC
        }



    }

    
    @IBAction func techniciansTapped(_ sender: UIButton) {
        print("Technicians tapped")
        // Will navigate to technicians screen
    }
    
    @IBAction func reportsTapped(_ sender: UIButton) {
        print("Reports tapped")
        // Will navigate to reports screen
    }
    
    @IBAction func scheduleTapped(_ sender: UIButton) {
        print("Schedule tapped")
        // Will navigate to schedule screen
    }
    
    @IBAction func viewAllRequestsTapped(_ sender: UIButton) {
        print("View All Requests tapped")
        // Will navigate to all requests screen
    }
    
    @IBAction func manageTechniciansTapped(_ sender: UIButton) {
        print("Manage Technicians tapped")
        // Will navigate to manage technicians screen
    }
}
