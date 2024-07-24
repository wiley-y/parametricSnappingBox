

// Which part of the design to show
// Parts box, deck box
generatedPart = "Gridded_Box"; // [Gridded_Box, Lid, none, test]

/* [Global Parameters] */
Lid_Thickness = 1.5;
Wall_Thickness = 1;
Lid_Height = 1;
Lid_As_Box_Stand_Height = 5;
Outer_Edge_Rounding = 0; //[0:0.0001:0.01]

Grid_Size_X = 140; // 95
Grid_Size_Y = 100; // 120
Grid_Size_Z = 29; // 25

Horizontal_Grid_Devisions = 2;
Vertical_Grid_Devisions = 1;

Default_Grid_Type = "Box"; //[Box, Deck, Scoop]
Scoop_Edge_Rounding = 0.25; // [0:0.05:1]
Box_Edge_Rounding = 0; //[0:0.0001:0.01]

Deck_Edge_Opening = 0.8; //[0:0.05:1]
Deck_Edge_Slope = 0.8; //[0:0.05:1]

/* [First Custom Grid Settings] */
First_Custom_Grid_Toggle = false;
First_Custom_Grid_Position = 0;
First_Custom_Grid_Size = [2, 2];
First_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
First_Custom_Deck_Edge_Left = true;
First_Custom_Deck_Edge_Top = true;
First_Custom_Deck_Edge_Bottom = true;
First_Custom_Deck_Edge_Right = true;

/* [Second Custom Grid Settings] */
Second_Custom_Grid_Toggle = false;
Second_Custom_Grid_Position = 1;
Second_Custom_Grid_Size = [1, 1];
Second_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Second_Custom_Deck_Edge_Left = true;
Second_Custom_Deck_Edge_Top = true;
Second_Custom_Deck_Edge_Bottom = true;
Second_Custom_Deck_Edge_Right = true;

/* [Third Custom Grid Settings] */
Third_Custom_Grid_Toggle = false;
Third_Custom_Grid_Position = 1;
Third_Custom_Grid_Size = [1, 1];
Third_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Third_Custom_Deck_Edge_Left = true;
Third_Custom_Deck_Edge_Top = true;
Third_Custom_Deck_Edge_Bottom = true;
Third_Custom_Deck_Edge_Right = true;

/* [Fourth Custom Grid Settings] */
Fourth_Custom_Grid_Toggle = false;
Fourth_Custom_Grid_Position = 1;
Fourth_Custom_Grid_Size = [1, 1];
Fourth_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Fourth_Custom_Deck_Edge_Left = true;
Fourth_Custom_Deck_Edge_Top = true;
Fourth_Custom_Deck_Edge_Bottom = true;
Fourth_Custom_Deck_Edge_Right = true;

/* [Fifth Custom Grid Settings] */
Fifth_Custom_Grid_Toggle = false;
Fifth_Custom_Grid_Position = 1;
Fifth_Custom_Grid_Size = [1, 1];
Fifth_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Fifth_Custom_Deck_Edge_Left = true;
Fifth_Custom_Deck_Edge_Top = true;
Fifth_Custom_Deck_Edge_Bottom = true;
Fifth_Custom_Deck_Edge_Right = true;

/* [Sixth Custom Grid Settings] */
Sixth_Custom_Grid_Toggle = false;
Sixth_Custom_Grid_Position = 1;
Sixth_Custom_Grid_Size = [1, 1];
Sixth_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Sixth_Custom_Deck_Edge_Left = true;
Sixth_Custom_Deck_Edge_Top = true;
Sixth_Custom_Deck_Edge_Bottom = true;
Sixth_Custom_Deck_Edge_Right = true;

/* [Seventh Custom Grid Settings] */
Seventh_Custom_Grid_Toggle = false;
Seventh_Custom_Grid_Position = 1;
Seventh_Custom_Grid_Size = [1, 1];
Seventh_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Seventh_Custom_Deck_Edge_Left = true;
Seventh_Custom_Deck_Edge_Top = true;
Seventh_Custom_Deck_Edge_Bottom = true;
Seventh_Custom_Deck_Edge_Right = true;

