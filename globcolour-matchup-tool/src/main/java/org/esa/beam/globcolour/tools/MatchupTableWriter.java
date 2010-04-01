/*
    $Id: MatchupTableWriter.java,v 1.6 2007-07-17 17:56:21 ralf Exp $

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

import org.esa.beam.globcolour.internal.SimpleLinearRegression;
import org.esa.beam.globcolour.internal.Statistics;

import java.io.IOException;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;
import java.text.MessageFormat;

/**
 * Matchup table writer.
 *
 * @author Marco Peters
 * @author Ralf Quast
 * @version $Revision: 1.6 $ $Date: 2007-07-17 17:56:21 $
 */
class MatchupTableWriter {

    private MatchupTable matchupTable;
    private String separator;

    private static final String[] measurementIds = new String[]{
            "Chla_hplc",
            "Chla_fluor",
            "Kd490",
            "TSM",
            "acdm443",
            "bbp443",
            "T865",
            "exLwn412",
            "exLwn443",
            "exLwn490",
            "exLwn510",
            "exLwn531",
            "exLwn555",
            "exLwn620",
            "exLwn670"
    };

    private static final BandId[] bandIds = new BandId[]{
            BandId.CHL1,
            BandId.KD490,
            BandId.TSM,
            BandId.CDM,
            BandId.BBP,
            BandId.T865,
            BandId.L412,
            BandId.L443,
            BandId.L490,
            BandId.L510,
            BandId.L530,
            BandId.L555,
            BandId.L620,
            BandId.L670
    };

    private static final Map<String, BandId> bandIdMap = new HashMap<String, BandId>();

    static {
        bandIdMap.put("Chla_hplc", BandId.CHL1);
        bandIdMap.put("Chla_fluor", BandId.CHL1);
        bandIdMap.put("Kd490", BandId.KD490);
        bandIdMap.put("TSM", BandId.TSM);
        bandIdMap.put("acdm443", BandId.CDM);
        bandIdMap.put("bbp443", BandId.BBP);
        bandIdMap.put("T865", BandId.T865);
        bandIdMap.put("exLwn412", BandId.L412);
        bandIdMap.put("exLwn443", BandId.L443);
        bandIdMap.put("exLwn490", BandId.L490);
        bandIdMap.put("exLwn510", BandId.L510);
        bandIdMap.put("exLwn531", BandId.L530);
        bandIdMap.put("exLwn555", BandId.L555);
        bandIdMap.put("exLwn620", BandId.L620);
        bandIdMap.put("exLwn670", BandId.L670);
    }

    public MatchupTableWriter(final MatchupTable matchupTable, final String separator) {
        this.matchupTable = matchupTable;
        this.separator = separator;
    }

