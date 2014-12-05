Pod::Spec.new do |s|

  s.name         = "ClientError"
  s.version      = "0.0.1"
  s.summary      = "Log NSError or custom errors to the Parse.com database using the Parse iOS SDK and get error email reports"

  s.description  = <<-DESC
                   Instead of logging unexpected, unknown or unhandled errors to the console where you will never see them once your app is distributed, you can log them to your Parse.com database instead.
                   Written in Swift.
                   
                   Additionally, you will find a configurable Parse cloud code job in the ParseJobs directory in the github repo that sends emails reporting the latest ClientErrors to your inbox on a regular basis,
so you can easily keep track of them.
                   DESC

  s.homepage     = "https://github.com/apploft/ClientError"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  
  s.author       = { "Michael Kamphausen" => "michael.kamphausen@apploft.de" }
  
  s.platform     = :ios

  s.source       = { :git => "https://github.com/apploft/ClientError.git", :tag => s.version.to_s }

  s.source_files  = "Classes", "Classes/**/*.{h,m,swift}"
  s.exclude_files = "Classes/Exclude"
  
  s.requires_arc = true
  
  s.dependency   = 'Parse-iOS-SDK', '~> 1.3'

end
