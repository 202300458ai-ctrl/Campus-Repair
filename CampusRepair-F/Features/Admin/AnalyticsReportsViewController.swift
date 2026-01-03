//
//  AnalyticsReportsViewController.swift
//  Admin
//
//

import UIKit

class AnalyticsReportsViewController: UIViewController {

    @IBOutlet weak var btnExportReport: UIButton!
    @IBOutlet weak var weeklyComparison: UIImageView!
    @IBOutlet weak var requestCategories: UIImageView!
    @IBOutlet weak var resolutiontimetrend: UIImageView!
    @IBOutlet weak var rating: UITextField!
    @IBOutlet weak var requests: UITextField!
    @IBOutlet weak var completionRate: UITextField!
    @IBOutlet weak var resolution: UITextField!
    @IBOutlet weak var week_month_all: UISegmentedControl!
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
