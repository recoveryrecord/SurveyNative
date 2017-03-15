//
//  SurveyViewController.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/23/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

open class SurveyViewController: UIViewController {
   
   @IBOutlet var tableView: UITableView!
   
   var surveyQuestions : SurveyQuestions?
   
   var dataSource: UITableViewDataSource?
   var delegate : UITableViewDelegate?
   var cellDataDelegate : TableCellDataDelegate?
   
   open func surveyJsonFile() -> String {
      preconditionFailure("This method must be overridden")
   }
   
   open func surveyTitle() -> String {
      preconditionFailure("This method must be overridden")
   }
   
   open func surveyTheme() -> SurveyTheme {
      return DefaultSurveyTheme()
   }
   
   override open func viewDidLoad() {
      super.viewDidLoad()
      
      surveyQuestions = SurveyQuestions.load(surveyJsonFile(), surveyTheme: surveyTheme())
      
      self.title = surveyTitle()
      
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancel));
      
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
   
   func tableViewTapped(sender: UITapGestureRecognizer) {
      if sender.view as? UITextField == nil {
         tableView.endEditing(true)
         UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
      }
   }
   
   func cancel() {
      self.dismiss(animated: true, completion: {})
   }
}




