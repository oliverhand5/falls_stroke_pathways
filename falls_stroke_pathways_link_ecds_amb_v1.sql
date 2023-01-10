-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Script:	Examining the pathway of fallers & stroke patients in HWICS
-- Author:	Oliver Hand (oliver.hand@nh.,net)
-- Created:	2022-09-27
-- Known issues:	Needs system ratification
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Basic flow:
-- Create a temporary table to hold the reduced and merged dataset.  Data without identifiers is removed.


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create a temporary table to hold the combined dataset.
CREATE OR REPLACE TEMPORARY TABLE tmp_ae999 (pnhsNo VARCHAR(10), dataset VARCHAR(10), prov VARCHAR(50), treat_type VARCHAR(50), complaint VARCHAR(100), county VARCHAR(30), wmas_clock_start DATETIME,wmas_clock_at_scene
	DATETIME,wmas_clock_left_scene DATETIME,wmas_clock_at_provider DATETIME,wmas_clock_handover DATETIME,wmas_vehicle_clear DATETIME ,Duration_Start_to_Vehicle_at_Scene_Seconds INT, Duration_Vehicle_at_Scene_to_Left_Scene_Seconds INT, 
	Duration_Left_Scene_to_Hospital_Seconds INT, Duration_Hospital_to_handover_seconds INT, ecds_arrival DATETIME, ecds_departure_time DATETIME, ecds_acuity VARCHAR(100), ecds_attend_cat VARCHAR(100), ecds_disposal VARCHAR(150)
	,SeenForTreatmentDateTime DATETIME, DecisionToAdmitDateTime DATETIME,adm_admission_date DATETIME, adm_discharge_date DATETIME
	,INDEX ind_ref (pnhsNo,dataset,prov))
 ENGINE=MYISAM;


-- WMAS contacts
-- Pull only data with pseudo nhs numbers and where the call indicates a stroke or fall is likely.  NULLS pad the unused fields.
INSERT INTO tmp_ae999 (
SELECT 
a.NHS_Number
,'ambulance'
,concat(left(a.Provider_Site_Code_Mapped,3),'00')
,a.Treatment_Type_Desc
,a.WMAS_Chief_Complaint_Desc_Mapped
,a.Analysis_Area
,a.Clock_Start_DateTime
,a.DateTime_Vehicle_at_Scene
,a.DateTime_Vehicle_Left_Scene
,a.DateTime_Vehicle_at_Hospital
,a.DateTime_Hospital_Handover
,a.DateTime_Vehicle_Clear
,timestampdiff(second,a.Clock_Start_DateTime,a.DateTime_Vehicle_at_Scene) AS 'Duration_Start_to_Vehicle_at_Scene_Seconds'
,timestampdiff(second,a.DateTime_Vehicle_at_Scene,a.DateTime_Vehicle_Left_Scene) AS 'Duration_Vehicle_at_Scene_to_Left_Scene_Seconds'
,timestampdiff(second,a.DateTime_Vehicle_Left_Scene,a.DateTime_Vehicle_at_Hospital) AS 'Duration_Left_Scene_to_Hospital_Seconds'
,timestampdiff(second,a.DateTime_Vehicle_at_Hospital,a.DateTime_Hospital_Handover) AS 'Duration_Hospital_to_handover_seconds'
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL
FROM 43_mlcsu_data_ftp2.tb_wmas_contacts2 a
LEFT JOIN calendar.calendar_table c ON a.Date_of_Incident = c.c_date
WHERE 1=1
and a.WMAS_Chief_Complaint_Desc_Mapped REGEXP ('fall|stroke')
AND a.Date_of_Incident between '2021-08-01' AND '2022-07-31'
AND a.NHS_Number IS NOT NULL 
);


