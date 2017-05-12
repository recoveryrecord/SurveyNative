#
# Be sure to run `pod lib lint SurveyNative.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SurveyNative'
  s.version          = '0.1.12'
  s.summary          = 'SurveyNative is a library for creating surveys.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Supports many question types and the ability to skip questions.  The question data is provided as JSON.
                       DESC

  s.homepage         = 'https://github.com/recoveryrecord/SurveyNative'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nmullaney' => 'nora.mullaney@gmail.com' }
  s.source           = { :git => 'https://github.com/recoveryrecord/SurveyNative.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SurveyNative/Classes/**/*'
  
  s.resource_bundles = {
    'SurveyNative' => [
      'SurveyNative/Assets/*.png',
      'SurveyNative/**/*.xib'
    ]
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
