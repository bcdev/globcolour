/*
    $Id: MacroPixelExtractor.java,v 1.9 2007-06-15 20:34:18 ralf Exp $

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

import org.esa.beam.framework.datamodel.*;

import java.io.File;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.Map;

/**
 * Macro-pixel extractor.
 *
 * @author Ralf Quast
 * @version $Revision: 1.9 $ $Date: 2007-06-15 20:34:18 $
 */
class MacroPixelExtractor {

    public static <K> MacroPixel<K> extract(final Product product,
                                            final double lat, final double lon,
                                            final int border,
                                            final Map<K, String> dataBandMap,
                                            final Map<K, String> flagBandMap) throws IOException {
        if (product == null) {
            throw new NullPointerException("product");
        }
        if (!product.isUsingSingleGeoCoding() || !product.getGeoCoding().canGetPixelPos()) {
            throw new IOException(MessageFormat.format("{0}: no usable geo-coding", product.getName()));
        }
        if (Math.abs(lat) > 90.0) {
            throw new IllegalArgumentException("abs(lat) > 90.0");
        }
        if (Math.abs(lon) > 180.0) {
            throw new IllegalArgumentException("abs(lon) > 180.0");
        }
        if (border < 0) {
            throw new IllegalArgumentException("border < 0");
        }
        if (dataBandMap == null) {
            throw new NullPointerException("flagBandMap == null");
        }

        final GeoPos geoPos = new GeoPos((float) lat, (float) lon);
        final PixelPos pixelPos = product.getGeoCoding().getPixelPos(geoPos, null);

        if (!pixelPos.isValid()) {
            throw new IOException(createPixelNotFoundMessage(product, geoPos));
        }

        final int x = (int) Math.floor(pixelPos.getX());
        final int y = (int) Math.floor(pixelPos.getY());

        final int xmin = x - border;
        final int xmax = x + border;
        if (xmin < 0 || xmax > product.getSceneRasterWidth() - 1) {
            throw new IOException(createPixelNotFoundMessage(product, geoPos));
        }

        final int ymin = y - border;
        final int ymax = y + border;
        if (ymin < 0 || ymax > product.getSceneRasterHeight() - 1) {
            throw new IOException(createPixelNotFoundMessage(product, geoPos));
        }

        final MacroPixel<K> macroPixel = new MacroPixel<K>(2 * border + 1);
        File fileLocation = product.getFileLocation();
        macroPixel.setProdutFilename(fileLocation != null ? fileLocation.getName() : "");

        // Set start and end times
        final ProductData.UTC startTime = product.getStartTime();
        if (startTime != null) {
            macroPixel.setStartTimeInMillis(startTime.getAsCalendar().getTimeInMillis());
        }
        final ProductData.UTC endTime = product.getEndTime();
        if (endTime != null) {
            macroPixel.setEndTimeInMillis(endTime.getAsCalendar().getTimeInMillis());
        }

        // Set geographical location
        for (int i = 0; i < macroPixel.getHeight(); ++i) {
            pixelPos.y = ymin + i + 0.5f;

            for (int j = 0; j < macroPixel.getHeight(); ++j) {
                pixelPos.x = xmin + j + 0.5f;

                product.getGeoCoding().getGeoPos(pixelPos, geoPos);
                macroPixel.setLat(i * macroPixel.getWidth() + j, geoPos.getLat());
                macroPixel.setLon(i * macroPixel.getWidth() + j, geoPos.getLon());
            }
        }

        // Add data layers
        for (final K key : dataBandMap.keySet()) {
            final String name = dataBandMap.get(key);
            if (name == null || !product.containsBand(name)) {
                continue;
            }

            final Band band = product.getBand(name);
            try {
                band.loadRasterData();
            } catch (IOException e) {
                throw new IOException(createLoadFailedMessage(product, band));
            }

            macroPixel.addLayer(key);

            // Set pixel values
            final double[] values = macroPixel.getValues(key);
            band.getPixels(xmin, ymin, macroPixel.getWidth(), macroPixel.getHeight(), values);

            if (band.isNoDataValueSet() && band.isNoDataValueUsed()) {
                for (int i = 0; i < values.length; ++i) {
                    if (values[i] == band.getNoDataValue()) {
                        values[i] = Double.NaN;
                    }
                }
            }
        }

        // Set pixel flags, if applicable
        if (flagBandMap != null) {
            for (final K key : macroPixel.getLayerKeySet()) {
                final String name = flagBandMap.get(key);
                if (name == null || !product.containsBand(name)) {
                    continue;
                }

                final Band band = product.getBand(name);
                try {
                    band.loadRasterData();
                } catch (IOException e) {
                    throw new IOException(createLoadFailedMessage(product, band));
                }

                final int[] flags = macroPixel.getFlags(key);
                band.getPixels(xmin, ymin, xmax - xmin + 1, ymax - ymin + 1, flags);
            }
        }

        return macroPixel;
    }

    private static String createLoadFailedMessage(final Product product, final Band band) {
        return MessageFormat.format("{0}: failed to load dataset {1}", product.getName(), band.getName());
    }

    private static String createPixelNotFoundMessage(final Product product, final GeoPos geoPos) {
        return MessageFormat.format("{0}: pixel not found for lat = {1}, lon = {2}", product.getName(),
                GeoPos.getLatString(geoPos.lat), GeoPos.getLonString(geoPos.lon));
    }

}
