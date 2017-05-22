//
//  AddTextFieldTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/17/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class AddTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate, TableViewCellActivating {
   
   @IBOutlet var verticalStack : UIStackView?
   @IBOutlet var firstTextField : UITextField?
   @IBOutlet weak var nextButton: UIButton!
   
   var extraTextFields : [UITextField] = []
   
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   var currentValues : [String]? {
      didSet {
         if currentValues == nil || currentValues?.count == 0 {
            return
         }
         firstTextField?.text = currentValues![0]
         for value in currentValues!.suffix(from: 1) {
            addTextField(value: value)
         }
      }
   }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      firstTextField?.delegate = self
   }
   
   override func prepareForReuse() {
      for textField in extraTextFields {
         verticalStack?.removeArrangedSubview(textField)
         textField.removeFromSuperview()
      }
      extraTextFields = []
   }
   
   func cellDidActivate() {
      if extraTextFields.count > 0 {
         if (extraTextFields[0].text == "") {
            extraTextFields[0].becomeFirstResponder()
         }
      }
   }
   
   @IBAction func tappedNextButton(_ sender: UIButton) {
      self.resignFirstResponder()
      var data : [String] = []
      data.append(firstTextField!.text!)
      for textField in extraTextFields {
         data.append(textField.text!)
      }
      data = data.filter({ !$0.isEmpty })
      dataDelegate?.update(updateId: updateId!, data: data)
   }
   
   func addTextField(value : String? = nil) {
      let newTextField = UITextField(frame: CGRect(x: 0, y: 0, width: (firstTextField?.bounds.width)!, height: (firstTextField?.bounds.height)!))
      newTextField.delegate = self
      newTextField.borderStyle = .roundedRect
      newTextField.font = firstTextField?.font
      newTextField.enablesReturnKeyAutomatically = true
      newTextField.addTarget(self, action: #selector(enterTapped(_:)), for: .primaryActionTriggered)
      self.verticalStack?.addArrangedSubview(newTextField)
      self.extraTextFields.append(newTextField)
      if value != nil {
         newTextField.text = value
      }
   }
   
   @IBAction func enterTapped(_ sender: UITextField) {
      if (sender == firstTextField && extraTextFields.isEmpty) ||
         (!extraTextFields.isEmpty && sender == extraTextFields.last) {
         addTextField()
         dataDelegate?.updateUI()
      }
      if let nextField = nextTextField(sender) {
         if (nextField.text == "") {
            nextField.becomeFirstResponder()
         }
      }
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      self.dataDelegate?.updateActiveTextView(textField)
   }
   
   func nextTextField(_ textField : UITextField) -> UITextField? {
      if extraTextFields.isEmpty || textField == extraTextFields.last {
         return nil
      }
      if textField == firstTextField {
         return extraTextFields[0]
      }
      for (index, field) in extraTextFields.enumerated() {
         if field == textField {
            return extraTextFields[index + 1]
         }
      }
      return nil
   }
   
   @IBAction func addButtonTapped(_ sender: UIButton) {
      addTextField()
      dataDelegate?.updateUI()
   }
}
