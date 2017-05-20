Pod::Spec.new do |s|

  s.license      = "MIT"
  s.author       = { "qqc" => "20599378@qq.com" }
  s.platform     = :ios, "8.0"
  s.requires_arc  = true

  s.name         = "QqcScan"
  s.version      = "1.0.4"
  s.summary      = "QqcScan"
  s.homepage     = "https://github.com/xukiki/QqcScan"
  s.source       = { :git => "https://github.com/xukiki/QqcScan.git", :tag => "#{s.version}" }
  
  s.source_files = 'QqcScan/*.{h,m}'
  s.resource = 'QqcScan/QqcScan.bundle'

  s.dependency 'QqcSizeDef'
  s.dependency 'UIImage-Qqc'
  s.dependency 'QqcMarginDef'
  s.dependency 'QqcUtility'
  s.dependency 'QqcComFuncDef'
  s.dependency 'QqcImagePickerController'
  s.dependency 'ZXingObjC'
  
end
