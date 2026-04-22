// FineTune/Views/Settings/SettingsView.swift
import SwiftUI

/// Main settings panel with all app-wide configuration options
struct SettingsView: View {
    @Binding var settings: AppSettings
    @ObservedObject var updateManager: UpdateManager
    let launchIconStyle: MenuBarIconStyle
    let onResetAll: () -> Void

    // System sounds control
    @Bindable var deviceVolumeMonitor: DeviceVolumeMonitor
    let outputDevices: [AudioDevice]

    @State private var showResetConfirmation = false
    @State private var isSupportHovered = false
    @State private var isStarHovered = false
    @State private var isLicenseHovered = false

    private var unifiedLoudnessToggleBinding: Binding<Bool> {
        Binding(
            get: { settings.loudnessCompensationEnabled && settings.loudnessEqualizationEnabled },
            set: { isEnabled in
                settings.setUnifiedLoudnessEnabled(isEnabled)
            }
        )
    }

    var body: some View {
        // Scrollable settings content
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                generalSection
                audioSection
                notificationsSection
                dataSection

                aboutFooter
            }
        }
        .scrollIndicators(.never)
    }

    // MARK: - General Section

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            SectionHeader(title: "通用")
                .padding(.bottom, DesignTokens.Spacing.xs)

            SettingsToggleRow(
                icon: "power",
                title: "登录时启动",
                description: "登录时自动启动 FineTune",
                isOn: $settings.launchAtLogin
            )

            SettingsIconPickerRow(
                icon: "menubar.rectangle",
                title: "菜单栏图标",
                selection: $settings.menuBarIconStyle,
                appliedStyle: launchIconStyle
            )

            SettingsUpdateRow(
                automaticallyChecks: Binding(
                    get: { updateManager.automaticallyChecksForUpdates },
                    set: { updateManager.automaticallyChecksForUpdates = $0 }
                ),
                lastCheckDate: updateManager.lastUpdateCheckDate,
                onCheckNow: { updateManager.checkForUpdates() }
            )
        }
    }

    // MARK: - Audio Section

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            SectionHeader(title: "音频")
                .padding(.bottom, DesignTokens.Spacing.xs)

            SettingsSliderRow(
                icon: "speaker.wave.2",
                title: "默认音量",
                description: "新应用的初始音量",
                value: $settings.defaultNewAppVolume,
                range: 0.1...1.0
            )

            SettingsToggleRow(
                icon: "speaker.badge.exclamationmark",
                title: "不支持设备的软件音量",
                description: "为无原生控制的输出设备添加音量滑块（如 HDMI 电视）",
                isOn: $settings.softwareDeviceVolumeEnabled
            )

            SettingsToggleRow(
                icon: "mic",
                title: "锁定输入设备",
                description: "设备连接时防止自动切换",
                isOn: $settings.lockInputDevice
            )

            // Sound Effects device selection
            SoundEffectsDeviceRow(
                devices: outputDevices,
                selectedDeviceUID: deviceVolumeMonitor.systemDeviceUID,
                defaultDeviceUID: deviceVolumeMonitor.defaultDeviceUID,
                isFollowingDefault: deviceVolumeMonitor.isSystemFollowingDefault,
                onDeviceSelected: { deviceUID in
                    if let device = outputDevices.first(where: { $0.uid == deviceUID }) {
                        deviceVolumeMonitor.setSystemDeviceExplicit(device.id)
                    }
                },
                onSelectFollowDefault: {
                    deviceVolumeMonitor.setSystemFollowDefault()
                }
            )

            // Sound Effects alert volume slider
            SettingsSliderRow(
                icon: "bell.and.waves.left.and.right",
                title: "提示音音量",
                description: "提醒和通知的音量",
                value: Binding(
                    get: { deviceVolumeMonitor.alertVolume },
                    set: { deviceVolumeMonitor.setAlertVolume($0) }
                )
            )
            .task {
                // Poll alert volume for live sync with System Settings.
                // No CoreAudio property listener exists for alert volume —
                // AppleScript is the only read path, so periodic refresh is required.
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2))
                    deviceVolumeMonitor.refreshAlertVolume()
                }
            }

            SettingsLoudnessCompensationRow(
                isOn: unifiedLoudnessToggleBinding
            )
        }
    }


    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            SectionHeader(title: "通知")
                .padding(.bottom, DesignTokens.Spacing.xs)

            SettingsToggleRow(
                icon: "bell",
                title: "设备断开提醒",
                description: "设备断开时显示通知",
                isOn: $settings.showDeviceDisconnectAlerts
            )
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            SectionHeader(title: "数据")
                .padding(.bottom, DesignTokens.Spacing.xs)

            if showResetConfirmation {
                // Inline confirmation row
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(DesignTokens.Colors.mutedIndicator)
                        .frame(width: DesignTokens.Dimensions.settingsIconWidth)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("重置所有设置？")
                            .font(DesignTokens.Typography.rowName)
                            .foregroundStyle(DesignTokens.Colors.textPrimary)
                        Text("此操作无法撤销")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.textTertiary)
                    }

                    Spacer()

                    Button("取消") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showResetConfirmation = false
                        }
                    }
                    .buttonStyle(.plain)
                    .font(DesignTokens.Typography.pickerText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)

                    Button("重置") {
                        onResetAll()
                        showResetConfirmation = false
                    }
                    .buttonStyle(.plain)
                    .font(DesignTokens.Typography.pickerText)
                    .foregroundStyle(DesignTokens.Colors.mutedIndicator)
                }
                .hoverableRow()
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                SettingsButtonRow(
                    icon: "arrow.counterclockwise",
                    title: "重置所有设置",
                    description: "清除所有音量、EQ 和设备路由",
                    buttonLabel: "重置",
                    isDestructive: true
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showResetConfirmation = true
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    // MARK: - About Footer

    private var aboutFooter: some View {
        let startYear = 2026
        let currentYear = Calendar.current.component(.year, from: .now)
        let yearText = startYear == currentYear ? "\(startYear)" : "\(startYear)-\(currentYear)"

        return HStack(spacing: DesignTokens.Spacing.xs) {
            Button {
                NSWorkspace.shared.open(URL(string: "https://github.com/ronitsingh10/FineTune")!)
            } label: {
                Text("\(Image(systemName: isStarHovered ? "star.fill" : "star")) 在 GitHub 加星")
                    .foregroundStyle(isStarHovered ? Color(nsColor: .systemYellow) : DesignTokens.Colors.textTertiary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(DesignTokens.Animation.hover) {
                    isStarHovered = hovering
                }
            }
            .accessibilityLabel("在 GitHub 加星")

            Text("·")

            Button {
                NSWorkspace.shared.open(DesignTokens.Links.support)
            } label: {
                Text("\(Image(systemName: isSupportHovered ? "heart.fill" : "heart")) 支持 FineTune")
                    .foregroundStyle(isSupportHovered ? Color(nsColor: .systemPink) : DesignTokens.Colors.textTertiary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(DesignTokens.Animation.hover) {
                    isSupportHovered = hovering
                }
            }
            .accessibilityLabel("支持 FineTune")

            Text("·")

            Text("版权所有 © \(yearText) Ronit Singh")

            Text("·")

            Button {
                NSWorkspace.shared.open(DesignTokens.Links.license)
            } label: {
                Text("GPL-3.0")
                    .foregroundStyle(isLicenseHovered ? DesignTokens.Colors.textSecondary : DesignTokens.Colors.textTertiary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(DesignTokens.Animation.hover) {
                    isLicenseHovered = hovering
                }
            }
            .accessibilityLabel("查看 GPL-3.0 许可证")
        }
        .font(DesignTokens.Typography.caption)
        .foregroundStyle(DesignTokens.Colors.textTertiary)
        .frame(maxWidth: .infinity)
        .padding(.top, DesignTokens.Spacing.sm)
    }
}

// MARK: - Previews

// Note: Preview requires mock DeviceVolumeMonitor which isn't available
// Use live testing instead
