/*
    $Id: Statistics.java,v 1.1 2007-06-14 16:03:25 ralf Exp $

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

import java.util.Arrays;

/**
 * The class {@code Statistics} is a utility class providing some statistical
 * functions.
 *
 * @author Ralf Quast
 * @version $Revision: 1.1 $ $Date: 2007-06-14 16:03:25 $
 */
public class Statistics {

    /**
     * Returns the number of values in an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the number of values.
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static int count(final float[] values) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        int count = 0;
        for (final float value : values) {
            if (isValid(value)) {
                ++count;
            }
        }

        return count;
    }

    /**
     * Returns the number of values in an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the number of values.
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static int count(final double[] values) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        int count = 0;
        for (final double value : values) {
            if (isValid(value)) {
                ++count;
            }
        }

        return count;
    }

    /**
     * Returns the mean of an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the mean value (or {@link Float#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float mean(float[] values) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        float sum = 0.0f;
        int count = 0;

        for (final float value : values) {
            if (isValid(value)) {
                sum += value;
                ++count;
            }
        }

        return sum / count;
    }

    /**
     * Returns the mean of an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the mean value (or {@link Double#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double mean(final double[] values) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        double sum = 0.0;
        int count = 0;

        for (final double value : values) {
            if (isValid(value)) {
                sum += value;
                ++count;
            }
        }

        return sum / count;
    }

    /**
     * Returns the root mean square (RMS) of an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the RMS value (or {@link Float#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float rms(final float[] values) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        float sum = 0.0f;
        int count = 0;

        for (final float value : values) {
            if (isValid(value)) {
                sum += value * value;
                ++count;
            }
        }

        return (float) Math.sqrt(sum / count);
    }

    /**
     * Returns the root mean square (RMS) of an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the RMS value (or {@link Double#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double rms(final double[] values) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        double sum = 0.0;
        int count = 0;

        for (final double value : values) {
            if (isValid(value)) {
                sum += value * value;
                ++count;
            }
        }

        return Math.sqrt(sum / count);
    }

    /**
     * Returns the standard deviation of an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the standard deviation (or {@link Float#NaN} if {@code values} is empty or
     *         contains less than two valid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float sdev(float[] values) throws NullPointerException {
        return (float) Math.sqrt(variance(values));
    }

    /**
     * Returns the standard deviation of an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the standard deviation (or {@link Double#NaN} if {@code values} is empty or
     *         includes less than two valid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double sdev(double[] values) throws NullPointerException {
        return Math.sqrt(variance(values));
    }

    /**
     * Returns the variance of an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     * <p/>
     * To minimize the roundoff error, the implementation uses the <em>corrected two-pass
     * algorithm</em> described by e.g. Press et al. (2002, Numerical Recipes).
     *
     * @param values the values.
     * @return the variance (or {@link Float#NaN} if {@code values} is empty or
     *         includes less than two valid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float variance(final float[] values) throws NullPointerException {
        return variance(values, mean(values));
    }

    private static float variance(final float[] values, final float mean) {
        float var = 0.0f;
        float sum = 0.0f;
        int count = 0;

        for (final float value : values) {
            if (isValid(value)) {
                final float d = value - mean;
                sum += d;
                var += d * d;

                ++count;
            }
        }

        return (var - sum * sum / count) / (count - 1);
    }

    /**
     * Returns the variance of an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     * <p/>
     * To minimize the roundoff error, the implementation uses the <em>corrected two-pass
     * algorithm</em> described by e.g. Press et al. (2002, Numerical Recipes).
     *
     * @param values the values.
     * @return the variance (or {@link Double#NaN} if {@code values} is empty or
     *         includes less than two valid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double variance(final double[] values) throws NullPointerException {
        return variance(values, mean(values));
    }

    private static double variance(final double[] values, final double mean) {
        double var = 0.0;
        double sum = 0.0;
        int count = 0;

        for (final double value : values) {
            if (isValid(value)) {
                final double d = value - mean;
                sum += d;
                var += d * d;

                ++count;
            }
        }

        return (var - sum * sum / count) / (count - 1);
    }

    /**
     * Returns the minimum of an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the minimum value (or {@link Float#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float min(final float[] values) {
        if (values == null) {
            throw new NullPointerException("values");
        }

        float min = Float.POSITIVE_INFINITY;

        for (final float value : values) {
            if (isValid(value)) {
                if (value < min) {
                    min = value;
                }
            }

        }
        if (Float.isInfinite(min)) {
            min = Float.NaN;
        }

        return min;
    }

    /**
     * Returns the minimum of an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the minimum value (or {@link Double#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double min(final double[] values) {
        if (values == null) {
            throw new NullPointerException("values");
        }

        double min = Double.POSITIVE_INFINITY;

        for (final double value : values) {
            if (isValid(value)) {
                if (value < min) {
                    min = value;
                }
            }

        }
        if (Double.isInfinite(min)) {
            min = Double.NaN;
        }

        return min;
    }

    /**
     * Returns the maximum of an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the maximum value (or {@link Float#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float max(final float[] values) {
        if (values == null) {
            throw new NullPointerException("values");
        }

        float max = Float.NEGATIVE_INFINITY;

        for (final float value : values) {
            if (isValid(value)) {
                if (value > max) {
                    max = value;
                }
            }

        }
        if (Float.isInfinite(max)) {
            max = Float.NaN;
        }

        return max;
    }

    /**
     * Returns the maximum of an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the maximum value (or {@link Double#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double max(final double[] values) {
        if (values == null) {
            throw new NullPointerException("values");
        }

        double max = Double.NEGATIVE_INFINITY;

        for (final double value : values) {
            if (isValid(value)) {
                if (value > max) {
                    max = value;
                }
            }

        }
        if (Double.isInfinite(max)) {
            max = Double.NaN;
        }

        return max;
    }

    /**
     * Returns the coefficient of variation for an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the coefficient of variation (or {@link Float#NaN} if {@code values} is empty or
     *         includes less than two valid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float cv(final float[] values) throws NullPointerException {
        final float mean = mean(values);
        final float sdev = (float) Math.sqrt(variance(values, mean));

        return sdev / mean;
    }

    /**
     * Returns the coefficient of variation for an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the coefficient of variation (or {@link Double#NaN} if {@code values} is empty or
     *         includes less than two valid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double cv(final double[] values) throws NullPointerException {
        final double mean = mean(values);
        final double sdev = Math.sqrt(variance(values, mean));

        return sdev / mean;
    }

    /**
     * Returns the value which minimizes the distance to a given target value. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @param target the target value.
     * @return the value which minimizes the distance to the target value (or {@link Float#NaN}
     *         if there is no such value).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float fittest(final float[] values, final float target) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        float fittest = Float.NaN;
        float d = Float.POSITIVE_INFINITY;

        for (final float value : values) {
            if (isValid(value)) {
                final float d2 = Math.abs(value - target);

                if (d2 < d) {
                    d = d2;
                    fittest = value;
                }
            }

        }

        return fittest;
    }

    /**
     * Returns the value which minimizes the distance to a given target value.
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @param target the target value.
     * @return the value which minimizes the distance to the target value (or {@link Double#NaN}
     *         if there is no such value).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double fittest(final double[] values, final double target) throws NullPointerException {
        if (values == null) {
            throw new NullPointerException("values");
        }

        double fittest = Double.NaN;
        double d = Double.POSITIVE_INFINITY;

        for (final double value : values) {
            if (isValid(value)) {
                final double d2 = Math.abs(value - target);

                if (d2 < d) {
                    d = d2;
                    fittest = value;
                }
            }

        }

        return fittest;
    }


    /**
     * Returns the median of an array of {@code float} values. The internal
     * {@link Float#NaN}, {@link Float#POSITIVE_INFINITY} and {@link Float#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the median value (or {@link Float#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static float median(final float[] values) {
        final int count = count(values);
        final float[] floats = new float[count];

        for (int i = 0, j = 0; j < count; ++i) {
            if (isValid(values[i])) {
                floats[j++] = values[i];
            }
        }

        float median = Float.NaN;

        if (count > 0) {
            final int half = count >> 1;
            Arrays.sort(floats);

            if (half << 1 == count) {
                // even
                median = (float) (0.5 * (floats[half - 1] + floats[half]));
            } else {
                // odd
                median = floats[half];
            }
        }

        return median;
    }


    /**
     * Returns the median of an array of {@code double} values. The internal
     * {@link Double#NaN}, {@link Double#POSITIVE_INFINITY} and {@link Double#NEGATIVE_INFINITY}
     * are interpreted as missing values.
     *
     * @param values the values.
     * @return the median value (or {@link Double#NaN} if {@code values} is empty or
     *         includes only invalid values).
     * @throws NullPointerException if {@code values} is {@code null}.
     */
    public static double median(final double[] values) {
        final int count = count(values);
        final double[] doubles = new double[count];

        for (int i = 0, j = 0; j < count; ++i) {
            if (isValid(values[i])) {
                doubles[j++] = values[i];
            }
        }

        double median = Double.NaN;

        if (count > 0) {
            final int half = count >> 1;
            Arrays.sort(doubles);

            if (half << 1 == count) {
                // even
                median = 0.5 * (doubles[half - 1] + doubles[half]);
            } else {
                // odd
                median = doubles[half];
            }
        }

        return median;
    }

