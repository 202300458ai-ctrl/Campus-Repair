//
//  SecheduleTaskViewController.swift
//  Admin
//
//

import UIKit

class SecheduleTaskViewController: UIViewController {


    @IBOutlet weak var saveDraft: UIButton!
    @IBOutlet weak var secheduleTask: UIButton!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBOutlet weak var tableVew: UITableView!
    @IBOutlet weak var descriptionTask: UITextField!
    @IBOutlet weak var priority: UISegmentedControl!
    @IBOutlet weak var catagory: UIPickerView!
    @IBOutlet weak var room: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
