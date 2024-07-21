

// Which part of the design to show
generatedPart = "lid"; // [box, lid, none]

/* [Basic Dimentions] */
width = 50; // 95
length = 50; // 120
height = 15; // 25

// controls the outer edges of the box, inner cavity edges are controlled in cavity settings
boxFillet=0; 
 // the rounding of the cylindrical containers
cylCavityFillet = 0.25; // [0:0.05:1]

// how high the lower box/lid landing extends up the box
boxLipHeight=5; 
// how tall the lid is, must be as tall or taller than the height of the box "z"
lidHeight = 15;
// how much room will be added between the box and the lid for 3d printing
lidTolerance = 0.8;
// the size of the protrusions that hold the lid in place
lockingRidgeSize = 1.6;

// the thickness of the outer wall and floor
outerWallThickness=2;
// the thickness of the walls that separate the cavities
innerWallThickness=0.5;

/* Compartment Customization */
xGrids = 1;
// Much of this customization cannot be dont in the left bar, you must edit the code directly
yGrids = 1;
// throw example size to echo to calculate the actual size of a cavity
calculateCavity = [1, 1];

// [position, x size, y size, type, fillet] 
// set the default cavities to be built on every grid space except those blocked by DoNotBuild 
cavityArrayConfigDefault = ["-", 1, 1, "box", boxFillet]; 

//define which grid spaces to not build default boxes on, this does not affect cavities boxes below
//useful to stop defaults from stepping on your custom boxes defined below
cavityDoNotBuild = [ 
    
];

// define cavities boxes to be built anywhere on the grid with non-default settings
// it is recomended to turn off default cavities that interfere with your custom ones
// cavity positions are shown on the file itself if numberGuides are enabled
// size is in units relative to the grid size. a size of [1, 1] is the size of the default container. 2 is twice as big. 
// it is possible to make multiple custom cavities in the same position, large complex cavities are possible with box types. experement!
cavityArrayConfig = [
    //[position, x size, y size, "type", boxfillet]
    //[01, 2, 3, "box", 0],
    //[01, 2, 1, "box", 0],
];

/* [Additional Options] */
numberGuides = true;
enforceOuterWall = false;

//////////////////////////////////////

include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>
use <BOSL/math.scad>

$fa = 1;
$fs = 0.4;

// process variables to ensure accuracy in outermost dimentions
x = width - outerWallThickness - lidTolerance;
y = length - outerWallThickness - lidTolerance;
z = height - outerWallThickness - lidTolerance;

lockingRidgeSpacing = ((z-boxLipHeight)*0.2);

// init grid
xGridsMM = (x - (outerWallThickness*2)) / (yGrids);// - ((innerWallThickness * (yGrids - 1))); //get the size of each grid
yGridsMM = (y - (outerWallThickness*2)) / (xGrids);// - ((innerWallThickness * (xGrids - 1)));


// create a vector of vectors describing every point in the grid
grid = [for (ix=[1:(yGrids)]) for(iy=[1:xGrids]) [(ix), (iy), 0]];
// echo(grid);


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
    xCavitySizeMM = (xCavitySize * xGridsMM) - innerWallThickness*2;
    yCavitySizeMM = (yCavitySize * yGridsMM) - innerWallThickness*2;


        move([ // move to spot in grid
            grid[cavityPos][0] * xGridsMM + innerWallThickness,
            grid[cavityPos][1] * yGridsMM + innerWallThickness,
            0
        ])
        move([ // align with box
            -grid[0][0] * xGridsMM + (outerWallThickness),///2 - innerWallThickness),
            -grid[0][1] * yGridsMM + (outerWallThickness),///2 - innerWallThickness),
            0
            ])
    union() {
        if(cavityType=="box") 
        {
            zmove(-z/2)
            zmove(outerWallThickness) // move up for floor
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
            
            zmove(z/2)
            zscale((z*2-(outerWallThickness*2)) / cylCavityWidth)
            cyl(
                l = cylCavityLength,
                d = cylCavityWidth,
                orient = cylCavityOrient,
                fillet = cylCavityWidth*(cylCavityFillet),
                align = V_BACK+V_RIGHT);
        };
        # if(numberGuides==true) {
            textGuide = str(cavityPos);
            zmove(z) ymove(yCavitySizeMM/2) xmove(xCavitySizeMM/2) 
            text(textGuide, size = 5, font="Liberation Sans");
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
        cyl(
            d = x + lockingRidgeSize + lockingRidgeTolerance,
            h = lockingRidgeSize,
            fillet = lockingRidgeSize/2
        );
        yscale(y*2) FilledBox();
    };

    //y wall edges
    xscale(1)
    difference () {
        cyl(
            d = y + lockingRidgeSize + lockingRidgeTolerance,
            h = lockingRidgeSize,
            fillet = lockingRidgeSize/2
        );
        xscale(x*2) FilledBox();
    };
}

module AdornedBox ()
{
    FilledBox();

    if(enforceOuterWall==true) HollowBox();
    
    zmove(-(z/2)) zmove(boxLipHeight/2)
    BoxLip(lidTolerance);

    zmove(-(z/2)) zmove(boxLipHeight + (lockingRidgeSize * 2))
    LockingRidge(0);
}

module SubdevBox ()
{
    difference() {
        move([x/2, y/2, 0]) AdornedBox();

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
            zmove(-(lidHeight/2)) zmove(boxLipHeight/2) zmove(-lidTolerance) zmove(-outerWallThickness)
            BoxLip(lidTolerance);

            zmove(-(lidHeight/2)) zmove(boxLipHeight + (lockingRidgeSize*2) - lidTolerance - outerWallThickness)
            union() {
                LockingRidge(0);
                LockingRidge(lidTolerance);
            };
    };
}

module EchoInformation() 
{
    echo();

    xCavitySizeEcho = (1 * xGridsMM) - innerWallThickness*2;
    yCavitySizeEcho = (1 * yGridsMM) - innerWallThickness*2;

    echo("----- Interior Cavity Dimentions -----");
        // default cavity
        echo("The size of a [1, 1] cavity is ", xCavitySizeEcho, " by ", yCavitySizeEcho, " by ", z-outerWallThickness);

        // custom calculations
        if(calculateCavity==undef) echo("To calculate a larger box please enter a size into cavlulateCavity");
        if(calculateCavity!=undef) {
            echo(
                "The size of a ", calculateCavity, " cavity is ", 
                calculateCavity[0] * xCavitySizeEcho, " by ", calculateCavity[1] * yCavitySizeEcho, " by ", z-outerWallThickness);
        };

    echo();
}

EchoInformation();

if(generatedPart=="box") {
    //zmove(z/2)
    //zrot(-90) // rotate for better readability
    SubdevBox();
};
if(generatedPart=="lid") {
    // zflip()
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