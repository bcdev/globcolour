/*
    $Id: MacroPixel.java,v 1.16 2007-06-15 16:49:51 ralf Exp $

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
package org.esa.beam.globcolour.tools;

import org.esa.beam.globcolour.internal.Statistics;

import java.util.*;

/**
 * The class {@code MacroPixel} is a representation of a macro pixel. Macro pixels
 * are used by the GlobColour validation team for comparison with in-situ measurement
 * data.
 *
 * @author Ralf Quast
 * @version $Revision: 1.16 $ $Date: 2007-06-15 16:49:51 $
 */
class MacroPixel<K> {

    private int width;
    private int height;

    private int pixelCount;

    private Calendar startTime;
    private Calendar endTime;

    private double[] lats;
    private double[] lons;
    private String fileName;


    private static class Layer {

        /**
         * Constructs a new layer.
         *
         * @param pixelCount the number of pixels in the layer.
         * @throws NegativeArraySizeException if {@code pixelCount} is a negative number.
         */
        public Layer(final int pixelCount) {
            values = new double[pixelCount];
            flags = new int[pixelCount];
        }

        private double[] values;
        private int[] flags;
    }

    private Map<K, Layer> layerMap = new HashMap<K, Layer>();


    /**
     * Constructs a new macro pixel.
     *
     * @param width  the width of the macro pixel (in pixels).
     * @param height the heigth of the macro pixel (in pixels).
     * @throws IllegalArgumentException if {@code width} or {@code height} is nonpositive.
     */
    private MacroPixel(final int width, final int height) {
        if (width < 1) {
            throw new IllegalArgumentException("width < 1");
        }
        if (height < 1) {
            throw new IllegalArgumentException("height < 1");
        }

        this.width = width;
        this.height = height;

        pixelCount = width * height;

        lats = new double[pixelCount];
        lons = new double[pixelCount];

        fileName = "";
    }


    /**
     * Constructs a new macro pixel.
     *
     * @param length the side length the macro pixel (in pixels). The new
     *               macro pixel will consist of {@code length} pixels squared.
     * @throws IllegalArgumentException if {@code length} is nonpositive.
     */
    public MacroPixel(final int length) {
        this(length, length);
    }

    public void setProdutFilename(String name) {
        fileName = name;
    }

    public String getFileName() {
        return fileName;
    }

    /**
     * Returns the width of the macro pixel (in pixels).
     *
     * @return the width.
     */
    public final int getWidth() {
        return width;
    }


    /**
     * Returns the height of the macro pixel (in pixels).
     *
     * @return the height.
     */
    public int getHeight() {
        return height;
    }


    /**
     * Returns the number of pixels within the macro pixel.
     *
     * @return the number of pixels.
     */
    public final int getPixelCount() {
        return pixelCount;
    }


    /**
     * Returns the number of measurement layers constituting the macro pixel.
     *
     * @return the number of measurement layers.
     */
    public final int getLayerCount() {
        return layerMap.size();
    }


    /**
     * Returns a {@link Set} view of the layers contained in the macro pixel.
     *
     * @return a set view of the keys contained in the macro pixel.
     * @see Map
     */
    public final Set<K> getLayerKeySet() {
        return layerMap.keySet();
    }


    /**
     * Tests if the macro pixel has a certain measurement layer.
     *
     * @param key the key of the measurement layer.
     * @return {@code true} if the macro pixel has a layer associated with the given key,
     *         {@code false} otherwise.
     * @throws NullPointerException if {@code key} is {@code null}.
     */
    public final boolean hasLayer(final K key) {
        if (key == null) {
            throw new NullPointerException("key == null");
        }

        return layerMap.containsKey(key);
    }


    /**
     * Tests if the macro pixel has a start time.
     *
     * @return {@code true} if the macro pixel has a start time,
     *         {@code false} otherwise.
     */
    public final boolean hasStartTime() {
        return startTime != null;
    }


    /**
     * Tests if the macro pixel has an end time.
     *
     * @return {@code true} if the macro pixel has an end time,
     *         {@code false} otherwise.
     */
    public final boolean hasEndTime() {
        return endTime != null;
    }


    /**
     * Returns the start time associated with the macro pixel expressed in milliseconds
     * since 01 January 1970 00:00:00.
     *
     * @return the start time expressed in milliseconds.
     * @throws IllegalStateException if macro pixel has no start time.
     */
    public final long getStartTimeInMillis() {
        return startTime.getTimeInMillis();
    }


