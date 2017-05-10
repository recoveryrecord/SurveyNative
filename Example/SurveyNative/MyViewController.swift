//
//  MyViewController.swift
//  SurveyNativeExample
//
//  Created by Nora Mullaney on 2/23/17.
//  Copyright © 2017 recoveryrecord. All rights reserved.
//

import UIKit
import SurveyNative

class MyViewController: SurveyViewController, SurveyAnswerDelegate {
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.setSurveyAnswerDelegate(self)
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
}

