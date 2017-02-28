//
//  SurveyBundle.swift
//  Pods
//
//  Created by Nora Mullaney on 2/27/17.
//
//

import Foundation

public class SurveyBundle {
   
   static var bundle : Bundle = SurveyBundle.initBundle()
   
   class func initBundle() -> Bundle {
      let podBundle = Bundle(for: SurveyBundle.self)
      let bundleURL = podBundle.url(forResource: "SurveyNative", withExtension: "bundle")
      return Bundle(url: bundleURL!)!
   }
}
