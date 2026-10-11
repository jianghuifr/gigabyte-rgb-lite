# 灯效 / 颜色 —— 双击即切换（不弹 UAC）

> 这些 .cmd 由 install\Install-GccLite.ps1 自动生成到 %LOCALAPPDATA%\GccLite\Effects\。

每个 `.cmd` 双击后立刻生效，**效果一直保持着**，你想看多久看多久。
随时双击 `1-Off.cmd` 全灭。

**共 34 个启动器：14 个基础开关/灯效 + 10 种颜色 + 10 个 ENE 专属灯效。**

---

## 一、基础（已验证）

| 文件 | 作用 | ARGB/风扇 | DDR5 内存 |
|---|---|---|---|
| `1-Off.cmd` | 全灭 | ✅ | ✅ |
| `2-On-White.cmd` | 全亮（白） | ✅ | ✅ |
| `3-Static-Red.cmd` | 静态红 | ✅ | ✅ |
| `4-Static-Green.cmd` | 静态绿 | ✅ | ✅ |
| `5-Breath-Green.cmd` | 呼吸 | ✅ | ✅ |
| `6-Flash-Blue.cmd` | 闪烁 | ✅ | ✅ **已验证** |
| `7-Cycle.cmd` | 彩虹循环 | ✅ | ✅ |
| `8-Wave-Cyan.cmd` | 波浪 | 待验证 | 待验证 |
| `9-Random.cmd` | 随机 | 待验证 | 回退为循环 |
| `A-Breath-Slow-Red.cmd` | 慢速呼吸（speed=1） | 待验证 | 待验证 |
| `B-Cycle-Fast.cmd` | 快速循环（speed=10） | 待验证 | 待验证 |
| `C-Dim-White.cmd` | 低亮度白（40/255） | 待验证 | 待验证 |
| `D-FanOnly-Cycle.cmd` | **只**风扇循环 | ✅ **彩虹流动** | — |
| `E-MemOnly-Breath.cmd` | **只**内存呼吸 | — | ✅ **呼吸生效** |

## 二、颜色（10 色）

| 文件 | 颜色 | 文件 | 颜色 |
|---|---|---|---|
| `F1-Red.cmd` | 红 `FF0000` | `F6-Blue.cmd` | 蓝 `0000FF` |
| `F2-Orange.cmd` | 橙 `FF8000` | `F7-Purple.cmd` | 紫 `8000FF` |
| `F3-Yellow.cmd` | 黄 `FFFF00` | `F8-Magenta.cmd` | 品红 `FF00FF` |
| `F4-Green.cmd` | 绿 `00FF00` | `F9-White.cmd` | 白 `FFFFFF` |
| `F5-Cyan.cmd` | 青 `00FFFF` | `FA-Warm-White.cmd` | 暖白 `FFAA55` |

## 三、ENE 专属灯效（内存通道才有，10 个）

模式编号来自 `Gigabyte.ULightingEffects.Devices.ENE.EneLedNewMode`。

| 文件 | 灯效 | ENE mode | 已验证 |
|---|---|---|---|
| `G-Rainbow.cmd` | 彩虹 | 5 | 待验证 |
| `H-Breath-Rainbow.cmd` | 呼吸彩虹 | 6 | 待验证 |
| `I-Comet.cmd` | 彗星 | 7 | 待验证 |
| `J-Comet-Rainbow.cmd` | 彩虹彗星 | 8 | 待验证 |
| `K-Moving-Flash.cmd` | 流动闪烁 | 9 | 待验证 |
| `L-YoYo.cmd` | 辉光往复 | 12 | 待验证 |
| `M-Starry-Night.cmd` | 星空 | 13 | 待验证 |
| `N-Double-Flash.cmd` | 双闪 | 254 | 待验证 |
| `O-Aorus-Rainbow.cmd` | AORUS 彩虹 | 80 | 待验证 |
| `P-Cold-Rainbow.cmd` | AORUS 冷彩虹 | 81 | 待验证 |

---

## 四、两个必须记住的实测细节

**注 1：内存通道的颜色缓冲区是 `R, B, G`，不是 RGB。**
实测 `FF 00 00` → 红、`00 FF 00` → **蓝**。工具内部已按实测换算，
所以你填标准 `--color 00FF00` 就是绿色。ARGB（风扇）那路是标准 RGB。

**注 2：内存灯的动效颜色不跟 `--color` 走。**
ENE 控制器的动效用它自己的颜色通道（发"绿色呼吸"会看到蓝色呼吸）。
静态模式的颜色是准的。

---

## 五、原理

每个 `.cmd` 只是触发一个预先注册好的计划任务（`GccLiteFx-*`，最高权限）。
触发自己名下的任务**不需要管理员权限**，所以不弹 UAC；任务本身带最高权限，
内存灯需要的 `MsIo64.sys` 端口 I/O 才能用。

## 六、命令行（进阶）

```powershell
$exe = "$env:LOCALAPPDATA\GccLite\GccLiteAll.exe"
& $exe off
& $exe color 20FF60
& $exe effect rainbow
& $exe effect flash --color 0000FF
& $exe --hid-only effect wave      # 只控风扇
& $exe --smb-only effect comet     # 只控内存
& $exe brightness 40
& $exe list
```

任意颜色/灯效都可以临时触发已有任务，不用提权：

```powershell
schtasks /Run /TN GccLiteFx-Rainbow
```

