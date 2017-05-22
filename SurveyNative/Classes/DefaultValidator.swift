//
//  DefaultValidator.swift
//  Pods
//
//  Created by Nora Mullaney on 5/22/17.
//
//

import Foundation

public class DefaultValidator : Validator {
    
    var surveyQuestions : SurveyQuestions
    var failedDelegate : ValidationFailedDelegate
    
    init(surveyQuestions: SurveyQuestions, failedDelegate : ValidationFailedDelegate) {
        self.surveyQuestions = surveyQuestions
        self.failedDelegate = failedDelegate
    }
    
    public func validate(validations: [[String : Any]]?, answer: String) -> (Bool, String) {
        if validations == nil {
            return (true, "")
        }
        for validation in validations! {
            if (!conditionMet(validation, answer: answer)) {
                let message : String = validation["on_fail_message"] as! String
                return (false, message)
            }
        }
        return (true, "")
    }
    
    public func validate(validations: [[String : Any]]?, answers: [String : String]) -> (Bool, String) {
        if validations == nil {
            return (true, "")
        }
        for validation in validations! {
            let answer = answers[validation["for_label"] as! String]
            if answer == nil {
                continue
            }
            if (!conditionMet(validation, answer: answer!)) {
                let message : String = validation["on_fail_message"] as! String
                return (false, message)
            }
        }
      return (true, "")
    }
    
    public func conditionMet(_ condition : [String : Any], answer : String ) -> Bool {
        
        let operationType : String = condition["operation"] as! String
        var value : Any? = condition["value"]
        let questionId : String? = condition["answer_to_question_id"] as! String?
        
        if (questionId != nil) {
            value = self.surveyQuestions.answer(for: questionId!)!
        }
        
        if (value == nil) {
            Logger.log("Unable to check condition for unknown operation \"\(operationType)\" as value is nil, assuming false", level: .error)
            return false
        }
        
        switch operationType {
        case "greater than", "greater than or equal to", "less than", "less than or equal to":
            return SurveyQuestions.numberComparison(answer: answer, value: value!, operation: operationType)
        default:
            Logger.log("Unable to check condition for unknown operation \"\(operationType)\", assuming false", level: .error)
            return false
        }
    }
    
    public func validationFailed(message: String) {
        failedDelegate.validationFailed(message: message)
    }
}
