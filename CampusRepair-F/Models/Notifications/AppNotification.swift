//
//  AppNotification.swift
//  CampusRepair-F
//

import Foundation
import FirebaseFirestore

struct AppNotification {
    let id: String
    let userId: String
    let type: String
    let title: String
    let body: String
    let isRead: Bool
    let relatedRequestID: String?
    let priority: String
    let createdAt: Date?
    
    // Your existing initializer
    init(id: String = "", data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.type = data["type"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.body = data["body"] as? String ?? ""
        self.isRead = data["isRead"] as? Bool ?? false
        self.relatedRequestID = data["relatedRequestID"] as? String
        self.priority = data["priority"] as? String ?? "normal"
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
    }
    
    // New initializer for sending notifications
    init(
        id: String = "",
        userId: String = "",
        type: String,
        title: String,
        body: String,
        isRead: Bool = false,
        relatedRequestID: String? = nil,
        priority: String = "normal",
        createdAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.body = body
        self.isRead = isRead
        self.relatedRequestID = relatedRequestID
        self.priority = priority
        self.createdAt = createdAt
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "userId": userId,
            "type": type,
            "title": title,
            "body": body,
            "isRead": isRead,
            "priority": priority
        ]
        
        if let relatedRequestID = relatedRequestID {
            dict["relatedRequestID"] = relatedRequestID
        }
        
        if let createdAt = createdAt {
            dict["createdAt"] = Timestamp(date: createdAt)
        } else {
            dict["createdAt"] = FieldValue.serverTimestamp()
        }
        
        return dict
    }
}
