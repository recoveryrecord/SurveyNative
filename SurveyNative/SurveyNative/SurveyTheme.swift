//
//  SurveyTheme.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/23/17.
//  Copyright © 2017 recoveryrecord. All rights reserved.
//

import Foundation

public protocol SurveyTheme {
   func radioButtonSelectedImage() -> UIImage
   func radioButtonDeselectedImage() -> UIImage
   func tickBoxTickedImage() -> UIImage
   func tickBoxNotTickedImage() -> UIImage
}
