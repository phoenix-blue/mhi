import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
SystrayIcon {
 id:tray
 posIndex:9060
 property string objectName:"mhiTray"
 visible:app.alerts.length>0
 property bool fault:{for(var i=0;i<app.alerts.length;i++)if(app.alerts[i].fault)return true;return false}
 onClicked:{app.requestedAlerts=true;stage.openFullscreen(app.screenUrl);if(app.mhiScreen){app.mhiScreen.tab=6;app.requestedAlerts=false}}
 Rectangle{anchors.centerIn:parent;width:26;height:26;radius:7;color:tray.fault?"#c53730":"#d08b22"
 Text{anchors.centerIn:parent;text:"!";font.bold:true;font.pixelSize:22;color:"white"}}
}
