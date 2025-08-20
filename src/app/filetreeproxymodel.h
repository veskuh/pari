#ifndef FILETREEPROXYMODEL_H
#define FILETREEPROXYMODEL_H

#include <QSortFilterProxyModel>

class FileTreeProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit FileTreeProxyModel(QObject *parent = nullptr);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

};

#endif // FILETREEPROXYMODEL_H
