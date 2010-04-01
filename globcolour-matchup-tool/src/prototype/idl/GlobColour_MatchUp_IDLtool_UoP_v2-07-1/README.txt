~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
File: README.txt
GlobColour Match up tool in IDL

Release: 25 April 2007 13:33, version - 02.07.1
Status: OK (feedback, bug reports welcome)
Contact: Yaswant.Pradhan@plymouth.ac.uk or/and S.Lavender@plymouth.ac.uk
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are two main procedures to perform the match-up using GlobColour DDS and in-situ files (matchup_GlobColour.pro and matchup_Stat_GlobColour.pro).  These two procedures use in-built IDL functions plus the GlobColour utilities indise the 'lib' folder. Make sure to add 'lib' to your IDL default path. 

Description
1. <matchup_GlobColour.pro>
 	Main procedure which takes GlobColour DDS files (binned or mapped) and in-situ tables (GlobColour 31-column format) and produces two CSV (text) files
	1.1 INSITU_v_SENSOR_DDS_Match_extract.csv
		contains extracts of all DDS pixels corresponding to in-situ data
	1.2 INSITU_v_SENSOR_DDS_Match_average.csv
		contains the average of DDS pixels corresponding to each in-situ data
		
Usage:
   	matchup_GlobCOLOUR  [ [,/l3m_dds | ,/l3b_dds] [,/seawifs] [,/modis] [,/meris] [,/time_series] [,CV=value] [,/update]]
   	
Keywords:
	>l3m_dds - this is the default setting. All Level3Mapped DDS files will be searched recursively from the selected directory
	>l3b_dds - set this option if Level3Binned DDS files are considered.  Chose either l3m_dds or l3b_dds (not both at a time)
	>seawifs - only SeaWiFS DDS files are to be searched (default is all 3 sensors)
	>modis - only MODIS DDS files are to be searched (default is all 3 sensors)
	>meris - only MERIS DDS files are to be searched (default is all 3 sensors)
	>time_series - for single location (time-series) in-situ/DDS data 
	>CV - acceptable coefficint of variation within the extracted kernel for type 2 kernel average (default is 0.2 or 20%)
	>update - not implemented
			
			
2. <matchup_Stat_GlobColour.pro>
	Procedure that takes the average.csv file generated from "matchup_GlobColour.pro" produces two CSV (text) files and an EPS file
		2.1 INSITU_v_SENSOR_DDS_Match_summary1.csv
			contains statistics summary type 1* (GlobColour format)
		2.2 INSITU_v_SENSOR_DDS_Match_summary1.csv
			contains statistics summary type 2* (GlobColour format)
		2.3 INSITU_v_SENSOR_DDS_Match_average.eps
			contains the plots of statistics summary type 1,2
	* See <GlobColour_MatchUp_Prorocol_Apr07.doc> file for explanation

Usage:
	matchup_Stat_GlobColour  [,Max_Time_Diff=value] [,/catch_duplicates] [,/show]
	
Keywords:
	>Max_Time_Diff - Maximum allowed time difference between in-situ and DDS (default is +/-12hrs)
	>catch_duplicates - A single in-situ record might have been used more than once if there are more than one  DDS file is available (which is possible). Use this keyword to avoid duplicate match-ups.
	>show - displays the scatter plot EPS file using "gsview32 for windows".  If you have not installed GSview on your machine please comment or change the 'spawn' command at line #2177.  To obtain free (unregistered) version of GSview for several operating system, please visit http://www.cs.wisc.edu/~ghost/gsview/index.htm