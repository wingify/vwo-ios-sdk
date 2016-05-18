Pod::Spec.new do |s|
s.name             = "VWO"
s.version          = "1.4.7"
s.summary          = "VWO SDK for A/B Testing iOS apps."
s.description      = "VWO iOS SDK enables you to A/B test mobile apps."
s.homepage         = "http://vwo.com"
s.license          = { :type => 'Commercial', :text => 'See http://vwo.com/terms-conditions' }
s.author           = { 'VWO' => 'info@wingify.com' }
s.source          = { :git => "https://github.com/wingify/vwo-ios-sdk.git", :tag => s.version.to_s }
s.social_media_url = "http://twitter.com/wingify"
s.platform     	   = :ios, '7.0'
s.requires_arc 	   = true
s.source_files     = 'vwo-sdk/**/*.{m,h}'
s.xcconfig 		   = { 'OTHER_LDFLAGS' => '-ObjC' }
s.prefix_header_file = 'vwo-sdk/VWO-Prefix.pch'
end
