// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  PDDropDownMenu.swift
//  PDDropDownSwiftUI
//
//  Created by pavan dhakar on 13/09/26.
//
//  A fully dynamic, pure-SwiftUI dropdown menu component.
//  All visual and behavioural properties are configurable via
//  `PDDropDownMenuConfig` or set directly on the view.
//
//  ── Quick Usage ────────────────────────────────────────────────────────────
//
//      @State private var selectedIndex = 0
//      @State private var showDropdown  = false
//
//      PDDropDownMenu(
//          options: ["Apple", "Banana", "Cherry"],
//          selectedOptionIndex: $selectedIndex,
//          showDropdown: $showDropdown
//      )
//
//  ── With config ────────────────────────────────────────────────────────────
//
//      var config = PDDropDownMenuConfig()
//      config.backgroundColor    = Color(.systemIndigo).opacity(0.1)
//      config.showChevron        = true
//      config.showCheckmark      = true
//      config.textAlignment      = .trailing
//
//      PDDropDownMenu(
//          options: cities,
//          selectedOptionIndex: $selectedIndex,
//          showDropdown: $showDropdown,
//          config: config
//      )
//

import SwiftUI

// MARK: - PDDropDownMenuConfig

/// All visual and behavioural settings for `PDDropDownMenu`, with sensible defaults.
public struct PDDropDownMenuConfig {

    // MARK: Geometry
    /// Width of the dropdown button and menu. Default `200`.
    public var menuWidth: CGFloat           = 200
    /// Height of each button row (selected header + each option). Default `50`.
    public var buttonHeight: CGFloat        = 50
    /// Maximum number of items visible before the list scrolls. Default `4`.
    public var maxItemDisplayed: Int        = 4
    /// Corner radius applied to the dropdown container. Default `12`.
    public var cornerRadius: CGFloat        = 12

    // MARK: Colours
    /// Background colour of the dropdown container. Default `.white`.
    public var backgroundColor: Color       = .white
    /// Text colour for all option labels. Default `.primary`.
    public var textColor: Color             = .primary
    /// Tint colour for the chevron icon. Default `.primary`.
    public var chevronColor: Color          = .primary
    /// Tint colour for the checkmark icon. Default `.accentColor`.
    public var checkmarkColor: Color        = .accentColor
    /// Background highlight colour of the selected row. Default `.clear`.
    public var selectedRowColor: Color      = .clear
    /// Separator line colour between rows. `nil` hides separators.
    public var separatorColor: Color?       = nil

    // MARK: Typography
    /// Font applied to option labels. Default `.body`.
    public var font: Font                   = .body
    /// Horizontal alignment of text inside each row. Default `.leading`.
    public var textAlignment: TextAlignment = .leading
    /// Horizontal padding inside each row. Default `16`.
    public var horizontalPadding: CGFloat   = 16

    // MARK: Optional adornments
    /// Show/hide the chevron icon on the header button. Default `true`.
    public var showChevron: Bool            = true
    /// Show/hide the checkmark on the selected option row. Default `true`.
    public var showCheckmark: Bool          = true
    /// System image name used for the chevron. Default `"chevron.down"`.
    public var chevronImageName: String     = "chevron.down"
    /// System image name used for the checkmark. Default `"checkmark.circle.fill"`.
    public var checkmarkImageName: String   = "checkmark.circle.fill"

    // MARK: Shadow
    /// Drop-shadow radius on the container. `0` disables the shadow. Default `8`.
    public var shadowRadius: CGFloat        = 8
    /// Drop-shadow colour. Default `.black.opacity(0.12)`.
    public var shadowColor: Color           = Color.black.opacity(0.12)
    /// Drop-shadow offset. Default `(0, 4)`.
    public var shadowOffset: CGSize         = CGSize(width: 0, height: 4)

    // MARK: Animation
    /// Animation used when opening/closing the dropdown. Default `.spring(response:0.35,dampingFraction:0.75)`.
    public var animation: Animation         = .spring(response: 0.35, dampingFraction: 0.75)

