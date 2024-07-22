

// Which part of the design to show
generatedPart = "test"; // [box, lid, none]

/* [Basic Dimentions] */
width = 97; // 95
length = 122; // 120
height = 25; // 25

// controls the outer edges of the box, inner cavity edges are controlled in cavity settings
boxFillet=0; 
 // the rounding of the cylindrical containers
cavityFillet = 0;
cylCavityFillet = 0.25; // [0:0.05:1]

// the base thickness of the lid and lid lip
lidThickness=1.5;
// how much taller the lid is than the box, open space between box and lid interior
lidClearence = 1;
// how much room will be added between the box and the lid for 3d printing
lidTolerance = 0.6;
// the size of the protrusions that hold the lid in place
lockingRidgeSize = 0.5;
// how high the lower box/lid landing extends up the box
boxLipHeight=8; 

// the thickness of the walls that separate the cavities
wallThickness=0.5;

/* Compartment Customization */
xGrids = 2;
// Much of this customization cannot be dont in the left bar, you must edit the code directly
yGrids = 2;
// throw example size to echo to calculate the actual size of a cavity
calculateCavity = [1, 1];

// [position, x size, y size, type, fillet] 
// set the default cavities to be built on every grid space except those blocked by DoNotBuild 
cavityConfigDefault = ["pos", "box", ["grids", 1, 1]]; 

//define which grid spaces to not build default boxes on, this does not affect cavities boxes below
//useful to stop defaults from stepping on your custom boxes defined below
cavityDoNotBuild = [ 
    0,1,2,3
];

// define cavities boxes to be built anywhere on the grid with non-default settings
// it is recomended to turn off default cavities that interfere with your custom ones
// cavity positions are shown on the file itself if numberGuides are enabled
// size is in units relative to the grid size. a size of [1, 1] is the size of the default container. 2 is twice as big. 
// it is possible to make multiple custom cavities in the same position, large complex cavities are possible with box types. experement!
cavityConfig = [
    /*
    [pos, "type", ["units", x, y], [offset x, offset y], [finger tabs?, width] ]
    */
    [0, "box", ["mm", 50,25], [], [true, 10]],
    [1, "box", ["mm", 1,1], [0,-10]]
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
x = width - lidThickness - lidTolerance;
y = length - lidThickness - lidTolerance;
z = height - lidThickness - lidTolerance;

lidHeight = z + lidClearence;


lockingRidgeSpacing = ((z-boxLipHeight)*0.2);

// init grid
xGridsMM = (x - (wallThickness)) / (yGrids);// - ((wallThickness * (yGrids - 1))); //get the size of each grid
yGridsMM = (y - (wallThickness)) / (xGrids);// - ((wallThickness * (xGrids - 1)));


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

            zmove(z/2) zmove(wallThickness)
        cuboid(
            size = [
                (x - (wallThickness*2)),
                (y - (wallThickness*2)),
                z],
            fillet = boxFillet,
            edges = EDGES_Z_ALL + EDGES_BOTTOM,
            center = true);
    };
};

module FloatingNumberGuides(cavityPos) 
{
    textGuide = str(cavityPos);
    move([ // move to spot in grid
        grid[cavityPos][0] * xGridsMM,// + wallThickness,
        grid[cavityPos][1] * yGridsMM,// + wallThickness,
        0
        ])
    move([ // align with box
        -grid[0][0] * xGridsMM + (wallThickness),///2 - wallThickness),
        -grid[0][1] * yGridsMM + (wallThickness),///2 - wallThickness),
        0
        ])
    zmove(z) ymove(CalcDefaultCavitySize(2)/2) xmove(CalcDefaultCavitySize(1)/2) 
    text(textGuide, size = 5, font="Liberation Sans");
}

module CavityFingerTab (fingerTabWidth) 
{
    zmove(-z/2) zmove(wallThickness)
    cyl(
        d = fingerTabWidth,
        h = z,
        fillet1 = fingerTabWidth / 2,
        align = V_UP
    );
}

