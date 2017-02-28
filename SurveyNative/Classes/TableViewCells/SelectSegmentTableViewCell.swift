//
//  SelectSegmentTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/14/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class SelectSegmentTableViewCell: UITableViewCell {
   
   @IBOutlet var lowLabel : UILabel?
   @IBOutlet var highLabel : UILabel?
   @IBOutlet var segmentedControl : UISegmentedControl?
   
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   var values : [String]? {
      didSet {
         updateSegmentedControl()
      }
   }
   
   public func setSelectedValue(_ value : String) {
      if let selectedIndex = values?.index(of: value) {
         segmentedControl?.selectedSegmentIndex = selectedIndex
      }
   }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
   }
   
   func updateSegmentedControl() {
      if values == nil {
         return
      }
      segmentedControl?.removeAllSegments()
      for (index, value) in values!.enumerated() {
         segmentedControl?.insertSegment(withTitle: value, at: index, animated: false)
      }
   }
   
   @IBAction func valueChanged(_ sender: UISegmentedControl) {
      dataDelegate?.update(updateId: updateId!, data: values![sender.selectedSegmentIndex])
   }
}
