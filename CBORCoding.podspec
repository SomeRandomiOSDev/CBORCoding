Pod::Spec.new do |s|

  s.name         = "CBORCoding"
  s.version      = "1.4.0"
  s.summary      = "A CBOR Encoder and Decoder"
  s.description  = <<-DESC
                   A lightweight framework containing a coder pair for encoding and decoding `Codable` conforming types to and from CBOR document format for iOS, macOS, tvOS, and watchOS.
                   DESC

  s.homepage     = "https://github.com/SomeRandomiOSDev/CBORCoding"
  s.license      = "MIT"
  s.author       = { "Joe Newton" => "somerandomiosdev@gmail.com" }
  s.source       = { :git => "https://github.com/SomeRandomiOSDev/CBORCoding.git", :tag => s.version.to_s }

  s.ios.deployment_target     = '12.0'
  s.macos.deployment_target   = '10.13'
  s.tvos.deployment_target    = '12.0'
  s.watchos.deployment_target = '4.0'

  s.source            = { :git => "https://github.com/SomeRandomiOSDev/CBORCoding.git", :tag => s.version.to_s }
  s.source_files      = 'Sources/**/*.swift'
  s.swift_versions    = ['5.0']
  s.cocoapods_version = '>= 1.7.3'

  s.dependency 'Half', '~> 1.4'

end
