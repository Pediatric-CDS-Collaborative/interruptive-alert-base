select 
	max('SITE_NAME') as SITE
	,LGL.LOCATOR_NAME as NAME
	,ALERT.BPA_LOCATOR_ID as ID
	,count(distinct ALT_HISTORY.ALT_CSN_ID) as FIRINGS

from ALERT
	inner join CL_LGL_NOADD_SING as LGL 
		on (LGL.LOCATOR_ID = ALERT.BPA_LOCATOR_ID)
	inner join ALT_HISTORY 
		on (ALT_HISTORY.ALT_ID = ALERT.ALT_ID)
	inner join ALT_HISTORY_2
		on (ALT_HISTORY_2.ALT_CSN_ID = ALT_HISTORY.ALT_CSN_ID)
	inner join CL_LGL_OVRTME_SING 
		on (CL_LGL_OVRTME_SING.LOCATOR_ID = LGL.LOCATOR_ID)  

	/* -- if you want to limit by age at time of firing, uncomment this block  
	inner join PATIENT 
		on (PATIENT.PAT_ID = ALERT.PAT_ID)
	*/

	/* -- if you want to limit by location, uncomment this block 
	inner join CLARITY_DEP	
		on (CLARITY_DEP.DEPARTMENT_ID = ALT_HISTORY.PATIENT_DEP_ID)
	left join CLARITY_LOC
		on (CLARITY_LOC.LOC_ID = CLARITY_DEP.ADT_PARENT_ID)
	*/
    
	/* if you need to limit by both department and room ID, uncomment this
	    block and add the appropriate WHERE conditions (ACD 2022.07.18) 
	left join V_PAT_ADT_LOCATION_HX
	    on (ALERT.PAT_CSN = V_PAT_ADT_LOCATION_HX.PAT_ENC_CSN AND
		    ALT_HISTORY.ALT_ACTION_INST >= V_PAT_ADT_LOCATION_HX.IN_DTTM AND
			ALT_HISTORY.ALT_ACTION_INST < V_PAT_ADT_LOCATION_HX.OUT_DTTM)
	*/

where ALERT.GENERAL_ALT_TYPE_C = '1' -- BPAs
	and CL_LGL_OVRTME_SING.RELEASED_YN = 'Y' -- Released
	and	ALT_HISTORY.WAS_SHOWN_C = 0 -- Shown
	and ALT_HISTORY_2.BPA_DISPLAY_MODE_C = 3 -- Interruptive
	and ALT_HISTORY.ALT_ACTION_INST >= TO_TIMESTAMP('1-JUL-2022 12:00:00 AM')
	  and ALT_HISTORY.ALT_ACTION_INST < TO_TIMESTAMP('1-JUL-2023 12:00:00 AM')
	
	/* -- if you want to limit by age at time of firing, uncomment this block
	and (datediff(yy, PATIENT.BIRTH_DATE, ALT_HISTORY.ALT_ACTION_INST) - 
		case when dateadd(yy, datediff(yy, PATIENT.BIRTH_DATE, ALT_HISTORY.ALT_ACTION_INST), PATIENT.BIRTH_DATE) > ALT_HISTORY.ALT_ACTION_INST then 1 else 0 end) < 18
	*/
	
	/* -- Limit by age < 21 by day / 365.25 
	and (datediff(day, PATIENT.BIRTH_DATE, ALT_HISTORY.ALT_ACTION_INST) / 365.25 < 21.0)
	*/

	/* -- if you want to limit by location, uncomment this block
	and CLARITY_LOC.LOC_ID = '##########' 
	*/

	/* if you want to limit by department and room using V_PAT_ADT_LOCATION_HX join, 
	   uncomment this block 
	and (
	  -- Limit by a list of departments
	  V_PAT_ADT_LOCATION_HX.ADT_DEPARTMENT_ID in (
        XXXXXXXX,
		XXXXXXXX
	  )
	-- Limit by departments and room IDs
    OR (V_PAT_ADT_LOCATION_HX.ADT_DEPARTMENT_ID = XXXXXXXX
      AND V_PAT_ADT_LOCATION_HX.ADT_ROOM_ID IN ( 
			XX, XX, XX, XX, XX
      ))
	)
	*/
	
group by LGL.LOCATOR_NAME 
	,ALERT.BPA_LOCATOR_ID
order by dbms_random.value
