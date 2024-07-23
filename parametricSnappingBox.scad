

// Which part of the design to show
// Parts box, deck box
generatedPart = "Gridded_Token_Box"; // [Gridded_Token_Box, Deck_Box, Lid, none]

/* [Global Parameters] */
Lid_Thickness = 1.5;
Wall_Thickness = 1;
Outer_Edge_Rounding = 0.5; //[0:0.05:1]

/* [Token Box Parameters] */
Grid_Size_X = 140; // 95
Grid_Size_Y = 100; // 120
Grid_Size_Z = 29; // 25

Horisontal_Grid_Devisions = 2;
Vertical_Grid_Devisions = 2;

Default_Grid_Type = "Box"; //[Box, Scoop]
Default_Grid_Rounding = 0.5; //[0:0.05:1]

/* [First Custom Grid Settings] */
First_Custom_Grid_Toggle = true;
First_Custom_Grid_Position = 0;
First_Custom_Grid_Size = [2, 2];
First_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Second Custom Grid Settings] */
Second_Custom_Grid_Toggle = true;
Second_Custom_Grid_Position = 1;
Second_Custom_Grid_Size = [1, 1];
Second_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Third Custom Grid Settings] */
Third_Custom_Grid_Toggle = true;
Third_Custom_Grid_Position = 1;
Third_Custom_Grid_Size = [1, 1];
Third_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Fourth Custom Grid Settings] */
Fourth_Custom_Grid_Toggle = true;
Fourth_Custom_Grid_Position = 1;
Fourth_Custom_Grid_Size = [1, 1];
Fourth_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Fifth Custom Grid Settings] */
Fifth_Custom_Grid_Toggle = true;
Fifth_Custom_Grid_Position = 1;
Fifth_Custom_Grid_Size = [1, 1];
Fifth_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Sixth Custom Grid Settings] */
Sixth_Custom_Grid_Toggle = true;
Sixth_Custom_Grid_Position = 1;
Sixth_Custom_Grid_Size = [1, 1];
Sixth_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Seventh Custom Grid Settings] */
Seventh_Custom_Grid_Toggle = true;
Seventh_Custom_Grid_Position = 1;
Seventh_Custom_Grid_Size = [1, 1];
Seventh_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Eighth Custom Grid Settings] */
Eighth_Custom_Grid_Toggle = true;
Eighth_Custom_Grid_Position = 1;
Eighth_Custom_Grid_Size = [1, 1];
Eighth_Custom_Grid_Type = "Box"; //[Box, Scoop]

/* [Ninth Custom Grid Settings] */
Ninth_Custom_Grid_Toggle = true;
Ninth_Custom_Grid_Position = 1;
Ninth_Custom_Grid_Size = [1, 1];
Ninth_Custom_Grid_Type = "Box"; //[Box, Scoop]

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


// throw example size to echo to calculate the actual size of a cavity
calculateCavity = [1, 1];

// [position, x size, y size, type, fillet] 
// set the default cavities to be built on every grid space except those blocked by DoNotBuild 
cavityConfigDefault = ["pos", "box", ["grids", 1, 1]]; 

//define which grid spaces to not build default boxes on, this does not affect cavities boxes below
//useful to stop defaults from stepping on your custom boxes defined below
cavityDoNotBuild = [ 
    0,1
];

