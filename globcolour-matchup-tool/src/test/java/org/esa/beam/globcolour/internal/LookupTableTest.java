/*
    $Id: LookupTableTest.java,v 1.2 2007-06-14 16:44:43 ralf Exp $

    Copyright (c) 2006 Brockmann Consult. All rights reserved. Use is
    subject to license terms.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the Lesser GNU General Public License as
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the BEAM software; if not, download BEAM from
    http://www.brockmann-consult.de/beam/ and install it.
*/
package org.esa.beam.globcolour.internal;

import junit.framework.TestCase;
import org.esa.beam.globcolour.internal.IntervalPartition;

import java.util.Random;

/**
 * Test methods for class {@link LookupTable}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.2 $ $Date: 2007-06-14 16:44:43 $
 */
public class LookupTableTest extends TestCase {

    public void testInterpolation1D() {
        final double[] dimension = new double[]{0, 1};
        final double[] values = new double[]{0, 1};

        final LookupTable lut = new LookupTable(values, dimension);
        assertEquals(1, lut.getDimensionCount());

        assertEquals(0.0, lut.getDimension(0).getMin(), 0.0);
        assertEquals(1.0, lut.getDimension(0).getMax(), 0.0);

        assertEquals(0.0, lut.getValue(0.0), 0.0);
        assertEquals(1.0, lut.getValue(1.0), 0.0);
        assertEquals(0.5, lut.getValue(0.5), 0.0);
    }

    public void testInterpolation2D() {
        final double[][] dimensions = new double[][]{{0, 1}, {0, 1}};
        final double[] values = new double[]{0, 1, 2, 3};

        final LookupTable lut = new LookupTable(values, dimensions);
        assertEquals(2, lut.getDimensionCount());

        assertEquals(0.0, lut.getDimension(0).getMin(), 0.0);
        assertEquals(1.0, lut.getDimension(0).getMax(), 0.0);
        assertEquals(0.0, lut.getDimension(1).getMin(), 0.0);
        assertEquals(1.0, lut.getDimension(1).getMax(), 0.0);

        assertEquals(0.0, lut.getValue(0.0, 0.0), 0.0);
        assertEquals(1.0, lut.getValue(0.0, 1.0), 0.0);
        assertEquals(2.0, lut.getValue(1.0, 0.0), 0.0);
        assertEquals(3.0, lut.getValue(1.0, 1.0), 0.0);

        assertEquals(0.5, lut.getValue(0.0, 0.5), 0.0);
        assertEquals(1.5, lut.getValue(0.5, 0.5), 0.0);
        assertEquals(2.5, lut.getValue(1.0, 0.5), 0.0);
    }

    public void testInterpolation3D() {
        final IntervalPartition[] dimensions = IntervalPartition.createArray(
                new double[]{0, 1, 2, 3, 4}, new double[]{1, 2, 3, 4, 5}, new double[]{2, 3, 4, 5, 6});

        assertEquals(125, LookupTable.getVertexCount(dimensions));

        final double[] values = new double[125];
        for (int i = 0; i < values.length; ++i) {
            values[i] = i;
        }

        final LookupTable lut = new LookupTable(values, dimensions);
        assertEquals(3, lut.getDimensionCount());

        final double[] r = new double[3];
        final double[] x = new double[3];
        final LookupTable.FracIndex[] fi = LookupTable.FracIndex.createArray(3);
        final Random rng = new Random(27182);

        for (int i = 0; i < 10; ++i) {
            // Compute random coordinates and fractional indices
            for (int j = 0; j < 3; ++j) {
                r[j] = rng.nextDouble() * (lut.getDimension(j).getMax() - lut.getDimension(j).getMin());
                x[j] = r[j] + lut.getDimension(j).getMin();

                fi[j].i = (int) r[j];
                fi[j].f = r[j] % 1.0;

            }

            // Check computation of fractional indices
            for (int j = 0; j < 3; ++j) {
                final LookupTable.FracIndex fracIndex = new LookupTable.FracIndex();

                LookupTable.computeFracIndex(dimensions[j], x[j], fracIndex);
                assertEquals(fi[j].i, fracIndex.i);
                assertEquals(fi[j].f, fracIndex.f, 1.0E-10);
            }

            final double expected = r[2] + 5.0 * (r[1] + 5.0 * r[0]);
            final double a = lut.getValue(x);
            final double b = lut.getValue(fi);

            assertEquals(expected, a, 1.0E-10);
            assertEquals(expected, b, 1.0E-10);
        }
    }

}
