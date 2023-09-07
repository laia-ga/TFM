SELECT DISTINCT ing.pacnhc AS NHC, ing.ingepi AS EPI, 
    DAYS(DATE(TIMESTAMP_FORMAT(CHAR(ing.ingfal), 'YYYYMMDD'))) - 
    DAYS(DATE(TIMESTAMP_FORMAT(CHAR(ing.ingfin), 'YYYYMMDD'))) AS LOS,
    DAYOFWEEK(DATE(TIMESTAMP_FORMAT(CHAR(ingfin),'YYYYMMDD'))) AS DIA_INGRESO,
    rq.rquhip HORA_INICIO_PROC, 
    rq.rquhfp AS HORA_FINAL_PROC,
    CASE
        WHEN rq.rqutia = 'RAQ' THEN '1'
        WHEN rq.rqutia = 'GEN' THEN '0'
    END AS TIPO_ANESTESIA,
    CASE
        WHEN bnp.rquint IS NOT NULL THEN '1'
        ELSE '0'
    END AS BLOQUEO_NERVIO_PERIFERICO,
    CASE
        WHEN mpd.prccod LIKE '%Z' THEN '0'
        WHEN mpd.prccod LIKE '%A' THEN '1'
        WHEN mpd.prccod LIKE '%9' THEN '2'
    END AS FIJACION,
    CASE
        WHEN mpd.prccod LIKE '%1%' THEN '1'
        WHEN mpd.prccod LIKE '%2%' THEN '3'
        WHEN mpd.prccod LIKE '%3%' THEN '2'
        WHEN mpd.prccod LIKE '%4%' THEN '4'
        WHEN mpd.prccod LIKE '%6%' THEN '5'
        ELSE '0'
    END AS PAR_FRICCION,
    CASE
        WHEN mp.pacsex = 'F' THEN '0'
        WHEN mp.pacsex = 'M' THEN '1'
    END AS SEXO, 
    YEAR(DATE(TIMESTAMP_FORMAT(CHAR(ing.ingfin), 'YYYYMMDD'))) - YEAR(DATE(TIMESTAMP_FORMAT(CHAR(mp.PACFNA), 'YYYYMMDD'))) AS EDAD,
    CASE
        WHEN asd.diaprl IN ('M16.12', 'M15.11') THEN '1'
        ELSE '0' 
    END AS ARTROSIS_PRIMARIA_CADERA, 
    CASE
        WHEN asd.diaprl LIKE ('S72%') THEN '1' 
        ELSE '0' 
    END AS FRACTURAS_FEMUR, 
    CASE
        WHEN asd.diaxx2 = 'I10' OR asd.diaxx3 = 'I10' OR asd.diaxx4 = 'I10' THEN '1'
        ELSE '0'
    END AS HIPERTENSION,
    CASE
        WHEN asd.diaxx2 = 'E11.9' OR asd.diaxx3 = 'E11.9' THEN '1'
        ELSE '0'
    END AS DIABETES_MELLITUS,
    CASE
        WHEN asd.diaxx2 = 'E78.5' OR asd.diaxx3 = 'E78.5' OR asd.diaxx4 = 'E78.5' THEN '1'
        ELSE '0'
    END AS HIPERLIPIDEMIA,
    CASE
        WHEN asd.diaxx2 = 'N18.9' OR asd.diaxx3 = 'N18.9' OR asd.diaxx4 LIKE 'N18.9' THEN '1' 
        ELSE '0'
    END AS ENFERMEDAD_RENAL_CRONICA,
    CASE
        WHEN asd.diaxx2 LIKE 'I21.3%' OR asd.diaxx3 LIKE 'I21.3%' OR asd.diaxx4 LIKE 'I21.3%' THEN '1'
        ELSE '0'
    END AS INFARTO_MIOCARDIO
FROM udcdat.admingf AS ing 
JOIN udcdat.admpacf AS mp ON ing.pacnhc = mp.pacnhc 
JOIN udcdat.deprquf AS rq ON ing.ingepi = rq.rquepi AND ing.pacnhc = rq.rqunhc 
JOIN udcdat.dptdp0f AS asd ON ing.ingepi = asd.ingepi AND ing.pacnhc = asd.pacnhc 
JOIN udcdat.deppr0f AS mpd ON asd.prcprl = mpd.prccod
LEFT JOIN (SELECT rquint, rqunhc, rquepi FROM udcdat.deprquf WHERE rquint LIKE '%BLOQUEO%') AS bnp
    ON ing.pacnhc = bnp.rqunhc AND ing.ingepi = bnp.rquepi
WHERE (mpd.prccod LIKE '0SRB%' OR mpd.prccod LIKE '0SR9%')
AND mp.pacfna <> '0' AND rq.rquint LIKE '%SUSTITUCION TOTAL%';
