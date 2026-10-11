# 逆向过程记录

这份文档记录 GccLite 用到的协议是**怎么挖出来的**，以及中间踩过的坑。
目的有两个：一是让结论可复核，二是给想在其他主板上复现的人一套现成的方法。

---

## 一、方法：代理 DLL 抓包

核心思路很简单：

> GCC 是通过几个自己的 DLL 跟 RGB 控制器通信的。
> **把那个 DLL 换成同名的日志代理**，代理加载真正的 DLL（改名保存），
> 在转发每一次调用的同时把参数记下来——就能拿到完整的通信记录。

```
GCC.exe
  └─ 加载 GHidApi.dll  ← 换成我们的代理
       └─ 代理 LoadLibrary("GHidApi.orig.dll")  ← 真正的原厂 DLL
            └─ 记录参数 → 尾巴跳转 → 原厂函数
```

原生 DLL 用 **MinGW-w64 GCC** 编译即可：

```powershell
scoop install mingw-winlibs       # 或任何 x86_64-w64-mingw32-gcc
gcc -c -O2 ghid_proxy.c -o ghid_proxy.o
gcc -shared -o GHidApi.dll ghid_proxy.o ghid_proxy.def
```

跑一次 `GCC.exe -b`（技嘉自己的静默模式），抓完立刻还原原 DLL。
自动化脚本见 [`tools/re/run-proxy.ps1`](../tools/re/run-proxy.ps1)。

### 两个关键技巧

**1. 签名无关的汇编跳板（签名未知的 DLL 用这个）**

有些 DLL 的导出函数原型我们不知道，用 C 声明参数个数很容易错。
解决办法是写纯汇编的尾跳转——**完全不需要知道原型**：

```asm
    .intel_syntax noprefix
    .text
    .globl Write_SMB_Block
Write_SMB_Block:
    sub  rsp, 0x88
    mov  [rsp+0x28], rcx          # 保存 4 个整型寄存器参数
    mov  [rsp+0x30], rdx
    mov  [rsp+0x38], r8
    mov  [rsp+0x40], r9
    movsd [rsp+0x50], xmm0        # 再保存 4 个浮点参数
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea  rcx, [rip+.Lnm_Write_SMB_Block]
    mov  rdx, [rsp+0x28]
    mov  r8,  [rsp+0x30]
    mov  r9,  [rsp+0x38]
    mov  rax, [rsp+0x40]
    mov  [rsp+0x20], rax          # 第 5 个参数走栈
    call log_call
    # ... 还原所有寄存器 ...
    add  rsp, 0x88
    jmp  qword ptr [rip+p_Write_SMB_Block]    # 尾跳转，完美转发
```

栈对齐要点：x64 Windows 函数入口处 `rsp % 16 == 8`，
`sub rsp, 0x88` 之后变成 `0`（16 字节对齐），满足 `call` 的要求。

**2. 用 objdump 反推原型**

反汇编小 DLL，看函数怎么读它的参数，就能确定原型：

```powershell
objdump -d -M intel --start-address=0x180006880 --stop-address=0x180006fa0 MsIo64_ENE.dll
```

对照 MS x64 调用约定：`rcx/rdx/r8/r9` 是前 4 个参数，第 5 个起在栈上；
函数序言里的 `mov [rsp+0x8], cl` 之类就是参数落位。

---

## 二、三条通道分别抓到了什么

### 1. `GHidApi.dll` — ITE IT5702 的 USB HID 报文

GCC 关灯时实际下发的（按顺序）：

```
CC 60 00 00               读控制器身份 → IT5701-GIGABYTE V3.5.5.0
CC 34 00 00 00 ...        设 ARGB 灯珠数
CC 47 00 ...              关闭"掉电保持"
CC 20 00 ... CC 21 00 ... CC 22 00 ... CC 23 00 ...
CC 24 00 ... CC 25 00 ... CC 26 00 ... CC 27 00 ...     清空 8 个 zone 寄存器
CC 28 FF 00 00 00 ...     APPLY

—— 逐 zone 写 STATIC ——
CC 21 02 00 00 00 | ... | 01 | FF | 00 | 00 00 00 00     LED_C1   zone 位 0x02
CC 22 04 ...                                             Chipset Accent  0x04
CC 32 00 ...                       ← 内置/软件控制位
CC 24 10 ...                                             LED_C2  0x10
CC 25 20 ...                                             D_LED1  0x20
CC 26 40 ...                                             D_LED2  0x40
CC 28 FF 00 ...                   APPLY
```

### 2. `YccDrvv3.dll` — 底层端口 I/O（用来定位 SMBus）

把所有导出换成签名无关跳板。抓到 1456 次 `access_io_port`，
其中大部分是 PCI 配置枚举（`0xCF8/0xCFC`），剩下的是
**`0xEFA0–0xEFA6` = Intel PCH SMBus 控制器**：

| 偏移 | 寄存器 |
|---|---|
| +0x00 | HST_STS |
| +0x02 | HST_CNT（`0x48` = START + Byte-Data，`0x6C` = START + Word-Data）|
| +0x03 | HST_CMD |
| +0x04 | XMIT_SLVA（bit0 = R/W#）|
| +0x05 | HST_D0 |
| +0x06 | HST_D1 |

