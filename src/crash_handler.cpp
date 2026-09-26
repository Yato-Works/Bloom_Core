#include <windows.h>
#include <dbghelp.h>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QTextStream>

#pragma comment(lib, "dbghelp.lib")

static LONG WINAPI BloomCrashHandler(EXCEPTION_POINTERS *ep) {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/crash.dmp";
    QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation));

    HANDLE hFile = CreateFileW((LPCWSTR)path.utf16(), GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile != INVALID_HANDLE_VALUE) {
        MINIDUMP_EXCEPTION_INFORMATION mei;
        mei.ThreadId = GetCurrentThreadId();
        mei.ExceptionPointers = ep;
        mei.ClientPointers = FALSE;
        MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), hFile, MiniDumpNormal, &mei, NULL, NULL);
        CloseHandle(hFile);
    }
    return EXCEPTION_EXECUTE_HANDLER;
}

void installCrashHandler() {
    SetUnhandledExceptionFilter(BloomCrashHandler);
}
