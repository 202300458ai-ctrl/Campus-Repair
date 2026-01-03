//
//  TaskModels.swift
//  tech
//
//  Created by Macbook Pro on 11/12/2025.
//

import Foundation
import UIKit

enum TaskPriority: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum TaskStatus: String {
    case new = "New"
    case assigned = "Assigned"
    case inProgress = "In Progress"
    case done = "Done"
}

struct MaintenanceTask {
    let id: String
    let title: String
    let location: String
    let description: String
    let dueText: String
    let priority: TaskPriority
    var status: TaskStatus
}

struct RecentActivity {
    let id: String
    let title: String
    let subtitle: String
    let timeText: String
    let status: TaskStatus
}

struct MaintenanceTechnician {
    let id: String
    let name: String
    let profileImageName: String?
    let unreadNotifications: Int
    
    var assignedCount: Int
    var completedCount: Int
    var highPriorityCount: Int
    var averageResolutionTime: String
}