-- ECDS data
-- Pull only data with pseudo nhs numbers.  NULLS pad the unused fields.
INSERT INTO tmp_ae999 (
SELECT 
ecds.pseudo_nhs_no
,'ed'
,ecds.provider_code
,NULL
,ecds.diag_1
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,ecds.arrival_date_time
,ecds.departure_date_time
,ecds.acuity
,ecds.attend_category
,ecds.disposal_method
,ecds.SeenForTreatmentDateTime
,ecds.DecisionToAdmitDateTime
,NULL 
,NULL 
FROM 50_weekly_data.tb_weekly_ecds ecds
WHERE 1=1
AND ecds.pseudo_nhs_no IS NOT NULL
AND ecds.arrival_date_time between '2021-08-01' AND '2022-07-31'
);


-- Inpatient data (emergency admissions)
-- Pull only data with pseudo nhs numbers, dominant episodes, and emergency admissions.  NULLS pad the unused fields.
INSERT INTO tmp_ae999 (
SELECT 
ip.NHSNumber
,'admission'
,ip.ProviderCode
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,NULL 
,ip.AdmissionDate
,ip.DischargeDate
FROM 43_mlcsu_data_ftp2.tb_ip_episodes_all ip
WHERE 1=1 
AND ip.OrderInSpell = 1
AND ip.ReconciliationPoint BETWEEN '202108' AND '202207' 
AND ip.NHSNumber IS NOT NULL 
AND left(ip.AdmissionMethodCode,1) IN ('2') 
AND ip.PatientClassificationCode IN ('1','2') 
);


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Count check for record totals
SELECT 
COUNT(*)
FROM tmp_ae999 t
WHERE
t.dataset = 'ambulance'
-- AND t.treat_type = 'See And Convey'
;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE 33_adhoc.tb_falls_3_pathway;
INSERT INTO 33_adhoc.tb_falls_3_pathway (

	-- pull the see & convery ambulance data, calculating required time fields for the stages of the pathway, and the additional groupings for day/night, winter/not-winter, weekday/non-weekday etc.
	-- The self join links the ambulance data on to ECDS data and returns records for the same pseudo-number and provider with a 2hr windoow either side of the handover time (arrival if handowver is missing) and the ecds arrival time.
	-- ECDS data is merged inot the record where matches occur.
	SELECT 
	t.pnhsNo AS 'Pseudo_Nhs_Number'
	,t.prov AS 'Provider'
	,t.treat_type AS 'Amb_Treatment_Type'
	,t.complaint AS 'Amb_Complaint'
	,t1.ecds_acuity AS 'ED_Acuity'
	,t1.complaint AS 'ED_Chief_Complaint'
	,t1.ecds_disposal AS 'ED_Disposal'
	,t.county AS 'County'
	,t.wmas_clock_start AS 'Amb_Call_Datatime'
	,t.wmas_clock_at_scene AS 'Amb_At_Scene_Datatime'
	,t.wmas_clock_left_scene AS 'Amb_Left_Scene_Datatime'
	,t.wmas_clock_at_provider AS 'Amb_At_Hospital_Datatime'
	,t.wmas_clock_handover AS 'Amb_Handover_Datatime'
	,t1.ecds_arrival AS 'ED_Arrival_Datatime'
	,t1.SeenForTreatmentDateTime AS 'ED_Treatment_Datatime'
	,t1.DecisionToAdmitDateTime AS 'ED_DTA_Datatime'
	,t1.ecds_departure_time AS 'ED_Departure_Datatime'
	,case when t.pnhsNo NOT IN (SELECT pnhsno FROM tmp_ae999 WHERE t1.dataset = 'ed' ) then 'Missing' ELSE '' END AS 'Flag'
	,t.Duration_Start_to_Vehicle_at_Scene_Seconds
	,t.Duration_Vehicle_at_Scene_to_Left_Scene_Seconds 
	,t.Duration_Left_Scene_to_Hospital_Seconds
	,t.Duration_Hospital_to_handover_seconds
	,timestampdiff(SECOND,t1.ecds_arrival,t1.SeenForTreatmentDateTime) AS 'Duration_arrival_to_treatment_seconds'
	,timestampdiff(SECOND,t1.ecds_arrival,t1.DecisionToAdmitDateTime) AS 'Duration_arrival_to_dta_seconds'
	,timestampdiff(second,t1.ecds_arrival,t1.ecds_departure_time) AS 'Duration_arrival_to_departure_seconds'
	,timestampdiff(second,t1.DecisionToAdmitDateTime,t1.ecds_departure_time) AS 'Duration_dta_to_departure_seconds'
	,case when left(time(t.wmas_clock_start),2) BETWEEN 8 AND 17 then 'day' ELSE 'night' END AS 'is_daynight'
	,case when DAYOFWEEK(t.wmas_clock_start) BETWEEN 0 AND 4 then 'weekday' ELSE 'weekend' END AS 'is_weekday'
	,case when MONTH(t.wmas_clock_start) IN ('1','2','3','12','11') then 'winter' ELSE 'not_winter' END AS 'is_winter'
	FROM tmp_ae999 t
		LEFT JOIN tmp_ae999 t1 ON t1.pnhsNo = t.pnhsNo AND t1.prov = t.prov AND TIMESTAMPDIFF(minute,ifnull(t.wmas_clock_handover,t.wmas_clock_at_provider),t1.ecds_arrival) BETWEEN -120 AND 120 AND t1.dataset = 'ed'	
	WHERE 1=1
	and t.dataset = 'ambulance'
	AND t.treat_type = 'See And Convey'
	
	
	UNION all
	

	-- pull the remaining ambulance trust data (no ambulance conveyance occured).
	SELECT 
	t.pnhsNo AS 'Pseudo_Nhs_Number'
	,t.prov AS 'Provider'
	,t.treat_type AS 'Amb_Treatment_Type'
	,t.complaint AS 'Amb_Complaint'
	,NULL AS 'ED_Acuity'
	,NULL AS 'ED_Chief_Complaint'
	,NULL AS 'ED_Disposal'
	,t.county AS 'County'
	,t.wmas_clock_start AS 'Amb_Call_Datatime'
	,t.wmas_clock_at_scene AS 'Amb_At_Scene_Datatime'
	,t.wmas_clock_left_scene AS 'Amb_Left_Scene_Datatime'
	,t.wmas_clock_at_provider AS 'Amb_At_Hospital_Datatime'
	,t.wmas_clock_handover AS 'Amb_Handover_Datatime'
	,NULL AS 'ED_Arrival_Datatime'
	,NULL AS 'ED_Treatment_Datatime'
	,NULL AS 'ED_DTA_Datatime'
	,NULL AS 'ED_Departure_Datatime'
	,NULL AS 'Flag'
	,t.Duration_Start_to_Vehicle_at_Scene_Seconds
	,t.Duration_Vehicle_at_Scene_to_Left_Scene_Seconds 
	,t.Duration_Left_Scene_to_Hospital_Seconds
	,t.Duration_Hospital_to_handover_seconds
	,NULL AS 'Duration_arrival_to_treatment_seconds'
	,NULL AS 'Duration_arrival_to_dta_seconds'
	,NULL AS 'Duration_arrival_to_departure_seconds'
	,NULL AS 'Duration_dta_to_departure_seconds'
	,NULL
	,NULL
	,NULL
	FROM tmp_ae999 t	
	WHERE 1=1
	and t.dataset = 'ambulance'
	AND t.treat_type <> 'See And Convey'
);



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- data export
SELECT *
INTO OUTFILE 'D:/reports/falls/fall_stroke_detail.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	-- 'data_type',
	'Pseudo_Nhs_Number','Provider','Amb_Treatment_Type','Amb_Complaint','ED_Acuity','ED_Chief_Complaint','ED_Disposal','County','Amb_Call_Datatime','Amb_At_Scene_Datatime','Amb_Left_Scene_Datatime','Amb_At_Hospital_Datatime','Amb_Handover_Datatime'
	,'ED_Arrival_Datatime','ED_Treatment_Datatime','ED_DTA_Datatime','ED_Departure_Datatime','Flag','Duration_Start_to_Vehicle_at_Scene_Seconds','Duration_Vehicle_at_Scene_to_Left_Scene_Seconds','Duration_Left_Scene_to_Hospital_Seconds','Duration_Hospital_to_handover_seconds'
	,'Duration_arrival_to_treatment_seconds','Duration_arrival_to_dta_seconds','Duration_arrival_to_departure_seconds','Duration_dta_to_departure_seconds','is_day_night','is_weekday_weekend','is_winter'
