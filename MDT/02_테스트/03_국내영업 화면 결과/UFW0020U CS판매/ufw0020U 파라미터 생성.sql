-- CREATE TABLE MBSASMDTBAKHPT.TBSHEMORH_01_20231213 AS (SELECT * FROM MBSASSTD.TBSHEMORH WHERE ORD_DT > '20221231') WITH DATA;

-- 15���� URCF ������ 
CREATE TABLE MBSASMDTBAKUPT.TBSUFURCF15 AS (
SELECT * FROM MBSASMDTDT0.TBSUFURCF WHERE CS_ALLO_VNO_NO NOT IN (SELECT CS_ALLO_VNO_NO FROM MBSASMDTBAK.TBSUFURCF)) WITH DATA;

-- 6272��
SELECT count(*) FROM MBSASMDTBAKUPT.TBSUFURCF15;

-- 15���� URCS ������
CREATE TABLE MBSASMDTBAKUPT.TBSUFURCS15 AS (
SELECT * FROM MBSASMDTDT0.TBSUFURCS WHERE CS_ALLO_VNO_NO IN (SELECT CS_ALLO_VNO_NO FROM MBSASMDTBAKUPT.TBSUFURCF15)) WITH DATA;

-- dsSearch
 INSERT	INTO MBSASDEV.TB_PARAMETER (
 	APPL_ID,
	DATASET,
	COL_CNT,
	SEQ,
	COL_1,
	COL_2,
	COL_3,
	COL_4,
	COL_5,
	COL_6,
	COL_7,
	COL_8,
	COL_9,
	COL_10,
	COL_11,
	COL_12,
	COL_13,
	COL_14,
	COL_15,
	COL_16,
	COL_17,
	COL_18,
	COL_19,
	COL_20,
	COL_21,
	COL_22,
	COL_23,
	COL_24,
	COL_25,
	COL_26,
	COL_27,
	COL_28,
	COL_29,
	COL_30,
	COL_31,
	COL_32,
	COL_33)
SELECT
	'UFW0020U' AS APPL_ID
	, 'dsSearch' AS DATASET
	, 33 AS COL_CNT
	, 0 AS SEQ
	, 'rtlSltcd' AS COL_1
	, 'alloBrnCd' AS COL_2
	, 'alloBrnNm' AS COL_3
	, 'alloWhsCd' AS COL_4
	, 'alloYear' AS COL_5
	, 'alloMn' AS COL_6
	, 'alloSno' AS COL_7
	, 'sltYn' AS COL_8
	, 'ptno' AS COL_9
	, 'smyVndCd' AS COL_10
	, 'smyVndNm' AS COL_11
	, 'smyVndDcd' AS COL_12
	, 'smyVndPrcBsCd' AS COL_13
	, 'hkcDcd' AS COL_14
	, 'brnFuncDcd' AS COL_15
	, 'mctrCd' AS COL_16
	, 'vnoOtptPrntId' AS COL_17
	, 'sndWhsCd' AS COL_18
	, 'InvQty' AS COL_19
	, 'rtlSnstOtptYn' AS COL_20
	, 'csVnoPrntId' AS COL_21
	, 'ozrId' AS COL_22
	, 'ozrPgmId' AS COL_23
	, 'chkYn' AS COL_24
	, 'csAlloVnoNo' AS COL_25
	, 'rtlRsrvDys' AS COL_26
	, 'slRsrvNo' AS COL_27
	, 'ponoIdx' AS COL_28
	, 'rtlSlDcd' AS COL_29
	, 'slGrndRsn' AS COL_30
	, 'idx' AS COL_31
	, 'winType' AS COL_32
	, 'lckAcptNo' AS COL33
	FROM "SYSIBM".dual