module Cavity(
    cavityPos,  
    xCavitySize,
    yCavitySize, 
    cavityType,
    cavityBoxFillet) 
{
        move([ // move to spot in grid
            grid[cavityPos][0] * xGridsMM,// + wallThickness,
            grid[cavityPos][1] * yGridsMM,// + wallThickness,
            0
        ])
        move([ // align with box
            -grid[0][0] * xGridsMM + (wallThickness),///2 - wallThickness),
            -grid[0][1] * yGridsMM + (wallThickness),///2 - wallThickness),
            0
            ])
    union() {
        if(cavityType=="box") 
        {   
            if(cavityConfig[cavityPos][4][0] != undef) // Finger tabs only on boxes
                if(cavityConfig[cavityPos][4][0] == true)
                    for(i = [
                        [xCavitySize/2, 0, 0],
                        [0, yCavitySize/2, 0],
                        [xCavitySize, yCavitySize/2 ,0],
                        [xCavitySize/2, yCavitySize ,0]
                    ]) {
                        move (i)
                        CavityFingerTab(cavityConfig[cavityPos][4][1]);
                    };

            //echo("box at pos ", cavityPos, " size = ", xCavitySize, yCavitySize);
            zmove(-z/2)
            zmove(wallThickness) // move up for floor
            cuboid(
                size=[xCavitySize, yCavitySize, z],
                fillet=cavityBoxFillet,
                edges=EDGES_Z_ALL+EDGES_BOTTOM,
                center = false);
        };
        if(cavityType=="cyl")
        {
            // make the longer of the two sides the length
            cylCavityLength = xCavitySize>yCavitySize ? xCavitySize : yCavitySize; 
            // make the other value the width
            cylCavityWidth = cylCavityLength==xCavitySize ? yCavitySize : xCavitySize;
            // orient the length along the correct axis
            cylCavityOrient = xCavitySize>yCavitySize ? ORIENT_X : ORIENT_Y;
            
            zmove(z/2)
            zscale((z*2-(wallThickness*2)) / cylCavityWidth)
            cyl(
                l = cylCavityLength,
                d = cylCavityWidth,
                orient = cylCavityOrient,
                fillet = cylCavityWidth*(cylCavityFillet),
                align = V_BACK+V_RIGHT);
        };
    };
};

function WhichAxisMM (axis) = axis == 1 ? xGridsMM : yGridsMM;

function CalcDefaultCavitySize (axis) = (cavityConfigDefault[2][axis] * WhichAxisMM(axis)) - wallThickness;

function CalcCavitySize (pos, axis) = 
    cavityConfig[pos][2][0] == "grids" ? //check the units: 1 = x, 2 = y.
        //if units == "grids" 
        cavityConfig[pos][2][axis] * (WhichAxisMM(axis))
        : //if units == "mm"
        cavityConfig[pos][2][axis];

//echo(CalcCavitySize(0, 1));

module CavityArray()
{
    for(i = [0:(xGrids * yGrids)-1]) //build defaults
    {
        # if(numberGuides==true) {
            FloatingNumberGuides(i);
        };

        // echo("loop ", i);
        cavityArrayBlocker = in_list(i, cavityDoNotBuild);

        if(cavityArrayBlocker != true) 
        { 
            //echo("building default cavity");
            Cavity(
                cavityPos = i,  
                xCavitySize = CalcDefaultCavitySize(1),
                yCavitySize = CalcDefaultCavitySize(2), 
                cavityType = cavityConfigDefault[1],
                cavityBoxFillet = cavityFillet,
                cavityBuildToggle = cavityConfigDefault[4]);
        };
        
        if(cavityArrayBlocker == true) echo("did not build default cavity ", cavityDoNotBuild[i]);
    };

    for(i = [0:len(cavityConfig)]) { // build custom cavities
        if(cavityConfig[i][0] != undef)
        {
            customCavityOffset = cavityConfig[i][3] != [] ? concat(cavityConfig[i][3], [0]) : [0,0,0];
            move(customCavityOffset)
            Cavity(
                    cavityPos = cavityConfig[i][0],  
                    xCavitySize = CalcCavitySize(i, 1),
                    yCavitySize = CalcCavitySize(i, 2), 
                    cavityType = cavityConfig[i][1],
                    cavityBoxFillet = cavityFillet);
        };
    };
}


