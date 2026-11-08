import QtQuick
import Quickshell
import Quickshell.Hyprland

// Open windows on this bar's monitor, with the same app's windows side by side.
// Click to focus, middle-click to close, hover for the window title.
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  readonly property int iconSize: 18

  readonly property var monitor: {
    var window = root.QsWindow.window
    return window && window.screen ? Hyprland.monitorFor(window.screen) : null
  }

  readonly property var windows: {
    var name = root.monitor ? root.monitor.name : ""
    return Hyprland.toplevels.values.filter(function(toplevel) {
      var wayland = toplevel.wayland
      var workspace = toplevel.workspace
      return wayland && wayland.appId && !wayland.parent
        && workspace && workspace.monitor && workspace.monitor.name === name
    }).sort(function(left, right) {
      return left.wayland.appId.localeCompare(right.wayland.appId)
        || String(left.address).localeCompare(String(right.address))
    })
  }

  function iconFor(appId) {
    var entry = DesktopEntries.heuristicLookup(appId)
    var icon = entry && entry.icon ? entry.icon : appId
    return Quickshell.iconPath(icon, true) || Quickshell.iconPath("application-x-executable", true)
  }

  function focusWindow(toplevel) {
    var address = String(toplevel.address)
    if (!/^(0x)?[0-9a-fA-F]+$/.test(address)) return
    if (address.indexOf("0x") !== 0) address = "0x" + address
    var target = "window = \"address:" + address + "\""
    root.bar.run("hyprctl dispatch 'hl.dsp.focus({ " + target + " })'"
      + " && hyprctl dispatch 'hl.dsp.window.alter_zorder({ mode = \"top\", " + target + " })'")
  }

  implicitWidth: row.implicitWidth + (root.windows.length > 0 ? 8 : 0)
  implicitHeight: bar ? bar.barSize : 26

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 4

    Repeater {
      model: root.windows

      Item {
        id: slot
        required property var modelData
        readonly property var wayland: modelData.wayland

        width: root.iconSize + 2
        height: root.implicitHeight

        Image {
          anchors.centerIn: parent
          width: root.iconSize
          height: root.iconSize
          sourceSize: Qt.size(root.iconSize * 2, root.iconSize * 2)
          source: slot.wayland ? root.iconFor(slot.wayland.appId) : ""
          fillMode: Image.PreserveAspectFit
          asynchronous: true
        }

        // Marks the focused window.
        Rectangle {
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          width: root.iconSize
          height: 2
          visible: slot.wayland ? slot.wayland.activated : false
          color: root.bar ? root.bar.foreground : "white"
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton
          cursorShape: Qt.PointingHandCursor
          onEntered: if (root.bar && slot.wayland) root.bar.showTooltip(slot, slot.wayland.title)
          onExited: if (root.bar) root.bar.hideTooltip(slot)
          onClicked: function(mouse) {
            if (mouse.button === Qt.MiddleButton) {
              if (root.bar) root.bar.hideTooltip(slot)
              if (slot.wayland) slot.wayland.close()
            } else if (root.bar) {
              root.focusWindow(slot.modelData)
            }
          }
        }
      }
    }
  }
}
