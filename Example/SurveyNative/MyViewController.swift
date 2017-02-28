//
//  MyViewController.swift
//  SurveyNativeExample
//
//  Created by Nora Mullaney on 2/23/17.
//  Copyright © 2017 recoveryrecord. All rights reserved.
//

import UIKit
import SurveyNative

class MyViewController: SurveyViewController {
   
   override func surveyJsonFile() -> String {
      return "ExampleQuestions"
   }
   
   override func surveyTitle() -> String {
      return "Example Survey"
   }
}

