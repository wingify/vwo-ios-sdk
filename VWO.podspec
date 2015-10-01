Pod::Spec.new do |s|
s.name             = "VWO"
s.version          = "1.2.0"
s.summary          = "VWO SDK for A/B Testing iOS apps."

s.description      = "VWO iOS SDK enables you to A/B test mobile apps."
s.homepage         = "http://vwo.com"
s.license          = { :type => 'Commercial', :text => 'See http://vwo.com/terms-conditions' }
s.author           = { 'VWO' => 'info@wingify.com' }
s.source           = { :git => "https://github.com/agarwalswapnil/VWO-iOS-SDK.git", :tag => s.version.to_s }
s.social_media_url = "http://twitter.com/wingify"

s.platform     = :ios, '7.0'
s.requires_arc = true

s.public_header_files = "Pod/VWO.framework/**/*.h"
s.frameworks = "MobileCoreServices", "SystemConfiguration", "JavaScriptCore"
#s.library = "sqlite3"
s.vendored_frameworks = "Pod/VWO.framework"
s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }
end
