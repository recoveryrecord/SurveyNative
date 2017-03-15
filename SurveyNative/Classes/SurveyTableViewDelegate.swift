//
//  SurveyTableViewDelegate.swift
//  Pods
//
//  Created by Nora Mullaney on 3/15/17.
//
//

import Foundation

open class SurveyTableViewDelegate : NSObject, UITableViewDelegate {
   
   var surveyQuestions : SurveyQuestions
   
   public init(_ surveyQuestions : SurveyQuestions) {
      self.surveyQuestions = surveyQuestions
   }
   
   open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      TableUIUpdater.updateTable(self.surveyQuestions.selectedRowAt(indexPath), tableView: tableView)
      tableView.deselectRow(at: indexPath, animated: false)
   }
   
}
