//
//  DatePickerTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/31/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell, DatePickerViewControllerDelegate {

   weak var presentationDelegate : UIViewController?
   var dataDelegate: TableCellDataDelegate?
   var updateId: String?
   var selectedDateStr: String? {
      didSet {
         textLabel?.text = selectedDateStr ?? "Date"
         if selectedDateStr != nil {
            currentDate = strToDate(selectedDateStr!)
         }
      }
   }
   
   var datePickerViewController: DatePickerViewController?
   
   var currentDate : Date?
   var minDate: Date?
   var maxDate: Date?
   
   public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setup()
   }
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setup()
   }
   
   func setup() {
      textLabel?.text = "Date"
      textLabel?.textColor = self.tintColor
      selectionStyle = .none
   }
   
   func setDateRange(currentDate : String?, minDate: String?, maxDate: String?, dateDiff: [String : Int]?) {
      if currentDate != nil {
         self.currentDate = strToDate(currentDate!)
      }
      if minDate != nil {
         self.minDate = strToDate(minDate!)
      }
      if maxDate != nil {
         self.maxDate = strToDate(maxDate!)
      }
      if dateDiff != nil {
         if self.minDate == nil  && self.maxDate != nil {
            self.minDate = self.diffDate(startDate: self.maxDate!, dateDiff: dateDiff!)
            
         } else if self.maxDate == nil && self.minDate != nil {
            self.maxDate = self.diffDate(startDate: self.minDate!, dateDiff: dateDiff!)
         }
      }
   }
   
   func diffDate(startDate: Date, dateDiff: [String : Int]) -> Date {
      var dateToUpdate = startDate
      for (dateComponentStr, value) in dateDiff {
         if let component = strToComponent(dateComponentStr) {
            dateToUpdate = Calendar.autoupdatingCurrent.date(byAdding: component, value: value, to: dateToUpdate)!
         }
      }
      return dateToUpdate
   }
   
   func strToComponent(_ componentStr : String) -> Calendar.Component? {
      if componentStr == "day" {
         return .day
      } else if componentStr == "month" {
         return .month
      } else if componentStr == "year" {
         return .year
      }
      return nil
   }
   
   func strToDate(_ dateStr: String) -> Date {
      return dateStr == "current_date" ? Date() : self.dateFormatter().date(from: dateStr)!
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      if presentationDelegate != nil && selected {
         if datePickerViewController == nil {
            datePickerViewController = DatePickerViewController(nibName: "DatePickerViewController", bundle: SurveyBundle.bundle)
            datePickerViewController?.controllerDelegate = self
            datePickerViewController?.currentDate = currentDate
            datePickerViewController?.minDate = minDate
            datePickerViewController?.maxDate = maxDate
            datePickerViewController?.modalPresentationStyle = .overCurrentContext
         }
         if (datePickerViewController!.isViewLoaded && datePickerViewController!.view.window != nil) {
            // controller is already active
            return
         }
         presentationDelegate?.present(datePickerViewController!, animated: true, completion: nil)
      }
   }
   
   func onDone(selectedDate : Date?) {
      datePickerViewController?.dismiss(animated: true, completion: nil)
      if selectedDate != nil, let dateText = dateString(for: selectedDate!) {
         self.selectedDateStr = dateText
         dataDelegate?.update(updateId: updateId!, data: dateText)
      }
   }
   
   func dateFormatter() -> DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "yyyy-MM-dd"
      return dateFormatter
   }
   
   func dateString(for selectedDate: Date) -> String? {
      return dateFormatter().string(from: selectedDate)
   }
}
