//
//  SurveyQuestions.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/24/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import Foundation

open class SurveyQuestions {
   
   var surveyTheme : SurveyTheme
   var surveyAnswerDelegate: SurveyAnswerDelegate?
   var customConditionDelegate: CustomConditionDelegate?
   
   var questions : [[String : Any?]]
   var submitData : [String : String]
   var autoFocusText: Bool = false
   var answers: [String: Any] = [:]
   var completedMultiAnswerQ = Set<String>()
   
   var maybeSkippedQuestions : [String : [Int]]
   var skippedQuestions : [Int] = []
   var previousSkipCount : [Int]
   var subQsToShowCache: [String : [[String: Any?]]] = [:]
   var subQToParentIdMap : [String : String]
   var activeQuestion: Int = 0
   var showSubmitButton = false
   
   // MARK: setup
   
   class open func load(_ jsonFileName : String, surveyTheme: SurveyTheme) -> SurveyQuestions? {
      var loadedQuestions : SurveyQuestions? = nil
      if let path = Bundle.main.path(forResource: jsonFileName, ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
         do {
            let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any?]
            Logger.log(dict)
            loadedQuestions = SurveyQuestions(dict["questions"] as! [[String : Any?]], submitData: dict["submit"] as! [String : String], surveyTheme: surveyTheme)
            if let autoFocus = dict["auto_focus_text"] as? Bool {
               loadedQuestions?.autoFocusText = autoFocus
            }
         } catch {
            Logger.log(error.localizedDescription, level: .error)
         }
      } else {
         Logger.log("Error: Could not find questions file", level: .error)
      }
      return loadedQuestions
   }
   
   init(_ questions : [[String : Any?]], submitData: [String : String], surveyTheme: SurveyTheme) {
      self.questions = questions
      self.submitData = submitData
      self.surveyTheme = surveyTheme
      
      self.subQToParentIdMap = SurveyQuestions.calculateSubQToParentIdMap(questions)
      self.maybeSkippedQuestions = SurveyQuestions.calculatePotentialSkippedQuestions(questions)
      Logger.log("Maybe skipped: \(self.maybeSkippedQuestions)")
      self.previousSkipCount = Array(repeating: 0, count: questions.count)
   }
   
   public func setSurveyAnswerDelegate(_ surveyAnswerDelegate: SurveyAnswerDelegate) {
      self.surveyAnswerDelegate = surveyAnswerDelegate
   }
   
   public func setCustomConditionDelegate(_ customConditionDelegate: CustomConditionDelegate) {
      self.customConditionDelegate = customConditionDelegate
   }
   
   class func calculateSubQToParentIdMap(_ questions: [[String: Any?]]) -> [String : String] {
      var map : [String : String] = [:]
      for question in questions {
         if let subqs = question["sub_questions"] as? [[String : Any?]] {
            let questionId = question["id"] as! String
            for subq in subqs {
               let subqId = subq["id"] as! String
               map[subqId] = questionId
            }
         }
      }
      return map
   }
   
   // Creates a map from answerId to indexes of the affected question
   class func calculatePotentialSkippedQuestions(_ questions: [[String: Any?]]) -> [String : [Int]] {
      var potentialSkippedMap : [String: [Int]] = [:]
      for (index, question) in questions.enumerated() {
         let dependencyIds = SurveyQuestions.showDependencyIds(question)
         for answerId in dependencyIds {
            if potentialSkippedMap[answerId] == nil {
               potentialSkippedMap[answerId] = [index]
            } else {
               potentialSkippedMap[answerId]!.append(index)
            }
         }
      }

      // At this point our potentialSkippedMap is shallow (not recursive, depth: 1). Lets fix that.
      for (targetId, indexes) in potentialSkippedMap {
         for index in indexes {
            let dependencyId : String = questions[index]["id"] as! String
            let indexes : [Int] = dependencyIndexesRecurisve( questions: questions, potentialSkippedMap: potentialSkippedMap, dependencyId : dependencyId)
            potentialSkippedMap[targetId]?.append( contentsOf: indexes )
         }
      }

      // Lets remove all dupes and sort
      for (targetId, indexes) in potentialSkippedMap {
         potentialSkippedMap[targetId] = Array(Set(indexes)).sorted()
      }

      return potentialSkippedMap
   }

   class func dependencyIndexesRecurisve(questions: [[String: Any?]], potentialSkippedMap: [String: [Int]] = [:], dependencyId : String ) -> [Int] {

      if (potentialSkippedMap[dependencyId] == nil) {
         return []
      }

      var result : [Int] = []

      result.append( contentsOf: potentialSkippedMap[dependencyId]!);

      for ( index ) in potentialSkippedMap[dependencyId]! {
         let id : String = questions[index]["id"] as! String
         result.append(contentsOf: dependencyIndexesRecurisve( questions: questions, potentialSkippedMap: potentialSkippedMap, dependencyId: id))
      }

      return result
   }

   // MARK: submission
   
   func isSubmitSection(_ section : Int) -> Bool {
      if section >= self.questions.count {
         return true
      } else {
         let questionIndex = self.questionIndex(for: section)
         return questionIndex >= self.questions.count
      }
   }
   
   func isSubmitSection(indexPath : IndexPath) -> Bool {
      return isSubmitSection(indexPath.section)
   }
   
   func submitTitle() -> String {
      return self.submitData["button_title"]!
   }
   
   public func submitUrl() -> String {
      return self.submitData["url"]!
   }
   
   public func submitJson() -> [String : Any] {
      return ["answers" : self.answers]
   }
   
   // MARK: section and row info
   
   func numberOfSections() -> Int {
      return activeQuestion + 1 - self.numSkippedBefore(questionIndex: activeQuestion) + (showSubmitButton ? 1 : 0)
   }
   
   func questionIndex(for section: Int) -> Int {
      return section + self.previousSkipCount[section]
   }
   
   func numSkippedBefore(questionIndex: Int) -> Int {
      var skippedBefore : Int? = nil
      for (index, skippedQIndex) in self.skippedQuestions.enumerated() {
         if questionIndex < skippedQIndex {
            skippedBefore = index
            break
         }
      }
      if skippedBefore == nil {
         skippedBefore = self.skippedQuestions.count
      }
      return skippedBefore!
   }
   
   func section(for questionIndex: Int) -> Int {
      return questionIndex - numSkippedBefore(questionIndex: questionIndex)
   }
   
   func numberOfRows(for section: Int) -> Int {
      if isSubmitSection(section) {
         return 1
      }
      let question = self.question(section: section)
      let baseQuestionRowCount = numberOfRows(for: question)
      // We assume that sub-questions do not contain more sub-questions
      let subqsToShow = subQuestionsToShow(for: question)
      var subqRowCount = 0
      for subq in subqsToShow {
         subqRowCount = subqRowCount + numberOfRows(for: subq)
      }
      return baseQuestionRowCount + subqRowCount
   }
   
   func numberOfRows(for question: [String : Any?]) -> Int {
      switch self.questionType(for: question) {
      case "single_select":
         return 1 + numberOfOptions(for: question)
      case "multi_select":
         return 1 + numberOfOptions(for: question) + 1
      case "year_picker":
         return 2
      case "date_picker":
         return 2
      case "single_text_field":
         return 2
      case "multi_text_field":
         return 1 + numberOfFields(question: question)
      case "dynamic_label_text_field":
         return 2
      case "add_text_field":
         return 2
      case "segment_select":
         return 2
      case "table_select":
         return 2 + numberOfTableQuestions(for: question)
      default:
         return 1
      }
   }
   
   // MARK: extract basic data from questions
   
   func question(for indexPath: IndexPath) -> [String : Any?] {
      return self.question(section: indexPath.section)
   }
   
   func question(section: Int) -> [String : Any?] {
      return self.question(index: self.questionIndex(for: section))
   }
   
   func question(index: Int) -> [String : Any?] {
      return self.questions[index]
   }
   
   func question(for questionPath: QuestionPath) -> [String : Any?] {
      let topQuestion = self.question(index: questionPath.primaryQuestionIndex) as [String : Any?]
      if questionPath.subQuestionIndex != nil {
         return self.subQuestions(for: topQuestion)[questionPath.subQuestionIndex!]
      }
      return topQuestion
   }
   
   func id(for question: [String: Any?]) -> String {
      return question["id"] as! String
   }
   
   func primaryQuestionId(for questionPath: QuestionPath) -> String {
      let question = self.question(index: questionPath.primaryQuestionIndex)
      return id(for: question)
   }
   
   func subQuestionId(for questionPath: QuestionPath) -> String {
      return questionPath.subQuestionIndex == nil ? "" : self.questionId(for: questionPath)
   }
   
   func questionId(for questionPath: QuestionPath) -> String {
      let question = self.question(for: questionPath)
      return id(for: question)
   }
   
   func questionType(for questionPath: QuestionPath) -> String {
      let question = self.question(for: questionPath)
      return self.questionType(for: question)
   }
   
   func questionType(for question: [String : Any?]) -> String {
      return question["question_type"] as! String
   }
   
   // MARK: data for UI
   
   public func type(for indexPath: IndexPath) -> String {
      if isSubmitSection(indexPath : indexPath) {
         return "submit"
      }
      let questionPath = self.questionPath(for: indexPath)
      return type(for: questionPath)
   }
   
   func type(for questionPath: QuestionPath) -> String {
      let question = self.question(for: questionPath)
      let questionType = self.questionType(for: question)
      if questionPath.row() == 0 {
         return "question"
      } else if questionType == "single_select" && questionPath.row() <= numberOfOptions(for: question) {
         return isOtherOption(for: questionPath) ? "other_option" : "option"
      } else if questionType == "multi_select" && questionPath.row() <= numberOfOptions(for: question) {
         return isOtherOption(for: questionPath) ? "other_option" : "option"
      } else if questionType == "multi_select" && questionPath.row() > numberOfOptions(for: question) {
         return "next_button"
      } else if questionType == "year_picker" {
         return "year_picker"
      } else if questionType == "single_text_field" {
         return "text_field"
      } else if questionType == "multi_text_field" {
         return "text_field"
      } else if questionType == "dynamic_label_text_field" {
         return "dynamic_label_text_field"
      } else if questionType == "date_picker" {
         return "date_picker"
      } else if questionType == "segment_select" {
         return "segment_select"
      } else if questionType == "table_select" {
         return questionPath.row() == 1 ? "row_header" : "row_select"
      } else if questionType == "add_text_field" {
         return "add_text_field"
      }
      return ""
   }
   
   public func headerText(section: Int) -> String? {
      if isSubmitSection(section) {
         return nil
      }
      return self.question(section: section)["header"] as? String
   }
   
   public func text(for indexPath: IndexPath) -> String {
      let questionPath = self.questionPath(for: indexPath)
      return self.text(for: questionPath)
   }
   
   func text(for questionPath: QuestionPath) -> String {
      let type = self.type(for: questionPath)
      switch type {
      case "option", "other_option":
         return self.optionText(for: questionPath)
      case "text_field":
         let questionType = self.questionType(for: questionPath)
         if questionType == "multi_text_field" {
            let textField = self.textField(for: questionPath)
            return self.label(textField: textField)
         } else if let label = self.question(for: questionPath)["label"] as? String {
            return label
         } else {
            return ""
         }
      case "row_select":
         return self.tableQuestionTitle(for: questionPath)
      default:
         let question = self.question(for: questionPath)
         if let typeText = question[type] as? String {
            return typeText
         } else {
            return ""
         }
      }
   }
   
   func image(for indexPath: IndexPath) -> UIImage? {
      let questionPath = self.questionPath(for: indexPath)
      return self.image(for: questionPath)
   }
   
   func image(for questionPath: QuestionPath) -> UIImage? {
      let question = self.question(for: questionPath)
      let questionType = self.questionType(for: question)
      let hasOptionType : Bool = self.isOptionType(questionPath)
      if hasOptionType && self.isOptionSelected(questionPath: questionPath) {
         return (questionType == "single_select") ? surveyTheme.radioButtonSelectedImage() : surveyTheme.tickBoxTickedImage()
      } else if hasOptionType {
         return (questionType == "single_select") ? surveyTheme.radioButtonDeselectedImage() : surveyTheme.tickBoxNotTickedImage()
      }
      return nil
   }
   
   func showNextButton(for indexPath: IndexPath) -> Bool {
      let question = self.question(for: indexPath)
      let questionType = self.questionType(for: question)
      switch questionType {
         case "multi_select":
            return false
         case "multi_text_field":
            return indexPath.row == (self.numberOfRows(for: question) - 1)
      default:
         return true
      }
   }
   
   func keyboardType(for indexPath: IndexPath) -> UIKeyboardType {
      let questionPath = self.questionPath(for: indexPath)
      let questionType = self.questionType(for: questionPath)
      var inputType: String = "default"
      if questionType == "multi_text_field" {
         let textField = self.textField(for: questionPath)
         inputType = self.inputType(textField: textField)
      } else if questionType == "single_text_field" || questionType == "dynamic_label_text_field" || questionType == "add_text_field" {
         inputType = self.question(for: questionPath)["input_type"] as? String ?? "default"
      } else if questionType == "single_select" {
         let option = self.option(for: questionPath)
         inputType = self.otherOptionType(option: option)
      }
      switch inputType {
      case "number":
         return UIKeyboardType.numberPad
      default:
         return UIKeyboardType.default
      }
   }
   
   // MARK: sub-questions
   
   func subQuestions(for question: [String: Any?]) -> [[String : Any?]] {
      if let subqs = question["sub_questions"] as? [[String : Any?]] {
         return subqs
      } else {
         return []
      }
   }
   
   func subQuestionsToShow(for question: [String: Any?]) -> [[String : Any?]] {
      let questionId = self.id(for: question)
      if let subQs = self.subQsToShowCache[questionId] {
         return subQs
      }
      let subquestions = subQuestions(for: question)
      let subQs = subquestions.filter({ self.shouldShow(question: $0) })
      self.subQsToShowCache[questionId] = subQs
      return subQs
   }
   
   func shouldShow(question: [String: Any?]) -> Bool {
      if let condition = question["show_if"] as? [String : Any] {
         return conditionMet(condition)
      }
      return true
   }
   
   func conditionMet(_ condition : [String : Any]) -> Bool {
      if let answerId = condition["id"] as? String {
         let operation : String = condition["operation"] as! String
         let value : Any = condition["value"]!
         var answer = self.answer(for: answerId)
         if let dictAnswer = answer as? [String : String], let subid = condition["subid"] as? String {
            answer = dictAnswer[subid]
         }
         switch operation {
         case "equals":
            let result = areEqual(value as? NSObject, answer as? NSObject)
            return result
         case "not equals":
            let result = areNotEqual(value as? NSObject, answer as? NSObject)
            return result
         case "greater than", "greater than or equal to", "less than", "less than or equal to":
            return SurveyQuestions.numberComparison(answer: answer, value: value, operation: operation)
         case "contains":
            return SurveyQuestions.contains(value as! NSObject, answer as? [NSObject])
         case "not contains":
            return !SurveyQuestions.contains(value as! NSObject, answer as? [NSObject])
         default:
            Logger.log("Unable to check condition for unknown operation \"\(operation)\", assuming false", level: .error)
            return false
         }
      } else if let subconditions = condition["subconditions"] as? [[String : Any]] {
         let operation : String = condition["operation"] as! String
         switch operation {
            case "or":
            for subcondition in subconditions {
               if conditionMet(subcondition) == true {
                  return true
               }
            }
            return false
            case "and":
               for subcondition in subconditions {
                  if conditionMet(subcondition) == false {
                     return false
                  }
               }
               return true
         default:
            Logger.log("Error: Could not handle operation: \(operation)!", level: .error)
            return true
         }
      } else if let customCondition = condition["operation"] as? String, customCondition == "custom" {
         if customConditionDelegate == nil {
            Logger.log("CustomConditionDelegate is not set, assuming false", level: .error)
            return false
         }
         let ids = condition["ids"] as? [String] ?? []
         let extra = condition["extra"] as? [String : Any]
         var customAnswers : [String : Any] = [:]
         for id in ids {
            customAnswers[id] = self.answer(for: id)
         }
         return customConditionDelegate!.isConditionMet(answers: customAnswers, extra: extra)
      } else {
         Logger.log("Error: Poorly constructed condition: \(condition)", level: .error)
         return true
      }
   }
   
   class func numberComparison(answer: Any?, value: Any, operation: String) -> Bool {
      if answer != nil, let numAnswer = number(for: answer!), let numValue = SurveyQuestions.number(for: value) {
         
         switch operation {
         case "greater than":
            return numAnswer > numValue
         case "greater than or equal to":
               return numAnswer >= numValue
         case "less than":
               return numAnswer < numValue
         case "less than or equal to":
               return numAnswer <= numValue
         default:
            Logger.log("Error: unexpected operation \(operation)", level: .error)
            return false
         }
      }
      Logger.log("Error: Invalid number for comparison", level: .error)
      return false
   }
   
   class func number(for value: Any) -> Double? {
      if let _ = value as? Double {
         return (value as! Double)
      } else if let strValue = value as? String {
         return Double(strValue)
      } else if let intValue = value as? Int {
         return Double(intValue)
      } else if let fltValue = value as? Float {
         return Double(fltValue)
      }
      Logger.log("Error: Unable to convert value \(value) to number", level: .error)
      return nil
   }
   
   class func contains<T : Equatable>(_ value : T, _ container : [T]?) -> Bool {
      return container == nil ? false : container!.contains(value)
   }

   class func showDependencyIds(_ question: [String : Any?]) -> [String] {
      if let condition = question["show_if"] as? [String : Any] {
         return SurveyQuestions.dependencyIds(for: condition)
      }
      return []
   }
   
   class func dependencyIds(for condition : [String : Any]) -> [String] {
      var dependencyIds : [String] = []
      if let id = condition["id"] as? String {
         dependencyIds.append(id)
      } else if let subconditions = condition["subconditions"] as? [[String : Any]] {
         subconditions.forEach({ dependencyIds.append(contentsOf: SurveyQuestions.dependencyIds(for: $0)) })
      } else if let ids = condition["ids"] as? [String] {
         dependencyIds.append(contentsOf: ids)
      }
      return dependencyIds
   }
   
   func areEqual<T : Equatable>(_ value1 : T?, _ value2 : T?) -> Bool {
      if value1 == nil && value2 == nil {
         return true
      } else if value1 == nil || value2 == nil {
         return false
      }
      return value1 == value2
   }
   
   func areNotEqual<T : Equatable>(_ value1 : T?, _ value2 : T?) -> Bool {
      if value1 == nil && value2 == nil {
         return false
      } else if value1 == nil || value2 == nil {
         return true
      }
      return value1 != value2
   }
   
   // The IndexPath is always relative to what's showing, but the QuestionPath is absolute -- no matter
   // what is showing, an idential QuestionPath will always get you to the same point in the data
   func questionPath(for indexPath: IndexPath) -> QuestionPath {
      let question = self.question(for: indexPath)
      let questionId = self.id(for: question)
      let questionIndex = self.questionIndex(for: indexPath.section)
      let baseRowCount = self.numberOfRows(for: question)
      if indexPath.row < baseRowCount {
         return QuestionPath(primaryQuestionIndex: questionIndex, rowToPrimary: indexPath.row)
      }
      var subQuestionIndex = 0
      var rowsExamined = baseRowCount
      let subQuestions = self.subQuestions(for: question)
      let cachedShownSubQsIds = self.shownSubQIds(for: questionId)
      for subq in subQuestions {
         if (cachedShownSubQsIds == nil && !shouldShow(question: subq)) ||
            (cachedShownSubQsIds != nil && !cachedShownSubQsIds!.contains(self.id(for: subq))) {
            subQuestionIndex = subQuestionIndex + 1
            continue
         }
         let subRowCount = self.numberOfRows(for: subq)
         if indexPath.row < (rowsExamined + subRowCount) {
            return QuestionPath(primaryQuestionIndex: questionIndex, subQuestionIndex: subQuestionIndex, rowToSub: (indexPath.row - rowsExamined))
         } else {
            subQuestionIndex = subQuestionIndex + 1
            rowsExamined = rowsExamined + subRowCount
         }
      }
      // Getting to this point indicates unexpected failure
      assertionFailure("Unable to build QuestionPath for \(indexPath)")
      return QuestionPath(primaryQuestionIndex: questionIndex, rowToPrimary: indexPath.row)
   }
   
   func shownSubQIds(for questionId : String) -> [String]? {
      let cachedShownSubQsIds = self.subQsToShowCache[questionId]
      if cachedShownSubQsIds != nil {
         let ids = cachedShownSubQsIds!.map( { self.id(for: $0)} )
         return ids
      }
      return nil
   }
   
   func indexPath(for questionPath: QuestionPath) -> IndexPath {
      if questionPath.subQuestionIndex == nil {
         return IndexPath(row: questionPath.rowToPrimary!, section: self.section(for: questionPath.primaryQuestionIndex))
      }
      let primaryQuestion = self.question(index: questionPath.primaryQuestionIndex)
      var rowCount = self.numberOfRows(for: primaryQuestion)
      let subQuestions = self.subQuestionsToShow(for: primaryQuestion)
      for i in 0 ..< questionPath.subQuestionIndex! {
         rowCount = rowCount + self.numberOfRows(for: subQuestions[i])
      }
      rowCount = rowCount + questionPath.rowToSub!
      return IndexPath(row: rowCount, section: self.section(for: questionPath.primaryQuestionIndex))
   }
   
   // MARK: options
   
   func options(for question: [String : Any?]) -> [AnyHashable] {
      return question["options"] as! [AnyHashable]
   }
   
   func simpleOptions(for questionPath: QuestionPath) -> [String] {
      let question = self.question(for: questionPath)
      let options = self.options(for: question)
      return options.map( {$0 as? String}).filter( {$0 != nil} ) as! [String]
   }
   
   func numberOfOptions(for question: [String : Any?]) -> Int {
      return options(for: question).count
   }
   
   func option(for questionPath: QuestionPath) -> AnyHashable {
      let question = self.question(for: questionPath)
      let options = self.options(for: question)
      return options[questionPath.row() - 1]
   }
   
   func optionText(for questionPath: QuestionPath) -> String {
      return self.optionText(option: self.option(for: questionPath))
   }
   
   func optionText(option: AnyHashable) -> String {
      if let title = option as? String {
         return title
      } else if let optionDict = option as? [String : Any] {
         return optionDict["title"] as! String
      } else {
         return ""
      }
   }
   
   func otherOptionType(option: AnyHashable) -> String {
      if let optionDict = option as? [String : Any] {
         return optionDict["type"] as! String
      } else {
         return ""
      }
   }
   
   func isOptionType(_ questionPath: QuestionPath) -> Bool {
      let type = self.type(for: questionPath)
      return type == "option" || type == "other_option"
   }
   
   func isOtherOption(for questionPath: QuestionPath) -> Bool {
      let option = self.option(for: questionPath)
      return (option as? [String : Any]) != nil
   }
   
   public func isOptionSelected(_ indexPath: IndexPath) -> Bool {
      let questionPath = self.questionPath(for: indexPath)
      return isOptionSelected(questionPath: questionPath)
   }
   
   func isOptionSelected(questionPath: QuestionPath) -> Bool {
      let answerText = self.optionText(for: questionPath)
      if let answer = self.answer(for: questionPath) as? String {
         return answer == answerText
      } else if let answer = self.answer(for: questionPath) as? [String : String] {
         return answer[answerText] != nil
      } else if let answers = self.answer(for: questionPath) as? [String] {
         if answers.contains(answerText) {
            return true
         } else if self.isOtherOption(for: questionPath) {
            let simpleOptions = self.simpleOptions(for: questionPath)
            for answer in answers {
               if !simpleOptions.contains(answer) {
                  return true
               }
            }
         }
         return false
      } else {
         return false
      }
   }
   
   public func isMultiSelect(_ indexPath: IndexPath) -> Bool {
      let questionPath = self.questionPath(for: indexPath)
      return self.questionType(for: questionPath) == "multi_select"
   }
   
   public func relatedDeselectPaths(_ indexPath: IndexPath) -> [IndexPath] {
      var deselectPaths : [IndexPath] = []
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      let questionType = self.questionType(for: questionPath)
      if questionType != "single_select" {
         return []
      }
      let rows = numberOfOptions(for: question) + 1
      for index in 1..<rows {
         if index == questionPath.row() {
            continue
         }
         let indexQP = questionPath.subQuestionIndex == nil
            ? QuestionPath(primaryQuestionIndex: questionPath.primaryQuestionIndex, rowToPrimary: index)
            : QuestionPath(primaryQuestionIndex: questionPath.primaryQuestionIndex, subQuestionIndex: questionPath.subQuestionIndex!, rowToSub: index)
         if isOptionSelected(questionPath: indexQP) {
            deselectPaths.append(self.indexPath(for: indexQP))
         }
      }
      return deselectPaths
   }
   
   // MARK: text input fields
   
   func numberOfFields(question: [String : Any?]) -> Int {
      let fields = question["fields"] as! [[String : String]]
      return fields.count
   }
   
   func textFields(for questionPath: QuestionPath) -> [[String : String]] {
      let question = self.question(for: questionPath)
      return question["fields"] as! [[String : String]]
   }
   
   func textField(for questionPath: QuestionPath) -> [String : String] {
      let textFields = self.textFields(for: questionPath)
      let index = questionPath.row() - 1
      return textFields[index]
   }
   
   func label(textField: [String : String]) -> String {
      return textField["label"]!
   }
   
   func inputType(textField: [String : String]) -> String {
      return textField["input_type"]!
   }
   
   func maxChars(for indexPath: IndexPath) -> Int? {
      let questionPath = self.questionPath(for: indexPath)
      let type = self.type(for: questionPath)
      if type != "text_field" {
         return nil
      }
      let questionType = self.questionType(for: questionPath)
      if questionType == "multi_text_field" {
         let textField = self.textField(for: questionPath)
         return maxChars(textField)
      } else {
         let question = self.question(for: questionPath)
         return maxChars(question)
      }
   }
   
   func maxChars(_ textField: [String : Any?]) -> Int? {
      if let maxChars = textField["max_chars"] as? String {
         return Int(maxChars)
      } else {
         return Int.max
      }
   }

   func validations(for indexPath: IndexPath) -> [[String : Any]] {
      let questionPath = self.questionPath(for: indexPath)
      let type = self.type(for: questionPath)
      if type != "text_field" && type != "dynamic_label_text_field" && type != "other_option" {
         return []
      }
      let question = self.question(for: questionPath)

      if type == "other_option" {
         let option = self.option(for: questionPath) as! [String : Any]
         return validations(option)
      }
      return validations(question)
   }

   func validations(_ question: [String : Any?]) -> [[String : Any]] {
      if let validations = question["validations"] as? [[String : Any]] {
         return validations
      } else {
         return []
      }
   }
   
   // MARK: segment_select fields
   
   public func values(for indexPath : IndexPath) -> [String] {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["values"] as! [String]
   }
   
   public func lowTag(for indexPath: IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["low_tag"] as! String?
   }
   
   public func highTag(for indexPath: IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["high_tag"] as! String?
   }
   
   // MARK: table_select fields
   
   public func headers(for indexPath: IndexPath) -> [String]? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["options"] as! [String]?
   }
   
   func numberOfTableQuestions(for question: [String : Any?]) -> Int {
      return tableQuestions(for: question).count
   }
   
   func tableQuestions(for question: [String : Any?]) -> [[String : String]] {
      return question["table_questions"] as! [[String : String]]
   }
   
   func tableQuestion(for questionPath : QuestionPath) -> [String : String] {
      let question = self.question(for: questionPath)
      let tableQuestions = self.tableQuestions(for: question)
      let tqIndex = questionPath.row() - 2
      return tableQuestions[tqIndex]
   }
   
   func tableQuestionTitle(for questionPath : QuestionPath) -> String {
      let tableQuestion = self.tableQuestion(for: questionPath)
      return tableQuestion["title"]!
   }
   
   func tableQuestionId(for questionPath : QuestionPath) -> String {
      let tableQuestion = self.tableQuestion(for: questionPath)
      return tableQuestion["id"]!
   }
   
   // MARK: dynamic label text field
   
   func labelOptions(for indexPath : IndexPath) -> [AnyHashable] {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["label_options"] as! [AnyHashable]
   }
   
   func labelOptionTypes(for indexPath : IndexPath) -> [String]? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["label_option_types"] as? [String]
   }
   
   func optionsMetadata(for indexPath : IndexPath) -> [String : Any]? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["options_metadata"] as? [String: Any]
   }
   
   // MARK: year picker
   func minYear(for indexPath : IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["min_year"] as? String
   }
   
   func maxYear(for indexPath : IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["max_year"] as? String
   }
   
   func numYears(for indexPath : IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["num_years"] as? String
   }
   
   func yearSortOrder(for indexPath : IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["sort_order"] as? String
   }
   
   func initialYear(for indexPath: IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["initial_year"] as? String
   }
   
   // MARK: date picker
   func date(for indexPath : IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["date"] as? String
   }
   
   func minDate(for indexPath : IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["min_date"] as? String
   }
   
   func maxDate(for indexPath : IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["max_date"] as? String
   }

   func dateDiff(for indexPath : IndexPath) -> [String : Int]? {
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      return question["date_diff"] as? [String : Int]
   }
   
   // MARK: answers
   
   func hasAnswer(for questionPath: QuestionPath) -> Bool {
      let answer = self.answer(for: questionPath)
      let question = self.question(for: questionPath)
      return isCompleteAnswer(answer, question: question)
   }
   
   func hasAnswer(for question: [String: Any?]) -> Bool {
      let answer = self.answer(for: question)
      return isCompleteAnswer(answer, question : question)
   }
   
   func isCompleteAnswer(_ answer: Any?, question: [String : Any?]) -> Bool {
      let questionId = self.id(for: question)
      let questionType = self.questionType(for: question)
      if let stringAnswer = answer as? String {
         return !stringAnswer.isEmpty
      } else if let _ = answer as? [String] {
         if questionType == "add_text_field" {
            return true
         }
         return self.completedMultiAnswerQ.contains(questionId)
      } else if let dict = answer as? [String : String] {
         if questionType == "single_select", otherValue(dict) != "" {
            return true
         } else if questionType == "dynamic_label_text_field" {
            var complete = true
            for (_, value) in dict {
               if value == "" {
                  complete = false
                  break
               }
            }
            return complete
         } else if questionType == "table_select" {
            return self.numberOfTableQuestions(for: question) == dict.count
         }
         return self.completedMultiAnswerQ.contains(questionId)
      } else {
         return answer != nil
      }
   }
   
   // Returns the value for an "other" answer in a single select question
   func otherValue(_ answerDict: [String : String]) -> String {
      for (_, element) in answerDict.enumerated() {
         return element.value
      }
      return ""
   }
   
   public func answer(for indexPath: IndexPath) -> Any? {
      let questionPath = self.questionPath(for: indexPath)
      return self.answer(for: questionPath)
   }
   
   func answer(for questionPath: QuestionPath) -> Any? {
      return self.answer(for: question(for: questionPath))
   }
   
   func answer(for question: [String: Any?]) -> Any? {
      return self.answer(for: id(for: question))
   }
   
   func answer(for id: String) -> Any? {
      return self.answers[id]
   }
   
   func partialAnswer(for indexPath: IndexPath) -> Any? {
      let questionPath = self.questionPath(for: indexPath)
      let questionType = self.questionType(for: questionPath)
      let fullAnswer = self.answer(for: questionPath)
      if questionType == "multi_text_field" {
         let field = self.textField(for: questionPath)
         let label = self.label(textField: field)
         let dictAnswer = fullAnswer as? [String : String]
         return dictAnswer?[label]
      } else if questionType == "table_select" {
         let tableQuestionId = self.tableQuestionId(for: questionPath)
         let dictAnswer = fullAnswer as? [String : String]
         return dictAnswer?[tableQuestionId]
      } else {
         return fullAnswer
      }
   }
   
   func isAnswer(_ indexPath: IndexPath) -> Bool {
      let question = self.question(for: indexPath)
      let answer = self.answer(for: question)
      return answer != nil && (answer as! String) == self.text(for: indexPath)
   }
   
   func isQuestionFullyAnswered(_ primaryQuestionIndex: Int) -> Bool {
      let primaryQuestion = self.question(index: primaryQuestionIndex)
      if !self.hasAnswer(for: primaryQuestion) {
         return false
      }
      for subq in self.subQuestionsToShow(for: primaryQuestion) {
         if !self.hasAnswer(for: subq) {
            return false
         }
      }
      return true
   }
   
   func answerQuestion(_ questionPath: QuestionPath, data: Any) {
      let question = self.question(for: questionPath)
      self.answerQuestion(self.id(for:question), data: data)
   }
   
   func answerQuestion(_ questionId: String, data: Any) {
      self.answers[questionId] = data
      self.subQsToShowCache.removeValue(forKey: questionId)
      if let parentId = self.subQToParentIdMap[questionId] {
         // ensures we recalculate for any inter-dependent sub-questions
         self.subQsToShowCache.removeValue(forKey: parentId)
      }
      if self.surveyAnswerDelegate != nil {
         surveyAnswerDelegate!.question(for: questionId, answer: data)
      }
      Logger.log("Answers so far: \(self.answers)")
   }
   
   // Update the list of skipped questions, based on the newly answered question
   // Also updates the previousSkipCount array (which can be derived from the skippedQuestionsArray.
   // It keeps track of the number of skipped questions that have been skipped previous to the question
   // at the current index.
   func updateSkippedQuestions(_ answeredQuestionId: String) -> (skipped: IndexSet, unSkippedQ: [Int]) {
      var skipped = IndexSet()
      var unSkippedQ = [Int]()
      // we need a copy because we need to keep self.skippedQuestions the same while we calculate all the changes
      var skippedQuestionsList = self.skippedQuestions
      if let maybeSkipChangedIndices = self.maybeSkippedQuestions[answeredQuestionId] {
         var skippedIndex = 0
         
         for maybeIndex in maybeSkipChangedIndices {
            while skippedQuestionsList.count > skippedIndex && skippedQuestionsList[skippedIndex] < maybeIndex {
               skippedIndex = skippedIndex + 1
            }
            let isSkipped = (skippedQuestionsList.count > skippedIndex) && (skippedQuestionsList[skippedIndex] == maybeIndex)
            let question = self.question(index: maybeIndex)
            let shouldShow = self.shouldShow(question: question)
            if !shouldShow && !isSkipped {
               skippedQuestionsList.insert(maybeIndex, at: skippedIndex)
               if maybeIndex <= activeQuestion {
                  skipped.insert(section(for: maybeIndex))
               }
            } else if shouldShow && isSkipped {
               skippedQuestionsList.remove(at: skippedIndex)
               unSkippedQ.append(maybeIndex)
            }
         }
         self.skippedQuestions = skippedQuestionsList
         
         self.previousSkipCount = []
         var lastQIndex = -1
         for (skipIndex, questionIndex) in self.skippedQuestions.enumerated() {
            self.previousSkipCount.append(contentsOf: Array(repeating: skipIndex, count: questionIndex - lastQIndex - 1))
            lastQIndex = questionIndex
         }
         let remainingCount = self.questions.count - self.previousSkipCount.count
         self.previousSkipCount.append(contentsOf: Array(repeating: self.skippedQuestions.count, count: remainingCount))
      }
      Logger.log("Skipped Questions: \(self.skippedQuestions)")
      return (skipped, unSkippedQ)
   }

   
   func toggleAnswer(_ questionId: String, data: Any) {
      let answerToToggle = data as! String
      var currentAnswer = self.answer(for: questionId) as? [String]
      if currentAnswer == nil {
         currentAnswer = [answerToToggle]
      } else if let removeIndex = currentAnswer!.index(of: answerToToggle) {
         currentAnswer!.remove(at: removeIndex)
      } else {
         currentAnswer!.append(answerToToggle)
      }
      self.answerQuestion(questionId, data: currentAnswer!)
   }
   
   func updateOtherAnswer(questionPath: QuestionPath, data: Any) {
      let newOtherAnswer = data as! String
      let questionId = self.questionId(for: questionPath)
      var currentAnswer = self.answer(for: questionId) as? [String]
      let currentOtherAnswer = self.otherAnswer(for: questionPath)
      if currentAnswer == nil {
         currentAnswer = [newOtherAnswer]
         self.answerQuestion(questionId, data: currentAnswer!)
         return
      }
      if currentOtherAnswer != nil, let removeIndex = currentAnswer!.index(of: currentOtherAnswer!) {
         currentAnswer!.remove(at: removeIndex)
      }
      currentAnswer!.append(newOtherAnswer)
      self.answerQuestion(questionId, data: currentAnswer!)
   }
   
   public func otherAnswer(for indexPath: IndexPath) -> String? {
      let questionPath = self.questionPath(for: indexPath)
      return otherAnswer(for: questionPath)
   }
   
   func otherAnswer(for questionPath: QuestionPath) -> String? {
      if !isOtherOption(for: questionPath) {
         return nil
      }
      let simpleOptions = self.simpleOptions(for: questionPath)
      let completeAnswer = self.answer(for: questionPath)
      if let stringAnswer = completeAnswer as? String {
         return simpleOptions.contains(stringAnswer) ? nil : stringAnswer
      } else if let answerList = completeAnswer as? [String] {
         for answer in answerList {
            if !simpleOptions.contains(answer) {
               return answer
            }
         }
      } else if let answerDict = completeAnswer as? [String : String] {
         let otherKey = self.optionText(for: questionPath)
         return answerDict[otherKey]
      }
      return nil
   }
   
   func emptyAnswer(for questionType : String) -> Any {
      switch questionType {
      case "multi_select":
         return []
      case "multi_text_field", "dynamic_label_text_field":
         return [:]
      default:
         return ""
      }
   }
   
   func addAnswer(questionPath: QuestionPath, data: Any) {
      let questionType = self.questionType(for: questionPath)
      if questionType != "multi_text_field" && questionType != "table_select" {
         Logger.log("This method is only for multi_text_field or table_select", level: .warning)
         return
      }
      let questionId = self.questionId(for: questionPath)
      var inputId : String = ""
      if questionType == "multi_text_field" {
         let textField = self.textField(for: questionPath)
         inputId = self.label(textField: textField)
      } else if questionType == "table_select" {
         inputId = self.tableQuestionId(for: questionPath)
      }
      let value = data as! String
      var currentAnswer = self.answer(for: questionPath) as? [String : String]
      if currentAnswer == nil {
         currentAnswer = [inputId : value]
      } else {
         currentAnswer![inputId] = value
      }
      self.answerQuestion(questionId, data: currentAnswer!)
   }
   
   // Mark: Unique id for row and figuring out row/section from unique id
   
   // returns an id of the for question_index:sub_question_index:row
   func id(for indexPath: IndexPath) -> String {
      let questionPath = self.questionPath(for: indexPath)
      let subString = questionPath.subQuestionIndex == nil ? "" : String(questionPath.subQuestionIndex!)
      return String(format: "%d:%@:%d", questionPath.primaryQuestionIndex, subString, questionPath.row())
   }
   
   // Mark: Update data and inform which how data should be re-calculated
   
   public func selectedRowAt(_ indexPath: IndexPath, tableView: UITableView) -> SectionChanges {
      var sectionChanges = SectionChanges()
      let questionPath = self.questionPath(for: indexPath)
      let question = self.question(for: questionPath)
      let questionType = self.questionType(for: question)
      let type = self.type(for: questionPath)
      if questionType == "single_select" && isOptionType(questionPath) {
         if type == "option" {
            let data : Any = self.text(for: questionPath)
            self.answerQuestion(questionPath, data: data)
         } else {
            if let otherOptionCell = tableView.cellForRow(at: indexPath) as? OtherOptionTableViewCell {
               let text = otherOptionCell.textField.text ?? ""
               let data : Any = [self.optionText(for: questionPath) : text]
               self.answerQuestion(questionPath, data: data)
            }
         }
         let numRows = self.numberOfRows(for: questionPath.primaryQuestionIndex)
         let (skipped, unSkippedQ) = updateSkippedQuestions(self.id(for: question))
         sectionChanges.removeSections = skipped
         var unSkippedSet = self.activeIndexSet(for: unSkippedQ)
         self.sectionsToInsert(questionPath: questionPath).forEach( {unSkippedSet.insert($0) })
         sectionChanges.insertSections = unSkippedSet
         sectionChanges.scrollPath = calculateScrollPath(sectionChanges)
         let newNumRows = self.numberOfRows(for: questionPath.primaryQuestionIndex)
         if newNumRows != numRows {
            sectionChanges.reloadSections = IndexSet(integer: indexPath.section)
         }
         return sectionChanges
      } else if questionType == "multi_select" && isOptionType(questionPath) {
         let data = type == "option" ? self.text(for: questionPath) : self.otherAnswer(for: questionPath) ?? ""
         self.toggleAnswer(self.id(for: question), data: data)
         let (skipped, unSkippedQ) = updateSkippedQuestions(self.id(for: question))
         sectionChanges.removeSections = skipped
         sectionChanges.insertSections = self.activeIndexSet(for: unSkippedQ)
         sectionChanges.scrollPath = calculateScrollPath(sectionChanges)
         return sectionChanges
      }
      return sectionChanges
   }
   
   func activeIndexSet(for questionIndicies: [Int]) -> IndexSet {
      var set : IndexSet = IndexSet()
      for index in questionIndicies {
         if index <= activeQuestion {
            set.insert(self.section(for: index))
         }
      }
      return set
   }
   
   // Call this only AFTER answering the question
   func sectionsToInsert(questionPath: QuestionPath) -> IndexSet {
      if activeQuestion >= (self.questions.count - 1) && isQuestionFullyAnswered(activeQuestion) && !showSubmitButton {
         showSubmitButton = true
         return IndexSet(integer: self.section(for: (activeQuestion + 1)))
      } else if activeQuestion >= (self.questions.count - 1) {
         return IndexSet()
      }
      let isActiveQuestionSkipped = self.skippedQuestions.contains(activeQuestion)
      let activeStateChanged = isActiveQuestionSkipped || (activeQuestion == questionPath.primaryQuestionIndex && self.isQuestionFullyAnswered(activeQuestion))
      if !activeStateChanged {
         return IndexSet()
      }
      activeQuestion = activeQuestion + 1
      while self.skippedQuestions.contains(activeQuestion) && activeQuestion < (self.questions.count - 1) {
         activeQuestion = activeQuestion + 1
      }
      if self.skippedQuestions.contains(activeQuestion) {
         showSubmitButton = true
         return IndexSet(integer: self.section(for: (activeQuestion + 1)))
      } else {
         return IndexSet(integer: self.section(for: activeQuestion))
      }
   }
   
   func questionPath(updateId: String) -> QuestionPath {
      let idArr = updateId.characters.split(separator: ":", omittingEmptySubsequences: false).map(String.init)
      let primaryQuestionIndex = Int(idArr[0])
      let subQuestionIndex = Int(idArr[1])
      let row = Int(idArr[2])
      return subQuestionIndex == nil ? QuestionPath(primaryQuestionIndex: primaryQuestionIndex!, rowToPrimary: row!) : QuestionPath(primaryQuestionIndex: primaryQuestionIndex!, subQuestionIndex: subQuestionIndex!, rowToSub: row!)
   }
   
   public func update(id: String, data : Any) -> SectionChanges {
      let questionPath = self.questionPath(updateId: id)
      return update(questionPath, data: data)
   }
   
   func update(_ questionPath : QuestionPath, data : Any) -> SectionChanges {
      var sectionChanges = SectionChanges()
      let questionType = self.questionType(for: self.question(for: questionPath))
      switch questionType {
      case "multi_select":
         self.updateOtherAnswer(questionPath: questionPath, data: data)
      case "multi_text_field":
         self.addAnswer(questionPath: questionPath, data: data)
      case "table_select":
         self.addAnswer(questionPath: questionPath, data: data)
      case "single_select":
         if self.isOtherOption(for: questionPath) {
            self.answerQuestion(questionPath, data: [self.optionText(for: questionPath) : data])
         } else {
            self.answerQuestion(questionPath, data: data)
         }
      default:
         self.answerQuestion(questionPath, data: data)
      }
      let (skipped, unSkippedQ) = updateSkippedQuestions(self.questionId(for: questionPath))
      sectionChanges.removeSections = skipped
      var insertSet = self.activeIndexSet(for: unSkippedQ)
      self.sectionsToInsert(questionPath: questionPath).forEach({ insertSet.insert($0) })
      sectionChanges.insertSections = insertSet
      sectionChanges.scrollPath = calculateScrollPath(sectionChanges)
      return sectionChanges
   }
   
   public func update(_ indexPath : IndexPath, data : Any) -> SectionChanges {
      let questionPath = self.questionPath(for: indexPath)
      return update(questionPath, data: data)
   }
   
   public func markFinished(updateId: String) -> SectionChanges {
      var sectionChanges = SectionChanges()
      let questionPath = self.questionPath(updateId: updateId)
      let questionId = self.questionId(for: questionPath)
      var insertSet = IndexSet()
      // Make sure we indicate that the question was answered even if nothing was checked
      if self.answer(for: questionId) == nil {
         let type = self.questionType(for: self.question(for: questionPath))
         let emptyAnswer = self.emptyAnswer(for: type)
         self.answerQuestion(questionId, data: emptyAnswer)
         let (skipped, unSkippedQ) = updateSkippedQuestions(questionId)
         sectionChanges.removeSections = skipped
         self.activeIndexSet(for: unSkippedQ).forEach({ insertSet.insert($0) })
      }
      self.completedMultiAnswerQ.insert(questionId)
      Logger.log("multi-answer complete: \(self.completedMultiAnswerQ)")
      self.sectionsToInsert(questionPath: questionPath).forEach({ insertSet.insert($0) })
      sectionChanges.insertSections = insertSet
      sectionChanges.scrollPath = calculateScrollPath(sectionChanges)
      return sectionChanges
   }
   
   private func calculateScrollPath(_ sectionChanges: SectionChanges) -> IndexPath? {
      // Find first unanswered question
      for section in 0...activeQuestion {
         if isSubmitSection(section) {
            return IndexPath(row: 0, section: section)
         }
         let questionIndex = self.questionIndex(for: section)
         if !self.isQuestionFullyAnswered(questionIndex) {
            return IndexPath(row: 0, section: section)
         }
      }
      return nil
   }
}

