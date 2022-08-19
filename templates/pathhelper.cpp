#include "pathhelper.h"
#include <QtCore/QCoreApplication>

PathHelper::PathHelper(QObject *parent)
    : QObject{parent}
{

}

QUrl PathHelper::modelLocation(const QString &model)
{
    // Git the location of the test data
    QString dataDirPath = QCoreApplication::applicationDirPath();
#ifdef Q_OS_MACOS
    dataDirPath += QStringLiteral("/../Resources/");
#else
    dataDirPath += QStringLiteral("/");
#endif
    return QUrl::fromLocalFile(dataDirPath + model);
}
