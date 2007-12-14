/*
    $Id: MacroPixelTest.java,v 1.9 2007-06-15 18:01:57 ralf Exp $

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

import junit.framework.TestCase;

import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.TimeZone;

/**
 * Tests for class {@link MacroPixel}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.9 $ $Date: 2007-06-15 18:01:57 $
 */
public class MacroPixelTest extends TestCase {

    private enum Layers {

        ONE, TWO}


    public void testConstruction() {
        try {
            new MacroPixel(0);
            fail();
        } catch (IllegalArgumentException expected) {
            // macro pixel size must be positive
        }

        final MacroPixel macroPixel = new MacroPixel(2);
        assertEquals(2, macroPixel.getWidth());
        assertEquals(2, macroPixel.getHeight());
        assertEquals(4, macroPixel.getPixelCount());
        assertEquals(0, macroPixel.getLayerCount());
        assertEquals("", macroPixel.getFileName());
        assertTrue(macroPixel.getLayerKeySet().isEmpty());
    }


    public void testSetGetTime() {
        final MacroPixel macroPixel = new MacroPixel(2);
        assertFalse(macroPixel.hasStartTime());
        assertFalse(macroPixel.hasEndTime());

        // Test set start time
        long millis = createCalendar(2007, 2, 22, 6, 18).getTimeInMillis();
        macroPixel.setStartTimeInMillis(millis);
        assertTrue(macroPixel.hasStartTime());

        assertEquals(millis, macroPixel.getStartTimeInMillis());
        assertEquals(2007, macroPixel.getStartYear());
        assertEquals(2, macroPixel.getStartMonth());
        assertEquals(22, macroPixel.getStartDate());
        assertEquals(6, macroPixel.getStartHour());
        assertEquals(18, macroPixel.getStartMinute());
        assertEquals(53, macroPixel.getStartDayOfYear());
        assertEquals(2007053.2625, macroPixel.getStartTimeAsDouble(), 0.0);

        // Test set end time
        millis = createCalendar(2008, 3, 23, 18, 54).getTimeInMillis();
        macroPixel.setEndTimeInMillis(millis);
        assertTrue(macroPixel.hasEndTime());

        assertEquals(millis, macroPixel.getEndTimeInMillis());
        assertEquals(2008, macroPixel.getEndYear());
        assertEquals(3, macroPixel.getEndMonth());
        assertEquals(23, macroPixel.getEndDate());
        assertEquals(18, macroPixel.getEndHour());
        assertEquals(54, macroPixel.getEndMinute());
        assertEquals(83, macroPixel.getEndDayOfYear());
        assertEquals(2008083.7875, macroPixel.getEndTimeAsDouble(), 0.0);
    }


    public void testSetGetLatitude() {
        final MacroPixel macroPixel = new MacroPixel(2);

        assertEquals(0.0, macroPixel.getLat(0), 0.0);
        assertEquals(0.0, macroPixel.getLat(1), 0.0);
        assertEquals(0.0, macroPixel.getLat(2), 0.0);
        assertEquals(0.0, macroPixel.getLat(3), 0.0);

        try {
            macroPixel.getLat(4);
            fail();
        } catch (IndexOutOfBoundsException expected) {
            // invalid pixel index
        }

        try {
            macroPixel.setLat(4, 0.0);
            fail();
        } catch (IndexOutOfBoundsException expected) {
            // invalid pixel index
        }

        try {
            macroPixel.setLat(0, 91.0);
            fail();
        } catch (IllegalArgumentException expected) {
            // latitude greater than 90.0
        }

        try {
            macroPixel.setLat(0, -91.0);
            fail();
        } catch (IllegalArgumentException expected) {
            // latitude less than -90.0
        }

        try {
            macroPixel.setLat(0, Double.NaN);
            fail();
        } catch (IllegalArgumentException expected) {
            // invalid value
        }

        try {
            macroPixel.setLat(0, Double.POSITIVE_INFINITY);
            fail();
        } catch (IllegalArgumentException expected) {
            // invalid value
        }

        try {
            macroPixel.setLat(0, Double.NEGATIVE_INFINITY);
            fail();
        } catch (IllegalArgumentException expected) {
            // invalid value
        }

        macroPixel.setLat(0, 10.0);
        macroPixel.setLat(1, 20.0);
        macroPixel.setLat(2, 30.0);
        macroPixel.setLat(3, 40.0);

        assertEquals(10.0, macroPixel.getLat(0), 0.0);
        assertEquals(20.0, macroPixel.getLat(1), 0.0);
        assertEquals(30.0, macroPixel.getLat(2), 0.0);
        assertEquals(40.0, macroPixel.getLat(3), 0.0);
    }


