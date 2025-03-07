// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtCharts
import contactlist

ApplicationWindow {
    id: window

    x: windowsettings.value("x", 200)
    y: windowsettings.value("y", 200)
    width: windowsettings.value("width", 320)
    height: windowsettings.value("height", 480)
    visible: true
    title: qsTr("Contact List")

    function storeSettings() {
        windowsettings.setValue("x", window.x)
        windowsettings.setValue("y", window.y)
        windowsettings.setValue("width", window.width)
        windowsettings.setValue("height", window.height)
        windowsettings.setValue("page", swipeView.currentIndex)
    }

    onClosing: storeSettings()

    SwipeView {
        id: swipeView

        currentIndex: windowsettings.value("page", 0)
        anchors.fill: parent

        Item {
            id: contactPage
            property int currentContact: -1

            ContactDialog {
                id: contactDialog
                onFinished: function(fullName, address, city, number, company, positionX, positionY) {
                    var tempPosition = Qt.point(positionX, positionY)
                    if (contactPage.currentContact === -1) {
                        contactView.model.append(fullName, address, city, number, company, tempPosition)
                        series.append(positionX, positionY);
                    } else {
                        contactView.model.set(contactPage.currentContact, fullName, address, city, number, company, tempPosition)
                        series.remove(contactPage.currentContact);
                        series.insert(contactPage.currentContact, positionX, positionY);
                    }
                }
            }

            Menu {
                id: contactMenu
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
                modal: true

                Label {
                    padding: 10
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Qt.AlignHCenter
                    text: contactPage.currentContact >= 0 ? contactView.model.get(contactPage.currentContact).fullName : ""
                }
                MenuItem {
                    text: qsTr("Edit...")
                    onTriggered: contactDialog.editContact(contactView.model.get(contactPage.currentContact))
                }
                MenuItem {
                    text: qsTr("Remove")
                    onTriggered: confirmDeletionDialog.open()
                }
            }

            ContactView {
                id: contactView
                anchors.fill: parent
                onPressAndHold: function(index) {
                    contactPage.currentContact = index
                    contactMenu.open()
                }
            }

            RoundButton {
                text: qsTr("+")
                highlighted: true
                anchors.margins: 10
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked: {
                    contactPage.currentContact = -1
                    contactDialog.createContact()
                }
            }
        }
        Item {
            id: secondPage

            Label {
                anchors.centerIn: parent
                text: "Current window size is: " + window.height + "x" + window.width
                    + "\nCurrent window position is: " + window.x + ":" + window.y
            }
        }
        Item {
            id: thirdPage

            Component.onCompleted: loadSeries()

            ChartView {
                id: chartView
                title: "Positions"
                anchors.fill: parent
                antialiasing: true
                legend.visible: false

                ValueAxis {
                    id: axisX
                    min: 0
                    max: 10
                    tickCount: 5
                }

                ValueAxis {
                    id: axisY
                    min: -0.5
                    max: 1.5
                }

                ScatterSeries {
                    id: series
                    axisX: axisX
                    axisY: axisY
                }

                MouseArea {
                    id: chartMouseArea
                    anchors.fill: parent
                    propagateComposedEvents: true
                    acceptedButtons: Qt.LeftButton
                    onClicked:{
                        var mousePoint = mouse // mouse position
                        var chartPoint = chartView.mapToValue(mousePoint, series) // mouse position in chart coordinates
                        console.log("Chart: " + chartPoint)
                        canvas.xx = mousePoint.x
                        canvas.yy = mousePoint.y
                        canvas.xval = chartPoint.x
                        canvas.yval = chartPoint.y
                        canvas.requestPaint()
                    }
                    hoverEnabled: false
                }

                Canvas {
                    id: canvas
                    anchors.fill: parent

                    property double xx: 0.0
                    property double yy: 0.0
                    property double xval: 0.0
                    property double yval: 0.0

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, parent.width, parent.height)

                        if (
                                (xx > chartView.plotArea.x) && (yy > chartView.plotArea.y)
                                && (xx < (chartView.plotArea.x + chartView.plotArea.width)) && (yy < chartView.plotArea.y + chartView.plotArea.height)
                            ) {
                            ctx.strokeStyle = "#CCFF0000"
                            ctx.lineWidth = 2

                            // cross
                            ctx.beginPath()
                            ctx.moveTo(xx-5, yy-5)
                            ctx.lineTo(xx+5, yy+5)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(xx-5, yy+5)
                            ctx.lineTo(xx+5, yy-5)
                            ctx.stroke()

                            // X value on axis
                            ctx.beginPath()
                            ctx.moveTo(chartView.x + xx, chartView.plotArea.y + chartView.plotArea.height + 5)
                            ctx.lineTo(chartView.x + xx, chartView.plotArea.y + chartView.plotArea.height - 5)
                            ctx.stroke()

                            // X value label
                            ctx.beginPath()
                            ctx.fillStyle = "red";
                            ctx.textAlign = "center";
                            ctx.fillText(xval.toFixed(2), chartView.x + xx, chartView.plotArea.y + chartView.plotArea.height + 17);
                            ctx.restore();

                            // Y value on axis
                            ctx.beginPath()
                            ctx.moveTo(chartView.plotArea.x + 5, chartView.y + yy)
                            ctx.lineTo(chartView.plotArea.x - 5, chartView.y + yy)
                            ctx.stroke()

                            // Y value label
                            ctx.beginPath()
                            ctx.fillStyle = "red";
                            ctx.textAlign = "right";
                            ctx.fillText(yval.toFixed(2), chartView.plotArea.x - 7, chartView.y + yy + 4);
                            ctx.restore();
                        }
                    }
                }
            }

            RoundButton {
                text: qsTr("Img")
                highlighted: true
                anchors.margins: 10
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked: {
                    chartView.grabToImage(function(result) {
                        // TODO: Choose the folder and file name
                        result.saveToFile("something.png");
                    });
                }
            }
        }
        Item {
            id: fourthPage

            Rectangle {
                anchors.centerIn: parent
                width: parent.width / 2
                height: parent.height / 2
                color: "darkgreen"

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    duration: 10000
                    from: 0
                    to: 360
                }
            }
        }
    }

    PageIndicator {
        id: indicator

        count: swipeView.count
        currentIndex: swipeView.currentIndex

        anchors.bottom: swipeView.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    RoundButton {
        text: qsTr("S")
        highlighted: true
        anchors.margins: 10
        anchors.right: parent.right
        anchors.top: parent.top
        onClicked: {
            swipeView.currentIndex = 1
        }
    }

    ContactModel {
            id: contactModel

            onRowsRemoved: console.log("REMOVED")
            onDataChanged: console.log("CHANGED")
    }

    ConfirmDeletionDialog {
        id: confirmDeletionDialog
        onAccepted: function() {
            contactView.model.remove(contactPage.currentContact)
            series.remove(contactPage.currentContact)
        }
    }

    function loadSeries() {
        console.log("Model length: " + contactModel.rowCount());
        var xmax = -2147483648;
        var xmin = 2147483647;
        var ymax = -2147483648;
        var ymin = 2147483647;
        for (var i = 0; i < contactModel.rowCount(); i++) {
            var position = contactModel.get(i).position;
            series.append(position.x, position.y);

            if(position.x > xmax)
                xmax = position.x;
            if(position.x < xmin)
                xmin = position.x;
            if(position.y > ymax)
                ymax = position.y;
            if(position.y < ymin)
                ymin = position.y;

            axisX.max = xmax;
            axisX.min = xmin;
            axisY.max = ymax;
            axisY.min = ymin;
        }
    }
}