    /**
     * TODO - complete
     *
     * @param x
     * @param y
     * @return the mean relative error.
     */
    public static double meanRelativeError(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] errors = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            errors[i] = Math.abs((y[i] - x[i]) / x[i]);
        }

        return mean(errors);
    }

    /**
     * TODO - complete
     *
     * @param x
     * @param y
     * @return the median relative error.
     */
    public static double medianRelativeError(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] errors = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            errors[i] = Math.abs((y[i] - x[i]) / x[i]);
        }

        return median(errors);
    }

    /**
     * TODO - complete
     *
     * @param x
     * @param y
     * @return the mean ratio.
     */
    public static double meanRatio(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] ratios = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            ratios[i] = y[i] / x[i];
        }

        return mean(ratios);
    }

    /**
     * TODO - complete
     *
     * @param x
     * @param y
     * @return the median ratio.
     */
    public static double medianRatio(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] ratios = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            ratios[i] = y[i] / x[i];
        }

        return median(ratios);
    }

    /**
     * TODO -complete
     *
     * @param x
     * @param y
     * @return the mean difference.
     */
    public static double meanDifference(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] diffs = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            diffs[i] = y[i] - x[i];
        }

        return mean(diffs);
    }

    /**
     * TODO - complete
     *
     * @param x
     * @param y
     * @return the mean difference of logarithms.
     */
    public static double meanDifferenceLog(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] diffs = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            diffs[i] = Math.log(y[i]) - Math.log(x[i]);
        }

        return mean(diffs);
    }

    /**
     * TODO - complete
     *
     * @param x
     * @param y
     * @return the RMS difference.
     */
    public static double rmsDifference(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] diffs = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            diffs[i] = y[i] - x[i];
        }

        return rms(diffs);
    }

    /**
     * TODO - complete
     *
     * @param x
     * @param y
     * @return the RMS difference of logarithms.
     */
    public static double rmsDifferenceLog(final double[] x, final double[] y) {
        ensureNotNullAndEqualLength(x, y);
        final double[] diffs = new double[x.length];

        for (int i = 0; i < x.length; ++i) {
            diffs[i] = Math.log(y[i]) - Math.log(x[i]);
        }

        return rms(diffs);
    }

    private static void ensureNotNullAndEqualLength(final double[] x, final double[] y) {
        if (x == null) {
            throw new NullPointerException("x == null");
        }
        if (y == null) {
            throw new NullPointerException("y == null");
        }
        if (x.length != y.length) {
            throw new IllegalArgumentException("x.length != y.length");
        }
    }

    private static boolean isValid(float value) {
        return !(Float.isNaN(value) || Float.isInfinite(value));
    }

    private static boolean isValid(final double value) {
        return !(Double.isNaN(value) || Double.isInfinite(value));
    }

}
