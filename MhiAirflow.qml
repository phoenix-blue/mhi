import QtQuick 2.1
Item {
 id:flow
 property bool active:false
 property string mode:""
 property int fan:0
 property color airColor:mode==="Verwarmen"?"#e96652":mode==="Koelen"?"#339cde":"#77b7bd"
 property int period:fan===6?650:fan===2?850:fan===1?1100:fan===7?1300:1600
 clip:true
 visible:active
 Repeater {
  model:5
  Item {
   x:flow.width*(index+1)/6-3;width:6;height:flow.height
   property real travel:0
   NumberAnimation on travel {from:0;to:1;duration:flow.period;loops:Animation.Infinite;running:flow.active&&flow.visible}
   Repeater {model:2
    Rectangle {x:0;y:((parent.travel+index*0.5)%1)*flow.height;height:flow.height*0.30;width:3;radius:2;color:flow.airColor;opacity:0.8*(1-y/flow.height)}
   }
  }
 }
}
