/*
    $Id: InsituDataTableTest.java,v 1.8 2007-06-15 18:53:12 ralf Exp $

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

import java.io.*;

/**
 * Tests for class {@link InsituDataTable}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.8 $ $Date: 2007-06-15 18:53:12 $
 */
public class InsituDataTableTest extends TestCase {

    public void testConstructor() throws IOException {
        final InputStream inputStream = getClass().getResourceAsStream("insitu.txt");
        assertNotNull(inputStream);

        final InputStreamReader reader = new InputStreamReader(inputStream);
        assertNotNull(reader);

        final InsituDataTable table = new InsituDataTable(reader, new ErrorHandler() {
            public void warn(String msg) {
            }

            public void error(Throwable t) {
            }
        });

        assertEquals(2, table.getRecordCount());
        assertEquals("NO00-00001", table.getRecord(0).getId());
        assertEquals(1.21, table.getRecord(0).getValue("CHLA_FLUOR"), 0.0);
        assertEquals(0.06, table.getRecord(1).getValue("KD490"), 0.0);
        assertEquals("5729", table.getRecord(1).getComment());
    }
}
