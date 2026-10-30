import QtQuick 2.1
Canvas {
 property string kind:"fan"
 property color tint:"#329ee8"
 property int level:-1
 onKindChanged:requestPaint()
 onTintChanged:requestPaint()
 onLevelChanged:requestPaint()
 onPaint:{
  var c=getContext("2d");c.clearRect(0,0,width,height);c.save();c.scale(width/40,height/40);
  c.strokeStyle=String(tint);c.fillStyle=String(tint);c.lineWidth=2.6;c.lineCap="round";c.lineJoin="round";
  if(kind==="sun"){
   c.beginPath();c.arc(20,20,8,0,Math.PI*2);c.fill();
   for(var i=0;i<8;i++){var a=i*Math.PI/4;c.beginPath();c.moveTo(20+12*Math.cos(a),20+12*Math.sin(a));c.lineTo(20+17*Math.cos(a),20+17*Math.sin(a));c.stroke()}
  }else if(kind==="snow"){
   for(var j=0;j<6;j++){c.save();c.translate(20,20);c.rotate(j*Math.PI/3);c.beginPath();c.moveTo(0,0);c.lineTo(0,-17);c.moveTo(-5,-10);c.lineTo(0,-5);c.lineTo(5,-10);c.stroke();c.restore()}
  }else if(kind==="drop"){
   c.beginPath();c.moveTo(20,2);c.bezierCurveTo(16,12,7,20,8,27);c.bezierCurveTo(10,41,33,39,32,25);c.bezierCurveTo(31,18,23,8,20,2);c.fill();c.strokeStyle="#ffffff";c.lineWidth=2;c.beginPath();c.moveTo(13,25);c.quadraticCurveTo(12,31,18,32);c.stroke();
  }else if(kind==="fan"){
   var activeBlades=level<1?5:Math.min(5,level);
   for(var k=0;k<5;k++){c.save();c.translate(20,20);c.rotate(k*Math.PI*2/5);c.globalAlpha=k<activeBlades?1:0.16;c.beginPath();c.moveTo(1,-3);c.bezierCurveTo(-7,-18,10,-19,12,-10);c.quadraticCurveTo(11,-4,1,-3);c.fill();c.restore()}
   c.globalAlpha=1;c.beginPath();c.arc(20,20,4,0,Math.PI*2);c.fill();
  }else if(kind==="auto"){
   c.beginPath();c.arc(20,20,16,0,Math.PI*2);c.stroke();c.beginPath();c.moveTo(12,28);c.lineTo(20,11);c.lineTo(28,28);c.moveTo(16,22);c.lineTo(24,22);c.stroke();
  }else{
   if(kind==="horizontal"){c.translate(40,0);c.rotate(Math.PI/2)}
   c.beginPath();c.moveTo(5,7);c.lineTo(35,7);c.lineTo(32,15);c.lineTo(8,15);c.closePath();c.stroke();
   for(var m=0;m<3;m++){var x=11+m*9;c.beginPath();c.moveTo(x,20);c.bezierCurveTo(x,26,x+4,28,x+4,34);c.stroke()}
   c.beginPath();c.moveTo(25,31);c.lineTo(33,35);c.lineTo(36,28);c.stroke();
  }
  c.restore();
 }
}
