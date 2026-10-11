// GccLiteAll - standalone lighting control for a Gigabyte Z790M AORUS ELITE,
// with no GIGABYTE Control Center involved at runtime.
//
// Two independent channels, both reverse engineered from GCC itself
// (see PROXY_FINDINGS.md):
//
//  (1) ARGB headers / fans - ITE IT5701/IT5702 over USB HID.
//      Per-zone PktEffect packets; the firmware ignores broadcast packets.
//      header 0x21/0x22/0x24/0x25/0x26 with zone bits 0x02/0x04/0x10/0x20/0x40
//      packet: [0]=0xCC [1]=header [2..5]=zone0 [11]=effect [12]=maxBri
//              [14..17]=color0 0x00RRGGBB [22..27]=periods [30..31]=params
//
//  (2) DDR5 DIMM RGB - ENE controllers on SMBus 0x70..0x73 via MsIo64_ENE.dll.
//      init   : WORD 0x4000, 0x1CF0, 0x1030, 0x87FB, 0x80A1
//      colour : BLOCK(reg 3, RGB triplets, len = leds*3)
//      commit : WORD 0x8020, BLOCK(reg 3, {00,mode,00,00}, 4), WORD 0x8029,
//               BYTE(reg 1, 0x09), WORD 0x802F, BYTE(reg 1, 0x01)
//      effect : WORD 0x80F2, BYTE(reg 1, param)     (breath 0x8C, cycle 0x11)
//      final  : WORD 0x8160
//      mode: 1 = static, 2 = breath, 4 = colour cycle
//
// Build: csc.exe /target:winexe /platform:x64 /optimize+ /out:GccLiteAll.exe GccLiteAll.cs

using System;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Threading;

internal static class GccLiteAll
{
    // ---------------- ITE IT5702 (USB HID) ----------------

    private const byte ReportId = 0xCC;
    private const int BufSize = 64;
    private const ushort DefVid = 0x048D, DefPid = 0x5702;
    private const ushort UsagePageRgb = 0xFF89, UsageRgb = 0x00CC;
    private const uint DIGCF_PRESENT = 0x02, DIGCF_DEVICEINTERFACE = 0x10;
    private const int HIDP_STATUS_SUCCESS = 0x00110000;

    private static Guid HidInterfaceGuid = new Guid("4D1E55B2-F16F-11CF-88CB-001111000030");
    private static readonly IntPtr InvalidHandle = new IntPtr(-1);

    private static readonly byte[] ZoneReg = new byte[] { 0x21, 0x22, 0x24, 0x25, 0x26 };
    private static readonly uint[] ZoneBit = new uint[] { 0x02, 0x04, 0x10, 0x20, 0x40 };

    [StructLayout(LayoutKind.Sequential)]
    private struct SP_DEVICE_INTERFACE_DATA { public int cbSize; public Guid InterfaceClassGuid; public int Flags; public IntPtr Reserved; }

    [StructLayout(LayoutKind.Sequential)]
    private struct HIDD_ATTRIBUTES { public int Size; public ushort VendorID; public ushort ProductID; public ushort VersionNumber; }

