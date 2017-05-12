//
//  CustomConditionDelegate.swift
//  Pods
//
//  Created by Nora Mullaney on 5/11/17.
//
//

import Foundation

public protocol CustomConditionDelegate {
   func isConditionMet(answers: [String: Any], extra: [String: Any]?) -> Bool
}
