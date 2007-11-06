/*
    $Id$

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

/**
 * The class <code>ProductTypes</code> specifies the identifiers of the
 * different GlobColour product types.
 *
 * @author Ralf Quast
 * @version $Revision$ $Date$
 */
public class ProductTypes {

    /**
     * The type identifier for Binned global products.
     */
    public static final String BINNED_GLOBAL = "GlobColour-L3b";
    /**
     * The type identifier for Mapped global products.
     */
    public static final String MAPPED_GLOBAL = "GlobColour-L3m";
    /**
     * The type identifier for Binned DDS products.
     */
    public static final String BINNED_DDS = "GlobColour-L3b-DDS";
    /**
     * The type identifier for Mapped DDS products.
     */
    public static final String MAPPED_DDS = "GlobColour-L3m-DDS";
}
