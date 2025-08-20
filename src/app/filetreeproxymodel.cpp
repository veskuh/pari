#include "filetreeproxymodel.h"
#include <QFileSystemModel>

FileTreeProxyModel::FileTreeProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{

}

bool FileTreeProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QFileSystemModel* fsModel = qobject_cast<QFileSystemModel*>(sourceModel());
    if (!fsModel) {
        return false;
    }

    QModelIndex index = fsModel->index(source_row, 0, source_parent);
    if (!index.isValid()) {
        return false;
    }

    if (fsModel->isDir(index)) {
        for (int i = 0; i < fsModel->rowCount(index); ++i) {
            if (filterAcceptsRow(i, index)) {
                return true;
            }
        }
    }

    return fsModel->fileName(index).contains(filterRegularExpression());
}
