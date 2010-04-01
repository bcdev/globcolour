/*
    $Id: StatisticsTest.java,v 1.1 2007-06-14 16:03:25 ralf Exp $

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
import org.esa.beam.globcolour.internal.Statistics;

/**
 * Test methods for class {@link Statistics}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.1 $ $Date: 2007-06-14 16:03:25 $
 */
public class StatisticsTest extends TestCase {
    private static final double DSQRT_2 = Math.sqrt(2.0);
    private static final double DSQRT_5 = Math.sqrt(5.0);

    public void testCountFloat() {
        try {
            Statistics.count((float[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertEquals(0, Statistics.count(new float[]{}));
        assertEquals(0, Statistics.count(new float[]{Float.NaN}));
        assertEquals(0, Statistics.count(new float[]{Float.POSITIVE_INFINITY}));
        assertEquals(0, Statistics.count(new float[]{Float.NEGATIVE_INFINITY}));

        assertEquals(1, Statistics.count(new float[]{1.0f}));
        assertEquals(3, Statistics.count(new float[]{1.0f, 2.0f, 3.0f}));

        assertEquals(2, Statistics.count(new float[]{1.0f, Float.NaN, 3.0f}));
        assertEquals(2, Statistics.count(new float[]{1.0f, Float.POSITIVE_INFINITY, 3.0f}));
        assertEquals(2, Statistics.count(new float[]{1.0f, Float.NEGATIVE_INFINITY, 3.0f}));
    }

    public void testCountDouble() {
        try {
            Statistics.count((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertEquals(0, Statistics.count(new double[]{}));
        assertEquals(0, Statistics.count(new double[]{Float.NaN}));
        assertEquals(0, Statistics.count(new double[]{Float.POSITIVE_INFINITY}));
        assertEquals(0, Statistics.count(new double[]{Float.NEGATIVE_INFINITY}));

        assertEquals(1, Statistics.count(new double[]{1.0}));
        assertEquals(3, Statistics.count(new double[]{1.0, 2.0, 3.0}));

        assertEquals(2, Statistics.count(new double[]{1.0, Float.NaN, 3.0}));
        assertEquals(2, Statistics.count(new double[]{1.0, Float.POSITIVE_INFINITY, 3.0}));
        assertEquals(2, Statistics.count(new double[]{1.0, Float.NEGATIVE_INFINITY, 3.0}));
    }

    public void testMeanFloat() {
        try {
            Statistics.mean((float[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.mean(new float[]{})));
        assertTrue(Double.isNaN(Statistics.mean(new float[]{Float.NaN})));
        assertTrue(Double.isNaN(Statistics.mean(new float[]{Float.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.mean(new float[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0f, Statistics.mean(new float[]{1.0f}), 0.0f);
        assertEquals(2.0f, Statistics.mean(new float[]{1.0f, 2.0f, 3.0f}), 0.0f);

        assertEquals(2.0f, Statistics.mean(new float[]{1.0f, Float.NaN, 3.0f}), 0.0f);
        assertEquals(2.0f, Statistics.mean(new float[]{1.0f, Float.POSITIVE_INFINITY, 3.0f}), 0.0f);
        assertEquals(2.0f, Statistics.mean(new float[]{1.0f, Float.NEGATIVE_INFINITY, 3.0f}), 0.0f);
    }

    public void testMeanDouble() {
        try {
            Statistics.mean((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.mean(new double[]{})));
        assertTrue(Double.isNaN(Statistics.mean(new double[]{Double.NaN})));
        assertTrue(Double.isNaN(Statistics.mean(new double[]{Double.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.mean(new double[]{Double.NEGATIVE_INFINITY})));

        assertEquals(1.0, Statistics.mean(new double[]{1.0}), 0.0);
        assertEquals(2.0, Statistics.mean(new double[]{1.0, 2.0, 3.0}), 0.0);

        assertEquals(2.0, Statistics.mean(new double[]{1.0, Double.NaN, 3.0}), 0.0);
        assertEquals(2.0, Statistics.mean(new double[]{1.0, Double.POSITIVE_INFINITY, 3.0}), 0.0);
        assertEquals(2.0, Statistics.mean(new double[]{1.0, Double.NEGATIVE_INFINITY, 3.0}), 0.0);
    }

    public void testRmsFloat() {
        try {
            Statistics.rms((float[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Float.isNaN(Statistics.rms(new float[]{})));
        assertTrue(Float.isNaN(Statistics.rms(new float[]{Float.NaN})));
        assertTrue(Float.isNaN(Statistics.rms(new float[]{Float.POSITIVE_INFINITY})));
        assertTrue(Float.isNaN(Statistics.rms(new float[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0f, Statistics.rms(new float[]{1.0f}), 0.0f);
        assertEquals((float) DSQRT_5, Statistics.rms(new float[]{1.0f, 3.0f}), 0.0f);

        assertEquals((float) DSQRT_5, Statistics.rms(new float[]{1.0f, Float.NaN, 3.0f}), 0.0f);
        assertEquals((float) DSQRT_5, Statistics.rms(new float[]{1.0f, Float.POSITIVE_INFINITY, 3.0f}), 0.0f);
        assertEquals((float) DSQRT_5, Statistics.rms(new float[]{1.0f, Float.NEGATIVE_INFINITY, 3.0f}), 0.0f);
    }

    public void testRmsDouble() {
        try {
            Statistics.rms((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.rms(new double[]{})));
        assertTrue(Double.isNaN(Statistics.rms(new double[]{Float.NaN})));
        assertTrue(Double.isNaN(Statistics.rms(new double[]{Float.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.rms(new double[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0, Statistics.rms(new double[]{1.0}), 0.0);
        assertEquals(DSQRT_5, Statistics.rms(new double[]{1.0, 3.0}), 0.0);

        assertEquals(DSQRT_5, Statistics.rms(new double[]{1.0, Float.NaN, 3.0}), 0.0);
        assertEquals(DSQRT_5, Statistics.rms(new double[]{1.0, Float.POSITIVE_INFINITY, 3.0}), 0.0);
        assertEquals(DSQRT_5, Statistics.rms(new double[]{1.0, Float.NEGATIVE_INFINITY, 3.0}), 0.0);
    }

    public void testStandardCoefficientOfVariationFloat() {
        assertEquals(0.0f, Statistics.cv(new float[]{1.0f, 1.0f}), 0.0f);
        assertEquals(0.0f, Statistics.cv(new float[]{1.0f, 1.0f, 1.0f}), 0.0f);
        assertEquals(0.5f, Statistics.cv(new float[]{1.0f, 2.0f, 3.0f}), 0.0f);

        final float cv = Statistics.cv(new float[]{1.0f, Float.NaN, 3.0f});
        assertEquals((float) (DSQRT_2 / 2.0), cv, 0.0f);
    }

    public void testStandardCoefficientOfVariationDouble() {
        assertEquals(0.0, Statistics.cv(new double[]{1.0, 1.0}), 0.0);
        assertEquals(0.0, Statistics.cv(new double[]{1.0, 1.0, 1.0}), 0.0);
        assertEquals(0.5, Statistics.cv(new double[]{1.0, 2.0, 3.0}), 0.0);

        final double cv = Statistics.cv(new double[]{1.0, Double.NaN, 3.0});
        assertEquals(DSQRT_2 / 2.0, cv, 0.0);
    }

    public void testStandardDeviationFloat() {
        assertEquals(0.0f, Statistics.sdev(new float[]{1.0f, 1.0f}), 0.0f);
        assertEquals(0.0f, Statistics.sdev(new float[]{1.0f, 1.0f, 1.0f}), 0.0f);
        assertEquals(1.0f, Statistics.sdev(new float[]{1.0f, 2.0f, 3.0f}), 0.0f);

        final float stdev = Statistics.sdev(new float[]{1.0f, Float.NaN, 3.0f});
        assertEquals((float) DSQRT_2, stdev, 0.0f);
    }

    public void testStandardDeviationDouble() {
        assertEquals(0.0, Statistics.sdev(new double[]{1.0, 1.0}), 0.0);
        assertEquals(0.0, Statistics.sdev(new double[]{1.0, 1.0, 1.0}), 0.0);
        assertEquals(1.0, Statistics.sdev(new double[]{1.0, 2.0, 3.0}), 0.0);

        final double stdev = Statistics.sdev(new double[]{1.0, Double.NaN, 3.0});
        assertEquals(DSQRT_2, stdev, 0.0);
    }

    public void testVarianceFloat() {
        try {
            Statistics.variance((float[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Float.isNaN(Statistics.variance(new float[]{})));
        assertTrue(Float.isNaN(Statistics.variance(new float[]{Float.NaN})));
        assertTrue(Float.isNaN(Statistics.variance(new float[]{Float.POSITIVE_INFINITY})));
        assertTrue(Float.isNaN(Statistics.variance(new float[]{Float.NEGATIVE_INFINITY})));

        assertTrue(Float.isNaN(Statistics.variance(new float[]{1.0f})));
        assertTrue(Float.isNaN(Statistics.variance(new float[]{1.0f, Float.NaN})));
        assertTrue(Float.isNaN(Statistics.variance(new float[]{1.0f, Float.POSITIVE_INFINITY})));
        assertTrue(Float.isNaN(Statistics.variance(new float[]{1.0f, Float.NEGATIVE_INFINITY})));

        assertEquals(0.0f, Statistics.variance(new float[]{1.0f, 1.0f}), 0.0f);
        assertEquals(0.0f, Statistics.variance(new float[]{1.0f, 1.0f, 1.0f}), 0.0f);
        assertEquals(1.0f, Statistics.variance(new float[]{1.0f, 2.0f, 3.0f}), 0.0f);

        assertEquals(2.0f, Statistics.variance(new float[]{1.0f, Float.NaN, 3.0f}), 0.0f);
        assertEquals(2.0f, Statistics.variance(new float[]{1.0f, Float.POSITIVE_INFINITY, 3.0f}), 0.0f);
        assertEquals(2.0f, Statistics.variance(new float[]{1.0f, Float.NEGATIVE_INFINITY, 3.0f}), 0.0f);
    }

    public void testVarianceDouble() {
        try {
            Statistics.variance((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.variance(new double[]{})));
        assertTrue(Double.isNaN(Statistics.variance(new double[]{Double.NaN})));
        assertTrue(Double.isNaN(Statistics.variance(new double[]{Double.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.variance(new double[]{Double.NEGATIVE_INFINITY})));

        assertTrue(Double.isNaN(Statistics.variance(new double[]{1.0})));
        assertTrue(Double.isNaN(Statistics.variance(new double[]{1.0, Double.NaN})));
        assertTrue(Double.isNaN(Statistics.variance(new double[]{1.0, Double.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.variance(new double[]{1.0, Double.NEGATIVE_INFINITY})));

        assertEquals(0.0, Statistics.variance(new double[]{1.0, 1.0}), 0.0);
        assertEquals(0.0, Statistics.variance(new double[]{1.0, 1.0, 1.0}), 0.0);
        assertEquals(1.0, Statistics.variance(new double[]{1.0, 2.0, 3.0}), 0.0);

        assertEquals(2.0, Statistics.variance(new double[]{1.0, Double.NaN, 3.0}), 0.0);
        assertEquals(2.0, Statistics.variance(new double[]{1.0, Double.POSITIVE_INFINITY, 3.0}), 0.0);
        assertEquals(2.0, Statistics.variance(new double[]{1.0, Double.NEGATIVE_INFINITY, 3.0}), 0.0);
    }

    public void testMinFloat() {
        try {
            Statistics.min((float[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Float.isNaN(Statistics.min(new float[]{})));
        assertTrue(Float.isNaN(Statistics.min(new float[]{Float.NaN})));
        assertTrue(Float.isNaN(Statistics.min(new float[]{Float.POSITIVE_INFINITY})));
        assertTrue(Float.isNaN(Statistics.min(new float[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0f, Statistics.min(new float[]{1.0f}), 0.0f);
        assertEquals(1.0f, Statistics.min(new float[]{1.0f, Float.NaN}), 0.0f);
        assertEquals(1.0f, Statistics.min(new float[]{1.0f, Float.POSITIVE_INFINITY}), 0.0f);
        assertEquals(1.0f, Statistics.min(new float[]{1.0f, Float.NEGATIVE_INFINITY}), 0.0f);

        assertEquals(1.0f, Statistics.min(new float[]{1.0f, 2.0f}), 0.0f);
        assertEquals(2.0f, Statistics.min(new float[]{3.0f, 2.0f}), 0.0f);
    }

    public void testMinDouble() {
        try {
            Statistics.min((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.min(new double[]{})));
        assertTrue(Double.isNaN(Statistics.min(new double[]{Float.NaN})));
        assertTrue(Double.isNaN(Statistics.min(new double[]{Float.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.min(new double[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0, Statistics.min(new double[]{1.0}), 0.0);
        assertEquals(1.0, Statistics.min(new double[]{1.0, Double.NaN}), 0.0);
        assertEquals(1.0, Statistics.min(new double[]{1.0, Double.POSITIVE_INFINITY}), 0.0);
        assertEquals(1.0, Statistics.min(new double[]{1.0, Double.NEGATIVE_INFINITY}), 0.0);

        assertEquals(1.0, Statistics.min(new double[]{1.0, 2.0}), 0.0);
        assertEquals(2.0, Statistics.min(new double[]{3.0, 2.0}), 0.0);
    }

    public void testMaxFloat() {
        try {
            Statistics.max((float[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Float.isNaN(Statistics.max(new float[]{})));
        assertTrue(Float.isNaN(Statistics.max(new float[]{Float.NaN})));
        assertTrue(Float.isNaN(Statistics.max(new float[]{Float.POSITIVE_INFINITY})));
        assertTrue(Float.isNaN(Statistics.max(new float[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0f, Statistics.max(new float[]{1.0f}), 0.0f);
        assertEquals(1.0f, Statistics.max(new float[]{1.0f, Float.NaN}), 0.0f);
        assertEquals(1.0f, Statistics.max(new float[]{1.0f, Float.POSITIVE_INFINITY}), 0.0f);
        assertEquals(1.0f, Statistics.max(new float[]{1.0f, Float.NEGATIVE_INFINITY}), 0.0f);

        assertEquals(2.0f, Statistics.max(new float[]{1.0f, 2.0f}), 0.0f);
        assertEquals(3.0f, Statistics.max(new float[]{3.0f, 2.0f}), 0.0f);
    }

    public void testMaxDouble() {
        try {
            Statistics.max((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.max(new double[]{})));
        assertTrue(Double.isNaN(Statistics.max(new double[]{Float.NaN})));
        assertTrue(Double.isNaN(Statistics.max(new double[]{Float.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.max(new double[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0, Statistics.max(new double[]{1.0}), 0.0);
        assertEquals(1.0, Statistics.max(new double[]{1.0, Double.NaN}), 0.0);
        assertEquals(1.0, Statistics.max(new double[]{1.0, Double.POSITIVE_INFINITY}), 0.0);
        assertEquals(1.0, Statistics.max(new double[]{1.0, Double.NEGATIVE_INFINITY}), 0.0);

        assertEquals(2.0, Statistics.max(new double[]{1.0, 2.0}), 0.0);
        assertEquals(3.0, Statistics.max(new double[]{3.0, 2.0}), 0.0);
    }

    public void testMedianFloat() {
        try {
            Statistics.median((float[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.median(new double[]{})));
        assertTrue(Double.isNaN(Statistics.median(new double[]{Float.NaN})));
        assertTrue(Double.isNaN(Statistics.median(new double[]{Float.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.median(new double[]{Float.NEGATIVE_INFINITY})));

        assertEquals(1.0f, Statistics.median(new double[]{1.0f}), 0.0f);
        assertEquals(2.0f, Statistics.median(new double[]{1.0f, 2.0f, 3.0f}), 0.0f);
        assertEquals(2.5f, Statistics.median(new double[]{1.0f, 2.0f, 3.0f, 4.0f}), 0.0f);

        assertEquals(2.0f, Statistics.median(new double[]{1.0f, Double.NaN, 3.0f}), 0.0f);
        assertEquals(2.0f, Statistics.median(new double[]{1.0f, Double.POSITIVE_INFINITY, 3.0f}), 0.0f);
        assertEquals(2.0f, Statistics.median(new double[]{1.0f, Double.NEGATIVE_INFINITY, 3.0f}), 0.0f);
    }

    public void testMedianDouble() {
        try {
            Statistics.median((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.median(new double[]{})));
        assertTrue(Double.isNaN(Statistics.median(new double[]{Double.NaN})));
        assertTrue(Double.isNaN(Statistics.median(new double[]{Double.POSITIVE_INFINITY})));
        assertTrue(Double.isNaN(Statistics.median(new double[]{Double.NEGATIVE_INFINITY})));

        assertEquals(1.0, Statistics.median(new double[]{1.0}), 0.0);
        assertEquals(2.0, Statistics.median(new double[]{1.0, 2.0, 3.0}), 0.0);
        assertEquals(2.5, Statistics.median(new double[]{1.0, 2.0, 3.0, 4.0}), 0.0);

        assertEquals(2.0, Statistics.median(new double[]{1.0, Double.NaN, 3.0}), 0.0);
        assertEquals(2.0, Statistics.median(new double[]{1.0, Double.POSITIVE_INFINITY, 3.0}), 0.0);
        assertEquals(2.0, Statistics.median(new double[]{1.0, Double.NEGATIVE_INFINITY, 3.0}), 0.0);
    }

    public void testFittestFloat() {
        try {
            Statistics.fittest(null, 0.0);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Float.isNaN(Statistics.fittest(new float[]{}, 0.0f)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{Float.NaN}, 0.0f)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{Float.POSITIVE_INFINITY}, 0.0f)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{Float.NEGATIVE_INFINITY}, 0.0f)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{1.0f}, Float.NaN)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{1.0f}, Float.POSITIVE_INFINITY)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{1.0f}, Float.NEGATIVE_INFINITY)));

        assertEquals(1.0f, Statistics.fittest(new float[]{2.0f, 1.0f, 5.0f}, 0.0f), 0.0f);
        assertEquals(2.0f, Statistics.fittest(new float[]{2.0f, 1.0f, 5.0f}, 3.0f), 0.0f);
        assertEquals(5.0f, Statistics.fittest(new float[]{2.0f, 1.0f, 5.0f}, 4.0f), 0.0f);

        assertTrue(Float.isNaN(Statistics.fittest(new float[]{2.0f, 1.0f, 5.0f}, Float.NaN)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{2.0f, 1.0f, 5.0f}, Float.POSITIVE_INFINITY)));
        assertTrue(Float.isNaN(Statistics.fittest(new float[]{2.0f, 1.0f, 5.0f}, Float.NEGATIVE_INFINITY)));

        assertEquals(1.0f, Statistics.fittest(new float[]{Float.NaN, 1.0f, 5.0f}, 0.0f), 0.0f);
        assertEquals(1.0f, Statistics.fittest(new float[]{Float.POSITIVE_INFINITY, 1.0f, 5.0f}, 0.0f), 0.0f);
        assertEquals(1.0f, Statistics.fittest(new float[]{Float.NEGATIVE_INFINITY, 1.0f, 5.0f}, 0.0f), 0.0f);
    }

    public void testFittestDouble() {
        try {
            Statistics.fittest(null, 0.0);
            fail();
        } catch (NullPointerException expected) {
        }

        assertTrue(Double.isNaN(Statistics.fittest(new double[]{}, 0.0)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{Double.NaN}, 0.0)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{Double.POSITIVE_INFINITY}, 0.0)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{Double.NEGATIVE_INFINITY}, 0.0)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{1.0}, Double.NaN)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{1.0}, Double.POSITIVE_INFINITY)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{1.0}, Double.NEGATIVE_INFINITY)));

        assertEquals(1.0, Statistics.fittest(new double[]{2.0, 1.0, 5.0}, 0.0), 0.0);
        assertEquals(2.0, Statistics.fittest(new double[]{2.0, 1.0, 5.0}, 3.0), 0.0);
        assertEquals(5.0, Statistics.fittest(new double[]{2.0, 1.0, 5.0}, 4.0), 0.0);

        assertTrue(Double.isNaN(Statistics.fittest(new double[]{2.0, 1.0, 5.0}, Double.NaN)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{2.0, 1.0, 5.0}, Double.POSITIVE_INFINITY)));
        assertTrue(Double.isNaN(Statistics.fittest(new double[]{2.0, 1.0, 5.0}, Double.NEGATIVE_INFINITY)));

        assertEquals(1.0, Statistics.fittest(new double[]{Double.NaN, 1.0, 5.0}, 0.0), 0.0);
        assertEquals(1.0, Statistics.fittest(new double[]{Double.POSITIVE_INFINITY, 1.0, 5.0}, 0.0), 0.0);
        assertEquals(1.0, Statistics.fittest(new double[]{Double.NEGATIVE_INFINITY, 1.0, 5.0}, 0.0), 0.0);
    }

    public void testMeanRelativeError() {
        try {
            Statistics.meanRelativeError(null, new double[]{0});
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.meanRelativeError(new double[]{0}, null);
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.meanRelativeError(new double[]{0}, new double[]{0, 0});
            fail();
        } catch (IllegalArgumentException expected) {
        }
        try {
            Statistics.meanRelativeError(new double[]{0, 0}, new double[]{0});
            fail();
        } catch (IllegalArgumentException expected) {
        }

        assertEquals(1.0, Statistics.meanRelativeError(new double[]{0.5}, new double[]{1.0}), 0.0);
        assertEquals(1.5, Statistics.meanRelativeError(new double[]{0.5, 1.5}, new double[]{1.0, 4.5}), 0.0);
    }

    public void testMedianRelativeError() {
        try {
            Statistics.medianRelativeError(null, new double[]{0});
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.medianRelativeError(new double[]{0}, null);
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.medianRelativeError(new double[]{0}, new double[]{0, 0});
            fail();
        } catch (IllegalArgumentException expected) {
        }
        try {
            Statistics.medianRelativeError(new double[]{0, 0}, new double[]{0});
            fail();
        } catch (IllegalArgumentException expected) {
        }

        assertEquals(1.0, Statistics.medianRelativeError(new double[]{0.5}, new double[]{1.0}), 0.0);
        assertEquals(1.5, Statistics.medianRelativeError(new double[]{0.5, 1.5}, new double[]{1.0, 4.5}), 0.0);
        assertEquals(2.0, Statistics.medianRelativeError(new double[]{0.5, 1.0, 1.5}, new double[]{1.0, 3.0, 6.0}), 0.0);
    }

    public void testMeanRatio() {
        try {
            Statistics.meanRatio(null, new double[]{0});
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.meanRatio(new double[]{0}, null);
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.meanRatio(new double[]{0}, new double[]{0, 0});
            fail();
        } catch (IllegalArgumentException expected) {
        }
        try {
            Statistics.meanRatio(new double[]{0, 0}, new double[]{0});
            fail();
        } catch (IllegalArgumentException expected) {
        }

        assertEquals(2.0, Statistics.meanRatio(new double[]{0.5}, new double[]{1.0}), 0.0);
        assertEquals(1.0, Statistics.meanRatio(new double[]{0.5, 1.0}, new double[]{1.0, 0.0}), 0.0);
    }

    public void testMedianRatio() {
        try {
            Statistics.medianRatio(null, new double[]{0});
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.medianRatio(new double[]{0}, null);
            fail();
        } catch (NullPointerException expected) {
        }
        try {
            Statistics.medianRatio(new double[]{0}, new double[]{0, 0});
            fail();
        } catch (IllegalArgumentException expected) {
        }
        try {
            Statistics.medianRatio(new double[]{0, 0}, new double[]{0});
            fail();
        } catch (IllegalArgumentException expected) {
        }

        assertEquals(2.0, Statistics.medianRatio(new double[]{0.5}, new double[]{1.0}), 0.0);
        assertEquals(1.0, Statistics.medianRatio(new double[]{0.5, 1.0}, new double[]{1.0, 0.0}), 0.0);
        assertEquals(1.5, Statistics.medianRatio(new double[]{0.5, 1.0, 2.0}, new double[]{1.0, 0.0, 3.0}), 0.0);
    }
}
