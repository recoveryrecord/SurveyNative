//
//  TableRowHeaderTableViewCell.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/15/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class TableRowHeaderTableViewCell: UITableViewCell {

   @IBOutlet var header1 : UILabel?
   @IBOutlet var header2 : UILabel?
   @IBOutlet var header3 : UILabel?
   
   let defaultFont = UIFont.systemFont(ofSize: 14.0)
   let minFontSize : CGFloat = 10.0
   
   var headers : [String]? {
      didSet {
         if headers == nil {
            return
         }
         if headers!.count > 0 {
            header1?.text = headers![0]
            resizeFont(header1!)
         }
         if headers!.count > 1 {
            header2?.text = headers![1]
            resizeFont(header2!)
         }
         if headers!.count > 2 {
            header3?.text = headers![2]
            resizeFont(header3!)
         }
      }
   }
   
   // These are multi-line, so they won't auto-shrink, but we want to try to shrink if
   // the label would wrap in the middle of a word
   func resizeFont(_ label: UILabel) {
      label.font = defaultFont
      var currentFontSize = defaultFont.pointSize
      let words = label.text?.split{ $0 == " "}.map(String.init)
      while(hasOverflow(label, words: words!) &&  currentFontSize > minFontSize) {
         currentFontSize = currentFontSize - 1.0
         label.font = UIFont.systemFont(ofSize: currentFontSize)
      }
      // If no matter how much we shrink the text, the word still wraps, might as well
      // make it big
      if hasOverflow(label, words: words!) {
         label.font = defaultFont
      }
   }
   
   func hasOverflow(_ label: UILabel, words: [String]) -> Bool {
      for word in words {
         let nsWord: NSString = word as NSString
        let size: CGSize = nsWord.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): label.font as Any]))
         if (size.width > label.bounds.size.width) {
            return true
         }
      }
      return false
   }    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
