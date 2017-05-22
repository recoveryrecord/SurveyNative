//
//  Validator.swift
//  Pods
//
//  Created by Nora Mullaney on 5/22/17.
//
//

import Foundation

public protocol Validator {
   func validate(validations: [[String : Any]]?, answer: String) -> (Bool, String)
   func validate(validations: [[String : Any]]?, answers: [String : String]) -> (Bool, String)
   func validationFailed(message: String)
}
