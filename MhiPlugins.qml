import QtQuick 2.1
Item {
 id: panel
 property var entries: []
 property bool loading: false
 property string status: "Download en beheer gecontroleerde airco-koppelingen uit de externe catalogus."
 property string removeID: ""
 onVisibleChanged: if (visible) reload()
 function reload() {
  if (loading) return
  loading=true; status="Plugincatalogus ophalen…"
  var x=new XMLHttpRequest()
  x.open("GET","http://127.0.0.1:18781/plugins")
  x.onreadystatechange=function(){
   if(x.readyState!==4)return
   loading=false
   if(x.status!==200){status="Catalogus niet bereikbaar";return}
   try {var data=JSON.parse(x.responseText); entries=data.plugins; status=data.message||"Plugins blijven behouden bij een app-update."}
   catch(e){status="Ongeldig antwoord"}
  }
  x.send()
 }
 function change(id,action) {
  if(loading)return
  loading=true; removeID=""; status=action==="install"?"Plugin downloaden en controleren…":"Plugin verwijderen…"
  var x=new XMLHttpRequest()
  x.open("POST","http://127.0.0.1:18781/plugins"); x.setRequestHeader("X-Toon-MHI","1")
  x.onreadystatechange=function(){
   if(x.readyState!==4)return
   loading=false
   if(x.status!==200){status=x.responseText||"Plugin wijzigen mislukt";return}
   reload();app.refresh()
  }
  x.send(JSON.stringify({id:id,action:action}))
 }
 Column {
  anchors.fill:parent; spacing:10
  Row {spacing:10
   Text {width:310;height:44;verticalAlignment:Text.AlignVCenter;text:"Externe airco-plugins";font.pixelSize:24;color:"#234250"}
   MhiButton {width:190;label:panel.loading?"Even wachten…":"Catalogus ophalen";enabled:!panel.loading;onClicked:panel.reload()}
  }
  Text {width:parent.width;text:panel.status;wrapMode:Text.WordWrap;font.pixelSize:16;color:"#526e7b"}
  Item {width:parent.width;height:panel.height-120
  Flickable {id:pluginScroll
   width:parent.width-14;height:parent.height;contentHeight:cards.height;clip:true;boundsBehavior:Flickable.StopAtBounds
   Column {id:cards;width:pluginScroll.width;spacing:12
    Repeater {model:panel.entries
     Rectangle {
      width:cards.width;height:panel.removeID===modelData.id?164:114;radius:9;color:"white";border.color:"#b8cdd6"
      Column {x:12;y:10;spacing:8
       Text {text:modelData.name;font.pixelSize:22;color:"#234250"}
       Text {text:(modelData.installed?"Geïnstalleerd: "+modelData.installed:"Nog niet geïnstalleerd")+"   ·   Beschikbaar: "+modelData.version+(modelData.inUse?"   ·   In gebruik":"");font.pixelSize:15;color:"#526e7b"}
       Row {spacing:10
        MhiButton {width:260;height:36;label:!modelData.installed?"Downloaden en installeren":modelData.installed!==modelData.version?"Bijwerken":"Opnieuw installeren";enabled:!panel.loading;onClicked:panel.change(modelData.id,"install")}
        MhiButton {width:170;height:36;label:"Verwijderen";enabled:!panel.loading&&!!modelData.installed&&!modelData.inUse;onClicked:panel.removeID=modelData.id}
       }
       Row {visible:panel.removeID===modelData.id;spacing:10
        MhiButton {width:210;height:36;label:"Bevestig verwijderen";enabled:!panel.loading;onClicked:panel.change(modelData.id,"remove")}
        MhiButton {width:170;height:36;label:"Annuleren";onClicked:panel.removeID=""}
       }
      }
     }
    }
   }
  }
  Rectangle {anchors.right:parent.right;width:5;height:parent.height;radius:3;color:"#e1e9ee";visible:pluginScroll.contentHeight>pluginScroll.height
   Rectangle {width:parent.width;height:Math.max(28,parent.height*pluginScroll.visibleArea.heightRatio);radius:3;color:"#7fa4b7";y:(parent.height-height)*pluginScroll.visibleArea.yPosition}
  }
  }
 }
}
