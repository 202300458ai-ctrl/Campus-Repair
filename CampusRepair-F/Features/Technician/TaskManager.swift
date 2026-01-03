//
//  TaskManager.swift
//  tech
//
//  Created by Macbook Pro on 17/12/2025.
//
import Foundation

final class TaskManager {

    static let shared = TaskManager()
    private init() {}

    // 🔥 SINGLE SOURCE OF TRUTH
    var tasks: [Task] = []

    // MARK: - Seed Initial Tasks (CALL ONCE)
    func loadInitialTasks() {
        tasks = [

            // 🏗 ENGINEERING – FLOOR 3
            Task(
                title: "AC Unit Malfunction",
                priority: "LOW",
                timeAgo: "2h ago",
                description: "AC leaking water continuously.",
                location: "Engineering - Room 301",
                due: "Today 5 PM",
                status: "ASSIGNED"
            ),

            Task(
                title: "Projector Not Working",
                priority: "MEDIUM",
                timeAgo: "4h ago",
                description: "Projector not turning on.",
                location: "Engineering - Room 305",
                due: "Tomorrow 10 AM",
                status: "ASSIGNED"
            ),

            Task(
                title: "Server Overheating",
                priority: "HIGH",
                timeAgo: "30m ago",
                description: "Server temperature critical.",
                location: "Engineering - Server Room",
                due: "Today",
                status: "IN-PROGRESS"
            ),

            // 🖥 IT – FLOOR 1
            Task(
                title: "Network Down",
                priority: "HIGH",
                timeAgo: "1h ago",
                description: "No network connectivity.",
                location: "IT - Room 101",
                due: "Today",
                status: "ASSIGNED"
            ),

            Task(
                title: "PC Not Booting",
                priority: "MEDIUM",
                timeAgo: "45m ago",
                description: "PC stuck on boot screen.",
                location: "IT - Computer Lab",
                due: "Today",
                status: "ASSIGNED"
            ),

            // 🏢 BUSINESS – FLOOR 2
            Task(
                title: "Projector Alignment",
                priority: "MEDIUM",
                timeAgo: "3h ago",
                description: "Projector needs calibration.",
                location: "Business - Room 201",
                due: "Today",
                status: "ASSIGNED"
            ),

            Task(
                title: "Cleaning Completed",
                priority: "LOW",
                timeAgo: "15m ago",
                description: "Lecture hall cleaned.",
                location: "Business - Lecture Hall 1",
                due: "Today",
                status: "COMPLETED"
            )
        ]
    }



    func inProgressTask() -> Task? {
        return tasks.first {
            $0.status.uppercased() == "IN-PROGRESS"
        }
    }
}
extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
}
