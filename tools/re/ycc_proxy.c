// YccDrvv3.dll logging proxy - forwards every export to a renamed copy of the real DLL,
// logging the first five integer arguments and xmm0..xmm3 of every call.
//
// The per-export trampolines live in ycc_proxy.S and are signature-agnostic
// (pure tail jumps), so we do not need to know any prototype.
//
// Build:
//   gcc -c ycc_proxy.c -o ycc_proxy.o
//   gcc -c ycc_proxy.S -o ycc_stubs.o
//   gcc -shared -o YccDrvv3.dll ycc_proxy.o ycc_stubs.o ycc_proxy.def

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
    snprintf(g_logpath, sizeof(g_logpath), "%s\\\\ycc-proxy.log", dir);
}

/* one pointer per export, filled by DllMain, used as the tail-jump target */
#define DECL(n) void *p_##n = 0;
DECL(access_io_port)
DECL(CheckNewSMI_State)
DECL(fnYccDrv)
DECL(gb_inp)
DECL(gb_inpd)
DECL(gb_inpw)
DECL(gb_outp)
DECL(gb_outpd)
DECL(gb_outpw)
DECL(MapMem)
DECL(MapMem_Phys_To_Linear)
DECL(MapMem_Phys_To_Linear2)
DECL(MapMemEx)
DECL(MS_ReadMSR)
DECL(MS_WriteMSR)
DECL(nYccDrv)
DECL(ReadMSR)
DECL(ReadMSR64)
DECL(SMICmd)
DECL(SMICmd64)
DECL(UnMapMem)
DECL(UnMapMemEx)
DECL(WriteMSR)
DECL(WriteMSR64)
DECL(YCC_Alloc_Kernel_PhysMem)
DECL(YCC_Free_Kernel_PhysMem)
DECL(YCC_MapMem_Copy_Userbuf_To_Phys)
DECL(YCC_TranslateLinsToPhys)

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

/* called from the assembly trampolines */
void log_call(const char *name, unsigned long long a, unsigned long long b,
              unsigned long long c, unsigned long long d, unsigned long long e)
{
    if (!g_log) return;
    if (strcmp(name, "gb_inp") == 0 || strcmp(name, "gb_inpw") == 0 ||
        strcmp(name, "gb_inpd") == 0)
    {
        fprintf(g_log, "%-28s port=0x%llX\n", name, a);
    }
    else
    {
        fprintf(g_log, "%-28s a=0x%llX b=0x%llX c=0x%llX d=0x%llX e=0x%llX\n",
                name, a, b, c, d, e);
    }
    fflush(g_log);
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
    L("=== YccDrvv3 proxy attached pid=%lu ===", (unsigned long)GetCurrentProcessId());

    if (!GetModuleFileNameA(hinst, self, MAX_PATH)) return TRUE;
    strcpy(real, self);
    slash = strrchr(real, '\\');
    if (slash) *(slash + 1) = 0;
    strcat(real, "YccDrvv3.orig.dll");
    L("real dll : %s", real);

    g_real = LoadLibraryA(real);
    if (!g_real) { L("FATAL: LoadLibrary failed err=%lu", (unsigned long)GetLastError()); return TRUE; }
    L("real dll loaded ok");

#define BIND(n) p_##n = (void *)GetProcAddress(g_real, #n); if (!p_##n) L("  missing export %s", #n);
    BIND(access_io_port) BIND(CheckNewSMI_State) BIND(fnYccDrv) BIND(gb_inp) BIND(gb_inpd)
    BIND(gb_inpw) BIND(gb_outp) BIND(gb_outpd) BIND(gb_outpw) BIND(MapMem)
    BIND(MapMem_Phys_To_Linear) BIND(MapMem_Phys_To_Linear2) BIND(MapMemEx)
    BIND(MS_ReadMSR) BIND(MS_WriteMSR) BIND(nYccDrv) BIND(ReadMSR) BIND(ReadMSR64)
    BIND(SMICmd) BIND(SMICmd64) BIND(UnMapMem) BIND(UnMapMemEx) BIND(WriteMSR)
    BIND(WriteMSR64) BIND(YCC_Alloc_Kernel_PhysMem) BIND(YCC_Free_Kernel_PhysMem)
    BIND(YCC_MapMem_Copy_Userbuf_To_Phys) BIND(YCC_TranslateLinsToPhys)
    L("all pointers bound");
    return TRUE;
}

