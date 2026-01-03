import UIKit
import Foundation

class AdminProfile: UIViewController {
    var fullName: String
    var email: String
    var phone: String
    var adminID: String
    var department: String
    var room: String
    var photo: UIImage?
    var pushNotification: Bool
    var emailUpdate: Bool
    var smsAlert: Bool

    // Custom initializer
    init(fullName: String, email: String, phone: String, adminID: String, department: String, room: String, photo: UIImage?, pushNotification: Bool, emailUpdate: Bool, smsAlert: Bool) {
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.adminID = adminID
        self.department = department
        self.room = room
        self.photo = photo
        self.pushNotification = pushNotification
        self.emailUpdate = emailUpdate
        self.smsAlert = smsAlert
        super.init(nibName: nil, bundle: nil) // Call UIViewController's designated initializer
    }

    // Required initializer for Storyboards/XIBs
    required init?(coder aDecoder: NSCoder) {
        // You can either provide default values or make properties optional
        self.fullName = ""
        self.email = ""
        self.phone = ""
        self.adminID = ""
        self.department = ""
        self.room = ""
        self.photo = nil
        self.pushNotification = false
        self.emailUpdate = false
        self.smsAlert = false
        super.init(coder: aDecoder)
    }
}
