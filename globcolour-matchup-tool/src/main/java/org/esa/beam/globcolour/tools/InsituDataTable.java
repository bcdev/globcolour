/*
    $Id: InsituDataTable.java,v 1.10 2007-07-17 17:53:53 ralf Exp $

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

import org.esa.beam.util.io.CsvReader;

import java.io.IOException;
import java.io.Reader;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

/**
 * Created by IntelliJ IDEA.
 *
 * @author Ralf Quast
 * @version $Revision: 1.10 $ $Date: 2007-07-17 17:53:53 $
 */
class InsituDataTable {

    private static final int HEAD_ROW_COUNT = 3;
    private static final int HEAD_COL_COUNT = 11;
    private static final int TAIL_COL_COUNT = 3;

    private Map<CaselessKey, Integer> indexMap = new HashMap<CaselessKey, Integer>();
    private List<Record> recordList = new ArrayList<Record>();

    private String[] columnNames;

    public InsituDataTable(Reader reader, final ErrorHandler errorHandler) throws IOException {
        readAll(reader, errorHandler);
    }

    public String[] getColumnNames() {
        return columnNames;
    }

    private void readAll(final Reader reader, final ErrorHandler errorHandler) throws IOException {
        final CsvReader csvReader = new CsvReader(reader, ",".toCharArray(), true, ";");
        final List recordList = csvReader.readAllRecords();

        columnNames = (String[]) recordList.get(0);

        for (int i = HEAD_COL_COUNT; i < columnNames.length - TAIL_COL_COUNT; i++) {
            indexMap.put(new CaselessKey(columnNames[i]), i - HEAD_COL_COUNT);
        }

        for (int i = HEAD_ROW_COUNT; i < recordList.size(); ++i) {
            final String[] tokens = (String[]) recordList.get(i);

            if (tokens.length != columnNames.length) {
                throw new IOException("length of record does not match length of header");
            }

            final String id = tokens[0];
            final int siteId;
            final String siteName = tokens[2];
            final int year;
            final int month;
            final int day;
            final int hour;
            final int minute;
            final double lat;
            final double lon;
            final double depth;
            final double[] values = new double[columnNames.length - HEAD_COL_COUNT - TAIL_COL_COUNT];
            final long flags;
            final String campaign;
            final String comment;

            try {
                siteId = Integer.parseInt(tokens[1]);

                year = Integer.parseInt(tokens[3]);
                month = Integer.parseInt(tokens[4]);
                day = Integer.parseInt(tokens[5]);
                hour = Integer.parseInt(tokens[6]);
                minute = Integer.parseInt(tokens[7]);

                lon = Float.parseFloat(tokens[8]);
                lat = Float.parseFloat(tokens[9]);
                depth = Float.parseFloat(tokens[10]);

                for (int j = 0; j < values.length; ++j) {
                    values[j] = Double.parseDouble(tokens[HEAD_COL_COUNT + j]);
                }

                final String flagsToken = tokens[columnNames.length - 3];
                if ("NA".equalsIgnoreCase(flagsToken)) {
                    flags = 0;
                } else {
                    flags = Long.parseLong(flagsToken);
                }
            } catch (NumberFormatException e) {
                errorHandler.warn(MessageFormat.format("Rejected in-situ data record {0}: {1}", id, e.getMessage()));
                continue;
            }

            campaign = tokens[columnNames.length - 2];
            comment = tokens[columnNames.length - 1];

            final Calendar calendar = new GregorianCalendar(TimeZone.getTimeZone("UTC"), Locale.ENGLISH);
            calendar.clear();
            calendar.setLenient(false);
            calendar.set(year, month - 1, day, hour, minute);

            try {
                this.recordList.add(new Record(this, id, siteId, siteName, calendar, lat, lon, depth, values, flags,
                                               campaign, comment));
            } catch (IllegalArgumentException e) {
                errorHandler.warn(MessageFormat.format("Rejected in-situ data record {0}: {1}", id, e.getMessage()));
            }
        }
    }

    public int getRecordCount() {
        return recordList.size();
    }

    public Record getRecord(final int i) {
        return recordList.get(i);
    }

    public Record[] getRecords() {
        return recordList.toArray(new Record[recordList.size()]);
    }

    private static class CaselessKey {

        private final String str;
        private final int hash;

        public CaselessKey(final String str) {
            this.str = str;
            this.hash = str.toLowerCase().hashCode();
        }

        @Override
        public final int hashCode() {
            return hash;
        }

        @Override
        public final boolean equals(Object obj) {
            if (obj == this) {
                return true;
            }
            if (obj instanceof CaselessKey) {
                return str.equalsIgnoreCase(((CaselessKey) obj).str);
            }
            return false;
        }

        @Override
        public final String toString() {
            return str;
        }
    }


    public static class Record {

        private InsituDataTable table;

        private String id;
        private int siteId;
        private String siteName;

        private Calendar calendar;

        private double lat;
        private double lon;
        private double depth;

        private double[] values;

        private long flags;
        private String campaign;
        private String comment;