UNION ALL
SELECT * FROM 33_adhoc.tb_falls_3_pathway
) exp;




SELECT 
p.County
,p.ED_Acuity
,p.Amb_Complaint
,p.Amb_Treatment_Type
,COUNT(*)
FROM 33_adhoc.tb_falls_3_pathway p 
GROUP by
p.County
,p.ED_Acuity
,p.Amb_Complaint
,p.Amb_Treatment_Type



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Sankey chart produciton - falls only - currently work in progress
SELECT *
INTO OUTFILE 'D:/reports/falls/fall_sankey.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	-- 'data_type',
	'Source','Target','Vol'
UNION ALL

SELECT 
'4' AS 'Source'
,case 
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Closed fracture : femur (not NoF)','Open fracture : femur') AND t.ED_DTA_Datatime IS NOT null then '5'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Open fracture : hip (NoF)','Closed fracture : hip (NoF)') AND t.ED_DTA_Datatime IS NOT null then '7'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_DTA_Datatime IS NOT null then '9'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Closed fracture : femur (not NoF)','Open fracture : femur') then '6'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Open fracture : hip (NoF)','Closed fracture : hip (NoF)') then '8'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL then '10'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS null then '11'
	ELSE '' END AS 'Target'
,COUNT(*) AS 'Vol'
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1
AND t.Amb_Treatment_Type = 'See And Convey'
AND t.Amb_Complaint REGEXP ('fall')
GROUP BY
case 
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Closed fracture : femur (not NoF)','Open fracture : femur') AND t.ED_DTA_Datatime IS NOT null then '5'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Open fracture : hip (NoF)','Closed fracture : hip (NoF)') AND t.ED_DTA_Datatime IS NOT null then '7'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_DTA_Datatime IS NOT null then '9'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Closed fracture : femur (not NoF)','Open fracture : femur') then '6'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_Chief_Complaint IN ('Open fracture : hip (NoF)','Closed fracture : hip (NoF)') then '8'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL then '10'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS null then '11'
	ELSE '' END

