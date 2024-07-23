

// Which part of the design to show
// Parts box, deck box
generatedPart = "test"; // [Gridded_Token_Box, Deck_Box, Lid, none]

/* [Global Parameters] */
Lid_Thickness = 1.5;
Wall_Thickness = 1;
Outer_Edge_Rounding = 0; //[0:0.05:1]

/* [Token Box Parameters] */
Grid_Size_X = 140; // 95
Grid_Size_Y = 100; // 120
Grid_Size_Z = 29; // 25

Horizontal_Grid_Devisions = 2;
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

// how much taller the lid is than the box, open space between box and lid interior
lidClearence = 1;
// how much room will be added between the box and the lid for 3d printing
lidTolerance = 0.6;
// the size of the protrusions that hold the lid in place
lockingRidgeSize = 0.5;
// how high the lower box/lid landing extends up the box
boxLipHeight=8; 

// throw example size to echo to calculate the actual size of a cavity
calculateCavity = [1, 1];

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

module GridSizeWarning (nGridSize, Grid_Size)
{
    if(Grid_Size[0] > Horizontal_Grid_Devisions || Grid_Size[1] > Vertical_Grid_Devisions) 
        echo("Warning : ", nGridSize, "Grid size cannot exceed Grid Devisions");
}
GridSizeWarning("First", First_Custom_Grid_Size);
GridSizeWarning("Second", Second_Custom_Grid_Size);
GridSizeWarning("Third", Third_Custom_Grid_Size);
GridSizeWarning("Fourth", Fourth_Custom_Grid_Size);
GridSizeWarning("Fifth", Fifth_Custom_Grid_Size);
GridSizeWarning("Sixth", Sixth_Custom_Grid_Size);
GridSizeWarning("Seventh", Seventh_Custom_Grid_Size);
GridSizeWarning("Eighth", Eighth_Custom_Grid_Size);
GridSizeWarning("Ninth", Ninth_Custom_Grid_Size);

//process size variables to create the size of the outer box
Grid_Size_Vector = concat([Grid_Size_X], [Grid_Size_Y], [Grid_Size_Z]);

function OuterSizeFromGridSize (axis) = 
    axis == "x" ? //test
    (Grid_Size_X * Horizontal_Grid_Devisions) + (Wall_Thickness * (Horizontal_Grid_Devisions+1)) + ((Lid_Thickness + lidTolerance) * 2) //true value
    :
    axis == "y" ? // false value / second test
    (Grid_Size_Y * Vertical_Grid_Devisions) + (Wall_Thickness * (Vertical_Grid_Devisions+1)) + ((Lid_Thickness + lidTolerance) * 2) // second true value
    :
    axis == "z" ? // third test
    (Grid_Size_Z + Wall_Thickness + Lid_Thickness + lidTolerance)
    :
    undef; // if none pass
function InnerBoxFromGridSize (axis) = 
    axis == "x" ? //test
    (Grid_Size_X * Horizontal_Grid_Devisions) + (Wall_Thickness * (Horizontal_Grid_Devisions+1))//true value
    :
    axis == "y" ? // false value / second test
    (Grid_Size_Y * Vertical_Grid_Devisions) + (Wall_Thickness * (Vertical_Grid_Devisions+1))// second true value
    :
    axis == "z" ? // third test
    (Grid_Size_Z + Wall_Thickness)
    :
    undef; // if none pass

x = InnerBoxFromGridSize("x"); // horisontal
y = InnerBoxFromGridSize("y"); // vertical
z = InnerBoxFromGridSize("z");

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

customCavityVerticalSpan = [
    for(i = [0 : len(customCavityArray) - 1])
        [for(i2 = [0 : customCavityArray[i][2][1] - 1])
            customCavityArray[i][0] == true ? // only add to the array if that custom cavity is enabled
            customCavityArray[i][1] + (1 * i2) : undef // if false, set undef
        ]
];
//echo("customCavityVerticalSpan", customCavityVerticalSpan);

customCavityDoNotBuild = [
    for(i = [0 : len(customCavityArray) - 1])
        for(i2 = [0 : customCavityArray[i][2][0] - 1])
            for(i3 = [0 : customCavityArray[i][2][1] - 1])
                customCavityVerticalSpan[i][i3] != undef ?
                customCavityVerticalSpan[i][i3] + (Vertical_Grid_Devisions * (i2))
                :undef
    ];
echo("customCavityDoNotBuild", customCavityDoNotBuild);


echo(customCavityArray[0][2][1] - 1);

lockingRidgeSpacing = ((z-boxLipHeight)*0.2);

// create an array describing every point in the grid
grid = [for (ix=[0:(Horizontal_Grid_Devisions-1)]) for(iy=[0:Vertical_Grid_Devisions-1]) [(ix), (iy), 0]];
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

            zmove(z/2) zmove(Wall_Thickness)
        cuboid(
            size = [
                (x - (Wall_Thickness*2)),
                (y - (Wall_Thickness*2)),
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
        grid[cavityPos][0] * Grid_Size_X,// + Wall_Thickness,
        grid[cavityPos][1] * Grid_Size_Y,// + Wall_Thickness,
        0
        ])
    move([ // align with box
        -grid[0][0] * Grid_Size_X + (Wall_Thickness),///2 - Wall_Thickness),
        -grid[0][1] * Grid_Size_Y + (Wall_Thickness),///2 - Wall_Thickness),
        0
        ])
    zmove(z) ymove(Grid_Size_Y/2) xmove(Grid_Size_X/2) 
    text(textGuide, size = 5, font="Liberation Sans");
}

