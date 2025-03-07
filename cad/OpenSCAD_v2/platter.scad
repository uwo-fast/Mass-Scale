







$fn = $preview ? 32 : 128;
zFite = $preview ? 0.1 : 0;

module platter(length, width, height, corner_radius, wall_thickness, top_thickness)
{
    minkowskiDim = [ corner_radius, corner_radius, 1 ];
    oDim = [ length, width, height ];
    iDim = [ oDim[0] - wall_thickness * 2, oDim[1] - wall_thickness * 2, oDim[2] - top_thickness ];

    translate([ length, 0, height ]) rotate([ 0, 180, 0 ]) difference()
    {
        union()
        {
            translate([ minkowskiDim[0], minkowskiDim[1], 0 ]) difference()
            {
                minkowski()
                {
                    cube(oDim - minkowskiDim * 2);
                    cylinder(r = minkowskiDim[0], h = minkowskiDim[2] * 2);
                }
                minkowski()
                {
                    translate([ wall_thickness, wall_thickness, top_thickness ]) cube(iDim - minkowskiDim * 2);
                    cylinder(r = minkowskiDim[0], h = minkowskiDim[2] * 2 + zFite);
                }
            }
        }
    }
}

// dimensions of the main body
test_length = 100;
test_width = 100;
test_height = 10;

// radius of the corners
test_corner_radius = 15;

// thickness of the walls and top
test_wall_thickness = 3;
test_top_thickness = 3;

platter(length = test_length, width = test_width, height = test_height, corner_radius = test_corner_radius,
        wall_thickness = test_wall_thickness, top_thickness = test_top_thickness);