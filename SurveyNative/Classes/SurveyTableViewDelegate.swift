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
   var heightAtIndexPath = NSMutableDictionary()
   
   public init(_ surveyQuestions : SurveyQuestions) {
      self.surveyQuestions = surveyQuestions
   }
   
   open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      TableUIUpdater.updateTable(self.surveyQuestions.selectedRowAt(indexPath), tableView: tableView)
      tableView.deselectRow(at: indexPath, animated: false)
   }
   
   open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if let height = heightAtIndexPath.object(forKey: key(indexPath)) as? NSNumber {
         return CGFloat(height.floatValue)
      } else {
         return UITableViewAutomaticDimension
      }
   }
   
   open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
      if let height = heightAtIndexPath.object(forKey: key(indexPath)) as? NSNumber {
         return CGFloat(height.floatValue)
      } else {
         return UITableViewAutomaticDimension
      }
   }
   
   open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let height = cell.frame.size.height
      self.heightAtIndexPath.setObject(height, forKey: key(indexPath))
   }
   
   private func key(_ indexPath: IndexPath) -> NSCopying {
      if self.surveyQuestions.isSubmitSection(indexPath: indexPath) {
         return NSString(string: "SubmitQuestion")
      }
      return self.surveyQuestions.questionPath(for: indexPath)
   }
}