UNION ALL 

SELECT 
case 
	when t.Amb_Treatment_Type = 'See And Convey' then '0'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '0'
	when t.Amb_Treatment_Type = 'See And Treat' then '0'
	when t.Amb_Treatment_Type = 'No Treatment' then '0'
	ELSE '' END AS 'Source'
,case 
	when t.Amb_Treatment_Type = 'See And Convey' then '4'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '1'
	when t.Amb_Treatment_Type = 'See And Treat' then '3'
	when t.Amb_Treatment_Type = 'No Treatment' then '2'
	ELSE '' END AS 'Target'
,COUNT(*) AS 'Vol'
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1
AND t.Amb_Complaint REGEXP ('fall')
GROUP BY
case 
	when t.Amb_Treatment_Type = 'See And Convey' then '0'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '0'
	when t.Amb_Treatment_Type = 'See And Treat' then '0'
	when t.Amb_Treatment_Type = 'No Treatment' then '0'
	ELSE '' END 
,case 
	when t.Amb_Treatment_Type = 'See And Convey' then '4'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '1'
	when t.Amb_Treatment_Type = 'See And Treat' then '3'
	when t.Amb_Treatment_Type = 'No Treatment' then '2'
	ELSE '' END
) EXP1;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Sankey chart produciton - stroke only - currently work in progress
SELECT *
INTO OUTFILE 'D:/reports/falls/stroke_sankey.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	-- 'data_type',
	'Source','Target','Vol'
