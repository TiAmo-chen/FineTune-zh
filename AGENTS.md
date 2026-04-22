# FineTune 项目知识库

**生成时间:** 2026-04-22
**Commit:** 8e9ea5b
**Branch:** main

## 项目概述

FineTune 是 macOS 菜单栏音频控制应用，使用 SwiftUI + CoreAudio + Sparkle。独立控制每个应用音量、EQ、AutoEQ耳机校正、多设备路由。

## 目录结构

```
FineTune-zh/
├── FineTune/           # 主应用源码
│   ├── Audio/          # 音频引擎核心 (CoreAudio封装)
│   ├── Views/          # SwiftUI UI层
│   ├── Models/         # 数据模型
│   ├── Utilities/      # 工具类 (URLHandler, UpdateManager)
│   └── Assets.xcassets/ # 资源文件
├── FineTuneTests/      # 单元测试
├── .github/workflows/  # CI/Release自动化
├── appcast.xml         # Sparkle更新清单
└── guide/              # 用户文档
```

## 快速定位

| 任务 | 位置 | 说明 |
|------|------|------|
| 应用入口 | `FineTune/FineTuneApp.swift` | SwiftUI App主体 |
| 音频引擎 | `FineTune/Audio/Engine/AudioEngine.swift` | 核心音频处理 |
| 主界面 | `FineTune/Views/MenuBarPopupView.swift` | 菜单栏弹出界面 |
| 设置页 | `FineTune/Views/Settings/SettingsView.swift` | 设置面板 |
| EQ面板 | `FineTune/Views/EQPanelView.swift` | 10段均衡器 |
| AutoEQ | `FineTune/Audio/AutoEQ/` | 耳机校正 |
| 设备监控 | `FineTune/Audio/Monitors/` | 音频设备监测 |
| 设计系统 | `FineTune/Views/DesignSystem/DesignTokens.swift` | UI设计规范 |
| 更新管理 | `FineTune/Utilities/UpdateManager.swift` | Sparkle集成 |

## 核心架构

### AudioEngine (2182行核心类)

- **职责**: 音频分流、设备路由、音量控制、EQ处理
- **依赖**: ProcessMonitor, DeviceMonitor, DeviceVolumeMonitor, AutoEQProfileManager
- **关键概念**:
  - `ProcessTap`: 为每个应用创建音频分流
  - `AggregateDevice`: 虚拟设备用于多设备输出
  - `VolumeControlTier`: 硬件/DDC/软件三种音量控制方式

### 视图层次

```
MenuBarPopupView (主容器)
├── DeviceSection (输出/输入设备)
│   └── DeviceRow / DeviceEditRow
├── AppsSection (应用列表)
│   └── AppRow / AppEditRow
├── BluetoothSection (蓝牙设备)
│   └── PairedDeviceRow
└── SettingsView (设置面板)
```

## 开发规范

### SwiftUI约定

- 使用 `@Observable` 替代 `@ObservableObject` (Swift 5.9)
- `@MainActor` 标记UI相关类
- `DesignTokens` 统一设计变量 (颜色、字体、间距)
- `.hoverableRow()` 修饰器统一行悬停效果
- `.glassButtonStyle()` 统一玻璃按钮样式

### 音频层约定

- 协议抽象便于测试: `AudioProcessMonitoring`, `AudioDeviceProviding`
- `AudioDeviceID` 是 CoreAudio 设备标识
- `uid` 是设备唯一字符串标识 (持久化用)
- 音量映射: 硬件(线性dB)、DDC(0-100)、软件(x²曲线)

### 文件命名

- `*View.swift`: SwiftUI视图
- `*Row.swift`: 列表行组件
- `*Monitor.swift`: 监控器类
- `*Controller.swift`: 控制器类
- `*Manager.swift`: 管理器类

## 构建命令

```bash
# Debug构建 (无签名)
xcodebuild -project FineTune.xcodeproj -scheme FineTune \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO build

# Release构建
xcodebuild -project FineTune.xcodeproj -scheme FineTune \
  -configuration Release \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO build

# 运行测试
xcodebuild test -project FineTune.xcodeproj -scheme FineTune \
  -skip-testing:FineTuneUITests
```

## 注意事项

- **权限**: 需要 Screen & System Audio Recording 权限
- **签名**: 本地开发可禁用签名，分发需要 Apple Developer 证书
- **Sparkle**: 更新检查需要 `SUPublicEDKey` 和 `appcast.xml`
- **DDC**: 外接显示器音量控制通过 I2C (仅 macOS 14+)
- **AutoEQ**: 配置来自 [AutoEq项目](https://github.com/jaakkopasanen/AutoEq)

## 子模块文档

- `FineTune/Audio/AGENTS.md` - 音频引擎详细文档
- `FineTune/Views/AGENTS.md` - UI组件详细文档