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

lidOverlap=z; // lidOverlap = z means 100% coverage
lidHeight = 30;
lidTolerance = 0.8;
notchRadius=0.6;
fingerHoleSize = 10;
fingerHoleType = "all"; // edges, or all

botDevision = false; 
topDevisionSize = botDevision==true ? 25 : x;
botDevisionSize= x - topDevisionSize;

boxFillet=1;
compartementFillet=0;

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
        cuboid( // outer shell
            size = [
                x + outerWallThickness + lidTolerance, 
                y + outerWallThickness + lidTolerance, 
                lidHeight + outerWallThickness + lidTolerance],
                fillet = boxFillet,
                edges = EDGES_ALL,
                center = true);

        zmove(-outerWallThickness) 
        cuboid( // inner mask
            size = [
                x + lidTolerance, 
                y + lidTolerance, 
                lidHeight + lidTolerance],
                fillet = boxFillet,
                edges = EDGES_Z_ALL + EDGES_BOTTOM);

        zmove(-((lidHeight/2)+lidTolerance))
        zmove(z/2)
        lockingNotch(); // notch indents for box to fit into

        cylRotCopies = fingerHoleType=="all" ? 8 : 4;
        zmove(-((lidHeight/2)+lidTolerance))
        zrot_copies(n=cylRotCopies)
        cyl(d = fingerHoleSize, h = x+y, orient = ORIENT_Y, center = true);
    };
    
    if(lidHeight > z) //add reverse entry notch to block over-insertion to large lids and allow for the lid to be used as a tray ala oath orginizers
    {
        for(i = [0:1:1])
            zrot(90 * i)
            zmove(-((lidHeight/2)+lidTolerance))
            zmove(z)
            lockingNotch();
    };
};

if(generatedPart=="box") {
    zmove(z/2)
    subdevBox();
};
if(generatedPart=="lid") {
    lid();
};
if(generatedPart=="test"){
    subdevBox();

    lid();
}