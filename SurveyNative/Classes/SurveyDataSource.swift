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
   }
   
   func configure(_ tableCell : UITableViewCell, for cellIdentifier: String, indexPath: IndexPath) -> UITableViewCell {
      switch cellIdentifier {
      case "year_picker":
         (tableCell as! YearPickerTableViewCell).presentationDelegate = self.presentationDelegate
         (tableCell as! YearPickerTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! YearPickerTableViewCell).updateId = surveyQuestions.id(for: indexPath)
         (tableCell as! YearPickerTableViewCell).selectedYear = surveyQuestions.answer(for: indexPath) as! String?
         (tableCell as! YearPickerTableViewCell).setYearRange(minYear: surveyQuestions.minYear(for: indexPath), maxYear: surveyQuestions.maxYear(for: indexPath), numYears: surveyQuestions.numYears(for: indexPath), sortOrder: surveyQuestions.yearSortOrder(for: indexPath))
         (tableCell as! YearPickerTableViewCell).initialYear = surveyQuestions.initialYear(for: indexPath)
      case "date_picker":
         (tableCell as! DatePickerTableViewCell).presentationDelegate = self.presentationDelegate
         (tableCell as! DatePickerTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! DatePickerTableViewCell).updateId = surveyQuestions.id(for: indexPath)
         (tableCell as! DatePickerTableViewCell).setDateRange(currentDate: surveyQuestions.date(for: indexPath), minDate: surveyQuestions.minDate(for: indexPath), maxDate: surveyQuestions.maxDate(for: indexPath), dateDiff: surveyQuestions.dateDiff(for: indexPath))
         (tableCell as! DatePickerTableViewCell).selectedDateStr = surveyQuestions.answer(for: indexPath) as! String?
      case "option":
         (tableCell as! OptionTableViewCell).optionLabel?.text = surveyQuestions.text(for: indexPath)
         (tableCell as! OptionTableViewCell).surveyTheme = self.surveyTheme
         (tableCell as! OptionTableViewCell).setSelectionState(surveyQuestions.isOptionSelected(indexPath))
         (tableCell as! OptionTableViewCell).isSingleSelection = !surveyQuestions.isMultiSelect(indexPath)
      case "other_option":
         (tableCell as! OtherOptionTableViewCell).updateId = nil
         (tableCell as! OtherOptionTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! OtherOptionTableViewCell).surveyTheme = self.surveyTheme
         (tableCell as! OtherOptionTableViewCell).label?.text = surveyQuestions.text(for: indexPath)
         (tableCell as! OtherOptionTableViewCell).isSingleSelection = !surveyQuestions.isMultiSelect(indexPath)
         let selected = surveyQuestions.isOptionSelected(indexPath)
         (tableCell as! OtherOptionTableViewCell).isSelectedOption = selected
         if selected {
            (tableCell as! OtherOptionTableViewCell).optionText = surveyQuestions.otherAnswer(for: indexPath)
            (tableCell as! OtherOptionTableViewCell).setSelectionState(true)
         } else {
            (tableCell as! OtherOptionTableViewCell).optionText = ""
         }
         (tableCell as! OtherOptionTableViewCell).textField?.keyboardType = surveyQuestions.keyboardType(for: indexPath)
         (tableCell as! OtherOptionTableViewCell).shouldShowNextButton = surveyQuestions.showNextButton(for: indexPath)
         (tableCell as! OtherOptionTableViewCell).updateId = surveyQuestions.id(for: indexPath)
      case "text_field":
         (tableCell as! TextFieldTableViewCell).updateId = nil
         (tableCell as! TextFieldTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! TextFieldTableViewCell).textFieldLabel?.text = surveyQuestions.text(for: indexPath)
         (tableCell as! TextFieldTableViewCell).textField?.keyboardType = surveyQuestions.keyboardType(for: indexPath)
         (tableCell as! TextFieldTableViewCell).maxCharacters = surveyQuestions.maxChars(for: indexPath)
         (tableCell as! TextFieldTableViewCell).textFieldText = surveyQuestions.partialAnswer(for: indexPath) as! String?
         (tableCell as! TextFieldTableViewCell).shouldShowNextButton = surveyQuestions.showNextButton(for: indexPath)
         (tableCell as! TextFieldTableViewCell).updateId = surveyQuestions.id(for: indexPath)
      case "next_button":
         let nextButton = UIButtonWithId(type: UIButtonType.system)
         nextButton.setTitle("Next", for: UIControlState.normal)
         let updateId = surveyQuestions.id(for: indexPath)
         nextButton.updateId = updateId
         nextButton.frame = CGRect(x: 0, y: 0, width: 100, height: 35)
         nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: UIControlEvents.touchUpInside)
         tableCell.addSubview(nextButton)
         tableCell.accessoryView = nextButton
         tableCell.selectionStyle = UITableViewCellSelectionStyle.none
      case "question":
         (tableCell as! DynamicLabelTableViewCell).dynamicLabel?.text = surveyQuestions.text(for: indexPath)
      case "segment_select":
         (tableCell as! SelectSegmentTableViewCell).updateId = surveyQuestions.id(for: indexPath)
         (tableCell as! SelectSegmentTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! SelectSegmentTableViewCell).values = surveyQuestions.values(for: indexPath)
         if let answer = surveyQuestions.answer(for: indexPath) as? String {
            (tableCell as! SelectSegmentTableViewCell).setSelectedValue(answer)
         }
         (tableCell as! SelectSegmentTableViewCell).lowLabel?.text = surveyQuestions.lowTag(for: indexPath)
         (tableCell as! SelectSegmentTableViewCell).highLabel?.text = surveyQuestions.highTag(for: indexPath)
      case "row_header":
         (tableCell as! TableRowHeaderTableViewCell).headers = surveyQuestions.headers(for: indexPath)
      case "row_select":
         let surveyTheme = self.surveyTheme
         (tableCell as! TableRowTableViewCell).surveyTheme = surveyTheme
         (tableCell as! TableRowTableViewCell).updateId = surveyQuestions.id(for: indexPath)
         (tableCell as! TableRowTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! TableRowTableViewCell).headers = surveyQuestions.headers(for: indexPath)!
         (tableCell as! TableRowTableViewCell).question?.text = surveyQuestions.text(for: indexPath)
         (tableCell as! TableRowTableViewCell).selectedHeader = surveyQuestions.partialAnswer(for: indexPath) as! String?
      case "dynamic_label_text_field":
         (tableCell as! DynamicLabelTextFieldTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! DynamicLabelTextFieldTableViewCell).updateId = surveyQuestions.id(for: indexPath)
         (tableCell as! DynamicLabelTextFieldTableViewCell).presentationDelegate = self.presentationDelegate
         (tableCell as! DynamicLabelTextFieldTableViewCell).labelOptions = surveyQuestions.labelOptions(for: indexPath)
         (tableCell as! DynamicLabelTextFieldTableViewCell).optionsMetadata = surveyQuestions.optionsMetadata(for: indexPath)
         (tableCell as! DynamicLabelTextFieldTableViewCell).currentValue = surveyQuestions.answer(for: indexPath) as? [String : String]
         (tableCell as! DynamicLabelTextFieldTableViewCell).keyboardType = surveyQuestions.keyboardType(for: indexPath)
      case "add_text_field":
         (tableCell as! AddTextFieldTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! AddTextFieldTableViewCell).updateId = surveyQuestions.id(for: indexPath)
         (tableCell as! AddTextFieldTableViewCell).currentValues = surveyQuestions.answer(for: indexPath) as? [String]
      case "submit":
         (tableCell as! SubmitButtonTableViewCell).dataDelegate = self.tableCellDataDelegate
         (tableCell as! SubmitButtonTableViewCell).submitButton?.setTitle(surveyQuestions.submitTitle(), for: .normal)
      default:
         tableCell.textLabel?.text = surveyQuestions.text(for: indexPath)
         tableCell.textLabel?.numberOfLines = 0
         tableCell.imageView?.image = surveyQuestions.image(for: indexPath)
         tableCell.selectionStyle = UITableViewCellSelectionStyle.none
      }
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
   
   open func nextButtonTapped(_ sender: UIButton) {
      if let buttonWithId = sender as? UIButtonWithId, let updateId = buttonWithId.updateId {
         self.tableCellDataDelegate.markFinished(updateId: updateId)
      }
   }
}

public class UIButtonWithId: UIButton {
   public var updateId: String?
}