    public init() {}
}

// MARK: - PDDropDownMenu

/// A fully dynamic, pure-SwiftUI dropdown menu.
///
/// Bind `selectedOptionIndex` to track the current selection and
/// `showDropdown` to control open/close state externally if needed.
public struct PDDropDownMenu: View {

    // MARK: Required inputs
    /// The full list of options to display.
    public let options: [String]

    /// Index of the currently selected option.
    @Binding public var selectedOptionIndex: Int

    /// Controls whether the dropdown list is expanded.
    @Binding public var showDropdown: Bool

    // MARK: Configuration
    /// Visual and behavioural configuration.
    public var config: PDDropDownMenuConfig

    // MARK: Private state
    @State private var scrollPosition: Int?

    // MARK: - Init

    /// Creates a `PDDropDownMenu` with the given options and bindings.
    ///
    /// - Parameters:
    ///   - options:              Full list of selectable strings.
    ///   - selectedOptionIndex: Binding to the selected index.
    ///   - showDropdown:        Binding to the expanded/collapsed state.
    ///   - config:              Optional configuration. Defaults to `PDDropDownMenuConfig()`.
    public init(
        options: [String],
        selectedOptionIndex: Binding<Int>,
        showDropdown: Binding<Bool>,
        config: PDDropDownMenuConfig = PDDropDownMenuConfig()
    ) {
        self.options              = options
        self._selectedOptionIndex = selectedOptionIndex
        self._showDropdown        = showDropdown
        self.config               = config
    }

    // MARK: - Body

