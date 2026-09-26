#include <QFontDatabase>
#include <QFile>
#include <QByteArray>
#include <QTextStream>
#include <QApplication>

int main(int argc, char **argv) {
    QApplication app(argc, argv);
    QTextStream out(stdout);
    const QString path = argc > 1 ? QString::fromUtf8(argv[1]) : QStringLiteral("MaterialSymbolsOutlined.ttf");
    const int id = QFontDatabase::addApplicationFont(path);
    if (id < 0) {
        out << "FAILED to load " << path << "\n";
        return 1;
    }
    const QStringList families = QFontDatabase::applicationFontFamilies(id);
    out << "family count: " << families.size() << "\n";
    for (const QString &f : families)
        out << "FAMILY: " << f << "\n";
    return 0;
}
