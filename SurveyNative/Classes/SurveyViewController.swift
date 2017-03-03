//
//  SurveyViewController.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/23/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

open class SurveyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableCellDataDelegate {
   
   @IBOutlet var tableView: UITableView?
   
   var surveyQuestions : SurveyQuestions?
   
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
      
      // ensures we have no empty rows at the bottom of the table
      // Make sure the footer is as tall as the entire screen, so that we can always scroll
      // to any question
      let footer = UIView()
      var frame = CGRect()
      frame.size.width = 1
      frame.size.height = UIScreen.main.bounds.height
      footer.frame = frame
      tableView!.separatorStyle = .none
      tableView!.tableFooterView = footer
      tableView!.dataSource = self
      tableView!.delegate = self
      tableView!.allowsSelection = true
      
      tableView!.estimatedRowHeight = 80
      tableView!.rowHeight = UITableViewAutomaticDimension
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
      tapRecognizer.cancelsTouchesInView = false
      tableView!.addGestureRecognizer(tapRecognizer)
      
      registerTableViewCells()
   }
   
   public func registerTableViewCells() {
      let surveyBundle = SurveyBundle.bundle
      tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "option")
      tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "next_button")
      tableView!.register(YearPickerTableViewCell.self, forCellReuseIdentifier: "year_picker")
      tableView!.register(DatePickerTableViewCell.self, forCellReuseIdentifier: "date_picker")
      let otherOptionNib = UINib(nibName: "OtherOptionTableViewCell", bundle: surveyBundle)
      tableView!.register(otherOptionNib, forCellReuseIdentifier: "other_option")
      let textFieldNib = UINib(nibName: "TextFieldTableViewCell", bundle: surveyBundle)
      tableView!.register(textFieldNib, forCellReuseIdentifier: "text_field")
      let questionNib = UINib(nibName: "DynamicLabelTableViewCell", bundle: surveyBundle)
      tableView!.register(questionNib, forCellReuseIdentifier: "question")
      let segmentNib = UINib(nibName: "SelectSegmentTableViewCell", bundle: surveyBundle)
      tableView!.register(segmentNib, forCellReuseIdentifier: "segment_select")
      let rowHeaderNib = UINib(nibName: "TableRowHeaderTableViewCell", bundle: surveyBundle)
      tableView!.register(rowHeaderNib, forCellReuseIdentifier: "row_header")
      let rowSelectNib = UINib(nibName: "TableRowTableViewCell", bundle: surveyBundle)
      tableView!.register(rowSelectNib, forCellReuseIdentifier: "row_select")
      let dynamicLabelTextFieldNib = UINib(nibName: "DynamicLabelTextFieldTableViewCell", bundle: surveyBundle)
      tableView!.register(dynamicLabelTextFieldNib, forCellReuseIdentifier: "dynamic_label_text_field")
      let addTextFieldNib = UINib(nibName: "AddTextFieldTableViewCell", bundle: surveyBundle)
      tableView!.register(addTextFieldNib, forCellReuseIdentifier: "add_text_field")
      let submitNib = UINib(nibName: "SubmitButtonTableViewCell", bundle: surveyBundle)
      tableView!.register(submitNib, forCellReuseIdentifier: "submit")
   }
   
   func tableViewTapped(sender: UITapGestureRecognizer) {
      if sender.view as? UITextField == nil {
         tableView!.endEditing(true)
         UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
      }
   }
   
   open func numberOfSections(in tableView: UITableView) -> Int {
      return surveyQuestions!.numberOfSections()
   }
   
   open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return surveyQuestions!.numberOfRows(for: section)
   }
   
   open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return surveyQuestions?.headerText(section: section)
   }
   
   open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cellIdentifier = surveyQuestions!.type(for: indexPath)
      return configureCell(for: cellIdentifier, indexPath: indexPath)
   }
   
   public func configureCell(for cellIdentifier: String, indexPath: IndexPath) -> UITableViewCell {
      let tableCell = tableView!.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
      switch cellIdentifier {
      case "year_picker":
         (tableCell as! YearPickerTableViewCell).presentationDelegate = self
         (tableCell as! YearPickerTableViewCell).dataDelegate = self
         (tableCell as! YearPickerTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
         (tableCell as! YearPickerTableViewCell).selectedYear = surveyQuestions!.answer(for: indexPath) as! String?
         (tableCell as! YearPickerTableViewCell).setYearRange(minYear: surveyQuestions!.minYear(for: indexPath), maxYear: surveyQuestions!.maxYear(for: indexPath), numYears: surveyQuestions!.numYears(for: indexPath), sortOrder: surveyQuestions!.yearSortOrder(for: indexPath))
      case "date_picker":
         (tableCell as! DatePickerTableViewCell).presentationDelegate = self
         (tableCell as! DatePickerTableViewCell).dataDelegate = self
         (tableCell as! DatePickerTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
         (tableCell as! DatePickerTableViewCell).setDateRange(currentDate: surveyQuestions!.date(for: indexPath), minDate: surveyQuestions!.minDate(for: indexPath), maxDate: surveyQuestions!.maxDate(for: indexPath), dateDiff: surveyQuestions!.dateDiff(for: indexPath))
         (tableCell as! DatePickerTableViewCell).selectedDateStr = surveyQuestions!.answer(for: indexPath) as! String?
      case "other_option":
         (tableCell as! OtherOptionTableViewCell).updateId = nil
         (tableCell as! OtherOptionTableViewCell).dataDelegate = self
         (tableCell as! OtherOptionTableViewCell).optionImageView?.image = surveyQuestions!.image(for: indexPath)
         (tableCell as! OtherOptionTableViewCell).label?.text = surveyQuestions!.text(for: indexPath)
         let selected = surveyQuestions!.isOptionSelected(indexPath)
         (tableCell as! OtherOptionTableViewCell).isSelectedOption = selected
         if selected {
            (tableCell as! OtherOptionTableViewCell).optionText = surveyQuestions!.otherAnswer(for: indexPath)
         }
         (tableCell as! OtherOptionTableViewCell).textField?.keyboardType = surveyQuestions!.keyboardType(for: indexPath)
         (tableCell as! OtherOptionTableViewCell).shouldShowNextButton = surveyQuestions!.showNextButton(for: indexPath)
         (tableCell as! OtherOptionTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
      case "text_field":
         (tableCell as! TextFieldTableViewCell).updateId = nil
         (tableCell as! TextFieldTableViewCell).dataDelegate = self
         (tableCell as! TextFieldTableViewCell).textFieldLabel?.text = surveyQuestions!.text(for: indexPath)
         (tableCell as! TextFieldTableViewCell).textField?.keyboardType = surveyQuestions!.keyboardType(for: indexPath)
         (tableCell as! TextFieldTableViewCell).textFieldText = surveyQuestions!.partialAnswer(for: indexPath) as! String?
         (tableCell as! TextFieldTableViewCell).shouldShowNextButton = surveyQuestions!.showNextButton(for: indexPath)
         (tableCell as! TextFieldTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
      case "next_button":
         let nextButton = UIButtonWithId(type: UIButtonType.system)
         nextButton.setTitle("Next", for: UIControlState.normal)
         let updateId = surveyQuestions!.id(for: indexPath)
         nextButton.updateId = updateId
         nextButton.frame = CGRect(x: 0, y: 0, width: 100, height: 35)
         nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: UIControlEvents.touchUpInside)
         tableCell.addSubview(nextButton)
         tableCell.accessoryView = nextButton
         tableCell.selectionStyle = UITableViewCellSelectionStyle.none
      case "question":
         (tableCell as! DynamicLabelTableViewCell).dynamicLabel?.text = surveyQuestions!.text(for: indexPath)
      case "segment_select":
         (tableCell as! SelectSegmentTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
         (tableCell as! SelectSegmentTableViewCell).dataDelegate = self
         (tableCell as! SelectSegmentTableViewCell).values = surveyQuestions!.values(for: indexPath)
         if let answer = surveyQuestions!.answer(for: indexPath) as? String {
            (tableCell as! SelectSegmentTableViewCell).setSelectedValue(answer)
         }
         (tableCell as! SelectSegmentTableViewCell).lowLabel?.text = surveyQuestions!.lowTag(for: indexPath)
         (tableCell as! SelectSegmentTableViewCell).highLabel?.text = surveyQuestions!.highTag(for: indexPath)
      case "row_header":
         (tableCell as! TableRowHeaderTableViewCell).headers = surveyQuestions!.headers(for: indexPath)
      case "row_select":
         let surveyTheme = self.surveyTheme()
         (tableCell as! TableRowTableViewCell).surveyTheme = surveyTheme
         (tableCell as! TableRowTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
         (tableCell as! TableRowTableViewCell).dataDelegate = self
         (tableCell as! TableRowTableViewCell).headers = surveyQuestions!.headers(for: indexPath)!
         (tableCell as! TableRowTableViewCell).question?.text = surveyQuestions!.text(for: indexPath)
         (tableCell as! TableRowTableViewCell).selectedHeader = surveyQuestions!.partialAnswer(for: indexPath) as! String?
      case "dynamic_label_text_field":
         (tableCell as! DynamicLabelTextFieldTableViewCell).dataDelegate = self
         (tableCell as! DynamicLabelTextFieldTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
         (tableCell as! DynamicLabelTextFieldTableViewCell).presentationDelegate = self
         (tableCell as! DynamicLabelTextFieldTableViewCell).labelOptions = surveyQuestions!.labelOptions(for: indexPath)
         (tableCell as! DynamicLabelTextFieldTableViewCell).currentValue = surveyQuestions!.answer(for: indexPath) as? [String : String]
         (tableCell as! DynamicLabelTextFieldTableViewCell).keyboardType = surveyQuestions!.keyboardType(for: indexPath)
      case "add_text_field":
         (tableCell as! AddTextFieldTableViewCell).dataDelegate = self
         (tableCell as! AddTextFieldTableViewCell).updateId = surveyQuestions!.id(for: indexPath)
         (tableCell as! AddTextFieldTableViewCell).currentValues = surveyQuestions!.answer(for: indexPath) as? [String]
      case "submit":
         (tableCell as! SubmitButtonTableViewCell).dataDelegate = self
         (tableCell as! SubmitButtonTableViewCell).submitButton?.setTitle(surveyQuestions!.submitTitle(), for: .normal)
      default:
         tableCell.textLabel?.text = surveyQuestions!.text(for: indexPath)
         tableCell.textLabel?.numberOfLines = 0
         tableCell.imageView?.image = surveyQuestions!.image(for: indexPath)
         tableCell.selectionStyle = UITableViewCellSelectionStyle.none
      }
      return tableCell
   }
   
   open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      updateTable(surveyQuestions!.selectedRowAt(indexPath))
      tableView.deselectRow(at: indexPath, animated: false)
   }
   
   public func nextButtonTapped(_ sender: UIButton) {
      if let buttonWithId = sender as? UIButtonWithId, let updateId = buttonWithId.updateId {
         self.markFinished(updateId: updateId)
      }
   }
   
   func updateTable(_ changes: SectionChanges) {
      Logger.log(changes.description)
      if (changes.removeSections == nil || changes.removeSections!.isEmpty) &&
         (changes.reloadSections == nil || changes.reloadSections!.isEmpty) &&
         (changes.insertSections == nil || changes.insertSections!.isEmpty) {
         Logger.log("No table updates.", level: .info)
         return
      }
      UIView.performWithoutAnimation {
         self.tableView!.beginUpdates()
         if (changes.removeSections != nil && !changes.removeSections!.isEmpty) {
            self.tableView!.deleteSections(changes.removeSections!, with: .none)
         }
         if (changes.reloadSections != nil && !changes.reloadSections!.isEmpty) {
            self.tableView!.reloadSections(changes.reloadSections!, with: .none)
         }
         if (changes.insertSections != nil && !changes.insertSections!.isEmpty) {
            self.tableView!.insertSections(changes.insertSections!, with: .none)
         }
         self.tableView!.endUpdates()
      }
      if (changes.insertSections != nil && changes.insertSections!.count != 0) {
         // A small pause helps avoid issues with keyboard dismissal messing up the scroll
         DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let numberOfSections = self.tableView!.numberOfSections
            let scrollPath = IndexPath(row: 0, section: (self.maxIndex(changes.insertSections!))! as Int)
            self.tableView!.scrollToRow(at: scrollPath, at: UITableViewScrollPosition.top, animated: true)
         }
      }
   }
   
   func maxIndex(_ indexSet: IndexSet) -> Int? {
      if indexSet == nil || indexSet.isEmpty {
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
   
   public func update(updateId: String, data: Any) {
      updateTable(surveyQuestions!.update(id: updateId, data: data))
   }
   
   public func markFinished(updateId: String) {
      updateTable(surveyQuestions!.markFinished(updateId: updateId))
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
