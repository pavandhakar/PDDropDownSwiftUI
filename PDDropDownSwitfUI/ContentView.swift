//
//  ContentView.swift
//  PDDropDownSwiftUI – Demo
//
//  This file is the demo app for the PDDropDownSwiftUI pod.
//  It demonstrates every major usage pattern so other developers can
//  copy-paste what they need.
//

import SwiftUI

struct ContentView: View {

    // MARK: - State

    @State private var selectedDemo: String    = ""
    @State private var selectedCity: String    = ""
    @State private var selectedCountry: String = ""
    @State private var selectedRole: String    = ""

    private let cities: [String]    = ["Mumbai", "Delhi", "Bengaluru", "Hyderabad",
                                        "Ahmedabad", "Chennai", "Kolkata", "Pune", "Surat", "Jaipur"]
    private let countries: [String] = ["Russia", "Canada", "China", "United States",
                                        "Brazil", "India", "Japan", "Germany", "France"]
    private let roles: [String]     = ["Admin", "Editor", "Viewer", "Guest"]

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    sectionHeader("0. Simple Example")
                    PDDropDownSwiftUIView(
                        selectedStr: selectedDemo,
                        listOfString: cities,
                        placeholder: "Select City"
                    ) { value, _, _ in
                        selectedDemo = value
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    
                    Divider()
                    
                    sectionHeader("1. Fluent modifier API (recommended)")
                    fluentExampleSection

                    Divider()

                    sectionHeader("2. Config struct API")
                    configExampleSection

                    Divider()

                    sectionHeader("3. Custom table insets (leading & trailing)")
                    insetsExampleSection
                }
                .padding()
            }
            .navigationTitle("PDDropDownSwiftUI")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Example sections

    /// USAGE PATTERN 1 – Fluent modifier API
    /// Chain `.pd*` modifiers just like built-in SwiftUI view modifiers.
    private var fluentExampleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            label("Select City")
            PDDropDownSwiftUIView(
                selectedStr: selectedCity,
                listOfString: cities,
                placeholder: "Select City"
            ) { value, _, _ in
                selectedCity = value
            }
            // ── Fluent modifiers ──────────────────────────────────────────
            .pdFont(UIFont.systemFont(ofSize: 15, weight: .medium))
            .pdTextColor(.label)
            .pdArrow(size: 16, color: .systemBlue)
            .pdListHeight(200)
            .pdRowHeight(50)
            .pdSearchEnabled(true)
            .pdCheckMark(false)
            .pdRowColors(normal: .systemBackground, selected: UIColor.systemBlue.withAlphaComponent(0.15))
            // ─────────────────────────────────────────────────────────────
            .frame(height: 50)
            .dropDownBorder()

            selectionLabel(selectedCity)
        }
    }

    /// USAGE PATTERN 2 – Config struct API
    /// Build a `PDDropDownConfig` once and reuse it across multiple dropdowns.
    private var configExampleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            label("Select Country")
            PDDropDownSwiftUIView(
                selectedStr: selectedCountry,
                listOfString: countries,
                placeholder: "Select Country",
                config: sharedConfig
            ) { value, _, _ in
                selectedCountry = value
            }
            .frame(height: 50)
            .dropDownBorder()

            selectionLabel(selectedCountry)
        }
    }

    /// USAGE PATTERN 3 – Dynamic table insets
    /// Use `.pdTableInsets(leading:trailing:)` to control the dropdown
    /// table width independently of the text field width.
    private var insetsExampleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            label("Select Role (table inset 12pt each side)")
            PDDropDownSwiftUIView(
                selectedStr: selectedRole,
                listOfString: roles,
                placeholder: "Select Role"
            ) { value, _, _ in
                selectedRole = value
            }
            .pdTableInsets(leading: 12, trailing: 12)   // ← key modifier
            .pdListHeight(160)
            .pdSearchEnabled(false)
            .pdCheckMark(true)
            .frame(height: 50)
            .dropDownBorder()

            selectionLabel(selectedRole)
        }
    }

    // MARK: - Shared config (Pattern 2)

    /// A reusable config object – define once, apply to many dropdowns.
    private var sharedConfig: PDDropDownConfig {
        var c = PDDropDownConfig()
        c.font                = UIFont.systemFont(ofSize: 14, weight: .regular)
        c.textColor           = .label
        c.arrowColor          = .systemGreen
        c.arrowSize           = 18
        c.listHeight          = 180
        c.rowHeight           = 44
        c.rowBackgroundColor  = .systemBackground
        c.selectedRowColor    = UIColor.systemGreen.withAlphaComponent(0.15)
        c.isSearchEnable      = true
        c.checkMarkEnabled    = true
        return c
    }

    // MARK: - Small helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private func selectionLabel(_ value: String) -> some View {
        Group {
            if !value.isEmpty {
                Text("Selected: \(value)")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
    }
}

// MARK: - Convenience ViewModifier

/// Thin wrapper that applies a standard rounded border used across all demo examples.
private extension View {
    func dropDownBorder() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
