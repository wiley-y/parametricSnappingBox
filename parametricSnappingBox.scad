include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

$fa = 1;
$fs = 0.4;

generatedPart = "box"; //box or Lid

x=100;
y=200;
z=20;

// Cavity Definition

xGrids = 6;
yGrids = 10;

totalCavities = 65;
cavityArrayConfig = [
    /* 
    ex. [starting pos, x size, y size, type, fillet, build toggle] */
    [01, 2, 3, "box", 0, 1],
    [01, 5, 2, "box", 0, 1],
    [02, 1, 1, "box", 0, 1],
    [03, 1, 1, "box", 0, 1],
    [04, 1, 1, "box", 0, 1],
    [05, 1, 1, "box", 0, 1],
    [06, 1, 1, "box", 0, 1],
    [07, 1, 1, "box", 0, 1],
    [08, 1, 1, "box", 0, 1],
    [09, 1, 1, "box", 0, 1],
    [10, 1, 1, "box", 0, 1],
    [11, 1, 1, "box", 0, 1],
    [12, 1, 1, "box", 0, 1],
    [13, 1, 1, "box", 0, 1],
    [14, 1, 1, "box", 0, 1],
    [15, 1, 1, "box", 0, 1],
    [16, 1, 1, "box", 0, 1],
    [17, 1, 1, "box", 0, 1],
    [18, 1, 1, "box", 0, 1],
    [19, 1, 1, "box", 0, 1],
    [20, 1, 1, "box", 0, 1],
    [21, 1, 1, "box", 0, 1],
    [22, 1, 1, "box", 0, 1],
    [23, 1, 1, "box", 0, 1],
    [24, 1, 1, "box", 0, 1],
    [25, 1, 1, "box", 0, 1],
    [26, 1, 1, "box", 0, 1],
    [27, 1, 1, "box", 0, 1],
    [28, 1, 1, "box", 0, 1],
    [29, 1, 1, "box", 0, 1],
    [30, 1, 1, "box", 0, 1],
    [31, 1, 1, "box", 0, 1],
    [32, 1, 1, "box", 0, 1],
    [33, 1, 1, "box", 0, 1],
    [34, 1, 1, "box", 0, 1],
    [35, 1, 1, "box", 0, 1],
    [36, 1, 1, "box", 0, 1],
    [37, 1, 1, "box", 0, 1],
    [38, 1, 1, "box", 0, 1],
    [39, 1, 1, "box", 0, 1],
    [40, 1, 1, "box", 0, 1],
    [41, 1, 1, "box", 0, 1],
    [42, 1, 1, "box", 0, 1],
    [43, 1, 1, "box", 0, 1],
    [44, 1, 1, "box", 0, 1],
    [45, 1, 1, "box", 0, 1],
    [46, 1, 1, "box", 0, 1],
    [47, 1, 1, "box", 0, 1],
    [48, 1, 1, "box", 0, 1],
    [49, 1, 1, "box", 0, 1],
    [50, 1, 1, "box", 0, 1],
    [51, 1, 1, "box", 0, 1],
    [52, 1, 1, "box", 0, 1],
    [53, 1, 1, "box", 0, 1],
    [54, 1, 1, "box", 0, 1],
    [55, 1, 1, "box", 0, 1],
    [56, 1, 1, "box", 0, 1],
    [57, 1, 1, "box", 0, 1],
    [58, 1, 1, "box", 0, 1],
    [59, 1, 1, "box", 0, 1],
    [60, 1, 1, "box", 0, 1]
];

enforceOuterWall = false;

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
innerWallThickness=0.5;
innerWallHeight=z;

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
    // cavityArrayLoopLen = (xGrids*yGrids)<totalCavities ? (xGrids*yGrids) : totalCavities;

    for(i = [0:(totalCavities)-1]) 
    {
        if(cavityArrayConfig[i][0] != undef) {
            Cavity(
                cavityPos = (cavityArrayConfig[i][0])-1,  
                xCavitySize = cavityArrayConfig[i][1],
                yCavitySize = cavityArrayConfig[i][2], 
                cavityType = cavityArrayConfig[i][3],
                cavityBoxFillet = cavityArrayConfig[i][4],
                cavityBuildToggle = cavityArrayConfig[i][5]);
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
    HollowBox();

    /* Cavity(
            cavityPos = 1,  
            xCavitySize = 1,
            yCavitySize = 1, 
            cavityType = "box",
            cavityBoxFillet = 1); */
};
if(generatedPart=="none") {}