UNION ALL
(SELECT
	'UFW0020U' AS APPL_ID
	, 'dsSearch' AS DATASET
	, 33 AS COL_CNT
	, ROW_NUMBER() OVER (ORDER BY 1) AS SEQ
	, URCS.RTL_SL_TCD AS COL_1
	, URCF.ALLO_BRN_CD AS COL_2
	, '' AS COL_3
	, URCF.ALLO_WHS_CD AS COL_4
	, URCF.ALLO_YEAR AS COL_5
	, URCF.ALLO_MN AS COL_6
	, URCF.ALLO_SNO AS COL_7
	, '' AS COL_8
	, '' AS COL_9
	, URCF.SMY_VND_CD AS COL_10
	, URCF.SMY_VND_CUST_NM AS COL_11 
	, '' AS COL_12 					-- "smyVndDcd"
	, URCF.APLY_PRC_CD AS COL_13 		-- "smyVndPrcBsCd"
	, URCS.HKC_DCD AS COL_14 					--"hkcDcd"
	, '' AS COL_15 					-- "brnFuncDcd"
	, '' AS COL_16 --"mctrCd"
	, '' AS COL_17 --"vnoOtptPrntId"
	, '' AS COL_18 --"sndWhsCd"
	, '' AS COL_19 --"InvQty"
	, '' AS COL_20 -- "rtlSnstOtptYn"
	, '' AS COL_21 --"csVnoPrntId"
	, '' AS COL_22 --"ozrId"
	, '' AS COL_23 -- "ozrPgmId"
	, 'Y' AS COL_24 --"chkYn"
	, '' AS COL_25 --"csAlloVnoNo"
	, '' AS COL_26 -- "rtlRsrvDys"
	, '' AS COL_27 -- "slRsrvNo"
	, '' AS COL_28 -- "ponoIdx"
	, URCF.RTL_SL_DCD AS COL_29 --"rtlSlDcd"
	, URCF.SL_GRND_RSN AS COL_30 --"slGrndRsn"
	, '' AS COL_31 --"idx"
	, CASE WHEN URCF.RTL_SL_DCD = 'V' THEN 'VS' WHEN URCF.RTL_SL_DCD ='C' THEN '' END AS COL_32 --"winType"
	, '' AS COL_33 -- "lckAcptNo"
  FROM MBSASMDTBAKUPT.TBSUFURCF15 URCF,  MBSASMDTBAKUPT.TBSUFURCS15 URCS
  WHERE URCF.CS_ALLO_VNO_NO = URCS.CS_ALLO_VNO_NO AND URCS.ATCL_SNO = '001'
  ORDER BY URCF.SL_HRM )
  ORDER BY SEQ;
 
 
