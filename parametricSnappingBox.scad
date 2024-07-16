include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

$fa = 1;
$fs = 0.4;

x=50;
y=50;
z=20;
lidOverlap=undef;
topDevisionSize= x / 2;
botDevisionSize= x - topDevisionSize;
boxFillet=1;
compartementFillet=0;
outerWallThickness=1;
innerWallThickness=1;
innerWallHeight=z;
topDevisionType="square"; // Square or Scoop
topXSubDiv=4;
topYSubDiv=1;
botDevisionType="square"; // Square or Scoop
botXSubDiv=3;
botYSubDiv=1;

topMaskX = ((x - ((outerWallThickness * 2)+(innerWallThickness * (topXSubDiv - 1)))) / topXSubDiv); // two outer walls and n-1 inner walls
topMaskY = ((topDevisionSize - ((outerWallThickness * 1.5)+(innerWallThickness * (topYSubDiv - 1)))) / topYSubDiv); // 1.5 outer walls and n-1 inner walls


botMaskX = ((x - ((outerWallThickness * 2)+(innerWallThickness * (botXSubDiv - 1)))) / botXSubDiv); // two outer walls and n-1 inner walls
botMaskY = ((topDevisionSize - ((outerWallThickness * 1.5)+(innerWallThickness * (botYSubDiv - 1)))) / botYSubDiv); // 1.5 outer walls and n-1 inner walls 

topDevisionCenter = (x/2) - (topDevisionSize / 2);
botDevisionCenter = -((x/2) - (botDevisionSize / 2));

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

module lockingNotch(radius)
{
    for(i=[-1:2:1]) 
    {
            ymove(i * (y/2)) zmove(z-(lidOverlap/2)) zmove(radius)
            zscale(-0.5)
        cyl(r=radius, 
            h=(x * 0.25),
            fillet=(radius * 0.5),
            orient=ORIENT_X,
            center=true);
    }
}

module compartementMaskBoxes (xSubDiv, ySubDiv, xSize, ySize, moveAmount) 
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
}

module subdevBox (subdevBoxEdges=EDGES_TOP + EDGES_Z_ALL + EDGES_BOTTOM)
{
    difference() {
        cuboid(
            size=[x,y,z],
            fillet=boxFillet,
            edges=subdevBoxEdges);
        
        ymove(topDevisionCenter) ymove(-(outerWallThickness/2)) // move to upper portion and make room for wall
        ymove(-(topMaskY/2)) // starting position for y stacking
        compartementMaskBoxes(
            xSubDiv=topXSubDiv,
            ySubDiv=topYSubDiv,
            xSize=topMaskX,
            ySize=topMaskY,
            moveAmount=botDevisionCenter
        );

        ymove(botDevisionCenter) ymove(outerWallThickness/2) // move to lower portion and make room for wall
        compartementMaskBoxes(
            xSubDiv=botXSubDiv,
            ySubDiv=botYSubDiv,
            xSize=botMaskX,
            ySize=botMaskY,
            moveAmount=botDevisionCenter
        );
    };
    
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
    radius=0.5,
    lidOverlap=4
);
*/