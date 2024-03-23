/*
 * Copyright (c) 2024. Vili and contributors.
 * This source code is subject to the terms of the GNU General Public
 * License, version 3. If a copy of the GPL was not distributed with this
 * file, You can obtain one at: https://www.gnu.org/licenses/gpl-3.0.txt
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: widget
    property string price: "Fetching..."
    property string nextPrice: ""
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: widget.implicitWidth
        Layout.minimumHeight: widget.implicitHeight
        Layout.preferredWidth: 250 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 90 * PlasmaCore.Units.devicePixelRatio

        Column {
            spacing: 5

            Text {
                text: widget.price
                font.pixelSize: 12
                color: "white"
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: widget.nextPrice
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
                text: "<a href='https://vili.dev'>Made by Vili</a> | <a href='https://api.spot-hinta.fi'>Powered by spot-hinta.fi</a>"
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
                    // console.log(response)
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
    function fetchElectricityPriceNext() {
        let date = new Date();
        var minutesLeft = 60 - date.getMinutes();
        var apiUrl = "https://api.spot-hinta.fi/JustNow?lookForwardHours=1";
        var request = new XMLHttpRequest();

        request.open("GET", apiUrl, true);
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    var response = JSON.parse(request.responseText);
                    console.error(response)
                    var price = (response.PriceWithTax * 100).toFixed(2);
                    var formattedResponse = `Price in ${minutesLeft} minutes: ${price} snt/kWh \n`;
                    widget.nextPrice = formattedResponse;
                } else {
                    console.error("Error fetching electricity price:", request.status, request.statusText);
                    widget.nextPrice = "Something went wrong while fetching prices..!";
                }
            }
        };
        request.send();
    }

    // Call both functions.
    function call() {
        fetchElectricityPriceNow();
        fetchElectricityPriceNext();
    }
}
