//
//  TableUIUpdater.swift
//  Pods
//
//  Created by Nora Mullaney on 3/15/17.
//
//

import Foundation

// Methods for inserting, removing, and reloading sections of a UITableView
open class TableUIUpdater {
   
   static open func setupTable(_ tableView: UITableView) {
      tableView.allowsSelection = true
      tableView.separatorStyle = .none
      
      setupFooter(for: tableView)
      
      tableView.estimatedRowHeight = 80
      tableView.rowHeight = UITableViewAutomaticDimension
      
      registerTableViewCells(tableView)
   }
   
   /**
    * Make sure the footer is as tall as the entire screen, so that we can always scroll to any question
    */
   static func setupFooter(for tableView: UITableView) {
      let footer = UIView()
      var frame = CGRect()
      frame.size.width = 1
      frame.size.height = UIScreen.main.bounds.height
      footer.frame = frame
      tableView.tableFooterView = footer
   }
   
   public static func registerTableViewCells(_ tableView: UITableView) {
      let surveyBundle = SurveyBundle.bundle
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "next_button")
      tableView.register(YearPickerTableViewCell.self, forCellReuseIdentifier: "year_picker")
      tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: "date_picker")
      let optionNib = UINib(nibName: "OptionTableViewCell", bundle: surveyBundle)
      tableView.register(optionNib, forCellReuseIdentifier: "option")
      let otherOptionNib = UINib(nibName: "OtherOptionTableViewCell", bundle: surveyBundle)
      tableView.register(otherOptionNib, forCellReuseIdentifier: "other_option")
      let textFieldNib = UINib(nibName: "TextFieldTableViewCell", bundle: surveyBundle)
      tableView.register(textFieldNib, forCellReuseIdentifier: "text_field")
      let questionNib = UINib(nibName: "DynamicLabelTableViewCell", bundle: surveyBundle)
      tableView.register(questionNib, forCellReuseIdentifier: "question")
      let segmentNib = UINib(nibName: "SelectSegmentTableViewCell", bundle: surveyBundle)
      tableView.register(segmentNib, forCellReuseIdentifier: "segment_select")
      let rowHeaderNib = UINib(nibName: "TableRowHeaderTableViewCell", bundle: surveyBundle)
      tableView.register(rowHeaderNib, forCellReuseIdentifier: "row_header")
      let rowSelectNib = UINib(nibName: "TableRowTableViewCell", bundle: surveyBundle)
      tableView.register(rowSelectNib, forCellReuseIdentifier: "row_select")
      let dynamicLabelTextFieldNib = UINib(nibName: "DynamicLabelTextFieldTableViewCell", bundle: surveyBundle)
      tableView.register(dynamicLabelTextFieldNib, forCellReuseIdentifier: "dynamic_label_text_field")
      let addTextFieldNib = UINib(nibName: "AddTextFieldTableViewCell", bundle: surveyBundle)
      tableView.register(addTextFieldNib, forCellReuseIdentifier: "add_text_field")
      let submitNib = UINib(nibName: "SubmitButtonTableViewCell", bundle: surveyBundle)
      tableView.register(submitNib, forCellReuseIdentifier: "submit")
   }
   
   static func updateTable(_ changes: SectionChanges, tableView : UITableView, autoFocus: Bool) {
      Logger.log(changes.description)
      if (changes.removeSections == nil || changes.removeSections!.isEmpty) &&
         (changes.reloadSections == nil || changes.reloadSections!.isEmpty) &&
         (changes.insertSections == nil || changes.insertSections!.isEmpty) {
         Logger.log("No table updates.", level: .info)
         return
      }
      // The CATransaction lines below ensure that the tableView updates complete before we
      // attempt to scroll the tableView
      CATransaction.begin()
      CATransaction.setCompletionBlock {
         if changes.scrollPath != nil {
            // A small pause helps avoid issues with keyboard dismissal messing up the scroll
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
               UIView.animate(withDuration: 0.5, delay: 0.02, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                  tableView.scrollToRow(at: changes.scrollPath!, at: UITableViewScrollPosition.top, animated: false)
               }, completion: { (success) in
                  // Fixes a bug where sometimes rows don't appear if offscreen
                  // at beginning of scroll
                  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                     let contentOffset = tableView.contentOffset;
                     tableView.reloadData()
                     tableView.layoutIfNeeded()
                     tableView.setContentOffset(contentOffset, animated: false)
                     // So far, it's always the row #1 that should be activated. May not always be true
                     let activeCellPath = IndexPath(row: 1, section: changes.scrollPath!.section)
                     if let activatingCell = tableView.cellForRow(at: activeCellPath) as? TableViewCellActivating, autoFocus == true {
                        activatingCell.cellDidActivate()
                     }
                  }
               })
            }
         }
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
      CATransaction.commit()
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
