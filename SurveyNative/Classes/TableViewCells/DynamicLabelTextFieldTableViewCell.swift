//
//  DynamicLabelTextFieldTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/16/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class DynamicLabelTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate, TableViewCellActivating {
   
   @IBOutlet weak var firstHorizontalStackView: UIStackView!
   @IBOutlet weak var secondHorizontalStackView: UIStackView!
   @IBOutlet weak var nextButton: UIButton!
   
   var secondStackViewWidthConstraint : NSLayoutConstraint?
   
   var textFields : [UITextField] = []
   var buttons : [UIButton] = []
   
   var keyboardType : UIKeyboardType? {
      didSet {
         if keyboardType == nil {
            return
         }
         for textField in textFields {
            textField.keyboardType = keyboardType!
         }
      }
   }

   var validations: [[String : Any]]?
   
   var labelOptions : [AnyHashable]?
   var optionsMetadata: [String : Any]?
   static var metadataDefaults : [String : String] = [:]
   var currentValue : [String : String]? {
      didSet {
         if labelOptions == nil || labelOptions!.isEmpty {
            Logger.log("Error: LabelOptions should be set before currentValue", level: .error)
            return
         }
         if currentValue == nil || currentValue!.isEmpty {
            updateLabels(labels: labelOptions![indexOfDefaultOption()])
            return
         }
         let keySet = Array(currentValue!.keys)
         let selectedLabelSet: [String]? = findMatchingLabelOption(keySet)
         if selectedLabelSet != nil {
            for label in selectedLabelSet! {
               addLabelAndTextField(labelText: label, valueText:currentValue![label])
            }
         }
         
      }
   }
   
   weak var presentationDelegate : UIViewController?
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      self.resize()
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
   override func prepareForReuse() {
      removeExtraLabelAndTextFields()
   }
   
   func cellDidActivate() {
      if textFields.count > 0 {
         if (textFields[0].text == "") {
            textFields[0].becomeFirstResponder()
         }
      }
   }
   
   func metadataOptionsId() -> String? {
      return self.optionsMetadata?["id"] as? String
   }
   
   func metadataOptionsTypes() -> [String]? {
      return self.optionsMetadata?["types"] as? [String]
   }
   
   func indexOfDefaultOption() -> Int {
      var defaultOption = 0
      if let metadataId = metadataOptionsId(), let metadataTypeOptions = metadataOptionsTypes(), let selectedDefault = DynamicLabelTextFieldTableViewCell.metadataDefaults[metadataId] {
         defaultOption = metadataTypeOptions.index(of: selectedDefault) ?? defaultOption
      }
      return defaultOption
   }
   
   func findMatchingLabelOption(_ keySet: [String]) -> [String]? {
      if keySet.count == 1 {
         for labelOptionSet in labelOptions! {
            if let labelString = labelOptionSet as? String, labelString == keySet[0] {
               return [labelString]
            }
         }
      }
      for labelOptionSet in labelOptions! {
         if let labelStringSet = labelOptionSet as? [String], labelStringSet.elementsEqual(keySet) {
            return labelStringSet
         }
      }
      return nil
   }
   
   func addLabelAndTextField(labelText : String? = nil, valueText : String? = nil) {
      let newTextField = UITextField()
      newTextField.text = valueText
      newTextField.borderStyle = .roundedRect
      newTextField.enablesReturnKeyAutomatically = true
      newTextField.addTarget(self, action: #selector(actionTriggered(_:)), for: .primaryActionTriggered)
      newTextField.delegate = self
      newTextField.keyboardType = self.keyboardType ?? UIKeyboardType.default
      let newLabel = UIButton(type: .system)
      newLabel.setTitle(labelText, for: .normal)
      newLabel.titleLabel?.adjustsFontSizeToFitWidth = true
      newLabel.contentHorizontalAlignment = .left
      let image = UIImage(named: "blue-down-button", in: SurveyBundle.bundle, compatibleWith: nil)
      newLabel.setImage(image, for: .normal)
      newLabel.addTarget(self, action: #selector(labelTapped(_:)), for: .touchUpInside)
      firstHorizontalStackView.addArrangedSubview(newTextField)
      secondHorizontalStackView.addArrangedSubview(newLabel)
      textFields.append(newTextField)
      buttons.append(newLabel)
   }
   
   func resize() {
      var minWidth : CGFloat = 0
      for view in secondHorizontalStackView.arrangedSubviews {
         let size = view.intrinsicContentSize
         if size.width > minWidth {
            minWidth = size.width
         }
      }
      if secondStackViewWidthConstraint != nil {
         secondHorizontalStackView.removeConstraint(secondStackViewWidthConstraint!)
      }
      secondStackViewWidthConstraint = NSLayoutConstraint(item: secondHorizontalStackView, attribute: .width, relatedBy: .equal, toItem: secondHorizontalStackView, attribute: .width, multiplier: 1.0, constant: minWidth)
      secondHorizontalStackView.addConstraint(secondStackViewWidthConstraint!)
   }
   
   // TextField delegate methods
   func textFieldDidBeginEditing(_ textField: UITextField) {
      dataDelegate?.updateActiveTextView(firstHorizontalStackView)
   }
   
   func textFieldDidEndEditing(_ textField: UITextField) {
      if (validate().0) {
         sendUpdate()
      }
   }
   
   func sendUpdate() {
      self.resignFirstResponder()
      dataDelegate?.update(updateId: updateId!, data: getData())
   }
   
   @IBAction func tappedNextButton(_ sender: UIButton) {
      let v = validate()
      if (!v.0) {
         self.dataDelegate?.getValidator()?.validationFailed(message: v.1)
         return
      }

      sendUpdate()
   }
   
   @IBAction func actionTriggered(_ sender: UITextField) {
      if (validate().0) {
         sendUpdate()
      }
   }
   
   func getData() -> [String : String] {
      var data : [String : String] = [:]
      for i in 0..<self.buttons.count {
         data[buttons[i].titleLabel!.text!] = textFields[i].text
      }
      return data
   }
   
   func removeExtraLabelAndTextFields() {
      for view in firstHorizontalStackView!.arrangedSubviews {
         firstHorizontalStackView.removeArrangedSubview(view)
         view.removeFromSuperview()
      }
      for view in secondHorizontalStackView!.arrangedSubviews {
         secondHorizontalStackView.removeArrangedSubview(view)
         view.removeFromSuperview()
      }
      textFields.removeAll()
      buttons.removeAll()
   }

   func updateLabels(labels : AnyHashable) {
      removeExtraLabelAndTextFields()
      var labelsArray : [String] = []
      if let label = labels as? String {
         labelsArray = [label]
      } else if let labellist =  labels as? [String] {
         labelsArray = labellist
      }
      for label in labelsArray {
         addLabelAndTextField(labelText: label)
      }
      if self.optionsMetadata != nil {
         let selectedIndex = labelOptions!.index(of: labels)
         DynamicLabelTextFieldTableViewCell.metadataDefaults[self.metadataOptionsId()!] = self.metadataOptionsTypes()?[selectedIndex!]
      }
   }

   func textFieldWithLabel(label : String) -> UITextField? {
      for (index, button) in self.buttons.enumerated() {
         if button.title(for: UIControlState.normal) == label {
            return self.textFields[index]
         }
      }
      return nil
   }

   func validate() -> (Bool, String) {
      var answers : [String : String] = [:]
      if validations != nil {
         for validation in self.validations! {
            let textField : UITextField? = textFieldWithLabel(label: validation["for_label"] as! String)
            answers[validation["for_label"] as! String] = textField?.text
         }
      }
      if let validator = self.dataDelegate?.getValidator() {
         return validator.validate(validations: validations, answers: answers)
      } else {
         Logger.log("Validator or ValidationFailedDelegate is not set.  Validation will not be done.", level: .error)
         return (true, "")
      }
   }

   @IBAction func labelTapped(_ sender: UIButton) {
      let alertController = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)
      
      for option in labelOptions! {
         var title: String?
         if let stringOption = option as? String {
            title = stringOption
         } else if let arrayOption = option as? [String] {
            title = arrayOption.joined(separator: ", ")
         }
         let action = UIAlertAction(title: title, style: .default, handler: { (action) -> Void in
            self.updateLabels(labels: option)
            self.resize()
            self.dataDelegate?.updateUI()
         })
         alertController.addAction(action)
      }
      presentationDelegate?.present(alertController, animated: true, completion: nil)
   }
}
