include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

$fa = 1;
$fs = 0.4;

generatedPart = "test"; //box or Lid

x=100;
y=200;
z=20;

// Cavity Definition

xGrids = 3;
yGrids = 3;

totalCavities = 16;
cavityArrayConfig = [
    /* 
    ex. [starting pos, x size, y size, type, fillet, build toggle] */
    [1, 1, 1, "box", 0, true],
    [2, 1, 1, "box", 0, true],
    [3, 1, 1, "box", 0, true],
    [4, 1, 1, "box", 0, true],
    [5, 1, 1, "box", 0, true],
    [6, 1, 1, "box", 0, true],
    [7, 1, 1, "box", 0, true],
    [8, 1, 1, "box", 0, true],
    [9, 1, 1, "box", 0, true],
    [10, 1, 1, "box", 0, true],
    [11, 1, 1, "box", 0, true],
    [12, 1, 1, "box", 0, true],
    [13, 1, 1, "box", 0, true],
    [14, 1, 1, "box", 0, true],
    [15, 1, 1, "box", 0, true],
    [16, 1, 1, "box", 0, true]
];

enforceOuterWall = true:

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

topXSubDiv=1;
topYSubDiv=1;

botXSubDiv=3;
botYSubDiv=2;

//topMaskX = ((x - ((outerWallThickness * 2)+(innerWallThickness * (topXSubDiv - 1)))) / topXSubDiv); // two outer walls and n-1 inner walls
//topMaskY = ((topDevisionSize - ((outerWallThickness)+(innerWallThickness * (topYSubDiv)))) / topYSubDiv); // 1.5 outer walls and n-1 inner walls

// botMaskX = botDevision==true ? ((x - ((outerWallThickness * 2)+(innerWallThickness * (botXSubDiv - 1)))) / botXSubDiv) : undef; // two outer walls and n-1 inner walls
// botMaskY = botDevision==true ? ((botDevisionSize - ((outerWallThickness)+(innerWallThickness * (botYSubDiv)))) / botYSubDiv) : undef; // 1 outer wall and n inner walls 

// init grid
xGridsMM = (x / xGrids); //get the size of each grid
yGridsMM = (y / yGrids);

// create a vector of vectors describing every point in the grid
grid = [for (ix=[1:(yGrids)]) for(iy=[1:xGrids]) [(ix * xGridsMM) + (xGridsMM/2), (iy * yGridsMM) + (yGridsMM/2), 0]];
echo(grid);


module FilledBox()
{
    subdevBoxEdges = EDGES_TOP + EDGES_Z_ALL + EDGES_BOTTOM;
    cuboid(
        size=[x,y,z],
        fillet=boxFillet,
        edges=subdevBoxEdges);
}

module HollowBox() {
    difference() 
    {
        FilledBox();

            zmove(z/2) zmove(outerWallThickness)
        cuboid(
            size[
                x = x - (outerWallThickness/2),
                y = y - (outerWallThickness/2),
                z = z],
            fillet = boxFillet,
            edges = EDGES_Z_ALL + EDGES_BOTTOM,
            center = true);
    };
};

module Cavity(
    cavityPos,  
    xCavitySize = 1,
    yCavitySize = 1, 
    cavityType = "cyl",
    cavityBoxFillet = 0,
    cavityBuildToggle = true) 
{
    // calculate size of box accounting for wall thicknesses and cavity size settings
    xCavitySizeMM = (xCavitySize * xGridsMM) - (outerWallThickness * 2) - (innerWallThickness * (xGrids - 1));
    yCavitySizeMM = (yCavitySize * yGridsMM) - (outerWallThickness * 2) - (innerWallThickness * (yGrids - 1));


        zmove(outerWallThickness)
        move(grid[cavityPos])
        xmove(-(x) + outerWallThickness) ymove((-y) + outerWallThickness)
    if(cavityBuildToggle==1)
    {
            
        if(cavityType=="box") 
        {
            cuboid(
                size=[xCavitySizeMM, yCavitySizeMM, z],
                fillet=cavityBoxFillet,
                edges=EDGES_Z_ALL+EDGES_BOTTOM,
                center = false);
        };
        if(cavityType=="cyl")
        {
            // make the longer of the two sides the length
            cylCavityLength = xCavitySizeMM>yCavitySizeMM ? xCavitySizeMM : yCavitySizeMM; 
            // make the other value the width
            cylCavityWidth = cylCavityLength==xCavitySizeMM ? yCavitySizeMM : xCavitySizeMM;
            // orient the length along the correct axis
            cylCavityOrient = xCavitySizeMM>yCavitySizeMM ? ORIENT_X : ORIENT_Y;
            
            cyl(
                l = cylCavityLength,
                d = cylCavityWidth,
                orient = cylCavityOrient,
                fillet = z*0.7);
        };
    };
};

module CavityArray()
{
    cavityArrayLoopLen = (xGrids*yGrids)<totalCavities ? (xGrids*yGrids) : totalCavities;

    //move(x = -(x/2), y = -(y/2), z = 0) move(x = -xGridsMM, y = -yGridsMM, z = 0)
    for(i = [0:(cavityArrayLoopLen)-1]) 
    {
        Cavity(
            cavityPos = (cavityArrayConfig[i][0])-1,  
            xCavitySize = cavityArrayConfig[i][1],
            yCavitySize = cavityArrayConfig[i][2], 
            cavityType = cavityArrayConfig[i][3],
            cavityBoxFillet = cavityArrayConfig[i][4],
            cavityBuildToggle = cavityArrayConfig[i][5]);
        echo(
            cavityArrayConfig[i][0],
            cavityArrayConfig[i][1],
            cavityArrayConfig[i][2],
            cavityArrayConfig[i][3],
            cavityArrayConfig[i][4]);
        
    };
}




/*
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
*/

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
        

        /*
        ymove((25 - topDevisionSize)) // offset for difference sizes tops and bots
        zmove(-(z/2)) // re-alaign with center, jank
        CompartementMaskBoxesArray();
        */
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
    CavityArray();

    /* Cavity(
            cavityPos = 1,  
            xCavitySize = 1,
            yCavitySize = 1, 
            cavityType = "box",
            cavityBoxFillet = 1); */
};
if(generatedPart=="none") {}