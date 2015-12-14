//
//  NRStoryTableViewCell.swift
//  NewsReader
//
//  Created by Philip Henson on 12/11/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//

import UIKit

class NRStoryTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
