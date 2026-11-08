import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Audio visualizer: click to play/pause, scroll to change the volume.
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  readonly property int barCount: 12
  readonly property int maxLevel: 18 // ascii_max_range in ../cava.conf
  property var levels: []

  implicitWidth: row.implicitWidth + 16
  implicitHeight: bar ? bar.barSize : 26

  function readLevels(line) {
    var fields = String(line).split(";")
    var next = []
    for (var i = 0; i < root.barCount; i++) {
      var level = parseInt(fields[i], 10)
      next.push(isFinite(level) ? Math.max(0, Math.min(root.maxLevel, level)) : 0)
    }
    root.levels = next
  }

  // The bars run through these theme colors, left to right.
  readonly property var gradientNames: ["bright_cyan", "blue", "bright_magenta"]
  property var gradient: []
  property color backdrop: "transparent"

  function readTheme(text) {
    var found = []
    for (var i = 0; i < root.gradientNames.length; i++) {
      var match = String(text).match(new RegExp("^" + root.gradientNames[i] + "\\s*=\\s*\"#([0-9a-fA-F]{6})\"", "m"))
      if (!match) {
        root.gradient = [] // A theme without them keeps the bar's own color.
        return
      }
      found.push({
        r: parseInt(match[1].slice(0, 2), 16) / 255,
        g: parseInt(match[1].slice(2, 4), 16) / 255,
        b: parseInt(match[1].slice(4, 6), 16) / 255
      })
    }
    root.gradient = found
  }

  function readBackdrop(text) {
    var match = String(text).match(/^lighter_background\s*=\s*"#([0-9a-fA-F]{6})"/m)
    root.backdrop = match ? "#" + match[1] : "transparent"
  }

  function barColor(index) {
    if (root.gradient.length < 2) return root.bar ? root.bar.foreground : "white"
    var position = index / (root.barCount - 1) * (root.gradient.length - 1)
    var from = Math.min(Math.floor(position), root.gradient.length - 2)
    var mix = position - from
    var a = root.gradient[from]
    var b = root.gradient[from + 1]
    return Qt.rgba(a.r + (b.r - a.r) * mix, a.g + (b.g - a.g) * mix, a.b + (b.b - a.b) * mix, 1)
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      root.readTheme(text())
      root.readBackdrop(text())
    }
  }

  function togglePlaying() {
    var players = Mpris.players ? Mpris.players.values : []
    var target = null
    for (var i = 0; i < players.length; i++) {
      if (!players[i].canTogglePlaying) continue
      if (players[i].isPlaying) {
        target = players[i]
        break
      }
      if (!target) target = players[i]
    }
    if (target) target.togglePlaying()
  }

  Process {
    id: cava
    command: ["cava", "-p", Quickshell.env("HOME") + "/.config/omarchy/bar/cava.conf"]
    running: true
    stdout: SplitParser { onRead: function(line) { root.readLevels(line) } }
    onExited: {
      root.levels = []
      restart.start()
    }
  }

  // Cava exits if the audio server restarts, so bring it back.
  Timer {
    id: restart
    interval: 5000
    onTriggered: cava.running = true
  }

  // A lighter panel behind the bars.
  Rectangle {
    anchors.centerIn: parent
    width: row.width + 10
    height: root.maxLevel + 8
    radius: 4
    color: root.backdrop
  }

  Row {
    id: row
    anchors.centerIn: parent
    height: root.maxLevel
    spacing: 1

    Repeater {
      model: root.barCount

      Rectangle {
        required property int index

        anchors.bottom: parent.bottom
        width: 4
        height: Math.max(1, root.levels[index] || 0)
        color: root.barColor(index)
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.togglePlaying()
    onWheel: function(wheel) {
      if (root.bar) root.bar.run(wheel.angleDelta.y > 0 ? "pamixer -i 5" : "pamixer -d 5")
    }
  }
}
