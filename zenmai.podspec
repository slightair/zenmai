Pod::Spec.new do |s|
  s.name         = "zenmai"
  s.version      = "0.0.3"
  s.summary      = "zenmai task manager."
  s.homepage     = "https://github.com/slightair/zenmai"
  s.license      = 'MIT'
  s.author       = { "slightair" => "arksutite@gmail.com" }
  s.source       = { :git => "https://github.com/slightair/zenmai.git", :tag => "0.0.3" }
  s.platform     = :ios, '5.0'
  s.source_files = 'zenmai/*.{h,m}'
  s.requires_arc = true
end