/* [Eighth Custom Grid Settings] */
Eighth_Custom_Grid_Toggle = false;
Eighth_Custom_Grid_Position = 1;
Eighth_Custom_Grid_Size = [1, 1];
Eighth_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Eighth_Custom_Deck_Edge_Left = true;
Eighth_Custom_Deck_Edge_Top = true;
Eighth_Custom_Deck_Edge_Bottom = true;
Eighth_Custom_Deck_Edge_Right = true;

/* [Ninth Custom Grid Settings] */
Ninth_Custom_Grid_Toggle = false;
Ninth_Custom_Grid_Position = 1;
Ninth_Custom_Grid_Size = [1, 1];
Ninth_Custom_Grid_Type = "Box"; //[Box, Scoop, Deck, Fill]
Ninth_Custom_Deck_Edge_Left = true;
Ninth_Custom_Deck_Edge_Top = true;
Ninth_Custom_Deck_Edge_Bottom = true;
Ninth_Custom_Deck_Edge_Right = true;

// controls the outer edges of the box, inner cavity edges are controlled in cavity settings
boxFillet=0; 
 // the rounding of the cylindrical containers
cavityFillet = 0;

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

$fa = $preview ? 20 : 1;
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
    [ 
        [ First_Custom_Grid_Toggle,     
        First_Custom_Grid_Position,       
        First_Custom_Grid_Size,       
        First_Custom_Grid_Type,
        First_Custom_Deck_Edge_Left,
        First_Custom_Deck_Edge_Top,
        First_Custom_Deck_Edge_Bottom,
        First_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Second_Custom_Grid_Toggle,    
        Second_Custom_Grid_Position,      
        Second_Custom_Grid_Size,      
        Second_Custom_Grid_Type,
        Second_Custom_Deck_Edge_Left,
        Second_Custom_Deck_Edge_Top,
        Second_Custom_Deck_Edge_Bottom,
        Second_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Third_Custom_Grid_Toggle,     
        Third_Custom_Grid_Position,       
        Third_Custom_Grid_Size,       
        Third_Custom_Grid_Type,
        Third_Custom_Deck_Edge_Left,
        Third_Custom_Deck_Edge_Top,
        Third_Custom_Deck_Edge_Bottom,
        Third_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Fourth_Custom_Grid_Toggle,    
        Fourth_Custom_Grid_Position,      
        Fourth_Custom_Grid_Size,      
        Fourth_Custom_Grid_Type,
        Fourth_Custom_Deck_Edge_Left,
        Fourth_Custom_Deck_Edge_Top,
        Fourth_Custom_Deck_Edge_Bottom,
        Fourth_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Fifth_Custom_Grid_Toggle,     
        Fifth_Custom_Grid_Position,       
        Fifth_Custom_Grid_Size,       
        Fifth_Custom_Grid_Type,
        Fifth_Custom_Deck_Edge_Left,
        Fifth_Custom_Deck_Edge_Top,
        Fifth_Custom_Deck_Edge_Bottom,
        Fifth_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Sixth_Custom_Grid_Toggle,     
        Sixth_Custom_Grid_Position,       
        Sixth_Custom_Grid_Size,       
        Sixth_Custom_Grid_Type,
        Sixth_Custom_Deck_Edge_Left,
        Sixth_Custom_Deck_Edge_Top,
        Sixth_Custom_Deck_Edge_Bottom,
        Sixth_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Seventh_Custom_Grid_Toggle,   
        Seventh_Custom_Grid_Position,     
        Seventh_Custom_Grid_Size,     
        Seventh_Custom_Grid_Type,
        Seventh_Custom_Deck_Edge_Left,
        Seventh_Custom_Deck_Edge_Top,
        Seventh_Custom_Deck_Edge_Bottom,
        Seventh_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Eighth_Custom_Grid_Toggle,    
        Eighth_Custom_Grid_Position,      
        Eighth_Custom_Grid_Size,      
        Eighth_Custom_Grid_Type,
        Eighth_Custom_Deck_Edge_Left,
        Eighth_Custom_Deck_Edge_Top,
        Eighth_Custom_Deck_Edge_Bottom,
        Eighth_Custom_Deck_Edge_Right ] 
    ], 
    [ 
        [ Ninth_Custom_Grid_Toggle,     
        Ninth_Custom_Grid_Position,       
        Ninth_Custom_Grid_Size,       
        Ninth_Custom_Grid_Type,
        Ninth_Custom_Deck_Edge_Left,
        Ninth_Custom_Deck_Edge_Top,
        Ninth_Custom_Deck_Edge_Bottom,
        Ninth_Custom_Deck_Edge_Right ] 
    ] 
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
        fillet=Outer_Edge_Rounding * z,
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
            fillet = Box_Edge_Rounding * z,
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
    linear_extrude(1) text(textGuide, size = 5, font="Liberation Sans");
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

