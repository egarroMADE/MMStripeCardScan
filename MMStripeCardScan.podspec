#
# Be sure to run `pod lib lint MMStripeCardScan.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMStripeCardScan'
  s.version          = '1.2.0'
  s.summary          = 'Fork of StripeCardScan to support expiry dates'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Modified CardScanSheet and SimpleScanViewController to expect expiryMonth and expiryYear'

  s.homepage         = 'https://github.com/egarroMADE/MMStripeCardScan'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'egarroMADE' => 'esteban@mademediacorp.com' }
  s.source           = { :git => 'https://github.com/egarroMADE/MMStripeCardScan.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.requires_arc = true

  s.source_files = 'MMStripeCardScan/Classes/**/*'
  s.swift_versions = ['5.0']
  s.dependency 'StripeCore', '23.28.1'

  s.resource_bundles = {
    'MMStripeCardScan' => ['MMStripeCardScan/Classes/Resources/**/*.{lproj,mlmodelc}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.weak_frameworks = 'AVKit', 'CoreML', 'VideoToolbox', 'Vision', 'AVFoundation'
  
end
