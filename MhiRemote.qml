import QtQuick 2.1
Item {
 id:remote
 width:parent.width;height:410
 property var unit:({online:false})
 property bool available:unit.online
 property bool coolingBlocked:!!unit.blockCoolingWhenCV&&app.snapshot.thermostat.online&&app.snapshot.thermostat.heating
 property real target:app.desired(unit,"target",unit.target||23)
 property int fanSetting:app.desired(unit,"fan",({7:0,0:1,1:2,2:3,6:4})[unit.fan]||0)
 property bool desiredPower:!!app.desired(unit,"power",unit.power?1:0)
 property int selectedMode:app.desired(unit,"mode",({Auto:0,Drogen:4,Koelen:8,Ventileren:12,Verwarmen:16})[unit.mode]||0)
 property string statusMode:({0:"Auto",4:"Drogen",8:"Koelen",12:"Ventileren",16:"Verwarmen"})[selectedMode]||unit.mode||"Actief"
 property color accent:selectedMode===16?"#ef953e":selectedMode===12?"#64ac51":selectedMode===4?"#39b7cb":selectedMode===8?"#329ee8":"#798797"
 signal backRequested()
 function vaneIndex(key){var pending=app.desired(unit,key,-1);if(pending>=0)return pending;var label=unit[key]||"";if(unit.driver==="esphome")return (unit.choices&&unit.choices[key]||[]).indexOf(label);if(label.indexOf("Swing")===0)return 0;var match=label.match(/Stand (\d+)/);return match?Number(match[1]):-1}
 function cycleVane(key,count){if(unit.driver==="esphome")count=(unit.choices&&unit.choices[key]||[]).length;if(count>0)app.control(key,(vaneIndex(key)+1)%count)}
 function vaneLabel(key){var v=vaneIndex(key);if(unit.driver==="esphome")return (unit.choices&&unit.choices[key]||[])[v]||"—";return v===0?"Swing":v>0?"Stand "+v:"Onbekend"}
 Rectangle{anchors.fill:parent;radius:18;color:"#ffffff";border.color:"#e2e8ed"}
 MhiButton{x:14;y:10;width:145;height:38;label:"‹  Alle airco’s";onClicked:remote.backRequested()}
 Text{x:175;y:19;width:390;text:"MHI Airco · "+(unit.name||"Airco");elide:Text.ElideRight;font.family:"DejaVu Sans";font.pixelSize:18;font.bold:true;color:"#243849"}
 Image{x:remote.width-235;y:12;width:140;height:102;source:"mhi-logo.png";fillMode:Image.PreserveAspectFit;smooth:true}
 Rectangle{x:parent.width-79;y:10;width:62;height:49;radius:12;color:remote.desiredPower?"#258fe3":"#e8eef3";opacity:remote.available?1:0.45
 Canvas{anchors.centerIn:parent;width:30;height:30;property bool powered:remote.desiredPower;onPoweredChanged:requestPaint();onPaint:{var c=getContext("2d");c.clearRect(0,0,30,30);c.strokeStyle=powered?"white":"#637786";c.lineWidth=3;c.lineCap="round";c.beginPath();c.arc(15,16,10,-Math.PI/3,Math.PI*4/3);c.stroke();c.beginPath();c.moveTo(15,2);c.lineTo(15,15);c.stroke()}}
 MouseArea{anchors.fill:parent;enabled:remote.available;onClicked:app.control("power",remote.desiredPower?0:1)}
 }
 Item{x:(parent.width-width)/2;y:48;width:264;height:210
 Canvas{id:ring;anchors.fill:parent;property color tint:remote.accent;property real value:remote.target;onTintChanged:requestPaint();onValueChanged:requestPaint();onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.lineWidth=18;c.lineCap="round";var start=Math.PI*0.75,end=Math.PI*2.25;c.strokeStyle="#e9f0f5";c.beginPath();c.arc(132,113,104,start,end);c.stroke();c.strokeStyle=String(tint);c.beginPath();c.arc(132,113,104,start,start+(end-start)*(0.25+0.75*(Math.max(18,Math.min(30,value))-18)/12));c.stroke()}}
 Text{y:69;width:parent.width;text:Number(remote.target).toFixed(1).replace(".",",")+"°";horizontalAlignment:Text.AlignHCenter;font.family:"DejaVu Sans";font.pixelSize:49;font.bold:true;color:"#243849"}
 Text{y:128;width:parent.width;text:"Ingesteld";horizontalAlignment:Text.AlignHCenter;font.family:"DejaVu Sans";font.pixelSize:13;color:"#637786"}
 Text{y:154;width:parent.width;text:app.val(unit.indoor," °C")+" binnen";horizontalAlignment:Text.AlignHCenter;font.family:"DejaVu Sans";font.pixelSize:17;color:"#40586a"}
 }
 Repeater{model:[-0.5,0.5]
 Rectangle{x:remote.width/2+(index===0?-247:169);y:107;width:78;height:78;radius:39;border.width:2;border.color:"#86bde6";color:temperatureTap.pressed?"#c2e2fa":"#e5f2fc";opacity:remote.available?1:0.45
 Text{anchors.centerIn:parent;text:index===0?"−":"+";font.family:"DejaVu Sans";font.pixelSize:43;color:"#268ed7"}
 MouseArea{id:temperatureTap;anchors.fill:parent;enabled:remote.available&&(index===0?remote.target>18:remote.target<30);onClicked:app.control("target",Math.max(18,Math.min(30,remote.target+modelData)))}
 }}
 Rectangle{x:20;y:202;width:245;height:34;radius:17;color:!unit.online?"#f7e9e8":remote.desiredPower?Qt.lighter(remote.accent,1.82):"#eef2f4";border.color:!unit.online?"#d98a86":remote.desiredPower?remote.accent:"#c7d1d7"
  Rectangle{x:12;y:10;width:14;height:14;radius:7;color:!unit.online?"#d4514c":remote.desiredPower?remote.accent:"#9aa8b0"}
  Text{x:35;width:198;height:34;verticalAlignment:Text.AlignVCenter;text:!unit.online?"Niet verbonden":remote.desiredPower?"In bedrijf · "+remote.statusMode:"Stand-by";font.family:"DejaVu Sans";font.pixelSize:14;font.bold:true;color:"#40586a";elide:Text.ElideRight}
 }
 Text{x:remote.width-310;y:213;width:287;horizontalAlignment:Text.AlignRight;text:"Buiten "+app.val(unit.outdoor," °C");font.family:"DejaVu Sans";font.pixelSize:14;color:"#637786"}
 Row{x:16;y:258;spacing:8
 Repeater{model:[{label:"Auto",value:0,icon:"auto",color:"#798797"},{label:"Koelen",value:8,icon:"snow",color:"#329ee8"},{label:"Verwarmen",value:16,icon:"sun",color:"#ef953e"},{label:"Drogen",value:4,icon:"drop",color:"#39b7cb"},{label:"Ventileren",value:12,icon:"fan",color:"#64ac51"}]
 Rectangle{width:(remote.width-64)/5;height:72;radius:10
 property bool chosen:remote.selectedMode===modelData.value
 property bool allowed:remote.available&&!(modelData.value===8&&remote.coolingBlocked)
 color:modeTap.pressed?Qt.darker(modelData.color,1.08):chosen?modelData.color:"#f8fafb";border.color:chosen?modelData.color:"#c4d1da";border.width:chosen?2:1;opacity:allowed?1:0.4
 MhiIcon{x:(parent.width-40)/2;y:5;width:40;height:40;kind:modelData.icon;tint:parent.chosen?"#ffffff":modelData.color}
 Text{y:47;width:parent.width;text:modelData.label;horizontalAlignment:Text.AlignHCenter;font.family:"DejaVu Sans";font.pixelSize:15;font.bold:parent.chosen;color:parent.chosen?"#ffffff":"#2c4355"}
 MouseArea{id:modeTap;anchors.fill:parent;enabled:parent.allowed;onClicked:app.control("mode",modelData.value)}
 }}}
 Row{x:16;y:340;spacing:10
 Repeater{model:[{title:"Ventilator",key:"fan",count:5},{title:"Lamellen ↕",key:"louverUD",count:5},{title:"Lamellen ↔",key:"louverLR",count:8}]
 Rectangle{width:(remote.width-52)/3;height:56;radius:10;color:adjustTouch.pressed?"#e3eff8":"#f4f7f9";border.color:"#b9c9d5";border.width:2;opacity:remote.available?1:0.4
 MhiIcon{x:12;y:10;width:36;height:36;kind:modelData.key==="fan"?"fan":modelData.key==="louverUD"?"vertical":"horizontal";tint:remote.accent;level:modelData.key==="fan"?remote.fanSetting:-1}
 Text{x:60;y:7;text:modelData.title;font.family:"DejaVu Sans";font.pixelSize:13;color:"#637786"}
 Text{x:60;y:27;text:modelData.key==="fan"?["Auto","Stil","Laag","Midden","Hoog"][remote.fanSetting]:remote.vaneLabel(modelData.key);font.family:"DejaVu Sans";font.pixelSize:17;font.bold:true;color:"#2c4355"}
 Text{x:parent.width-30;y:13;text:"›";font.family:"DejaVu Sans";font.pixelSize:28;color:remote.accent}
 MouseArea{id:adjustTouch;anchors.fill:parent;enabled:remote.available;onClicked:if(modelData.key==="fan")app.control("fan",(remote.fanSetting+1)%5);else remote.cycleVane(modelData.key,modelData.count)}
 }}}
}
