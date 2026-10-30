import QtQuick 2.1
Item {
 id:manage
 property bool finding:false
 property string status:"Zoeken vindt WF-RAC en ESPHome met MHI in de netwerknaam."
 property string removeId:""
 function save(devices){if(app.busy){status="Wacht tot de opdracht klaar is en probeer opnieuw.";return;}var c=JSON.parse(JSON.stringify(app.snapshot.config));c.devices=devices;app.send("settings",c)}
 function edit(d){qkeyboard.open("Naam van airco",d.name,function(name){if(!name)return;qkeyboard.open("IP-adres",d.host.split(":")[0],function(host){if(!host)return;var list=JSON.parse(JSON.stringify(app.snapshot.config.devices));for(var i=0;i<list.length;i++)if(list[i].id===d.id){list[i].name=name;list[i].host=host.indexOf(":")<0?host+(d.driver==="esphome"?":6053":":51443"):host}manage.save(list)})})}
 function remove(id){var list=app.snapshot.config.devices.filter(function(d){return d.id!==id});save(list);removeId=""}
 function apiKey(d){qkeyboard.open("ESPHome API-sleutel", "", function(key){if(!key)return;app.send("esphome-key",{id:d.id,key:String(key).trim()})})}
 function toggleCooling(d){var list=JSON.parse(JSON.stringify(app.snapshot.config.devices));for(var i=0;i<list.length;i++)if(list[i].id===d.id)list[i].blockCoolingWhenCV=!list[i].blockCoolingWhenCV;save(list)}
 function nameFound(found,list,index,count){if(index>=found.length){finding=false;status=found.length+" gevonden · "+count+" toegevoegd.";if(count)save(list);return}var d=found[index];for(var j=0;j<list.length;j++)if(list[j].id===d.id){nameFound(found,list,index+1,count);return}if(list.length>=12){finding=false;status="Maximaal 12 airco’s; verwijder eerst een unit.";if(count)save(list);return}qkeyboard.open("Gevonden "+(d.driver==="esphome"?"ESPHome":"WF-RAC")+" · "+d.host.split(":")[0]+" · naam",d.name,function(name){if(name){d.name=name;list.push(d);count++}manage.nameFound(found,list,index+1,count)})}
 function scan(){finding=true;status="Netwerk doorzoeken…";var x=new XMLHttpRequest();x.open("POST","http://127.0.0.1:18781/discover");x.setRequestHeader("X-Toon-MHI","1");x.onreadystatechange=function(){if(x.readyState!==4)return;if(x.status!==200){manage.finding=false;manage.status="Zoeken mislukt; probeer opnieuw.";return}try{manage.nameFound(JSON.parse(x.responseText).devices,JSON.parse(JSON.stringify(app.snapshot.config.devices)),0,0)}catch(e){manage.finding=false;manage.status="Ongeldig zoekantwoord"}};x.send("{}")}

 Column{width:parent.width;spacing:8
 Text{text:"Airco’s beheren";font.pixelSize:24;color:"#234250"}
 MhiButton{width:350;label:manage.finding?"Zoeken…":"Zoek airco’s en geef een naam";enabled:!manage.finding&&!app.busy;onClicked:manage.scan()}
 Text{width:parent.width;text:manage.status;wrapMode:Text.WordWrap;font.pixelSize:15;color:"#526e7b"}
 Item{width:parent.width;height:manage.height-130
 Flickable{id:unitScroll;width:parent.width-14;height:parent.height;contentHeight:rows.height;clip:true;boundsBehavior:Flickable.StopAtBounds
 Column{id:rows;width:unitScroll.width;spacing:8
 Repeater{model:app.snapshot.config.devices||[]
 Rectangle{width:rows.width;height:manage.removeId===modelData.id?174:132;radius:8;color:"#e8f0f4"
 Column{x:10;y:6;width:parent.width-20;spacing:5
 Text{text:modelData.name+" · "+modelData.host.split(":")[0]+" · "+(modelData.driver==="esphome"?"ESPHome":"WF-RAC");font.pixelSize:17;color:"#234250"}
 Row{spacing:8
 MhiButton{label:"Aanpassen";enabled:!manage.finding&&!app.busy;onClicked:manage.edit(modelData)}
 MhiButton{label:"API-sleutel";visible:modelData.driver==="esphome";enabled:!manage.finding&&!app.busy;onClicked:manage.apiKey(modelData)}
 MhiButton{label:"Verwijderen";enabled:!manage.finding&&!app.busy;onClicked:manage.removeId=modelData.id}
 }
 MhiButton{width:parent.width;label:(modelData.blockCoolingWhenCV?"☑ ":"☐ ")+"Koelen blokkeren bij CV-warmtevraag";active:!!modelData.blockCoolingWhenCV;enabled:!manage.finding&&!app.busy;onClicked:manage.toggleCooling(modelData)}
 Row{visible:manage.removeId===modelData.id;spacing:8
 Text{text:"Uit deze app halen?";font.pixelSize:16;anchors.verticalCenter:parent.verticalCenter}
 MhiButton{label:"Ja, verwijderen";width:160;enabled:!app.busy;onClicked:manage.remove(modelData.id)}
 MhiButton{label:"Annuleren";onClicked:manage.removeId=""}
 }
 }
 }
 }
 }
 }
 Rectangle{anchors.right:parent.right;width:5;height:parent.height;radius:3;color:"#e1e9ee";visible:unitScroll.contentHeight>unitScroll.height
  Rectangle{width:parent.width;height:Math.max(28,parent.height*unitScroll.visibleArea.heightRatio);radius:3;color:"#7fa4b7";y:(parent.height-height)*unitScroll.visibleArea.yPosition}
 }
 Text{anchors.right:parent.right;anchors.bottom:parent.bottom;anchors.margins:8;text:"Veeg voor meer airco’s  ↕";font.pixelSize:13;color:"#607d8b";visible:unitScroll.contentHeight>unitScroll.height}
 }
 }
}
