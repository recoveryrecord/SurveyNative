//
//  DefaultTableCellDataDelegate.swift
//  Pods
//
//  Created by Nora Mullaney on 3/15/17.
//
//

import Foundation

open class DefaultTableCellDataDelegate : NSObject, TableCellDataDelegate {
   
   var surveyQuestions : SurveyQuestions
   var tableView : UITableView
   var submitCompletionHandler: (Data?, URLResponse?, Error?) -> Void
   
   init(_ surveyQuestions : SurveyQuestions, tableView: UITableView, submitCompletionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
      self.surveyQuestions = surveyQuestions
      self.tableView = tableView
      self.submitCompletionHandler = submitCompletionHandler
   }
   
   
   public func update(updateId: String, data: Any) {
      TableUIUpdater.updateTable(surveyQuestions.update(id: updateId, data: data), tableView: tableView)
   }
   
   public func markFinished(updateId: String) {
      TableUIUpdater.updateTable(surveyQuestions.markFinished(updateId: updateId), tableView: tableView)
   }
   
   public func updateUI() {
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
   }
   
   open func submitData() {
      let session = URLSession.shared
      let url = URL(string: surveyQuestions.submitUrl())
      var request = URLRequest(url: url!)
      let jsonData = try? JSONSerialization.data(withJSONObject: surveyQuestions.submitJson())
      request.httpMethod = "POST"
      request.httpBody = jsonData
      let task = session.dataTask(with: request as URLRequest, completionHandler: self.submitCompletionHandler)
      task.resume()
   }
   
}
