/*
    $Id: MatchupTool.java,v 1.24 2007-07-18 07:27:12 ralf Exp $

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

import com.bc.ceres.core.PrintWriterProgressMonitor;
import com.bc.ceres.core.ProgressMonitor;
import org.esa.beam.framework.dataio.IllegalFileFormatException;
import org.esa.beam.framework.dataio.ProductReader;
import org.esa.beam.framework.dataio.ProductReaderPlugIn;
import org.esa.beam.framework.dataio.DecodeQualification;
import org.esa.beam.framework.datamodel.GeoPos;
import org.esa.beam.framework.datamodel.PixelPos;
import org.esa.beam.framework.datamodel.Product;
import org.esa.beam.framework.datamodel.ProgressListener;
import org.esa.beam.util.logging.BeamLogManager;
import org.esa.beam.dataio.globcolour.BinnedProductReaderPlugIn;
import org.esa.beam.dataio.globcolour.MappedProductReaderPlugIn;

import java.io.*;
import java.text.MessageFormat;
import java.util.*;
import java.util.logging.FileHandler;
import java.util.logging.Logger;


/**
 * Matchup tool.
 *
 * @author Norman Fomferra
 * @author Ralf Quast
 * @version $Revision: 1.24 $ $Date: 2007-07-18 07:27:12 $
 */
public class MatchupTool {

    public static final String DEFAULT_CONFIG_FILE_PATH = "./gcmt.properties";

    private static final String USAGE_MESSAGE =
            "Usage: gcmt <insitu-file> [<dds-dir>] [-c <config-file>] [-r] [-d]\n" +
                    "with\n" +
                    "  <insitu-file>     - File in CSV format which contains the in-situ measurement\n" +
                    "  <dds-dir>         - Directory containing DDS files, default is '.'\n" +
                    "  -c <config-file>  - Sets the configuration file, default is './gcmt.properties'\n" +
                    "  -r                - Recursively searches for DDS files, default is OFF\n" +
                    "";

    // These variables are set by the command line args
    private String insituDataFilePath;
    private String configFilePath;
    private String ddsDirectoryPath;
    private boolean recursive;

