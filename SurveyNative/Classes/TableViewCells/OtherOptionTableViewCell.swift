//
//  OtherOptionTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/26/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class OtherOptionTableViewCell: UITableViewCell, UITextFieldDelegate, HasSelectionState {
   
   
   @IBOutlet weak var optionButton: UIButton!
   @IBOutlet weak var label: UILabel!
   @IBOutlet weak var textField: UITextField!
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
            if (validate().0) {
               sendUpdate()
            }
         }
      }
   }
   var isSelectedOption: Bool? {
      didSet {
         if isSelectedOption! {
            textField?.isHidden = false
            updateNextButtonVisibility()
         } else {
            textField?.isHidden = true
            nextButton?.isHidden = true
         }
      }
   }
   var shouldShowNextButton: Bool = true {
      didSet {
         updateNextButtonVisibility()
      }
   }
   var surveyTheme: SurveyTheme? {
      didSet {
         updateButtonImages()
      }
   }
   var isSingleSelection: Bool = true {
      didSet {
         updateButtonImages()
      }
   }

   var validations: [[String : Any]]?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      selectionStyle = .none
      self.textField.delegate = self
   }
   
   override func prepareForReuse() {
      optionButton.isSelected = false
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
      if (textField != nil) {
         let v = validate()
         if (!v.0) {
            self.dataDelegate?.validationFailed(message: v.1)
            return
         }
      }

      self.optionText = textField?.text ?? ""
      textField?.resignFirstResponder()
   }
   
   public func isSingleSelect() -> Bool {
      return isSingleSelection
   }
   
   public func setSelectionState(_ selected: Bool) {
      optionButton.isSelected = selected
      isSelectedOption = selected
      if selected {
         textField?.becomeFirstResponder()
      } else {
         textField?.resignFirstResponder()
      }
   }
   
   public func selectionState() -> Bool {
      return isSelectedOption ?? false
   }
   
   private func updateButtonImages() {
      if surveyTheme == nil {
         return
      }
      if isSingleSelection {
         optionButton.setImage(surveyTheme!.radioButtonSelectedImage(), for: .selected)
         optionButton.setImage(surveyTheme!.radioButtonDeselectedImage(), for: .normal)
      } else {
         optionButton.setImage(surveyTheme!.tickBoxTickedImage(), for: .selected)
         optionButton.setImage(surveyTheme!.tickBoxNotTickedImage(), for: .normal)
      }
   }
   
   private func updateNextButtonVisibility() {
      if isSelectedOption != nil && isSelectedOption! == true {
         nextButton?.isHidden = !shouldShowNextButton
      } else {
         nextButton?.isHidden = true
      }
   }

   func validate() -> (Bool, String) {
      if validations != nil {
         for validation in self.validations! {
            if (textField != nil) {
               if (!conditionMet(validation, answer: (textField?.text)!)) {
                  let message : String = validation["on_fail_message"] as! String
                  return (false, message)
               }
            }
         }
      }
      return (true, "")
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
