//
//  ContentView.swift
//  PDDropDownSwiftUI – Demo
//
//  This file is the demo app for the PDDropDownSwiftUI library.
//  It demonstrates every major usage pattern of PDDropDownMenu so
//  other developers can copy-paste what they need.
//

import SwiftUI

struct ContentView: View {

    // MARK: - State

    // Example 0 – Simple / Default
    @State private var selectedFruitIndex: Int   = 0
    @State private var showFruitDropdown: Bool   = false

    // Example 1 – Fluent modifiers (indigo theme, trailing text)
    @State private var selectedCityIndex: Int    = 0
    @State private var showCityDropdown: Bool    = false

    // Example 2 – Config struct, no chevron, custom checkmark
    @State private var selectedRoleIndex: Int    = 0
    @State private var showRoleDropdown: Bool    = false

    // Example 3 – Dark style, no checkmark
    @State private var selectedCountryIndex: Int = 0
    @State private var showCountryDropdown: Bool = false

    // Example 4 – No chevron, no checkmark, center text
    @State private var selectedLangIndex: Int    = 0
    @State private var showLangDropdown: Bool    = false

    // MARK: - Data

    private let fruits    = ["Apple", "Banana", "Cherry", "Mango", "Grape", "Watermelon"]
    private let cities    = ["Mumbai", "Delhi", "Bengaluru", "Hyderabad",
                             "Chennai", "Kolkata", "Pune", "Jaipur"]
    private let roles     = ["Admin", "Editor", "Viewer", "Guest"]
    private let countries = ["India", "United States", "Japan", "Germany", "France", "Brazil"]
    private let langs     = ["Swift", "Kotlin", "TypeScript", "Python", "Rust"]

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 36) {

                    // ── 0. Simple / Default ─────────────────────────────────
                    sectionHeader("0. Simple — Default Style")
                    sectionNote("Just pass options, selectedOptionIndex and showDropdown bindings.")

                    PDDropDownMenu(
                        options: fruits,
                        selectedOptionIndex: $selectedFruitIndex,
                        showDropdown: $showFruitDropdown
                    )
                    .pdMenuWidth(300)

                    selectionLabel(fruits[selectedFruitIndex])

                    Divider()

                    // ── 1. Fluent Modifier API ──────────────────────────────
                    sectionHeader("1. Fluent Modifier API — Indigo, Trailing Text")
                    sectionNote("Chain .pd* modifiers like native SwiftUI modifiers.")

                    // swiftlint:disable line_length
                    PDDropDownMenu(
                        options: cities,
                        selectedOptionIndex: $selectedCityIndex,
                        showDropdown: $showCityDropdown
                    )
                    .pdMenuWidth(300)
                    .pdButtonHeight(52)
                    .pdBackgroundColor(Color(.systemIndigo).opacity(0.10))
                    .pdTextColor(Color(.systemIndigo))
                    .pdChevronColor(Color(.systemIndigo))
                    .pdCheckmarkColor(Color(.systemIndigo))
                    .pdSelectedRowColor(Color(.systemIndigo).opacity(0.08))
                    .pdTextAlignment(.trailing)        // text on right, icons on left
                    .pdFont(.headline)
                    .pdCornerRadius(20)
                    .pdSeparatorColor(Color(.systemIndigo).opacity(0.15))
                    .pdShadow(color: Color(.systemIndigo).opacity(0.18), radius: 14)
                    .pdMaxItemsDisplayed(5)

                    selectionLabel(cities[selectedCityIndex])

                    Divider()

                    // ── 2. Config Struct API ────────────────────────────────
                    sectionHeader("2. Config Struct API — Custom Checkmark, No Chevron")
                    sectionNote("Build a PDDropDownMenuConfig once and reuse across multiple dropdowns.")

                    PDDropDownMenu(
                        options: roles,
                        selectedOptionIndex: $selectedRoleIndex,
                        showDropdown: $showRoleDropdown,
                        config: roleConfig
                    )

                    selectionLabel(roles[selectedRoleIndex])

                    Divider()

                    // ── 3. Dark Style ───────────────────────────────────────
                    sectionHeader("3. Dark Style — No Checkmark")
                    sectionNote("Dark background with white text. showCheckmark = false.")

                    PDDropDownMenu(
                        options: countries,
                        selectedOptionIndex: $selectedCountryIndex,
                        showDropdown: $showCountryDropdown
                    )
                    .pdMenuWidth(300)
                    .pdBackgroundColor(Color(.label))
                    .pdTextColor(Color(.systemBackground))
                    .pdChevronColor(Color(.systemBackground))
                    .pdShowCheckmark(false)            // ← checkmark hidden
                    .pdCornerRadius(14)
                    .pdFont(.subheadline.weight(.medium))
                    .pdSelectedRowColor(.white.opacity(0.10))
                    .pdShadow(color: .black.opacity(0.25), radius: 16)

                    selectionLabel(countries[selectedCountryIndex])

                    Divider()

                    // ── 4. No Chevron, No Checkmark, Center Text ───────────
                    sectionHeader("4. No Chevron · No Checkmark · Center Text")
                    sectionNote("showChevron = false, showCheckmark = false, textAlignment = .center.")

                    PDDropDownMenu(
                        options: langs,
                        selectedOptionIndex: $selectedLangIndex,
                        showDropdown: $showLangDropdown
                    )
                    .pdMenuWidth(300)
                    .pdShowChevron(false)              // ← chevron hidden
                    .pdShowCheckmark(false)            // ← checkmark hidden
                    .pdTextAlignment(.center)
                    .pdBackgroundColor(Color(.secondarySystemGroupedBackground))
                    .pdSelectedRowColor(Color(.systemGreen).opacity(0.12))
                    .pdSeparatorColor(Color(.separator))
                    .pdCornerRadius(16)
                    .pdFont(.callout.weight(.semibold))
                    .pdShadow(radius: 6)

                    selectionLabel(langs[selectedLangIndex])
                }
                .padding(20)
            }
            .navigationTitle("PDDropDownMenu")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Config Struct (Pattern 2)

    /// A reusable config — define once, apply to many dropdowns.
    private var roleConfig: PDDropDownMenuConfig {
        var config = PDDropDownMenuConfig()
        config.menuWidth         = 300
        config.buttonHeight      = 50
        config.backgroundColor   = Color(.secondarySystemGroupedBackground)
        config.textColor         = .primary
        config.showChevron       = false               // ← no chevron
        config.showCheckmark     = true
        config.checkmarkColor    = Color(.systemGreen)
        config.checkmarkImageName = "checkmark.seal.fill"  // ← custom icon
        config.textAlignment     = .leading
        config.font              = .callout
        config.separatorColor    = Color(.separator)
        config.cornerRadius      = 16
        config.shadowRadius      = 6
        config.selectedRowColor  = Color(.systemGreen).opacity(0.10)
        return config
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
    }

    private func sectionNote(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
    }

    private func selectionLabel(_ value: String) -> some View {
        Group {
            if !value.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("Selected: \(value)")
                        .font(.caption)
                }
                .foregroundStyle(Color(.systemGreen))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
