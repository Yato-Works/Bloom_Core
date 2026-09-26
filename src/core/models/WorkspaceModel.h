#pragma once

#include <QObject>
#include <QVariantList>
#include "../../platforms/include/IWorkspaceBackend.h"

/// QML Model exposing abstract desktop workspaces.
class WorkspaceModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(int currentWorkspace READ currentWorkspace NOTIFY currentWorkspaceChanged)
    Q_PROPERTY(int workspaceCount READ workspaceCount NOTIFY workspaceCountChanged)
    Q_PROPERTY(bool isSwitching READ isSwitching NOTIFY isSwitchingChanged)
    Q_PROPERTY(QVariantList list READ list NOTIFY listChanged)
public:
    explicit WorkspaceModel(IWorkspaceBackend *backend, QObject *parent = nullptr);

    [[nodiscard]] int currentWorkspace() const;
    [[nodiscard]] int workspaceCount() const;
    [[nodiscard]] bool isSwitching() const;
    [[nodiscard]] QVariantList list() const;

    Q_INVOKABLE void switchTo(int workspaceIndex);
    Q_INVOKABLE void switchNext();
    Q_INVOKABLE void switchPrevious();

signals:
    void currentWorkspaceChanged();
    void workspaceCountChanged();
    void isSwitchingChanged();
    void listChanged();

private:
    IWorkspaceBackend *m_backend;
};
