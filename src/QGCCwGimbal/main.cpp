#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "qgccwgimballib.h"

// Qml Singleton factories
static QObject* QGCCwGimbalSingletonFactory(QQmlEngine*, QJSEngine*)
{
    QGCCwGimbalController* qgcCwGimbalController = new QGCCwGimbalController(nullptr);
    return qgcCwGimbalController;
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // Register Qml Singletons
    qmlRegisterSingletonType<QGCCwGimbalController> ("QGCCwQml.QGCCwGimbalController",    1, 0, "QGCCwGimbalController",  QGCCwGimbalSingletonFactory);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
