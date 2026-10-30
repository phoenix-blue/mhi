import QtQuick 2.1
Item {
 id:panel
 property var unit:({})
 property string unitID:unit.id||""
 property var rows:makeRows()
 width:parent.width
 height:300
 function value(v,suffix){return v===undefined||v===null||!isFinite(Number(v))?"--":Number(v).toFixed(1)+(suffix||"")}
 function makeRows(){
  var u=unit||{}, s=u.sensors||{}, d=u.details||{}, times=u.sensorTimes||{}, r=[];
  function add(label,v,action,choices,stamp,fresh){var missing=v===undefined||v===null||v===""||v==="--"||v==="Niet ontvangen"||v==="Onbekend";r.push({label:label,available:!missing&&u.online&&fresh!==false,value:missing?"--":String(v),action:action||"",choices:choices||[],stamp:stamp===undefined?(u.updated||""):stamp})}
  function sensor(label,key,suffix){add(label,value(s[key],suffix),"",[],times[key]||"",(u.sensorFresh||{})[key]===true)}
  function flag(label,key){add(label,s[key]===undefined?"--":s[key]?"Actief":"Niet actief","",[],times[key]||"",(u.sensorFresh||{})[key]===true)}
  add("Bedrijf",u.power?"Aan":"Uit","power",[{name:"Uit",v:0},{name:"Aan",v:1}]);
  add("Modus",u.mode,"mode",[{name:"Auto",v:0},{name:"Koelen",v:8},{name:"Verwarmen",v:16},{name:"Ventileren",v:12}]);
  add("Doeltemperatuur",value(u.target," °C"),"target");
  var fan=[{name:"Auto",v:0},{name:"Stil",v:1},{name:"Laag",v:2},{name:"Midden",v:3},{name:"Hoog",v:4}];
  add("Ventilator binnen",({7:"Auto",0:"Stil",1:"Laag",2:"Midden",6:"Hoog"})[u.fan],"fan",fan);
  var ud=[{name:"Swing",v:0}],lr=[{name:"Swing",v:0}];for(var n=1;n<=7;n++){lr.push({name:"Stand "+n,v:n});if(n<=4)ud.push({name:"Stand "+n,v:n})}
  if(u.driver==="esphome"){ud=[];lr=[];var choices=u.choices||{};for(var a=0;a<(choices.louverUD||[]).length;a++)ud.push({name:choices.louverUD[a],v:a});for(var b=0;b<(choices.louverLR||[]).length;b++)lr.push({name:choices.louverLR[b],v:b});}
  add("Lamellen omhoog / omlaag",u.louverUD,"louverUD",ud);add("Lamellen links / rechts*",u.louverLR,"louverLR",lr);
  add("Temperatuur binnen",value(u.indoor," °C"));add("Temperatuur buiten",value(u.outdoor," °C"));
  sensor("Luchtvochtigheid binnen","humidity"," %");add("Foutcode",u.fault);sensor("Beveiligingscode","protection","");
  add("Compressorvraag",d.compressor);sensor("Compressorfrequentie","hz"," Hz");sensor("Bedrijfsstroom","current"," A");
  flag("Ontdooien","defrost");flag("Warme start","hotStart");flag("Stille buitenunit","silent");
  sensor("Persgastemperatuur","discharge"," °C");sensor("Warmtewisselaar binnen","indoorCoil"," °C");sensor("Warmtewisselaar uitlaat","gasCoil"," °C");
  sensor("EEV-positie","eevPercent"," %");sensor("EEV-pulsen","eev"," pulses");add("Energie huidige cyclus",value(u.energy," kWh"));
  add("Afwezigheidsmodus",d.afwezig);
  var labels=["Afwezig: koelen buitendrempel","Afwezig: verwarmen buitendrempel","Afwezig: koelen doeltemperatuur","Afwezig: verwarmen doeltemperatuur","Afwezig: koelen ventilator","Afwezig: verwarmen ventilator"];
  for(n=27;n<=32;n++){var k="leave"+n,v=s[k];add(labels[n-27],n<31?value(v," °C"):(v===undefined?"--":(fan[v]?fan[v].name:"--")),v===undefined?"":k,n>=31?fan:[],times[k],(u.sensorFresh||{})[k]===true)}
  if(u.driver==="esphome")sensor("Warmtewisselaar buiten","outdoorCoil"," °C");else add("Warmtewisselaar buiten","Geen betrouwbare °C-omrekening");
  add("IP-adres",(u.host||"").replace(/:\d+$/, "").replace(/^\[|\]$/g,""));
  return r;
 }
 property var editing:null
 function edit(row){editing=row;if(row.choices.length){chooser.visible=true;return}qkeyboard.open(row.label+" (°C)",String(row.action==="target"?unit.target:unit.sensors[row.action]),function(t){if(t===undefined||t===null||String(t).trim()==="")return;var n=Number(String(t).replace(",","."));if(isFinite(n))app.control(row.action,n)})}
 Column {width:parent.width;spacing:6
  ListView {width:parent.width;height:34;orientation:ListView.Horizontal;spacing:8;clip:true;model:app.snapshot.units
   delegate:MhiButton {width:180;height:34;label:modelData.name;active:index===app.selected;onClicked:app.selected=index}
  }
  Text {width:parent.width;text:unit.online?(unit.telemetry||"Servicedata ophalen")+" · grijs = niet actueel · -- = niet ontvangen":"Offline · eerdere waarden niet actueel";font.family:"DejaVu Sans";font.pixelSize:13;color:unit.online?"#526e7b":"#ac3939";elide:Text.ElideRight}
  Rectangle {width:parent.width;height:26;color:"#244b5b"
   Text{x:10;anchors.verticalCenter:parent.verticalCenter;text:"Gegeven";color:"white";font.family:"DejaVu Sans";font.pixelSize:14}
   Text{x:parent.width*.47;anchors.verticalCenter:parent.verticalCenter;text:"Waarde";color:"white";font.family:"DejaVu Sans";font.pixelSize:14}
   Text{x:parent.width-140;anchors.verticalCenter:parent.verticalCenter;text:"Ontvangen";color:"white";font.family:"DejaVu Sans";font.pixelSize:13}
  }
  ListView {id:list;width:parent.width;height:panel.height-108;clip:true;model:panel.rows.length;boundsBehavior:Flickable.StopAtBounds
   delegate:Rectangle {property var row:panel.rows[index];width:list.width;height:42;color:index%2?"#edf3f5":"white"
    Text{x:10;width:parent.width*.45-12;anchors.verticalCenter:parent.verticalCenter;text:row.label;font.family:"DejaVu Sans";font.pixelSize:14;color:"#294650";elide:Text.ElideRight}
    Text{x:parent.width*.47;width:parent.width*.53-152;anchors.verticalCenter:parent.verticalCenter;text:row.value;font.family:"DejaVu Sans";font.pixelSize:14;color:row.available?"#203d49":"#99a3aa";elide:Text.ElideRight}
    Text{x:parent.width-140;anchors.verticalCenter:parent.verticalCenter;text:row.stamp;font.family:"DejaVu Sans";font.pixelSize:12;color:"#6c818a"}
    MhiButton{x:parent.width-65;y:5;width:60;height:32;label:"Wijzig";visible:!!row.action;enabled:unit.online;onClicked:panel.edit(row)}
   }
   Rectangle{anchors.right:parent.right;width:3;y:list.visibleArea.yPosition*list.height;height:Math.max(15,list.visibleArea.heightRatio*list.height);color:"#147d99"}
  }
  Text{width:parent.width;text:"Veeg voor meer gegevens. * Links/rechts is een gemelde stand, geen positiemeting.";font.family:"DejaVu Sans";font.pixelSize:12;color:"#647f8a";elide:Text.ElideRight}
 }
 Rectangle{id:chooser;visible:false;anchors.fill:parent;color:"#f5f8fa";z:2
  Column {x:12;y:12;spacing:12;width:parent.width-24
   Text{text:panel.editing?panel.editing.label:"";font.family:"DejaVu Sans";font.pixelSize:20;color:"#244b5b"}
   Flow{width:parent.width;spacing:8;Repeater{model:panel.editing?panel.editing.choices:[];MhiButton{width:145;label:modelData.name;enabled:unit.online;onClicked:{app.control(panel.editing.action,modelData.v);chooser.visible=false}}}}
   MhiButton{label:"Annuleren";onClicked:chooser.visible=false}
  }
 }
 onUnitIDChanged:if(chooser.visible)chooser.visible=false
}
