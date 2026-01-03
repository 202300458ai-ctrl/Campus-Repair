//
//  studentMyRequestsVC.swift
//  CampusRepair-F
//
//  Created by khalid on 30/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class studentMyRequestsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var currentRequestLabel: UILabel!
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var doneRequestLabel: UILabel!
    @IBOutlet weak var pendingRequestLabel: UILabel!
    @IBOutlet weak var totalRequestLabel: UILabel!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    var selectedRequestId: String? // Store selected request ID

    
    var allRequests: [[String: Any]] = []
    var filteredRequests: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMyRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyRequests()
    }
    
       
    func fetchMyRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("requests")
            .whereField("createdBy", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                self.allRequests = snapshot?.documents.map { document in
                    var data = document.data()
                    data["id"] = document.documentID
                    return data
                } ?? []
                
                self.updateLabels()
                self.filterRequests()
            }
    }
    
    func updateLabels() {
        let total = allRequests.count
        let pending = allRequests.filter { $0["status"] as? String == "pending" }.count
        let current = allRequests.filter { $0["status"] as? String == "processing" }.count
        let done = allRequests.filter { $0["status"] as? String == "completed" }.count
        
        totalRequestLabel.text = "\(total)"
        pendingRequestLabel.text = "\(pending)"
        currentRequestLabel.text = "\(current)"
        doneRequestLabel.text = "\(done)"
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        filterRequests()

    }
    
    
    func filterRequests() {
        switch categorySegment.selectedSegmentIndex {
        case 0: // All
            filteredRequests = allRequests
        case 1: // Pending
            filteredRequests = allRequests.filter { $0["status"] as? String == "pending" }
        case 2: // Current
            filteredRequests = allRequests.filter { $0["status"] as? String == "processing" }
        case 3: // Done
            filteredRequests = allRequests.filter { $0["status"] as? String == "completed" }
        default:
            filteredRequests = allRequests
        }
        
        requestTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestCell", for: indexPath) as? MyRequestCell else {
            return UITableViewCell()
        }
        
        let request = filteredRequests[indexPath.row]
        cell.configure(with: request)
        
        // Store request ID for detail view
        cell.requestId = request["id"] as? String
        cell.viewDetailButton.tag = indexPath.row
        cell.viewDetailButton.addTarget(self, action: #selector(viewDetailButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let request = filteredRequests[indexPath.row]
            selectedRequestId = request["id"] as? String
            
            // Perform segue
            performSegue(withIdentifier: "showTaskDetails", sender: self)
    }
    
    @objc func viewDetailButtonTapped(_ sender: UIButton) {
            // Get the index path from the button's tag
            let indexPath = IndexPath(row: sender.tag, section: 0)
            let request = filteredRequests[indexPath.row]
            selectedRequestId = request["id"] as? String
            
            // Perform segue
            performSegue(withIdentifier: "showTaskDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showTaskDetails",
               let detailVC = segue.destination as? taskDetailsViewController,
               let requestId = selectedRequestId {
                detailVC.requestId = requestId
            }
    }
}

class MyRequestCell: UITableViewCell {
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestLocation: UILabel!
    @IBOutlet weak var requestDescription: UILabel!
    @IBOutlet weak var viewDetailButton: UIButton!
    
    var requestId: String?
    
    func configure(with request: [String: Any]) {
        requestTitle.text = request["title"] as? String ?? request["description"] as? String ?? "No Title"
        requestLocation.text = request["location"] as? String ?? "No Location"
        
        // Truncate description
        let description = request["description"] as? String ?? "No description"
        requestDescription.text = description.count > 60 ? String(description.prefix(60)) + "..." : description
        
        // Store request ID
        requestId = request["id"] as? String
    }
    
}