    public void testSetGetLongitude() {
        final MacroPixel macroPixel = new MacroPixel(2);

        assertEquals(0.0, macroPixel.getLon(0));
        assertEquals(0.0, macroPixel.getLon(1));
        assertEquals(0.0, macroPixel.getLon(2));
        assertEquals(0.0, macroPixel.getLon(3));

        try {
            macroPixel.getLon(4);
            fail();
        } catch (IndexOutOfBoundsException expected) {
            // invalid pixel index
        }

        try {
            macroPixel.setLon(4, 0.0);
            fail();
        } catch (IndexOutOfBoundsException expected) {
            // invalid pixel index
        }

        try {
            macroPixel.setLon(0, 181.0);
            fail();
        } catch (IllegalArgumentException expected) {
            // latitude greater than 90.0
        }

        try {
            macroPixel.setLon(0, -181.0);
            fail();
        } catch (IllegalArgumentException expected) {
            // latitude less than -90.0
        }

        try {
            macroPixel.setLon(0, Double.NaN);
            fail();
        } catch (IllegalArgumentException expected) {
            // invalid value
        }

        try {
            macroPixel.setLon(0, Double.POSITIVE_INFINITY);
            fail();
        } catch (IllegalArgumentException expected) {
            // invalid value
        }

        try {
            macroPixel.setLon(0, Double.NEGATIVE_INFINITY);
            fail();
        } catch (IllegalArgumentException expected) {
            // invalid value
        }

        macroPixel.setLon(0, 50.0);
        macroPixel.setLon(1, 60.0);
        macroPixel.setLon(2, 70.0);
        macroPixel.setLon(3, 80.0);

        assertEquals(50.0, macroPixel.getLon(0), 0.0);
        assertEquals(60.0, macroPixel.getLon(1), 0.0);
        assertEquals(70.0, macroPixel.getLon(2), 0.0);
        assertEquals(80.0, macroPixel.getLon(3), 0.0);
    }


    public void testAddLayer() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.addLayer(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not allowed
        }

        assertEquals(0, macroPixel.getLayerCount());
        assertTrue(macroPixel.getLayerKeySet().isEmpty());
        assertFalse(macroPixel.hasLayer(Layers.ONE));
        assertFalse(macroPixel.hasLayer(Layers.TWO));

        assertTrue(macroPixel.addLayer(Layers.ONE));
        assertFalse(macroPixel.addLayer(Layers.ONE));
        assertEquals(1, macroPixel.getLayerCount());
        assertTrue(macroPixel.getLayerKeySet().contains(Layers.ONE));
        assertTrue(macroPixel.hasLayer(Layers.ONE));
        assertFalse(macroPixel.getLayerKeySet().contains(Layers.TWO));
        assertFalse(macroPixel.hasLayer(Layers.TWO));

