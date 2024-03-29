//
//  PickerViewController.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/25/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate {
    @IBOutlet var pickerView: UIPickerView!
    
    var controllerDelegate: PickerViewControllerDelegate?
    var pickerDataSource: UIPickerViewDataSource?
    var pickerDelegate: UIPickerViewDelegate?
    var initialSelectedRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pickerView != nil {
            pickerView.delegate = pickerDelegate
            pickerView.dataSource = pickerDataSource
            
            if initialSelectedRow != nil {
                pickerView.selectRow(initialSelectedRow!, inComponent: 0, animated: true)
            }
            
            setColors()
        }
    }
    
    func setColors() {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                pickerView.backgroundColor = UIColor.black
            } else {
                pickerView.backgroundColor = UIColor.white
            }
        } else {
            pickerView.tintColor = UIColor.black
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColors()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        controllerDelegate?.onDone()
    }
}

public protocol PickerViewControllerDelegate : NSObjectProtocol {
    func onDone();
}
