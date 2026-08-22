//
//  PDDropDownSwiftUIView.swift
//  PDDropDownSwiftUI
//
//  Created by pavan dhakar on 22/08/26.
//
//  Provides a SwiftUI-friendly wrapper around `PDDropDown` (UIKit).
//  Two usage styles are supported:
//
//  ── 1. Fluent modifier API (recommended, reads like native SwiftUI) ─────────
//
//      PDDropDownSwiftUIView(selected: $city, options: cities) { value, _, _ in
//          city = value
//      }
//      .pdFont(UIFont.systemFont(ofSize: 15, weight: .medium))
//      .pdArrow(image: UIImage(named: "chevron"), size: 18, color: .systemBlue)
//      .pdTableInsets(leading: 12, trailing: 12)
//      .pdListHeight(200)
//      .pdSearchEnabled(true)
//
//  ── 2. Config struct API (good for shared / reusable configs) ────────────────
//
//      var config = PDDropDownConfig()
//      config.font = UIFont.systemFont(ofSize: 15)
//      config.listLeadingOffset = 12
//
//      PDDropDownSwiftUIView(selected: $city, options: cities, config: config) { value, _, _ in
//          city = value
//      }
//

import SwiftUI

// MARK: - PDDropDownConfig

/// All visual and behavioural settings for the dropdown, with sensible defaults.
///
/// Instantiate, override only what you need, and pass to ``PDDropDownSwiftUIView``.
public struct PDDropDownConfig {

    // MARK: Arrow
    /// Custom arrow image. When `nil` a built-in triangle is drawn.
    public var arrowImage: UIImage?           = nil
    /// Side-length of the arrow icon in points.
    public var arrowSize: CGFloat             = 20
    /// Tint colour of the arrow icon.
    public var arrowColor: UIColor            = .black

    // MARK: Typography
    /// Font applied to both the text field and each row label.
    public var font: UIFont                   = UIFont.systemFont(ofSize: 14, weight: .regular)
    /// Text colour of the text field value.
    public var textColor: UIColor             = .black
    /// Alignment of text inside the text field and each row.
    public var textAlignment: NSTextAlignment = .left
    /// Colour of option labels in normal (unselected) state.
    public var itemsColor: UIColor            = .darkGray
    /// Tint colour used for the check-mark accessory.
    public var itemsTintColor: UIColor        = .blue

    // MARK: Table geometry
    /// Maximum height the dropdown list can grow to before it scrolls.
    public var listHeight: CGFloat            = 180
    /// Fixed height of every row in the list.
    public var rowHeight: CGFloat             = 45
    /// Insets the table's **leading** edge by this amount relative to the field (positive = inward).
    public var listLeadingOffset: CGFloat     = 0
    /// Insets the table's **trailing** edge by this amount relative to the field (positive = inward).
    public var listTrailingOffset: CGFloat    = 0
    /// Horizontal shift applied when leading/trailing offsets are both zero (legacy).
    public var listXOffset: CGFloat           = 0
    /// Fixed width override for the list. Defaults to the text field's width when `nil`.
    public var listWidth: CGFloat?            = nil

    // MARK: Row appearance
    /// Background colour of every unselected row.
    public var rowBackgroundColor: UIColor    = .white
    /// Background colour of the currently selected row.
    public var selectedRowColor: UIColor      = .clear

    // MARK: Border / corner
    /// Colour of the text-field border.
    public var borderColor: UIColor           = .lightGray
    /// Width of the text-field border. `0` hides it.
    public var borderWidth: CGFloat           = 0
    /// Corner radius of the text field.
    public var cornerRadius: CGFloat          = 5

    // MARK: Behaviour
    /// When `true` the text field becomes editable and filters the list as you type.
    public var isSearchEnable: Bool           = true
    /// Shows a check-mark accessory on the selected row.
    public var checkMarkEnabled: Bool         = false
    /// Dismisses the list automatically after a row is tapped.
    public var hideOptionsWhenSelect: Bool    = true
    /// Adjusts the list position when the software keyboard is visible.
    public var handleKeyboard: Bool           = true

