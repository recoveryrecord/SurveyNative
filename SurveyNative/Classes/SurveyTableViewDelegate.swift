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
   var heightAtIndexPath: [AnyHashable : CGFloat] = [:]
   
   public init(_ surveyQuestions : SurveyQuestions) {
      self.surveyQuestions = surveyQuestions
   }
   
   open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if let selectedCell = tableView.cellForRow(at: indexPath) as? HasSelectionState {

         let unselectedIndexPaths : [IndexPath] = self.surveyQuestions.relatedDeselectPaths(indexPath)
         for path in unselectedIndexPaths {
            if let cellWithSelectionState = tableView.cellForRow(at: path) as? HasSelectionState {
               cellWithSelectionState.setSelectionState(false)
            }

         }

         if selectedCell.isSingleSelect() {
            selectedCell.setSelectionState(true)
         } else {
            selectedCell.setSelectionState(!selectedCell.selectionState())
         }
      }
      TableUIUpdater.updateTable(self.surveyQuestions.selectedRowAt(indexPath, tableView: tableView), tableView: tableView, autoFocus: surveyQuestions.autoFocusText)
      tableView.deselectRow(at: indexPath, animated: false)
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if let height = heightAtIndexPath[key(indexPath)] {
         return height
      } else {
         return UITableViewAutomaticDimension
      }
   }
   
   public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
      if let height = heightAtIndexPath[key(indexPath)] {
         return height
      } else {
         return UITableViewAutomaticDimension
      }
   }
   
   open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let height = cell.frame.size.height
      let cellKey = key(indexPath)
      self.heightAtIndexPath[cellKey] = height
   }
   
   private func key(_ indexPath: IndexPath) -> AnyHashable {
      if self.surveyQuestions.isSubmitSection(indexPath: indexPath) {
         return "SubmitQuestion"
      }
      return self.surveyQuestions.questionPath(for: indexPath).description
   }
}
