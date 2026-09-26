#pragma once

#include <QObject>

/// Abstract interface for desktop workspace / virtual desktop operations.
/// Implemented by Windows (VirtualDesktop COM/Win32) and Wayland (Hyprland/ExtWorkspace IPC).
class IWorkspaceBackend : public QObject {
    Q_OBJECT
public:
    explicit IWorkspaceBackend(QObject *parent = nullptr) : QObject(parent) {}
    ~IWorkspaceBackend() override;

    [[nodiscard]] virtual int currentWorkspace() const = 0;
    [[nodiscard]] virtual int workspaceCount() const = 0;
    [[nodiscard]] virtual bool isSwitching() const { return false; }

    virtual void switchTo(int workspaceIndex) = 0;
    virtual void switchNext() = 0;
    virtual void switchPrevious() = 0;

signals:
    void currentWorkspaceChanged(int index);
    void workspaceCountChanged(int count);
    void isSwitchingChanged(bool switching);
};
