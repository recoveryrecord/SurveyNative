//
//  DefaultSurveyTheme.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/23/17.
//  Copyright © 2017 recoveryrecord. All rights reserved.
//

import Foundation

class DefaultSurveyTheme : SurveyTheme {
   
   let frameworkBundle = Bundle(identifier: "com.guardiansd.recoveryrecord.SurveyNative")
   
   func radioButtonSelectedImage() -> UIImage {
      return UIImage(named: "blue-radio-button-selected-white", in: frameworkBundle, compatibleWith: nil)!
   }
   
   func radioButtonDeselectedImage() -> UIImage {
      return UIImage(named: "blue-radio-button-deselected-white", in: frameworkBundle, compatibleWith: nil)!
   }
   
   func tickBoxTickedImage() -> UIImage {
      return UIImage(named: "blue-tick-box-ticked-white", in: frameworkBundle, compatibleWith: nil)!
   }
   
   func tickBoxNotTickedImage() -> UIImage {
      return UIImage(named: "blue-tick-box-not-ticked-white", in: frameworkBundle, compatibleWith: nil)!
   }
}
