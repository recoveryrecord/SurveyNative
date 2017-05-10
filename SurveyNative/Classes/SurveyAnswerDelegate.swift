//
//  SurveyAnswerDelegate.swift
//  Pods
//
//  Created by Nora Mullaney on 5/10/17.
//
//

import Foundation

public protocol SurveyAnswerDelegate {
   func question(for id: String, answer: Any)
}
