/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the test suite of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <qbaselinetest.h>

#include <QtCore/QCoreApplication>
#include <QtCore/QDirIterator>
#include <QtCore/QDebug>
#include <QtCore/QProcess>
#include <QtGui/QImage>

#include <algorithm>

// qmlscenegrabber's default timeout, in ms
#define SCENE_TIMEOUT 6000

class tst_glTF2Tester : public QObject
{
    Q_OBJECT

public:
    tst_glTF2Tester();

private Q_SLOTS:
    void initTestCase();
    void cleanup();
    void testRendering_data();
    void testRendering();

private:
    void setupTestSuite(const QByteArray& filter = QByteArray());
    void runTest(const QStringList& extraArgs = QStringList());
    bool renderAndGrab(const QString& qmlFile, const QStringList& extraArgs, QImage *screenshot, QString *errMsg);
    quint16 checksumFileOrDir(const QString &path);

    QString testSuitePath;
    int grabberTimeout;
    int consecutiveErrors;   // Not test failures (image mismatches), but system failures (so no image at all)
    bool aborted;            // This run given up because of too many system failures
};


tst_glTF2Tester::tst_glTF2Tester()
    : consecutiveErrors(0), aborted(false)
{
    int sceneTimeout = qEnvironmentVariableIntValue("LANCELOT_SCENE_TIMEOUT");
    if (!sceneTimeout)
        sceneTimeout = SCENE_TIMEOUT;
    grabberTimeout = (sceneTimeout * 4) / 3; // Include some slack
}


void tst_glTF2Tester::initTestCase()
{
    QString dataDir = QFINDTESTDATA("../data/.");
    if (dataDir.isEmpty())
        dataDir = QStringLiteral("data");
    QFileInfo fi(dataDir);
    if (!fi.exists() || !fi.isDir() || !fi.isReadable())
        QSKIP("Test suite data directory missing or unreadable: " + fi.canonicalFilePath().toLatin1());
    testSuitePath = fi.canonicalFilePath();

#if defined(Q_OS_WIN)
    const char *defaultRhiBackend = "d3d11";
#elif defined(Q_OS_DARWIN)
    const char *defaultRhiBackend = "metal";
#else
    const char *defaultRhiBackend = "opengl";
#endif
    const QString rhiBackend = qEnvironmentVariable("QSG_RHI_BACKEND", QString::fromLatin1(defaultRhiBackend));
    const QString stack = QString::fromLatin1("RHI_%1").arg(rhiBackend);
    QBaselineTest::addClientProperty(QString::fromLatin1("GraphicsStack"), stack);

    QByteArray msg;
    if (!QBaselineTest::connectToBaselineServer(&msg))
        QSKIP(msg);
}


void tst_glTF2Tester::cleanup()
{
    // Allow subsystems time to settle
    if (!aborted)
        QTest::qWait(grabberTimeout / 100);
}


void tst_glTF2Tester::testRendering_data()
{
    setupTestSuite();
    consecutiveErrors = 0;
    aborted = false;
}


void tst_glTF2Tester::testRendering()
{
    runTest();
}


void tst_glTF2Tester::setupTestSuite(const QByteArray& filter)
{
    QTest::addColumn<QString>("qmlFile");
    int numItems = 0;

    QStringList ignoreItems;
    QFile ignoreFile(testSuitePath + "/Ignore");
    if (ignoreFile.open(QIODevice::ReadOnly)) {
        while (!ignoreFile.atEnd()) {
            QByteArray line = ignoreFile.readLine().trimmed();
            if (!line.isEmpty() && !line.startsWith('#'))
                ignoreItems += line;
        }
    }

    QStringList itemFiles;
    QDirIterator it(testSuitePath, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        QString fp = it.next();
        if (fp.endsWith(".qml")) {
            QString itemName = fp.mid(testSuitePath.length() + 1);
            if (!ignoreItems.contains(itemName) && (filter.isEmpty() || !itemName.startsWith(filter)))
                itemFiles.append(it.filePath());
        }
    }

    std::sort(itemFiles.begin(), itemFiles.end());
    for (const QString &filePath : std::as_const(itemFiles)) {
        QByteArray itemName = filePath.mid(testSuitePath.length() + 1).toLatin1();
        QString itemDir = QFileInfo(filePath).path();
        quint16 checkSum = checksumFileOrDir(itemDir);
        QBaselineTest::newRow(itemName, checkSum) << filePath;
        numItems++;
    }

    if (!numItems)
        QSKIP("No .qml test files found in " + testSuitePath.toLatin1());
}