    public var body: some View {
        // The outer frame is always fixed to buttonHeight.
        // The dropdown list is rendered in an overlay so it floats
        // OVER sibling views and never pushes the layout down.
        headerButton
            .frame(width: config.menuWidth, height: config.buttonHeight)
            .background(
                RoundedRectangle(
                    cornerRadius: showDropdown
                        ? config.cornerRadius  // keep full radius — list has its own bottom radius
                        : config.cornerRadius,
                    style: .continuous
                )
                .fill(config.backgroundColor)
                .shadow(
                    color: config.shadowColor,
                    radius: config.shadowRadius,
                    x: config.shadowOffset.width,
                    y: config.shadowOffset.height
                )
            )
            // Anchor the floating list to the bottom of the header
            .overlay(alignment: .top) {
                if showDropdown {
                    VStack(spacing: 0) {
                        // Transparent spacer that exactly matches the header height,
                        // so the list starts right below it.
                        Color.clear
                            .frame(height: config.buttonHeight)

                        dropdownList
                    }
                    .transition(.opacity.combined(with: .blurReplace))
//                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(width: config.menuWidth, height: config.buttonHeight, alignment: .top)
            .zIndex(100)
    }

    // MARK: - Subviews

    private var headerButton: some View {
        Button {
            withAnimation(config.animation) {
                showDropdown.toggle()
            }
        } label: {
            rowContent(
                text: options.indices.contains(selectedOptionIndex)
                    ? options[selectedOptionIndex]
                    : (options.first ?? ""),
                isHeader: true
            )
        }
        .frame(width: config.menuWidth, height: config.buttonHeight)
        .contentShape(Rectangle())
    }

    private var dropdownList: some View {
        let visibleCount = min(options.count, config.maxItemDisplayed)
        let listHeight   = config.buttonHeight * CGFloat(visibleCount)

        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    optionRow(index: index)

                    // Optional separator between rows
                    if let sepColor = config.separatorColor, index < options.count - 1 {
                        Rectangle()
                            .fill(sepColor)
                            .frame(height: 0.5)
                            .padding(.horizontal, config.horizontalPadding)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .scrollDisabled(options.count <= config.maxItemDisplayed)
        .frame(height: listHeight)
        .background(
            // Rounded bottom corners only so the list visually connects to the header above
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: config.cornerRadius,
                bottomTrailingRadius: config.cornerRadius,
                topTrailingRadius: 0,
                style: .continuous
            )
            .fill(config.backgroundColor)
            .shadow(
                color: config.shadowColor,
                radius: config.shadowRadius,
                x: config.shadowOffset.width,
                y: config.shadowOffset.height
            )
        )
        .onAppear { scrollPosition = selectedOptionIndex }
    }

    private func optionRow(index: Int) -> some View {
        Button {
            withAnimation(config.animation) {
                selectedOptionIndex = index
                showDropdown        = false
            }
        } label: {
            rowContent(text: options[index], isHeader: false, index: index)
        }
        .frame(width: config.menuWidth, height: config.buttonHeight)
        .background(index == selectedOptionIndex ? config.selectedRowColor : Color.clear)
        .contentShape(Rectangle())
    }

    /// Shared layout for header and option rows.
    @ViewBuilder
    private func rowContent(text: String, isHeader: Bool, index: Int? = nil) -> some View {
        let isSelected = index.map { $0 == selectedOptionIndex } ?? false
        let isTrailing = config.textAlignment == .trailing

        HStack(spacing: 8) {
            // Left side: chevron (header, trailing-text layout) or checkmark (option, trailing-text layout)
            if isHeader && config.showChevron && isTrailing {
                chevronIcon(rotated: showDropdown)
            }
            if !isHeader && config.showCheckmark && isSelected && isTrailing {
                checkmarkIcon
            }

            // Spacer before text when trailing
            if isTrailing { Spacer() }

            Text(text)
                .font(config.font)
                .foregroundStyle(config.textColor)
                .multilineTextAlignment(config.textAlignment)
                .lineLimit(1)

            // Spacer after text when leading / center
            if !isTrailing { Spacer() }

            // Right side: checkmark (option, leading-text layout) or chevron (header, leading-text layout)
            if !isHeader && config.showCheckmark && isSelected && !isTrailing {
                checkmarkIcon
            }
            if isHeader && config.showChevron && !isTrailing {
                chevronIcon(rotated: showDropdown)
            }
        }
        .padding(.horizontal, config.horizontalPadding)
    }

    private func chevronIcon(rotated: Bool) -> some View {
        Image(systemName: config.chevronImageName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(config.chevronColor)
            .rotationEffect(.degrees(rotated ? -180 : 0))
            .animation(config.animation, value: rotated)
    }

    private var checkmarkIcon: some View {
        Image(systemName: config.checkmarkImageName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(config.checkmarkColor)
    }
}

// MARK: - Fluent modifier API

public extension PDDropDownMenu {

    // MARK: Geometry

    /// Sets the width of the dropdown.
    func pdMenuWidth(_ width: CGFloat) -> Self {
        var copy = self; copy.config.menuWidth = width; return copy
    }

    /// Sets the height of each row.
    func pdButtonHeight(_ height: CGFloat) -> Self {
        var copy = self; copy.config.buttonHeight = height; return copy
    }

    /// Sets the maximum number of items visible before the list scrolls.
    func pdMaxItemsDisplayed(_ count: Int) -> Self {
        var copy = self; copy.config.maxItemDisplayed = count; return copy
    }

    /// Sets the corner radius of the dropdown container.
    func pdCornerRadius(_ radius: CGFloat) -> Self {
        var copy = self; copy.config.cornerRadius = radius; return copy
    }

    // MARK: Colours

    /// Sets the background colour of the dropdown.
    func pdBackgroundColor(_ color: Color) -> Self {
        var copy = self; copy.config.backgroundColor = color; return copy
    }

    /// Sets the text colour for option labels.
    func pdTextColor(_ color: Color) -> Self {
        var copy = self; copy.config.textColor = color; return copy
    }

    /// Sets the chevron icon tint colour.
    func pdChevronColor(_ color: Color) -> Self {
        var copy = self; copy.config.chevronColor = color; return copy
    }

    /// Sets the checkmark icon tint colour.
    func pdCheckmarkColor(_ color: Color) -> Self {
        var copy = self; copy.config.checkmarkColor = color; return copy
    }

    /// Sets the background colour for the selected row.
    func pdSelectedRowColor(_ color: Color) -> Self {
        var copy = self; copy.config.selectedRowColor = color; return copy
    }

    /// Sets the separator line colour between rows (`nil` hides separators).
    func pdSeparatorColor(_ color: Color?) -> Self {
        var copy = self; copy.config.separatorColor = color; return copy
    }

    // MARK: Typography

    /// Sets the font for option labels.
    func pdFont(_ font: Font) -> Self {
        var copy = self; copy.config.font = font; return copy
    }

    /// Sets horizontal text alignment inside each row (`.leading` or `.trailing`).
    func pdTextAlignment(_ alignment: TextAlignment) -> Self {
        var copy = self; copy.config.textAlignment = alignment; return copy
    }

    /// Sets horizontal padding inside each row.
    func pdHorizontalPadding(_ padding: CGFloat) -> Self {
        var copy = self; copy.config.horizontalPadding = padding; return copy
    }

    // MARK: Adornments

    /// Shows or hides the chevron icon on the header button.
    func pdShowChevron(_ show: Bool) -> Self {
        var copy = self; copy.config.showChevron = show; return copy
    }

    /// Shows or hides the checkmark on the selected option row.
    func pdShowCheckmark(_ show: Bool) -> Self {
        var copy = self; copy.config.showCheckmark = show; return copy
    }

    /// Sets a custom SF Symbol name for the chevron icon.
    func pdChevronIcon(_ name: String) -> Self {
        var copy = self; copy.config.chevronImageName = name; return copy
    }

    /// Sets a custom SF Symbol name for the checkmark icon.
    func pdCheckmarkIcon(_ name: String) -> Self {
        var copy = self; copy.config.checkmarkImageName = name; return copy
    }

    // MARK: Shadow

    /// Configures the drop shadow on the dropdown container.
    func pdShadow(
        color: Color = Color.black.opacity(0.12),
        radius: CGFloat = 8,
        offset: CGSize = CGSize(width: 0, height: 4)
    ) -> Self {
        var copy = self
        copy.config.shadowColor  = color
        copy.config.shadowRadius = radius
        copy.config.shadowOffset = offset
        return copy
    }

    // MARK: Animation

    /// Sets the open/close animation.
    func pdAnimation(_ animation: Animation) -> Self {
        var copy = self; copy.config.animation = animation; return copy
    }
}

// MARK: - Preview

#Preview("Default") {
    @Previewable @State var selectedIndex = 0
    @Previewable @State var showDropdown  = false
    @Previewable @State var selectedIndex2 = 0
    @Previewable @State var showDropdown2  = false

    VStack(spacing: 40) {
        // Default style
        PDDropDownMenu(
            options: ["Apple", "Banana", "Cherry", "Mango", "Grape"],
            selectedOptionIndex: $selectedIndex,
            showDropdown: $showDropdown
        )

        // Custom style — trailing text, indigo theme
        PDDropDownMenu(
            options: ["New York", "London", "Tokyo", "Paris"],
            selectedOptionIndex: $selectedIndex2,
            showDropdown: $showDropdown2
        )
        .pdBackgroundColor(Color(.systemIndigo).opacity(0.12))
        .pdTextColor(Color(.systemIndigo))
        .pdChevronColor(Color(.systemIndigo))
        .pdCheckmarkColor(Color(.systemIndigo))
        .pdSelectedRowColor(Color(.systemIndigo).opacity(0.08))
        .pdTextAlignment(.trailing)
        .pdMenuWidth(240)
        .pdFont(.headline)
        .pdCornerRadius(20)
        .pdSeparatorColor(Color(.systemIndigo).opacity(0.15))
        .pdShadow(color: Color(.systemIndigo).opacity(0.2), radius: 12)
    }
    .padding(40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}
