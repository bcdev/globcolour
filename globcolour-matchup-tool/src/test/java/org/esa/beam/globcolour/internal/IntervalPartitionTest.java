/*
    $Id: IntervalPartitionTest.java,v 1.1 2007-06-14 16:44:43 ralf Exp $

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

/**
 * Test methods for class {@link IntervalPartition}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.1 $ $Date: 2007-06-14 16:44:43 $
 */
public class IntervalPartitionTest extends TestCase {

    public void testConstructor() {
        try {
            new IntervalPartition(null);
            fail();
        } catch (NullPointerException expected) {
        }

        try {
            new IntervalPartition(new double[0]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            new IntervalPartition(new double[2]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            new IntervalPartition(1.0, 0.0);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        IntervalPartition partition = new IntervalPartition(0.0, 1.0);

        assertEquals(2, partition.getCardinal());

        assertEquals(0.0, partition.get(0), 0.0);
        assertEquals(1.0, partition.get(1), 0.0);
    }

    public void testCreateArray() {
        try {
            IntervalPartition.createArray((double[]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        try {
            IntervalPartition.createArray(new double[0]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            IntervalPartition.createArray(new double[2]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            IntervalPartition.createArray(new double[]{1.0, 0.0});
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            IntervalPartition.createArray((double[][]) null);
            fail();
        } catch (NullPointerException expected) {
        }

        try {
            IntervalPartition.createArray(new double[0][]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            IntervalPartition.createArray(new double[1][0]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            IntervalPartition.createArray(new double[1][2]);
            fail();
        } catch (IllegalArgumentException expected) {
        }

        try {
            IntervalPartition.createArray(new double[]{0.0, 1.0}, new double[]{1.0, 0.0});
            fail();
        } catch (IllegalArgumentException expected) {
        }

        final IntervalPartition[] partitions = IntervalPartition.createArray(new double[]{0.0, 1.0}, new double[]{2.0, 3.0});

        assertEquals(2, partitions.length);

        assertEquals(2, partitions[0].getCardinal());
        assertEquals(2, partitions[1].getCardinal());

        assertEquals(0.0, partitions[0].get(0), 0.0);
        assertEquals(1.0, partitions[0].get(1), 0.0);
        assertEquals(2.0, partitions[1].get(0), 0.0);
        assertEquals(3.0, partitions[1].get(1), 0.0);
    }
}
