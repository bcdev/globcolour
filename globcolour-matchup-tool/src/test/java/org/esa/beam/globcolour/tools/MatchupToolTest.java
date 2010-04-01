/*
    $Id: MatchupToolTest.java,v 1.14 2007-06-21 14:03:21 ralf Exp $

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
import org.esa.beam.dataio.globcolour.MappedProductReaderPlugIn;

import java.util.Properties;

/**
 * Tests for class {@link MatchupTool}.
 *
 * @author Ralf Quast
 * @version $Revision: 1.14 $ $Date: 2007-06-21 14:03:21 $
 */
public class MatchupToolTest extends TestCase {

    public void testParseWithNoArgs() throws MatchupTool.CliException {
        MatchupTool matchupTool = new MatchupTool();
        try {
            matchupTool.parseArgs(new String[]{});
            fail("CliException expected");
        } catch (MatchupTool.CliException e) {
        }
    }

    public void testParseInsituFileOnly() throws MatchupTool.CliException {
        MatchupTool matchupTool = new MatchupTool();
        matchupTool.parseArgs(new String[]{"my-insitu.csv"});
        assertEquals("my-insitu.csv", matchupTool.getInsituDataFilePath());
        assertEquals(".", matchupTool.getDdsDirectoryPath());
        assertEquals(false, matchupTool.isRecursive());
        assertEquals("./gcmt.properties", matchupTool.getConfigFilePath());
    }

    public void testParseInsituFileAndDdsDirRecursive() throws MatchupTool.CliException {
        MatchupTool matchupTool = new MatchupTool();
        matchupTool.parseArgs(new String[]{"my-insitu.csv", "my-dds-dir", "-r"});
        assertEquals("my-insitu.csv", matchupTool.getInsituDataFilePath());
        assertEquals("my-dds-dir", matchupTool.getDdsDirectoryPath());
        assertEquals(true, matchupTool.isRecursive());
        assertEquals("./gcmt.properties", matchupTool.getConfigFilePath());
    }

    public void testParseWithConfigFile() throws MatchupTool.CliException {
        MatchupTool matchupTool = new MatchupTool();
        matchupTool.parseArgs(new String[]{"my-insitu.csv", "-c", "my-config.txt", ".."});
        assertEquals("my-insitu.csv", matchupTool.getInsituDataFilePath());
        assertEquals("..", matchupTool.getDdsDirectoryPath());
        assertEquals(false, matchupTool.isRecursive());
        assertEquals("my-config.txt", matchupTool.getConfigFilePath());
    }

    public void testParseConfigWithDefaults() throws MatchupTool.CliException {
        MatchupTool matchupTool = new MatchupTool();
        matchupTool.parseConfig();

        assertEquals(MappedProductReaderPlugIn.FORMAT_NAME, matchupTool.getFileFormat());
        assertEquals(2, matchupTool.getPixelBorderSize());
        assertEquals(1000 * 24 * 60 * 60, matchupTool.getTimeTolerance());
        assertEquals("_Results", matchupTool.getOutputSuffix());
        assertEquals("_ResultsMean", matchupTool.getOutputMeanSuffix());
        assertEquals("_ResultsSummary", matchupTool.getOutputSummarySuffix());
    }

    public void testParseConfig() throws MatchupTool.CliException {
        MatchupTool matchupTool = new MatchupTool();
        Properties config = new Properties();

        config.setProperty("fileFormat", "biboFormat");
        config.setProperty("pixelBorderSize", "5");
        config.setProperty("timeTolerance", (1000 * 24) + "");
        config.setProperty("outputSuffix", "-res");
        config.setProperty("outputMeanSuffix", "-resmean");
        config.setProperty("outputSummarySuffix", "-ressum");

        matchupTool.parseArgs(new String[]{"insitu5.csv"});
        matchupTool.parseConfig(config);

        assertEquals("biboFormat", matchupTool.getFileFormat());
        assertEquals(5, matchupTool.getPixelBorderSize());
        assertEquals(1000 * 24, matchupTool.getTimeTolerance());

        assertEquals("-res", matchupTool.getOutputSuffix());
        assertEquals("-resmean", matchupTool.getOutputMeanSuffix());
        assertEquals("-ressum", matchupTool.getOutputSummarySuffix());

        assertEquals("insitu5-res.csv", matchupTool.getResultsFile().getPath());
        assertEquals("insitu5-resmean.csv", matchupTool.getMeanResultsFile().getPath());
        assertEquals("insitu5-ressum.csv", matchupTool.getSummaryFile().getPath());
    }
}
