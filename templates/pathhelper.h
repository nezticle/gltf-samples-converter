#ifndef PATHHELPER_H
#define PATHHELPER_H

#include <QObject>
#include <QQmlEngine>

class PathHelper : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit PathHelper(QObject *parent = nullptr);

    Q_INVOKABLE QUrl modelLocation(const QString &model);

};

#endif // PATHHELPER_H
