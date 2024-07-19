

generatedPart = "test"; //box or lid or none

x=100;
y=200;
z=20;

// Cavity Definition
xGrids = 6;
yGrids = 10;

// [position, x size, y size, type, fillet] 
// set the default cavities to be built on every grid space except those blocked by DoNotBuild 
cavityArrayConfigDefault = ["-", 1, 1, "box", 0]; 

//define which grid spaces to not build default boxes on, this does not affect cavities boxes below
cavityDoNotBuild = [ 
    0, 1, 2, 3, 4
];

// define cavities boxes to be built anywhere on the grid with non-default settings
// it is recomended to turn off default cavities that interfere with your custom ones
cavityArrayConfig = [
    //[01, 2, 3, "box", 0],
];

enforceOuterWall = false;
boxFillet=1;

boxLipHeight=5; 
lidHeight = 30;
lidTolerance = 0.8;
lockingRidgeSize = 1;

outerWallThickness=1;
innerWallThickness=0.5;
innerWallHeight=z;

//////////////////////////////////////

include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>
use <BOSL/math.scad>

$fa = 1;
$fs = 0.4;

lockingRidgeSpacing = ((z-boxLipHeight)*0.2);

// init grid
xGridsMM = (x - (outerWallThickness*4)) / (yGrids);// - ((innerWallThickness * (yGrids - 1))); //get the size of each grid
yGridsMM = (y - (outerWallThickness*4)) / (xGrids);// - ((innerWallThickness * (xGrids - 1)));


// create a vector of vectors describing every point in the grid
grid = [for (ix=[1:(yGrids)]) for(iy=[1:xGrids]) [(ix), (iy), 0]];
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
            size = [
                (x - (outerWallThickness/2)),
                (y - (outerWallThickness/2)),
                z],
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
    xCavitySizeMM = (xCavitySize * xGridsMM) - innerWallThickness;// - ((innerWallThickness * (xGrids - 1)));
    yCavitySizeMM = (yCavitySize * yGridsMM) - innerWallThickness;// - ((innerWallThickness * (yGrids - 1)));


        move([ // move to spot in grid
            grid[cavityPos][0] * xGridsMM + innerWallThickness,
            grid[cavityPos][1] * yGridsMM + innerWallThickness,
            0
        ])
        move([ // align with box
            -grid[0][0] * xGridsMM + (outerWallThickness - innerWallThickness),
            -grid[0][1] * yGridsMM + (outerWallThickness - innerWallThickness),
            0
            ])
        zmove(outerWallThickness) // move up for floor
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
    for(i = [0:(xGrids * yGrids)-1]) //build defaults
    {
        //echo("loop ", i);
        cavityArrayBlocker = in_list(i, cavityDoNotBuild);
        //echo("block cavity = ", cavityArrayBlocker);

        if(cavityArrayBlocker != true) 
        { 
            //echo("building default cavity");
            Cavity(
                cavityPos = i,  
                xCavitySize = cavityArrayConfigDefault[1],
                yCavitySize = cavityArrayConfigDefault[2], 
                cavityType = cavityArrayConfigDefault[3],
                cavityBoxFillet = cavityArrayConfigDefault[4],
                cavityBuildToggle = cavityArrayConfigDefault[5]);
        };
        
        if(cavityArrayBlocker == true) echo("did not build default cavity ", cavityDoNotBuild[i]);

    for(i = [0:len(cavityArrayConfig)]) {
        if(cavityArrayConfig[i][0] != undef)
        {
            //echo("building custom cavity");
            Cavity(
                    cavityPos = cavityArrayConfig[i][0],  
                    xCavitySize = cavityArrayConfig[i][1],
                    yCavitySize = cavityArrayConfig[i][2], 
                    cavityType = cavityArrayConfig[i][3],
                    cavityBoxFillet = cavityArrayConfig[i][4],
                    cavityBuildToggle = cavityArrayConfig[i][5]);
        };
    };
};
}

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

module AdornedBox ()
{
    FilledBox();

    if(enforceOuterWall==true) HollowBox();
    
    zmove(-(z/2)) zmove(boxLipHeight/2)
    BoxLip(0);

    zmove(-(z/2)) zmove(boxLipHeight + lockingRidgeSize)
    LockingRidge(0);
}

module SubdevBox ()
{
    difference() {
        move([x/2, y/2, 0]) AdornedBox();

        move([
            outerWallThickness,
            outerWallThickness,
            -(z/2)])
        CavityArray();
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