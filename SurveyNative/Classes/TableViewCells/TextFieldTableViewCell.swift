//
//  TextFieldTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/31/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate, TableViewCellActivating {
   @IBOutlet var textFieldLabel: UILabel!
   @IBOutlet var textField: UITextField!
   @IBOutlet var nextButton: UIButton!
   
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   var textFieldText: String? {
      didSet {
         textField?.text = textFieldText
         if updateId == nil {
            // updateId will be nil during setup of cell
            return
         }
         if (oldValue ?? "").isEmpty && (textFieldText ?? "").isEmpty {
            return
         }
         if textFieldText != oldValue {
            if (validate().0) {
               sendUpdate()
            }
         }
      }
   }
   var shouldShowNextButton: Bool? {
      didSet {
         nextButton?.isHidden = !shouldShowNextButton!
      }
   }
   var maxCharacters: Int?
   var validations: [[String : Any]]?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      selectionStyle = .none
      self.accessoryView = nextButton
      self.textField!.delegate = self
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      if selected {
         if (textField.text == "") {
            textField?.becomeFirstResponder()
         }
      }
   }
   
   func cellDidActivate() {
      if (self.textField.text == "") {
         self.textField!.becomeFirstResponder()
      }
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      self.dataDelegate?.updateActiveTextView(textField)
   }
   
   func textFieldDidEndEditing(_ textField: UITextField) {
      self.textFieldText = textField.text ?? ""
      textField.resignFirstResponder()
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      self.textFieldText = textField.text ?? ""
      textField.resignFirstResponder()
      return true
   }
   
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      if maxCharacters == nil {
         return false
      }
      let oldLength = textField.text?.characters.count ?? 0
      let replacemenetLength = string.characters.count
      let rangeLength = range.length
      
      let newLength = oldLength - rangeLength + replacemenetLength
      return newLength <= maxCharacters!
   }
   
   func sendUpdate() {
      dataDelegate?.update(updateId: updateId!, data: self.textFieldText ?? "")
   }

   func validate() -> (Bool, String) {
      if let validator = self.dataDelegate?.getValidator() {
         return validator.validate(validations: validations, answer: textField.text ?? "")
      } else {
         Logger.log("Validator or ValidationFailedDelegate is not set.  Validation will not be done.", level: .error)
         return (true, "")
      }
   }

   @IBAction func tappedNextButton(_ sender: UIButton) {
      let v = validate()
      if (!v.0) {
         self.dataDelegate?.getValidator()?.validationFailed(message: v.1)
         return
      }

      dataDelegate?.markFinished(updateId: updateId!)
      self.textFieldText = textField?.text ?? ""
      textField?.resignFirstResponder()
   }
}
