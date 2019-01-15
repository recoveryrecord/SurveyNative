//
//  SurveyDataSource.swift
//  Pods
//
//  Created by Nora Mullaney on 3/15/17.
//
//

import Foundation

open class SurveyDataSource : NSObject, UITableViewDataSource {

   var surveyQuestions : SurveyQuestions
   var surveyTheme : SurveyTheme
   var tableCellDataDelegate : TableCellDataDelegate
   weak var presentationDelegate : UIViewController?

   public init(_ surveyQuestions : SurveyQuestions, surveyTheme : SurveyTheme, tableCellDataDelegate : TableCellDataDelegate, presentationDelegate: UIViewController) {
      self.surveyQuestions = surveyQuestions
      self.surveyTheme = surveyTheme
      self.tableCellDataDelegate = tableCellDataDelegate
      self.presentationDelegate = presentationDelegate
   }

   open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cellIdentifier = surveyQuestions.type(for: indexPath)
      let tableCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
      return configure(tableCell, for: cellIdentifier, indexPath: indexPath)

      /*
       If any strangeness happens with cells then uncomment this part as first thing to do with testing. Disables the reusue of cells.

      var cell : UITableViewCell?

      let surveyBundle = SurveyBundle.bundle

      switch cellIdentifier {
      case "year_picker":
         cell = YearPickerTableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier)
      case "date_picker":
         cell = DatePickerTableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier)
      case "option":
         cell = UINib(nibName: "OptionTableViewCell", bundle: SurveyBundle.bundle).instantiate(withOwner: tableView, options: nil)[0] as! OptionTableViewCell
      case "other_option":
         cell = UINib(nibName: "OtherOptionTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! OtherOptionTableViewCell
      case "text_field":
         cell = UINib(nibName: "TextFieldTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! TextFieldTableViewCell
      case "question":
         cell = UINib(nibName: "DynamicLabelTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! DynamicLabelTableViewCell
      case "segment_select":
         cell = UINib(nibName: "SelectSegmentTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! SelectSegmentTableViewCell
      case "row_header":
         cell = UINib(nibName: "TableRowHeaderTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! TableRowHeaderTableViewCell
      case "row_select":
         cell = UINib(nibName: "TableRowTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! TableRowTableViewCell
      case "dynamic_label_text_field":
         cell = UINib(nibName: "DynamicLabelTextFieldTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! DynamicLabelTextFieldTableViewCell
      case "add_text_field":
         cell = UINib(nibName: "AddTextFieldTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! AddTextFieldTableViewCell
      case "submit":
         cell = UINib(nibName: "SubmitButtonTableViewCell", bundle: surveyBundle).instantiate(withOwner: tableView, options: nil)[0] as! SubmitButtonTableViewCell
      default:
         cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier)
      }

      return configure(cell!, for: cellIdentifier, indexPath: indexPath)
      */
   }

   func configure(_ tableCell : UITableViewCell, for cellIdentifier: String, indexPath: IndexPath) -> UITableViewCell {
      switch cellIdentifier {
      case "year_picker":
         let cell = (tableCell as! YearPickerTableViewCell)
         cell.presentationDelegate = self.presentationDelegate
         cell.dataDelegate = self.tableCellDataDelegate
         cell.updateId = surveyQuestions.id(for: indexPath)
         cell.selectedYear = surveyQuestions.answer(for: indexPath) as! String?
         cell.setYearRange(minYear: surveyQuestions.minYear(for: indexPath), maxYear: surveyQuestions.maxYear(for: indexPath), numYears: surveyQuestions.numYears(for: indexPath), sortOrder: surveyQuestions.yearSortOrder(for: indexPath))
         cell.initialYear = surveyQuestions.initialYear(for: indexPath)
      case "date_picker":
         let cell = (tableCell as! DatePickerTableViewCell)
         cell.presentationDelegate = self.presentationDelegate
         cell.dataDelegate = self.tableCellDataDelegate
         cell.updateId = surveyQuestions.id(for: indexPath)
         cell.setDateRange(currentDate: surveyQuestions.date(for: indexPath), minDate: surveyQuestions.minDate(for: indexPath), maxDate: surveyQuestions.maxDate(for: indexPath), dateDiff: surveyQuestions.dateDiff(for: indexPath))
         cell.selectedDateStr = surveyQuestions.answer(for: indexPath) as! String?
      case "option":
         let cell = (tableCell as! OptionTableViewCell)
         cell.optionLabel?.text = surveyQuestions.text(for: indexPath)
         cell.surveyTheme = self.surveyTheme
         cell.setSelectionState(surveyQuestions.isOptionSelected(indexPath))
         cell.isSingleSelection = !surveyQuestions.isMultiSelect(indexPath)
      case "other_option":
         let cell = (tableCell as! OtherOptionTableViewCell)
         cell.updateId = nil
         cell.dataDelegate = self.tableCellDataDelegate
         cell.surveyTheme = self.surveyTheme
         cell.label?.text = surveyQuestions.text(for: indexPath)
         cell.isSingleSelection = !surveyQuestions.isMultiSelect(indexPath)
         let selected = surveyQuestions.isOptionSelected(indexPath)
         cell.isSelectedOption = selected
         if selected {
            cell.optionText = surveyQuestions.otherAnswer(for: indexPath)
            cell.setSelectionState(true)
         } else {
            cell.optionText = ""
         }
         cell.textField?.keyboardType = surveyQuestions.keyboardType(for: indexPath)
         cell.shouldShowNextButton = surveyQuestions.showNextButton(for: indexPath)
         cell.updateId = surveyQuestions.id(for: indexPath)
         cell.validations = surveyQuestions.validations(for: indexPath)
      case "text_field":
         let cell = (tableCell as! TextFieldTableViewCell)
         cell.updateId = nil
         cell.dataDelegate = self.tableCellDataDelegate
         cell.textFieldLabel?.text = surveyQuestions.text(for: indexPath)
         cell.textField?.keyboardType = surveyQuestions.keyboardType(for: indexPath)
         cell.maxCharacters = surveyQuestions.maxChars(for: indexPath)
         cell.validations = surveyQuestions.validations(for: indexPath)
         cell.textFieldText = surveyQuestions.partialAnswer(for: indexPath) as! String?
         cell.shouldShowNextButton = surveyQuestions.showNextButton(for: indexPath)
         cell.updateId = surveyQuestions.id(for: indexPath)
      case "next_button":
         let nextButton = UIButtonWithId(type: UIButton.ButtonType.system)
         nextButton.setTitle("Next", for: UIControl.State.normal)
         let updateId = surveyQuestions.id(for: indexPath)
         nextButton.updateId = updateId
         nextButton.frame = CGRect(x: 0, y: 0, width: 100, height: 35)
         nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: UIControl.Event.touchUpInside)
         tableCell.addSubview(nextButton)
         tableCell.accessoryView = nextButton
         tableCell.selectionStyle = UITableViewCell.SelectionStyle.none
      case "question":
         (tableCell as! DynamicLabelTableViewCell).dynamicLabel?.text = surveyQuestions.text(for: indexPath)
      case "segment_select":
         let cell = (tableCell as! SelectSegmentTableViewCell)
         cell.updateId = surveyQuestions.id(for: indexPath)
         cell.dataDelegate = self.tableCellDataDelegate
         cell.values = surveyQuestions.values(for: indexPath)
         if let answer = surveyQuestions.answer(for: indexPath) as? String {
            cell.setSelectedValue(answer)
         }
         cell.lowLabel?.text = surveyQuestions.lowTag(for: indexPath)
         cell.highLabel?.text = surveyQuestions.highTag(for: indexPath)
      case "row_header":
         (tableCell as! TableRowHeaderTableViewCell).headers = surveyQuestions.headers(for: indexPath)
      case "row_select":
         let surveyTheme = self.surveyTheme
         let cell = (tableCell as! TableRowTableViewCell)
         cell.surveyTheme = surveyTheme
         cell.updateId = surveyQuestions.id(for: indexPath)
         cell.dataDelegate = self.tableCellDataDelegate
         cell.headers = surveyQuestions.headers(for: indexPath)!
         cell.question?.text = surveyQuestions.text(for: indexPath)
         cell.selectedHeader = surveyQuestions.partialAnswer(for: indexPath) as! String?
      case "dynamic_label_text_field":
         let cell = (tableCell as! DynamicLabelTextFieldTableViewCell)
         cell.dataDelegate = self.tableCellDataDelegate
         cell.updateId = surveyQuestions.id(for: indexPath)
         cell.presentationDelegate = self.presentationDelegate
         cell.labelOptions = surveyQuestions.labelOptions(for: indexPath)
         cell.optionsMetadata = surveyQuestions.optionsMetadata(for: indexPath)
         cell.currentValue = surveyQuestions.answer(for: indexPath) as? [String : String]
         cell.keyboardType = surveyQuestions.keyboardType(for: indexPath)
         cell.validations = surveyQuestions.validations(for: indexPath)
      case "add_text_field":
         let cell = (tableCell as! AddTextFieldTableViewCell)
         cell.dataDelegate = self.tableCellDataDelegate
         cell.updateId = surveyQuestions.id(for: indexPath)
         cell.currentValues = surveyQuestions.answer(for: indexPath) as? [String]
      case "submit":
         let cell = (tableCell as! SubmitButtonTableViewCell)
         cell.dataDelegate = self.tableCellDataDelegate
         cell.submitButton?.setTitle(surveyQuestions.submitTitle(), for: .normal)
      default:
         tableCell.textLabel?.text = surveyQuestions.text(for: indexPath)
         tableCell.textLabel?.numberOfLines = 0
         tableCell.imageView?.image = surveyQuestions.image(for: indexPath)
         tableCell.selectionStyle = UITableViewCell.SelectionStyle.none
      }
      tableCell.setNeedsLayout()
      return tableCell
   }

   open func numberOfSections(in tableView: UITableView) -> Int {
      return surveyQuestions.numberOfSections()
   }

   open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return surveyQuestions.numberOfRows(for: section)
   }

   open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return surveyQuestions.headerText(section: section)
   }

   @objc open func nextButtonTapped(_ sender: UIButton) {
      if let buttonWithId = sender as? UIButtonWithId, let updateId = buttonWithId.updateId {
         self.tableCellDataDelegate.markFinished(updateId: updateId)
      }
   }
}

public class UIButtonWithId: UIButton {
   public var updateId: String?
}
