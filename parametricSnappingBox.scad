include <BOSL/constants.scad>
use <BOSL/joiners.scad>


module innerBoxMask(x, y, z , innerFillet)
{
    for(i=[
        [x,0,0]
        [-x,0,0]
        [0,y,0]
        [0,-y,0]
    ]) {
        translate(i)
        cuboid(size = innerBoxSize, fillet=innerFillet, center=true)
    }
}

module boxAndLid(
        x=1
        y=1
        z=1,
        lidHeight=1,
        lidOverlap=0.5,
        boxFillet=0,
        lidFillet=0,
        part=undef // "lid" or "box"
        center=true )
{
    cuboid(size=boxSize, fillet=boxFillet, center=center, )
}

boxAndLid(
    x=10,
    y=10,
    z=10,
    boxFillet=2,
    lidFillet=2,)