//
//  RepairRequest.swift
//  CampusRepair-F
//
//  Created by khalid on 28/12/2025.
//


import Foundation
import FirebaseFirestore

struct RepairRequest {
    let id: String
    let createdBy: String
    let category: String
    let priority: String
    let location: String
    let description: String
    let status: String
    let assignedTo: String?
    let images: [String]
    let feedback: [String: Any]?
    let createdAt: Timestamp
    let updatedAt: Timestamp
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.createdBy = data["createdBy"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.priority = data["priority"] as? String ?? ""
        self.location = data["location"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.status = data["status"] as? String ?? "pending"
        self.assignedTo = data["assignedTo"] as? String
        self.images = data["images"] as? [String] ?? []
        self.feedback = data["feedback"] as? [String: Any]
        self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "createdBy": createdBy,
            "category": category,
            "priority": priority,
            "location": location,
            "description": description,
            "status": status,
            "images": images,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
        if let assignedTo = assignedTo { dict["assignedTo"] = assignedTo }
        if let feedback = feedback { dict["feedback"] = feedback }
        return dict
    }
}