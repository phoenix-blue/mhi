import QtQuick 2.1
Item {
 id:add
 property string driver:"wfrac"
 signal backRequested()
 signal addRequested(string driver)
 Column{width:parent.width;spacing:8
  Row{spacing:12
   MhiButton{width:150;label:"‹ Instellingen";onClicked:add.backRequested()}
   Text{height:42;verticalAlignment:Text.AlignVCenter;text:"Airco toevoegen";font.pixelSize:25;font.bold:true;color:"#234250"}
  }
  Text{text:"1. Merk";font.pixelSize:16;font.bold:true;color:"#526e7b"}
  Rectangle{width:parent.width;height:54;radius:10;color:"#ffffff";border.color:"#b8cdd6";border.width:2
   Image{x:14;y:7;width:90;height:40;source:"mhi-logo.png";fillMode:Image.PreserveAspectFit;smooth:true}
   Text{x:118;height:54;verticalAlignment:Text.AlignVCenter;text:"Mitsubishi Heavy Industries";font.pixelSize:19;font.bold:true;color:"#234250"}
  }
  Text{text:"2. Type koppeling";font.pixelSize:16;font.bold:true;color:"#526e7b"}
  Row{spacing:10
   Repeater{model:[{id:"wfrac",title:"WF-RAC",note:"Originele MHI wifi-adapter"},{id:"esphome",title:"ESPHome MHI WiFi",note:"Lokale ESPHome API"}]
    Rectangle{width:(add.width-10)/2;height:76;radius:10;color:add.driver===modelData.id?"#e6f3fb":"#ffffff";border.color:add.driver===modelData.id?"#2d94d2":"#b8cdd6";border.width:add.driver===modelData.id?3:2
     Text{x:14;y:10;text:modelData.title;font.pixelSize:19;font.bold:true;color:"#234250"}
     Text{x:14;y:39;text:modelData.note;font.pixelSize:14;color:"#607985"}
     MouseArea{anchors.fill:parent;onClicked:add.driver=modelData.id}
    }
   }
  }
  Text{text:"3. Verbinding";font.pixelSize:16;font.bold:true;color:"#526e7b"}
  Row{spacing:10
   Rectangle{width:(add.width-10)/2;height:58;radius:10;color:"#e8f5ed";border.color:"#45a766";border.width:3
    Rectangle{x:14;y:21;width:13;height:13;radius:7;color:"#45a766"}
    Text{x:38;height:58;verticalAlignment:Text.AlignVCenter;text:"Lokaal · geselecteerd";font.pixelSize:18;font.bold:true;color:"#2c6240"}
   }
   Rectangle{width:(add.width-10)/2;height:58;radius:10;color:"#f1f3f5";border.color:"#cbd3d8";border.width:2;opacity:0.72
    Text{anchors.centerIn:parent;text:"Cloud · toekomstoptie";font.pixelSize:18;color:"#778991"}
   }
  }
  Text{width:parent.width;wrapMode:Text.WordWrap;text:add.driver==="wfrac"?"De app zoekt de WF-RAC lokaal via IP-adres en poort 51443. Er zijn geen cloudgegevens nodig.":"De app verbindt lokaal via poort 6053. Na het toevoegen kun je onder Airco’s beheren de ESPHome API-sleutel invullen.";font.pixelSize:15;color:"#526e7b"}
  MhiButton{width:430;height:42;label:"Doorgaan met lokaal toevoegen";active:true;onClicked:add.addRequested(add.driver)}
 }
}