    /**
     * Returns the end time associated with the macro pixel expressed in milliseconds
     * since 01 January 1970 00:00:00.
     *
     * @return the end time expressed in milliseconds.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final long getEndTimeInMillis() {
        return endTime.getTimeInMillis();
    }


    /**
     * Sets the start time associated with the macro pixel.
     *
     * @param millis the start time expressed in milliseconds since 01 January 1970 00:00:00 UTC.
     */
    public void setStartTimeInMillis(final long millis) {
        if (startTime == null) {
            startTime = new GregorianCalendar(TimeZone.getTimeZone("UTC"), Locale.ENGLISH);
        }

        startTime.setTimeInMillis(millis);
    }


    /**
     * Sets the end time associated with the macro pixel.
     *
     * @param millis the end time expressed in milliseconds since 01 January 1970 00:00:00 UTC.
     */
    public void setEndTimeInMillis(final long millis) {
        if (endTime == null) {
            endTime = new GregorianCalendar(TimeZone.getTimeZone("UTC"), Locale.ENGLISH);
        }

        endTime.setTimeInMillis(millis);
    }


    /**
     * Returns the start year associated with the macro pixel.
     *
     * @return the start year.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getStartYear() {
        return startTime.get(Calendar.YEAR);
    }


    /**
     * Returns the end year associated with the macro pixel.
     *
     * @return the end year.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getEndYear() {
        return endTime.get(Calendar.YEAR);
    }


    /**
     * Returns the start month associated with the macro pixel.
     *
     * @return the start month.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getStartMonth() {
        return startTime.get(Calendar.MONTH) + 1;
    }


    /**
     * Returns the end month associated with the macro pixel.
     *
     * @return the end month.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getEndMonth() {
        return endTime.get(Calendar.MONTH) + 1;
    }


    /**
     * Returns the start date (day of month) associated with the macro pixel.
     *
     * @return the start date.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getStartDate() {
        return startTime.get(Calendar.DATE);
    }


    /**
     * Returns the end date (day of month) associated with the macro pixel.
     *
     * @return the end date.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getEndDate() {
        return endTime.get(Calendar.DATE);
    }


    /**
     * The start hour (of day) associated with the macro pixel.
     *
     * @return the start hour (of day).
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getStartHour() {
        return startTime.get(Calendar.HOUR_OF_DAY);
    }


    /**
     * The end hour (of day) associated with the macro pixel.
     *
     * @return the end hour (of day).
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getEndHour() {
        return endTime.get(Calendar.HOUR_OF_DAY);
    }

    /**
     * The start minute associated with the macro pixel.
     *
     * @return the start minute.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getStartMinute() {
        return startTime.get(Calendar.MINUTE);
    }


    /**
     * The end minute associated with the macro pixel.
     *
     * @return the end minute.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getEndMinute() {
        return endTime.get(Calendar.MINUTE);
    }


    /**
     * The start day of year associated with the macro pixel.
     *
     * @return the start day of year.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getStartDayOfYear() {
        return startTime.get(Calendar.DAY_OF_YEAR);
    }


    /**
     * The end day of year associated with the macro pixel.
     *
     * @return the end day of year.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public final int getEndDayOfYear() {
        return endTime.get(Calendar.DAY_OF_YEAR);
    }


    /**
     * Returns the start time associated with the macro pixel expressed as real
     * number. The result is equal to the value of the expression:
     * <p/>
     * {@code 1000.0 * YEAR + DAY_OF_YEAR + HOUR_OF_DAY / 24.0 + MINUTE / 1440.0}
     *
     * @return the start time expressed as real number.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public double getStartTimeAsDouble() {
        return 1000.0 * getStartYear() + getStartDayOfYear() + getStartHour() / 24.0 + getStartMinute() / 1440.0;
    }


    /**
     * Returns the end time associated with the macro pixel expressed as real
     * number. The result is equal to the value of the expression:
     * <p/>
     * {@code 1000.0 * YEAR + DAY_OF_YEAR + HOUR_OF_DAY / 24.0 + MINUTE / 1440.0}
     *
     * @return the end time expressed as real number.
     * @throws IllegalStateException if macropixel has no start time.
     */
    public double getEndTimeAsDouble() {
        return 1000.0 * getEndYear() + getEndDayOfYear() + getEndHour() / 24.0 + getEndMinute() / 1440.0;
    }


    /**
     * Returns the latitude (degrees) associated with a pixel of interest within
     * the macro pixel.
     *
     * @param i the index number of the pixel of interest.
     * @return the latitude (degrees).
     * @throws IndexOutOfBoundsException if {@code i} is not a valid pixel index number.
     */
    public final double getLat(final int i) {
        return lats[i];
    }

