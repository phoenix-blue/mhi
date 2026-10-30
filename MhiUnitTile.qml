import QtQuick 2.1
import qb.components 1.0
Tile {
 id:tile
 property string unitId: ""
 property var unit: app.unitById(unitId)
 onClicked: app.openUnit(unitId)
 Rectangle { anchors.fill:parent;anchors.margins:6;radius:16;color:screenStateController.dimmedColors?"#17252d":"#eef7fa"
 Column { anchors.centerIn:parent;width:parent.width-24;spacing:5
 Text{width:parent.width;horizontalAlignment:Text.AlignHCenter;text:tile.unit.name||"Airco";elide:Text.ElideRight;font.pixelSize:20;font.bold:true;color:"#288da3"}
 Item{anchors.horizontalCenter:parent.horizontalCenter;width:140;height:55
 MhiAirflow{x:10;y:25;width:120;height:30;active:tile.visible&&tile.unit.online&&tile.unit.power;mode:tile.unit.mode||"";fan:tile.unit.fan||0}
 Rectangle{x:20;width:100;height:25;radius:6;color:"#d5e3e9";border.color:"#9eb5c1"
 Rectangle{x:10;y:17;width:80;height:2;color:"#8ba5b3"}
 Rectangle{x:83;y:6;width:5;height:5;radius:3;color:!tile.unit.online?"#ce8969":tile.unit.power?"#2ca883":"#8a9da7"}}}
 Text{width:parent.width;horizontalAlignment:Text.AlignHCenter;text:tile.unit.missing?"Open airco-overzicht":tile.unit.online?(tile.unit.power?"Aan · "+tile.unit.mode:"Uit"):"Offline";elide:Text.ElideRight;font.pixelSize:17;color:screenStateController.dimmedColors?"white":"#223d4a"}
 Text{width:parent.width;horizontalAlignment:Text.AlignHCenter;text:tile.unit.missing?"Kies of voeg een airco toe":tile.unit.online?app.val(tile.unit.indoor,"°")+" → "+app.val(tile.unit.target,"°"):"Geen live verbinding";font.pixelSize:17;color:"#708590"}
 }
 }
}