UNION ALL

SELECT 
'4' AS 'Source'
,case 
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_DTA_Datatime IS NOT null then '12'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL then '13'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS null then '11'
	ELSE '' END AS 'Target'
,COUNT(*) AS 'Vol'
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1
AND t.Amb_Treatment_Type = 'See And Convey'
AND t.Amb_Complaint REGEXP ('stroke')
GROUP BY
case 
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL AND t.ED_DTA_Datatime IS NOT null then '12'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS NOT NULL then '13'
	when t.Amb_Treatment_Type = 'See And Convey' and t.ED_Arrival_Datatime IS null then '11'
	ELSE '' END

UNION ALL 

SELECT 
case 
	when t.Amb_Treatment_Type = 'See And Convey' then '0'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '0'
	when t.Amb_Treatment_Type = 'See And Treat' then '0'
	when t.Amb_Treatment_Type = 'No Treatment' then '0'
	ELSE '' END AS 'Source'
,case 
	when t.Amb_Treatment_Type = 'See And Convey' then '4'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '1'
	when t.Amb_Treatment_Type = 'See And Treat' then '3'
	when t.Amb_Treatment_Type = 'No Treatment' then '2'
	ELSE '' END AS 'Target'
,COUNT(*) AS 'Vol'
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1
AND t.Amb_Complaint REGEXP ('stroke')
GROUP BY
case 
	when t.Amb_Treatment_Type = 'See And Convey' then '0'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '0'
	when t.Amb_Treatment_Type = 'See And Treat' then '0'
	when t.Amb_Treatment_Type = 'No Treatment' then '0'
	ELSE '' END 
,case 
	when t.Amb_Treatment_Type = 'See And Convey' then '4'
	when t.Amb_Treatment_Type = 'Hear And Treat' then '1'
	when t.Amb_Treatment_Type = 'See And Treat' then '3'
	when t.Amb_Treatment_Type = 'No Treatment' then '2'
	ELSE '' END
) EXP2;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Export data for R processing into boxplots

-- Export WMAS based charts for first 4 stages of the pathway to allow the charts split, include ALL ECDS attendances irrespective of diagnostic findings at A&E department.
SELECT *
INTO OUTFILE 'D:/reports/falls/boxp_normal_1-4.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	'Amb_Complaint','County','Cat','Vol','is_day_night','is_weekday','is_winter'
UNION ALL

SELECT 
t.Amb_Complaint, t.County,'1 Call->Scene',t.Duration_Start_to_Vehicle_at_Scene_Seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall') AND Duration_Start_to_Vehicle_at_Scene_Seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'2 Arrive->LeaveScene',t.Duration_Vehicle_at_Scene_to_Left_Scene_Seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_Vehicle_at_Scene_to_Left_Scene_Seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'3 Scene->Hospital',t.Duration_Left_Scene_to_Hospital_Seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_Left_Scene_to_Hospital_Seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'4 Hospital->Handover',t.Duration_Hospital_to_handover_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_Hospital_to_handover_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
) ds1;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Export WMAS based charts for latter 4 stages of the pathway to allow the charts split, include ALL ECDS attendances irrespective of diagnostic findings at A&E department.
SELECT *
INTO OUTFILE 'D:/reports/falls/boxp_normal_5-8.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	'Amb_Complaint','County','Cat','Vol','is_day_night','is_weekday','is_winter'
UNION ALL

