/*
    $Id: BinnedProductReaderTest.java,v 1.2 2007-06-14 17:42:32 ralf Exp $

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
package org.esa.beam.dataio.globcolour;

import junit.framework.TestCase;

/**
 * Test methods for class {@link BinnedProductReader}.
 *
 * @author Norman Fomferra
 * @author Ralf Quast
 * @version $Revision: 1.2 $ $Date: 2007-06-14 17:42:32 $
 */
public class BinnedProductReaderTest extends TestCase {

    // GlobColour Technical Specification
    private static final int ROW_COUNT_SPEC = 4320;
    private static final int TOTAL_BIN_COUNT_SPEC = 23761676;
    private static final int POLE_BIN_COUNT_SPEC = 3;
    private static final int EQUATOR_BIN_COUNT_SPEC = 8640;

    public void testIsinGrid() {
        final IsinGrid ig = BinnedProductReader.IG;

        assertEquals(ROW_COUNT_SPEC, ig.getRowCount());
        assertEquals(TOTAL_BIN_COUNT_SPEC, ig.getBinCount());

        final int southPoleRow = 0;
        final int northPoleRow = ROW_COUNT_SPEC - 1;

        assertEquals(POLE_BIN_COUNT_SPEC, ig.getColCount(southPoleRow));
        assertEquals(POLE_BIN_COUNT_SPEC, ig.getColCount(northPoleRow));

        final int southernEquatorRow = ROW_COUNT_SPEC / 2 - 1;
        final int northernEquatorRow = ROW_COUNT_SPEC / 2;

        assertEquals(EQUATOR_BIN_COUNT_SPEC, ig.getColCount(southernEquatorRow));
        assertEquals(EQUATOR_BIN_COUNT_SPEC, ig.getColCount(northernEquatorRow));
    }


    public void testReadProductNodes() {
        // todo - provide a test case with some netcdf file variants here
    }


    public void testReadRasterData() {
        // todo - provide a test case with some netcdf file variants here
    }
}
