/*
    $Id: BandId.java,v 1.1 2007-06-14 16:44:42 ralf Exp $

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

/**
 * The enumeration type <code>BandId</code> is a representation of the
 * geophysical parameters (bands) included in GlobColour products.
 *
 * @author Ralf Quast
 * @version $Revision: 1.1 $ $Date: 2007-06-14 16:44:42 $
 */
enum BandId {

    /**
     * Case 1 water chlorophyll-a concentration (mg m-3)
     */
    CHL1,
    /**
     * Case 2 water chlorophyll-a concentration (mg m-3)
     */
    CHL2,
    /**
     * Merged chlorophyll-a concentration (mg m-3)
     */
    CHLM {
        @Override
        public String toString() {
            return "CHLm";
        }
    },
    /**
     * Coloured dissolved organic matter absorption (m-1)
     */
    CDM,
    /**
     * Total suspended matter concentration (g m-3)
     */
    TSM,
    /**
     * Particulate back-scattering coefficient at 443 nm (m-1)
     */
    BBP,
    /**
     * Diffuse attenuation coefficient at 490 nm (m-1)
     */
    KD490,
    /**
     * Normalized water-leaving radiance at 412 nm
     */
    L412,
    /**
     * Normalized water-leaving radiance at 443 nm
     */
    L443,
    /**
     * Normalized water-leaving radiance at 490 nm
     */
    L490,
    /**
     * Normalized water-leaving radiance at 510 nm
     */
    L510,
    /**
     * Normalized water-leaving radiance at 531 nm (MODIS only)
     */
    L530,
    /**
     * Normalized water-leaving radiance at 550-565 nm
     */
    L555,
    /**
     * Normalized water-leaving radiance at 620 nm (MERIS only)
     */
    L620,
    /**
     * Normalized water-leaving radiance at 665-670 nm
     */
    L670,
    /**
     * Measured water-leaving radiance at 681 nm (MERIS only)
     */
    L681,
    /**
     * Normalized water-leaving radiance at 709 nm (MERIS only)
     */
    L709,
    /**
     * Relative excess of radiance at 555 nm
     */
    EL555,
    /**
     * Photosynthetically available radiation
     */
    PAR,
    /**
     * Aerosol optical thickness
     */
    T865,
    /**
     * Cloud fraction
     */
    CF;


    /**
     * Returns the name of the flags band which is associated with the measured
     * parameter.
     *
     * @return the name of the flags band.
     */
    public final String getFlagsBandName() {
        return new StringBuilder(toString()).append("_").append("flags").toString();
    }


    /**
     * Returns the name of the mean value band which is associated with the measured
     * parameter.
     *
     * @return the name of the mean value band.
     */
    public final String getMeanValueBandName() {
        return new StringBuilder(toString()).append("_").append("mean").toString();
    }


    /**
     * Returns the name of the value band which is associated with the measured
     * parameter.
     *
     * @return the name of the value band.
     */
    public final String getValueBandName() {
        return new StringBuilder(toString()).append("_").append("value").toString();
    }

}
