#
# Be sure to run `pod lib lint MMStripeCardScan.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMStripeCardScan'
  s.version          = '1.5.4'
  s.summary          = 'Fork of StripeCardScan to support expiry dates and DNI detection'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Modified CardScanSheet and SimpleScanViewController to expect expiryMonth and expiryYear. Also adds DNI scanning'

  s.homepage         = 'https://github.com/egarroMADE/MMStripeCardScan'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'egarroMADE' => 'esteban@mademediacorp.com' }
  s.source           = { :git => 'https://github.com/egarroMADE/MMStripeCardScan.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.requires_arc = true

  s.source_files = 'MMStripeCardScan/Classes/**/*'
  s.swift_versions = ['5.0']
  s.dependency 'StripeCore', '24.6.0'

  s.resource_bundles = {
    'MMStripeCardScan' => ['MMStripeCardScan/Classes/Resources/**/*.{lproj,mlmodelc}']
  }

  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHITECTURES[sdk=iphonesimulator*]' => 'x86_64',
    'VALID_ARCHS' => 'arm64',
    'ARCHS' => 'arm64'
  }

  s.user_target_xcconfig = {
    'EXCLUDED_ARCHITECTURES[sdk=iphonesimulator*]' => 'x86_64'
  }
  
  s.exclude_files = [
    'MMStripeCardScan/Classes/Resources/**/*.espresso.weights',
    'MMStripeCardScan/Classes/Resources/**/*.bin',
    'MMStripeCardScan/Classes/Resources/**/*.macbinary',
    'MMStripeCardScan/Classes/Resources/**/*.json',           # New
    'MMStripeCardScan/Classes/Resources/**/*.espresso.net',   # New  
    'MMStripeCardScan/Classes/Resources/**/*.espresso.shape'  # New
  ]

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.weak_frameworks = 'AVKit', 'CoreML', 'VideoToolbox', 'Vision', 'AVFoundation'
  
  # Preserve the Core ML model structure
  s.preserve_paths = 'MMStripeCardScan/Classes/Resources/**/*.mlmodelc'

end
