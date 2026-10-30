import QtQuick 2.1
Item {
 id:fan
 property bool active:false
 Canvas {anchors.fill:parent
  RotationAnimation on rotation {from:0;to:360;duration:1800;loops:Animation.Infinite;running:fan.active&&fan.visible}
  onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.fillStyle="#8faab7";for(var i=0;i<3;i++){c.save();c.translate(55,55);c.rotate(i*Math.PI*2/3);c.beginPath();c.moveTo(0,0);c.bezierCurveTo(40,-35,51,15,13,27);c.closePath();c.fill();c.restore()}}
 }
 Canvas {anchors.fill:parent;onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.strokeStyle="#a8bdc8";c.lineWidth=1;for(var r=13;r<=49;r+=6){c.beginPath();c.arc(55,55,r,0,Math.PI*2);c.stroke()}c.beginPath();c.arc(55,55,9,0,Math.PI*2);c.fillStyle="#607e8e";c.fill()}}
}
