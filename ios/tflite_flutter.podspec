#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tflite_flutter_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tflite_flutter'
  s.version          = '0.1.0'
  s.summary          = 'TensorFlow Lite plugin for Flutter apps.'
  s.description      = <<-DESC
TensorFlow Lite plugin for Flutter apps.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  
  s.ios.vendored_frameworks = 'TensorFlowLiteC.framework'
  #s.ios.vendored_frameworks = 'TensorFlowLiteSelectTfOps.framework'
  s.ios.deployment_target = '8.0'
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
  s.library = 'c++'
  # Fail early during build instead of not finding the library during runtime
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework TensorFlowLiteC -all_load' }
  #s.xcconfig = { 'OTHER_LDFLAGS' => '-framework TensorFlowLiteSelectTfOps -all_load' }
  #s.xcconfig = { 'OTHER_LDFLAGS' => '-framework TensorFlowLiteC -force_load TensorFlowLiteSelectTfOps' }
  
  #linking with this recommended way will cause the duplicate symbols bug. see issue-> https://github.com/tensorflow/tensorflow/issues/52042
  #s.xcconfig = { 'OTHER_LDFLAGS' => '-force_load ${PODS_ROOT}/../.symlinks/plugins/tflite_flutter/ios/TensorFlowLiteSelectTfOps.framework/TensorFlowLiteSelectTfOps' }
  
end
