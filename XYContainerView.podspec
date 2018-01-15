Pod::Spec.new do |s|
s.name = 'XYContainerView'
s.version = '0.0.1'
s.license = 'MIT'
s.summary = 'ContainerScroll like homeView of xianyu'
s.homepage = 'https://github.com/shaohung001/XYContainerView'
s.authors = { 'shaohung001' => '767838865@qq.com' }
s.source = { :git => "https://github.com/shaohung001/XYContainerView.git", :tag => "0.0.1"}
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = "XYContainerView/XYContainerView/XYContainerView/*.{h,m}"
end
