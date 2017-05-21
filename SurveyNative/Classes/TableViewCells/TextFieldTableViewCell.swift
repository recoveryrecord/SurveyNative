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
         textField?.becomeFirstResponder()
      }
   }
   
   func cellDidActivate() {
      self.textField!.becomeFirstResponder()
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
      if validations != nil {
         for validation in self.validations! {
            if (!conditionMet(validation, answer: textField.text!)) {
               let message : String = validation["on_fail_message"] as! String
               return (false, message)
            }
         }
      }
      return (true, "")
   }

   @IBAction func tappedNextButton(_ sender: UIButton) {
      let v = validate()
      if (!v.0) {
         self.dataDelegate?.validationFailed(message: v.1)
         return
      }

      dataDelegate?.markFinished(updateId: updateId!)
      self.textFieldText = textField?.text ?? ""
      textField?.resignFirstResponder()
   }

   func conditionMet(_ condition : [String : Any], answer : String ) -> Bool {

      let operationType : String = condition["operation"] as! String
      var value : Any? = condition["value"]
      let questionId : String? = condition["answer_to_question_id"] as! String?

      if (questionId != nil) {
         value = self.dataDelegate?.answerForQuestion(id : questionId!)
      }

      if (value == nil) {
         Logger.log("Unable to check condition for unknown operation \"\(operationType)\" as value is nil, assuming false", level: .error)
         return false
      }

      switch operationType {
      case "greater than", "greater than or equal to", "less than", "less than or equal to":
         return SurveyQuestions.numberComparison(answer: answer, value: value!, operation: operationType)
      default:
         Logger.log("Unable to check condition for unknown operation \"\(operationType)\", assuming false", level: .error)
         return false
      }
   }
}
