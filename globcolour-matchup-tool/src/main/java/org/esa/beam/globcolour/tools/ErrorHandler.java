/*
    $Id: ErrorHandler.java,v 1.2 2007-06-15 18:01:57 ralf Exp $

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
 * Error handler interface.
 *
 * @author Norman Fomferra
 * @version $Revision: 1.2 $ $Date: 2007-06-15 18:01:57 $
 */
interface ErrorHandler {
    void warn(String msg);

    void error(Throwable t);
}
