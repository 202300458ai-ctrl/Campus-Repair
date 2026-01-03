import UIKit

class AdminProfileViewController: UIViewController {

    @IBOutlet weak var notification: UIButton!
    @IBOutlet weak var secur: UIButton!
    @IBOutlet weak var contactSupport: UIButton!
    @IBOutlet weak var helpCenter: UIButton!
    @IBOutlet weak var personalInfo: UIButton!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var adminID: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var singout: UIButton!
    @IBOutlet weak var photo: UIImageView!

    var profile = AdminProfile(
        fullName: "Janet Jackson",
        email: "janet.jackson@university.edu",
        phone: "+1 (333) 321-7542",
        adminID: "ADM20230242",
        department: "Computer Science",
        room: "Room 500",
        photo: UIImage(named: "admin_photo"),
        pushNotification: true,
        emailUpdate: true,
        smsAlert: false
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        setupPhotoTap()
    }

    func updateUI() {
        fullName.text = profile.fullName
        adminID.text = profile.adminID
        department.text = profile.department
        photo.image = profile.photo

        photo.layer.cornerRadius = photo.frame.width / 2
        photo.clipsToBounds = true
    }

    func setupPhotoTap() {
        photo.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        photo.addGestureRecognizer(tap)
    }

    @objc func changePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func personalInfoTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditProfile" {
            let vc = segue.destination as! editProfileViewController
            vc.profile = profile
            vc.delegate = self
        }
    }
}

// MARK: - Image Picker
extension AdminProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            profile.photo = img
            photo.image = img
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - Edit Profile Delegate
extension AdminProfileViewController: EditProfileDelegate {
    func didSaveProfile(_ updatedProfile: AdminProfile) {
        self.profile = updatedProfile
        updateUI()
    }
}
