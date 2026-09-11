import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.muhamm-ad-ahmad.omarchy-cursor"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null

  property var installedThemes: []
  property var curatedThemes: [
    { package: "capitaine-cursors", name: "Capitaine Cursors", description: "Crisp macOS-inspired cursor pack with clean arrows", source: "extra" },
    { package: "bibata-cursor-theme", name: "Bibata Modern Classic", description: "Material-based rounded cursor with sharp black accents", source: "aur" },
    { package: "catppuccin-cursors", name: "Catppuccin Cursors", description: "Soothing pastel cursor themes (Mocha, Macchiato, Frappe, Latte)", source: "aur" },
    { package: "breeze-cursors", name: "Breeze Cursors", description: "Official KDE Plasma Breeze Dark and Breeze Light cursors", source: "extra" },
    { package: "breezex-cursor-theme", name: "BreezeX", description: "Modern reimagined Breeze cursors with smooth gradients", source: "aur" },
    { package: "nordzy-cursors", name: "Nordzy Cursors", description: "Dark aesthetic cursor theme built for the Nord color palette", source: "aur" },
    { package: "posy-cursor-tweaks", name: "Posy's Cursors", description: "Ergonomic, minimalist high-visibility cursors by Michiel de Boer", source: "aur" },
    { package: "volantes-cursors", name: "Volantes Cursors", description: "Sharp, geometric, modern cursor pack", source: "aur" },
    { package: "apple-cursor", name: "Apple Cursor", description: "Pixel-perfect macOS style cursor theme", source: "aur" },
    { package: "oreo-cursors-git", name: "Oreo Cursors", description: "Modern material design cursors with vibrant accent borders", source: "aur" },
    { package: "material-cursors", name: "Material Cursors", description: "Clean Material Design cursors with crisp outlines", source: "aur" },
    { package: "phinger-cursors", name: "Phinger Cursors", description: "Sophisticated, high-visibility cursor theme for Linux", source: "aur" }
  ]

  property string currentThemeId: "breeze_cursors"
  property string currentThemeName: "Breeze Dark"
  property int currentSize: 24
  property string activeTab: "installed" // "installed" or "curated"
  property string filterText: ""

  readonly property var filteredInstalledThemes: {
    var list = root.installedThemes || []
    if (!root.filterText) return list
    var q = root.filterText.toLowerCase().trim()
    return list.filter(function(t) {
      var n = (t.name || "").toLowerCase()
      var i = (t.id || "").toLowerCase()
      return n.indexOf(q) !== -1 || i.indexOf(q) !== -1
    })
  }

  function isInstalled(pkg) {
    if (!root.installedThemes) return false
    for (var i = 0; i < root.installedThemes.length; i++) {
      var id = (root.installedThemes[i].id || "").toLowerCase()
      if (pkg.indexOf("capitaine") !== -1 && id.indexOf("capitaine") !== -1) return true
      if (pkg.indexOf("breeze") !== -1 && id.indexOf("breeze") !== -1) return true
      if (pkg.indexOf("bibata") !== -1 && id.indexOf("bibata") !== -1) return true
      if (pkg.indexOf("catppuccin") !== -1 && id.indexOf("catppuccin") !== -1) return true
      if (pkg.indexOf("nordzy") !== -1 && id.indexOf("nordzy") !== -1) return true
      if (pkg.indexOf("posy") !== -1 && id.indexOf("posy") !== -1) return true
      if (pkg.indexOf("volantes") !== -1 && id.indexOf("volantes") !== -1) return true
      if (pkg.indexOf("apple") !== -1 && id.indexOf("apple") !== -1) return true
      if (pkg.indexOf("oreo") !== -1 && id.indexOf("oreo") !== -1) return true
    }
    return false
  }

  function open() {
    root.controller.show()
    root.refresh()
  }

  function close() {
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function refresh() {
    if (!listProc.running) listProc.running = true
    if (!curProc.running) curProc.running = true
  }

  function applyCursor(themeId, size) {
    var s = size || currentSize || 24
    currentThemeId = themeId
    currentSize = s
    if (hostWidget) {
      hostWidget.currentTheme = themeId
      hostWidget.currentSize = s
    }
    applyProc.command = ["omarchy-cursor", "set", themeId, String(s)]
    applyProc.running = true
  }

  function openTerminal(cmd) {
    if (root.bar && typeof root.bar.run === "function") {
      root.bar.run("omarchy-launch-floating-terminal-with-presentation \"" + cmd + "\"")
    }
    root.close()
  }

  Component.onCompleted: {
    root.refresh()
  }

  onOpenedChanged: {
    if (opened) root.refresh()
  }

  onActiveTabChanged: {
    root.refresh()
  }

  Process {
    id: listProc
    command: ["omarchy-cursor", "list", "--json"]
    running: false
    stdout: StdioCollector {
      id: listStdout
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (exitCode === 0 && listStdout.text) {
        try {
          var data = JSON.parse(listStdout.text)
          if (Array.isArray(data)) {
            root.installedThemes = data
          }
        } catch (e) {}
      }
    }
  }

  Process {
    id: curProc
    command: ["omarchy-cursor", "current", "--json"]
    running: false
    stdout: StdioCollector {
      id: curStdout
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (exitCode === 0 && curStdout.text) {
        try {
          var cur = JSON.parse(curStdout.text)
          if (cur && cur.id) {
            root.currentThemeId = cur.id
            root.currentThemeName = cur.name || cur.id
            root.currentSize = cur.size || 24
            if (root.hostWidget) {
              root.hostWidget.currentTheme = cur.id
              root.hostWidget.currentName = cur.name || cur.id
              root.hostWidget.currentSize = cur.size || 24
            }
          }
        } catch (e) {}
      }
    }
  }

  Process {
    id: applyProc
    running: false
    onExited: function(exitCode) {
      root.refresh()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(350))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Column {
        id: content
        width: parent.width
        spacing: Style.space(10)

        // Header
        RowLayout {
          width: parent.width
          spacing: Style.space(8)

          Text {
            Layout.fillWidth: true
            text: "Cursor Themes"
            color: root.barForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.subtitle
            font.bold: true
          }

          // Refresh button
          Text {
            text: "\uf021"
            color: root.barForeground
            opacity: 0.75
            font.pixelSize: Style.font.body
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.refresh()
            }
          }
        }

        // Active theme pill / status
        Rectangle {
          width: parent.width
          height: Style.space(36)
          radius: Style.space(6)
          color: Qt.rgba(1, 1, 1, 0.05)
          border.color: Qt.rgba(1, 1, 1, 0.1)
          border.width: 1

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(10)
            anchors.rightMargin: Style.space(10)

            Text {
              text: "Active:"
              color: root.barForeground
              opacity: 0.6
              font.pixelSize: Style.font.caption
            }

            Text {
              Layout.fillWidth: true
              text: root.currentThemeName
              elide: Text.ElideRight
              font.bold: true
              color: root.barForeground
              font.pixelSize: Style.font.caption
            }

            Text {
              text: root.currentSize + "px"
              color: Color.accent || "#7aa2f7"
              font.bold: true
              font.pixelSize: Style.font.caption
            }
          }
        }

        // Size selector row
        RowLayout {
          width: parent.width
          spacing: Style.space(6)

          Text {
            text: "Size:"
            color: root.barForeground
            opacity: 0.7
            font.pixelSize: Style.font.caption
          }

          Repeater {
            model: [24, 28, 32, 48]

            delegate: Rectangle {
              required property int modelData
              width: Style.space(42)
              height: Style.space(24)
              radius: Style.space(4)
              color: root.currentSize === modelData ? (Color.accent || "#7aa2f7") : Qt.rgba(1, 1, 1, 0.08)

              Text {
                anchors.centerIn: parent
                text: parent.modelData
                font.bold: root.currentSize === parent.modelData
                font.pixelSize: Style.font.caption
                color: root.currentSize === parent.modelData ? "#000000" : root.barForeground
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.applyCursor(root.currentThemeId, parent.modelData)
              }
            }
          }
        }

        // Tab switcher: Installed vs Discover
        RowLayout {
          width: parent.width
          spacing: Style.space(4)

          Rectangle {
            Layout.fillWidth: true
            height: Style.space(28)
            radius: Style.space(4)
            color: root.activeTab === "installed" ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

            Text {
              anchors.centerIn: parent
              text: "Installed (" + root.installedThemes.length + ")"
              font.bold: root.activeTab === "installed"
              font.pixelSize: Style.font.caption
              color: root.barForeground
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.activeTab = "installed"
                root.refresh()
              }
            }
          }

          Rectangle {
            Layout.fillWidth: true
            height: Style.space(28)
            radius: Style.space(4)
            color: root.activeTab === "curated" ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

            Text {
              anchors.centerIn: parent
              text: "Discover Online"
              font.bold: root.activeTab === "curated"
              font.pixelSize: Style.font.caption
              color: root.barForeground
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.activeTab = "curated"
                root.refresh()
              }
            }
          }
        }

        // Tab 1: Installed Themes
        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: root.activeTab === "installed"

          // Search Filter Field
          TextField {
            width: parent.width
            placeholderText: "Filter installed cursors..."
            text: root.filterText
            font.pixelSize: Style.font.caption
            onTextChanged: root.filterText = text
            verticalPadding: Style.space(4)
          }

          ScrollView {
            id: installedScroll
            width: parent.width
            height: Style.space(260)
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
              width: installedScroll.availableWidth
              spacing: Style.space(4)

              Text {
                visible: root.filteredInstalledThemes.length === 0
                text: root.filterText ? "No cursors match \"" + root.filterText + "\"" : "Loading installed cursors..."
                color: root.barForeground
                opacity: 0.6
                font.pixelSize: Style.font.caption
                topPadding: Style.space(10)
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
              }

              Repeater {
                model: root.filteredInstalledThemes

                delegate: Rectangle {
                  required property var modelData
                  required property int index
                  width: installedScroll.availableWidth
                  height: Style.space(32)
                  radius: Style.space(4)
                  readonly property bool isCur: modelData.id === root.currentThemeId
                  color: isCur ? Qt.rgba(1, 1, 1, 0.12) : (mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

                  RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(8)
                    anchors.rightMargin: Style.space(8)
                    spacing: Style.space(8)

                    Text {
                      text: "\uf245"
                      color: isCur ? (Color.accent || "#7aa2f7") : root.barForeground
                      opacity: isCur ? 1.0 : 0.5
                      font.pixelSize: Style.font.body
                    }

                    Text {
                      Layout.fillWidth: true
                      text: modelData.name || modelData.id
                      color: root.barForeground
                      font.bold: isCur
                      elide: Text.ElideRight
                      font.pixelSize: Style.font.body
                    }

                    Text {
                      visible: isCur
                      text: "✓"
                      color: Color.accent || "#7aa2f7"
                      font.bold: true
                      font.pixelSize: Style.font.body
                    }
                  }

                  MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyCursor(modelData.id, root.currentSize)
                  }
                }
              }
            }
          }
        }

        // Tab 2: Discover Online Themes
        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: root.activeTab === "curated"

          ScrollView {
            id: curatedScroll
            width: parent.width
            height: Style.space(260)
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
              width: curatedScroll.availableWidth
              spacing: Style.space(6)

              Repeater {
                model: root.curatedThemes

                delegate: Rectangle {
                  required property var modelData
                  width: curatedScroll.availableWidth
                  height: Style.space(44)
                  radius: Style.space(4)
                  color: Qt.rgba(1, 1, 1, 0.04)
                  readonly property bool alreadyInstalled: root.isInstalled(modelData.package)

                  RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(8)
                    anchors.rightMargin: Style.space(8)
                    spacing: Style.space(6)

                    ColumnLayout {
                      Layout.fillWidth: true
                      spacing: Style.space(2)

                      RowLayout {
                        Text {
                          text: modelData.name
                          color: root.barForeground
                          font.bold: true
                          font.pixelSize: Style.font.caption
                        }
                        Text {
                          text: "[" + modelData.source + "]"
                          color: Color.accent || "#7aa2f7"
                          font.pixelSize: Style.font.caption - 2
                        }
                      }

                      Text {
                        Layout.fillWidth: true
                        text: modelData.description
                        color: root.barForeground
                        opacity: 0.6
                        elide: Text.ElideRight
                        font.pixelSize: Style.font.caption - 1
                      }
                    }

                    Rectangle {
                      width: Style.space(62)
                      height: Style.space(24)
                      radius: Style.space(3)
                      color: alreadyInstalled ? Qt.rgba(1, 1, 1, 0.1) : (Color.accent || "#7aa2f7")

                      Text {
                        anchors.centerIn: parent
                        text: alreadyInstalled ? "Installed" : "Install"
                        color: alreadyInstalled ? root.barForeground : "#000000"
                        font.bold: true
                        font.pixelSize: Style.font.caption - 1
                      }

                      MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                          if (alreadyInstalled) {
                            root.activeTab = "installed"
                          } else {
                            root.openTerminal("omarchy-cursor install " + modelData.package)
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // Bottom Action Button
        Rectangle {
          width: parent.width
          height: Style.space(30)
          radius: Style.space(4)
          color: Qt.rgba(1, 1, 1, 0.08)

          RowLayout {
            anchors.centerIn: parent
            spacing: Style.space(6)

            Text {
              text: "\uf002"
              color: root.barForeground
              font.pixelSize: Style.font.caption
            }

            Text {
              text: "Search & Install Any Cursor from AUR (TUI)"
              color: root.barForeground
              font.bold: true
              font.pixelSize: Style.font.caption
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openTerminal("omarchy-cursor browse")
          }
        }
      }
    }
  }
}