-- MainList
 INSERT	INTO	MBSASDEV.TB_PARAMETER (
 	APPL_ID,
	DATASET,
	COL_CNT,
	SEQ,
	COL_1,
	COL_2,
	COL_3,
	COL_4,
	COL_5,
	COL_6,
	COL_7,
	COL_8,
	COL_9,
	COL_10,
	COL_11,
	COL_12,
	COL_13,
	COL_14,
	COL_15,
	COL_16,
	COL_17,
	COL_18,
	COL_19,
	COL_20,
	COL_21,
	COL_22,
	COL_23,
	COL_24,
	COL_25,
	COL_26,
	COL_27,
	COL_28,
	COL_29,
	COL_30,
	COL_31,
	COL_32,
	COL_33,
	COL_34,
	COL_35,
	COL_36,
	COL_37,
	COL_38,
	COL_39)
 SELECT 
 	'UFW0020U' AS APPL_ID
	, 'dsMainList' AS DATASET
	, 39 AS COL_CNT
	, 0  AS SEQ
	, 'chkYn' AS COL_1
	, 'rnum' AS COL_2
	, 'rtlSlTcd' AS COL_3
	, 'alloBrnCd' AS COL_4
	, 'alloWhsCd' AS COL_5
	, 'smyVndCd' AS COL_6
	, 'smyVndNm' AS COL_7
	, 'saleYn' AS COL_8
	, 'ptno' AS COL_9
	, 'ptEngNm' AS COL_10
	, 'ptKorNm' AS COL_11
	, 'hkcDcd' AS COL_12
	, 'hkcDnm' AS COL_13
	, 'cmdlCd' AS COL_14
	, 'cmdlNm' AS COL_15
	, 'srcCd' AS COL_16
	, 'srcNm' AS COL_17
	, 'prcIndDcd' AS COL_18
	, 'prcIndDnm' AS COL_19
	, 'rtlBsPrc' AS COL_20
	, 'puntRqrdQty' AS COL_21
	, 'slUpc' AS COL_22
	, 'availQty' AS COL_23
	, 'availQty2' AS COL_24
	, 'mavUpc' AS COL_25
	, 'sndWhsCd' AS COL_26
	, 'emdRfctYn' AS COL_27
	, 'bsaGrpCd' AS COL_28
	, 'bsaGrpNm' AS COL_29
	, 'rtlDcrt' AS COL_30
	, 'mcCd' AS COL_31
	, 'mbsCmdlCd' AS COL_32
	, 'mbsCmdlNm' AS COL_33
	, 'rtlSalPrc' AS COL_34
	, 'grpClass' AS COL_35
	, 'smyVndPrcBsCd' AS COL_36
	, 'itmDcd' AS COL_37
	, 'ptAccDcd' AS COL_38
	, 'trn1DstbLocNo' AS COL_39
  FROM SYSIBM.dual;
  
 INSERT	INTO	MBSASDEV.TB_PARAMETER (
 	APPL_ID,
	DATASET,
	COL_CNT,
	SEQ,
	COL_1,
	COL_2,
	COL_3,
	COL_4,
	COL_5,
	COL_6,
	COL_7,
	COL_8,
	COL_9,
	COL_10,
	COL_11,
	COL_12,
	COL_13,
	COL_14,
	COL_15,
	COL_16,
	COL_17,
	COL_18,
	COL_19,
	COL_20,
	COL_21,
	COL_22,
	COL_23,
	COL_24,
	COL_25,
	COL_26,
	COL_27,
	COL_28,
	COL_29,
	COL_30,
	COL_31,
	COL_32,
	COL_33,
	COL_34,
	COL_35,
	COL_36,
	COL_37,
	COL_38,
	COL_39)
 SELECT  
 	'UFW0020U' AS APPL_ID
	, 'dsMainList' AS DATASET
	, 39 AS COL_CNT
	, PARA.SEQ AS SEQ
 	, 'Y' AS COL_1
 	, URCS.ATCL_SNO*1 AS COL_2
 	, '' AS COL_3
 	, URCS.ALLO_BRN_CD AS COL_4
 	, URCS.ALLO_WHS_CD AS COL_5
 	, '' AS COL_6
 	, '' AS COL_7
 	, '' AS COL_8
 	, URCS.ptno AS COL_9
 	, URCS.PT_ENG_NM AS COL_10
 	, '' AS COL_11
 	, URCS.HKC_DCD AS COL_12
 	, '' AS COL_13
 	, '' AS COL_14
 	, '' AS COL_15
 	, '' AS COL_16
 	, '' AS COL_17
 	, '' AS COL_18
 	, '' AS COL_19
 	, '' AS COL_20
 	, URCS.SL_QTY AS COL_21
 	, '' AS COL_22
 	, '' AS COL_23
 	, '' AS COL_24
 	, '' AS COL_25
 	, URCS.SND_WHS_CD AS COL_26
 	, URCS.EMD_RFCT_YN AS COL_27
 	, '' AS COL_28
 	, '' AS COL_29
 	, '' AS COL_30
 	, '' AS COL_31
 	, '' AS COL_32
 	, '' AS COL_33
 	, '' AS COL_34
 	, '' AS COL_35
 	, '' AS COL_36
 	, '' AS COL_37
 	, '' AS COL_38
 	, '' AS COL_39
   FROM MBSASMDTBAKUPT.TBSUFURCS15 URCS, MBSASDEV.TB_PARAMETER PARA
  WHERE PARA.APPL_ID = 'UFW0020U' 
    AND PARA.SEQ > 0 
    AND PARA.DATASET = 'dsSearch' 
    AND URCS.ALLO_BRN_CD = PARA.COL_2
    AND URCS.ALLO_YEAR = PARA.COL_5
    AND URCS.ALLO_MN = PARA.COL_6 
    AND URCS.ALLO_WHS_CD = PARA.COL_4
    AND URCS.ALLO_SNO = PARA.COL_7 
   ;