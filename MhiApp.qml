import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
App {
 id: app
 property url tileUrl: "MhiTile.qml"
 property MhiTile mhiTile
 property url screenUrl: "MhiScreen.qml"
 property MhiTray mhiTray
 property MhiScreen mhiScreen
 property var snapshot: ({units:[], thermostat:{online:false,reason:"Verbinden..."},config:{sensorInterval:10,devices:[]}})
 property string message: "Verbinden met MHI-service..."
 property var queue: []
 property var pending: ({})
 property int revision: 0
 property string queueError: ""
 property bool busy: false
 function desired(unit,action,fallback){var k=unit.id+":"+action;return pending[k]===undefined?fallback:pending[k]}

 property bool refreshing: false
 property int selected: 0
 property bool requestedAlerts: false
 property string connectionError: ""
 property var alerts: buildAlerts(snapshot,queueError,connectionError)
 function buildAlerts(s,q,c){var a=[];if(c)a.push({name:"MHI-service",text:c,fault:false});if(q)a.push({name:"Opdracht",text:q,fault:false});var units=s.units||[];for(var i=0;i<units.length;i++){var u=units[i];if(!u.online)a.push({name:u.name,text:u.error||"Niet bereikbaar",fault:false});else if(u.fault&&u.fault!=="Geen"&&u.fault!=="00"&&u.fault!=="0")a.push({name:u.name,text:"Storing "+u.fault,fault:true})}if(s.notice&&s.notice.indexOf("Koel")===0)a.push({name:"Koelblokkering",text:s.notice,fault:false});return a}
 property string requestedUnit: ""
 property var registeredUnits: ({})
 function unitById(id){for(var i=0;i<snapshot.units.length;i++)if(snapshot.units[i].id===id)return snapshot.units[i];return {online:false,missing:true,name:"MHI Airco"}}
 function registerUnits(units){for(var i=0;i<units.length;i++){var u=units[i];if(!registeredUnits[u.id]&&/^[a-f0-9]{12}$/.test(u.id)){registry.registerWidget("tile",Qt.resolvedUrl("MhiUnit_"+u.id+".qml"),app,null,{thumbCategory:"general",thumbLabel:"Airco · "+u.name,thumbIcon:"qrc:/tsc/button_on.png",thumbWeight:30,baseTileWeight:12});registeredUnits[u.id]=true}}}
 // Register saved URLs before Toon restores its home-screen layout. Never wait
 // for /state here: the service or WF-RAC may still be starting or offline.
 function registerSavedUnits() {
 try {
 var x=new XMLHttpRequest();
 x.open("GET","file:///mnt/data/tsc/mhi.json",false);x.send();
 var saved=JSON.parse(x.responseText);
 registerUnits(saved.devices||[]);
 } catch(e) { console.log("MHI: opgeslagen unit-tegels konden niet worden geladen") }
 }
 // Keep existing home-screen shortcuts usable after a device is removed.
 // Only restore URLs already in the layout and backed by an installed tile.
 function registerLayoutUnits() {
 try {
 var x=new XMLHttpRequest();
 x.open("GET","file:///mnt/data/qmf/config/config_qt-gui.xml",false);x.send();
 var pattern=/<url>[^<]*\/apps\/mhi\/MhiUnit_([a-f0-9]{12})\.qml<\/url>/g;
 var match;
 while((match=pattern.exec(x.responseText))!==null){
 var id=match[1];
 if(registeredUnits[id])continue;
 var tile=new XMLHttpRequest();
 tile.open("GET","file:///qmf/qml/apps/mhi/MhiUnit_"+id+".qml",false);tile.send();
 if(tile.responseText)registerUnits([{id:id,name:"MHI-overzicht"}]);
 }
 } catch(e) { console.log("MHI: bestaande snelkoppelingen konden niet worden geladen") }
 }
 function openUnit(id){requestedUnit=id;stage.openFullscreen(screenUrl)}
 function init() {
 registry.registerWidget("tile",tileUrl,this,"mhiTile",{thumbCategory:"general",thumbLabel:"MHI Airco",thumbIcon:"qrc:/tsc/button_on.png",thumbWeight:30,baseTileWeight:12})
 registry.registerWidget("screen",screenUrl,this,"mhiScreen")
 registry.registerWidget("systrayIcon",Qt.resolvedUrl("MhiTray.qml"),this,"mhiTray")
 registerSavedUnits()
 registerLayoutUnits()
 refresh()
 }
 function requestInstall() {
 try {
 var pending=tscCommandFile.read()
 if(pending.length===0)tscCommandFile.write("external-mhi")
 } catch(e) { console.log("MHI: TSC-installatieopdracht kon niet worden aangevraagd") }
 }
 function refresh() {
 if(refreshing)return;refreshing=true;
 var version=revision;var x=new XMLHttpRequest(); x.open("GET","http://127.0.0.1:18781/state");
 x.onreadystatechange=function(){if(x.readyState===4){app.refreshing=false;if(x.status===200){try{app.snapshot=JSON.parse(x.responseText);app.connectionError="";app.registerUnits(app.snapshot.units);if(!app.busy&&version===app.revision)app.pending=({});if(!app.busy)app.message=app.queueError||app.snapshot.notice||"Live verbinding"}catch(e){app.connectionError=app.message="Ongeldige servicegegevens"}}else {app.connectionError=app.message="MHI-service niet bereikbaar"}}};x.send()
 }
 function send(path,body) {
 if(queue.length>=64){message="Wachtrij vol; wacht tot opdrachten klaar zijn";return false}
 if(!busy)queueError="";
 queue.push({path:path,body:body});revision++;drain();return true;
 }
 function drain(){
 if(busy||!queue.length)return;
 var job=queue.shift();busy=true;message="Opdracht uitvoeren · "+queue.length+" in wachtrij";
 // Settings patches are applied when dispatched, avoiding stale queued configs.
 if(job.path==="setting"){var c=JSON.parse(JSON.stringify(snapshot.config));c[job.body.key]=job.body.value;job={path:"settings",body:c}}
 var x=new XMLHttpRequest();x.open("POST","http://127.0.0.1:18781/"+job.path);x.setRequestHeader("Content-Type","application/json");x.setRequestHeader("X-Toon-MHI","1");
 x.onreadystatechange=function(){if(x.readyState!==4)return;
 var result={};try{result=JSON.parse(x.responseText)}catch(e){}
 var ok=x.status===200&&result.ok!==false;
 if(!ok)app.queueError="Mislukt: "+(result.message||x.responseText||"geen verbinding");
 if(ok&&job.path==="settings"){var snap=JSON.parse(JSON.stringify(app.snapshot));snap.config=job.body;app.snapshot=snap}
 app.busy=false;app.message=app.queueError||(job.path==="settings"?"Instellingen opgeslagen":result.message||"Opdracht verzonden");
 if(app.queue.length)app.drain();else app.refresh();
 };x.send(JSON.stringify(job.body));
 }
 function control(action,value){var unit=snapshot.units[selected];if(!unit)return;
 if(send("command",{id:unit.id,index:selected,action:action,value:value})){var p=JSON.parse(JSON.stringify(pending));p[unit.id+":"+action]=value;pending=p}
 }
 function setting(key,value){send("setting",{key:key,value:value})}
 function val(v,suffix){return v===null||v===undefined?"Niet beschikbaar":Number(v).toFixed(1)+suffix}
 Timer{interval:3000;running:true;repeat:true;onTriggered:if(!app.busy)app.refresh()}
 Component.onCompleted: requestInstall()
 FileIO{id:tscCommandFile;source:"file:///tmp/tsc.command"}
}
