Pod::Spec.new do |s|

s.name         = "SOCycleSrollView"
s.version      = "1.0.0"
s.summary      = "简单易用的无限轮播器. 支持横向、竖向两种滑动方式"
s.description  = <<-DESC
                    It is a cycle scroll view used on iOS, which implement by Swift 3.
                    DESC

s.homepage     = "https://github.com/pjk1129/SOCycleScroll.git"
s.license          = { :type => 'MIT', :file => 'LICENSE' }

s.platform     = :ios, "9.0"
s.author       = { 'pjk1129' => 'pjk1129@qq.com' }

s.source       = { :git => "https://github.com/pjk1129/SOCycleScroll.git", :tag => "1.0.0"}
s.source_files  = 'SOCycleSrollView/*.swift'

s.requires_arc = true

s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'

s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

end
