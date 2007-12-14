FUNCTION get_avg_template

;+
;NAME:
;   GET_AVG_TEMPLATE
;PURPOSE:
;   RETURNS GLOBCOLOUR MATCH-UP AVERAGE FILE TEMPLATE THAT CAN BE USED IN READING
;   THE AVERAGE FILE USING READ_ASCII
;INPUTS:
;   NONE
;OUTPUT:
;   GLOBCOLOUR AVERAGE TEMPLATE ANONYMOUS STRUCTURE
;SYNTAX:
;   template=get_avg_template()
;
;Note: The idl function create_struct() can also be used instead of {} to create anonymous structure like
;   avg_tenplate = CREATE_STRUCT('VERSION',1.0, 'DATASTART',1, and so on)
;Author: Yaswant Pradhan, Mar 07
;-

  avg_template={$
   VERSION : 1.0,$
   DATASTART : 1,$
   DELIMITER : 44b,$
   MISSINGVALUE : !Values.F_NaN,$
   COMMENTSYMBOL : '',$
   FIELDCOUNT : 162,$
   FIELDTYPES : [7,7,4,4,7,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4, $
          4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4, $
          4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4, $
          4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,7,7],$
   FIELDNAMES : ['inID','inTime','inLat','inLon','ddsTime','ddsLat','ddsLon','inChl','inChl_Flag','inK490','inTSM','inaCDM','inBBP','inT865','inL412','inL443','inL490','inL510','inL531','inL555','inL620','inL670','inL681','inL709', $
   'ddsChl1_avg','ddsChl2_avg','ddsK490_avg','ddsTSM_avg','ddsaCDM_avg','ddsBBP_avg','ddsT865_avg','ddsL412_avg','ddsL443_avg','ddsL490_avg','ddsL510_avg','ddsL531_avg','ddsL555_avg','ddsL620_avg','ddsL670_avg','ddsL681_avg','ddsL709_avg', $
   'ddsChl1_med','ddsChl2_med','ddsK490_med','ddsTSM_med','ddsaCDM_med','ddsBBP_med','ddsT865_med','ddsL412_med','ddsL443_med','ddsL490_med','ddsL510_med','ddsL531_med','ddsL555_med','ddsL620_med','ddsL670_med','ddsL681_med','ddsL709_med', $
   'ddsChl1_std','ddsChl2_std','ddsK490_std','ddsTSM_std','ddsaCDM_std','ddsBBP_std','ddsT865_std','ddsL412_std','ddsL443_std','ddsL490_std','ddsL510_std','ddsL531_std','ddsL555_std','ddsL620_std','ddsL670_std','ddsL681_std','ddsL709_std', $
   'ddsChl1_N','ddsChl2_N','ddsK490_N','ddsTSM_N','ddsaCDM_N','ddsBBP_N','ddsT865_N','ddsL412_N','ddsL443_N','ddsL490_N','ddsL510_N','ddsL531_N','ddsL555_N','ddsL620_N','ddsL670_N','ddsL681_N','ddsL709_N', $
   'ddsChl1_avg2','ddsChl2_avg2','ddsK490_avg2','ddsTSM_avg2','ddsaCDM_avg2','ddsBBP_avg2','ddsT865_avg2', $
   'ddsL412_avg2','ddsL443_avg2','ddsL490_avg2','ddsL510_avg2','ddsL531_avg2','ddsL555_avg2','ddsL620_avg2','ddsL670_avg2','ddsL681_avg2','ddsL709_avg2', $
   'ddsChl1_med2','ddsChl2_med2','ddsK490_med2','ddsTSM_med2','ddsaCDM_med2','ddsBBP_med2','ddsT865_med2', $
   'ddsL412_med2','ddsL443_med2','ddsL490_med2','ddsL510_med2','ddsL531_med2','ddsL555_med2','ddsL620_med2','ddsL670_med2','ddsL681_med2','ddsL709_med2', $
   'ddsChl1_std2','ddsChl2_std2','ddsK490_std2','ddsTSM_std2','ddsaCDM_std2','ddsBBP_std2','ddsT865_std2', $
   'ddsL412_std2','ddsL443_std2','ddsL490_std2','ddsL510_std2','ddsL531_std2','ddsL555_std2','ddsL620_std2','ddsL670_std2','ddsL681_std2','ddsL709_std2', $
   'ddsChl1_N2','ddsChl2_N2','ddsK490_N2','ddsTSM_N2','ddsaCDM_N2','ddsBBP_N2','ddsT865_N2','ddsL412_N2','ddsL443_N2','ddsL490_N2','ddsL510_N2','ddsL531_N2','ddsL555_N2','ddsL620_N2','ddsL670_N2','ddsL681_N2','ddsL709_N2', $
   'ddsFilename','Input_file_Tag'],$
   FIELDLOCATIONS : [0,11,28,44,60,77,93,109,135,161,187,213,239,265,291,317,343,369,395,421,447,473,499,525,551,567,583,599,615,631,647,663,679,695,711,727,743,759,775,791,807,823,839,855,871, $
   887,903,919,935,951,967,983,999,1015,1031,1047,1063,1079,1095,1111,1127,1143,1159,1175,1191,1207,1223,1239,1255,1271,1287,1303,1319,1335,1351,1367,1383,1399,1415,1431,1447,1463,1479,1495, $
   1511,1527,1543,1559,1575,1591,1607,1623,1639,1655,1671,1687,1703,1719,1735,1751,1767,1783,1799,1815,1831,1847,1863,1879,1895,1911,1927,1943,1959,1975,1991,2007,2023,2039,2055,2071,2087, $
   2103,2119,2135,2151,2167,2183,2199,2215,2231,2247,2263,2279,2295,2311,2327,2343,2359,2375,2391,2407,2423,2439,2455,2471,2487,2503,2519,2535,2551,2567,2583,2599,2615,2631,2647,2663, $
   2679,2695,2711,2727,2778], $
   FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50, $
   51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102, $
   103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142, $
   143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161] }

  return,avg_template

END