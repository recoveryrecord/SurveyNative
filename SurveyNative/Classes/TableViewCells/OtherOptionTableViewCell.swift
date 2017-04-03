//
//  OtherOptionTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/26/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class OtherOptionTableViewCell: UITableViewCell, UITextFieldDelegate {
   @IBOutlet var optionImageView: UIImageView!
   @IBOutlet var label: UILabel!
   @IBOutlet var textField: UITextField!
   @IBOutlet weak var nextButton: UIButton!
   
   
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
      self.textField.delegate = self
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      self.dataDelegate?.updateActiveTextView(textField)
   }
   
   func textFieldDidEndEditing(_ textField: UITextField) {
      self.optionText = textField.text ?? ""
      textField.resignFirstResponder()
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      self.optionText = textField.text ?? ""
      textField.resignFirstResponder()
      return true
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
}
