/*
 * GHidApi.dll logging proxy.
 *
 * Exports exactly the five entry points that GHidApi.dll provides, logs every call
 * with its arguments (and hex-dumps the 64-byte HID feature reports), then forwards
 * the call to a renamed copy of the real DLL.
 *
 * Build (x64):
 *   gcc -shared -O2 -o GHidApi.dll ghid_proxy.c ghid_proxy.def
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

typedef struct
{
    unsigned short FeatureLength;
    unsigned short InputReportLength;
    unsigned short OutputReportLength;
} HIDLEN;

typedef struct
{
    int devNum;
    int device;
} CONNDEV;

typedef int (__cdecl *fn_connect)(unsigned short, unsigned short, unsigned short, unsigned short, HIDLEN *);
typedef int (__cdecl *fn_disconnect)(unsigned short, unsigned short, unsigned char);
typedef int (__cdecl *fn_list)(unsigned short, unsigned short, CONNDEV *);
typedef int (__cdecl *fn_write)(unsigned short, unsigned short, unsigned char, unsigned char *, unsigned char);
typedef int (__cdecl *fn_read)(unsigned short, unsigned short, unsigned char, unsigned char *, unsigned char);

static HMODULE       g_real  = NULL;
static FILE         *g_log   = NULL;
static fn_connect    p_connect;
static fn_disconnect p_disconnect;
static fn_list       p_list;
static fn_write      p_write;
static fn_read       p_read;

static char g_logpath[MAX_PATH];
static void InitLogPath(void)
{
    const char *la = getenv("LOCALAPPDATA");
    char dir[MAX_PATH];
    if (!la) la = ".";
    snprintf(dir, sizeof(dir), "%s\\\\GccLiteRE", la);
    CreateDirectoryA(dir, NULL);
    snprintf(g_logpath, sizeof(g_logpath), "%s\\\\ghid-proxy.log", dir);
}

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

static void HexDump(const unsigned char *p, int n)
{
    int i;
    char line[256];
    char *w = line;
    if (!g_log || !p) return;
    for (i = 0; i < n; i++)
    {
        w += sprintf(w, "%02X ", p[i]);
        if ((i % 16) == 15 || i == n - 1)
        {
            *w = 0;
            fprintf(g_log, "        %s\n", line);
            fflush(g_log);
            w = line;
        }
    }
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
    L("=== GHidApi proxy attached  pid=%lu  %s", (unsigned long)GetCurrentProcessId(), "===");

    if (GetModuleFileNameA(hinst, self, MAX_PATH))
    {
        strcpy(real, self);
        slash = strrchr(real, '\\');
        if (slash) *(slash + 1) = 0;
        strcat(real, "GHidApi.orig.dll");
        L("real dll  : %s", real);
        g_real = LoadLibraryA(real);
        if (!g_real)
        {
            L("FATAL: could not load the real DLL, GetLastError=%lu", (unsigned long)GetLastError());
            return TRUE;
        }
        p_connect    = (fn_connect)   GetProcAddress(g_real, "dllexp_ConnectDevice");
        p_disconnect = (fn_disconnect)GetProcAddress(g_real, "dllexp_DisconnectDevice");
        p_list       = (fn_list)      GetProcAddress(g_real, "dllexp_GetConnectedList");
        p_write      = (fn_write)     GetProcAddress(g_real, "dllexp_WriteDataToDevice");
        p_read       = (fn_read)      GetProcAddress(g_real, "dllexp_ReadDataFromDevice");
        L("real dll loaded ok");
    }
    return TRUE;
}

__declspec(dllexport) int __cdecl dllexp_ConnectDevice(unsigned short vid, unsigned short pid,
                                                       unsigned short up, unsigned short usage,
                                                       HIDLEN *len)
{
    int r;
    L("ConnectDevice(vid=%04X pid=%04X usagePage=%04X usage=%04X len=%p)", vid, pid, up, usage, (void *)len);
    if (!p_connect) return -1;
    r = p_connect(vid, pid, up, usage, len);
    L("  -> %d", r);
    if (len)
    {
        int i;
        for (i = 0; i < 8; i++)
        {
            if (len[i].FeatureLength || len[i].InputReportLength || len[i].OutputReportLength)
                L("     len[%d] feature=%u input=%u output=%u", i,
                  len[i].FeatureLength, len[i].InputReportLength, len[i].OutputReportLength);
        }
    }
    return r;
}

__declspec(dllexport) int __cdecl dllexp_DisconnectDevice(unsigned short vid, unsigned short pid,
                                                          unsigned char devNum)
{
    int r;
    L("DisconnectDevice(vid=%04X pid=%04X devNum=%u)", vid, pid, devNum);
    if (!p_disconnect) return -1;
    r = p_disconnect(vid, pid, devNum);
    L("  -> %d", r);
    return r;
}

__declspec(dllexport) int __cdecl dllexp_GetConnectedList(unsigned short vid, unsigned short pid,
                                                          CONNDEV *list)
{
    int r, i;
    L("GetConnectedList(vid=%04X pid=%04X list=%p)", vid, pid, (void *)list);
    if (!p_list) return -1;
    r = p_list(vid, pid, list);
    L("  -> %d", r);
    if (list)
    {
        for (i = 0; i < 8; i++)
            if (list[i].devNum || list[i].device)
                L("     dev[%d] devNum=%d device=%d", i, list[i].devNum, list[i].device);
    }
    return r;
}

__declspec(dllexport) int __cdecl dllexp_WriteDataToDevice(unsigned short vid, unsigned short pid,
                                                           unsigned char devNum, unsigned char *data,
                                                           unsigned char size)
{
    int r;
    L("WriteDataToDevice(vid=%04X pid=%04X devNum=%u size=%u)", vid, pid, devNum, size);
    if (data)
    {
        L("  data[0..15]: %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X",
          data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
          data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
        if (size > 16) L("  rest nonzero:");
        HexDump(data + 16, size > 16 ? size - 16 : 0);
    }
    if (!p_write) return -1;
    r = p_write(vid, pid, devNum, data, size);
    L("  -> %d", r);
    return r;
}

__declspec(dllexport) int __cdecl dllexp_ReadDataFromDevice(unsigned short vid, unsigned short pid,
                                                            unsigned char devNum, unsigned char *data,
                                                            unsigned char size)
{
    int r;
    L("ReadDataFromDevice(vid=%04X pid=%04X devNum=%u size=%u)", vid, pid, devNum, size);
    if (data)
        L("  req[0..3]: %02X %02X %02X %02X", data[0], data[1], data[2], data[3]);
    if (!p_read) return -1;
    r = p_read(vid, pid, devNum, data, size);
    L("  -> %d", r);
    if (data && r >= 0) HexDump(data, size);
    return r;
}

