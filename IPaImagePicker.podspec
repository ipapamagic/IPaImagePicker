#
# Be sure to run `pod lib lint IPaImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IPaImagePicker'
  s.version          = '1.0'
  s.summary          = 'A short description of IPaImagePicker.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ipapamagic@gmail.com/IPaImagePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ipapamagic@gmail.com' => 'ipapamagic@gmail.com' }
  s.source           = { :git => 'https://github.com/ipapamagic@gmail.com/IPaImagePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.3'
  s.swift_version = '5.0'
  s.source_files = 'IPaImagePicker/Classes/**/*'
  s.resource_bundles = {'IPaImagePicker' => ['IPaImagePicker/Assets/*.png','IPaImagePicker/Assets/*.storyboard','IPaImagePicker/Assets/*.xcassets','IPaImagePicker/Assets/*.xib']}
  s.dependency 'IPaAVCamera'
  s.dependency 'IPaImageTool'
  s.dependency 'IPaDesignableUI'
  s.dependency 'IPaImagePreviewer'
  s.dependency 'IPaBlockOperation'
  s.dependency 'IPaIndicator'
  # s.resource_bundles = {
  #   'IPaImagePicker' => ['IPaImagePicker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
