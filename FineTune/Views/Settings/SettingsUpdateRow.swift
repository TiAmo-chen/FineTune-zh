// FineTune/Views/Settings/SettingsUpdateRow.swift
import SwiftUI

/// Combined update settings row with toggle and manual check button (like Rectangle app)
struct SettingsUpdateRow: View {
    @Binding var automaticallyChecks: Bool
    let lastCheckDate: Date?
    let onCheckNow: () -> Void

    private var descriptionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        if let date = lastCheckDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return "版本 \(version) · 上次检查 \(formatter.localizedString(for: date, relativeTo: .now))"
        }
        return "版本 \(version) · 从未检查"
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .frame(width: DesignTokens.Dimensions.settingsIconWidth)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("自动检查更新")
                        .font(DesignTokens.Typography.rowName)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)

                    Toggle("", isOn: $automaticallyChecks)
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                        .tint(DesignTokens.Colors.accentPrimary)
                        .labelsHidden()
                }

                Text(descriptionText)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.textTertiary)
            }

            Spacer()

            Button("检查更新") {
                onCheckNow()
            }
            .buttonStyle(.plain)
            .font(DesignTokens.Typography.pickerText)
            .foregroundStyle(DesignTokens.Colors.textPrimary)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .frame(width: DesignTokens.Dimensions.settingsPickerWidth)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                    .fill(DesignTokens.Colors.pickerBackground)
            }
        }
        .hoverableRow()
    }
}

// MARK: - Preview

#Preview("Settings Update Row") {
    VStack(spacing: DesignTokens.Spacing.sm) {
        SettingsUpdateRow(
            automaticallyChecks: .constant(true),
            lastCheckDate: .now.addingTimeInterval(-120),
            onCheckNow: { print("Check now") }
        )

        SettingsUpdateRow(
            automaticallyChecks: .constant(false),
            lastCheckDate: nil,
            onCheckNow: { print("Check now") }
        )
    }
    .padding(DesignTokens.Spacing.lg)
    .frame(width: DesignTokens.Dimensions.popupWidth)
    .darkGlassBackground()
    .environment(\.colorScheme, .dark)
}