    // These variables are set by the configuration file
    private String outputSeparator;
    private String outputSuffix;
    private String outputMeanSuffix;
    private String outputSummarySuffix;
    private long timeTolerance;
    private String fileFormat;
    private int pixelBorderSize;
    private double maxCV;
    private int minSampleCount;

    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println(USAGE_MESSAGE);
            return;
        }

        BeamLogManager.removeRootLoggerHandlers();

        final Logger logger = Logger.getLogger("org.esa.beam.globcolour.tools");
        try {
            logger.addHandler(new FileHandler("gcmt.log"));
        } catch (Exception e) {
            // ignore
        }

        final MatchupTool matchupTool = new MatchupTool();
        try {
            matchupTool.parseArgs(args);
            matchupTool.parseConfig();
        } catch (CliException e) {
            System.out.println(MessageFormat.format("Error: {0}", e.getMessage()));
            return;
        }

        matchupTool.run(logger, new ErrorHandler() {
            private final Logger logger = Logger.getLogger("org.esa.beam.globcolour.tools");

            public void warn(final String message) {
                logger.warning(message);
            }

            public void error(final Throwable t) {
                logger.severe(t.getMessage());
                System.out.println(MessageFormat.format("Error: {0}", t.getMessage()));
                System.exit(1);
            }
        });
    }

    private void run(final Logger logger, final ErrorHandler errorHandler) {
        if (!"GlobColour-binned".equals(fileFormat)) {
            if (!"GlobColour-mapped".equals(fileFormat)) {
                errorHandler.error(new IllegalFileFormatException(
                        MessageFormat.format("Error: Illegal file format {0}", fileFormat)));
            }
        }
        logger.info(MessageFormat.format("Collecting matchup records for ''{0}'' with DDS files in ''{1}''",
                insituDataFilePath, ddsDirectoryPath));

        try {
            final File insituDataFile = new File(insituDataFilePath);
            final File ddsDirectory = new File(ddsDirectoryPath);

            final Map<BandId, String> vmap = new HashMap<BandId, String>();
            final Map<BandId, String> fmap = new HashMap<BandId, String>();


            final ProductReader productReader;
            if ("GlobColour-binned".equalsIgnoreCase(fileFormat)) {
                for (final BandId bandId : BandId.values()) {
                    vmap.put(bandId, bandId.getMeanValueBandName());
                    fmap.put(bandId, bandId.getFlagsBandName());
                }
                productReader = new BinnedProductReaderPlugIn().createReaderInstance();
            } else {
                // TODO - if band-id.config exists, overwrite default values
                for (final BandId bandId : BandId.values()) {
                    vmap.put(bandId, bandId.getValueBandName());
                    fmap.put(bandId, bandId.getFlagsBandName());
                }
                productReader = new MappedProductReaderPlugIn().createReaderInstance();
            }

            final ArrayList<File> ddsFileList = new ArrayList<File>(1000);
            collectFiles(ddsDirectory, new ProductFileFilter(productReader.getReaderPlugIn()), ddsFileList);
            final FileReader insituDataReader = new FileReader(insituDataFile);

            final ProgressMonitor pm = new PrintWriterProgressMonitor(System.out);

            try {
                final InsituDataTable insituDataTable = new InsituDataTable(insituDataReader, errorHandler);
                final MatchupTable matchupTable = new MatchupTable();

                pm.beginTask("collecting records...", ddsFileList.size());
                // Main loop
                try {
                    for (final File ddsFile : ddsFileList) {
                        logger.info(MessageFormat.format("Processing DDS file ''{0}''", ddsFile));

                        final Product product;
                        try {
                            product = productReader.readProductNodes(ddsFile, null);
                        } catch (IOException e) {
                            errorHandler.warn(e.getMessage());
                            continue;
                        }

                        final SpaceTimeCoverage coverage = new SpaceTimeCoverage(product);

                        for (final InsituDataTable.Record record : insituDataTable.getRecords()) {
                            final double lat = record.getLat();
                            final double lon = record.getLon();

                            if (!coverage.covers(lat, lon)) {
                                // no lateral overlap, next in-situ data record
                                continue;
                            }
                            if (!coverage.coincidesWith(record.getTimeInMillis(), timeTolerance)) {
                                // no temporal overlap, next in-situ data record
                                continue;
                            }

                            final MacroPixel<BandId> macroPixel;
                            try {
                                macroPixel = MacroPixelExtractor.extract(product, lat, lon, pixelBorderSize, vmap, fmap);
                            } catch (IOException e) {
                                errorHandler.warn(
                                        MessageFormat.format("failed to extract macro pixel for DDS file ''{0}'' and in-situ data record {1}: {2}",
                                                ddsFile, record.getId(), e.getMessage()));
                                continue;
                            }
                            if (macroPixel != null) {
                                matchupTable.add(new MatchupTable.Record(record, macroPixel));
                            }
                        }

                        product.dispose();
                        pm.worked(1);
                    }
                } finally {
                    pm.done();
                }

                System.out.println(MessageFormat.format("  {0} DDS files selected from ''{1}''",
                        ddsFileList.size(), ddsDirectory));
                System.out.println(MessageFormat.format("  {0} matchup records created from ''{1}''",
                        matchupTable.getRecordCount(), insituDataFile));

                if (matchupTable.getRecordCount() > 0) {
                    final MatchupTableWriter matchupTableWriter = new MatchupTableWriter(matchupTable, outputSeparator);
                    final File resultsFile = getResultsFile();
                    logger.info(MessageFormat.format("Writing matchup results to file ''{0}''", resultsFile));
                    writeResultsTable(matchupTableWriter, resultsFile);
                    System.out.println(MessageFormat.format("  Written file ''{0}''", resultsFile));

                    final File meanResultsFile = getMeanResultsFile();
                    if (pixelBorderSize > 0) {
                        logger.info(MessageFormat.format("Writing mean results to file ''{0}''", meanResultsFile));
                        writeMeanResultsTable(matchupTableWriter, meanResultsFile);
                        System.out.println(MessageFormat.format("  Written file ''{0}''", meanResultsFile));
                    }

                    final File summaryFile = getSummaryFile();
                    logger.info(MessageFormat.format("Writing matchup summary to file ''{0}''", summaryFile));
                    writeSummaryTable(matchupTableWriter, summaryFile, maxCV, minSampleCount);
                    System.out.println(MessageFormat.format("  Written file ''{0}''", summaryFile));
                }
            } finally {
                insituDataReader.close();
            }
        } catch (IOException e) {
            errorHandler.error(e);
        }
    }

    private static void writeResultsTable(final MatchupTableWriter matchupTableWriter, final File file) throws IOException {
        final FileWriter writer = new FileWriter(file);
        try {
            matchupTableWriter.writeResultsTable(writer);
        } finally {
            try {
                writer.close();
            } catch (IOException e) {
                // ignore
            }
        }
    }

    private static void writeMeanResultsTable(final MatchupTableWriter matchupTableWriter, final File file) throws IOException {
        final FileWriter writer = new FileWriter(file);
        try {
            matchupTableWriter.writeMeanResultsTable(writer);
        } finally {
            try {
                writer.close();
            } catch (IOException e) {
                // ignore
            }
        }
    }

    private static void writeSummaryTable(final MatchupTableWriter matchupTableWriter, final File file,
                                          final double maxCV, final int minSampleCount) throws IOException {
        final FileWriter writer = new FileWriter(file);
        try {
            matchupTableWriter.writeSummaryTable(writer, maxCV, minSampleCount);
        } finally {
            try {
                writer.close();
            } catch (IOException e) {
                // ignore
            }
        }
    }

    public File getSummaryFile() {
        return getOutputFile(outputSummarySuffix);
    }

    public File getMeanResultsFile() {
        return getOutputFile(outputMeanSuffix);
    }

    public File getResultsFile() {
        return getOutputFile(outputSuffix);
    }

    private File getOutputFile(final String suffix) {
        final File file = new File(insituDataFilePath);

        String name = file.getName();
        String ext = "";
        int pos = name.indexOf(".");
        if (pos > 0) {
            ext = name.substring(pos);
            name = name.substring(0, pos);
        }

        return new File(file.getParent(), name + suffix + ext);
    }

    private void collectFiles(final File directory, final FileFilter filter, final List<File> fileList) {
        for (File file : directory.listFiles(filter)) {
            if (file.isDirectory()) {
                if (recursive) {
                    collectFiles(file, filter, fileList);
                }
            } else {
                fileList.add(file);
            }
        }
    }

    void parseArgs(final String[] args) throws CliException {
        int argCount = 0;
        for (int i = 0; i < args.length; i++) {
            String arg = args[i];
            if (arg.startsWith("-")) {
                if (arg.equals("-r")) {
                    recursive = true;
                } else if (arg.equals("-c")) {
                    if (i == args.length - 1) {
                        throw new CliException(MessageFormat.format("Missing argument for option {0}", arg));
                    }
                    arg = args[++i];
                    configFilePath = arg;
                } else {
                    throw new CliException(MessageFormat.format("Unrecognized option {0}", arg));
                }
            } else {
                if (insituDataFilePath == null) {
                    insituDataFilePath = arg;
                } else if (ddsDirectoryPath == null) {
                    ddsDirectoryPath = arg;
                } else {
                    throw new CliException(MessageFormat.format("Unrecognized argument #{0}", argCount + 1));
                }
                argCount++;
            }
        }

        if (insituDataFilePath == null) {
            throw new CliException("Missing argument #1: <matchup-file>");
        }

        if (ddsDirectoryPath == null) {
            ddsDirectoryPath = ".";
        }

        if (configFilePath == null && new File(DEFAULT_CONFIG_FILE_PATH).exists()) {
            configFilePath = DEFAULT_CONFIG_FILE_PATH;
        }
    }

    void parseConfig() throws CliException {
        Properties config = new Properties(System.getProperties());
        if (configFilePath != null) {
            loadConfig(config);
        }
        parseConfig(config);
    }

    void parseConfig(Properties config) {
        fileFormat = parseProperty(config, "fileFormat", "GlobColour-mapped");
        timeTolerance = parseProperty(config, "timeTolerance", 24L * 60L * 60L * 1000L);
        pixelBorderSize = parseProperty(config, "pixelBorderSize", 2);
        outputSeparator = parseProperty(config, "outputSeparator", ",");
        outputSuffix = parseProperty(config, "outputSuffix", "_Results");
        outputMeanSuffix = parseProperty(config, "outputMeanSuffix", "_ResultsMean");
        outputSummarySuffix = parseProperty(config, "outputSummarySuffix", "_ResultsSummary");
        maxCV = parseProperty(config, "maxCV", 0.15);
        minSampleCount = parseProperty(config, "minSampleCount", 13);
    }

    private static long parseProperty(Properties config, String name, long defaultValue) {
        String value = config.getProperty(name);
        if (value != null) {
            return Long.parseLong(value);
        } else {
            return defaultValue;
        }
    }

    private static int parseProperty(Properties config, String name, int defaultValue) {
        String value = config.getProperty(name);
        if (value != null) {
            return Integer.parseInt(value);
        } else {
            return defaultValue;
        }
    }

    private static double parseProperty(Properties config, String name, double defaultValue) {
        String value = config.getProperty(name);
        if (value != null) {
            return Double.parseDouble(value);
        } else {
            return defaultValue;
        }
    }

    private static String parseProperty(Properties config, String name, String defaultValue) {
        String value = config.getProperty(name);
        if (value != null) {
            return value;
        } else {
            return defaultValue;
        }
    }

    public static String getDefaultConfigFile() {
        return DEFAULT_CONFIG_FILE_PATH;
    }

    public String getInsituDataFilePath() {
        return insituDataFilePath;
    }

    public String getConfigFilePath() {
        return configFilePath;
    }

    public String getDdsDirectoryPath() {
        return ddsDirectoryPath;
    }

    public boolean isRecursive() {
        return recursive;
    }

    public long getTimeTolerance() {
        return timeTolerance;
    }

    public String getFileFormat() {
        return fileFormat;
    }

    public int getPixelBorderSize() {
        return pixelBorderSize;
    }

    public String getOutputSuffix() {
        return outputSuffix;
    }

    public String getOutputMeanSuffix() {
        return outputMeanSuffix;
    }

    public String getOutputSummarySuffix() {
        return outputSummarySuffix;
    }

    public double getMaxCV() {
        return maxCV;
    }

    public int getMinSampleCount() {
        return minSampleCount;
    }

    private void loadConfig(Properties config) throws CliException {
        try {
            final InputStream inputStream = new FileInputStream(configFilePath);
            try {
                config.load(inputStream);
            } finally {
                inputStream.close();
            }
        } catch (IOException e) {
            throw new CliException("Failed to load configuration " + configFilePath + ": " + e.getMessage());
        }
    }


    static class CliException extends Exception {
        public CliException(String message) {
            super(message);
        }
    }


    private static class ProductFileFilter implements FileFilter {
        private ProductReaderPlugIn readerPlugIn;

        public ProductFileFilter(final ProductReaderPlugIn readerPlugIn) {
            this.readerPlugIn = readerPlugIn;
        }

        public boolean accept(File file) {
            if (file.isDirectory()) {
                return true;
            }

            return readerPlugIn.getDecodeQualification(file) == DecodeQualification.INTENDED;
        }

    }


    private static class SpaceTimeCoverage {
        private long minMillis;
        private long maxMillis;

        private double maxLat;
        private double minLat;
        private double maxLon;
        private double minLon;

        public SpaceTimeCoverage(final Product product) {
            minMillis = product.getStartTime().getAsCalendar().getTimeInMillis();
            maxMillis = product.getEndTime().getAsCalendar().getTimeInMillis();

            final PixelPos pixelPosUL = new PixelPos(0.5f, 0.5f);
            final PixelPos pixelPosLR = new PixelPos(product.getSceneRasterWidth() - 0.5f,
                    product.getSceneRasterHeight() - 0.5f);

            final GeoPos geoPosUL = product.getGeoCoding().getGeoPos(pixelPosUL, null);
            final GeoPos geoPosLR = product.getGeoCoding().getGeoPos(pixelPosLR, null);
            minLon = Math.min(geoPosUL.lon, geoPosLR.lon);
            maxLon = Math.max(geoPosUL.lon, geoPosLR.lon);
            minLat = Math.min(geoPosUL.lat, geoPosLR.lat);
            maxLat = Math.max(geoPosUL.lat, geoPosLR.lat);
        }

        public final boolean covers(final double lat, final double lon) {
            return !(lat < minLat || lat > maxLat || lon < minLon || lon > maxLon);
        }

        public final boolean coincidesWith(final long millis, final long toleranceMillis) {
            return !(millis + toleranceMillis < minMillis || millis - toleranceMillis > maxMillis);
        }
    }
}
