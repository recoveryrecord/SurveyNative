//
//  DynamicLabelTextFieldTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/16/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class DynamicLabelTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
   
   @IBOutlet var verticalStack : UIStackView?
   @IBOutlet var firstHorizontalStack : UIStackView?
   @IBOutlet var textField : UITextField?
   @IBOutlet var dynamicLabel: UIButton?
   
   var extraTextFields : [UITextField] = []
   var extraLabels : [UIButton] = []
   
   var keyboardType : UIKeyboardType? {
      didSet {
         if keyboardType == nil {
            return
         }
         textField?.keyboardType = keyboardType!
         for extraTextField in extraTextFields {
            extraTextField.keyboardType = keyboardType!
         }
      }
   }
   
   var labelOptions : [Any]?
   var currentValue : [String : String]? {
      didSet {
         if labelOptions == nil || labelOptions!.isEmpty {
            Logger.log("Error: LabelOptions should be set before currentValue", level: .error)
            return
         }
         if currentValue == nil || currentValue!.isEmpty {
            updateLabels(labels: labelOptions![0])
         } else {
            let keySet = Array(currentValue!.keys)
            if keySet.count == 1 {
               dynamicLabel?.setTitle(keySet[0], for: .normal)
               textField?.text = currentValue![keySet[0]]
            } else if keySet.count > 1 {
               var selectedLabelSet: [String]?
               for labelOptionSet in labelOptions! {
                  if let labelStringSet = labelOptionSet as? [String], labelStringSet.elementsEqual(keySet) {
                     selectedLabelSet = labelStringSet
                     break
                  }
               }
               if selectedLabelSet != nil {
                  dynamicLabel?.setTitle(selectedLabelSet![0], for: .normal)
                  textField?.text = currentValue![selectedLabelSet![0]]
                  for label in selectedLabelSet!.suffix(from: 1) {
                     addLabelAndTextField(labelText: label, valueText:currentValue![label])
                  }
               }
            }
         }
      }
   }
   
   weak var presentationDelegate : UIViewController?
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      let nextButton = UIButtonWithId(type: UIButtonType.system)
      nextButton.setTitle("Next", for: UIControlState.normal)
      nextButton.frame = CGRect(x: 0, y: 0, width: 100, height: 35)
      nextButton.addTarget(self, action: #selector(tappedNextButton(_:)), for: UIControlEvents.touchUpInside)
      addSubview(nextButton)
      self.accessoryView = nextButton
      textField?.delegate = self
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
   override func prepareForReuse() {
      removeExtraLabelAndTextFields()
      textField?.text = ""
   }
   
   func addLabelAndTextField(labelText : String? = nil, valueText : String? = nil) {
      let newHorizontalStack = UIStackView()
      newHorizontalStack.axis = .horizontal
      newHorizontalStack.alignment = .fill
      newHorizontalStack.distribution = .fillEqually
      let newTextField = UITextField()
      newTextField.text = valueText
      newTextField.borderStyle = .roundedRect
      newTextField.font = self.textField?.font
      newTextField.enablesReturnKeyAutomatically = true
      newTextField.addTarget(self, action: #selector(actionTriggered(_:)), for: .primaryActionTriggered)
      newTextField.delegate = self
      newTextField.keyboardType = self.keyboardType ?? UIKeyboardType.default
      let newLabel = UIButton(type: .system)
      newLabel.setTitle(labelText, for: .normal)
      let imageSize = self.dynamicLabel!.currentImage!.size
      newLabel.contentHorizontalAlignment = .left
      newLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10 + imageSize.width, bottom: 0, right: 10)
      newHorizontalStack.addArrangedSubview(newTextField)
      newHorizontalStack.addArrangedSubview(newLabel)
      extraTextFields.append(newTextField)
      extraLabels.append(newLabel)
      verticalStack?.addArrangedSubview(newHorizontalStack)
   }
   
   // TextField delegate methods
   func textFieldDidEndEditing(_ textField: UITextField) {
      sendUpdate()
   }
   
   func sendUpdate() {
      self.resignFirstResponder()
      dataDelegate?.update(updateId: updateId!, data: getData())
   }
   
   @IBAction func tappedNextButton(_ sender: UIButton) {
      sendUpdate()
   }
   
   @IBAction func actionTriggered(_ sender: UITextField) {
      sendUpdate()
   }
   
   func getData() -> [String : String] {
      var data : [String : String] = [dynamicLabel!.title(for: .normal)! : textField!.text!]
      for i in 0..<extraLabels.count {
         data[extraLabels[i].titleLabel!.text!] = extraTextFields[i].text
      }
      return data
   }
   
   func removeExtraLabelAndTextFields() {
      for view in verticalStack!.arrangedSubviews {
         if view != firstHorizontalStack {
            verticalStack?.removeArrangedSubview(view)
            view.removeFromSuperview()
         }
      }
      extraTextFields.removeAll()
      extraLabels.removeAll()
   }

   func updateLabels(labels : Any) {
      removeExtraLabelAndTextFields()
      if let firstLabel = labels as? String {
         dynamicLabel?.setTitle(firstLabel, for: .normal)
      } else if let labelsArray =  labels as? [String] {
         dynamicLabel?.setTitle(labelsArray[0], for: .normal)
         for label in labelsArray.suffix(from: 1) {
            addLabelAndTextField(labelText: label)
         }
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
            self.dataDelegate?.updateUI()
         })
         alertController.addAction(action)
      }
      presentationDelegate?.present(alertController, animated: true, completion: nil)
   }
}