module SlicedCyl(l, d1, d2, fillet1, thickness)
{
    intersection() {
        //yscale(100)
        cyl(
            l = l,
            d2 = d2,
            d1 = d1,
            fillet1 = (l < (d1/2) ? z/2 : (d1/4))
        );
        cuboid(
            size = ([d2*d1*2, thickness+0.01, d2*d1*2]),
            center = true
        );
    };
}

module TokenBoxCavity(
    cavityPos,  
    xCavitySize,
    yCavitySize, 
    cavityType,
    cavityBoxFillet,
    cavityNumber) 
{
    xCavitySizeMM = (Grid_Size_X * xCavitySize) + (Wall_Thickness * (xCavitySize - 1));
    yCavitySizeMM = (Grid_Size_Y * yCavitySize) + (Wall_Thickness * (yCavitySize - 1));
    echo(xCavitySize);

        move([ // move to spot in grid
            (grid[cavityPos][0] * Grid_Size_X) + (Wall_Thickness * (grid[cavityPos][0] + 1)),
            (grid[cavityPos][1] * Grid_Size_Y) + (Wall_Thickness * (grid[cavityPos][1] + 1)),
            0
        ])
    union() {
        if(cavityType=="Box" || cavityType == "Deck")
        {
            if(cavityType=="Deck") { // check if deck is enabled
                sliceThickness = Wall_Thickness + Lid_Thickness + lidTolerance;
                for(i = [0:3], // count the loop
                    deckArray = [ // and also encode move array to get the cutouts at the edges of the box
                    [[xCavitySizeMM / 2,                    -(sliceThickness / 2),                  0], "x", 3], //bottom
                    [[xCavitySizeMM / 2,                    (sliceThickness / 2) + yCavitySizeMM,   0], "x", 1], //top
                    [[-(sliceThickness / 2),                yCavitySizeMM / 2,                      0], "y", 2], //left
                    [[(sliceThickness / 2) + xCavitySizeMM, yCavitySizeMM / 2,                      0], "y", 4]  //right
                ]) {
                    if(customCavityArray[cavityNumber][deckArray[2] + 3] == true) {
                            move(deckArray[0])
                            zrot(deckArray[1] == "x" ? 0 : 90) // if x, not rot. if y, 90 degrees rot
                            zmove(Wall_Thickness)
                        SlicedCyl(
                            l = z,
                            d2 = Deck_Edge_Opening * (deckArray[1] == "x" ? xCavitySizeMM : yCavitySizeMM),
                            d1 = (Deck_Edge_Opening * Deck_Edge_Slope) * (deckArray[1] == "x" ? xCavitySizeMM : yCavitySizeMM),
                            thickness = sliceThickness
                        );
                    };
                };
            };
            
            zmove(-z/2)
            zmove(Wall_Thickness) // move up for floor
            cuboid(
                size=[xCavitySizeMM, yCavitySizeMM, z],
                fillet=cavityBoxFillet,
                edges=EDGES_Z_ALL+EDGES_BOTTOM,
                center = false);
        };
        if(cavityType=="Scoop")
        {
            // make the longer of the two sides the Grid_Size_Y
            cylCavityLength = xCavitySizeMM>yCavitySizeMM ? xCavitySizeMM : yCavitySizeMM; 
            // make the other value the Grid_Size_X
            cylCavityWidth = cylCavityLength==xCavitySizeMM ? yCavitySizeMM : xCavitySizeMM;
            // orient the Grid_Size_Y along the correct axis
            cylCavityOrient = xCavitySizeMM>yCavitySizeMM ? ORIENT_X : ORIENT_Y;
            
            zmove(z/2)
            zscale((z*2-(Wall_Thickness*2)) / cylCavityWidth)
            cyl(
                l = cylCavityLength,
                d = cylCavityWidth,
                orient = cylCavityOrient,
                fillet = cylCavityWidth*(Scoop_Edge_Rounding),
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
            if(in_list(i, customCavityDoNotBuild) == true) echo("did not build default cavity ", customCavityDoNotBuild[i]);
            if(in_list(i, customCavityDoNotBuild) != true) 
            { 
                //echo("building default cavity");
                TokenBoxCavity(
                    cavityPos = i,  
                    xCavitySize = 1,
                    yCavitySize = 1, 
                    cavityType = Default_Grid_Type,
                    cavityBoxFillet = Box_Edge_Rounding * z);
            };
    };
    for(i = [0:len(customCavityArray)]) { // build custom cavities
        if(customCavityArray[i][0] == true)
        {
            TokenBoxCavity(
                    cavityPos = customCavityArray[i][1],  
                    xCavitySize = customCavityArray[i][2][0],
                    yCavitySize = customCavityArray[i][2][1], 
                    cavityType = customCavityArray[i][3],
                    cavityBoxFillet = Box_Edge_Rounding * z,
                    cavityNumber = i);
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
        fillet=Outer_Edge_Rounding * z,
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

            if(enforceOuterWall==true) HollowBox();
    
            zmove(-(z/2)) zmove(boxLipHeight/2)
            BoxLip(lidTolerance);
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
    difference() {
        zmove(z/2)
        SubdevBox();

        if(Lid_As_Box_Stand_Height != 0)
                zmove(boxLipHeight + lidTolerance) // align top with 0
                move([x/2, y/2, 0]) // align with box
                zmove(Lid_As_Box_Stand_Height) // move in by the variable amount
                zflip() 
            union() { // tolerance in all directions by adding slightly different scale lids
                Lid();
                scale([((x + lidTolerance*2) / x), ((y + lidTolerance*2) / y), 1])
                Lid();
                scale([-((x + lidTolerance*2) / x), -((y + lidTolerance*2) / y), 1])
                Lid();
            };
    };
}

module Lid ()
{
    difference() {
            zmove(z/2) zmove(Lid_Height/2) zmove(Lid_Thickness/2) //zmove(-lidTolerance/2)
        //move([x/2, y/2, 0]) 
        difference() {
            cuboid( // outer shell
                    size = [
                        x + Lid_Thickness*2 + lidTolerance, 
                        y + Lid_Thickness*2 + lidTolerance, 
                        z + Lid_Height + Lid_Thickness + lidTolerance],
                        fillet = Outer_Edge_Rounding * z,// * (Lid_Height + Lid_Thickness + lidTolerance),
                        edges = EDGES_ALL,
                        center = true);

            zmove(-Lid_Thickness) // make room for floor
            cuboid( // inner mask
                size = [
                    x + lidTolerance*2, 
                    y + lidTolerance*2, 
                    z + Lid_Height + lidTolerance*2],
                    fillet = Box_Edge_Rounding* z,// * (Lid_Height + lidTolerance*2),
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
            zmove(-(Lid_Height/2)) zmove(boxLipHeight/2) 
            zmove(-lidTolerance) zmove(-Lid_Thickness)
            BoxLip(lidTolerance);

            zmove(-(Lid_Height/2)) zmove(boxLipHeight/2) zmove((z - boxLipHeight) * 0.2)
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

if(generatedPart=="Gridded_Box") {
    //zmove(z/2)
    //zrot(-90) // rotate for better readability
    render() 
    Box();
};
if(generatedPart=="Lid") {
    zflip()
    Lid();
};
if(generatedPart=="test"){
    SlicedCyl(
        l = z + Wall_Thickness,
        d2 = 80,
        d1 = 70,
        fillet1 = (z + Wall_Thickness)/2,
        thickness = 1
    );
};
if(generatedPart=="none") {}