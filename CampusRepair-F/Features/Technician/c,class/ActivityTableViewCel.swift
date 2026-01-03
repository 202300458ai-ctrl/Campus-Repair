//
//  ActivityTableViewCel.swift
//  tech
//
//  Created by Macbook Pro on 11/12/2025.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    // MARK: - Fill Cell Data
    func configure(with activity: RecentActivity) {
        titleLabel.text = activity.title
        subtitleLabel.text = activity.subtitle
        timeLabel.text = activity.timeText
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true

        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0
    }
}
