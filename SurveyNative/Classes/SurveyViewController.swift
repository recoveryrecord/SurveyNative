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
      
      // ensures we have no empty rows at the bottom of the table
      // Make sure the footer is as tall as the entire screen, so that we can always scroll
      // to any question
      let footer = UIView()
      var frame = CGRect()
      frame.size.width = 1
      frame.size.height = UIScreen.main.bounds.height
      footer.frame = frame
      
      tableView!.allowsSelection = true
      tableView!.separatorStyle = .none
      tableView!.tableFooterView = footer
      tableView!.estimatedRowHeight = 80
      tableView!.rowHeight = UITableViewAutomaticDimension
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
      tapRecognizer.cancelsTouchesInView = false
      tableView!.addGestureRecognizer(tapRecognizer)
      
      registerTableViewCells()
      self.dataSource = SurveyDataSource(surveyQuestions!, surveyTheme: self.surveyTheme(), tableCellDataDelegate: self, presentationDelegate: self)
      tableView!.dataSource = dataSource
      self.delegate = SurveyTableViewDelegate(surveyQuestions!)
      tableView!.delegate = self.delegate
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
