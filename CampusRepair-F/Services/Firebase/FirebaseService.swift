//
//  FirebaseService.swift
//  CampusRepair-F
//
//  Created by khalid on 28/12/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private let storage = Storage.storage()
    
    // Auth: Sign Up
    func signUp(email: String, password: String, name: String, role: String, studentID: String?, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let uid = authResult?.user.uid else { return }
            
            let user = User(id: uid, data: ["email": email, "name": name, "role": role, "studentID": studentID ?? "", "createdAt": Timestamp()])
            self.db.collection("users").document(uid).setData(user.toDictionary()) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success(user))
                }
            }
        }
    }
    
    // Auth: Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let uid = authResult?.user.uid else { return }
            self.getUser(uid: uid, completion: completion)
        }
    }
    
    // Auth: Forgot Password
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Get User (for role-based redirect)
    func getUser(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { doc, err in
            if let err = err {
                completion(.failure(err))
            } else if let data = doc?.data() {
                let user = User(id: uid, data: data)
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "No user found", code: 404)))
            }
        }
    }
    
    // Create Request
    func createRequest(request: RepairRequest, images: [Data]? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection("requests").addDocument(data: request.toDictionary()) { err in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let requestID = ref?.documentID else { return }
            
            // Upload images if any
            if let images = images, !images.isEmpty {
                self.uploadImages(for: requestID, images: images) { urls, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.db.collection("requests").document(requestID).updateData(["images": urls ?? []]) { _ in
                            completion(.success(requestID))
                        }
                    }
                }
            } else {
                completion(.success(requestID))
            }
        }
    }
    
    // Get Requests for User (student: createdBy, technician: assignedTo, admin: all)
    func getRequests(for uid: String, role: String, completion: @escaping (Result<[RepairRequest], Error>) -> Void) {
        var query: Query = db.collection("requests")
        if role == "student" {
            query = query.whereField("createdBy", isEqualTo: uid)
        } else if role == "technician" {
            query = query.whereField("assignedTo", isEqualTo: uid)
        } // Admin gets all
        
        query.order(by: "createdAt", descending: true).getDocuments { snapshot, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            let requests = snapshot?.documents.compactMap { doc -> RepairRequest? in
                RepairRequest(id: doc.documentID, data: doc.data())
            } ?? []
            completion(.success(requests))
        }
    }
    
    // Update Request Status (e.g., assign, change status)
    func updateRequest(requestID: String, updates: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("requests").document(requestID).updateData(updates) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                // Optional: Send notification
                if let status = updates["status"] as? String,
                   let createdBy = self.getCreatedByFromUpdates(updates) {
                    self.sendNotification(
                        to: createdBy,
                        title: "Request Update",
                        body: "Your request is now \(status)",
                        type: "status_change",
                        relatedRequestID: requestID
                    )
                }
                completion(.success(()))
            }
        }
    }
    
    // Helper method to extract createdBy from updates or fetch it
    private func getCreatedByFromUpdates(_ updates: [String: Any]) -> String? {
        if let createdBy = updates["createdBy"] as? String {
            return createdBy
        }
        // You might need to fetch the request to get createdBy
        return nil
    }
    
    // Send Notification - FIXED VERSION
    func sendNotification(to uid: String, title: String, body: String, type: String, relatedRequestID: String? = nil) {
        let notification = AppNotification(
            type: type,
            title: title,
            body: body,
            relatedRequestID: relatedRequestID
        )
        
        // Store in the user's notifications collection
        db.collection("users")
            .document(uid)
            .collection("notifications")
            .addDocument(data: notification.toDictionary()) { error in
                if let error = error {
                    print("Error sending notification: \(error.localizedDescription)")
                } else {
                    print("Notification sent successfully to user: \(uid)")
                }
            }
        
        // Also store in the global notifications collection for the NotificationsViewController
        var notificationData = notification.toDictionary()
        notificationData["userId"] = uid
        
        db.collection("notifications")
            .addDocument(data: notificationData) { error in
                if let error = error {
                    print("Error adding to global notifications: \(error.localizedDescription)")
                }
            }
    }
    
    // Get Notifications for User - UPDATED VERSION
    func getNotifications(for uid: String, completion: @escaping (Result<[AppNotification], Error>) -> Void) {
        // Get from global notifications collection (used by NotificationsViewController)
        db.collection("notifications")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                
                let notifs = snapshot?.documents.compactMap { doc -> AppNotification? in
                    var data = doc.data()
                    data["id"] = doc.documentID
                    return AppNotification(id: doc.documentID, data: data)
                } ?? []
                
                completion(.success(notifs))
            }
    }
    
    // Mark Notification as Read
    func markNotificationAsRead(notificationId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Update in global notifications
        db.collection("notifications")
            .document(notificationId)
            .updateData(["isRead": true]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Also update in user's personal notifications if needed
                    completion(.success(()))
                }
            }
    }
    
    // Delete Notification
    func deleteNotification(notificationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("notifications")
            .document(notificationId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // Upload Images to Storage
    private func uploadImages(for requestID: String, images: [Data], completion: @escaping ([String]?, Error?) -> Void) {
        var urls: [String] = []
        let group = DispatchGroup()
        
        for (index, imageData) in images.enumerated() {
            group.enter()
            let ref = storage.reference().child("requests/\(requestID)/image_\(index).jpg")
            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                ref.downloadURL { url, error in
                    if let url = url?.absoluteString {
                        urls.append(url)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(urls, nil)
        }
    }
    
    // Add more functions as needed, e.g., for analytics: query counts
    func getAnalytics(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Example: Count pending requests
        db.collection("requests").whereField("status", isEqualTo: "pending").getDocuments { snapshot, err in
            if let err = err {
                completion(.failure(err))
            } else {
                let count = snapshot?.documents.count ?? 0
                completion(.success(["pendingCount": count])) // Expand for more metrics
            }
        }
    }
}
