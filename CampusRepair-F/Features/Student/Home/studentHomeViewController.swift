//
//  studentHomeViewController.swift
//  CampusRepair-F
//
//  Created by khalid on 28/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class studentHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var completedImg: UIImageView!
    @IBOutlet weak var currentImg: UIImageView!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var recentRequestTable: UITableView!
    @IBOutlet weak var needHelpView: UIView!
    @IBOutlet weak var pendingImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var requests: [[String: Any]] = []

    
    override func viewDidLoad() {
        fetchMyRequests()
        
        super.viewDidLoad()
        recentRequestTable.delegate = self
        recentRequestTable.dataSource = self
        getUserName()
        needHelpView.layer.cornerRadius = 10
        profilePicImgView.layer.cornerRadius = 50
        pendingImg.layer.cornerRadius = 10
        currentImg.layer.cornerRadius = 10
        completedImg.layer.cornerRadius = 10
        
        recentRequestTable.reloadData()
        
    
        
    }
    
    func getUserName() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error getting user: \(error)")
                return
            }
            
            if let data = snapshot?.data(),
               let name = data["name"] as? String {
                self.nameLabel.text = "\(name)"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "recentActCell", for: indexPath) as? studentRecentActCell else {
                return UITableViewCell()
            }
            
            let request = requests[indexPath.row]
            cell.configure(with: request)
            return cell
    }
    
    func timeAgoSince(_ date: Date) -> String {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
            
            if let minutes = components.minute, minutes < 60 {
                return "\(minutes) mins ago"
            } else if let hours = components.hour, hours < 24 {
                return "\(hours) hours ago"
            } else if let days = components.day {
                return "\(days) days ago"
            }
            
            return "Recently"
        }
    
    func fetchMyRequests() {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            Firestore.firestore().collection("requests")
                .whereField("createdBy", isEqualTo: userId)
                .order(by: "updatedAt", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching requests: \(error)")
                        return
                    }
                    
                    self.requests = snapshot?.documents.map { document in
                        var data = document.data()
                        data["id"] = document.documentID
                        return data
                    } ?? []
                    
                    self.recentRequestTable.reloadData()
                }
        }
    
    @IBAction func CreateRequestClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "studentCreateRequest", bundle: nil)
            if let createVC = storyboard.instantiateViewController(withIdentifier: "CreateRequest") as? studentCreateRequestVC {
                navigationController?.pushViewController(createVC, animated: true)
            } else {
                print("❌ Failed to load create request view controller")
                print("Storyboard name: studentCreateRequest")
                print("ViewController ID: StudentCreateRequestViewController")
            }
    }
    
}

class studentRecentActCell: UITableViewCell {
    @IBOutlet weak var requestLastUpdated: UILabel!
    @IBOutlet weak var requestLocation: UILabel!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var recentActImgView: UIImageView!
    
    // Track category for selection
    private var currentCategoryColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style the cell
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12
        self.contentView.clipsToBounds = true
        
        // Style image view
        recentActImgView.layer.cornerRadius = 8
        recentActImgView.clipsToBounds = true
        recentActImgView.backgroundColor = .white
        recentActImgView.contentMode = .center
        
        // Remove default selection style
        self.selectionStyle = .none
    }
    
    func configure(with request: [String: Any]) {
        // Title
        requestTitle.text = request["title"] as? String ?? "No Title"
        
        // Location
        requestLocation.text = request["location"] as? String ?? "No Location"
        
        // Last Updated Time
        if let timestamp = request["updatedAt"] as? Timestamp {
            requestLastUpdated.text = timeAgoSince(timestamp.dateValue())
        } else {
            requestLastUpdated.text = "Just now"
        }
        
        // Set image and color based on category
        let category = request["category"] as? String ?? "general"
        recentActImgView.image = getImageForCategory(category)
        
        let color = getColorForCategory(category)
        currentCategoryColor = color
        applyCategoryColor(color)
    }
    
    func getImageForCategory(_ category: String) -> UIImage {
        switch category {
        case "hvac":
            return UIImage(systemName: "thermometer")!
        case "electrical":
            return UIImage(systemName: "bolt.fill")!
        case "network":
            return UIImage(systemName: "wifi")!
        case "plumbing":
            return UIImage(systemName: "drop.fill")!
        default:
            return UIImage(systemName: "wrench.fill")!
        }
    }
    
    func getColorForCategory(_ category: String) -> UIColor {
        switch category {
        case "hvac":
            return UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0) // Blue
        case "electrical":
            return UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.0) // Yellow
        case "network":
            return UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0) // Green
        case "plumbing":
            return UIColor(red: 0.40, green: 0.30, blue: 0.80, alpha: 1.0) // Purple
        default:
            return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) // Gray
        }
    }
    
    func applyCategoryColor(_ color: UIColor) {
        let backgroundColor = color.withAlphaComponent(0.25)
        
        // Set background with 25% opacity
        self.contentView.backgroundColor = backgroundColor
        
        // Tint the image with full color
        recentActImgView.tintColor = color
        
        // Add subtle border
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = color.withAlphaComponent(0.1).cgColor
    }
    
    // Add visual feedback on selection
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted, let color = currentCategoryColor {
            UIView.animate(withDuration: 0.1) {
                self.contentView.backgroundColor = color.withAlphaComponent(0.4)
            }
        } else if let color = currentCategoryColor {
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = color.withAlphaComponent(0.25)
            }
        }
    }
    
    func timeAgoSince(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let minutes = components.minute, minutes < 60 {
            return minutes == 1 ? "1 min ago" : "\(minutes) mins ago"
        } else if let hours = components.hour, hours < 24 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let days = components.day {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        }
        
        return "Recently"
    }
}
