import UIKit

protocol EditProfileDelegate: AnyObject {
    func didSaveProfile(_ updatedProfile: AdminProfile)
}

class editProfileViewController: UIViewController {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSaveChange: UIButton!
    @IBOutlet weak var smsAlerts: UISwitch!
    @IBOutlet weak var emailUpdate: UISwitch!
    @IBOutlet weak var pushNotifi: UISwitch!
    @IBOutlet weak var txtRoom: UITextField!
    @IBOutlet weak var department: UIPickerView!
    @IBOutlet weak var txtAdminID: UITextField!
    @IBOutlet weak var txtPhoneNum: UITextField!
    @IBOutlet weak var txtEmailAdd: UITextField!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var photo: UIImageView!

    weak var delegate: EditProfileDelegate?
    var profile: AdminProfile!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfileData()
        setupPhotoTap()
    }

    func loadProfileData() {
        txtFullName.text = profile.fullName
        txtEmailAdd.text = profile.email
        txtPhoneNum.text = profile.phone
        txtAdminID.text = profile.adminID
        txtRoom.text = profile.room
        photo.image = profile.photo

        pushNotifi.isOn = profile.pushNotification
        emailUpdate.isOn = profile.emailUpdate
        smsAlerts.isOn = profile.smsAlert

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

    @IBAction func saveTapped(_ sender: UIButton) {
        profile.fullName = txtFullName.text ?? ""
        profile.email = txtEmailAdd.text ?? ""
        profile.phone = txtPhoneNum.text ?? ""
        profile.room = txtRoom.text ?? ""
        profile.photo = photo.image
        profile.pushNotification = pushNotifi.isOn
        profile.emailUpdate = emailUpdate.isOn
        profile.smsAlert = smsAlerts.isOn

        delegate?.didSaveProfile(profile)
        dismiss(animated: true)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Image Picker
extension editProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            photo.image = img
        }
        picker.dismiss(animated: true)
    }
}
