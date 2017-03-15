//
//  TableUIUpdater.swift
//  Pods
//
//  Created by Nora Mullaney on 3/15/17.
//
//

import Foundation

// Methods for inserting, removing, and reloading sections of a UITableView
class TableUIUpdater {
   
   static func updateTable(_ changes: SectionChanges, tableView : UITableView) {
      Logger.log(changes.description)
      if (changes.removeSections == nil || changes.removeSections!.isEmpty) &&
         (changes.reloadSections == nil || changes.reloadSections!.isEmpty) &&
         (changes.insertSections == nil || changes.insertSections!.isEmpty) {
         Logger.log("No table updates.", level: .info)
         return
      }
      UIView.performWithoutAnimation {
         tableView.beginUpdates()
         if (changes.removeSections != nil && !changes.removeSections!.isEmpty) {
            tableView.deleteSections(changes.removeSections!, with: .none)
         }
         if (changes.reloadSections != nil && !changes.reloadSections!.isEmpty) {
            tableView.reloadSections(changes.reloadSections!, with: .none)
         }
         if (changes.insertSections != nil && !changes.insertSections!.isEmpty) {
            tableView.insertSections(changes.insertSections!, with: .none)
         }
         tableView.endUpdates()
      }
      if (changes.insertSections != nil && changes.insertSections!.count != 0) {
         // A small pause helps avoid issues with keyboard dismissal messing up the scroll
         DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let scrollPath = IndexPath(row: 0, section: (self.maxIndex(changes.insertSections!))! as Int)
            tableView.scrollToRow(at: scrollPath, at: UITableViewScrollPosition.top, animated: true)
         }
      }
   }
   
   static func maxIndex(_ indexSet: IndexSet) -> Int? {
      if indexSet.isEmpty {
         return nil
      }
      var max : Int = indexSet.first!
      for value in indexSet {
         if value > max {
            max = value
         }
      }
      return max
   }
 
}
