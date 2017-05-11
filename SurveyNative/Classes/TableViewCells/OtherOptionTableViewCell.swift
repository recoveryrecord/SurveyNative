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
            sendUpdate()
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
}
