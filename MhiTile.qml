import QtQuick 2.1
import qb.components 1.0
Tile {
 onClicked: app.openUnit("")
 Rectangle{anchors.fill:parent;anchors.margins:6;radius:16;color:screenStateController.dimmedColors?"#17252d":"#eef7fa"
 Column{anchors.centerIn:parent;spacing:9
 Text{anchors.horizontalCenter:parent.horizontalCenter;text:"MHI AIRCO";font.pixelSize:20;color:"#147d99"}
 Text{anchors.horizontalCenter:parent.horizontalCenter;text:app.snapshot.units.length?app.val(app.snapshot.units[0].indoor," °C"):"Verbinden";font.pixelSize:23;color:screenStateController.dimmedColors?"white":"#223d4a"}
 Text{anchors.horizontalCenter:parent.horizontalCenter;text:app.snapshot.units.length?(app.snapshot.units[0].online?(app.snapshot.units[0].power?"Aan · "+app.snapshot.units[0].mode:"Uit"):"Offline"):"WF-RAC";font.pixelSize:15;color:"#708590"}
 }}
}
