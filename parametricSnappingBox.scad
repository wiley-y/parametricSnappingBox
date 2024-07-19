include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

/*
Test one : Lid needs more boxLipTolerance, notch needs to be a little bigger, reverse insertion notch laos needs to be bigger. box should not be this small. 

todo : 
    fillet cylender type cavities
    better locking mechanism (just a little bit, it should not be too tough)

    i want the Lid locking and Lid removal to be better, the Lid overlap should come down onto a lip as big as the Lid, the Lid locking should be a rounded square ridge
    
*/

$fa = 1;
$fs = 0.4;

generatedPart = "none"; //box or Lid

x=100;
y=200;
z=20;

boxLipHeight=5; 
lidHeight = 30;
lidTolerance = 0.8;
lockingRidgeSize = 1;
lockingRidgeSpacing = ((z-boxLipHeight)*0.2);
//notchRadius=0.6;
//fingerHoleSize = 8;
//fingerHoleType = "all"; // edges, or all

botDevision = false; 
topDevisionSize = botDevision==true ? 25 : x;
botDevisionSize= x - topDevisionSize;

boxFillet=1;
compartementFillet=0;

outerWallThickness=1;
innerWallThickness=1;
innerWallHeight=z;

xGrids = 3;
yGrids = 3;


topXSubDiv=1;
topYSubDiv=1;

botXSubDiv=3;
botYSubDiv=2;

topMaskX = ((x - ((outerWallThickness * 2)+(innerWallThickness * (topXSubDiv - 1)))) / topXSubDiv); // two outer walls and n-1 inner walls
topMaskY = ((topDevisionSize - ((outerWallThickness)+(innerWallThickness * (topYSubDiv)))) / topYSubDiv); // 1.5 outer walls and n-1 inner walls

botMaskX = botDevision==true ? ((x - ((outerWallThickness * 2)+(innerWallThickness * (botXSubDiv - 1)))) / botXSubDiv) : undef; // two outer walls and n-1 inner walls
botMaskY = botDevision==true ? ((botDevisionSize - ((outerWallThickness)+(innerWallThickness * (botYSubDiv)))) / botYSubDiv) : undef; // 1 outer wall and n inner walls 


xGridsMM = (x / xGrids); //get the size of each grid
yGridsMM = (y / yGrids);

// create a vector of vectors describing every point in the grid
grid = [for (ix=[1:(yGrids)]) for(iy=[1:xGrids]) [(ix * xGrids) + (xGrids/2), (iy * xGrids) + (xGrids/2), 0]];
echo(grid);

for(i = [0:(xGrids * yGrids)-1]) 
{
    move(grid[i])
    zmove(z/2)
    cyl(r=1, h=z, center=true);
}

module FilledBox ()
{
    subdevBoxEdges = EDGES_TOP + EDGES_Z_ALL + EDGES_BOTTOM;
    cuboid(
        size=[x,y,z],
        fillet=boxFillet,
        edges=subdevBoxEdges);
}

module CompartementMaskBoxes (xSubDiv, ySubDiv, xSize, ySize) 
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

module CompartementMaskBoxesArray ()
{
    for(i = [0:1:(topYSubDiv - 1)])
        ymove((topMaskY / 2)) ymove(innerWallThickness / 2) // starting position
        ymove(topMaskY * i) ymove(innerWallThickness * i) // affected by loop
        CompartementMaskBoxes(
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
            CompartementMaskBoxes(
                xSubDiv=botXSubDiv,
                ySubDiv=botYSubDiv,
                xSize=botMaskX,
                ySize=botMaskY,
        );
    };
};

module BoxLip (boxLipTolerance) 
{
    cuboid(
        size=[
            x + outerWallThickness + boxLipTolerance,
            y + outerWallThickness + boxLipTolerance,
            boxLipHeight + (boxLipTolerance*2),
        ],
        fillet=boxFillet,
        edges=EDGES_ALL
    );
};

module LockingRidge (lockingRidgeTolerance)
{
    //x wall edges
    yscale(1)
    difference () {
        torus( 
            od = x + lockingRidgeSize + lockingRidgeTolerance,
            id = x + lockingRidgeTolerance
        );
        yscale(y*2) FilledBox();
    };

    //y wall edges
    xscale(1)
    difference () {
        torus( 
            od = y + lockingRidgeSize + lockingRidgeTolerance,
            id = y + lockingRidgeTolerance
        );
        xscale(x*2) FilledBox();
    };
}

module SubdevBox ()
{
    difference() {
        union() {
            FilledBox();
            
            zmove(-(z/2)) zmove(boxLipHeight/2)
            BoxLip(0);
        };
        
        ymove((25 - topDevisionSize)) // offset for difference sizes tops and bots
        zmove(-(z/2)) // re-alaign with center, jank
        CompartementMaskBoxesArray();
    };
    zmove(-(z/2)) zmove(boxLipHeight + lockingRidgeSize)
    LockingRidge(0);
};

module Lid ()
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

            zmove(-outerWallThickness) // make room for floor
            cuboid( // inner mask
                size = [
                    x + lidTolerance, 
                    y + lidTolerance, 
                    lidHeight + lidTolerance],
                    fillet = boxFillet,
                    edges = EDGES_Z_ALL + EDGES_BOTTOM);
            zmove(-(lidHeight/2)) zmove(boxLipHeight/2) zmove(-lidTolerance)
            BoxLip(lidTolerance);

            zmove(-(lidHeight/2)) zmove(boxLipHeight + lockingRidgeSize)
            LockingRidge(lidTolerance);
    };
}


/* old Lid and notch system
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

    module Lid () 
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
        
        if(lidHeight > z) //add reverse entry notch to block over-insertion to large lids and allow for the Lid to be used as a tray ala oath orginizers
        {
            for(i = [0:1:1])
                zrot(90 * i)
                zmove(-((lidHeight/2)+lidTolerance))
                zmove(z)
                lockingNotch();
        };
    };
*/

if(generatedPart=="box") {
    //zmove(z/2)
    SubdevBox();
};
if(generatedPart=="lid") {
    //zflip()
    Lid();
};
if(generatedPart=="test"){
    SubdevBox();
    LockingRidge(0);
};
if(generatedPart=="none") {}