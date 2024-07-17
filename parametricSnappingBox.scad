include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

$fa = 1;
$fs = 0.4;

generatedPart = "lid"; //box or lid

x=50;
y=50;
z=20;

lidOverlap=10;
lidTolerance = 0.8;
notchRadius=0.6;

botDevision = false; 
topDevisionSize = botDevision==true ? 25 : x;
botDevisionSize= x - topDevisionSize;

boxFillet=1;
compartementFillet=2;

outerWallThickness=1;
innerWallThickness=1;
innerWallHeight=z;

topXSubDiv=5;
topYSubDiv=3;

botXSubDiv=3;
botYSubDiv=2;

topMaskX = ((x - ((outerWallThickness * 2)+(innerWallThickness * (topXSubDiv - 1)))) / topXSubDiv); // two outer walls and n-1 inner walls
topMaskY = ((topDevisionSize - ((outerWallThickness)+(innerWallThickness * (topYSubDiv)))) / topYSubDiv); // 1.5 outer walls and n-1 inner walls

botMaskX = botDevision==true ? ((x - ((outerWallThickness * 2)+(innerWallThickness * (botXSubDiv - 1)))) / botXSubDiv) : undef; // two outer walls and n-1 inner walls
botMaskY = botDevision==true ? ((botDevisionSize - ((outerWallThickness)+(innerWallThickness * (botYSubDiv)))) / botYSubDiv) : undef; // 1 outer wall and n inner walls 


module compartementMaskBoxes (xSubDiv, ySubDiv, xSize, ySize) 
{
    for(i=[0:1:(xSubDiv-1)])
            xmove(-(x/2)) xmove((xSize / 2) + outerWallThickness) //starting position
            xmove(xSize * i) xmove(innerWallThickness * i) //loop changes this
            zmove(z/2) zmove(outerWallThickness) //make room for floor
        cuboid(
            size=[xSize, ySize, z], 
            fillet=compartementFillet,
            edges=EDGES_Z_ALL+EDGES_BOTTOM,
            center=true
        );
};

module compartementMaskBoxesArray ()
{
    for(i = [0:1:(topYSubDiv - 1)])
        ymove((topMaskY / 2)) ymove(innerWallThickness / 2) // starting position
        ymove(topMaskY * i) ymove(innerWallThickness * i) // affected by loop
        compartementMaskBoxes(
            xSubDiv=topXSubDiv,
            ySubDiv=topYSubDiv,
            xSize=topMaskX,
            ySize=topMaskY,
    );
    if(botDevision==true)
    {
        for(i = [0:1:(botYSubDiv - 1)])
            ymove(-(botMaskY / 2)) ymove(-(innerWallThickness / 2)) // starting position
            ymove(-(botMaskY * i)) ymove(-(innerWallThickness * i)) // affected by loop
            compartementMaskBoxes(
                xSubDiv=botXSubDiv,
                ySubDiv=botYSubDiv,
                xSize=botMaskX,
                ySize=botMaskY,
        );
    };
};

module subdevBox (subdevBoxEdges=EDGES_TOP + EDGES_Z_ALL + EDGES_BOTTOM)
{
    difference() {
        cuboid(
            size=[x,y,z],
            fillet=boxFillet,
            edges=subdevBoxEdges);
        
        ymove((25 - topDevisionSize)) // offset for difference sizes tops and bots
        compartementMaskBoxesArray();
    };
    lockingNotch();
    
};

module lockingNotch()
{
    for(i=[-1:2:1]) 
    {
            xmove(i * (x/2)) 
            zmove((z/2)-(lidOverlap/2)) zmove(notchRadius)
            zscale(-0.8)
        cyl(r=notchRadius, 
            h=(y * 0.25),
            fillet=(notchRadius * 0.5),
            orient=ORIENT_Y,
            center=true);
    };
};

module lid () 
{
    difference() {
        cuboid(
            size = [
                x + outerWallThickness + lidTolerance, 
                y + outerWallThickness + lidTolerance, 
                z + outerWallThickness + lidTolerance],
                fillet = boxFillet,
                edges = EDGES_ALL,
                center = true);
        zmove(outerWallThickness)
        cuboid(
            size = [
                x + lidTolerance, 
                y + lidTolerance, 
                z + lidTolerance],
                fillet = boxFillet,
                edges = EDGES_Z_ALL + EDGES_BOTTOM);
    };
};

if(generatedPart=="box") {
    subdevBox();
};
if(generatedPart=="lid") {
    lid();
};