解码出来：先读 4 条内存的 SPD（`0xA1/0xA3/0xA5/0xA7` → 0x50–0x53），
再往 **0x70/0x71/0x72/0x73** 写模式字 —— 内存灯控制器的地址就此确定。

### 3. `MsIo64_ENE.dll` — DDR5 内存灯的完整协议

**怎么找到它的**：直接列出 `GCC.exe` 进程加载的模块，一眼看到：

```
...\Lib\MBStorage\AACDDR_Lib.dll
C:\Program Files\ENE\Aac_ENE_DRAM_RGB_AIO\x64\AacHal_x64.dll
C:\Program Files\ENE\Aac_ENE_DRAM_RGB_AIO\x64\MsIo64_ENE.dll
```

它只有 11 个导出，名字自解释：`InitializeSMB / ShutdownSMB / ReadSmbType /
Read_SMB_Quick / Read_SMB_Byte / Read_SMB_Word / Read_SMB_Block /
Write_SMB_Byte / Write_SMB_Word / Write_SMB_Block / SMB_Process_Call`。

objdump 反汇编后确定：每个函数构造一个 **12 字节请求包**，交给
`DeviceIoControl`：

```
pkt[0]     = arg1                通道/索引
pkt[1]     = arg2 & 0xFF         SMBus 从机地址
pkt[2]     = arg3 & 0xFF         寄存器
pkt[3..10] = arg4                word 值 或 数据指针
pkt[11]    = arg5 & 0xFF         Block 的长度
```

---

## 三、踩过的坑（这部分最有价值）

### 坑 1：广播报文无效

IT5702 固件**忽略** `header 0x20` + `zone0 = 0xFF` 的广播包。
必须逐个 zone 用各自的 header 和 zone 位。我一开始一直发广播，所以"完全没反应"。

### 坑 2：`CC 32` 的值

我一直以为是 `0x03`（照搬 OpenRGB 里 `SetBuiltin(false)` 的语义），
抓包发现 GCC 用的是 **`0x00`**。

### 坑 3：颜色字节序（ARGB 与内存不一样！）

- **ARGB / HID 通道**：直接写 `0x00RRGGBB`，标准 RGB，不需要交换。
- **DDR5 / ENE 通道**：缓冲区是 **`R, B, G`** 顺序。

实测证据：发 `FF 00 00` 得红色（→ `buf[0]` 是 R），发 `00 FF 00` 得**蓝色**
（→ `buf[1]` 是 B）。工具内部已按实测换算。

### 坑 4：代理的参数个数错了会得到"看起来合理但其实是假象"的数据

我最初把 `Write_SMB_Block` 声明成 4 个参数，但它实际有 **5** 个
（第 5 个是长度）。结果每次转发时长度都是栈上的垃圾值，
抓到的那批"payload"完全没有意义，白白多花了一轮。

**教训**：代理未知原型的函数时，要么用签名无关的汇编跳板，要么先反汇编确认。

### 坑 5：内存灯的序列少一步都不生效

只发 `BLOCK(颜色) + 提交块` 是**不够的**。完整结构见 README，
关键是：前置的 `0x87FB` / `0x8160` 各要发两次、要先发一遍**静态打底**、
再按参数个数重复若干遍灯效遍。

### 坑 6：误判依赖（最典型的一个）

我一度认为内存灯依赖 `MSIO` / `MsIo64.sys`，因为 GCC 装了它、名字又像。

**拆解演练直接推翻了**：把 `MSIO` 停掉、删掉服务、驱动文件改名，
内存灯**照样工作**（`ok=4 failed=0`）。真正的依赖是从 DLL 里挖出来的
设备名 **`\\.\CTIIO`**（对应 `CtiIo64.sys`），把它拆掉立刻变成 `ok=0 failed=4`。

**教训**：依赖关系要靠"拆掉再试"来证明，不能靠名字猜。

### 坑 7：安全软件会拦截隐藏 PowerShell 的计划任务

火绒的 HIPS 规则「隐藏执行 PowerShell」会让
`powershell.exe -WindowStyle Hidden -Command ...` 的计划任务静默失败
（任务结果码 `4294967295`，没有任何日志）。

**解法**：计划任务**直接调用 exe**，绕开这条规则。

---

## 四、技能清单

| 用到的技术 | 用途 |
|---|---|
| 日志代理 DLL + 同名替换 | 抓取任意原生 DLL 的调用 |
| 签名无关的 x64 汇编跳板 | 代理原型未知的 DLL |
| `objdump -d -M intel` | 反推函数原型 |
| .NET 反射 / `MethodBody.GetILAsByteArray()` | 读托管程序集的 IL 调用图 |
| `Assembly.LoadFrom` + `AssemblyResolve` | 加载有依赖的托管程序集 |
| .NET 反射枚举 enum | 拿到灯效模式编号表（比抓包快得多）|
| 列出进程已加载模块 | 快速定位某功能用的是哪个 DLL |
| 拆解 + 恢复演练 | **证明**依赖关系，而不是猜 |

最后一条尤其值得强调：整个项目里最容易出错的就是"依赖判断"，
而唯一可靠的验证方式就是**真的拆掉、确认坏了、再恢复、确认好了**。
