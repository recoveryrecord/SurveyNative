//
//  SurveyViewController.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/23/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

open class SurveyViewController: UIViewController, UITableViewDelegate, TableCellDataDelegate {
   
   @IBOutlet var tableView: UITableView?
   
   var surveyQuestions : SurveyQuestions?
   
   var dataSource: UITableViewDataSource?
   var delegate : UITableViewDelegate?
   
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
      
      TableUIUpdater.setupTable(tableView!)
      
      self.dataSource = SurveyDataSource(surveyQuestions!, surveyTheme: self.surveyTheme(), tableCellDataDelegate: self, presentationDelegate: self)
      tableView!.dataSource = dataSource
      self.delegate = SurveyTableViewDelegate(surveyQuestions!)
      tableView!.delegate = self.delegate
   }
   
   public func update(updateId: String, data: Any) {
      TableUIUpdater.updateTable(surveyQuestions!.update(id: updateId, data: data), tableView: tableView!)
   }
   
   public func markFinished(updateId: String) {
      TableUIUpdater.updateTable(surveyQuestions!.markFinished(updateId: updateId), tableView: tableView!)
   }
   
   public func updateUI() {
      self.tableView!.beginUpdates()
      self.tableView!.endUpdates()
   }
   
   public func submitData() {
      let session = URLSession.shared
      let url = URL(string: surveyQuestions!.submitUrl())
      var request = URLRequest(url: url!)
      let jsonData = try? JSONSerialization.data(withJSONObject: surveyQuestions!.submitJson())
      request.httpMethod = "POST"
      request.httpBody = jsonData
      let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
         self.dismiss(animated: true, completion: {})
      })
      task.resume()
   }
   
   func cancel() {
      self.dismiss(animated: true, completion: {})
   }
}

public protocol TableCellDataDelegate {
   func update(updateId: String, data: Any)
   func markFinished(updateId: String)
   func updateUI()
   func submitData()
}

public class UIButtonWithId: UIButton {
   public var updateId: String?
}
