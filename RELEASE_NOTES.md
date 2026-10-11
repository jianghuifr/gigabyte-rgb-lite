# Release Notes

## v1.0.0 — 首个版本

用一个小工具取代 GIGABYTE Control Center 控制灯光。**下载 `GccLiteAll.exe`，
双击即用**（关闭所有灯光）；想常驻化管理用 `install\Install-GccLite.ps1`。

### 亮点

- **单个 18 KB 的 exe**，无依赖、无安装、无后台进程
- 开机自动关灯：登录后跑一次，**约 1 秒**，然后退出
- 同时覆盖 **ARGB 排针/风扇灯** 和 **DDR5 内存灯**两条完全独立的通道
- **34 个双击启动器**切换灯效和颜色，不弹 UAC、效果持续保持
- 不需要 GCC 主程序运行；可以把技嘉的自启任务永久禁用

### 支持的能力

| | ARGB / 风扇 | DDR5 内存 |
|---|---|---|
| 开关 | ✅ | ✅ |
| 任意颜色 | ✅ 标准 RGB | ✅（内部换算 R,B,G）|
| 亮度 | ✅ | — |
| 动态灯效 | ✅ 6 种 | ✅ 16 种 |

**已实测**：静态颜色（红/绿/蓝）、呼吸、闪烁、彩虹 —— 两条通道都通过。

### 兼容性

在以下配置上开发并实测：

- 主板：**Gigabyte Z790M AORUS ELITE D5**（IT5702 RGB 控制器）
- 内存：4 根 DDR5（ENE RGB 控制器，SMBus 0x70–0x73）
- 系统：Windows 11 + .NET Framework 4.x

其他 IT5702 / IT5701 的技嘉主板大概率可用（协议通用），但未验证。

### 已知限制

- **睡眠唤醒后**控制器会复位，可能需要再运行一次
- 内存的**动效颜色不跟 `--color` 走**（ENE 控制器用自己的颜色通道）；
  静态模式颜色准确
- 内存 `--leds` 默认 8（每根 8 颗灯珠），换内存条时可能需要调整
- 主板板载灯无法控制（本型号没有独立板载 LED）
- 内存通道需要厂商组件 `MsIo64_ENE.dll` + `CtiIo64.sys`（由技嘉安装程序安装）；
  **本仓库不分发这些文件**

### 安装

**方式 A：只要关灯（最简）**

下载 `GccLiteAll.exe`，双击运行即可立刻关掉所有灯。
把它放进「启动」文件夹或计划任务就能开机自动关灯。

**方式 B：完整安装（推荐）**

```powershell
git clone https://github.com/<you>/gcc-lite.git
cd gcc-lite
powershell -ExecutionPolicy Bypass -File .\install\Install-GccLite.ps1   # 提权
```

会自动编译、注册开机任务、生成 34 个双击启动器、并禁用技嘉的 GCC 自启。

### 回滚

```powershell
Unregister-ScheduledTask -TaskName 'GccLiteAll' -Confirm:$false
Get-ScheduledTask -TaskName 'GccLiteFx-*' | Unregister-ScheduledTask -Confirm:$false
Enable-ScheduledTask -TaskName 'GCC'
```

### 校验

```
文件    : GccLiteAll.exe
大小    : 17920 字节
编译    : csc.exe (x64, /optimize+)
来源    : src\GccLiteAll.cs  —— 单文件 C#，可直接审阅后自行编译
```

不放心直接跑 exe 的话，用 `build.ps1` 从源码自己编译一个：

```powershell
.\build.ps1        # 只用 Windows 自带的 csc.exe
```

### 免责声明

本项目与技嘉（GIGABYTE）、ENE Technology、CTI **无任何关联**，未获授权或认可。
协议通过观察本机已安装软件的通信逆向得出，属互操作性研究。
仓库不含任何厂商二进制或反编译产物。直接读写硬件控制器，**使用风险自负**。