SELECT 
t.Amb_Complaint, t.County,'5 ED Arrival->Treat',t.Duration_arrival_to_treatment_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_arrival_to_treatment_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'6 ED Arrival->DTA',t.Duration_arrival_to_dta_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_arrival_to_dta_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'7 ED Arrival->Departure',t.Duration_arrival_to_departure_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_arrival_to_departure_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'8 ED Dta->Departure',t.Duration_dta_to_departure_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_dta_to_departure_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
) ds2;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Export WMAS based charts for first 4 stages of the pathway to allow the charts split, include only ECDS attendances matches where the ED depaartment coding suggests stroke or hip fractures.
SELECT *
INTO OUTFILE 'D:/reports/falls/boxp_ed_1-4.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	'Amb_Complaint','County','Cat','Vol','is_day_night','is_weekday','is_winter'
UNION ALL

SELECT 
t.Amb_Complaint, t.County,'1 Call->Scene',t.Duration_Start_to_Vehicle_at_Scene_Seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall') AND Duration_Start_to_Vehicle_at_Scene_Seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'2 Arrive->LeaveScene',t.Duration_Vehicle_at_Scene_to_Left_Scene_Seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_Vehicle_at_Scene_to_Left_Scene_Seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'3 Scene->Hospital',t.Duration_Left_Scene_to_Hospital_Seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_Left_Scene_to_Hospital_Seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'4 Hospital->Handover',t.Duration_Hospital_to_handover_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_Hospital_to_handover_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')
) ds3;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Export WMAS based charts for latter 4 stages of the pathway to allow the charts split, include only ECDS attendances matches where the ED depaartment coding suggests stroke or hip fractures.
SELECT *
INTO OUTFILE 'D:/reports/falls/boxp_ed_5-8.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	'Amb_Complaint','County','Cat','Vol','is_day_night','is_weekday','is_winter'
UNION ALL

SELECT 
t.Amb_Complaint, t.County,'5 ED Arrival->Treat',t.Duration_arrival_to_treatment_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_arrival_to_treatment_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'6 ED Arrival->DTA',t.Duration_arrival_to_dta_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_arrival_to_dta_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'7 ED Arrival->Departure',t.Duration_arrival_to_departure_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_arrival_to_departure_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')

UNION ALL 
SELECT 
t.Amb_Complaint, t.County,'8 ED Dta->Departure',t.Duration_dta_to_departure_seconds / 3600, is_day_night, is_weekday, is_winter
FROM 33_adhoc.tb_falls_3_pathway t	
WHERE 1=1 AND t.Amb_Treatment_Type = 'See And Convey' AND t.Amb_Complaint REGEXP ('stroke|fall')  AND Duration_dta_to_departure_seconds IS NOT NULL AND County IN ('Herefordshire','Worcester')
	AND t.ED_Chief_Complaint IN ('Stroke','Closed fracture : hip (NoF)','Open fracture : hip (NoF)')
) ds4;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TEMPORARY TABLE if EXISTS tmp_ae999;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Falls trends export
SELECT *
INTO OUTFILE 'D:/reports/falls/fall_trend.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM (
SELECT 
	'Treatment_Type_Desc','Complaint','County','Period','Vol'
UNION ALL

SELECT 
a.Treatment_Type_Desc
,a.WMAS_Chief_Complaint_Desc_Mapped
,a.Analysis_Area
,left(a.Clock_Start_DateTime,10) AS 'Call Date'
,COUNT(*) AS 'Vol'

FROM 43_mlcsu_data_ftp2.tb_wmas_contacts2 a
LEFT JOIN calendar.calendar_table c ON a.Date_of_Incident = c.c_date
WHERE
a.WMAS_Chief_Complaint_Desc_Mapped REGEXP ('fall|stroke')
AND a.Date_of_Incident between '2021-08-01' AND '2022-07-31'
AND a.Analysis_Area IN ('Herefordshire','Worcester')

GROUP BY
a.Treatment_Type_Desc
,a.WMAS_Chief_Complaint_Desc_Mapped
,a.Analysis_Area
,left(a.Clock_Start_DateTime,10)
) exp_trend;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