// define cavities boxes to be built anywhere on the grid with non-default settings
// it is recomended to turn off default cavities that interfere with your custom ones
// cavity positions are shown on the file itself if numberGuides are enabled
// size is in units relative to the grid size. a size of [1, 1] is the size of the default container. 2 is twice as big. 
// it is possible to make multiple custom cavities in the same position, large complex cavities are possible with box types. experement!
cavityConfig = [
    /*
    [pos, "type", ["units", x, y], [offset x, offset y], [finger tabs?, Grid_Size_X] ]
    */
  //  [0, "box", ["mm", 50,25], [], [true, 10]],
  //  [1, "box", ["mm", 1,1], [0,-10]]
  [0, "box", ["grids", 1, 1], [], [true, 10]],
  [1, "box", ["grids", 1, 1], [], [true, 10]],
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

//process size variables to create the size of the outer box
Grid_Size_Vector = concat([Grid_Size_X], [Grid_Size_Y], [Grid_Size_Z]);

function OuterSizeFromGridSize (axis) = 
    axis == "x" ? //test
    (Grid_Size_X * Horisontal_Grid_Devisions) + (Wall_Thickness * (Horisontal_Grid_Devisions-1)) + ((Lid_Thickness + lidTolerance) * 2) //true value
    :
    axis == "y" ? // false value / second test
    (Grid_Size_Y * Vertical_Grid_Devisions) + (Wall_Thickness * (Vertical_Grid_Devisions-1)) + ((Lid_Thickness + lidTolerance) * 2) // second true value
    :
    axis == "z" ? // third test
    (Grid_Size_Z + Wall_Thickness + Lid_Thickness + lidTolerance)
    :
    undef; // if none pass
x = OuterSizeFromGridSize("x"); // horisontal
y = OuterSizeFromGridSize("y"); // vertical
z = OuterSizeFromGridSize("z");

// create an array to make the custom grid settings readable
customCavityArray = concat(
    [ [ First_Custom_Grid_Toggle,     First_Custom_Grid_Position,       First_Custom_Grid_Size,       First_Custom_Grid_Type] ], 
    [ [ Second_Custom_Grid_Toggle,    Second_Custom_Grid_Position,      Second_Custom_Grid_Size,      Second_Custom_Grid_Type] ], 
    [ [ Third_Custom_Grid_Toggle,     Third_Custom_Grid_Position,       Third_Custom_Grid_Size,       Third_Custom_Grid_Type] ], 
    [ [ Fourth_Custom_Grid_Toggle,    Fourth_Custom_Grid_Position,      Fourth_Custom_Grid_Size,      Fourth_Custom_Grid_Type] ], 
    [ [ Fifth_Custom_Grid_Toggle,     Fifth_Custom_Grid_Position,       Fifth_Custom_Grid_Size,       Fifth_Custom_Grid_Type] ], 
    [ [ Sixth_Custom_Grid_Toggle,     Sixth_Custom_Grid_Position,       Sixth_Custom_Grid_Size,       Sixth_Custom_Grid_Type] ], 
    [ [ Seventh_Custom_Grid_Toggle,   Seventh_Custom_Grid_Position,     Seventh_Custom_Grid_Size,     Seventh_Custom_Grid_Type] ], 
    [ [ Eighth_Custom_Grid_Toggle,    Eighth_Custom_Grid_Position,      Eighth_Custom_Grid_Size,      Eighth_Custom_Grid_Type] ], 
    [ [ Ninth_Custom_Grid_Toggle,     Ninth_Custom_Grid_Position,       Ninth_Custom_Grid_Size,       Ninth_Custom_Grid_Type] ] 
);


/* // make an array of default boxes to not build
allCustomCavityPos = [
    for (i = [0 : len(customCavityArray) - 1])
        customCavityArray[i][0] == true ? // only add to the array if that custom cavity is enabled
        customCavityArray[i][1] : undef // if false, set undef
    ];
echo("allCustomCavityPos", allCustomCavityPos); */


customCavityVerticalSpan = [
    for(i = [0 : len(customCavityArray) - 1])
        [for(i2 = [0 : customCavityArray[i][2][1] - 1])
            customCavityArray[i][0] == true ? // only add to the array if that custom cavity is enabled
            customCavityArray[i][1] + (1 * i2) : undef // if false, set undef
        ]
];
echo("customCavityVerticalSpan", customCavityVerticalSpan);

customCavityHorisontalSpan = [
    for(i = [0 : len(customCavityArray) - 1])
        [for(i2 = [0 : customCavityArray[i][2][0] - 1])
            for(i3 = [0 : customCavityArray[i][2][1] - 1])
                customCavityVerticalSpan[i][i3] + (3 * (i2))
        ]
    ];
echo("customCavityHorisontalSpan", customCavityHorisontalSpan);


/* echo(
    [ for(i = [0 : len(customCavityArray) - 1]) { // for loop to create a vector
        for(i2 = [
            customCavityArray[i][1] - 1 : customCavityArray[i][2][1] - 1
            ])
            customCavityArray[i][0] == true ? // only add to the array if that custom cavity is enabled
            i2 //customCavityArray[i][1] + (1 * i2)
            : undef // if custom cavity is not enabled set to undef
    } ]
); */

echo(customCavityArray[0][2][1] - 1);

lockingRidgeSpacing = ((z-boxLipHeight)*0.2);

// create an array describing every point in the grid
grid = [for (ix=[1:(Horisontal_Grid_Devisions)]) for(iy=[1:Vertical_Grid_Devisions]) [(ix), (iy), 0]];
//echo(grid);


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
        grid[cavityPos][0] * Grid_Size_X,// + wallThickness,
        grid[cavityPos][1] * Grid_Size_Y,// + wallThickness,
        0
        ])
    move([ // align with box
        -grid[0][0] * Grid_Size_X + (wallThickness),///2 - wallThickness),
        -grid[0][1] * Grid_Size_Y + (wallThickness),///2 - wallThickness),
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

module TokenBoxCavity(
    cavityPos,  
    xCavitySize,
    yCavitySize, 
    cavityType,
    cavityBoxFillet) 
{
        move([ // move to spot in grid
            grid[cavityPos][0] * Grid_Size_X,// + wallThickness,
            grid[cavityPos][1] * Grid_Size_Y,// + wallThickness,
            0
        ])
        move([ // align with box
            -grid[0][0] * Grid_Size_X + (wallThickness),///2 - wallThickness),
            -grid[0][1] * Grid_Size_Y + (wallThickness),///2 - wallThickness),
            0
            ])
    union() {
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
            // make the longer of the two sides the Grid_Size_Y
            cylCavityLength = xCavitySize>yCavitySize ? xCavitySize : yCavitySize; 
            // make the other value the Grid_Size_X
            cylCavityWidth = cylCavityLength==xCavitySize ? yCavitySize : xCavitySize;
            // orient the Grid_Size_Y along the correct axis
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

function WhichAxisMM (axis) = axis == 1 ? Grid_Size_X : Grid_Size_Y;

function CalcDefaultCavitySize (axis) = (cavityConfigDefault[2][axis] * WhichAxisMM(axis)) - wallThickness;

function CalcCavitySize (pos, axis) = 
    cavityConfig[pos][2][0] == "grids" ? //check the units: 1 = x, 2 = y.
        //if units == "grids" 
        cavityConfig[pos][2][axis] * (WhichAxisMM(axis)) - wallThickness
        : //if units == "mm"
        cavityConfig[pos][2][axis];

//echo(CalcCavitySize(0, 1));

module TokenBoxCavityArray()
{
    for(i = [0:(Vertical_Grid_Devisions * Horisontal_Grid_Devisions)-1]) //build defaults
    {
        # if(numberGuides==true) {
            FloatingNumberGuides(i);
        };

        // echo("loop ", i);
        cavityArrayBlocker = in_list(i, cavityDoNotBuild);

        if(cavityArrayBlocker != true) 
        { 
            //echo("building default cavity");
            TokenBoxCavity(
                cavityPos = i,  
                xCavitySize = CalcDefaultCavitySize(1),
                yCavitySize = CalcDefaultCavitySize(2), 
                cavityType = Default_Grid_Type,
                cavityBoxFillet = Default_Grid_Rounding);
        };
        
        if(cavityArrayBlocker == true) echo("did not build default cavity ", cavityDoNotBuild[i]);
    };

    for(i = [0:len(cavityConfig)]) { // build custom cavities
        if(cavityConfig[i][0] != undef)
        {
            customCavityOffset = cavityConfig[i][3] != [] ? concat(cavityConfig[i][3], [0]) : [0,0,0];
            move(customCavityOffset)
            TokenBoxCavity(
                    cavityPos = cavityConfig[i][0],  
                    xCavitySize = CalcCavitySize(i, 1),
                    yCavitySize = CalcCavitySize(i, 2), 
                    cavityType = cavityConfig[i][1],
                    cavityBoxFillet = Default_Grid_Rounding);
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
    zmove(-(z/2)) zmove(boxLipHeight + (lockingRidgeSize)) zmove((z - boxLipHeight) * 0.2)
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
                //zmove(-(z/2)) zmove(boxLipHeight + (lockingRidgeSize)) zmove((z - boxLipHeight) * 0.2)
                LockingRidge(0);

                FilledBox();
            };
        };

        TokenBoxCavityArray();
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
        //move([x/2, y/2, 0]) 
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
        union() {
            AdornedBox();
            LockingRidge(0);
        }
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

    xCavitySizeEcho = (1 * Grid_Size_X) - wallThickness*2;
    yCavitySizeEcho = (1 * Grid_Size_Y) - wallThickness*2;

    echo("----- Interior TokenBoxCavity Dimentions -----");
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

if(generatedPart=="Gridded_Token_Box") {
    //zmove(z/2)
    //zrot(-90) // rotate for better readability
    Box();
};
if(generatedPart=="Lid") {
    zflip()
    Lid();
};
if(generatedPart=="test"){
    //TokenBoxCavityArray();
    SubdevBox();


    /* TokenBoxCavity(
            cavityPos = 1,  
            xCavitySize = 1,
            yCavitySize = 1, 
            cavityType = "box",
            cavityBoxFillet = 1); */
};
if(generatedPart=="none") {}