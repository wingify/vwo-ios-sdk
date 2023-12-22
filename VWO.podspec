Pod::Spec.new do |s|
	s.name              = "VWO"
	s.version           = "2.17.0"
	s.summary           = "VWO SDK for A/B Testing iOS apps."
	s.description       = "VWO iOS SDK enables you to A/B test mobile apps."
	s.documentation_url = "http://developers.vwo.com/reference#ios-sdk-reference"
	s.homepage          = "http://vwo.com"
	s.license           = { :type => 'Commercial',
                            :text => 'See http://vwo.com/terms-conditions' }
	s.author            = { 'VWO' => 'info@wingify.com' }
	s.source            = { :git => "https://github.com/wingify/vwo-ios-sdk.git",
                            :tag => s.version.to_s }
	s.platform     	    = :ios, '9.0'
    s.swift_version = '5.0'
    s.default_subspec = 'All'

    s.subspec 'Core' do |ss|
	    ss.source_files = 'VWO/**/*.{m,h}'
	end

    s.subspec 'All' do |ss|
	    ss.source_files = 'VWO/**/*.{m,h}'
	    ss.dependency 'Socket.IO-Client-Swift', '~> 15.2.0'
    end
    
end
