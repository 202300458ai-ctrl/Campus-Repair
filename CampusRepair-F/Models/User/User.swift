//
//  User.swift
//  CampusRepair-F
//
//  Created by khalid on 28/12/2025.
//


import Foundation
import FirebaseFirestore

struct User {
    let id: String
    let email: String
    let name: String
    let role: String
    let studentID: String?
    let phone: String?
    let createdAt: Timestamp
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.email = data["email"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.role = data["role"] as? String ?? ""
        self.studentID = data["studentID"] as? String
        self.phone = data["phone"] as? String
        self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "email": email,
            "name": name,
            "role": role,
            "createdAt": createdAt
        ]
        if let studentID = studentID { dict["studentID"] = studentID }
        if let phone = phone { dict["phone"] = phone }
        return dict
    }
}