/*
 * Copyright (c) 2024. Vili and contributors.
 * This source code is subject to the terms of the GNU General Public
 * License, version 3. If a copy of the GPL was not distributed with this
 * file, You can obtain one at: https://www.gnu.org/licenses/gpl-3.0.txt
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {  
    id: widget

    property string price: "Fetching..."
    property string nextPrice1: ""
    property string nextPrice2: ""
    property string nextPrice3: ""
    

    Layout.minimumWidth: Kirigami.Units.gridUnit * 5
    Layout.minimumHeight: Kirigami.Units.gridUnit * 5

    implicitHeight: Kirigami.Units.gridUnit * 8
    implicitWidth: Kirigami.Units.gridUnit * 10


    PlasmaComponents.Label {
        anchors.fill: parent
        wrapMode: Text.Wrap

        Column {
            spacing: 5
            
            Text {
                text: widget.price
                font.pixelSize: 12
                color: "white"
                horizontalAlignment: Text.AlignLeft
            }
            Text {
                text: widget.nextPrice1
                font.pixelSize: 10
                color: "grey"
                horizontalAlignment: Text.AlignLeft
            }
            Text {
                text: widget.nextPrice2
                font.pixelSize: 10
                color: "grey"
                horizontalAlignment: Text.AlignLeft
            }
            Text {
                text: widget.nextPrice3
                font.pixelSize: 10
                color: "grey"
                horizontalAlignment: Text.AlignLeft
            }
            Text {
                text: "<a href='https://api.spot-hinta.fi/html/150/6'>See more prices...</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                font.pixelSize: 9
                color: "grey"
                linkColor: theme.textColor
                elide: Text.ElideLeft
                horizontalAlignment: Text.AlignRight
            }
            Text {
                text: "<a href='https://vili.dev'>Made by Vili</a> | <a href='https://spot-hinta.fi'>Powered by spot-hinta.fi</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                font.pixelSize: 8
                color: "grey"
                linkColor: theme.textColor
                elide: Text.ElideLeft
                horizontalAlignment: Text.AlignRight
            }
        }
    }


    // Update once the widget is opened.
    Component.onCompleted: {
        call();
    }

    // Keep updating...
    Timer {
        interval: 900000
        repeat: true
        running: true
        onTriggered: call();
    }

    // Gets the current hours price.
    function fetchElectricityPriceNow() {
        var apiUrl = "https://api.spot-hinta.fi/JustNow";
        var request = new XMLHttpRequest();
        request.open("GET", apiUrl, true);
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    var response = JSON.parse(request.responseText);
                    var price = (response.PriceWithTax * 100).toFixed(2);
                    var formattedResponse = `Currently: ${price} snt/kWh`;
                    widget.price = formattedResponse;
                } else {
                    console.error("Error fetching electricity price:", request.status, request.statusText);
                    widget.price = "Something went wrong while fetching prices..!";
                }
            }
        };
        request.send();
    }

    // Get the price of the next hour.
    function fetchElectricityPriceNext(hours) {
        let date = new Date();
        date.setHours(date.getHours() + hours);
        var formattedTime = formatDate(date);
        var apiUrl = "https://api.spot-hinta.fi/JustNow?lookForwardHours=" + hours;
        var request = new XMLHttpRequest();

        request.open("GET", apiUrl, true);
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    var response = JSON.parse(request.responseText);
                    var price = (response.PriceWithTax * 100).toFixed(2);
                    var formattedResponse = `Price at ${formattedTime}: ${price} snt/kWh`;
                    switch(hours) {
                        case 1:
                            widget.nextPrice1 = formattedResponse;
                            break;
                        case 2:
                            widget.nextPrice2 = formattedResponse;
                            break;
                        case 3:
                            widget.nextPrice3 = formattedResponse;
                            break;
                    }
                } else {
                    console.error("Error fetching electricity price:", request.status, request.statusText);
                    switch(hours) {
                        case 1:
                            widget.nextPrice1 = "Error fetching price..!";
                            break;
                        case 2:
                            widget.nextPrice2 = "Error fetching price..!";
                            break;
                        case 3:
                            widget.nextPrice3 = "Error fetching price..!";
                            break;
                    }
                }
            }
        };
        request.send();
    }

    // Call both functions.
    function call() {
        fetchElectricityPriceNow();
        for (let i = 1; i <= 3; i++) {
            fetchElectricityPriceNext(i);
        }
    }

    // Format date to display in a readable format
    function formatDate(date) {
        var hours = date.getHours();
        // var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        // minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ' ' + ampm;
        return strTime;
    }
}