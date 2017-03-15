//
//  DefaultSurveyTheme.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/23/17.
//  Copyright © 2017 recoveryrecord. All rights reserved.
//

import Foundation

open class DefaultSurveyTheme : SurveyTheme {
   
   let surveyBundle = SurveyBundle.bundle
   
   public init() {}
   
   public func radioButtonSelectedImage() -> UIImage {
      return UIImage(named: "blue-radio-button-selected-white", in: surveyBundle, compatibleWith: nil)!
   }
   
   public func radioButtonDeselectedImage() -> UIImage {
      return UIImage(named: "blue-radio-button-deselected-white", in: surveyBundle, compatibleWith: nil)!
   }
   
   public func tickBoxTickedImage() -> UIImage {
      return UIImage(named: "blue-tick-box-ticked-white", in: surveyBundle, compatibleWith: nil)!
   }
   
   public func tickBoxNotTickedImage() -> UIImage {
      return UIImage(named: "blue-tick-box-not-ticked-white", in: surveyBundle, compatibleWith: nil)!
   }
}
