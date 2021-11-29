Pod::Spec.new do |s|

  s.name         = "CBORCoding"
  s.version      = "1.3.2"
  s.summary      = "A CBOR Encoder and Decoder"
  s.description  = <<-DESC
                   A lightweight framework containing a coder pair for encoding and decoding `Codable` conforming types to and from CBOR document format for iOS, macOS, tvOS, and watchOS.
                   DESC

  s.homepage     = "https://github.com/SomeRandomiOSDev/CBORCoding"
  s.license      = "MIT"
  s.author       = { "Joe Newton" => "somerandomiosdev@gmail.com" }
  s.source       = { :git => "https://github.com/SomeRandomiOSDev/CBORCoding.git", :tag => s.version.to_s }

  s.ios.deployment_target     = '9.0'
  s.macos.deployment_target   = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source            = { :git => "https://github.com/SomeRandomiOSDev/CBORCoding.git", :tag => s.version.to_s }
  s.source_files      = 'Sources/**/*.swift'
  s.swift_versions    = ['4.2', '5.0']
  s.cocoapods_version = '>= 1.7.3'

  s.dependency 'Half', '~> 1.3'

  s.test_spec 'Tests' do |ts|
    ts.ios.deployment_target     = '9.0'
    ts.macos.deployment_target   = '10.10'
    ts.tvos.deployment_target    = '9.0'
    ts.watchos.deployment_target = '2.0'

    ts.source_files              = 'Tests/CBORCodingTests/*Tests.swift'
  end

end
