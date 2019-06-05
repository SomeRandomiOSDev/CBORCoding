Pod::Spec.new do |s|
  
  s.name         = "CBORCoding"
  s.version      = "1.0.1"
  s.summary      = "A CBOR Encoder and Decoder"
  s.description  = <<-DESC
                   A lightweight framework containing a coder pair for encoding and decoding `Codable` conforming types to and from CBOR document format for iOS, macOS, tvOS, and watchOS.
                   DESC
  
  s.homepage     = "https://github.com/SomeRandomiOSDev/CBORCoding"
  s.license      = "MIT"
  s.author       = { "Joseph Newton" => "somerandomiosdev@gmail.com" }

  s.ios.deployment_target     = '8.0'
  s.macos.deployment_target   = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source        = { :git => "https://github.com/SomeRandomiOSDev/CBORCoding.git", :tag => s.version.to_s }
  s.source_files  = 'CBORCoding/**/*.swift'
  s.frameworks    = 'Foundation'
  s.swift_version = '5.0'
  s.requires_arc  = true
  
end
