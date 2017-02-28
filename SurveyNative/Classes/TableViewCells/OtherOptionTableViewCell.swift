//
//  OtherOptionTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/26/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class OtherOptionTableViewCell: UITableViewCell {
   @IBOutlet var optionImageView: UIImageView?
   @IBOutlet var label: UILabel?
   @IBOutlet var textField: UITextField?
   
   var nextButton: UIButton?
   
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   var optionText: String? {
      didSet {
         textField?.text = optionText
         if updateId == nil {
            // updateId will be nil during setup of cell
            return
         }
         if (oldValue ?? "").isEmpty && (optionText ?? "").isEmpty {
            return
         }
         if optionText != oldValue {
            sendUpdate()
         }
      }
   }
   var isSelectedOption: Bool? {
      didSet {
         if isSelectedOption! {
            textField?.isHidden = false
            nextButton?.isHidden = isSelectedOption! && shouldShowNextButton
         } else {
            textField?.isHidden = true
            nextButton?.isHidden = true
         }
      }
   }
   var shouldShowNextButton: Bool = true {
      didSet {
         nextButton?.isHidden = !(isSelectedOption ?? false && shouldShowNextButton)
      }
   }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      selectionStyle = .none
      nextButton = UIButtonWithId(type: UIButtonType.system)
      nextButton?.setTitle("Next", for: UIControlState.normal)
      nextButton?.frame = CGRect(x: 0, y: 0, width: 100, height: 35)
      nextButton?.addTarget(self, action: #selector(tappedNextButton(_:)), for: UIControlEvents.touchUpInside)
      addSubview(nextButton!)
      self.accessoryView = nextButton
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      if selected {
         textField?.becomeFirstResponder()
      }
   }
   
   @IBAction func editingDone(_ sender: Any) {
      self.optionText = textField?.text ?? ""
      textField?.resignFirstResponder()
   }
   
   func sendUpdate() {
      dataDelegate?.update(updateId: updateId!, data: self.optionText ?? "")
   }
   
   @IBAction func tappedNextButton(_ sender: UIButton) {
      self.optionText = textField?.text ?? ""
      textField?.resignFirstResponder()
   }
   
   @IBAction func actionTriggered(_ sender: Any) {
      self.optionText = textField?.text ?? ""
      textField?.resignFirstResponder()
   }
}
