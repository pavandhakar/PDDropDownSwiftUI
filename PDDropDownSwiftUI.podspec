Pod::Spec.new do |spec|

  spec.name         = "PDDropDownSwiftUI"
<<<<<<< HEAD
  spec.version      = "1.1.3"
=======
  spec.version      = "1.1.1"
>>>>>>> c90d1a0 (Convert project to Swift Package)

  spec.summary      = "A reusable dropdown component for SwiftUI."

  spec.description  = <<-DESC
                       PDDropDownSwiftUI is a reusable and customizable
                       dropdown component built for SwiftUI applications.
                     DESC

  spec.homepage     = "https://github.com/pavandhakar/PDDropDownSwiftUI"

  spec.license      = {
    :type => "MIT",
    :file => "LICENSE"
  }

  spec.author       = {
    "Pavan Dhakar" => "pavanpavandhakar@gmail.com"
  }

  spec.platform     = :ios, "17.0"
  spec.swift_version = "5.9"

  spec.source       = {
    :git => "https://github.com/pavandhakar/PDDropDownSwiftUI.git",
    :tag => spec.version.to_s
  }

  spec.source_files = "PDDropDownSwitfUI/PDDropDownSwiftUI/**/*.swift"

end