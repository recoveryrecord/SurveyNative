//
//  DatePickerViewController.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/31/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
   @IBOutlet var datePickerView: UIDatePicker?
   
   var controllerDelegate: DatePickerViewControllerDelegate?
   var currentDate: Date? {
      didSet {
         datePickerView?.date = currentDate!
      }
   }
   var minDate: Date? {
      didSet {
         datePickerView?.minimumDate = minDate
      }
   }
   var maxDate: Date? {
      didSet {
         datePickerView?.maximumDate = maxDate
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      datePickerView?.date = currentDate ?? Date()
      datePickerView?.datePickerMode = UIDatePickerMode.date
      datePickerView?.minimumDate = minDate
      datePickerView?.maximumDate = maxDate
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   @IBAction func doneTapped(_ sender: UIButton) {
      controllerDelegate?.onDone(selectedDate: datePickerView?.date)
   }
}

public protocol DatePickerViewControllerDelegate : NSObjectProtocol {
   func onDone(selectedDate: Date?);
}
