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
      }
   }
   
   var datePickerViewController: DatePickerViewController?
   
   let currentDate = Date()
   let maxDate = Date()
   let minDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -30, to: Date())
   
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
      selectionStyle = .none
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
   
   func dateString(for selectedDate: Date) -> String? {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "yyyy-MM-dd"
      return dateFormatter.string(from: selectedDate)
   }
}