    public init() {}
}

// MARK: - PDDropDownSwiftUIView

/// A SwiftUI wrapper around `PDDropDown` (UIKit).
///
/// ### Quickstart
/// ```swift
/// PDDropDownSwiftUIView(selected: $city, options: cities) { value, _, _ in
///     city = value
/// }
/// .pdFont(UIFont.systemFont(ofSize: 15))
/// .pdArrow(color: .systemBlue)
/// .pdTableInsets(leading: 12, trailing: 12)
/// ```
public struct PDDropDownSwiftUIView: UIViewRepresentable {

    // MARK: Required inputs
    /// The currently selected value. Updated inside `didUpdateValue`.
    public var selectedStr: String
    /// Full list of options shown in the dropdown.
    public var listOfString: [String]

    // MARK: Optional inputs
    /// Placeholder shown when no item is selected.
    public var placeholder: String          = ""
    /// Configuration bundle. All modifiers below mutate this internally.
    public var config: PDDropDownConfig     = PDDropDownConfig()

    // MARK: Callback
    /// Called whenever the user picks an item.
    /// - Parameters:
    ///   - selectedText: The tapped option string.
    ///   - index: Its position inside `optionArray`.
    ///   - id: Value from `optionIds` at that index, or `0` if not set.
    public let didUpdateValue: (String, Int, Int) -> Void

    // MARK: - Initialisers

    /// Convenience initialiser matching the original API signature.
    public init(
        selectedStr: String,
        listOfString: [String],
        placeholder: String = "",
        config: PDDropDownConfig = PDDropDownConfig(),
        didUpdateValue: @escaping (String, Int, Int) -> Void
    ) {
        self.selectedStr    = selectedStr
        self.listOfString   = listOfString
        self.placeholder    = placeholder
        self.config         = config
        self.didUpdateValue = didUpdateValue
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context: Context) -> PDDropDown {
        let dropDown = PDDropDown()
        apply(config: config, to: dropDown)
        dropDown.didSelect { text, index, id in
            didUpdateValue(text, index, id)
        }
        return dropDown
    }

    public func updateUIView(_ uiView: PDDropDown, context: Context) {
        uiView.optionArray  = listOfString
        uiView.text         = selectedStr
        uiView.placeholder  = placeholder
        apply(config: config, to: uiView)
    }

    public func makeCoordinator() -> () { }

    // MARK: - Internal config applicator

    private func apply(config: PDDropDownConfig, to dropDown: PDDropDown) {
        // Arrow
        dropDown.arrowImage              = config.arrowImage
        dropDown.arrowSize               = config.arrowSize
        dropDown.arrowColor              = config.arrowColor

        // Typography
        dropDown.font                    = config.font
        dropDown.textColor               = config.textColor
        dropDown.textAlignment           = config.textAlignment
        dropDown.itemsColor              = config.itemsColor
        dropDown.itemsTintColor          = config.itemsTintColor

        // Table geometry
        dropDown.listHeight              = config.listHeight
        dropDown.rowHeight               = config.rowHeight
        dropDown.listLeadingOffset       = config.listLeadingOffset
        dropDown.listTrailingOffset      = config.listTrailingOffset
        dropDown.listXOffset             = config.listXOffset
        dropDown.listWidth               = config.listWidth

        // Row appearance
        dropDown.rowBackgroundColor      = config.rowBackgroundColor
        dropDown.selectedRowColor        = config.selectedRowColor

        // Border / corner
        dropDown.borderColor             = config.borderColor
        dropDown.borderWidth             = config.borderWidth
        dropDown.cornerRadius            = config.cornerRadius

        // Behaviour
        dropDown.isSearchEnable          = config.isSearchEnable
        dropDown.checkMarkEnabled        = config.checkMarkEnabled
        dropDown.hideOptionsWhenSelect   = config.hideOptionsWhenSelect
        dropDown.handleKeyboard          = config.handleKeyboard
    }
}

