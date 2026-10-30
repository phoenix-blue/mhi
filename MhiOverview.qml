import QtQuick 2.1
Item {
 id:overview
 signal selected(int unitIndex)
 signal addRequested()
 width:parent.width;height:410
 function onlineCount(){var n=0;for(var i=0;i<app.snapshot.units.length;i++)if(app.snapshot.units[i].online)n++;return n}
 Text{x:8;y:4;text:"Jouw airco’s";font.family:"DejaVu Sans";font.pixelSize:27;font.bold:true;color:"#1e3b4c"}
 Text{x:10;y:40;text:"Kies een ruimte om de airco te bedienen";font.family:"DejaVu Sans";font.pixelSize:15;color:"#71838d"}
 Text{x:parent.width-344;y:14;text:overview.onlineCount()+" / "+app.snapshot.units.length+" online";font.family:"DejaVu Sans";font.pixelSize:16;color:"#638478"}
 MhiButton{x:parent.width-204;y:4;width:204;label:"+ Airco toevoegen";enabled:app.snapshot.units.length<12;onClicked:overview.addRequested()}
 ListView{
 id:list;x:0;y:78;width:parent.width-14;height:330;clip:true;spacing:12
 model:app.snapshot.units
 delegate:Rectangle{
 width:list.width;height:94;radius:17;color:rowTouch.pressed?"#e4edf1":!modelData.power?"white":modelData.mode==="Verwarmen"?"#fff3e8":modelData.mode==="Ventileren"?"#eff8eb":"#edf7fd";border.color:"#e4ecef"
 Rectangle{x:15;y:24;width:78;height:45;radius:7;color:"#f5f7f8";border.color:"#c9d3da"
 Rectangle{x:6;y:29;width:66;height:10;radius:3;color:"#d9e1e6"}
 Repeater{model:3;Rectangle{x:9;y:31+index*2;width:60;height:1;color:"#9aaebd"}}
 Rectangle{x:62;y:22;width:5;height:2;color:modelData.online?"#67ae77":"#a8b4bc"}
 }
 Text{x:98;y:17;width:parent.width-470;text:modelData.name;font.family:"DejaVu Sans";font.pixelSize:23;font.bold:true;color:"#233e4e";elide:Text.ElideRight}
 Text{x:98;y:53;width:parent.width-470;text:modelData.online?(modelData.power?modelData.mode:"Uit")+"  ·  "+app.val(modelData.indoor," °C binnen"):"Offline · WF-RAC niet bereikbaar";font.family:"DejaVu Sans";font.pixelSize:16;color:"#7b8b95";elide:Text.ElideRight}
 Text{x:parent.width-350;y:18;width:160;horizontalAlignment:Text.AlignHCenter;text:modelData.online?app.val(modelData.target,"°C"):"—";font.family:"DejaVu Sans";font.pixelSize:29;font.bold:true;color:"#264657"}
 Text{x:parent.width-350;y:57;width:160;horizontalAlignment:Text.AlignHCenter;text:"INGESTELD";font.family:"DejaVu Sans";font.pixelSize:10;font.letterSpacing:1;color:"#8a9aa2"}
 Rectangle{x:parent.width-171;y:31;width:91;height:31;radius:15;color:!modelData.online?"#edf0f2":modelData.power?"#e2f1ea":"#eef2f4"
 Text{anchors.centerIn:parent;text:!modelData.online?"Offline":modelData.power?"Aan":"Uit";font.family:"DejaVu Sans";font.pixelSize:14;color:modelData.online&&modelData.power?"#397e67":"#7a8a93"}}
 Text{x:parent.width-48;y:26;text:"›";font.family:"DejaVu Sans";font.pixelSize:35;color:"#7493a3"}
 MouseArea{id:rowTouch;anchors.fill:parent;onClicked:overview.selected(index)}
 }
 }
 Rectangle{x:parent.width-6;y:78;width:4;height:330;radius:2;color:"#e1e9ed";visible:list.contentHeight>list.height
 Rectangle{width:4;radius:2;color:"#88a7b7";height:parent.height*list.visibleArea.heightRatio;y:parent.height*list.visibleArea.yPosition}}
 Text{x:12;y:112;visible:app.snapshot.units.length===0;text:"Nog geen airco’s toegevoegd.\nVoeg je eerste WF-RAC toe met de knop rechtsboven.";font.family:"DejaVu Sans";font.pixelSize:20;lineHeight:1.5;color:"#71838d"}
}
