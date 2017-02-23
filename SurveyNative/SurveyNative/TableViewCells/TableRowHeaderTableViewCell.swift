//
//  TableRowHeaderTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/15/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class TableRowHeaderTableViewCell: UITableViewCell {

   @IBOutlet var header1 : UILabel?
   @IBOutlet var header2 : UILabel?
   @IBOutlet var header3 : UILabel?
   
   var headers : [String]? {
      didSet {
         if headers == nil {
            return
         }
         if headers!.count > 0 {
            header1?.text = headers![0]
         }
         if headers!.count > 1 {
            header2?.text = headers![1]
         }
         if headers!.count > 2 {
            header3?.text = headers![2]
         }
      }
   }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