public struct SectionChanges {
   var reloadSections : IndexSet?
   var insertSections : IndexSet?
   var removeSections : IndexSet?
   var scrollPath : IndexPath?
}

extension SectionChanges: CustomStringConvertible {
   public var description: String {
      let reloadStr = SectionChanges.string(for: reloadSections)
      let insertStr = SectionChanges.string(for: insertSections)
      let removeStr = SectionChanges.string(for: removeSections)
      return "SectionChanges: reloadSection: \(reloadStr), insertSections:  \(insertStr),  removeSections:  \(removeStr))"
   }
   
   static func string(for indexSet: IndexSet?) -> String {
      var str : String = ""
      if indexSet == nil {
         return "nil"
      }
      for index in indexSet! {
         str.append("\(index) ")
      }
      return str
   }
}

public class QuestionPath : NSObject, NSCopying {
   var primaryQuestionIndex: Int
   var rowToPrimary: Int?
   var subQuestionIndex: Int?
   var rowToSub: Int?
   
   public init(primaryQuestionIndex: Int, rowToPrimary: Int) {
      self.primaryQuestionIndex = primaryQuestionIndex
      self.rowToPrimary = rowToPrimary
   }
   
   public init(primaryQuestionIndex: Int, subQuestionIndex: Int, rowToSub: Int) {
      self.primaryQuestionIndex = primaryQuestionIndex
      self.subQuestionIndex = subQuestionIndex
      self.rowToSub = rowToSub
   }
   
   required public init(_ questionPath: QuestionPath) {
      self.primaryQuestionIndex = questionPath.primaryQuestionIndex
      self.rowToPrimary = questionPath.rowToPrimary
      self.subQuestionIndex = questionPath.subQuestionIndex
      self.rowToSub = questionPath.rowToSub
   }
   
   // Convenience method for finding the most relevant row index
   public func row() -> Int {
      return self.subQuestionIndex == nil ? self.rowToPrimary! : self.rowToSub!
   }
   
   public func copy(with zone: NSZone? = nil) -> Any {
      return type(of:self).init(self)
   }
   
   static func == (lhs: QuestionPath, rhs: QuestionPath) -> Bool {
      return lhs.primaryQuestionIndex == rhs.primaryQuestionIndex &&
         lhs.rowToPrimary == rhs.rowToPrimary &&
         lhs.subQuestionIndex == rhs.subQuestionIndex &&
         lhs.rowToSub == rhs.rowToSub
   }
   
   override public var description : String {
      if subQuestionIndex != nil {
         return "Path: primary: \(primaryQuestionIndex), sub: \(subQuestionIndex!), row: \(row())"
      } else {
         return "Path: primary: \(primaryQuestionIndex), row: \(row())"
      }
   }
}


