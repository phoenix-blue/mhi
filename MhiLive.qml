import QtQuick 2.1

Item {
 id:live
 property var unit:({online:false})
 width:parent.width
 height:430

 function hasSensor(key){
  var s=unit.sensors||{}
  return unit.online&&s[key]!==undefined&&s[key]!==null&&(unit.sensorFresh||{})[key]===true
 }
 function sensor(key,suffix,decimals){
  if(!hasSensor(key))return "—"
  return Number(unit.sensors[key]).toFixed(decimals===undefined?1:decimals)+suffix
 }
 function direct(key,suffix){
  var value=unit[key]
  return unit.online&&value!==undefined&&value!==null?Number(value).toFixed(1)+suffix:"—"
 }
 function sensorColor(key){return hasSensor(key)?"#173b4b":"#9aaab1"}
 function directColor(key){return unit.online&&unit[key]!==undefined&&unit[key]!==null?"#173b4b":"#9aaab1"}
 function operation(){
  if(!unit.online)return "Geen verbinding"
  if(hasSensor("defrost")&&unit.sensors.defrost===1)return "Ontdooien"
  return unit.power?(unit.mode||"In bedrijf"):"Uit"
 }
 function normalCode(value){return value===""||value==="Geen"||value==="00"||value==="0"}
 function code(prefix){
  if(!unit.online)return "—"
  var value=String(unit.fault||"")
  if(normalCode(value))return "Geen"
  return value.indexOf(prefix)===0?value:"—"
 }
 function warning(){return !unit.online||!normalCode(String(unit.fault||""))}
 function accent(){
  if(hasSensor("defrost")&&unit.sensors.defrost===1)return "#7b83c6"
  if(unit.mode==="Verwarmen")return "#df7b35"
  if(unit.mode==="Koelen")return "#319cd1"
  if(unit.mode==="Drogen")return "#48a9ad"
  if(unit.mode==="Ventileren")return "#56a35d"
  return "#77909d"
 }

 Rectangle {
  x:0;y:0;width:parent.width;height:48;radius:10
  color:"#e7f0f4";border.color:"#d2e0e6"
  Rectangle{x:14;y:14;width:20;height:20;radius:10;color:unit.online?live.accent():"#a6b2b8"}
  Text{x:45;y:7;text:unit.name||"Airco";font.pixelSize:18;font.bold:true;color:"#173b4b"}
  Text{x:45;y:28;text:live.operation();font.pixelSize:13;color:unit.online?live.accent():"#8c9aa1"}
  Text{anchors.right:parent.right;anchors.rightMargin:16;y:15;text:unit.online?"LIVE  "+(unit.updated||""):"OFFLINE";font.pixelSize:14;font.bold:true;color:unit.online?"#43826f":"#a46758"}
 }

 Rectangle {
  x:0;y:60;width:(parent.width-14)/2;height:270;radius:14
  color:"white";border.color:"#d7e4e9"
  Text{x:18;y:13;text:"BINNENUNIT";font.pixelSize:13;font.bold:true;color:"#66808c"}
  Rectangle {
   x:184;y:36;width:270;height:105;radius:18;border.color:"#afc3cd"
   gradient:Gradient{GradientStop{position:0;color:"#fbfcfd"}GradientStop{position:1;color:"#d8e4e9"}}
   Text{x:18;y:14;text:"MHI";font.pixelSize:12;font.bold:true;color:"#69838f"}
   Rectangle{x:244;y:16;width:7;height:7;radius:4;color:unit.online?(unit.power?live.accent():"#94a6ae"):"#c9907f"}
   Repeater{model:6;Rectangle{x:20;y:64+index*5;width:230;height:1;color:"#a7bbc4"}}
  }
  MhiAirflow{x:218;y:143;width:205;height:48;active:live.visible&&unit.online&&unit.power;mode:unit.mode||"";fan:unit.fan||0}
  Text{x:18;y:48;text:live.direct("indoor"," °C");font.pixelSize:36;font.bold:true;color:live.directColor("indoor")}
  Text{x:20;y:92;text:"Binnentemperatuur";font.pixelSize:13;color:"#6a838e"}
  Rectangle{x:18;y:183;width:438;height:1;color:"#e2eaee"}
  Text{x:20;y:201;text:"Relatieve vochtigheid";font.pixelSize:15;color:"#59727e"}
  Text{anchors.right:parent.right;anchors.rightMargin:22;y:195;text:live.sensor("humidity"," %",0);font.pixelSize:25;font.bold:true;color:live.sensorColor("humidity")}
  Text{x:20;y:238;text:unit.power?"Luchtstroom actief":"Geen luchtstroom";font.pixelSize:13;color:unit.power?live.accent():"#8c9da5"}
 }

 Rectangle {
  x:(parent.width+14)/2;y:60;width:(parent.width-14)/2;height:270;radius:14
  color:"white";border.color:"#d7e4e9"
  Text{x:18;y:13;text:"BUITENUNIT";font.pixelSize:13;font.bold:true;color:"#66808c"}
  Text{x:18;y:48;text:live.direct("outdoor"," °C");font.pixelSize:36;font.bold:true;color:live.directColor("outdoor")}
  Text{x:20;y:92;text:"Buitentemperatuur";font.pixelSize:13;color:"#6a838e"}
  Rectangle {
   x:210;y:33;width:244;height:135;radius:8;border.color:"#a8bdc8"
   gradient:Gradient{GradientStop{position:0;color:"#f8fafb"}GradientStop{position:1;color:"#d1dfe5"}}
   Rectangle{x:20;y:129;width:38;height:7;color:"#a6bac4"}
   Rectangle{x:184;y:129;width:38;height:7;color:"#a6bac4"}
   MhiFan{x:8;y:9;width:110;height:110;active:live.visible&&unit.online&&unit.power&&!(live.hasSensor("defrost")&&unit.sensors.defrost===1)}
   Text{x:137;y:20;text:"MHI";font.pixelSize:19;font.bold:true;color:"#6f8996"}
   Repeater{model:7;Rectangle{x:137;y:58+index*5;width:82;height:1;color:"#a9bdc7"}}
  }
  Rectangle{x:18;y:183;width:438;height:1;color:"#e2eaee"}
  Text{x:20;y:199;text:"Compressorfrequentie";font.pixelSize:14;color:"#59727e"}
  Text{x:20;y:231;text:"Bedrijfsstroom";font.pixelSize:14;color:"#59727e"}
  Text{anchors.right:parent.right;anchors.rightMargin:22;y:194;text:live.sensor("hz"," Hz",1);font.pixelSize:20;font.bold:true;color:live.sensorColor("hz")}
  Text{anchors.right:parent.right;anchors.rightMargin:22;y:226;text:live.sensor("current"," A",1);font.pixelSize:20;font.bold:true;color:live.sensorColor("current")}
 }

 Rectangle {
  x:0;y:342;width:parent.width;height:78;radius:12
  color:live.warning()?"#fff0eb":"#edf5f2";border.color:live.warning()?"#e8b4a7":"#cfe3dc"
  Text{x:18;y:11;text:live.warning()?"!":"✓";font.pixelSize:26;font.bold:true;color:live.warning()?"#bf4d38":"#43826f"}
  Text{x:52;y:10;text:live.warning()?"Melding":"Geen storing";font.pixelSize:17;font.bold:true;color:live.warning()?"#9d3f31":"#356f5e"}
  Text{x:52;y:37;text:unit.online?"Airco reageert en levert actuele waarden":"De laatst bekende waarden blijven verborgen";font.pixelSize:13;color:"#6b8089"}
  Text{x:430;y:12;text:"Errorcode";font.pixelSize:13;color:"#71858e"}
  Text{x:430;y:34;text:live.code("E");font.pixelSize:21;font.bold:true;color:live.code("E")==="Geen"?"#43826f":live.code("E")==="—"?"#9aaab1":"#bf4d38"}
  Text{x:660;y:12;text:"Stopcode";font.pixelSize:13;color:"#71858e"}
  Text{x:660;y:34;text:live.code("M");font.pixelSize:21;font.bold:true;color:live.code("M")==="Geen"?"#43826f":live.code("M")==="—"?"#9aaab1":"#bf4d38"}
 }
}