module BoxLip (boxLipTolerance) 
{
    cuboid(
        size=[
            x + lidThickness*2 + boxLipTolerance,
            y + lidThickness*2 + boxLipTolerance,
            boxLipHeight + (boxLipTolerance*2),
        ],
        fillet=boxFillet,
        edges=EDGES_ALL
    );
};

module LockingRidge (lockingRidgeTolerance)
{
    zmove(lockingRidgeSize/2)
    cuboid(
        size = [
            x + (lockingRidgeTolerance * 2) + (lockingRidgeSize * 2),
            y + (lockingRidgeTolerance * 2) + (lockingRidgeSize * 2), 
            lockingRidgeSize
        ],
        fillet = lockingRidgeSize/2,
        center = true
    );

    /*
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
    */
}

module SubdevBox ()
{
    difference() {
        move([x/2, y/2, 0]) 
        union() {
            FilledBox();

            difference() {
                zmove(-(z/2)) zmove(boxLipHeight + (lockingRidgeSize)) zmove((z - boxLipHeight) * 0.2)
                LockingRidge(0);

                FilledBox();
            };
        };

        CavityArray();
    };
};

module AdornedBox() 
{
    if(enforceOuterWall==true) HollowBox();
    
    zmove(-(z/2)) zmove(boxLipHeight/2)
    BoxLip(lidTolerance);

}

module Box ()
{
    SubdevBox();

    move([x/2, y/2, 0])
    AdornedBox();
}

module Lid ()
{
    difference() {
            zmove(lidHeight/2) zmove(lidThickness/2) //zmove(-lidTolerance/2)
        difference() {
            cuboid( // outer shell
                    size = [
                        x + lidThickness*2 + lidTolerance, 
                        y + lidThickness*2 + lidTolerance, 
                        lidHeight + lidThickness + lidTolerance],
                        fillet = boxFillet,
                        edges = EDGES_ALL,
                        center = true);

            zmove(-lidThickness) // make room for floor
            cuboid( // inner mask
                size = [
                    x + lidTolerance*2, 
                    y + lidTolerance*2, 
                    lidHeight + lidTolerance*2],
                    fillet = boxFillet,
                    edges = EDGES_Z_ALL + EDGES_BOTTOM);
        };
            zmove(z/2)
            scale([((x + lidTolerance*2) / x), ((y + lidTolerance*2) / y), 1]) 
        Box();
    };

            /*
            zmove(-(lidHeight/2)) zmove(boxLipHeight/2) 
            zmove(-lidTolerance) zmove(-lidThickness)
            BoxLip(lidTolerance);

            zmove(-(lidHeight/2)) zmove(boxLipHeight/2) zmove((z - boxLipHeight) * 0.2)
            //zmove(-(z - boxLipHeight) * 0.2)
            LockingRidge(lidTolerance);
            */
    //};
}

module EchoInformation() 
{
    echo();

    xCavitySizeEcho = (1 * xGridsMM) - wallThickness*2;
    yCavitySizeEcho = (1 * yGridsMM) - wallThickness*2;

    echo("----- Interior Cavity Dimentions -----");
        // default cavity
        echo("The size of a [1, 1] cavity is ", xCavitySizeEcho, " by ", yCavitySizeEcho, " by ", z-lidThickness);

        // custom calculations
        if(calculateCavity==undef) echo("To calculate a larger box please enter a size into cavlulateCavity");
        if(calculateCavity!=undef) {
            echo(
                "The size of a ", calculateCavity, " cavity is ", 
                calculateCavity[0] * xCavitySizeEcho, " by ", calculateCavity[1] * yCavitySizeEcho, " by ", z-lidThickness);
        };

    echo();
}

EchoInformation();

if(generatedPart=="box") {
    //zmove(z/2)
    //zrot(-90) // rotate for better readability
    Box();
};
if(generatedPart=="lid") {
    zflip()
    Lid();
};
if(generatedPart=="test"){
    //CavityArray();
    SubdevBox();


    /* Cavity(
            cavityPos = 1,  
            xCavitySize = 1,
            yCavitySize = 1, 
            cavityType = "box",
            cavityBoxFillet = 1); */
};
if(generatedPart=="none") {}