import QtQuick 2.1
Rectangle {
 id:root
 property string label: ""
 property bool active: false
 signal clicked()
 width:130;height:44;radius:8;border.width:2;border.color:active?"#12647e":"#b4c7d1";color:tap.pressed?"#bcdbe8":!enabled?"#e1e5e8":active?"#147d99":"#eaf2f5"
 Text{anchors.centerIn:parent;text:root.label;font.family:"DejaVu Sans";font.pixelSize:16;font.bold:root.active;color:!root.enabled?"#99a4aa":root.active?"white":"#234250"}
 MouseArea{id:tap;anchors.fill:parent;enabled:root.enabled;onClicked:root.clicked()}
}
