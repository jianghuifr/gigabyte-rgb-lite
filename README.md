# GccLite — 用一个 18 KB 的小工具取代 GIGABYTE Control Center 控制灯光

> 针对 **技嘉 Z790M AORUS ELITE D5（小雕）** 逆向出来的独立灯光控制工具。
> 开机自动关灯，不需要 GCC 常驻、不需要 GCC 自启、不需要 GCC 主程序。

---

## 背景

这块板子上的灯默认是亮的，而技嘉官方的做法是：**让 GIGABYTE Control Center（GCC）开机自启**，
由它在后台跑一遍、把灯光配置写下去。GCC 装着几十个 DLL、一个 WPF 界面、一堆常驻服务，
而它实际做的事情只是往 RGB 控制器里写几十个字节的报文。

为了关个灯，得让这么一个庞然大物开机自启——**杀鸡用牛刀**。

于是我把 GCC 和硬件之间的通信完整抓了下来，重写成一个小工具：

| | GCC | GccLite |
|---|---|---|
| 体积 | 数百 MB 安装 + 常驻服务 | **单个 18 KB 的 exe** |
| 开机行为 | 常驻后台、托盘图标、多个服务进程 | 登录后跑一次，**立刻退出** |
| 依赖 | .NET / WPF / 一大堆私有 DLL | .NET Framework（系统自带） |
| 启动耗时 | 约 25 秒 | **约 1 秒** |

## 它做什么

| 灯 | 控制通道 | 能力 |
|---|---|---|
| **ARGB 排针 / 风扇灯 / 灯带** | ITE IT5701 / IT5702 · **USB HID** | 开关、任意颜色、亮度、6 种动态灯效 |
| **DDR5 内存条灯** | ENE 控制器 · **SMBus 0x70–0x73** | 开关、任意颜色、**16 种灯效** |
| 主板板载灯 | —— | 本型号无独立板载 LED（布局里的 LED_C1 / Chipset Accent / LED_C2 三个 zone 没有实体灯珠）|

**已验证可用**：静态颜色（红/绿/蓝）、呼吸、闪烁、彩虹 —— 两条通道都实测通过。

## 快速开始

### 1. 编译（或直接用 Release 里的 exe）

```powershell
.\build.ps1
```

只需要 Windows 自带的 `csc.exe`，不用装任何 SDK：

```
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
```

### 2. 安装开机自启

```powershell
# 提权运行
powershell -ExecutionPolicy Bypass -File .\install\Install-GccLite.ps1
```

它会：

1. 把 exe 复制到 `%LOCALAPPDATA%\GccLite\`
2. 注册登录触发任务 `GccLiteAll`（延迟 15 秒、最高权限、**直接调用 exe**）
3. 注册 34 个按需触发的灯效任务 `GccLiteFx-*`
4. **禁用技嘉自己的 `GCC` 自启任务**
5. 生成 34 个双击启动器到 `%LOCALAPPDATA%\GccLite\Effects\`

> 计划任务**直接调用 exe**，不走 `powershell.exe -WindowStyle Hidden`——
> 因为部分安全软件（如火绒）的 HIPS 规则会拦截隐藏 PowerShell 的计划任务。

### 3. 用

```powershell
$exe = "$env:LOCALAPPDATA\GccLite\GccLiteAll.exe"

& $exe off                                   # 全关（默认）
& $exe on                                    # 全开成白色
& $exe color FF0000                          # 任意颜色 0xRRGGBB
& $exe effect breath                         # 灯效
& $exe effect cycle --speed 10               # 灯效 + 速度
& $exe brightness 40                         # 亮度 0-255
& $exe --hid-only effect wave                # 只控 ARGB / 风扇
& $exe --smb-only off                        # 只控 DDR5 内存
& $exe list                                  # 列出全部灯效
```

### 4. 双击切换灯效（推荐日常用）

`Effects\` 里 34 个 `.cmd`，**双击即生效、不弹 UAC、效果一直保持**：

- **基础 14 个**：开 / 关 / 静态色 / 呼吸 / 闪烁 / 循环 / 波浪 / 随机 / 慢速 / 快速 / 低亮度 / 单通道测试
- **颜色 10 个**：红 橙 黄 绿 青 蓝 紫 品红 白 暖白
- **ENE 专属 10 个**（内存通道独有）：彩虹 / 呼吸彩虹 / 彗星 / 彩虹彗星 / 流动闪烁 / 辉光往复 / 星空 / 双闪 / AORUS 彩虹 / 冷彩虹

原理：每个 `.cmd` 只是触发一个预先注册好的最高权限计划任务。
**触发自己名下的任务不需要管理员权限**，所以不弹 UAC；而任务本身带最高权限，
内存灯需要的端口 I/O 才能用。

## 命令行参考

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
```

支持的灯效名：

```
static  breath  flash  cycle  rainbow  breathrainbow  comet  cometrainbow
movingflash  wave  yoyo  starry  aorusrainbow  coldrainbow  dflash  random
```

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

更详细的抓包记录和逆向过程见 [`docs/REVERSE-ENGINEERING.md`](docs/REVERSE-ENGINEERING.md)。

## 依赖

| 部件 | 位置 / 设备名 | 谁提供的 |
|---|---|---|
| ARGB 通道 | 无 —— 纯 `setupapi.dll` + `hid.dll` | Windows |
| `MsIo64_ENE.dll` | `%LOCALAPPDATA%\GccLite\ene\` | **CTI**（"CtiIo for ENE"）|
| `CtiIo64.sys` + `CTIIO` 服务 | `C:\Windows\system32\drivers\`，设备 `\\.\CTIIO` | **CTI** 内核驱动 |

**本工具源码里没有任何 GCC 路径，GCC 主程序一个字节都没用到。**

⚠️ 但内存那一路需要上面那两个**第三方组件**（技嘉的安装程序会一并装上）。
本仓库**不包含、也不再分发**这些厂商二进制文件。如果你机器上没有它们，
内存灯通道会不可用（ARGB 通道不受影响，纯 Win32 实现）。

### 能卸载 GCC 吗？

可以。`install\Restore-ENE-Driver.ps1` 是为此准备的恢复脚本，
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

- **睡眠唤醒后**控制器会复位，可能需要再运行一次（可以加一个唤醒触发器）。
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
in a single ~18 KB executable.

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
