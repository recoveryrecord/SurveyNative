//
//  TextAreaTableViewCell.swift
//  Pods
//
//  Created by Nora Mullaney on 4/12/19.
//

import UIKit

class TextAreaTableViewCell: UITableViewCell, UITextViewDelegate, TableViewCellActivating {
   
   @IBOutlet var myTextArea: UITextView!
   @IBOutlet var myNextButton: UIButton!
   
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   var textFieldText: String? {
      didSet {
         myTextArea?.text = textFieldText
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
   var maxCharacters: Int?
   var validations: [[String : Any]]?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      selectionStyle = .none
      self.myTextArea!.delegate = self
      self.myTextArea!.layer.borderColor = UIColor.gray.cgColor
      self.myTextArea!.layer.borderWidth = 1.0;
      self.myTextArea!.layer.cornerRadius = 8;
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      if selected {
         if (myTextArea.text == "") {
            myTextArea?.becomeFirstResponder()
         }
      }
   }
   
   func cellDidActivate() {
      if (self.myTextArea.text == "") {
         myTextArea!.becomeFirstResponder()
      }
   }
   
   func sendUpdate() {
      dataDelegate?.update(updateId: updateId!, data: self.textFieldText ?? "")
   }
   
   func textViewDidBeginEditing(_ textView: UITextView) {
      self.dataDelegate?.updateActiveTextView(textView)
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      self.textFieldText = textView.text ?? ""
      textView.resignFirstResponder()
   }
   
   
   func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      if maxCharacters == nil {
         return true
      }
      let oldLength = myTextArea.text?.count ?? 0
      let replacementLength = text.count
      let rangeLength = range.length
      
      let newLength = oldLength - rangeLength + replacementLength
      return newLength <= maxCharacters!
   }
   
   func validate() -> (Bool, String) {
      if let validator = self.dataDelegate?.getValidator() {
         return validator.validate(validations: validations, answer: myTextArea.text ?? "")
      } else {
         Logger.log("Validator or ValidationFailedDelegate is not set.  Validation will not be done.", level: .error)
         return (true, "")
      }
   }
   
   @IBAction func tappedNextButton(_ sender: Any) {
      let v = validate()
      if (!v.0) {
         self.dataDelegate?.getValidator()?.validationFailed(message: v.1)
         return
      }
      dataDelegate?.markFinished(updateId: updateId!)
      self.textFieldText = myTextArea?.text ?? ""
      myTextArea?.resignFirstResponder()
   }
}
