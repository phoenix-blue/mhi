import QtQuick 2.1
import qb.components 1.0
Screen {
 id:root
 screenTitle:"MHI Airco"
 property int tab:0
 property var unit:app.snapshot.units.length>app.selected?app.snapshot.units[app.selected]:({online:false})
 onVisibleChanged:if(visible){tab=0;if(app.requestedUnit){for(var i=0;i<app.snapshot.units.length;i++)if(app.snapshot.units[i].id===app.requestedUnit){app.selected=i;tab=4;break}app.requestedUnit=""}if(app.requestedAlerts){tab=6;app.requestedAlerts=false}addCustomTopRightButton("Sluiten");app.refresh()}
 onCustomButtonClicked:hide()
 function edit(key,title){qkeyboard.open(title,String(app.snapshot.config[key]),function(t){if(t!==undefined&&t!==null){var n=Number(String(t).replace(",","."));if(isFinite(n))app.setting(key,n)}})}
 function addUnit(driver){if(!driver){root.tab=8;return}qkeyboard.open("Naam van airco","",function(name){if(!name)return;qkeyboard.open("IP-adres van "+(driver==="esphome"?"ESPHome":"WF-RAC"),"192.168.10.",function(host){if(!host)return;if(driver!=="esphome"){root.resolveWF(name,host);return}qkeyboard.open("MAC-adres (12 hextekens)","",function(id){if(!id)return;var c=JSON.parse(JSON.stringify(app.snapshot.config));c.devices.push({name:name,driver:driver,host:host.indexOf(":")<0?host+(driver==="esphome"?":6053":":51443"):host,id:id.toLowerCase().replace(/:/g,"")});app.send("settings",c);root.tab=3})})})}
 function resolveWF(name,host){var x=new XMLHttpRequest();x.open("POST","http://127.0.0.1:18781/resolve");x.setRequestHeader("X-Toon-MHI","1");app.message="WF-RAC opzoeken…";x.onreadystatechange=function(){if(x.readyState!==4)return;if(x.status!==200){app.message=x.responseText||"WF-RAC niet gevonden";return}try{var d=JSON.parse(x.responseText);var c=JSON.parse(JSON.stringify(app.snapshot.config));for(var i=0;i<c.devices.length;i++)if(c.devices[i].id===d.id){c.devices[i]=d;app.send("settings",c);root.tab=3;return}c.devices.push(d);app.send("settings",c);root.tab=3}catch(e){app.message="Ongeldig antwoord van WF-RAC"}};x.send(JSON.stringify({name:name,host:host.indexOf(":")<0?host+":51443":host}))}

 Rectangle{anchors.fill:parent;color:"#f5f8fa"}
 Column{
 x:24;y:12;width:parent.width-48;spacing:10
 Row{spacing:10
 MhiButton{label:"Airco's";active:root.tab===0||root.tab===4;onClicked:root.tab=0}
 MhiButton{label:"Gegevens";active:root.tab===1;onClicked:root.tab=1}
 MhiButton{label:"Instellingen";active:root.tab===3;onClicked:root.tab=3}
 }
 Rectangle{visible:root.tab===3;width:parent.width;height:40;radius:7;color:app.snapshot.thermostat.heating?"#ffebd9":"#e3f2ed"
 Text{anchors.centerIn:parent;text:(app.snapshot.thermostat.reason||"Verbinden")+"   •   Toon "+app.val(app.snapshot.thermostat.temperature,"°")+" → "+app.val(app.snapshot.thermostat.target,"°");font.family:"DejaVu Sans";font.pixelSize:16;color:"#294650"}}
 MhiOverview{visible:root.tab===0;onSelected:{app.selected=unitIndex;root.tab=4}onAddRequested:root.tab=8}
 MhiPlugins{visible:root.tab===7;width:parent.width;height:root.height-110}
 MhiManage{visible:root.tab===5;width:parent.width;height:root.height-110}
 MhiAddUnit{visible:root.tab===8;width:parent.width;height:root.height-110;onBackRequested:root.tab=3;onAddRequested:root.addUnit(driver)}
 Column{visible:root.tab===6;spacing:10;width:parent.width
 Text{text:"Meldingen";font.pixelSize:24;color:"#234250"}
 Text{visible:app.alerts.length===0;text:"Geen actieve meldingen";font.pixelSize:18}
 Repeater{model:app.alerts
 Text{width:root.width-60;wrapMode:Text.WordWrap;text:(modelData.fault?"!  ":"•  ")+modelData.name+": "+modelData.text;font.pixelSize:18;color:modelData.fault?"#b12c28":"#80591b"}}
 }
 MhiLive{unit:root.unit;visible:root.tab===1;height:root.height-100}
 MhiRemote{unit:root.unit;visible:root.tab===4;onBackRequested:root.tab=0}
 Column{visible:root.tab===3;spacing:9
 MhiButton{width:530;label:"Airco’s beheren en zoeken";onClicked:root.tab=5}
 Row{spacing:10
 MhiButton{width:260;label:"+ Airco toevoegen";enabled:app.snapshot.units.length<12;onClicked:root.tab=8}
 MhiButton{width:260;label:"Externe plugins downloaden";onClicked:root.tab=7}
 }
 MhiButton{width:530;label:"Sensorinterval  "+(app.snapshot.config.sensorInterval||10)+" s";onClicked:root.edit("sensorInterval","Sensorinterval: 10 tot 300 seconden")}
 Text{width:root.width-60;text:"Per airco stel je onder ‘Airco’s beheren’ in of Koelen wordt geblokkeerd wanneer de CV-ketel warmtevraag heeft. Auto en Drogen blijven beschikbaar.\nEigen tegel: kies ‘Airco · naam’ in Toons tegelkeuze.";font.family:"DejaVu Sans";font.pixelSize:16;color:"#526e7b";wrapMode:Text.WordWrap}
 }
 Item{width:parent.width;height:24
 property bool unitError:root.tab===4&&!root.unit.online
 Rectangle{x:2;y:7;width:11;height:11;radius:6;color:parent.unitError||app.connectionError?"#d4514c":app.busy?"#e9a13b":"#45a766";border.width:2;border.color:"#ffffff"}
 Text{x:21;width:parent.width-21;height:24;verticalAlignment:Text.AlignVCenter;text:parent.unitError?(root.unit.error||"Airco niet bereikbaar"):app.message;font.family:"DejaVu Sans";font.pixelSize:14;color:"#647f8a";elide:Text.ElideRight}
 }
 }
}
