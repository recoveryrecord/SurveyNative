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
   
   var minYear : Int?
   var maxYear : Int?
   var numYears : Int?
   var initialYear : String?
   var sortOrder : String?
   var selectedRow: Int?
   
   public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setup()
   }
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setup()
   }
   
   func setYearRange(minYear: String?, maxYear: String?, numYears: String?, sortOrder: String? = "ASC") {
      self.sortOrder = sortOrder
      var notNilCount = 0
      if minYear != nil {
         self.minYear = yearToInt(minYear!)
         notNilCount = notNilCount + 1
      }
      if maxYear != nil {
         self.maxYear = yearToInt(maxYear!)
         notNilCount = notNilCount + 1
      }
      if numYears != nil {
         self.numYears = Int(numYears!)
         notNilCount = notNilCount + 1
      }
      if notNilCount == 0 {
         Logger.log("No year range data set.  Using defaults.", level: .error)
         self.minYear = 1900
         self.maxYear = yearToInt("current_year")
         self.numYears = self.maxYear! - self.minYear! + 1
      } else if notNilCount == 1 {
         Logger.log("Inadequate range data set.  Using defaults.", level: .error)
         if self.minYear != nil {
            self.maxYear = max(yearToInt("current_year"), self.minYear!)
            self.numYears = self.maxYear! - self.minYear! + 1
         } else if self.maxYear != nil {
            self.minYear = min(yearToInt("current_year"), self.maxYear!)
            self.numYears = self.maxYear! - self.minYear! + 1
         } else if self.numYears != nil {
            self.maxYear = yearToInt("current_year")
            self.minYear = self.maxYear! - self.numYears! + 1
         }
      } else if notNilCount == 2 {
         if self.minYear == nil {
            self.minYear = self.maxYear! - self.numYears! + 1
         } else if self.maxYear == nil {
            self.maxYear = self.numYears! - 1 + self.minYear!
         } else {
            self.numYears = self.maxYear! - self.minYear! + 1
         }
      } else {
         Logger.log("Too much data set for Year Picker, only using min/max year.", level: .warning)
         self.numYears = self.maxYear! - self.minYear! + 1
      }
   }
   
   func yearToInt(_ year: String) -> Int {
      return year == "current_year" ? YearPickerTableViewCell.currentYear() : Int(year)!
   }
   
   func setup() {
      textLabel?.text = "Year"
      textLabel?.textColor = self.tintColor
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
            if selectedRow == nil && initialYear != nil {
               self.selectedRow = rowIndex(for: initialYear!)
               pickerViewController?.initialSelectedRow = self.selectedRow
            }
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
      return numYears!
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
      if sortOrder == "DESC" {
         let intValue = maxYear! - row
         return String(intValue)
      } else {
         let intValue = minYear! + row
         return String(intValue)
      }
   }
   
   func rowIndex(for year: String) -> Int? {
      if let intYear = Int(year) {
         if sortOrder == "DESC" {
            return maxYear! - intYear
         } else {
            return intYear - minYear!
         }
      }
      return nil
   }
   
   static func currentYear() -> Int {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "yyyy"
      let stringYear = dateFormatter.string(from: Date())
      return Int(stringYear)!
   }
   
}
