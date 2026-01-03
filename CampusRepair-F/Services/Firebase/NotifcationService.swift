//
//  NotificationService.swift
//  CampusRepair-F
//
//  Created by khalid on 03/01/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class NotificationService {
    
    static let shared = NotificationService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Create Notification
    func createNotification(
        userId: String,
        type: String,
        title: String,
        message: String,
        relatedRequestId: String? = nil,
        priority: String = "normal"
    ) async throws -> String {
        let notificationData: [String: Any] = [
            "userId": userId,
            "type": type,
            "title": title,
            "message": message,
            "isRead": false,
            "relatedRequestId": relatedRequestId as Any,
            "priority": priority,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let documentRef = try await db.collection("notifications").addDocument(data: notificationData)
        return documentRef.documentID
    }
    
    // MARK: - Get User Notifications
    func getUserNotifications(userId: String) async throws -> [AppNotification] {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        let notifications = snapshot.documents.compactMap { document -> AppNotification? in
            var data = document.data()
            data["id"] = document.documentID
            return AppNotification(id: document.documentID, data: data)
        }
        
        return notifications
    }
    
    // MARK: - Mark as Read
    func markAsRead(notificationId: String) async throws {
        try await db.collection("notifications").document(notificationId).updateData([
            "isRead": true,
            "readAt": FieldValue.serverTimestamp()
        ])
    }
    
    // MARK: - Mark All as Read
    func markAllAsRead(userId: String) async throws {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        
        let batch = db.batch()
        for document in snapshot.documents {
            batch.updateData([
                "isRead": true,
                "readAt": FieldValue.serverTimestamp()
            ], forDocument: document.reference)
        }
        
        try await batch.commit()
    }
    
    // MARK: - Delete Notification
    func deleteNotification(notificationId: String) async throws {
        try await db.collection("notifications").document(notificationId).delete()
    }
    
    // MARK: - Delete All Notifications
    func deleteAllNotifications(userId: String) async throws {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
    }
    
    // MARK: - Get Unread Count
    func getUnreadCount(userId: String) async throws -> Int {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        
        return snapshot.documents.count
    }
    
    // MARK: - Notification Types
    enum NotificationType: String {
        case taskAssigned = "task_assigned"
        case taskCompleted = "task_completed"
        case newRequest = "new_request"
        case statusUpdate = "status_update"
        case urgentAlert = "urgent_alert"
        case feedbackRequest = "feedback_request"
        case scheduleReminder = "schedule_reminder"
    }
    
    // MARK: - Create Specific Notifications
    func createTaskAssignedNotification(
        to technicianId: String,
        taskId: String,
        taskTitle: String,
        assignedByName: String
    ) async throws {
        let title = "New Task Assigned"
        let message = "\(assignedByName) assigned you: \(taskTitle)"
        
        _ = try await createNotification(
            userId: technicianId,
            type: NotificationType.taskAssigned.rawValue,
            title: title,
            message: message,
            relatedRequestId: taskId,
            priority: "high"
        )
    }
    
    func createTaskCompletedNotification(
        to studentId: String,
        taskId: String,
        taskTitle: String,
        completedByName: String
    ) async throws {
        let title = "Task Completed"
        let message = "\(completedByName) completed: \(taskTitle)"
        
        _ = try await createNotification(
            userId: studentId,
            type: NotificationType.taskCompleted.rawValue,
            title: title,
            message: message,
            relatedRequestId: taskId
        )
    }
    
    func createNewRequestNotification(
        for adminIds: [String],
        requestId: String,
        requestTitle: String,
        studentName: String
    ) async throws {
        let title = "New Repair Request"
        let message = "\(studentName) submitted: \(requestTitle)"
        
        for adminId in adminIds {
            _ = try await createNotification(
                userId: adminId,
                type: NotificationType.newRequest.rawValue,
                title: title,
                message: message,
                relatedRequestId: requestId,
                priority: "medium"
            )
        }
    }
    
    func createStatusUpdateNotification(
        to userId: String,
        requestId: String,
        requestTitle: String,
        newStatus: String
    ) async throws {
        let title = "Status Updated"
        let message = "\(requestTitle) is now \(newStatus)"
        
        _ = try await createNotification(
            userId: userId,
            type: NotificationType.statusUpdate.rawValue,
            title: title,
            message: message,
            relatedRequestId: requestId
        )
    }
    
    func createUrgentAlertNotification(
        to technicianId: String,
        requestId: String,
        location: String
    ) async throws {
        let title = "Urgent Alert"
        let message = "Urgent repair needed at \(location)"
        
        _ = try await createNotification(
            userId: technicianId,
            type: NotificationType.urgentAlert.rawValue,
            title: title,
            message: message,
            relatedRequestId: requestId,
            priority: "urgent"
        )
    }
}

// MARK: - Real-time Listener Extension
extension NotificationService {
    func listenToUserNotifications(userId: String, completion: @escaping ([AppNotification]) -> Void) -> ListenerRegistration {
        return db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to notifications: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let notifications = documents.compactMap { document -> AppNotification? in
                    var data = document.data()
                    data["id"] = document.documentID
                    return AppNotification(id: document.documentID, data: data)
                }
                
                completion(notifications)
            }
    }
}