// MARK: - Fluent modifier API

/// Chainable SwiftUI-style modifiers so you never have to build a `PDDropDownConfig` by hand.
public extension PDDropDownSwiftUIView {

    // MARK: Arrow modifiers

    /// Sets a custom arrow image, its size, and tint colour.
    func pdArrow(image: UIImage? = nil, size: CGFloat? = nil, color: UIColor? = nil) -> Self {
        var copy = self
        if let image  = image  { copy.config.arrowImage = image }
        if let size   = size   { copy.config.arrowSize  = size  }
        if let color  = color  { copy.config.arrowColor = color }
        return copy
    }

    // MARK: Typography modifiers

    /// Sets the font for the text field and row labels.
    func pdFont(_ font: UIFont) -> Self {
        var copy = self; copy.config.font = font; return copy
    }

    /// Sets the text colour of the selected-value text field.
    func pdTextColor(_ color: UIColor) -> Self {
        var copy = self; copy.config.textColor = color; return copy
    }

    /// Sets the text alignment of the text field and row labels.
    func pdTextAlignment(_ alignment: NSTextAlignment) -> Self {
        var copy = self; copy.config.textAlignment = alignment; return copy
    }

    /// Sets the colour of option labels in the list.
    func pdItemsColor(_ color: UIColor) -> Self {
        var copy = self; copy.config.itemsColor = color; return copy
    }

    // MARK: Table geometry modifiers

    /// Maximum height of the dropdown list before it scrolls.
    func pdListHeight(_ height: CGFloat) -> Self {
        var copy = self; copy.config.listHeight = height; return copy
    }

    /// Height of every row in the dropdown list.
    func pdRowHeight(_ height: CGFloat) -> Self {
        var copy = self; copy.config.rowHeight = height; return copy
    }

    /// Insets the dropdown table from the text field's leading and/or trailing edges.
    ///
    /// - Parameters:
    ///   - leading:  Points inward from the leading edge (default `0`).
    ///   - trailing: Points inward from the trailing edge (default `0`).
    func pdTableInsets(leading: CGFloat = 0, trailing: CGFloat = 0) -> Self {
        var copy = self
        copy.config.listLeadingOffset  = leading
        copy.config.listTrailingOffset = trailing
        return copy
    }

    /// Overrides the width of the dropdown list absolutely.
    func pdListWidth(_ width: CGFloat) -> Self {
        var copy = self; copy.config.listWidth = width; return copy
    }

    /// Shifts the dropdown list horizontally (positive = right).
    func pdListXOffset(_ offset: CGFloat) -> Self {
        var copy = self; copy.config.listXOffset = offset; return copy
    }

    // MARK: Row appearance modifiers

    /// Sets background colours for normal and selected rows.
    func pdRowColors(normal: UIColor, selected: UIColor) -> Self {
        var copy = self
        copy.config.rowBackgroundColor = normal
        copy.config.selectedRowColor   = selected
        return copy
    }

    // MARK: Border / corner modifiers

    /// Configures the text field's border.
    func pdBorder(color: UIColor, width: CGFloat = 1, cornerRadius: CGFloat? = nil) -> Self {
        var copy = self
        copy.config.borderColor  = color
        copy.config.borderWidth  = width
        if let r = cornerRadius { copy.config.cornerRadius = r }
        return copy
    }

    // MARK: Behaviour modifiers

    /// Enables or disables live search filtering as the user types.
    func pdSearchEnabled(_ enabled: Bool) -> Self {
        var copy = self; copy.config.isSearchEnable = enabled; return copy
    }

    /// Shows or hides the check-mark accessory on the selected row.
    func pdCheckMark(_ enabled: Bool) -> Self {
        var copy = self; copy.config.checkMarkEnabled = enabled; return copy
    }

    /// Dismisses the list automatically when an option is selected.
    func pdHideOnSelect(_ hide: Bool) -> Self {
        var copy = self; copy.config.hideOptionsWhenSelect = hide; return copy
    }
}
