//
//  OptionTableViewCell.swift
//  Pods
//
//  Created by Nora Mullaney on 3/27/17.
//
//

import UIKit

class OptionTableViewCell: UITableViewCell {

   @IBOutlet weak var optionImage: UIImageView!
   @IBOutlet weak var optionLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
