//
//  SubmitButtonTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/23/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class SubmitButtonTableViewCell: UITableViewCell {

   @IBOutlet var submitButton : UIButton?
   
   var dataDelegate: TableCellDataDelegate?

   @IBAction func submitButtonTapped(_ sender: UIButton) {
      dataDelegate?.submitData()
   }
    
}
