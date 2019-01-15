//
//  SurveyViewController.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/23/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

open class SurveyViewController: UIViewController {
   
   @IBOutlet open var tableView: UITableView!
   
   open var surveyQuestions : SurveyQuestions?
   
   open var dataSource: UITableViewDataSource?
   open var delegate : UITableViewDelegate?
   open var cellDataDelegate : TableCellDataDelegate?
   
   open func surveyJsonFile() -> String {
      preconditionFailure("This method must be overridden")
   }
   
   open func surveyTitle() -> String {
      preconditionFailure("This method must be overridden")
   }
   
   open func surveyTheme() -> SurveyTheme {
      return DefaultSurveyTheme()
   }
   
   open func setSurveyAnswerDelegate(_ surveyAnswerDelegate: SurveyAnswerDelegate) {
      surveyQuestions?.setSurveyAnswerDelegate(surveyAnswerDelegate)
   }
   
   open func setCustomConditionDelegate(_ customConditionDelegate: CustomConditionDelegate) {
      surveyQuestions?.setCustomConditionDelegate(customConditionDelegate)
   }

   open func setValidationFailedDelegate(_ validationFailedDelegate: ValidationFailedDelegate) {
      self.cellDataDelegate?.setValidationFailedDelegate(validationFailedDelegate)
   }

   override open func viewDidLoad() {
      super.viewDidLoad()
      
      surveyQuestions = SurveyQuestions.load(surveyJsonFile(), surveyTheme: surveyTheme())
      
      self.title = surveyTitle()
      
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancel));
      
      TableUIUpdater.setupTable(tableView)
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
      tapRecognizer.cancelsTouchesInView = false
      tableView.addGestureRecognizer(tapRecognizer)
      
      self.cellDataDelegate = DefaultTableCellDataDelegate(surveyQuestions!, tableView: tableView, submitCompletionHandler: { data, response, error -> Void in
         self.dismiss(animated: true, completion: nil)
      })
      self.dataSource = SurveyDataSource(surveyQuestions!, surveyTheme: self.surveyTheme(), tableCellDataDelegate: cellDataDelegate!, presentationDelegate: self)
      tableView.dataSource = dataSource
      self.delegate = SurveyTableViewDelegate(surveyQuestions!)
      tableView.delegate = self.delegate
   }
   
   @objc public func tableViewTapped(sender: UITapGestureRecognizer) {
      if sender.view as? UITextField == nil {
         tableView.endEditing(true)
         UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
      }
   }
   
   @objc public func cancel() {
      self.dismiss(animated: true, completion: {})
   }
}




