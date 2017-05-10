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
   var activeTextView: UIView?
   
   public init(_ surveyQuestions : SurveyQuestions, tableView: UITableView, submitCompletionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
      self.surveyQuestions = surveyQuestions
      self.tableView = tableView
      self.submitCompletionHandler = submitCompletionHandler
      super.init()
      registerForKeyboardNotifications()
   }
   
   public func update(updateId: String, data: Any) {
      TableUIUpdater.updateTable(surveyQuestions.update(id: updateId, data: data), tableView: tableView, autoFocus: surveyQuestions.autoFocusText)
   }
   
   public func markFinished(updateId: String) {
      TableUIUpdater.updateTable(surveyQuestions.markFinished(updateId: updateId), tableView: tableView, autoFocus: surveyQuestions.autoFocusText)
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

   open func getSurveyQuestions() -> SurveyQuestions {
      return surveyQuestions
   }
   
   // MARK: keyboard methods
   
   public func updateActiveTextView(_ view: UIView) {
      self.activeTextView = view
   }
   
   func registerForKeyboardNotifications() {
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
   }
   
   func keyboardWasShown(_ notification: Notification) {
      let info = notification.userInfo
      if let kbSize = (info?[UIKeyboardFrameBeginUserInfoKey] as? CGRect)?.size {
         let contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, kbSize.height, 0)
         self.tableView.contentInset = contentInsets
         self.tableView.scrollIndicatorInsets = contentInsets
         
         if activeTextView != nil {
            var aRect = self.tableView.frame
            aRect.size.height -= kbSize.height
            let viewFrame = activeTextView!.convert(activeTextView!.bounds, to: self.tableView)
            if (!aRect.contains(viewFrame.origin)) {
               self.tableView.scrollRectToVisible(viewFrame, animated: true)
            }
         }
      }
   }
   
   func keyboardWillBeHidden(_ notification: Notification) {
      let contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0)
      self.tableView.contentInset = contentInsets
      self.tableView.scrollIndicatorInsets = contentInsets
   }
}
