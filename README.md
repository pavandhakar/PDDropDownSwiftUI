Here is the cleaned and formatted Markdown file, organized with standard README sections, closed code fences, and deduped examples:

```markdown
# PDDropDownSwiftUI

A lightweight, customizable dropdown component for SwiftUI wrapping UIKit's `PDDropDown`.

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### CocoaPods

Add the following entry to your `Podfile`:

```ruby
pod 'PDDropDownSwiftUI'

```

Then run:

```bash
pod install

```

### Swift Package Manager

Add the package URL to your project dependencies:

```text
[https://github.com/](https://github.com/)<username>/PDDropDownSwiftUI.git

```

## Usage

### Basic Example

```swift
import SwiftUI
import PDDropDownSwiftUI

struct ContentView: View {
    @State private var selectedIndex = 0
    @State private var showDropdown = false

    private let fruits = ["Apple", "Banana", "Cherry", "Mango", "Grape"]

    var body: some View {
        PDDropDownMenu(
            options: fruits,
            selectedOptionIndex: $selectedIndex,
            showDropdown: $showDropdown
        )
    }
}

```

---

### Customization via View Modifiers

Apply modifiers directly to configure styling fluently:

```swift
struct CustomDropdownView: View {
    @State private var selectedIndex = 0
    @State private var showDropdown = false

    private let cities = ["New York", "London", "Tokyo", "Paris"]

    var body: some View {
        PDDropDownMenu(
            options: cities,
            selectedOptionIndex: $selectedIndex,
            showDropdown: $showDropdown
        )
        .pdMenuWidth(240)
        .pdFont(.headline)
        .pdTextAlignment(.trailing)
        .pdCornerRadius(20)
        .pdBackgroundColor(Color(.systemIndigo).opacity(0.12))
        .pdTextColor(Color(.systemIndigo))
        .pdChevronColor(Color(.systemIndigo))
        .pdCheckmarkColor(Color(.systemIndigo))
        .pdSelectedRowColor(Color(.systemIndigo).opacity(0.08))
        .pdSeparatorColor(Color(.systemIndigo).opacity(0.15))
        .pdShadow(color: Color(.systemIndigo).opacity(0.2), radius: 12)
    }
}

```

---

### Customization via Configuration Object

Alternatively, inject an explicit `PDDropDownMenuConfig` instance:

```swift
struct ConfiguredDropdownView: View {
    @State private var selectedIndex = 0
    @State private var showDropdown = false

    private let cities = ["New York", "London", "Tokyo", "Paris"]

    private var menuConfig: PDDropDownMenuConfig {
        var config = PDDropDownMenuConfig()
        config.backgroundColor = Color(.systemIndigo).opacity(0.1)
        config.showChevron = true
        config.showCheckmark = true
        config.textAlignment = .trailing
        return config
    }

    var body: some View {
        PDDropDownMenu(
            options: cities,
            selectedOptionIndex: $selectedIndex,
            showDropdown: $showDropdown,
            config: menuConfig
        )
    }
}

```

## License

This project is available under the MIT license.

```

```

Support the Project

If you find this project helpful or it saved you some development time, consider buying me a coffee! Any support helps keep open-source projects like this maintained and updated.

UPI ID: pvn6415@ybl

(Scan or pay via Google Pay, PhonePe, Paytm, or any UPI app)