        private Record(final InsituDataTable table,
                       final String id,
                       final int siteId,
                       final String siteName,
                       final Calendar calendar,
                       final double lat,
                       final double lon,
                       final double depth,
                       final double[] values,
                       final long flags,
                       final String campaign,
                       final String comment) {
            validate(calendar, lat, lon);

            this.table = table;
            this.id = id;
            this.siteId = siteId;
            this.siteName = siteName;
            this.calendar = calendar;
            this.lat = lat;
            this.lon = lon;
            this.depth = depth;
            this.values = values;
            this.flags = flags;
            this.campaign = campaign;
            this.comment = comment;
        }

        public String getTimeString() {
            return calendar.getTime().toString();
        }

        public final String getId() {
            return id;
        }

        /**
         * Returns the diagnostic site ID.
         *
         * @return the ID.
         */
        public final int getSiteId() {
            return siteId;
        }

        /**
         * Returns the diagnostic site name.
         *
         * @return the ID.
         */
        public final String getSiteName() {
            return siteName;
        }

        /**
         * Returns the year of the UTC associated with a record.
         *
         * @return the year.
         */
        public final int getYear() {
            return calendar.get(Calendar.YEAR);
        }

        /**
         * Returns the month of the UTC associated with a record.
         *
         * @return the month.
         */
        public final int getMonth() {
            return calendar.get(Calendar.MONTH) + 1;
        }

        /**
         * Returns the date of the UTC associated with a record.
         *
         * @return the date.
         */
        public final int getDate() {
            return calendar.get(Calendar.DATE);
        }

        /**
         * Returns the day of year of the UTC associated with a record.
         *
         * @return the day of year.
         */
        public final int getDayOfYear() {
            return calendar.get(Calendar.DAY_OF_YEAR);
        }

        /**
         * Returns the hour of the UTC associated with a record.
         *
         * @return the hour.
         */
        public final int getHour() {
            return calendar.get(Calendar.HOUR_OF_DAY);
        }

        /**
         * Returns the minute of the UTC associated with a record.
         *
         * @return the minute.
         */
        public final int getMinute() {
            return calendar.get(Calendar.MINUTE);
        }

        /**
         * Returns the UTC associated with a record as a real number. The
         * result is equal to the value of the expression:
         * <p/>
         * {@code 1000.0 * YEAR + DAY_OF_YEAR + HOUR_OF_DAY / 24.0 + MINUTE / 1440.0}
         *
         * @return the UTC expressed as a real number.
         */
        public double getTimeAsDouble() {
            return 1000.0 * getYear() + getDayOfYear() + getHour() / 24.0 + getMinute() / 1440.0;
        }

        /**
         * Returns the UTC associated with a record as milliseconds.
         *
         * @return the UTC expressed in milliseconds.
         */
        public final long getTimeInMillis() {
            return calendar.getTimeInMillis();
        }

        /**
         * Returns the geographical latitude associated with a record.
         *
         * @return the latitude.
         */
        public final double getLat() {
            return lat;
        }

        /**
         * Returns the geographical longitude associated with a record.
         *
         * @return the longitude.
         */
        public final double getLon() {
            return lon;
        }

        /**
         * Returns the depth associated with a record.
         *
         * @return the depth.
         */
        public final double getDepth() {
            return depth;
        }

        public final double getValue(final String key) throws IllegalArgumentException {
            try {
                return values[getIndex(key)];
            } catch (NullPointerException e) {
                throw new IllegalArgumentException("column '" + key + "' does not exist");
            }
        }

        /**
         * Returns the value of a measurement.
         *
         * @param i the index number of the measurement.
         *
         * @return the measurement value.
         *
         * @throws IndexOutOfBoundsException if {@code i} is not a valid index number.
         */
        public final double getValue(final int i) {
            return values[i];
        }

        public final int getIndex(final String key) {
            return table.indexMap.get(new CaselessKey(key));
        }

        public final long getFlags() {
            return flags;
        }

        /**
         * Returns the campaign.
         *
         * @return the campaign.
         */
        public final String getCampaign() {
            return campaign;
        }

        /**
         * Returns the comment.
         *
         * @return a comment.
         */
        public final String getComment() {
            return comment;
        }

        private static void validate(final Calendar calendar, final double lat, final double lon) throws
                                                                                                  IllegalArgumentException {
            try {
                calendar.getTimeInMillis();
            } catch (Exception e) {
                throw new IllegalArgumentException(
                        MessageFormat.format("Illegal value for calendar field: {0}", e.getMessage()), e);
            }

            if (Double.isNaN(lat)) {
                throw new IllegalArgumentException("lat == NaN");
            }
            if (Math.abs(lat) > 90.0) {
                throw new IllegalArgumentException("abs(lat) > 90.0");
            }
            if (Double.isNaN(lon)) {
                throw new IllegalArgumentException("lon == NaN");
            }
            if (Math.abs(lon) > 180.0) {
                throw new IllegalArgumentException("abs(lon) > 180.0");
            }
        }

    }

}
