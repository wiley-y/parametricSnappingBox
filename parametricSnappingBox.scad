include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

$fa = 1;
$fs = 0.4;

x=50;
y=50;
z=20;
lidOverlap=10;
botDevision = false; 
topDevisionSize = botDevision==true ? 25 : x;
botDevisionSize= x - topDevisionSize;
boxFillet=1;
compartementFillet=2;
outerWallThickness=1;
innerWallThickness=1;
innerWallHeight=z;
cavityType="scoop"; // box or scoop
scoopDepthScale = 1.3;
topXSubDiv=5;
topYSubDiv=3;
botXSubDiv=3;
botYSubDiv=2;
notchRadius=0.6;

topMaskX = ((x - ((outerWallThickness * 2)+(innerWallThickness * (topXSubDiv - 1)))) / topXSubDiv); // two outer walls and n-1 inner walls
topMaskY = ((topDevisionSize - ((outerWallThickness)+(innerWallThickness * (topYSubDiv)))) / topYSubDiv); // 1.5 outer walls and n-1 inner walls

botMaskX = botDevision==true ? ((x - ((outerWallThickness * 2)+(innerWallThickness * (botXSubDiv - 1)))) / botXSubDiv) : undef; // two outer walls and n-1 inner walls
botMaskY = botDevision==true ? ((botDevisionSize - ((outerWallThickness)+(innerWallThickness * (botYSubDiv)))) / botYSubDiv) : undef; // 1 outer wall and n inner walls 


/*
module innerBoxMask(x, y, z , wallThickness)
{
    for(i=[
        [(x - wallThickness),0,0],
        [(x - wallThickness)*-1,0,0],
        [0,(y - wallThickness),0],
        [0,(y - wallThickness)*-1,0]]) 
    {
        translate(i)
        cuboid(size=[x,y,z], edges=EDGES_TOP, center=true);
    }
};
*/

module lockingNotch()
{
    for(i=[-1:2:1]) 
    {
            xmove(i * (x/2)) zmove((z/2)-(lidOverlap/2)) zmove(notchRadius)
            zscale(-0.8)
        cyl(r=notchRadius, 
            h=(y * 0.25),
            fillet=(notchRadius * 0.5),
            orient=ORIENT_Y,
            center=true);
    };
};

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

module compartementMaskScoops (xSubDiv, ySubDiv, xSize, ySize) 
{
    for(i=[0:1:(xSubDiv-1)])
            xmove(-(x/2)) xmove((xSize / 2) + outerWallThickness) //starting position
            xmove(xSize * i) xmove(innerWallThickness * i) //loop changes this
            zmove(z/2) zmove(outerWallThickness) //make room for floor
        scale(0.1)
        scale([xSize, ySize, (z * scoopDepthScale)])
        sphere(
            d=10,
            center=true
        );
};

module compartementMaskScoopsArray ()
{
    for(i = [0:1:(topYSubDiv - 1)])
        ymove((topMaskY / 2)) ymove(innerWallThickness / 2) // starting position
        ymove(topMaskY * i) ymove(innerWallThickness * i) // affected by loop
        compartementMaskScoops(
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
            compartementMaskScoops(
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
        if(cavityType=="box") {
            compartementMaskBoxesArray();
            };
        if(cavityType=="scoop") {
            compartementMaskScoopsArray();
            };
    };
    lockingNotch();
    
};

/*
module boxShell(
        wallThickness,
        floorThickness,
        boxFillet,
        edges=EDGES_TOP + EDGES_Z_ALL + EDGES_BOTTOM,
        center=true )
{
    zmove(z/2) // move bottom to be at zero
    intersection() { // Creates shell (ineficient but fine, simple difference would be better)
        cuboid(size=[x,y,z], fillet=boxFillet, edges=edges, center=center);
        innerBoxMask(
            x=x,
            y=y,
            z=z,
            wallThickness=wallThickness);
    };
    // create floor
    zmove(floorThickness/2) cuboid(size=[x,y,floorThickness], fillet=boxFillet, edges=edges, center=true);
};
*/

/*
topMaskX = ((x - (outerWallThickness * 2)) / topXSubDiv);
topMaskY = ((y - (outerWallThickness * 2)) / topYSubDiv);
compartementMaskBoxes (xSubDiv=4, ySubDiv=4, moveAmount=0);
*/

subdevBox ();


/*
boxShell(
    wallThickness=0.5,
    floorThickness=2,
    boxFillet=1
    );


lockingNotch(
    notchRadius=0.5,
    lidOverlap=4
);
*/