    [StructLayout(LayoutKind.Sequential)]
    private struct HIDP_CAPS
    {
        public ushort Usage, UsagePage, InputReportByteLength, OutputReportByteLength, FeatureReportByteLength;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 17)] public ushort[] Reserved;
        public ushort NumberLinkCollectionNodes, NumberInputButtonCaps, NumberInputValueCaps, NumberInputDataIndices;
        public ushort NumberOutputButtonCaps, NumberOutputValueCaps, NumberOutputDataIndices;
        public ushort NumberFeatureButtonCaps, NumberFeatureValueCaps, NumberFeatureDataIndices;
    }

    [DllImport("setupapi.dll", CharSet = CharSet.Unicode, SetLastError = true)] private static extern IntPtr SetupDiGetClassDevsW(ref Guid g, IntPtr e, IntPtr h, uint f);
    [DllImport("setupapi.dll", SetLastError = true)] private static extern bool SetupDiEnumDeviceInterfaces(IntPtr s, IntPtr d, ref Guid g, uint i, ref SP_DEVICE_INTERFACE_DATA did);
    [DllImport("setupapi.dll", CharSet = CharSet.Unicode, SetLastError = true)] private static extern bool SetupDiGetDeviceInterfaceDetailW(IntPtr s, ref SP_DEVICE_INTERFACE_DATA did, IntPtr det, int sz, out int need, IntPtr d);
    [DllImport("setupapi.dll", SetLastError = true)] private static extern bool SetupDiDestroyDeviceInfoList(IntPtr s);
    [DllImport("hid.dll", SetLastError = true)] private static extern byte HidD_GetAttributes(IntPtr h, ref HIDD_ATTRIBUTES a);
    [DllImport("hid.dll", SetLastError = true)] private static extern byte HidD_GetPreparsedData(IntPtr h, out IntPtr p);
    [DllImport("hid.dll", SetLastError = true)] private static extern byte HidD_FreePreparsedData(IntPtr p);
    [DllImport("hid.dll", SetLastError = true)] private static extern int HidP_GetCaps(IntPtr p, ref HIDP_CAPS c);
    [DllImport("hid.dll", SetLastError = true)] private static extern byte HidD_SetFeature(IntPtr h, byte[] b, int n);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)] private static extern IntPtr CreateFileW(string f, uint a, uint s, IntPtr sa, uint c, uint fl, IntPtr t);
    [DllImport("kernel32.dll", SetLastError = true)] private static extern bool CloseHandle(IntPtr h);

    // ---------------- ENE DDR5 DIMM (SMBus) ----------------

    // Preference order for the ENE SMBus layer. Our own copy comes first so that
    // uninstalling GIGABYTE Control Center cannot break the DDR5 channel.
    private static string[] EneDirs()
    {
        string local = System.IO.Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "GccLite", "ene");
        return new string[]
        {
            local,
            @"C:\Program Files\ENE\Aac_ENE_DRAM_RGB_AIO\x64",
            @"C:\Program Files\ENE\Aac_ENE RGB HAL\x64"
        };
    }

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)] private static extern bool SetDllDirectory(string p);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)] private static extern IntPtr LoadLibraryW(string p);

    [DllImport("MsIo64_ENE.dll", CallingConvention = CallingConvention.Cdecl)] private static extern int InitializeSMB();
    [DllImport("MsIo64_ENE.dll", CallingConvention = CallingConvention.Cdecl)] private static extern int ReadSmbType();
    [DllImport("MsIo64_ENE.dll", CallingConvention = CallingConvention.Cdecl)] private static extern int ShutdownSMB();
    [DllImport("MsIo64_ENE.dll", CallingConvention = CallingConvention.Cdecl)] private static extern int Write_SMB_Word(int idx, int addr, int reg, ushort value);
    [DllImport("MsIo64_ENE.dll", CallingConvention = CallingConvention.Cdecl)] private static extern int Write_SMB_Byte(int idx, int addr, int reg, byte value);
    [DllImport("MsIo64_ENE.dll", CallingConvention = CallingConvention.Cdecl)] private static extern int Write_SMB_Block(int idx, int addr, int reg, byte[] data, byte len);

    private static readonly int[] DimmAddr = new int[] { 0x70, 0x71, 0x72, 0x73 };

    // ---------------- effect tables ----------------

    // names accepted on the command line
    private static readonly string[] EffectNames = new string[]
    { "static", "breath", "flash", "cycle", "rainbow", "breathrainbow", "comet",
      "cometrainbow", "movingflash", "wave", "yoyo", "starry", "aorusrainbow",
      "coldrainbow", "dflash", "random" };

    // ARGB PktEffect effect_type values (OpenRGB EffectType)
    private static byte ArgEffectType(string name)
    {
        switch (name)
        {
            case "static": return 1;
            case "breath": return 2;   // EFFECT_PULSE
            case "flash": return 3;    // EFFECT_BLINKING
            case "cycle": return 4;    // EFFECT_COLORCYCLE
            case "rainbow": return 4;  // ARGB has no separate rainbow; reuse colour cycle
            case "wave": return 6;
            case "random": return 8;
            default: return 1;
        }
    }

    // DIMM effect descriptor. The 4-byte commit block is {00, mode, b2, b3};
    // "mode" matches Gigabyte.ULightingEffects.Devices.ENE.EneLedNewMode exactly
    // (1 static, 2 breathing, 3 flash, 4 colour cycle, 5 rainbow, 6 breathing
    //  rainbow, 7 comet, 11 wave, 254 double flash, ...).
    // The 0x80F2 parameter bytes were captured verbatim from GCC per mode.
    private sealed class DimSpec
    {
        public byte Mode;
        public byte B2;
        public byte B3;
        public byte[] Params;
        public DimSpec(byte mode, byte b2, byte b3, byte[] prm) { Mode = mode; B2 = b2; B3 = b3; Params = prm; }
    }

    private static readonly byte[] NoParams = new byte[0];

    private static DimSpec DimEffect(string name)
    {
        switch (name)
        {
            case "static": return new DimSpec(1, 0, 0, NoParams);
            case "breath": return new DimSpec(2, 0, 0, new byte[] { 0x8C, 0x8E });
            case "flash": return new DimSpec(3, 1, 0, new byte[] { 0x27, 0x28, 0x0D });
            case "cycle": return new DimSpec(4, 0, 0, new byte[] { 0x11 });
            case "rainbow": return new DimSpec(5, 0, 1, new byte[] { 0xDB, 0xDF, 0x7E, 0x1C });
            case "breathrainbow": return new DimSpec(6, 0, 0, NoParams);
            case "comet": return new DimSpec(7, 0, 0, NoParams);
            case "cometrainbow": return new DimSpec(8, 0, 0, NoParams);
            case "movingflash": return new DimSpec(9, 0, 0, NoParams);
            case "wave": return new DimSpec(11, 0, 0, NoParams);
            case "yoyo": return new DimSpec(12, 0, 0, NoParams);
            case "starry": return new DimSpec(13, 0, 0, NoParams);
            case "aorusrainbow": return new DimSpec(80, 0, 0, NoParams);
            case "coldrainbow": return new DimSpec(81, 0, 0, NoParams);
            case "dflash": return new DimSpec(254, 0, 0, NoParams);
            // no measured DIMM encoding - fall back to something sane
            case "random": return new DimSpec(4, 0, 0, new byte[] { 0x11 });
            default: return new DimSpec(1, 0, 0, NoParams);
        }
    }

    // ---------------- logging ----------------

    private static string _logPath;

    private static void Log(string s)
    {
        string line = string.Format("{0:yyyy-MM-dd HH:mm:ss}  {1}", DateTime.Now, s);
        try { Console.WriteLine(line); } catch { }
        try { if (_logPath != null) System.IO.File.AppendAllText(_logPath, line + Environment.NewLine); } catch { }
    }

    private static void WriteU32(byte[] b, int off, uint v)
    {
        b[off] = (byte)(v & 0xFF); b[off + 1] = (byte)((v >> 8) & 0xFF);
        b[off + 2] = (byte)((v >> 16) & 0xFF); b[off + 3] = (byte)((v >> 24) & 0xFF);
    }

    // ---------------- main ----------------

    private static int Main(string[] args)
    {
        try
        {
            string ld = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "GccLite");
            System.IO.Directory.CreateDirectory(ld);
            _logPath = System.IO.Path.Combine(ld, "GccLiteAll.log");
        }
        catch { }

        string cmd = (args.Length > 0 && !args[0].StartsWith("-")) ? args[0].ToLowerInvariant() : "off";
        uint color = 0x000000;
        int leds = 8;
        int speed = 5;
        byte brightness = 0xFF;
        bool doHid = true, doSmb = true;
        string effect = "static";
        bool effectGiven = false;

        int start = (args.Length > 0 && !args[0].StartsWith("-")) ? 1 : 0;
        for (int i = start; i < args.Length; i++)
        {
            string a = args[i].ToLowerInvariant();
            if ((a == "--color" || a == "-c") && i + 1 < args.Length) { color = Convert.ToUInt32(args[++i].TrimStart('#'), 16) & 0xFFFFFFu; }
            else if ((a == "--leds") && i + 1 < args.Length) { leds = int.Parse(args[++i], CultureInfo.InvariantCulture); }
            else if ((a == "--speed") && i + 1 < args.Length) { speed = int.Parse(args[++i], CultureInfo.InvariantCulture); }
            else if ((a == "--brightness") && i + 1 < args.Length) { brightness = byte.Parse(args[++i], CultureInfo.InvariantCulture); }
            else if (a == "--hid-only") { doSmb = false; }
            else if (a == "--smb-only") { doHid = false; }
            else if (a == "--effect" && i + 1 < args.Length) { effect = args[++i].ToLowerInvariant(); effectGiven = true; }
            else if (args[i].Length == 6 && !a.StartsWith("-")) { try { color = Convert.ToUInt32(args[i], 16) & 0xFFFFFFu; } catch { } }
        }

        Log("=== GccLiteAll " + string.Join(" ", args) + " ===");

        switch (cmd)
        {
            case "help":
            case "--help":
            case "-h":
                Usage(); return 0;

            case "list":
                Console.WriteLine("effects: " + string.Join(", ", EffectNames));
                return 0;

            case "off":
                DoAll("static", 0x000000, 0xFF, speed, leds, doHid, doSmb);
                return 0;

            case "on":
                DoAll("static", 0xFFFFFF, 0xFF, speed, leds, doHid, doSmb);
                return 0;

            case "color":
                if (color == 0) color = 0xFFFFFF;
                DoAll(effectGiven ? effect : "static", color, brightness, speed, leds, doHid, doSmb);
                return 0;

            case "effect":
                if (!effectGiven) effect = args.Length > 1 ? args[1].ToLowerInvariant() : "cycle";
                if (color == 0) color = 0xFFFFFF;
                DoAll(effect, color, brightness, speed, leds, doHid, doSmb);
                return 0;

            case "brightness":
                if (args.Length > 1) brightness = byte.Parse(args[1], CultureInfo.InvariantCulture);
                DoAll("static", 0xFFFFFF, brightness, speed, leds, doHid, doSmb);
                return 0;

            case "demo":
                Demo(speed, leds, doHid, doSmb);
                return 0;

            default:
                Usage(); return 1;
        }
    }

    private static void DoAll(string effect, uint color, byte brightness, int speed, int leds, bool doHid, bool doSmb)
    {
        Log("  effect=" + effect + " colour=0x" + color.ToString("X6") + " bri=" + brightness + " speed=" + speed + " leds=" + leds);
        if (doHid) DoHid(effect, color, brightness, speed);
        if (doSmb) DoSmb(effect, color, leds);
        Log("  done");
    }

    private static void Demo(int speed, int leds, bool doHid, bool doSmb)
    {
        string[] seq = new string[] { "off", "static", "breath", "flash", "cycle", "wave", "random", "off" };
        uint[] cols = new uint[] { 0x000000, 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0x00FFFF, 0xFF00FF, 0x000000 };
        Console.WriteLine("=== DEMO: 每步 8 秒，屏幕上是步号 ===");
        for (int i = 0; i < seq.Length; i++)
        {
            string step = seq[i];
            Console.WriteLine();
            Console.WriteLine(">>>>>>>>>> 第 {0} 步：{1}   颜色 0x{2:X6}", i + 1, step, cols[i]);
            Console.WriteLine("           发送中 ...");
            if (step == "off") DoAll("static", 0x000000, 0xFF, speed, leds, doHid, doSmb);
            else DoAll(step, cols[i], 0xFF, speed, leds, doHid, doSmb);
            for (int t = 8; t > 0; t--) { Console.Write("\r           观察中 ... {0} 秒   ", t); Thread.Sleep(1000); }
            Console.Write("\r                              \n");
        }
        Console.WriteLine();
        Console.WriteLine("=== DEMO 结束 ===");
        Console.WriteLine("请告诉我：第几步的灯有变化、是哪种效果（风扇灯 / 内存灯 分别说）。");
        Log("  demo finished");
    }

    // ---------------- ARGB headers (IT5702 over HID) ----------------

    private static void DoHid(string effect, uint color, byte brightness, int speed)
    {
        Log("[1] ARGB headers (IT5702 USB HID) effect=" + effect);
        try
        {
            IntPtr set = SetupDiGetClassDevsW(ref HidInterfaceGuid, IntPtr.Zero, IntPtr.Zero, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
            if (set == InvalidHandle) { Log("    SetupDiGetClassDevs failed"); return; }
            try
            {
                SP_DEVICE_INTERFACE_DATA did = new SP_DEVICE_INTERFACE_DATA();
                did.cbSize = Marshal.SizeOf(typeof(SP_DEVICE_INTERFACE_DATA));
                for (uint i = 0; ; i++)
                {
                    if (!SetupDiEnumDeviceInterfaces(set, IntPtr.Zero, ref HidInterfaceGuid, i, ref did)) break;
                    int need = 0;
                    SetupDiGetDeviceInterfaceDetailW(set, ref did, IntPtr.Zero, 0, out need, IntPtr.Zero);
                    if (need <= 0) continue;
                    IntPtr buf = Marshal.AllocHGlobal(need);
                    string path = null;
                    try
                    {
                        Marshal.WriteInt32(buf, (IntPtr.Size == 8) ? 8 : 6);
                        int got = 0;
                        if (!SetupDiGetDeviceInterfaceDetailW(set, ref did, buf, need, out got, IntPtr.Zero)) continue;
                        path = Marshal.PtrToStringUni(new IntPtr(buf.ToInt64() + 4));
                    }
                    finally { Marshal.FreeHGlobal(buf); }
                    if (string.IsNullOrEmpty(path)) continue;

                    IntPtr h = CreateFileW(path, 0xC0000000u, 3u, IntPtr.Zero, 3u, 0u, IntPtr.Zero);
                    if (h == IntPtr.Zero) continue;
                    bool match = false;
                    try
                    {
                        HIDD_ATTRIBUTES at = new HIDD_ATTRIBUTES();
                        at.Size = Marshal.SizeOf(typeof(HIDD_ATTRIBUTES));
                        ushort featLen = 64;
                        if (HidD_GetAttributes(h, ref at) != 0 && at.VendorID == DefVid && at.ProductID == DefPid)
                        {
                            IntPtr pre = IntPtr.Zero;
                            if (HidD_GetPreparsedData(h, out pre) != 0 && pre != IntPtr.Zero)
                            {
                                HIDP_CAPS caps = new HIDP_CAPS();
                                caps.Reserved = new ushort[17];
                                if (HidP_GetCaps(pre, ref caps) == HIDP_STATUS_SUCCESS &&
                                    caps.UsagePage == UsagePageRgb && caps.Usage == UsageRgb)
                                {
                                    match = true;
                                    if (caps.FeatureReportByteLength > 0) featLen = caps.FeatureReportByteLength;
                                }
                                HidD_FreePreparsedData(pre);
                            }
                        }
                        if (!match) continue;

                        byte[] p = new byte[BufSize];
                        // ---- GCC's preamble ----
                        p[0] = ReportId; p[1] = 0x34; Send(h, featLen, p); Thread.Sleep(20);
                        Array.Clear(p, 0, BufSize); p[0] = ReportId; p[1] = 0x47; Send(h, featLen, p); Thread.Sleep(20);
                        for (byte reg = 0x20; reg <= 0x27; reg++)
                        {
                            Array.Clear(p, 0, BufSize); p[0] = ReportId; p[1] = reg; Send(h, featLen, p); Thread.Sleep(5);
                        }
                        Array.Clear(p, 0, BufSize); p[0] = ReportId; p[1] = 0x28; p[2] = 0xFF; Send(h, featLen, p); Thread.Sleep(20);

                        // ---- per zone effect ----
                        byte eff = ArgEffectType(effect);
                        for (int z = 0; z < ZoneReg.Length; z++)
                        {
                            byte[] e = new byte[BufSize];
                            e[0] = ReportId;
                            e[1] = ZoneReg[z];
                            WriteU32(e, 2, ZoneBit[z]);
                            e[11] = eff;
                            e[12] = brightness;
                            e[13] = 0x00;
                            WriteU32(e, 14, color);
                            WriteU32(e, 18, 0);
                            WriteU32(e, 22, 0);
                            WriteU32(e, 26, 0);
                            ApplyPeriods(e, eff, speed);
                            Send(h, featLen, e);
                            Thread.Sleep(10);
                        }
                        Array.Clear(p, 0, BufSize); p[0] = ReportId; p[1] = 0x32; Send(h, featLen, p); Thread.Sleep(10);
                        Array.Clear(p, 0, BufSize); p[0] = ReportId; p[1] = 0x28; p[2] = 0xFF; Send(h, featLen, p);
                        Log("    5 zones: effect=" + effect + "/" + eff + " colour=0x" + color.ToString("X6"));
                    }
                    finally { CloseHandle(h); }
                    if (match) return;
                }
                Log("    IT5702 not found");
            }
            finally { SetupDiDestroyDeviceInfoList(set); }
        }
        catch (Exception ex) { Log("    HID error: " + ex.Message); }
    }

    /// <summary>Period fields copied from OpenRGB's SetLEDEffect so hardware animations move at a sane rate.</summary>
    private static void ApplyPeriods(byte[] e, byte eff, int speed)
    {
        if (speed < 1) speed = 1; if (speed > 10) speed = 10;
        switch (eff)
        {
            case 2: // pulse
                {
                    int p0 = (speed <= 6) ? (400 + speed * 100) : (1000 + (speed - 6) * 200);
                    WriteU16(e, 22, p0); WriteU16(e, 24, p0); WriteU16(e, 26, 200);
                    break;
                }
            case 3: // blinking
                WriteU16(e, 22, 100); WriteU16(e, 24, 100); WriteU16(e, 26, speed * 200 + 700);
                break;
            case 4: // colour cycle
                WriteU16(e, 22, speed * 100 + 300); WriteU16(e, 24, speed * 100 + 100); e[30] = 7;
                break;
            case 6: // wave
                WriteU16(e, 22, ((speed + 1) * (speed + 1) + (speed + 1) + 10) * 5 / 2); e[30] = 7;
                break;
            case 8: // random
                e[30] = 7;
                break;
        }
        e[31] = (byte)speed;
    }

    private static void WriteU16(byte[] b, int off, int v)
    {
        b[off] = (byte)(v & 0xFF); b[off + 1] = (byte)((v >> 8) & 0xFF);
    }

    private static void Send(IntPtr h, ushort featLen, byte[] p)
    {
        int len = p.Length;
        if (featLen > 0 && featLen < len) len = featLen;
        byte[] o = p;
        if (len != p.Length) { o = new byte[len]; Array.Copy(p, o, len); }
        HidD_SetFeature(h, o, len);
    }

    // ---------------- DDR5 DIMMs (ENE over SMBus) ----------------

    private static void DoSmb(string effect, uint color, int leds)
    {
        Log("[2] DDR5 DIMM RGB (ENE MsIo64) effect=" + effect);

        DimSpec spec = DimEffect(effect);

        string dir = null;
        foreach (string d in EneDirs()) { if (System.IO.File.Exists(System.IO.Path.Combine(d, "MsIo64_ENE.dll"))) { dir = d; break; } }
        if (dir == null) { Log("    MsIo64_ENE.dll not found"); return; }
        SetDllDirectory(dir);
        IntPtr hMod = LoadLibraryW(System.IO.Path.Combine(dir, "MsIo64_ENE.dll"));
        if (hMod == IntPtr.Zero)
        {
            Log("    LoadLibrary failed: " + Marshal.GetLastWin32Error()); return;
        }
        Log("    loaded MsIo64_ENE.dll from: " + dir);

        byte r = (byte)((color >> 16) & 0xFF), g = (byte)((color >> 8) & 0xFF), b = (byte)(color & 0xFF);
        int len = leds * 3; if (len < 3) len = 3; if (len > 240) len = 240;
        // Measured on this board: the DIMM colour buffer is R,B,G (not RGB).
        //   buffer FF 00 00 -> red, buffer 00 FF 00 -> BLUE, i.e. buf[1] drives blue.
        // (The ARGB/HID channel is plain RGB and is handled separately.)
        byte[] buf = new byte[len];
        for (int i = 0; i < leds && (i * 3 + 2) < len; i++)
        {
            buf[i * 3 + 0] = r;
            buf[i * 3 + 1] = b;
            buf[i * 3 + 2] = g;
        }

        int okCalls = 0, badCalls = 0;
        InitializeSMB();
        ReadSmbType();
        foreach (int addr in DimmAddr)
        {
            // ---- GCC's exact preamble (note 0x87FB / 0x8160 are each sent twice) ----
            if (Write_SMB_Word(0, addr, 0x00, 0x4000) != 0) okCalls++; else badCalls++;
            Write_SMB_Word(0, addr, 0x00, 0x1CF0);
            Write_SMB_Word(0, addr, 0x00, 0x1030);
            Write_SMB_Word(0, addr, 0x00, 0x87FB);
            Write_SMB_Word(0, addr, 0x00, 0x80A1);
            Write_SMB_Word(0, addr, 0x00, 0x87FB);
            Write_SMB_Word(0, addr, 0x00, 0x8160);

            // ---- pass 1: GCC always lays down a STATIC frame first ----
            OnePass(addr, buf, len, 0x01, 0x00, 0x00, 0x00, false);

            // ---- effect passes: one per captured 0x80F2 parameter ----
            int passes = spec.Params.Length > 0 ? spec.Params.Length : 1;
            for (int p = 0; p < passes; p++)
            {
                byte prm = spec.Params.Length > 0 ? spec.Params[p] : (byte)0x00;
                OnePass(addr, buf, len, spec.Mode, spec.B2, spec.B3, prm, spec.Params.Length > 0);
            }
            Thread.Sleep(60);
        }
        ShutdownSMB();
        Log("    SMBus calls ok=" + okCalls + " failed=" + badCalls);
        Log("    4 DIMMs: mode=" + spec.Mode + " b2=" + spec.B2 + " b3=" + spec.B3 +
            " params=" + spec.Params.Length + " colour=0x" + color.ToString("X6"));
    }

    /// <summary>One colour+commit cycle, exactly as GCC structures it.</summary>
    private static void OnePass(int addr, byte[] buf, int len, byte mode, byte b2, byte b3, byte param, bool hasParam)
    {
        byte[] commit = new byte[] { 0x00, mode, b2, b3 };
        Write_SMB_Block(0, addr, 0x03, buf, (byte)len);
        Write_SMB_Word(0, addr, 0x00, 0x8020);
        Write_SMB_Block(0, addr, 0x03, commit, 4);
        Write_SMB_Word(0, addr, 0x00, 0x8029);
        Write_SMB_Byte(0, addr, 0x01, 0x09);
        Write_SMB_Word(0, addr, 0x00, 0x802F);
        Write_SMB_Byte(0, addr, 0x01, 0x01);
        if (hasParam)
        {
            Write_SMB_Word(0, addr, 0x00, 0x80F2);
            Write_SMB_Byte(0, addr, 0x01, param);
        }
        Write_SMB_Word(0, addr, 0x00, 0x8160);
        Thread.Sleep(20);
    }

    private static void Usage()
    {
        Console.WriteLine("GccLiteAll <command> [options]");
        Console.WriteLine();
        Console.WriteLine("  off                          关灯（默认）");
        Console.WriteLine("  on                           开成白色");
        Console.WriteLine("  color RRGGBB                 静态颜色");
        Console.WriteLine("  effect <name>                灯效见 list");
        Console.WriteLine("  brightness <0-255>           亮度");
        Console.WriteLine("  demo                         依次演示各灯效（每步 8 秒，屏幕上有步号）");
        Console.WriteLine("  list                         列出支持的灯效");
        Console.WriteLine();
        Console.WriteLine("选项： --color RRGGBB  --leds N  --speed 1-10  --brightness 0-255");
        Console.WriteLine("       --hid-only  只控 ARGB/风扇    --smb-only  只控 DDR5 内存");
    }
}




