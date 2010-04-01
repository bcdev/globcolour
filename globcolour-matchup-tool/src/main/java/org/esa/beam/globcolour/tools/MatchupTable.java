/*
    $Id: MatchupTable.java,v 1.3 2007-07-16 09:24:48 ralf Exp $

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

import java.util.ArrayList;
import java.util.List;

/**
 * Matchup table.
 *
 * @author Norman Fomferra
 * @author Ralf Quast
 * @version $Revision: 1.3 $ $Date: 2007-07-16 09:24:48 $
 */
class MatchupTable {

    private List<Record> recordList = new ArrayList<Record>();

    public final void add(final Record record) {
        recordList.add(record);
    }

    public final int getRecordCount() {
        return recordList.size();
    }

    public final Record getRecord(final int index) {
        return recordList.get(index);
    }


    public static class Record {
        private InsituDataTable.Record insituDataRecord;
        private MacroPixel<BandId> macroPixel;

        public Record(final InsituDataTable.Record insituDataRecord, final MacroPixel<BandId> macroPixel) {
            this.insituDataRecord = insituDataRecord;
            this.macroPixel = macroPixel;
        }

        public final MacroPixel<BandId> getMacroPixel() {
            return macroPixel;
        }

        public final double getInsituTime() {
            return insituDataRecord.getTimeAsDouble();
        }

        public final double getInsituLat() {
            return insituDataRecord.getLat();
        }

        public final double getInsituLon() {
            return insituDataRecord.getLon();
        }

        public final double getInsituMeasurement(final String key) {
            return insituDataRecord.getValue(key);
        }

        public final double getSensingTime() {
            return macroPixel.getStartTimeAsDouble();
        }

        public final double getSensingTimeDiff() {
            return Math.abs(getSensingTime() - getInsituTime());
        }

        public final double getSensingDist() {
            return getSensingDist(macroPixel.getPixelCount() / 2);
        }

        public final double getSensingLat() {
            return macroPixel.getLat(macroPixel.getPixelCount() / 2);
        }

        public final double getSensingLon() {
            return macroPixel.getLon(macroPixel.getPixelCount() / 2);
        }

        public final double getSensingDist(final int i) {
            double lat = insituDataRecord.getLat();
            double lon = insituDataRecord.getLon();

            double dlat = macroPixel.getLat(i) - lat;
            double dlon = macroPixel.getLon(i) - lon;

            return Math.sqrt(dlat * dlat + Math.cos(Math.toRadians(lat)) * (dlon * dlon));
        }
    }

}
