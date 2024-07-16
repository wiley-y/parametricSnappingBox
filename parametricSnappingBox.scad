include <BOSL/constants.scad>
use <BOSL/joiners.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>


module innerBoxMask(x, y, z , wallThickness)
{
    for(i=[
        [(x - wallThickness),0,0],
        [(x - wallThickness)*-1,0,0],
        [0,(y - wallThickness),0],
        [0,(y - wallThickness)*-1,0]]) 
    {
        translate(i)
        cuboid(size=[x,y,z], edges=EDGES_TOP, center=true);
    }
};

module lockingNotch(
    x, y, z)
{
    
}

module box(
        x, y, z,
        wallThickness,
        floorThickness,
        boxFillet,
        edges=EDGES_TOP + EDGES_Z_ALL + EDGES_BOTTOM,
        center=true )
{
    zmove(z/2)
    intersection() {
        cuboid(size=[x,y,z], fillet=boxFillet, edges=edges, center=center);
        innerBoxMask(
            x=x,
            y=y,
            z=z,
            wallThickness=wallThickness);
    };
    zmove(floorThickness/2) cuboid(size=[x,y,floorThickness], fillet=boxFillet, edges=edges, center=true);
};


box(
    x=10,
    y=10,
    z=10,
    wallThickness=0.5,
    floorThickness=2,
    boxFillet=1
    );



/*
boxAndLid(
    x=10,
    y=10,
    z=10,
    boxFillet=2,
    lidFillet=2);
*/