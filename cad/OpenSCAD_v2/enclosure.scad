/* OS Nano Balance - Base: Accepts load cell, holds electronics.
    Copyright (C) 2019 Benjamin Hubbard

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

$fn = 50;

// Bed dimensions.
minkowskiDim = [ 10, 10, 1 ];
oDim = [ 150, 105, 30 ]; //[150, 150, 10];
iDim = [ 145, 100, 26 ]; //[144, 144, 6];
// Dimensional difference - for placement (also = shell thickness * 2)
diff = oDim - iDim;

// Front bevel.
bevelL = 100;

// Switch dimensions.
swL = 21.5;
swW = 13;

// Screen dimensions.

// Make the main body.
module base()
{
    difference()
    {
        union()
        {
            translate([ minkowskiDim[0], minkowskiDim[1], 0 ]) difference()
            {

                minkowski()
                {
                    translate([ 0, 0, diff[2] ]) cube(oDim - minkowskiDim * 2);
                    cylinder(r = minkowskiDim[0], h = minkowskiDim[2]);
                }

                minkowski()
                {
                    translate([ diff[0] / 2, diff[1] / 2, 0 ]) cube(iDim - minkowskiDim * 2);
                    cylinder(r = minkowskiDim[0], h = minkowskiDim[2] * 2);
                }
            }
        }
        // cuts
    }
}

module enclosure()
{

    difference()
    {
        base();
        // Front bevel cutout.
        translate([ 0, 0, diff[0] ]) rotate([ 0, -35, 0 ]) cube([ oDim[2] * 2, oDim[1], oDim[2] * 2 ]);
    }

    intersection()
    {
        translate([ minkowskiDim[0], minkowskiDim[1], 0 ]) minkowski()
        {
            cube(oDim - minkowskiDim * 2);
            cylinder(r = minkowskiDim[0], h = minkowskiDim[2]);
        }

        translate([ 0, 0, diff[0] ]) rotate([ 0, -35, 0 ]) cube([ oDim[2] * 2, oDim[1], diff[0] ]);
    }
}

enclosure();