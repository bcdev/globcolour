/*
    $Id: SimpleLinearRegressionTest.java,v 1.1 2007-06-14 16:03:25 ralf Exp $

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
import org.esa.beam.globcolour.internal.SimpleLinearRegression;

/**
 * Test methods for class {@link SimpleLinearRegression}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.1 $ $Date: 2007-06-14 16:03:25 $
 */
public class SimpleLinearRegressionTest extends TestCase {

    public void testConstruction() {
        try {
            new SimpleLinearRegression(null, new double[]{0, 0, 0});
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            new SimpleLinearRegression(new double[]{0, 0, 0}, null);
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            new SimpleLinearRegression(new double[0], new double[]{0, 0, 0});
            fail();
        } catch (IllegalArgumentException expected) {
        }
        try {
            new SimpleLinearRegression(new double[]{0, 0, 0}, new double[0]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        final SimpleLinearRegression r = new SimpleLinearRegression(new double[]{0, 0, 0},
                new double[]{0, 0, 0});

        assertEquals(3, r.getCount());
    }

    /**
     * Tests cases where no valid (x, y) pair is provided.
     */
    public void testNoPointRegression() {
        final SimpleLinearRegression r = new SimpleLinearRegression(new double[]{Double.NaN},
                new double[]{Double.NaN});

        assertEquals(0, r.getCount());
        assertTrue(Double.isNaN(r.getRSquared()));
        assertTrue(Double.isNaN(r.getIntercept()));
        assertTrue(Double.isNaN(r.getSlope()));

        final SimpleLinearRegression r2 = new SimpleLinearRegression(new double[]{Double.POSITIVE_INFINITY},
                new double[]{Double.NaN});

        assertEquals(0, r2.getCount());
        assertTrue(Double.isNaN(r2.getRSquared()));
        assertTrue(Double.isNaN(r2.getIntercept()));
        assertTrue(Double.isNaN(r2.getSlope()));

        final SimpleLinearRegression r3 = new SimpleLinearRegression(new double[]{Double.NEGATIVE_INFINITY},
                new double[]{Double.NaN});

        assertEquals(0, r3.getCount());
        assertTrue(Double.isNaN(r3.getRSquared()));
        assertTrue(Double.isNaN(r3.getIntercept()));
        assertTrue(Double.isNaN(r3.getSlope()));
    }

    /**
     * Tests cases where only one valid (x, y) pair is provided.
     */
    public void testOnePointRegression() {
        final SimpleLinearRegression r = new SimpleLinearRegression(new double[]{0},
                new double[]{0});

        assertEquals(1, r.getCount());
        assertTrue(Double.isNaN(r.getRSquared()));
        assertTrue(Double.isNaN(r.getIntercept()));
        assertTrue(Double.isNaN(r.getSlope()));
    }

    /**
     * Tests cases where only two valid (x, y) pairs are provided.
     */
    public void testTwoPointRegression() {
        final SimpleLinearRegression r = new SimpleLinearRegression(new double[]{0, 1},
                new double[]{0, 1});

        assertEquals(2, r.getCount());
        assertEquals(1.0, r.getRSquared(), 0.0);
        assertEquals(0.0, r.getIntercept(), 0.0);
        assertEquals(1.0, r.getSlope(), 0.0);
    }

    /**
     * Tests trivial cases where all points form a straight line or a square.
     */
    public void testTrivialRegressions() {
        // An ascending straight line
        final SimpleLinearRegression r = new SimpleLinearRegression(new double[]{0, 1, 2},
                new double[]{0, 1, 2});

        assertEquals(3, r.getCount());
        assertEquals(1.0, r.getRSquared(), 0.0);
        assertEquals(0.0, r.getIntercept(), 0.0);
        assertEquals(1.0, r.getSlope(), 0.0);

        // A descending straight line
        final SimpleLinearRegression r2 = new SimpleLinearRegression(new double[]{0, 1, 2},
                new double[]{2, 1, 0});

        assertEquals(3, r2.getCount());
        assertEquals(1.0, r2.getRSquared(), 0.0);
        assertEquals(2.0, r2.getIntercept(), 0.0);
        assertEquals(-1.0, r2.getSlope(), 0.0);

        // A square
        final SimpleLinearRegression r3 = new SimpleLinearRegression(new double[]{0, 0, 1, 1},
                new double[]{0, 1, 0, 1});

        assertEquals(4, r3.getCount());
        assertEquals(0.0, r3.getRSquared(), 0.0);
        assertEquals(0.5, r3.getIntercept(), 0.0);
        assertEquals(0.0, r3.getSlope(), 0.0);
    }

    /**
     * Performs a test using Example 11.1 of Mendenhall & Sincich (1995, Statistics for Engineering
     * and the Sciences) as reference.
     */
    public void testTextbookExample() {
        final SimpleLinearRegression r = new SimpleLinearRegression(new double[]{1, 2, 3, 4, 5},
                new double[]{1, 1, 2, 2, 4});

        assertEquals(5, r.getCount());
        assertEquals(4.9 / 6.0, r.getRSquared(), 0.0);
        assertEquals(-0.1, r.getIntercept(), 0.0);
        assertEquals(0.7, r.getSlope(), 0.0);
    }
}