    public void writeResultsTable(final Writer writer) throws IOException {
        final String[] header = {
                "Time_insitu",
                "Lat_insitu",
                "Lon_insitu",
                "Time_sat",
                "Lat_sat",
                "Lon_sat",

                measurementIds[0] + "_insitu",
                measurementIds[1] + "_insitu",
                measurementIds[2] + "_insitu",
                measurementIds[3] + "_insitu",
                measurementIds[4] + "_insitu",
                measurementIds[5] + "_insitu",
                measurementIds[6] + "_insitu",
                measurementIds[7] + "_insitu",
                measurementIds[8] + "_insitu",
                measurementIds[9] + "_insitu",
                measurementIds[10] + "_insitu",
                measurementIds[11] + "_insitu",
                measurementIds[12] + "_insitu",
                measurementIds[13] + "_insitu",
                measurementIds[14] + "_insitu",
                bandIds[0].toString() + "_sat",
                bandIds[1].toString() + "_sat",
                bandIds[2].toString() + "_sat",
                bandIds[3].toString() + "_sat",
                bandIds[4].toString() + "_sat",
                bandIds[5].toString() + "_sat",
                bandIds[6].toString() + "_sat",
                bandIds[7].toString() + "_sat",
                bandIds[8].toString() + "_sat",
                bandIds[9].toString() + "_sat",
                bandIds[10].toString() + "_sat",
                bandIds[11].toString() + "_sat",
                bandIds[12].toString() + "_sat",
                bandIds[13].toString() + "_sat",

                "Time_diff",
                "Loc_Diff",

                "Flag_" + bandIds[0].toString() + "_sat",
                "Flag_" + bandIds[1].toString() + "_sat",
                "Flag_" + bandIds[2].toString() + "_sat",
                "Flag_" + bandIds[3].toString() + "_sat",
                "Flag_" + bandIds[4].toString() + "_sat",
                "Flag_" + bandIds[5].toString() + "_sat",
                "Flag_" + bandIds[6].toString() + "_sat",
                "Flag_" + bandIds[7].toString() + "_sat",
                "Flag_" + bandIds[8].toString() + "_sat",
                "Flag_" + bandIds[9].toString() + "_sat",
                "Flag_" + bandIds[10].toString() + "_sat",
                "Flag_" + bandIds[11].toString() + "_sat",
                "Flag_" + bandIds[12].toString() + "_sat",
                "Flag_" + bandIds[13].toString() + "_sat",

                "SatFilename"};

        writeRow(writer, header, separator);

        for (int i = 0; i < matchupTable.getRecordCount(); i++) {
            final MatchupTable.Record record = matchupTable.getRecord(i);
            final MacroPixel<BandId> macroPixel = record.getMacroPixel();

            for (int j = 0; j < macroPixel.getPixelCount(); ++j) {

                final String[] row;
                try {
                    row = new String[]{
                            String.valueOf(record.getInsituTime()),
                            String.valueOf(record.getInsituLat()),
                            String.valueOf(record.getInsituLon()),
                            String.valueOf(record.getSensingTime()),
                            String.valueOf(macroPixel.getLat(j)),
                            String.valueOf(macroPixel.getLon(j)),

                            String.valueOf(record.getInsituMeasurement(measurementIds[0])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[1])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[2])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[3])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[4])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[5])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[6])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[7])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[8])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[9])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[10])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[11])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[12])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[13])),
                            String.valueOf(record.getInsituMeasurement(measurementIds[14])),

                            String.valueOf(getValue(macroPixel, bandIds[0], j)),
                            String.valueOf(getValue(macroPixel, bandIds[1], j)),
                            String.valueOf(getValue(macroPixel, bandIds[2], j)),
                            String.valueOf(getValue(macroPixel, bandIds[3], j)),
                            String.valueOf(getValue(macroPixel, bandIds[4], j)),
                            String.valueOf(getValue(macroPixel, bandIds[5], j)),
                            String.valueOf(getValue(macroPixel, bandIds[6], j)),
                            String.valueOf(getValue(macroPixel, bandIds[7], j)),
                            String.valueOf(getValue(macroPixel, bandIds[8], j)),
                            String.valueOf(getValue(macroPixel, bandIds[9], j)),
                            String.valueOf(getValue(macroPixel, bandIds[10], j)),
                            String.valueOf(getValue(macroPixel, bandIds[11], j)),
                            String.valueOf(getValue(macroPixel, bandIds[12], j)),
                            String.valueOf(getValue(macroPixel, bandIds[13], j)),

                            String.valueOf(record.getSensingTimeDiff()),
                            String.valueOf(record.getSensingDist(j)),

                            String.valueOf(getFlags(macroPixel, bandIds[0], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[1], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[2], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[3], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[4], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[5], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[6], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[7], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[8], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[9], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[10], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[11], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[12], j)),
                            String.valueOf(getFlags(macroPixel, bandIds[13], j)),

                            macroPixel.getFileName()};
                } catch (IllegalArgumentException e) {
                    throw new IOException(MessageFormat.format(
                            "could not write results table because {0}", e.getMessage()));
                }

                writeRow(writer, row, separator);
            }
        }
    }

    public void writeMeanResultsTable(final Writer writer) throws IOException {
        final String[] header = {
                "Time_insitu",
                "Lat_insitu",
                "Lon_insitu",
                "Time_sat",
                "Lat_sat",
                "Lon_sat",

                measurementIds[0] + "_insitu",
                measurementIds[1] + "_insitu",
                measurementIds[2] + "_insitu",
                measurementIds[3] + "_insitu",
                measurementIds[4] + "_insitu",
                measurementIds[5] + "_insitu",
                measurementIds[6] + "_insitu",
                measurementIds[7] + "_insitu",
                measurementIds[8] + "_insitu",
                measurementIds[9] + "_insitu",
                measurementIds[10] + "_insitu",
                measurementIds[11] + "_insitu",
                measurementIds[12] + "_insitu",
                measurementIds[13] + "_insitu",
                measurementIds[14] + "_insitu",

                "mean_" + bandIds[0].toString() + "_sat",
                "median_" + bandIds[0].toString() + "_sat",
                "sdev" + bandIds[0].toString() + "_sat",
                "N_" + bandIds[0].toString() + "_sat",

                "mean_" + bandIds[1].toString() + "_sat",
                "median_" + bandIds[1].toString() + "_sat",
                "sdev_" + bandIds[1].toString() + "_sat",
                "N_" + bandIds[1].toString() + "_sat",

                "mean_" + bandIds[2].toString() + "_sat",
                "median_" + bandIds[2].toString() + "_sat",
                "sdev_" + bandIds[2].toString() + "_sat",
                "N_" + bandIds[2].toString() + "_sat",

                "mean_" + bandIds[3].toString() + "_sat",
                "median_" + bandIds[3].toString() + "_sat",
                "sdev_" + bandIds[3].toString() + "_sat",
                "N_" + bandIds[3].toString() + "_sat",

                "mean_" + bandIds[4].toString() + "_sat",
                "median_" + bandIds[4].toString() + "_sat",
                "sdev_" + bandIds[4].toString() + "_sat",
                "N_" + bandIds[4].toString() + "_sat",

                "mean_" + bandIds[5].toString() + "_sat",
                "median_" + bandIds[5].toString() + "_sat",
                "sdev_" + bandIds[5].toString() + "_sat",
                "N_" + bandIds[5].toString() + "_sat",

                "mean_" + bandIds[6].toString() + "_sat",
                "median_" + bandIds[6].toString() + "_sat",
                "sdev_" + bandIds[6].toString() + "_sat",
                "N_" + bandIds[6].toString() + "_sat",

                "mean_" + bandIds[7].toString() + "_sat",
                "median_" + bandIds[7].toString() + "_sat",
                "sdev_" + bandIds[7].toString() + "_sat",
                "N_" + bandIds[7].toString() + "_sat",

                "mean_" + bandIds[8].toString() + "_sat",
                "median_" + bandIds[8].toString() + "_sat",
                "sdev_" + bandIds[8].toString() + "_sat",
                "N_" + bandIds[8].toString() + "_sat",

                "mean_" + bandIds[9].toString() + "_sat",
                "median_" + bandIds[9].toString() + "_sat",
                "sdev_" + bandIds[9].toString() + "_sat",
                "N_" + bandIds[9].toString() + "_sat",

                "mean_" + bandIds[10].toString() + "_sat",
                "median_" + bandIds[10].toString() + "_sat",
                "sdev_" + bandIds[10].toString() + "_sat",
                "N_" + bandIds[10].toString() + "_sat",

                "mean_" + bandIds[11].toString() + "_sat",
                "median_" + bandIds[11].toString() + "_sat",
                "sdev_" + bandIds[11].toString() + "_sat",
                "N_" + bandIds[11].toString() + "_sat",

                "mean_" + bandIds[12].toString() + "_sat",
                "median_" + bandIds[12].toString() + "_sat",
                "sdev_" + bandIds[12].toString() + "_sat",
                "N_" + bandIds[12].toString() + "_sat",

                "mean_" + bandIds[13].toString() + "_sat",
                "median_" + bandIds[13].toString() + "_sat",
                "sdev_" + bandIds[13].toString() + "_sat",
                "N_" + bandIds[13].toString() + "_sat",

                "Time_diff",
                "Loc_Diff",
                "SatFilename"};

        writeRow(writer, header, separator);

        for (int i = 0; i < matchupTable.getRecordCount(); i++) {
            final MatchupTable.Record record = matchupTable.getRecord(i);
            final MacroPixel<BandId> macroPixel = record.getMacroPixel();

            final String[] row = new String[]{
                    String.valueOf(record.getInsituTime()),
                    String.valueOf(record.getInsituLat()),
                    String.valueOf(record.getInsituLon()),
                    String.valueOf(record.getSensingTime()),
                    String.valueOf(record.getSensingLat()),
                    String.valueOf(record.getSensingLon()),

                    String.valueOf(record.getInsituMeasurement(measurementIds[0])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[1])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[2])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[3])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[4])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[5])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[6])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[7])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[8])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[9])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[10])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[11])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[12])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[13])),
                    String.valueOf(record.getInsituMeasurement(measurementIds[14])),

                    String.valueOf(getMean(macroPixel, bandIds[0])),
                    String.valueOf(getMedian(macroPixel, bandIds[0])),
                    String.valueOf(getSDev(macroPixel, bandIds[0])),
                    String.valueOf(getCount(macroPixel, bandIds[0])),

                    String.valueOf(getMean(macroPixel, bandIds[1])),
                    String.valueOf(getMedian(macroPixel, bandIds[1])),
                    String.valueOf(getSDev(macroPixel, bandIds[1])),
                    String.valueOf(getCount(macroPixel, bandIds[1])),

                    String.valueOf(getMean(macroPixel, bandIds[2])),
                    String.valueOf(getMedian(macroPixel, bandIds[2])),
                    String.valueOf(getSDev(macroPixel, bandIds[2])),
                    String.valueOf(getCount(macroPixel, bandIds[2])),

                    String.valueOf(getMean(macroPixel, bandIds[3])),
                    String.valueOf(getMedian(macroPixel, bandIds[3])),
                    String.valueOf(getSDev(macroPixel, bandIds[3])),
                    String.valueOf(getCount(macroPixel, bandIds[3])),

                    String.valueOf(getMean(macroPixel, bandIds[4])),
                    String.valueOf(getMedian(macroPixel, bandIds[4])),
                    String.valueOf(getSDev(macroPixel, bandIds[4])),
                    String.valueOf(getCount(macroPixel, bandIds[4])),

                    String.valueOf(getMean(macroPixel, bandIds[5])),
                    String.valueOf(getMedian(macroPixel, bandIds[5])),
                    String.valueOf(getSDev(macroPixel, bandIds[5])),
                    String.valueOf(getCount(macroPixel, bandIds[5])),

                    String.valueOf(getMean(macroPixel, bandIds[6])),
                    String.valueOf(getMedian(macroPixel, bandIds[6])),
                    String.valueOf(getSDev(macroPixel, bandIds[6])),
                    String.valueOf(getCount(macroPixel, bandIds[6])),

                    String.valueOf(getMean(macroPixel, bandIds[7])),
                    String.valueOf(getMedian(macroPixel, bandIds[7])),
                    String.valueOf(getSDev(macroPixel, bandIds[7])),
                    String.valueOf(getCount(macroPixel, bandIds[7])),

                    String.valueOf(getMean(macroPixel, bandIds[8])),
                    String.valueOf(getMedian(macroPixel, bandIds[8])),
                    String.valueOf(getSDev(macroPixel, bandIds[8])),
                    String.valueOf(getCount(macroPixel, bandIds[8])),

                    String.valueOf(getMean(macroPixel, bandIds[9])),
                    String.valueOf(getMedian(macroPixel, bandIds[9])),
                    String.valueOf(getSDev(macroPixel, bandIds[9])),
                    String.valueOf(getCount(macroPixel, bandIds[9])),

                    String.valueOf(getMean(macroPixel, bandIds[10])),
                    String.valueOf(getMedian(macroPixel, bandIds[10])),
                    String.valueOf(getSDev(macroPixel, bandIds[10])),
                    String.valueOf(getCount(macroPixel, bandIds[10])),

                    String.valueOf(getMean(macroPixel, bandIds[11])),
                    String.valueOf(getMedian(macroPixel, bandIds[11])),
                    String.valueOf(getSDev(macroPixel, bandIds[11])),
                    String.valueOf(getCount(macroPixel, bandIds[11])),

                    String.valueOf(getMean(macroPixel, bandIds[12])),
                    String.valueOf(getMedian(macroPixel, bandIds[12])),
                    String.valueOf(getSDev(macroPixel, bandIds[12])),
                    String.valueOf(getCount(macroPixel, bandIds[12])),

                    String.valueOf(getMean(macroPixel, bandIds[13])),
                    String.valueOf(getMedian(macroPixel, bandIds[13])),
                    String.valueOf(getSDev(macroPixel, bandIds[13])),
                    String.valueOf(getCount(macroPixel, bandIds[13])),

                    String.valueOf(record.getSensingTimeDiff()),
                    String.valueOf(record.getSensingDist()),
                    macroPixel.getFileName()};

            writeRow(writer, row, separator);
        }
    }

    public void writeSummaryTable(final Writer writer, final double maxCV, final int minSampleCount) throws IOException {
        final String[] header = {
                "Product",
                "N",
                "Slope",
                "Intercept",
                "R_Squared",
                "Mean_Ratio",
                "Median_Ratio",
                "Mean_Percent_Error",
                "Median_Percent_Error",
                "Bias",
                "RMS",
                "Bias_Rel",
                "RMS_Rel",
                "In-situ_Min",
                "In-situ_Max",
                "Satellite_Min",
                "Satellite_Max"};

        writeRow(writer, header, separator);

        final double[] x = new double[matchupTable.getRecordCount()];
        final double[] y = new double[matchupTable.getRecordCount()];

        for (final String measurementId : measurementIds) {
            for (int i = 0; i < matchupTable.getRecordCount(); i++) {
                final MatchupTable.Record record = matchupTable.getRecord(i);
                final MacroPixel<BandId> macroPixel = record.getMacroPixel();

                final BandId bandId = bandIdMap.get(measurementId);
                if (macroPixel.hasLayer(bandId)
                    && macroPixel.getCount(bandId) >= minSampleCount
                    && (macroPixel.getPixelCount() == 1 || macroPixel.getCV(bandId) < maxCV)) {
                    x[i] = record.getInsituMeasurement(measurementId);
                    y[i] = macroPixel.getMean(bandId);
                } else {
                    x[i] = Double.NaN;
                    y[i] = Double.NaN;
                }
            }

            final SimpleLinearRegression regression = new SimpleLinearRegression(x, y);
            final String[] row = {
                    measurementId,
                    String.valueOf(regression.getCount()),
                    String.valueOf(regression.getSlope()),
                    String.valueOf(regression.getIntercept()),
                    String.valueOf(regression.getRSquared()),
                    String.valueOf(Statistics.meanRatio(x, y)),
                    String.valueOf(Statistics.medianRatio(x, y)),
                    String.valueOf(100.0 * Statistics.meanRelativeError(x, y)),
                    String.valueOf(100.0 * Statistics.medianRelativeError(x, y)),
                    String.valueOf(Statistics.meanDifference(x, y)),
                    String.valueOf(Statistics.rmsDifference(x, y)),
                    String.valueOf(Statistics.meanDifferenceLog(x, y)),
                    String.valueOf(Statistics.rmsDifferenceLog(x, y)),
                    String.valueOf(Statistics.min(x)),
                    String.valueOf(Statistics.max(x)),
                    String.valueOf(Statistics.min(y)),
                    String.valueOf(Statistics.max(y))};

            writeRow(writer, row, separator);
        }
    }

    private static void writeRow(final Writer writer, final String[] row, final String separator) throws IOException {
        for (int i = 0; i < row.length; i++) {
            writer.write(row[i]);
            if (i < row.length - 1) {
                writer.write(separator);
            }
        }
        writer.append("\n");
    }

    private static double getValue(final MacroPixel<BandId> macroPixel, final BandId bandId, final int pixelIndex) {
        if (macroPixel.hasLayer(bandId)) {
            return macroPixel.getValues(bandId)[pixelIndex];
        }

        return Double.NaN;
    }

    private static double getMean(final MacroPixel<BandId> macroPixel, final BandId bandId) {
        if (macroPixel.hasLayer(bandId)) {
            return macroPixel.getMean(bandId);
        }

        return Double.NaN;
    }

    private static double getMedian(final MacroPixel<BandId> macroPixel, final BandId bandId) {
        if (macroPixel.hasLayer(bandId)) {
            return macroPixel.getMedian(bandId);
        }

        return Double.NaN;
    }

    private static double getSDev(final MacroPixel<BandId> macroPixel, final BandId bandId) {
        if (macroPixel.hasLayer(bandId)) {
            return macroPixel.getSDev(bandId);
        }

        return Double.NaN;
    }

    private static int getCount(final MacroPixel<BandId> macroPixel, final BandId bandId) {
        if (macroPixel.hasLayer(bandId)) {
            return macroPixel.getCount(bandId);
        }

        return 0;
    }

    private static int getFlags(final MacroPixel<BandId> macroPixel, final BandId bandId, final int pixelIndex) {
        if (macroPixel.hasLayer(bandId)) {
            return macroPixel.getFlags(bandId)[pixelIndex];
        }

        return 0;
    }

}
