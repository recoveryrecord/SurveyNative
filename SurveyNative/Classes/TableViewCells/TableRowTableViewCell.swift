//
//  TableRowTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/15/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class TableRowTableViewCell: UITableViewCell {
   
   @IBOutlet var question : UILabel?
   @IBOutlet var image1: UIButton?
   @IBOutlet var image2: UIButton?
   @IBOutlet var image3: UIButton?
   
   var surveyTheme: SurveyTheme? {
      didSet {
         if surveyTheme == nil {
            return
         }
         for image in images() {
            image.setImage(surveyTheme!.radioButtonSelectedImage(), for: .selected)
            image.setImage(surveyTheme!.radioButtonDeselectedImage(), for: .normal)
         }
      }
   }
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   
   var headers : [String]?
   var selectedHeader : String? {
      didSet {
         if selectedHeader == nil {
            return
         }
         if let index = headers?.index(of: selectedHeader!) {
            selectImageUI(index: index)
         }
      }
   }
   
   override func prepareForReuse() {
      for image in images() {
         image.isSelected = false
      }
   }
   
   func selectImageUI(index: Int) {
      for (imageIndex, image) in images().enumerated() {
         if imageIndex == index {
            image.isSelected = true
         } else {
            image.isSelected = false
         }
      }
   }
   
   func images() -> [UIButton] {
      return [image1!, image2!, image3!]
   }
   
   @IBAction func tappedImage(_ sender: UIButton) {
      var index: Int
      if sender == image1 {
         index = 0
      } else if sender == image2 {
         index = 1
      } else {
         index = 2
      }
      if headers != nil {
         dataDelegate?.update(updateId: updateId!, data: headers![index])
         selectImageUI(index: index)
      }
   }
}
