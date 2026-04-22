// FineTune/Views/Components/PermissionBannerView.swift
import SwiftUI

struct PermissionBannerView: View {
    let permission: AudioRecordingPermission

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "speaker.slash")
                    .font(.title)
                    .foregroundStyle(DesignTokens.Colors.textTertiary)

                Text("需要音频捕获权限")
                    .font(.callout)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)

                if permission.status == .denied {
                    Text("请在系统设置 → 隐私与安全 → 屏幕与系统音频录制 中启用")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }

                actionButton
            }
            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.xl)
    }

    @ViewBuilder
    private var actionButton: some View {
        if permission.status == .denied {
            Button("打开系统设置") {
                openSystemAudioSettings()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        } else {
            Button("授予权限") {
                permission.request()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    private func openSystemAudioSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}
