# PDDropDownSwiftUI

A reusable dropdown component for SwiftUI.

## Requirements

- iOS 16.0+
- Swift 5.9+

## Installation

### CocoaPods

Add the following to your Podfile:

```ruby
pod 'PDDropDownSwiftUI'


// MARK: - PDDropDownSwiftUIView

 A SwiftUI wrapper around `PDDropDown` (UIKit).
 ### Quickstart
 ```swift
 @State private var selectedCity: String    = ""
private let cities: [String]    = ["Mumbai", "Delhi", "Bengaluru", "Hyderabad",
                                        "Ahmedabad", "Chennai", "Kolkata", "Pune", "Surat", "Jaipur"]
                                        
 PDDropDownSwiftUIView(selected: $selectedCity, options: cities) { value, _, _ in
     selectedCity = value
 }
 .pdFont(UIFont.systemFont(ofSize: 15))
 .pdArrow(color: .systemBlue)
 .pdTableInsets(leading: 12, trailing: 12)
                                        
 ```