void tst_glTF2Tester::runTest(const QStringList& extraArgs)
{
    // qDebug() << "Rendering" << QTest::currentDataTag();

    if (aborted)
        QSKIP("System too unstable.");

    QFETCH(QString, qmlFile);

    QImage screenShot;
    QString errorMessage;
    if (renderAndGrab(qmlFile, extraArgs, &screenShot, &errorMessage)) {
        consecutiveErrors = 0;
    }
    else {
        if (++consecutiveErrors >= 3 && QBaselineTest::shouldAbortIfUnstable())
            aborted = true;                   // Just give up if screen grabbing fails 3 times in a row
        QFAIL(qPrintable("QuickView grabbing failed: " + errorMessage));
    }

    QBASELINE_TEST(screenShot);
}


bool tst_glTF2Tester::renderAndGrab(const QString& qmlFile, const QStringList& extraArgs, QImage *screenshot, QString *errMsg)
{
    bool usePipe = true;  // Whether to transport the grabbed image using temp. file or pipe. TBD: cmdline option
#if defined(Q_OS_WIN)
    usePipe = false;
#endif
    QProcess grabber;
    grabber.setProcessChannelMode(QProcess::ForwardedErrorChannel);
    QString cmd = QCoreApplication::applicationDirPath() + "/qmlscenegrabber";
    QStringList args = extraArgs;
    QString tmpfile = usePipe ? QString("-") : QString("%1/qmlscenegrabber-%2-out.ppm")
                                .arg(QDir::tempPath()).arg(QCoreApplication::applicationPid());
    args << qmlFile << "-o" << tmpfile;
    grabber.start(cmd, args, QIODevice::ReadOnly);
    grabber.waitForFinished(grabberTimeout);
    if (grabber.state() != QProcess::NotRunning) {
        grabber.terminate();
        grabber.waitForFinished(grabberTimeout / 4);
    }
    QImage img;
    bool res = usePipe ? img.load(&grabber, "ppm") : img.load(tmpfile);
    if (!res || img.isNull()) {
        if (errMsg) {
            QString s("Failed to grab screen. qmlscenegrabber exitcode: %1. Process error: %2.");
            *errMsg = s.arg(grabber.exitCode()).arg(grabber.errorString());
        }
        if (!usePipe)
            QFile::remove(tmpfile);
        return false;
    }
    if (screenshot)
        *screenshot = img;
    if (!usePipe)
        QFile::remove(tmpfile);
    return true;
}


quint16 tst_glTF2Tester::checksumFileOrDir(const QString &path)
{
    QFileInfo fi(path);
    if (!fi.exists() || !fi.isReadable())
        return 0;
    if (fi.isFile()) {
        QFile f(path);
        bool isBinary = !path.endsWith(".qml");
        f.open(isBinary ? QIODevice::ReadOnly : QIODevice::ReadOnly | QIODevice::Text);
        QByteArray contents = f.readAll();
        return qChecksum(contents);
    }
    if (fi.isDir()) {
        quint16 cs = 0;
        const auto entryList = QDir(fi.filePath()).entryList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot,
                                                             QDir::Name);
        for (const QString &item : entryList)
            cs ^= checksumFileOrDir(path + QLatin1Char('/') + item);
        return cs;
    }
    return 0;
}


#define main _realmain
QTEST_MAIN(tst_glTF2Tester)
#undef main

int main(int argc, char *argv[])
{
    QBaselineTest::handleCmdLineArgs(&argc, &argv);
    return _realmain(argc, argv);
}

#include "tst_gltf2tester.moc"