    /**
     * Sets the latitude (degrees) associated with a pixel of interest within
     * the macro pixel.
     *
     * @param i   the index number of the pixel of interest.
     * @param lat the latitude (degrees).
     * @throws IllegalArgumentException  if {@code lat} is {@link Double#NaN} or
     *                                   {@code abs(lat)} is greater than 90.
     * @throws IndexOutOfBoundsException if {@code i} is not a valid pixel index number.
     */
    public final void setLat(final int i, final double lat) throws IllegalArgumentException {
        if (Double.isNaN(lat)) {
            throw new IllegalArgumentException("lat == NaN");
        }
        if (Math.abs(lat) > 90.0) {
            throw new IllegalArgumentException("abs(lat) > 90.0");
        }

        lats[i] = lat;
    }


    /**
     * Returns the longitude (degrees) associated with a pixel of interest within
     * the macro pixel.
     *
     * @param i the row index number of the pixel of interest.
     * @return the longitude (degrees).
     * @throws IndexOutOfBoundsException if {@code i} is not a valid pixel index number.
     */
    public final double getLon(final int i) {
        return lons[i];
    }


    /**
     * Sets the longitude (degrees) associated with a pixel of interest within
     * the macro pixel.
     *
     * @param i   the row index number of the pixel of interest.
     * @param lon the longitude (degrees).
     * @throws IllegalArgumentException  if {@code lon} is {@link Double#NaN} or
     *                                   {@code abs(lon)} is greater than 180.
     * @throws IndexOutOfBoundsException if {@code i} is not a valid pixel index number.
     */
    public void setLon(final int i, final double lon) {
        if (Double.isNaN(lon)) {
            throw new IllegalArgumentException("lon == NaN");
        }
        if (Math.abs(lon) > 180.0) {
            throw new IllegalArgumentException("abs(lon) > 180.0");
        }

        lons[i] = lon;
    }


    /**
     * Returns the values for a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the array of measurement values.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public double[] getValues(final K key) {
        if (hasLayer(key)) {
            return layerMap.get(key).values;
        }

        throw new IllegalArgumentException("No such layer");
    }


    /**
     * Returns the flags for a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the array of measurement flags.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public int[] getFlags(final K key) {
        if (hasLayer(key)) {
            return layerMap.get(key).flags;
        }

        throw new IllegalArgumentException("No such layer");
    }


    /**
     * Adds a new measurement layer. If the layer is already present, the
     * macro pixel object is not modified.
     *
     * @param key the key of the new layer.
     * @return {@code true} if the layer has been added, {@code false} otherwise.
     * @throws NullPointerException if {@code key} is {@code null}.
     */
    public boolean addLayer(final K key) {
        if (hasLayer(key)) {
            return false;
        }
        layerMap.put(key, new Layer(pixelCount));

        return true;
    }


    /**
     * Returns the mean value of a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the mean value.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public final double getMean(final K key) {
        if (hasLayer(key)) {
            return Statistics.mean(layerMap.get(key).values);
        }

        throw new IllegalArgumentException("No such layer.");
    }


    /**
     * Returns the variance of a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the variance.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public final double getVariance(final K key) {
        if (hasLayer(key)) {
            return Statistics.variance(layerMap.get(key).values);
        }

        throw new IllegalArgumentException("No such layer.");
    }


    /**
     * Returns the median of a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the median.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public double getMedian(final K key) {
        if (hasLayer(key)) {
            return Statistics.median(layerMap.get(key).values);
        }

        throw new IllegalArgumentException("No such layer.");
    }


    /**
     * Returns the standard deviation of the values for a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the standard deviation.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public double getSDev(final K key) {
        if (hasLayer(key)) {
            return Statistics.sdev(layerMap.get(key).values);
        }

        throw new IllegalArgumentException("No such layer.");
    }


    /**
     * Returns the coefficient of variation for a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the coefficient of variation.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public double getCV(final K key) {
        if (hasLayer(key)) {
            return Statistics.cv(layerMap.get(key).values);
        }

        throw new IllegalArgumentException("No such layer.");
    }


    /**
     * Returns the value which minimizes the distance to a given target value.
     *
     * @param key   the key of the layer of interest.
     * @param value the target value.
     * @return the value which minimizes the distance to the target value.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public double getFittest(final K key, final double value) {
        if (hasLayer(key)) {
            return Statistics.fittest(layerMap.get(key).values, value);
        }

        throw new IllegalArgumentException("No such layer.");
    }


    /**
     * Returns the number of valid values in a measurement layer of interest.
     *
     * @param key the key of the layer of interest.
     * @return the number of valid values.
     * @throws IllegalArgumentException if {@code key} does not represent a layer.
     * @throws NullPointerException     if {@code key} is {@code null}.
     */
    public int getCount(final K key) {
        if (hasLayer(key)) {
            return Statistics.count(layerMap.get(key).values);
        }

        throw new IllegalArgumentException("No such layer.");
    }

}
