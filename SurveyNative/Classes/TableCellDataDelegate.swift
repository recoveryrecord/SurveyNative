//
//  TableCellDataDelegate.swift
//  Pods
//
//  Created by Nora Mullaney on 3/15/17.
//
//

import Foundation

public protocol TableCellDataDelegate {
   func update(updateId: String, data: Any)
   func markFinished(updateId: String)
   func updateUI()
   func submitData()
}
