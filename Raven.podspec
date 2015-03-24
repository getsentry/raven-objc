Pod::Spec.new do |s|
  s.name         = "Raven"
  s.version      = "1.0.1"
  s.summary      = "A client for Sentry (getsentry.com)."
  s.homepage     = "https://getsentry.com/"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "David Cramer" => "dcramer@gmail.com" }
  s.source       = { :git => "https://github.com/sblepa/raven-objc.git", :tag => s.version.to_s }
  s.source_files = ['Raven']
  s.requires_arc = true
end
