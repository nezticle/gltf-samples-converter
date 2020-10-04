#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuick3D/qquick3d.h>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QSurfaceFormat::setDefaultFormat(QQuick3D::idealSurfaceFormat(4));

    QQmlApplicationEngine engine;
#ifndef Q_OS_IOS
    const QUrl url(QStringLiteral("qrc:/GltfTestViewer.qml"));
    engine.rootContext()->setContextProperty("isMobile", false);
#else
    const QUrl url(QStringLiteral("GltfTestViewer.qml"));
    engine.rootContext()->setContextProperty("isMobile", true);
#endif
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
