// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SurveyNative",
    platforms: [.iOS(.v10)],
    products: [.library(name: "SurveyNative",
                        targets: ["SurveyNative"])],
    dependencies: [],
    targets: [.target(name: "SurveyNative",
                      dependencies: [],
                      path: "SurveyNative/",
                      resources: [.process("Assets/blue-radio-button-deselected-white.png"),
                                  .process("Assets/blue-radio-button-selected-white@2x.png"),
                                  .process("Assets/blue-tick-box-not-ticked-white.png"),
                                  .process("Assets/blue-tick-box-not-ticked-white@2x.png"),
                                  .process("Assets/blue-tick-box-ticked-white.png"),
                                  .process("Assets/blue-tick-box-ticked-white@2x.png"),
                                  .process("Assets/blue-down-button.png"),
                                  .process("Assets/blue-down-button@2x.png"),
                                  .process("Assets/blue-radio-button-selected-white.png"),
                                  .process("Assets/blue-radio-button-deselected-white@2x.png"),
                                  .process("Classes/TableViewCells/AddTextFieldTableViewCell.xib"),
                                  .process("Classes/TableViewCells/DatePickerViewController.xib"),
                                  .process("Classes/TableViewCells/DynamicLabelTableViewCell.xib"),
                                  .process("Classes/TableViewCells/DynamicLabelTextFieldTableViewCell.xib"),
                                  .process("Classes/TableViewCells/OptionTableViewCell.xib"),
                                  .process("Classes/TableViewCells/OtherOptionTableViewCell.xib"),
                                  .process("Classes/TableViewCells/PickerViewController.xib"),
                                  .process("Classes/TableViewCells/SelectSegmentTableViewCell.xib"),
                                  .process("Classes/TableViewCells/SubmitButtonTableViewCell.xib"),
                                  .process("Classes/TableViewCells/TableRowHeaderTableViewCell.xib"),
                                  .process("Classes/TableViewCells/TableRowTableViewCell.xib"),
                                  .process("Classes/TableViewCells/TextAreaTableViewCell.xib"),
                                  .process("Classes/TableViewCells/TextFieldTableViewCell.xib")])])
