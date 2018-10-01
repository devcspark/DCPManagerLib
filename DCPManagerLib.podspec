#
# Be sure to run `pod lib lint DCPManagerLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DCPManagerLib'
  s.version          = '0.1.4'
  s.summary          = 'DCPManagerLib is a library for simple use of CoreLocation API.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

  DCPManagerLib is a library for simple use of CoreLocation API.
  And.. We will continue to add various APIs to make it easier to use.

                       DESC

  s.homepage         = 'https://github.com/devcspark/DCPManagerLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ChunsooPark' => 'devcspark@gmail.com' }
  s.source           = { :git => 'https://github.com/devcspark/DCPManagerLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'DCPManagerLib/**/*'
  
  s.swift_version = '4.0'
  
  # s.resource_bundles = {
  #   'DCPManagerLib' => ['DCPManagerLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
