/*
    $Id: BinnedProductReaderPlugInTest.java,v 1.2 2007-06-14 17:19:34 ralf Exp $

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
import org.esa.beam.framework.dataio.DecodeQualification;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLDecoder;

/**
 * Test methods for class {@link BinnedProductReaderPlugIn}.
 *
 * @author Norman Fomferra
 * @author Ralf Quast
 * @version $Revision: 1.2 $ $Date: 2007-06-14 17:19:34 $
 */
public class BinnedProductReaderPlugInTest extends TestCase {

    public void testGetDecodeQualification() throws UnsupportedEncodingException {
        final String path = getResourcePath("mapped.nc");

        final File file = new File(path);
        assertEquals(file.getName(), "mapped.nc");
        assertTrue(file.exists());
        assertTrue(file.canRead());

        assertEquals(DecodeQualification.UNABLE, new BinnedProductReaderPlugIn().getDecodeQualification(file));

        // todo - add test with Binned product
    }

    private static String getResourcePath(final String name) throws UnsupportedEncodingException {
        final URL url = BinnedProductReaderPlugInTest.class.getResource(name);
        assertNotNull(url);

        final String path = URLDecoder.decode(url.getPath(), "UTF-8");
        assertTrue(path.endsWith(name));

        return path;
    }

}
