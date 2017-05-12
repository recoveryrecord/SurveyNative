//
//  MyViewController.swift
//  SurveyNativeExample
//
//  Created by Nora Mullaney on 2/23/17.
//  Copyright © 2017 recoveryrecord. All rights reserved.
//

import UIKit
import SurveyNative

class MyViewController: SurveyViewController, SurveyAnswerDelegate, CustomConditionDelegate {
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.setSurveyAnswerDelegate(self)
      self.setCustomConditionDelegate(self)
   }
   
   override func surveyJsonFile() -> String {
      return "ExampleQuestions"
   }
   
   override func surveyTitle() -> String {
      return "Example Survey"
   }
   
   func question(for id: String, answer: Any) {
      print("Question: \(id) has answer: \(answer)")
   }
   
   func isConditionMet(answers: [String: Any], extra: [String: Any]?) -> Bool {
      let id = extra!["id"] as! String
      if id == "check_age" {
         if let birthYearStr = answers["birthyear"] as? String, let ageStr = answers["age"] as? String {
            let birthYear = Int(birthYearStr)
            let age = Int(ageStr)
            let wiggleRoom = extra!["wiggle_room"] as? Int
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: date)
            let currentYear =  components.year
            return abs(birthYear! + age! - currentYear!) > wiggleRoom!
         } else {
            return false
         }
      } else {
         Logger.log("Unknown custom condition check: \(id)")
         return false
      }
   }
}

