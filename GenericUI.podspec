#
# Be sure to run `pod lib lint GenericUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GenericUI'
  s.version          = '0.2.5'
  s.summary          = 'Generic UI provides you with beautiful and generic UI components for your iOS projects.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
GenericUI provides you with beautiful and generic UI elements for your iOS projects. For now it just focuses on inputs and forms but there's a lot more to come.
                       DESC

  s.homepage         = 'https://github.com/tlextrait/GenericUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tlextrait' => 'thomas.lextrait@gmail.com' }
  s.source           = { :git => 'https://github.com/tlextrait/GenericUI.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'

  s.source_files = 'GenericUI/Classes/*'
  s.frameworks = 'UIKit'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.2' }
  s.swift_version = '5.2'

end