module CavityFingerTab (fingerTabWidth) 
{
    zmove(-z/2) zmove(Wall_Thickness)
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
            (grid[cavityPos][0] * Grid_Size_X) + (Wall_Thickness * (grid[cavityPos][0] + 1)),
            (grid[cavityPos][1] * Grid_Size_Y) + (Wall_Thickness * (grid[cavityPos][1] + 1)),
            0
        ])
        /* move([ // align with box
            -grid[0][0] * Grid_Size_X,// + (Wall_Thickness),///2 - Wall_Thickness),
            -grid[0][1] * Grid_Size_Y,// + (Wall_Thickness),///2 - Wall_Thickness),
            0
            ]) */
    union() {
        if(cavityType=="Box")
        {
            //echo("box at pos ", cavityPos, " size = ", xCavitySize, yCavitySize);
            zmove(-z/2)
            zmove(Wall_Thickness) // move up for floor
            cuboid(
                size=[xCavitySize, yCavitySize, z],
                fillet=cavityBoxFillet,
                edges=EDGES_Z_ALL+EDGES_BOTTOM,
                center = false);
        };
        if(cavityType=="Scoop")
        {
            // make the longer of the two sides the Grid_Size_Y
            cylCavityLength = xCavitySize>yCavitySize ? xCavitySize : yCavitySize; 
            // make the other value the Grid_Size_X
            cylCavityWidth = cylCavityLength==xCavitySize ? yCavitySize : xCavitySize;
            // orient the Grid_Size_Y along the correct axis
            cylCavityOrient = xCavitySize>yCavitySize ? ORIENT_X : ORIENT_Y;
            
            zmove(z/2)
            zscale((z*2-(Wall_Thickness*2)) / cylCavityWidth)
            cyl(
                l = cylCavityLength,
                d = cylCavityWidth,
                orient = cylCavityOrient,
                fillet = cylCavityWidth*(cylCavityFillet),
                align = V_BACK+V_RIGHT);
        };
    };
};

module TokenBoxCavityArray()
{
    for(i = [0:(Vertical_Grid_Devisions * Horizontal_Grid_Devisions)-1]) //build defaults
    {
        # if(numberGuides==true) {
            FloatingNumberGuides(i);
        };

        // echo("loop ", i);

            if(in_list(i, customCavityDoNotBuild) == true) echo("did not build default cavity ", customCavityDoNotBuild[i]);
            if(in_list(i, customCavityDoNotBuild) != true) 
            { 
                //echo("building default cavity");
                TokenBoxCavity(
                    cavityPos = i,  
                    xCavitySize = Grid_Size_X,
                    yCavitySize = Grid_Size_Y, 
                    cavityType = Default_Grid_Type,
                    cavityBoxFillet = Default_Grid_Rounding);
            };
    };

    for(i = [0:len(customCavityArray)]) { // build custom cavities
        if(customCavityArray[i][0] == true)
        {
            //customCavityOffset = cavityConfig[i][3] != [] ? concat(cavityConfig[i][3], [0]) : [0,0,0];
            //move(customCavityOffset)
            TokenBoxCavity(
                    cavityPos = customCavityArray[i][1],  
                    xCavitySize = customCavityArray[i][1][0],
                    yCavitySize = customCavityArray[i][1][1], 
                    cavityType = customCavityArray[i][3],
                    cavityBoxFillet = Default_Grid_Rounding);
        };
    };
}


module BoxLip (boxLipTolerance) 
{
    cuboid(
        size=[
            x + Lid_Thickness*2 + boxLipTolerance,
            y + Lid_Thickness*2 + boxLipTolerance,
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
            zmove(lidHeight/2) zmove(Lid_Thickness/2) //zmove(-lidTolerance/2)
        //move([x/2, y/2, 0]) 
        difference() {
            cuboid( // outer shell
                    size = [
                        x + Lid_Thickness*2 + lidTolerance, 
                        y + Lid_Thickness*2 + lidTolerance, 
                        lidHeight + Lid_Thickness + lidTolerance],
                        fillet = boxFillet,
                        edges = EDGES_ALL,
                        center = true);

            zmove(-Lid_Thickness) // make room for floor
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
            zmove(-lidTolerance) zmove(-Lid_Thickness)
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

    xCavitySizeEcho = (1 * Grid_Size_X) - Wall_Thickness*2;
    yCavitySizeEcho = (1 * Grid_Size_Y) - Wall_Thickness*2;

    echo("----- Interior TokenBoxCavity Dimentions -----");
        // default cavity
        echo("The size of a [1, 1] cavity is ", xCavitySizeEcho, " by ", yCavitySizeEcho, " by ", z-Lid_Thickness);

        // custom calculations
        if(calculateCavity==undef) echo("To calculate a larger box please enter a size into cavlulateCavity");
        if(calculateCavity!=undef) {
            echo(
                "The size of a ", calculateCavity, " cavity is ", 
                calculateCavity[0] * xCavitySizeEcho, " by ", calculateCavity[1] * yCavitySizeEcho, " by ", z-Lid_Thickness);
        };

    echo();
}

//EchoInformation();

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
    //SubdevBox();
    HollowBox();


    /* TokenBoxCavity(
            cavityPos = 1,  
            xCavitySize = 1,
            yCavitySize = 1, 
            cavityType = "box",
            cavityBoxFillet = 1); */
};
if(generatedPart=="none") {}