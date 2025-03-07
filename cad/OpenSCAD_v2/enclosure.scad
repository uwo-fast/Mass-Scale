// enclosure.scad

$fn = $preview ? 32 : 128;
zFite = $preview ? 0.1 : 0;

module enclosure(length, width, height, corner_radius, wall_thickness, top_thickness, bevel_angle)
{

    minkowskiDim = [ corner_radius, corner_radius, 1 ];
    oDim = [ length, width, height ];
    iDim = [ oDim[0] - wall_thickness * 2, oDim[1] - wall_thickness * 2, oDim[2] - top_thickness * 2 ];

    // main body
    difference()
    {

        translate([ minkowskiDim[0], minkowskiDim[1], -top_thickness ]) difference()
        {

            minkowski()
            {
                translate([ 0, 0, top_thickness ]) cube(oDim - minkowskiDim * 2);
                cylinder(r = minkowskiDim[0], h = minkowskiDim[2]);
            }

            minkowski()
            {
                translate([ wall_thickness, wall_thickness, 0 ]) cube(iDim - minkowskiDim * 2);
                cylinder(r = minkowskiDim[0], h = minkowskiDim[2] * 2);
            }
        }
        // Front bevel cutout.
        translate([ 0, -zFite / 2, wall_thickness * 2 ]) rotate([ 0, -bevel_angle, 0 ])
            cube([ oDim[2] * 2, oDim[1] + zFite, oDim[2] * 2 ]);
    }

    // front bevel
    intersection()
    {
        translate([ minkowskiDim[0], minkowskiDim[1], 0 ]) minkowski()
        {
            cube(oDim - minkowskiDim * 2);
            cylinder(r = minkowskiDim[0], h = minkowskiDim[2]);
        }

        rotate([ 0, -bevel_angle, 0 ]) cube([ oDim[2] * 2, oDim[1], wall_thickness * 2 ]);
    }
}

// dimensions of the main body
test_length = 150;
test_width = 100;
test_height = 30;

// radius of the corners
test_corner_radius = 15;

// thickness of the walls and top
test_wall_thickness = 3;
test_top_thickness = 2;

// angle of the front bevel
test_bevel_angle = 35;

enclosure(length = test_length, width = test_width, height = test_height, corner_radius = test_corner_radius,
          wall_thickness = test_wall_thickness, top_thickness = test_top_thickness, bevel_angle = test_bevel_angle);