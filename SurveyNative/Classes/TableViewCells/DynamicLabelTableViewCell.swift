//
//  DynamicLabelTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/13/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class DynamicLabelTableViewCell: UITableViewCell {

   @IBOutlet var dynamicLabel: UILabel?
   
   override func awakeFromNib() {
      super.awakeFromNib()
   }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
