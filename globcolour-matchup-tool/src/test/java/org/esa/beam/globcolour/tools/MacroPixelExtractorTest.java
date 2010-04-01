/*
    $Id: MacroPixelExtractorTest.java,v 1.15 2007-06-15 20:34:18 ralf Exp $

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
import org.esa.beam.framework.datamodel.*;
import org.esa.beam.framework.dataop.maptransf.*;
import org.esa.beam.dataio.globcolour.ProductUtilities;
import org.esa.beam.dataio.globcolour.ProductAttributes;

import java.io.IOException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

/**
 * Tests for class {@link MacroPixelExtractor}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.15 $ $Date: 2007-06-15 20:34:18 $
 */
public class MacroPixelExtractorTest extends TestCase {

    public void testExtract() throws IOException {
        final Product product = new Product("name", "type", 11, 11);

        final MapProjection mapProjection = MapProjectionRegistry.getProjection(IdentityTransformDescriptor.NAME);
        final MapInfo mapInfo = new MapInfo(mapProjection, 5.5f, 5.5f, 0.0f, 0.0f, 1.0f, 1.0f, Datum.WGS_84);

        mapInfo.setSceneWidth(11);
        mapInfo.setSceneHeight(11);
        product.setGeoCoding(new MapGeoCoding(mapInfo));
        MetadataAttribute ma = new MetadataAttribute(ProductAttributes.START_TIME, ProductData.createInstance("20070228"), true);
        product.getMetadataRoot().addElement(new MetadataElement("MPH"));
        product.getMetadataRoot().getElement("MPH").addAttribute(ma);

        assertNotNull(ProductUtilities.getTimeAttrValue(product, ProductAttributes.START_TIME));
        assertEquals(2007, ProductUtilities.getTimeAttrValue(product, ProductAttributes.START_TIME).getAsCalendar().get(
                Calendar.YEAR));
        assertEquals(1, ProductUtilities.getTimeAttrValue(product, ProductAttributes.START_TIME).getAsCalendar().get(
                Calendar.MONTH));
        assertEquals(28, ProductUtilities.getTimeAttrValue(product, ProductAttributes.START_TIME).getAsCalendar().get(
                Calendar.DATE));
        assertEquals(0, ProductUtilities.getTimeAttrValue(product, ProductAttributes.START_TIME).getAsCalendar().get(
                Calendar.HOUR));

        final Calendar calendar = Calendar.getInstance();
        product.setStartTime(ProductData.UTC.create(calendar.getTime(), 0));
        product.setEndTime(ProductData.UTC.create(calendar.getTime(), 0));
        final Band band = product.addBand(BandId.CHL1.getValueBandName(), ProductData.TYPE_FLOAT32);

        final float[] data = new float[11 * 11];
        for (int i = 0; i < data.length; ++i) {
            data[i] = i;
        }
        ProductData bandRasterData = ProductData.createInstance(data);
        band.setRasterData(bandRasterData);
        band.setPixels(0, 0, 11, 11, data);

        Map<BandId, String> vmap = new HashMap<BandId, String>();
        Map<BandId, String> fmap = new HashMap<BandId, String>();
        vmap.put(BandId.CHL1, BandId.CHL1.getValueBandName());
        fmap.put(BandId.CHL1, BandId.CHL1.getFlagsBandName());

        final MacroPixel<BandId> macroPixel = MacroPixelExtractor.extract(product, 0.0, 0.0, 1, vmap, fmap);

        assertNotNull(macroPixel);
        assertEquals(3, macroPixel.getWidth());
        assertEquals(3, macroPixel.getHeight());
        assertEquals(1, macroPixel.getLayerCount());
        assertTrue(macroPixel.hasLayer(BandId.CHL1));
        assertTrue(macroPixel.hasStartTime());
        assertTrue(macroPixel.hasEndTime());

        assertEquals(1.0, macroPixel.getLat(0), 0.0);
        assertEquals(1.0, macroPixel.getLat(2), 0.0);
        assertEquals(0.0, macroPixel.getLat(4), 0.0);
        assertEquals(-1.0, macroPixel.getLat(6), 0.0);
        assertEquals(-1.0, macroPixel.getLat(8), 0.0);

        assertEquals(-1.0, macroPixel.getLon(0), 0.0);
        assertEquals(1.0, macroPixel.getLon(2), 0.0);
        assertEquals(0.0, macroPixel.getLon(4), 0.0);
        assertEquals(-1.0, macroPixel.getLon(6), 0.0);
        assertEquals(1.0, macroPixel.getLon(8), 0.0);

        double[] values = macroPixel.getValues(BandId.CHL1);
        assertNotNull(values);

        assertEquals(48.0, values[0], 0.0);
        assertEquals(50.0, values[2], 0.0);
        assertEquals(60.0, values[4], 0.0);
        assertEquals(70.0, values[6], 0.0);
        assertEquals(72.0, values[8], 0.0);
    }

}

