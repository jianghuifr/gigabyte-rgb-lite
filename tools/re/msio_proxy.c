// MsIo64_ENE.dll logging proxy - ENE DRAM RGB SMBus layer used for the DDR5 DIMM LEDs.
// Forwards every export to a renamed copy of the real DLL.
//   * simple exports use signature-agnostic assembly trampolines (msio_proxy.S)
//   * the two Block functions are implemented in C so the block payload can be dumped
//
// Build:
//   gcc -c -O2 msio_proxy.c -o msio_proxy.o
//   gcc -c msio_proxy.S -o msio_stubs.o
//   gcc -shared -o MsIo64_ENE.dll msio_proxy.o msio_stubs.o msio_proxy.def

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

static HMODULE g_real = NULL;
static FILE   *g_log  = NULL;

static char g_logpath[MAX_PATH];
static void InitLogPath(void)
{
    const char *la = getenv("LOCALAPPDATA");
    char dir[MAX_PATH];
    if (!la) la = ".";
    snprintf(dir, sizeof(dir), "%s\\\\GccLiteRE", la);
    CreateDirectoryA(dir, NULL);
    snprintf(g_logpath, sizeof(g_logpath), "%s\\\\msio-proxy.log", dir);
}

#define DECL(n) void *p_##n = 0;
DECL(InitializeSMB)
DECL(ReadSmbType)
DECL(Read_SMB_Block)
DECL(Read_SMB_Byte)
DECL(Read_SMB_Quick)
DECL(Read_SMB_Word)
DECL(SMB_Process_Call)
DECL(ShutdownSMB)
DECL(Write_SMB_Block)
DECL(Write_SMB_Byte)
DECL(Write_SMB_Word)

static void L(const char *fmt, ...)
{
    va_list ap;
    if (!g_log) return;
    va_start(ap, fmt);
    vfprintf(g_log, fmt, ap);
    va_end(ap);
    fputc('\n', g_log);
    fflush(g_log);
}

static int Readable(const void *p, int n)
{
    MEMORY_BASIC_INFORMATION mbi;
    unsigned char *q = (unsigned char *)p;
    int done = 0;
    if (!p) return 0;
    while (done < n)
    {
        if (VirtualQuery(q + done, &mbi, sizeof(mbi)) == 0) return 0;
        if (mbi.State != MEM_COMMIT) return 0;
        if (mbi.Protect & (PAGE_NOACCESS | PAGE_GUARD)) return 0;
        done += (int)mbi.RegionSize - ((int)((ULONG_PTR)(q + done) - (ULONG_PTR)mbi.BaseAddress));
        if (done <= 0) return 0;
    }
    return 1;
}

static void DumpPtr(const char *tag, const void *p, int n)
{
    int i;
    const unsigned char *b = (const unsigned char *)p;
    char line[256];
    char *w;
    if (!p) return;
    if (!Readable(p, n))
    {
        fprintf(g_log, "%s @%p : unreadable\n", tag, p);
        fflush(g_log);
        return;
    }
    fprintf(g_log, "%s @%p :", tag, p);
    for (i = 0; i < n; i++)
    {
        if ((i % 16) == 0) { fprintf(g_log, "\n        "); }
        fprintf(g_log, "%02X ", b[i]);
    }
    fprintf(g_log, "\n");
    fflush(g_log);
    (void)line; (void)w;
}

void log_call(const char *name, unsigned long long a, unsigned long long b,
              unsigned long long c, unsigned long long d, unsigned long long e)
{
    if (!g_log) return;
    fprintf(g_log, "%-20s a=0x%llX b=0x%llX c=0x%llX d=0x%llX e=0x%llX\n",
            name, a, b, c, d, e);
    fflush(g_log);
}

/* --- Block calls implemented in C so the payload can be captured --- */

__declspec(dllexport) int __cdecl Write_SMB_Block(int a, int b, int c, const void *d, int e)
{
    int r;
    fprintf(g_log, "Write_SMB_Block      a=0x%X b=0x%X c=0x%X d=%p len=%d\n", a, b, c, d, e);
    fflush(g_log);
    if (d && e > 0 && e <= 240) DumpPtr("   data", d, e);
    else if (d) fprintf(g_log, "   (len=%d, data not dumped)\n", e);
    if (!p_Write_SMB_Block) return -1;
    r = ((int (__cdecl *)(int, int, int, const void *, int))p_Write_SMB_Block)(a, b, c, d, e);
    fprintf(g_log, "   -> %d\n", r);
    fflush(g_log);
    return r;
}

__declspec(dllexport) int __cdecl Read_SMB_Block(int a, int b, const void *c, const void *d)
{
    int r;
    fprintf(g_log, "Read_SMB_Block       a=0x%X b=0x%X c=%p d=%p\n", a, b, c, d);
    fflush(g_log);
    DumpPtr("   args[2]", c, 32);
    if (!p_Read_SMB_Block) return -1;
    r = ((int (__cdecl *)(int, int, const void *, const void *))p_Read_SMB_Block)(a, b, c, d);
    fprintf(g_log, "   -> %d\n", r);
    fflush(g_log);
    DumpPtr("   args[2] after", c, 64);
    return r;
}

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD reason, LPVOID reserved)
{
    char self[MAX_PATH];
    char real[MAX_PATH];
    char *slash;

    (void)reserved;
    if (reason != DLL_PROCESS_ATTACH) return TRUE;

    g_log = InitLogPath(), fopen(g_logpath, "a");
    L("");
    L("=== MsIo64_ENE proxy attached pid=%lu ===", (unsigned long)GetCurrentProcessId());

    if (!GetModuleFileNameA(hinst, self, MAX_PATH)) return TRUE;
    strcpy(real, self);
    slash = strrchr(real, '\\');
    if (slash) *(slash + 1) = 0;
    strcat(real, "MsIo64_ENE.orig.dll");
    L("real dll : %s", real);

    g_real = LoadLibraryA(real);
    if (!g_real) { L("FATAL: LoadLibrary failed err=%lu", (unsigned long)GetLastError()); return TRUE; }
    L("real dll loaded ok");

#define BIND(n) p_##n = (void *)GetProcAddress(g_real, #n); if (!p_##n) L("  missing export %s", #n);
    BIND(InitializeSMB) BIND(ReadSmbType) BIND(Read_SMB_Block) BIND(Read_SMB_Byte)
    BIND(Read_SMB_Quick) BIND(Read_SMB_Word) BIND(SMB_Process_Call) BIND(ShutdownSMB)
    BIND(Write_SMB_Block) BIND(Write_SMB_Byte) BIND(Write_SMB_Word)
    L("all pointers bound");
    return TRUE;
}


