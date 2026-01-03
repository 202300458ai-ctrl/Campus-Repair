//
//  NotificationsViewController.swift
//  CampusRepair-F
//
//  Created by khalid on 02/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class NotificationsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
   
    // MARK: - Properties
    private var notifications: [AppNotification] = []
    private var listener: ListenerRegistration?
    private let firebaseService = FirebaseService.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        // DO NOT register the cell class here if using storyboard prototype
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    private func setupNavigationBar() {
        title = "Notifications"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Add clear all button
        if !notifications.isEmpty {
            let clearButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllNotifications))
            navigationItem.rightBarButtonItem = clearButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Firebase Methods
    private func loadNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showLoginAlert()
            return
        }
        
        // Listen for real-time updates from global notifications collection
        let db = Firestore.firestore()
        listener = db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    self.showError(message: "Failed to load notifications")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.notifications = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.updateEmptyState()
                    }
                    return
                }
                
                // Parse notifications using AppNotification model
                self.notifications = documents.compactMap { document -> AppNotification? in
                    var data = document.data()
                    data["id"] = document.documentID
                    // If the notification has a "message" field, copy it to "body"
                    if let message = data["message"] as? String {
                        data["body"] = message
                    }
                    return AppNotification(id: document.documentID, data: data)
                }
                
                // Sort by unread first, then by date
                self.notifications.sort {
                    if $0.isRead != $1.isRead {
                        return !$0.isRead && $1.isRead
                    }
                    if let date1 = $0.createdAt, let date2 = $1.createdAt {
                        return date1 > date2
                    }
                    return false
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateEmptyState()
                    self.updateBadgeCount()
                    self.setupNavigationBar()
                }
            }
    }
    
    private func markAsRead(notificationId: String) {
        firebaseService.markNotificationAsRead(notificationId: notificationId, userId: Auth.auth().currentUser?.uid ?? "") { error in
           
        }
    }
    
    private func deleteNotification(notificationId: String) {
        firebaseService.deleteNotification(notificationId: notificationId) { [weak self] error in
            
        }
    }
    
    // MARK: - Actions
    @objc private func clearAllNotifications() {
        let alert = UIAlertController(
            title: "Clear All Notifications",
            message: "Are you sure you want to clear all notifications? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { [weak self] _ in
            self?.deleteAllNotifications()
        }))
        
        present(alert, animated: true)
    }
    
    private func deleteAllNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                let batch = db.batch()
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error deleting all notifications: \(error.localizedDescription)")
                            self.showError(message: "Failed to clear notifications")
                        } else {
                            self.notifications.removeAll()
                            self.tableView.reloadData()
                            self.updateEmptyState()
                            self.setupNavigationBar()
                            self.updateBadgeCount()
                        }
                    }
                }
            }
    }
    
    // MARK: - Helper Methods
    private func updateEmptyState() {
        let isEmpty = notifications.isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func updateBadgeCount() {
        let unreadCount = notifications.filter { !$0.isRead }.count
        
        if unreadCount > 0 {
            tabBarItem.badgeValue = "\(unreadCount)"
        } else {
            tabBarItem.badgeValue = nil
        }
        
        // Update app icon badge
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(
            title: "Login Required",
            message: "Please login to view notifications",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // SAFE: Use conditional casting and handle failure
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as? NotificationCell {
            let notification = notifications[indexPath.row]
            cell.configure(with: notification)
            return cell
        }
        
        // Fallback if cell doesn't exist
        print("ERROR: Could not dequeue NotificationCell. Check storyboard identifier.")
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "fallback")
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.title
        cell.detailTextLabel?.text = notification.body
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        
        // Mark as read if unread
        if !notification.isRead {
            markAsRead(notificationId: notification.id)
        }
        
        // Navigate based on notification type if needed
        if let requestId = notification.relatedRequestID {
            print("Navigate to request: \(requestId)")
            // Implement navigation to request detail here
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completion in
            guard let self = self else { return }
            
            let notification = self.notifications[indexPath.row]
            self.notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.deleteNotification(notificationId: notification.id)
            self.updateEmptyState()
            self.updateBadgeCount()
            
            completion(true)
        }
        
        let readAction = UIContextualAction(style: .normal, title: "Mark Read") { [weak self] action, view, completion in
            guard let self = self else { return }
            
            let notification = self.notifications[indexPath.row]
            if !notification.isRead {
                self.markAsRead(notificationId: notification.id)
            }
            
            completion(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        readAction.backgroundColor = UIColor.systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, readAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - NotificationCell Class (in same file)
class NotificationCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Properties
    private var notification: AppNotification?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryImageView.image = nil
        titleLabel.text = nil
        messageLabel.text = nil
        timeLabel.text = nil
    }
    
    // MARK: - Setup
    private func setupViews() {
        categoryImageView.tintColor = UIColor.systemBlue
        categoryImageView.contentMode = .scaleAspectFit
        
        // Configure labels
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        timeLabel.textColor = .gray
    }
    
    // MARK: - Configuration
    func configure(with notification: AppNotification) {
        self.notification = notification
        
        // Set icon based on type
        let iconName = getIconName(for: notification.type)
        categoryImageView.image = UIImage(systemName: iconName)
        
        // Set text
        titleLabel.text = notification.title
        messageLabel.text = notification.body
        
        // Format time
        if let createdAt = notification.createdAt {
            timeLabel.text = formatTimeAgo(from: createdAt)
        } else {
            timeLabel.text = "Just now"
        }
    }
    
    private func getIconName(for type: String) -> String {
        switch type {
        case "task_assigned", "status_change":
            return "wrench.and.screwdriver"
        case "task_completed":
            return "checkmark.circle"
        case "new_request":
            return "bell.badge"
        case "status_update":
            return "arrow.triangle.2.circlepath"
        case "urgent_alert":
            return "exclamationmark.triangle"
        default:
            return "bell"
        }
    }
    
    private func formatTimeAgo(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}
