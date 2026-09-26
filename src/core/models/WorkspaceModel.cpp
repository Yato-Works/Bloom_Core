#include "WorkspaceModel.h"
#include <QVariantMap>

WorkspaceModel::WorkspaceModel(IWorkspaceBackend *backend, QObject *parent)
    : QObject(parent)
    , m_backend(backend)
{
    if (m_backend) {
        connect(m_backend, &IWorkspaceBackend::currentWorkspaceChanged, this, [this]() {
            emit currentWorkspaceChanged();
            emit listChanged();
        });
        connect(m_backend, &IWorkspaceBackend::workspaceCountChanged, this, [this]() {
            emit workspaceCountChanged();
            emit listChanged();
        });
        connect(m_backend, &IWorkspaceBackend::isSwitchingChanged, this, &WorkspaceModel::isSwitchingChanged);
    }
}

int WorkspaceModel::currentWorkspace() const
{
    return m_backend ? m_backend->currentWorkspace() : 1;
}

int WorkspaceModel::workspaceCount() const
{
    return m_backend ? m_backend->workspaceCount() : 5;
}

bool WorkspaceModel::isSwitching() const
{
    return m_backend ? m_backend->isSwitching() : false;
}

QVariantList WorkspaceModel::list() const
{
    QVariantList res;
    const int count = workspaceCount();
    const int current = currentWorkspace();
    for (int i = 1; i <= count; ++i) {
        QVariantMap item;
        item[QStringLiteral("id")] = i;
        item[QStringLiteral("name")] = QString::number(i);
        item[QStringLiteral("active")] = (i == current);
        res.append(item);
    }
    return res;
}

void WorkspaceModel::switchTo(int workspaceIndex)
{
    if (m_backend) {
        m_backend->switchTo(workspaceIndex);
    }
}

void WorkspaceModel::switchNext()
{
    if (m_backend) {
        m_backend->switchNext();
    }
}

void WorkspaceModel::switchPrevious()
{
    if (m_backend) {
        m_backend->switchPrevious();
    }
}
