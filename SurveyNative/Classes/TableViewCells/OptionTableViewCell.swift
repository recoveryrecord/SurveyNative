//
//  OptionTableViewCell.swift
//  Pods
//
//  Created by Nora Mullaney on 3/27/17.
//
//

import UIKit

class OptionTableViewCell: UITableViewCell, HasSelectionState {
    
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var optionLabel: UILabel!
    
    var surveyTheme: SurveyTheme? {
        didSet {
            updateButtonImages()
        }
    }
    var dataDelegate: TableCellDataDelegate?
    var updateId: String?
    var isSingleSelection: Bool = true {
        didSet {
            updateButtonImages()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        optionButton.isSelected = false
    }
    
    public func isSingleSelect() -> Bool {
        return isSingleSelection
    }
    
    public func setSelectionState(_ selected: Bool) {
        optionButton.isSelected = selected
    }
    
    public func selectionState() -> Bool {
        return optionButton.isSelected
    }
    
    private func updateButtonImages() {
        if surveyTheme == nil {
            return
        }
        if isSingleSelection {
            optionButton.setImage(surveyTheme!.radioButtonSelectedImage(), for: .selected)
            optionButton.setImage(surveyTheme!.radioButtonDeselectedImage(), for: .normal)
        } else {
            optionButton.setImage(surveyTheme!.tickBoxTickedImage(), for: .selected)
            optionButton.setImage(surveyTheme!.tickBoxNotTickedImage(), for: .normal)
        }
    }
}
