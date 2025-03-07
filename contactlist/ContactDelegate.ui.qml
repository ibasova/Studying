// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCharts

ItemDelegate {
    id: delegate
    checkable: true

    required property string fullName
    required property string address
    required property string city
    required property string number
    required property string company
    required property var position

    contentItem: ColumnLayout {
        spacing: 10

        Label {
            text: delegate.fullName
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        GridLayout {
            id: grid
            visible: false

            columns: 2
            rowSpacing: 10
            columnSpacing: 10

            Label {
                text: qsTr("Address:")
                Layout.leftMargin: 60
            }

            Label {
                text: delegate.address
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("City:")
                Layout.leftMargin: 60
            }

            Label {
                text: delegate.city
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Number:")
                Layout.leftMargin: 60
            }

            Label {
                text: delegate.number
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Company:")
                Layout.leftMargin: 60
            }

            Label {
                text: (delegate.company.length == 0) ? "doesn't set" : delegate.company
                font.bold: (delegate.company.length == 0) ? false : true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Position:")
                Layout.leftMargin: 60
            }

            Label {
                text: delegate.position.x + ":" + delegate.position.y
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    states: [
        State {
            name: "expanded"
            when: delegate.checked

            PropertyChanges {
                // TODO: When Qt Design Studio supports generalized grouped properties, change to:
                //       grid.visible: true
                // qmllint disable Quick.property-changes-parsed
                target: grid
                visible: true
            }
        }
    ]
}
