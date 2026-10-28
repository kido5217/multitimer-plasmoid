import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    // Plasma 6: preferredRepresentation is a direct PlasmoidItem property and
    // takes the representation item itself (a Component), not a KF5 enum value.
    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        Layout.preferredWidth: 240
        Layout.preferredHeight: 160

        PlasmaComponents.Label {
            anchors.centerIn: parent
            text: plasmoid.title
        }
    }
}