        assertTrue(macroPixel.addLayer(Layers.TWO));
        assertFalse(macroPixel.addLayer(Layers.TWO));
        assertEquals(2, macroPixel.getLayerCount());
        assertTrue(macroPixel.getLayerKeySet().contains(Layers.ONE));
        assertTrue(macroPixel.hasLayer(Layers.ONE));
        assertTrue(macroPixel.getLayerKeySet().contains(Layers.TWO));
        assertTrue(macroPixel.hasLayer(Layers.TWO));
    }


    public void testGetValues() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getValues(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getValues(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 2.0;
        values[2] = 3.0;
        values[3] = 4.0;

        assertEquals(1.0, macroPixel.getValues(Layers.ONE)[0], 0.0);
        assertEquals(2.0, macroPixel.getValues(Layers.ONE)[1], 0.0);
        assertEquals(3.0, macroPixel.getValues(Layers.ONE)[2], 0.0);
        assertEquals(4.0, macroPixel.getValues(Layers.ONE)[3], 0.0);
    }


    public void testGetFlags() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getFlags(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getFlags(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final int[] flags = macroPixel.getFlags(Layers.ONE);
        assertNotNull(flags);

        flags[0] = 1;
        flags[1] = 2;
        flags[2] = 4;
        flags[3] = 8;

        assertEquals(1, macroPixel.getFlags(Layers.ONE)[0]);
        assertEquals(2, macroPixel.getFlags(Layers.ONE)[1]);
        assertEquals(4, macroPixel.getFlags(Layers.ONE)[2]);
        assertEquals(8, macroPixel.getFlags(Layers.ONE)[3]);
    }


    public void testGetMean() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getMean(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getMean(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 1.0;
        values[2] = 4.0;
        values[3] = 4.0;

        assertEquals(2.5, macroPixel.getMean(Layers.ONE), 0.0);
    }


    public void testGetMedian() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getMedian(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getMedian(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 1.0;
        values[2] = 2.0;
        values[3] = 3.0;

        assertEquals(1.5, macroPixel.getMedian(Layers.ONE), 0.0);
    }


    public void testGetVariance() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getVariance(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getVariance(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 1.0;
        values[2] = 4.0;
        values[3] = 4.0;

        assertEquals(3.0, macroPixel.getVariance(Layers.ONE), 0.0);
    }


    public void testGetSDev() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getSDev(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getSDev(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 1.0;
        values[2] = 4.0;
        values[3] = 4.0;

        assertEquals(Math.sqrt(3.0), macroPixel.getSDev(Layers.ONE), 0.0);
    }


    public void testGetCV() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getCV(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getCV(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 1.0;
        values[2] = 4.0;
        values[3] = 4.0;

        assertEquals(Math.sqrt(3.0) / 2.5, macroPixel.getCV(Layers.ONE), 0.0);
    }


    public void testGetFittest() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getFittest(null, 0.0);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getFittest(Layers.ONE, 0.0);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 2.0;
        values[2] = 3.0;
        values[3] = 4.0;

        assertEquals(1.0, macroPixel.getFittest(Layers.ONE, 0.0), 0.0);
        assertEquals(4.0, macroPixel.getFittest(Layers.ONE, 5.0), 0.0);
    }


    public void testGetCount() {
        final MacroPixel<Layers> macroPixel = new MacroPixel<Layers>(2);

        try {
            macroPixel.getCount(null);
            fail();
        } catch (NullPointerException expected) {
            // null key not permitted
        }

        try {
            macroPixel.getCount(Layers.ONE);
            fail();
        } catch (IllegalArgumentException expected) {
            // illegal key
        }

        assertTrue(macroPixel.addLayer(Layers.ONE));
        final double[] values = macroPixel.getValues(Layers.ONE);
        assertNotNull(values);

        values[0] = 1.0;
        values[1] = 1.0;
        values[2] = 4.0;
        values[3] = 4.0;

        assertEquals(4, macroPixel.getCount(Layers.ONE));

        values[1] = Double.NaN;
        assertEquals(3, macroPixel.getCount(Layers.ONE));
        
        values[2] = Double.POSITIVE_INFINITY;
        assertEquals(2, macroPixel.getCount(Layers.ONE));

        values[2] = Double.NEGATIVE_INFINITY;
        assertEquals(2, macroPixel.getCount(Layers.ONE));
    }


    private Calendar createCalendar(final int year, final int month, final int day, final int hour, final int minute) {
        final Calendar calendar = new GregorianCalendar(TimeZone.getTimeZone("UTC"));

        calendar.clear();
        calendar.set(year, month - 1, day, hour, minute);

        return calendar;
    }
}
