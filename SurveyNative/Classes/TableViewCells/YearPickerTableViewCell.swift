//
//  YearPickerTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/25/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class YearPickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, PickerViewControllerDelegate {
   
   weak var presentationDelegate : UIViewController?
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   var selectedYear: String? {
      didSet {
         textLabel?.text = selectedYear ?? "Year"
      }
   }
   
   var pickerViewController: PickerViewController?
   
   let numYears = 125
   let maxYear: Int = YearPickerTableViewCell.currentYear()
   var selectedRow: Int?
   
   public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setup()
   }
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setup()
   }
   
   func setup() {
      textLabel?.text = "Year"
      selectionStyle = .none
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      if presentationDelegate != nil && selected {
         if pickerViewController == nil {
            pickerViewController = PickerViewController(nibName: "PickerViewController", bundle: SurveyBundle.bundle)
            pickerViewController?.pickerDelegate = self
            pickerViewController?.pickerDataSource = self
            pickerViewController?.controllerDelegate = self
            pickerViewController?.modalPresentationStyle = .overCurrentContext
         }
         if (pickerViewController!.isViewLoaded && pickerViewController!.view.window != nil) {
            // controller is already active
            return
         }
         presentationDelegate?.present(pickerViewController!, animated: true, completion: nil)
      }
   }
   
   public func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
   }
   
   public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return numYears
   }
   
   public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return yearString(for: row)
   }
   
   public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      self.selectedRow = row
   }
   
   func onDone() {
      pickerViewController?.dismiss(animated: true, completion: nil)
      if selectedRow != nil, let pickedText = yearString(for: selectedRow!) {
         textLabel?.text = pickedText
         dataDelegate?.update(updateId: updateId!, data: pickedText)
      }
   }
   
   func yearString(for row: Int) -> String? {
      let intValue = maxYear - row
      return String(intValue)
   }
   
   static func currentYear() -> Int {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "yyyy"
      let stringYear = dateFormatter.string(from: Date())
      return Int(stringYear)!
   }
   
}
