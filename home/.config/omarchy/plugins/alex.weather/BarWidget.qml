import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "omarchy.weather"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  // Shape contract for shell.summon/hide/toggle routing (Bar.findPanelWidget
  // requires open/close/opened on the bar-widget root). Open maps to the
  // panel's hotkey path so summoning suppresses the center hover reveal,
  // matching what the old per-plugin IpcHandler did.
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.openFromHotkey) panelLoader.item.openFromHotkey()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  // Forwarded so this widget can stand in for the panel as the bar's popout
  // identity: Bar.requestPopout prefers closeForPopoutSwitch over close, and
  // KeyboardPanel reads popoutSwitchClosing back off its owner.
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  visible: panelLoader.item && panelLoader.item.label !== ""
  implicitWidth: button.implicitWidth + temperature.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  function handlePress(b) {
    if (!root.bar) return
    if (b === Qt.RightButton) root.bar.run("omarchy-notification-send \"$(omarchy-weather-status)\"")
    else if (b === Qt.MiddleButton) root.refresh()
    else root.togglePanel()
  }

  // Personal change: the icon takes a theme color for its kind of weather.
  // Each wttr.in code is drawn with the glyph Model.iconForCode picks, so the
  // glyph says which kind it is.
  readonly property var iconKinds: [
    { codes: [113], day: "yellow", night: "bright_magenta" },             // clear
    { codes: [116], day: "bright_yellow", night: "magenta" },              // partly cloudy
    { codes: [119], day: "light_foreground", night: "light_foreground" }, // cloudy
    { codes: [143], day: "dark_foreground", night: "dark_foreground" },   // fog
    { codes: [176], day: "bright_cyan", night: "bright_cyan" },           // showers
    { codes: [179], day: "bright_foreground", night: "bright_foreground" }, // light snow
    { codes: [182], day: "cyan", night: "cyan" },                         // sleet
    { codes: [200], day: "bright_yellow", night: "bright_yellow" },       // thunder
    { codes: [266], day: "blue", night: "blue" },                         // rain
    { codes: [329], day: "bright_foreground", night: "bright_foreground" } // snow
  ]
  property var themeColors: ({})

  function readTheme(text) {
    var next = {}
    var lines = String(text).split("\n")
    for (var i = 0; i < lines.length; i++) {
      var match = lines[i].match(/^\s*([a-z_]+)\s*=\s*"#([0-9a-fA-F]{6})"/)
      if (match) next[match[1]] = "#" + match[2]
    }
    root.themeColors = next
  }

  function iconColor(glyph) {
    if (glyph) {
      for (var i = 0; i < root.iconKinds.length; i++) {
        var kind = root.iconKinds[i]
        var name = ""
        if (Model.iconForCode(kind.codes[0], false) === glyph) name = kind.day
        else if (Model.iconForCode(kind.codes[0], true) === glyph) name = kind.night
        if (name && root.themeColors[name]) return root.themeColors[name]
      }
    }
    return root.bar ? root.bar.barForeground : Color.foreground
  }

  // Personal change: the temperature runs from cold to hot through the theme.
  readonly property var tempBands: [
    { below: 6, color: "blue" },     // up to 5°C
    { below: 15, color: "cyan" },    // 6-14°C
    { below: 25, color: "green" },   // 15-24°C
    { below: 32, color: "yellow" },  // 25-31°C
    { below: 1000, color: "red" }    // 32°C and up
  ]

  function tempColor(value, unit) {
    var degrees = parseFloat(value)
    var fallback = root.bar ? root.bar.barForeground : Color.foreground
    if (!isFinite(degrees)) return fallback
    if (String(unit).indexOf("F") !== -1) degrees = (degrees - 32) * 5 / 9
    for (var i = 0; i < root.tempBands.length; i++) {
      if (degrees < root.tempBands[i].below) return root.themeColors[root.tempBands[i].color] || fallback
    }
    return fallback
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readTheme(text())
  }

  BarIconButton {
    id: button
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    bar: root.bar
    text: panelLoader.item ? panelLoader.item.label : ""
    foreground: root.iconColor(text)
    slotSize: Style.bar.statusSlot
    // Tooltip suppressed because the panel is the detail view.
    tooltipText: ""

    onPressed: function(b) { root.handlePress(b) }
  }

  // Personal change: the current temperature, to the right of the icon.
  WidgetButton {
    id: temperature
    anchors.left: button.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    bar: root.bar
    horizontalMargin: 2
    text: panelLoader.item && panelLoader.item.reportTempNum !== ""
      ? panelLoader.item.reportTempNum + panelLoader.item.tempUnit : ""
    tooltipText: ""
    foreground: panelLoader.item ? root.tempColor(panelLoader.item.reportTempNum, panelLoader.item.tempUnit) : root.iconColor("")

    onPressed: function(b) { root.handlePress(b) }
  }
}
