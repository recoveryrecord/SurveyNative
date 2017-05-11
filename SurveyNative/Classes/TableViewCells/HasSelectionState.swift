//
//  HasSelectionState.swift
//  Pods
//
//  Created by Nora Mullaney on 5/11/17.
//
//

import Foundation

public protocol HasSelectionState {
   func isSingleSelect() -> Bool
   func setSelectionState(_ isSelected: Bool)
   func selectionState() -> Bool
}
