# GccLite — 用一个 18 KB 的小工具取代 GIGABYTE Control Center 控制灯光

[![build](https://github.com/jianghuifr/gigabyte-rgb-lite/actions/workflows/build.yml/badge.svg)](https://github.com/jianghuifr/gigabyte-rgb-lite/actions/workflows/build.yml)

> 针对 **技嘉 Z790M AORUS ELITE D5（小雕）** 逆向出来的独立灯光控制工具。
> 不需要 GCC 常驻、不需要 GCC 自启、不需要 GCC 主程序，也**不需要管理员权限**。

---

## 它做什么

| 灯 | 控制通道 | 能力 |
|---|---|---|
| **ARGB 排针 / 风扇灯 / 灯带** | ITE IT5701 / IT5702 · **USB HID** | 开关、任意颜色、亮度、6 种动态灯效 |
| **DDR5 内存条灯** | ENE 控制器 · **SMBus 0x70–0x73** | 开关、任意颜色、**16 种灯效** |
| 主板板载灯 | —— | 本型号无独立板载 LED（布局里的 LED_C1 / Chipset Accent / LED_C2 三个 zone 没有实体灯珠）|

**已实测**：静态颜色（红/绿/蓝）、呼吸、闪烁、彩虹 —— 两条通道都通过。

## 背景

这块板子上的灯默认是亮的，而技嘉官方的做法是：**让 GIGABYTE Control Center（GCC）开机自启**，
由它在后台跑一遍、把灯光配置写下去。GCC 装着几十个 DLL、一个 WPF 界面、一堆常驻服务，
而它实际做的事情只是往 RGB 控制器里写几十个字节的报文。

为了关个灯，得让这么一个庞然大物开机自启——**杀鸡用牛刀**。

于是我把 GCC 和硬件之间的通信完整抓了下来，重写成一个小工具：

| | GCC | GccLite |
|---|---|---|
| 体积 | 数百 MB 安装 + 常驻服务 | **单个 18 KB 的 exe** |
| 运行方式 | 常驻后台、托盘图标、多个服务进程 | 跑一次，**立刻退出** |
| 依赖 | .NET / WPF / 一大堆私有 DLL | .NET Framework（系统自带）|
| 耗时 | 约 25 秒 | **约 1 秒** |

## 快速开始

### 直接用 Release 里的 exe

下载 `GccLiteAll.exe` 双击，或者在命令行里跑：

```powershell
.\GccLiteAll.exe off              # 关掉所有灯
```

就这一步，没有安装过程，没有注册表改动，没有常驻进程。

### 从源码编译

```powershell
.\build.ps1
```

只需要 Windows 自带的 `csc.exe`，不用装任何 SDK：

```
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
```

产物只有一个：**`dist\GccLiteAll.exe`**。

```powershell
csc /target:exe /platform:x64 /optimize+ /out:dist\GccLiteAll.exe src\GccLiteAll.cs
```

它是**控制台子系统**程序——因为命令行是本工具的主要接口，
`list`、`demo`、出错提示都需要能看到输出。

如果你要把它挂到登录时自动跑，加 `--quiet` 就不会闪窗口：

```powershell
.\GccLiteAll.exe off --quiet
```

`--quiet` 只在**本进程独占控制台**时才隐藏窗口。
如果你是在已有的终端里跑，它不会去关你的终端（会自动跳过）。

## 用法

```
GccLiteAll <command> [options]

  off                    关灯（默认）
  on                     开成白色
  color RRGGBB           静态颜色
  effect <name>          灯效（见 list）
  brightness <0-255>     亮度
  demo                   依次演示各灯效
  list                   列出支持的灯效

选项
  --color RRGGBB    --leds N      每根内存的灯珠数（默认 8）
  --speed 1-10      --brightness 0-255
  --hid-only        只控 ARGB / 风扇
  --smb-only        只控 DDR5 内存
  --no-block        只发寄存器序列（诊断用）
  --quiet           隐藏控制台窗口（仅在独占控制台时生效，供计划任务用）
```

例：

```powershell
.\GccLiteAll.exe off
.\GccLiteAll.exe on
.\GccLiteAll.exe color FF0000
.\GccLiteAll.exe effect breath --color 00FF00 --speed 3
.\GccLiteAll.exe effect cycle --speed 10
.\GccLiteAll.exe brightness 40
.\GccLiteAll.exe --hid-only effect wave
.\GccLiteAll.exe --smb-only off
```

支持的灯效名：

```
static  breath  flash  cycle  rainbow  breathrainbow  comet  cometrainbow
movingflash  wave  yoyo  starry  aorusrainbow  coldrainbow  dflash  random
```

### 退出码

| 码 | 含义 |
|---|---|
| `0` | 成功 |
| `1` | 命令行参数错误 |
| `2` | **DDR5 通道失败**（厂商 SMBus 组件缺失或驱动不可用；ARGB 通道可能仍然成功）|

## 可选：开机自启

**这一步不属于本项目** —— 工具本身不做任何自启配置，也不碰你的计划任务。
需要的话自己加一条即可，记得加 `--quiet` 免得闪窗口：

```powershell
$exe = "$PWD\GccLiteAll.exe"
Register-ScheduledTask -TaskName 'GccLiteOff' `
    -Action  (New-ScheduledTaskAction -Execute $exe -Argument 'off --quiet') `
    -Trigger (New-ScheduledTaskTrigger -AtLogOn) `
    -Force
```

不需要管理员权限，也不需要 `-RunLevel Highest`。

删掉：

```powershell
Unregister-ScheduledTask -TaskName 'GccLiteOff' -Confirm:$false
```

> 如果你的杀毒软件有「隐藏执行 PowerShell」之类的 HIPS 规则，
> 注意**直接调用 exe**（如上）没问题，但别把任务写成
> `powershell.exe -WindowStyle Hidden -Command ...` —— 那种会被拦。

## 自动构建

[`.github/workflows/build.yml`](.github/workflows/build.yml) 在 `windows-latest` 上跑：

| 触发 | 行为 |
|---|---|
| push `main` / PR | 编译 + 冒烟测试 + 归档产物 |
| push `v*` tag | 额外**自动发布 Release**（exe + `SHA256SUMS.txt`）|
| 手动 | `workflow_dispatch` |

每次运行依次做：

| 步骤 | 干什么 |
|---|---|
| **Guard** | 检查仓库里有没有被提交的二进制（`.exe` / `.sys` / 厂商 DLL），有就**直接失败** |
| **Build** | 调 `build.ps1`，用 runner 自带的 `csc.exe` 编译 |
| **Smoke test** | 跑 `list` / `help` / 参数解析，并**断言 PE 子系统是 `3`**（控制台程序）|
| **Checksums** | 生成 `SHA256SUMS.txt` 并写进 job summary |
| **Upload** | 归档产物 |
| **Publish release** | 只在 tag 上跑，用 `gh release create` 发布 |

> 源码包不用自己打——GitHub 会给每个 tag 自动生成 "Source code (zip/tar.gz)"。
> Release 里只挂 exe 和校验和。
>
> **Guard 步骤是有意加的**：本项目的内存灯通道依赖 ENE/CTI 的驱动组件，
> 而那些是第三方版权物，**不能随本仓库分发**。CI 每次都会检查一遍，
> 防止以后有人（包括我自己）不小心提交进去。

## 技术原理

两条通道都是独立的，通过**代理 DLL 抓包**逆向得到：用 MinGW 编译一个日志代理，
替换 GCC 安装目录下的同名 DLL，让 `GCC.exe -b` 真实跑一次，
把它与硬件之间的全部通信抓下来，跑完自动还原原 DLL。

### ARGB / 风扇 —— ITE IT5702 over USB HID

`VID_048D` / `PID_5702`，usage page `0xFF89` / usage `0x00CC`，64 字节 feature report，report id `0xCC`。

关键坑：**固件会忽略广播报文**（header `0x20` + `zone0=0xFF`），必须**逐个 zone** 下发：

```
报文：[0]=0xCC [1]=header [2..5]=zone0(u32) [6..9]=zone1
      [11]=effect [12]=最大亮度 [13]=最小亮度 [14..17]=颜色 0x00RRGGBB
      [22..27]=period [30..31]=参数

zone 表（抓包所得）：
  header 0x21 / zone 位 0x02 = LED_C1
  header 0x22 / zone 位 0x04 = Chipset Accent
  header 0x24 / zone 位 0x10 = LED_C2
  header 0x25 / zone 位 0x20 = D_LED1   (ARGB 排针 1)
  header 0x26 / zone 位 0x40 = D_LED2   (ARGB 排针 2)

前缀：CC 34 00 | CC 47 00 | CC 20..27 清零 | CC 28 FF 00 (APPLY)
收尾：CC 32 00 | CC 28 FF 00 (APPLY)
```

颜色直接写 `0x00RRGGBB`，**不需要 BGR 交换**。

### DDR5 内存 —— ENE 控制器 over SMBus

每根内存一个控制器，地址 `0x70 / 0x71 / 0x72 / 0x73`。
经 `MsIo64_ENE.dll`（CTI 的 "CtiIo for ENE"）→ 设备 `\\.\CTIIO` → `CtiIo64.sys`。

每根内存的下发序列（**少一步都不生效**）：

```
前置  WORD 0x4000, 0x1CF0, 0x1030, 0x87FB, 0x80A1, 0x87FB, 0x8160
      （注意 0x87FB 和 0x8160 各发两次）

打底  BLOCK(颜色) → WORD 0x8020 → BLOCK(00 01 00 00)
      → WORD 0x8029 → BYTE reg1=09 → WORD 0x802F → BYTE reg1=01 → WORD 0x8160

灯效  BLOCK(颜色) → WORD 0x8020 → BLOCK(00 <mode> <b2> <b3>)
      → WORD 0x8029 → BYTE reg1=09 → WORD 0x802F → BYTE reg1=01
      → [WORD 0x80F2 → BYTE reg1=<参数>] → WORD 0x8160
      （按参数个数重复若干遍）
```

`mode` 就是 `Gigabyte.ULightingEffects.Devices.ENE.EneLedNewMode`：

| mode | 灯效 | | mode | 灯效 |
|---|---|---|---|---|
| 1 | 静态 | | 9 | 流动闪烁 |
| 2 | 呼吸 | | 11 | 波浪 |
| 3 | 闪烁 | | 12 | 辉光往复 |
| 4 | 颜色循环 | | 13 | 星空 |
| 5 | 彩虹 | | 80 | AORUS 彩虹 |
| 6 | 呼吸彩虹 | | 81 | AORUS 冷彩虹 |
| 7 | 彗星 | | 254 | 双闪 |
| 8 | 彩虹彗星 | | | |

**两个实测细节**：

1. 内存的颜色缓冲区是 **`R, B, G`** 顺序，不是 RGB。实测 `FF 00 00` → 红、`00 FF 00` → **蓝**。
   工具内部已按实测换算，你填标准的 `--color 00FF00` 就是绿色。
2. 内存的**动效颜色不跟 `--color` 走**——ENE 控制器的动效用它自己的颜色通道
   （发"绿色呼吸"会看到蓝色呼吸）。静态模式的颜色是准的。

踩过的坑、代理 DLL 的写法、objdump 反推原型的方法，都在
[`docs/REVERSE-ENGINEERING.md`](docs/REVERSE-ENGINEERING.md)。

## 依赖

| 部件 | 位置 / 设备名 | 谁提供的 | 需要管理员？ |
|---|---|---|---|
| ARGB 通道 | 无 —— 纯 `setupapi.dll` + `hid.dll` | Windows | **否** |
| `MsIo64_ENE.dll` | `%LOCALAPPDATA%\GccLite\ene\` 或 ENE 安装目录 | **CTI**（"CtiIo for ENE"）| **否** |
| `CtiIo64.sys` + `CTIIO` 服务 | `C:\Windows\system32\drivers\`，设备 `\\.\CTIIO` | **CTI** 内核驱动 | **否** |

**本工具源码里没有任何 GCC 路径，GCC 主程序一个字节都没用到。**
实测**不需要管理员权限**（CTIIO 的设备对象允许普通用户访问）。

`MsIo64_ENE.dll` 的导入表只有 `KERNEL32 / USER32 / ADVAPI32`，不依赖任何 GCC 组件。
工具会按下面的顺序找它，用第一个存在的：

```
%LOCALAPPDATA%\GccLite\ene\
C:\Program Files\ENE\Aac_ENE_DRAM_RGB_AIO\x64\
C:\Program Files\ENE\Aac_ENE RGB HAL\x64\
```

⚠️ **本仓库不包含、也不再分发**任何厂商二进制文件。如果你机器上没有它们，
内存灯通道会不可用并返回退出码 `2`（ARGB 通道不受影响，纯 Win32 实现）。

### 能卸载 GCC 吗？

可以。`tools\restore-vendor-drivers.ps1` 是为此准备的恢复脚本，
会依次检查 `CTIIO` / `CTIAIO` / `MSIO` 三个驱动的文件与服务、以及 ENE DLL 副本，缺哪个补哪个。

**这套恢复流程做过完整的拆解演练**：

| 阶段 | 结果 |
|---|---|
| 停 + 删 `CTIIO` 服务、驱动文件改名、DLL 副本目录改名 | 内存通道 `ok=0 failed=4`（确实坏了）|
| 跑恢复脚本 | 驱动文件 ✅ 服务重建 ✅ DLL 副本 ✅ |
| 恢复后实测 | `ok=4 failed=0` ✅ |

> ⚠️ 注意：早期我把 `MSIO` / `MsIo64.sys` 误认为内存通道的依赖，**那是错的**。
> 拆解演练证明把 `MSIO` 删掉内存灯照样工作，真正的依赖是 `\\.\CTIIO`。

## 已知限制

- **睡眠唤醒后**控制器会复位，可能需要再运行一次。
- 内存的 `--leds` 默认 8（每根内存 8 颗灯珠），换内存条时可能需要调整。
- 内存的动效颜色不跟 `--color` 走（见上）。
- 主板板载灯无法控制——本型号没有独立的板载 LED。
- **只在 Z790M AORUS ELITE D5 + IT5702 + ENE DDR5 上实测过。** 其他型号大概率能用
  （协议是通用的），但不保证，欢迎反馈。

## 免责声明

- 本项目与技嘉（GIGABYTE）、ENE Technology、CTI（Creative Technology Innovation）**无任何关联**，
  未获其授权或认可。
- 所有协议均通过**观察本机已安装软件的通信**逆向得出，属于互操作性研究。
- 仓库中**不包含**任何厂商的二进制文件或反编译产物。
- 本工具直接读写硬件控制器，**使用风险自负**。虽然实测无害，但请自行评估。
- 商标归各自所有者所有。

## License

MIT —— 见 [LICENSE](LICENSE)。

---

## English summary

**GccLite** replaces GIGABYTE Control Center for RGB control on a Gigabyte Z790M AORUS ELITE D5,
in a single ~18 KB executable. No resident process, no installer, and **no administrator rights**.

**Why**: GCC must autostart and stay resident just to write a few dozen bytes to the RGB
controllers at boot. GccLite does the same job in about one second and exits.

**How**: Both lighting channels were reverse engineered by building logging proxy DLLs
(MinGW) that replace GCC's own DLLs, capturing every packet GCC exchanges with the hardware,
then restoring the originals. Sources for that tooling are in `tools/re/`.

**Channels**
- ARGB headers / fans: ITE IT5702 over USB HID. The firmware ignores broadcast packets —
  each zone must be addressed with its own header byte.
- DDR5 DIMMs: ENE controllers on SMBus 0x70–0x73 via `MsIo64_ENE.dll` → `\\.\CTIIO`.

**Verified**: static colour (R/G/B), breathing, flashing and rainbow, on both channels.

**Requires**: the vendor ENE/CTI SMBus component (`MsIo64_ENE.dll` + `CtiIo64.sys`) for the
DDR5 channel, which is installed by GIGABYTE Control Center. **Those binaries are not
redistributed here.** The ARGB channel is pure Win32 and has no third-party dependency.

Not affiliated with GIGABYTE, ENE Technology or CTI. MIT licensed.
