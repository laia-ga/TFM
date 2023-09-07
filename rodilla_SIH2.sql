SELECT DISTINCT ing.HISTORYNUMBER AS NHC, ing.PROCESSID AS EPI,
    DATEDIFF(DAY, ing.ING, ing.ALT) AS LOS,
    DATEPART(WEEKDAY, ing.ING) AS DIA_INGRESO,
    CASE
        WHEN DATEDIFF(MINUTE, rq.STARTTIMESURGERY, rq.ENDTIMESURGERY) > 10 THEN DATEDIFF(MINUTE, rq.STARTTIMESURGERY, rq.ENDTIMESURGERY)
        ELSE DATEDIFF(MINUTE, otb.ENTRYSURGICAL, otb.DEPARTURESSURGICAL)
    END AS DURACION_PROC,
    CASE
        WHEN a.ANESTHESIATYPE = 4 THEN '1'
        ELSE '0'
    END AS BLOQUEO_NERVIO_PERIFERICO,
    CASE
        WHEN cp.OFFICIALID LIKE '%Z' THEN '0'
        WHEN cp.OFFICIALID LIKE '%A' THEN '1'
        WHEN cp.OFFICIALID LIKE '%9' THEN '2'
    END AS FIJACION, mp.GENDER AS SEXO, 
    DATEDIFF(YEAR, mp.DATEBIRTH, ing.ING) AS EDAD,
    CASE
        WHEN trim(ing.CUSTOMERID) + trim (ing.PROCESSID) IN 
            (SELECT trim(dcd.CUSTOMERID) + trim(dcd.PROCESSID) FROM [General]..DocumentalistCodedDiagnosis AS dcd 
            LEFT JOIN Masters..CodedDiagnostics AS cd ON dcd.DIAGNOSISID = cd.DIAGNOSISID
            WHERE cd.OFFICIALID IN ('M17.12', 'M17.11')) THEN '1'
        ELSE '0'
    END AS ARTROSIS_PRIMARIA_RODILLA,
    CASE
        WHEN trim(ing.CUSTOMERID) + trim (ing.PROCESSID) IN 
            (SELECT trim(dcd.CUSTOMERID) + trim(dcd.PROCESSID) FROM [General]..DocumentalistCodedDiagnosis AS dcd 
            LEFT JOIN Masters..CodedDiagnostics AS cd ON dcd.DIAGNOSISID = cd.DIAGNOSISID
            WHERE cd.OFFICIALID LIKE 'T84%') THEN '1'
        ELSE '0'
    END AS PROTESIS_INTERNA_PREVIA,
    CASE
        WHEN trim(ing.CUSTOMERID) + trim (ing.PROCESSID) IN 
            (SELECT trim(dcd.CUSTOMERID) + trim(dcd.PROCESSID) FROM [General]..DocumentalistCodedDiagnosis AS dcd 
            LEFT JOIN Masters..CodedDiagnostics AS cd ON dcd.DIAGNOSISID = cd.DIAGNOSISID
            WHERE cd.OFFICIALID = 'I10') THEN '1'
        ELSE '0'
    END AS HIPERTENSION,
    CASE
        WHEN trim(ing.CUSTOMERID) + trim (ing.PROCESSID) IN 
            (SELECT trim(dcd.CUSTOMERID) + trim(dcd.PROCESSID) FROM [General]..DocumentalistCodedDiagnosis AS dcd 
            LEFT JOIN Masters..CodedDiagnostics AS cd ON dcd.DIAGNOSISID = cd.DIAGNOSISID
            WHERE cd.OFFICIALID = 'E11.9') THEN '1'
        ELSE '0'
    END AS DIABETES_MELLITUS,
    CASE
        WHEN trim(ing.CUSTOMERID) + trim (ing.PROCESSID) IN 
            (SELECT trim(dcd.CUSTOMERID) + trim(dcd.PROCESSID) FROM [General]..DocumentalistCodedDiagnosis AS dcd 
            LEFT JOIN Masters..CodedDiagnostics AS cd ON dcd.DIAGNOSISID = cd.DIAGNOSISID
            WHERE cd.OFFICIALID = 'E78.5') THEN '1'
        ELSE '0'
    END AS HIPERLIPIDEMIA,
    CASE
        WHEN trim(ing.CUSTOMERID) + trim (ing.PROCESSID) IN 
            (SELECT trim(dcd.CUSTOMERID) + trim(dcd.PROCESSID) FROM [General]..DocumentalistCodedDiagnosis AS dcd 
            LEFT JOIN Masters..CodedDiagnostics AS cd ON dcd.DIAGNOSISID = cd.DIAGNOSISID
            WHERE cd.OFFICIALID = 'N18.9') THEN '1'
        ELSE '0'
    END AS ENFERMEDAD_RENAL_CRONICA,
    CASE
        WHEN trim(ing.CUSTOMERID) + trim (ing.PROCESSID) IN 
            (SELECT trim(dcd.CUSTOMERID) + trim(dcd.PROCESSID) FROM [General]..DocumentalistCodedDiagnosis AS dcd 
            LEFT JOIN Masters..CodedDiagnostics AS cd ON dcd.DIAGNOSISID = cd.DIAGNOSISID
            WHERE cd.OFFICIALID LIKE 'I21.3%') THEN '1'
        ELSE '0'
    END AS INFARTO_MIOCARDIO
FROM (SELECT CUSTOMERID, HISTORYNUMBER, PROCESSID,
	min(HOSPITALIZATIONDATE) AS ING, max(DISCHARGEDREADDATE) AS ALT
	FROM Healthcareprocs..HospProcess
	GROUP BY CUSTOMERID, HISTORYNUMBER, PROCESSID) AS ing
JOIN PatientManagement..Customer AS mp ON ing.CUSTOMERID = mp.CUSTOMERID
JOIN Surgery..Surgical AS rq ON ing.CUSTOMERID = rq.CUSTOMERID AND ing.PROCESSID = rq.PROCESSID
JOIN Surgery..OperatingTheatreBook AS otb ON ing.CUSTOMERID = otb.CUSTOMERID AND ing.PROCESSID = otb.PROCESSID
LEFT JOIN Surgery..SProcedure AS sp ON ing.CUSTOMERID = sp.CUSTOMERID AND ing.PROCESSID = sp.PROCESSID
LEFT JOIN Masters..CodedProcedures AS cp ON sp.PREOPERATIVEINDICATIONID = cp.DIAGNOSISID
LEFT JOIN Surgery..Anesth AS a ON ing.CUSTOMERID = a.CUSTOMERID AND ing.PROCESSID = a.PROCESSID
WHERE (cp.OFFICIALID LIKE '0SRC%' OR cp.OFFICIALID LIKE '0SRD%');
