/*
 * Copyright (c) 2023. Vili and contributors.
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
    property string txt: "Fetching..."
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: label.implicitWidth
        Layout.minimumHeight: label.implicitHeight
        Layout.preferredWidth: 250 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 80 * PlasmaCore.Units.devicePixelRatio

        Column {
            spacing: 10

            Text {
                text: getCurrentDate()
                font.pixelSize: 20
                color: "white"
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: widget.txt
                font.pixelSize: 10
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: "Made by Vili (https://vili.dev)"
                font.pixelSize: 9
                color: "grey"
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    // Keep updating...
    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: fetchElectricityPriceNow()
    }

    // Gets the current date and time.
    function getCurrentDate() {
        var now = new Date();
        var year = now.getFullYear();
        var month = (now.getMonth() + 1).toString().padStart(2, '0');
        var day = now.getDate().toString().padStart(2, '0');
        var hours = now.getHours().toString().padStart(2, '0');
        var minutes = now.getMinutes().toString().padStart(2, '0');
        var formattedDate = year + '-' + month + '-' + day + ' ' + hours + ':' + minutes;
        return formattedDate;
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
                    var priceNoTax = response.PriceNoTax;
                    var priceWithTax = response.PriceWithTax;
                    // var rank = response.rank;
                    var formattedResponse = `⚡️ Current hour: ${priceNoTax} (${priceWithTax}) snt/kWh`;
                    widget.txt = formattedResponse;
                } else {
                    console.error("Error fetching electricity price:", request.status, request.statusText);
                    widget.txt = "❌ Error while fetching prices!";
                }
            }
        };
        request.send();
    }
}
