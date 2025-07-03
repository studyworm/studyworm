-- �������� ����ȭ(� -> ����) , �ؿܰ��⺻, �ؿܰ��߰���, AMEND�ڵ�, �ؿܰ���ǰAMEND�������ǳ���, �Ҵ�켱��������, CO-PACK����, CO-PACK�󼼱���, ����FACTOR����, REFERRAL����
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHAMDST ) of cursor REPLACE into MBSASSTD.TBSHAMDST nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHAMDSZ ) of cursor REPLACE into MBSASSTD.TBSHAMDSZ nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHAMAMD ) of cursor REPLACE into MBSASSTD.TBSHAMAMD nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHAMQDP ) of cursor REPLACE into MBSASSTD.TBSHAMQDP nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHAMPRT ) of cursor REPLACE into MBSASSTD.TBSHAMPRT nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHACPAC ) of cursor REPLACE into MBSASSTD.TBSHACPAC nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHACPDT ) of cursor REPLACE into MBSASSTD.TBSHACPDT nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHAOFAC ) of cursor REPLACE into MBSASSTD.TBSHAOFAC nonrecoverable');
call admin_cmd('load from (database proddb select * from MBSASSTD.TBSHAREFL ) of cursor REPLACE into MBSASSTD.TBSHAREFL nonrecoverable');

call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHAMDST ) of cursor REPLACE into MBSASSTD.TBSHAMDST nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSLAULOC ) of cursor REPLACE into MBSASSTD.TBSLAULOC nonrecoverable');

-- HEB0050U IFSHA0410, 5908�� 
/*** ���� ���� ��� ��ȸ ***/
SELECT
MORD.IF_SNO                                                   /* I/F �Ϸù�ȣ */
, MORD.RNO                                                      /* ���ڵ��ȣ */
, MORD.ZSHIPMD                                                  /* Ship Mode */
, MORD.ZORDNO                                                 /* Order Number */
, MORD.ZORDLN                                                 /* Line Item Number */
, MORD.ZMATNR                                                   /* Part Number */
, MORD.ZORDQTY                                                  /* Order Quantity */
, MORD.PRCS_RSLT_DIV_VAL                                        /* ó��������а� */
FROM MBSASIFT.IFSHA0410 MORD JOIN MBSASNON.IF_JOB_LOG JLOG
ON MORD.IF_SNO = JLOG.IF_SNO
WHERE JLOG.IF_ID ='HPI0410U'                                        /* I/F ID : ���� */
AND MORD.PRCS_RSLT_DIV_VAL ='R'                                   /* ó��������а� : C - Complete, E - Error, R - Ready (��ó��) */
AND JLOG.SNRV_DIV_VAL ='R'                                        /* �ۼ��ű��а� : S - Send, R - Receive, T - Transmission */
AND JLOG.SNRV_RSLT_DIV_VAL ='S'                                   /* �ۼ��Ű�����а� : S - Success, E - Error */
AND JLOG.PRCS_RSLT_DIV_VAL ='R'                                   /* ó��������а� : C - Complete, E - Error, R - Ready (��ó��) */
ORDER BY MORD.IF_SNO, MORD.ZORDNO, MORD.ZORDLN
;

/*** I/F ���̺� INSERT ***/
INSERT INTO MBSASIFT.IFSHA0410 (
IF_SNO
, RNO
, ZSHIPMD
, ZORDNO
, ZORDLN
, ZMATNR
, ZORDQTY
, FST_USR_ID
, FST_CRT_DTM
, LST_UPD_ID
, LST_UPD_DTM
, PRCS_RSLT_DIV_VAL
)
SELECT
'20231114010021285'                                                      /* IF_SNO : I/F �Ϸù�ȣ */
, ROW_NUMBER() OVER() RNUM                                                 /* RNO : ���ڵ��ȣ */
, MORP.SHE_CD                                                              /* ZSHIPMD : SHIPMODE */
, MORP.ORD_NO                                                              /* ZORDNO : ORDER ��ȣ */
, MORP.ORD_LN                                                              /* ZORDLN : ORDER LINE */
, MORP.ORD_PTNO                                                            /* ZMATNR : Line Item Number */
, MORP.ORD_QTY                                                             /* ZORDQTY : Order Quantity */
,'SYSTEM'                                                                 /* FST_USR_ID : ���ʵ���� */
, TO_DATE('20231114010021285','YYYYMMDDHH24MISSNNNNNN') /* FST_CRT_DTM : ���ʵ���Ͻ� */
, 'SYSTEM'                                                                 /* LST_UPD_ID : ���������� */
, TO_DATE('20231114010021285','YYYYMMDDHH24MISSNNNNNN') /* LST_UPD_DTM : ���������Ͻ� */
, 'R'                                                                      /* PRCS_RSLT_DIV_VAL : ó��������а� : C - Complete, E - Error, R - Ready (��ó��) */
FROM MBSASMDTDT0.TBSHEMORP MORP
WHERE ORD_NO IN (
    SELECT ORD_NO FROM (
        SELECT ORD_NO, ORD_DT FROM MBSASMDTDT0.TBSHEMORH
        MINUS
        SELECT ORD_NO, ORD_DT FROM MBSASMDTBAK.TBSHEMORH
    ) T1
    WHERE T1.ORD_DT ='20231114'
)
ORDER BY ORD_NO, ORD_LN, ORD_SFX
;


/*** I/F LOG ���̺� INSERT ***/
INSERT INTO MBSASNON.IF_JOB_LOG (
IF_SNO
, IF_ID
, IF_ID_OLD
, SND_STRT_DTM
, SND_END_DTM
, SNRV_DIV_VAL
, OBJ_CNT
, SCS_CNT
, FLR_CNT
, SNRV_RSLT_DIV_VAL
, PRCS_RSLT_DIV_VAL
, SNRV_RSL_MSG
, PRCS_RSLT_MSG
, FST_USR_ID
, FST_CRT_DTM
, LST_UPD_ID
, LST_UPD_DTM
, JOB_EXECUTION_ID
) 
VALUES (
'20231114010021285'                                                      /* IF_SNO : I/F �Ϸù�ȣ */
, 'HPI0410U'                                                               /* IF_ID : I/F ID */
, 'IF-SD-00000'                                                            /* IF_ID_OLD : OLD I/F ID */
, '20231114010000000'                                                      /* SND_STRT_DTM : ���۽����Ͻ� */
, '20231114010000000'                                                      /* SND_END_DTM : ���������Ͻ� */
, 'R'                                                                      /* SNRV_DIV_VAL : �ۼ��ű��а� : S - Send, R - Receive, T - Transmission */
, 11039                                                                    /* OBJ_CNT : ���Ǽ� */
, 11039                                                                    /* SCS_CNT : �����Ǽ� */
, 0                                                                        /* FLR_CNT : ���аǼ� */
, 'S'                                                                      /* SNRV_RSLT_DIV_VAL : �ۼ��Ű�����а� : S - Success, E - Error */
, 'R'                                                                      /* PRCS_RSLT_DIV_VAL : ó��������а� : C - Complete, E - Error, R - Ready (��ó��) */
, 'Success'                                                                /* SNRV_RSL_MSG : �ۼ��Ű���޽��� */
, ''                                                                       /* PRCS_RSLT_MSG : ó������޽��� */
, 'SYSTEM'                                                                 /* FST_USR_ID : ���ʵ���� */
, TO_DATE('20231114010021285','YYYYMMDDHH24MISSNNNNNN') /* FST_CRT_DTM : ���ʵ���Ͻ� */
, 'SYSTEM'                                                                 /* LST_UPD_ID : ���������� */
, TO_DATE('20231114010021285','YYYYMMDDHH24MISSNNNNNN') /* LST_UPD_DTM : ���������Ͻ� */
, 0                                                                        /* JOB_EXECUTION_ID : Batch Job ID (FK : BATCH_JOB_EXECUTION) */
);

-- I/F�ʱ�ȭ
UPDATE MBSASIFT.IFSHA0410 SET PRCS_RSLT_DIV_VAL = 'R' WHERE IF_SNO = '20231114010021285';
UPDATE MBSASNON.IF_JOB_LOG SET PRCS_RSLT_DIV_VAL = 'R' WHERE IF_SNO = '20231114010021285';

call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMORH ) of cursor REPLACE into MBSASSTD.TBSHEMORH nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMORP ) of cursor REPLACE into MBSASSTD.TBSHEMORP nonrecoverable');



-- HEB0110U ���� : TBSIPMVPM
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMORH ) of cursor REPLACE into MBSASSTD.TBSHEMORH nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMORP ) of cursor REPLACE into MBSASSTD.TBSHEMORP nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSTAMEPM ) of cursor REPLACE into MBSASSTD.TBSTAMEPM nonrecoverable');

-- HEB0010I ����
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEOFLE ) of cursor REPLACE into MBSASSTD.TBSHEOFLE nonrecoverable');

-- HEB0200U ����

-- HEB0230U - ���� �߻� �� �ѹ�
TRUNCATE MBSASSTD.TBSHEABON;
call admin_cmd('load from ( select * from MBSASMDTBAKHPT.TBSHEMORH_03_20231213 ) of cursor REPLACE into MBSASSTD.TBSHEMORH nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAKHPT.TBSHEMORP_04_20231213 ) of cursor REPLACE into MBSASSTD.TBSHEMORP nonrecoverable');

call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMALD ) of cursor REPLACE into MBSASSTD.TBSHEMALD nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMALS ) of cursor REPLACE into MBSASSTD.TBSHEMALS nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSTAMEPM ) of cursor REPLACE into MBSASSTD.TBSTAMEPM nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSIAMEIM ) of cursor REPLACE into MBSASSTD.TBSIAMEIM nonrecoverable');

-- HEB0270U

-- HEB0280U
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMPIC ) of cursor REPLACE into MBSASSTD.TBSHEMPIC nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSLAUNBR ) of cursor REPLACE into MBSASSTD.TBSLAUNBR nonrecoverable');

SELECT * FROM MBSASSTD.TBSLAUNBR;
-- TBSHEMPIC �������� TBSLAUNBR �� INSERT, UPDATE �Ϸ� �Ͽ����ϴ�
INSERT INTO MBSASSTD.TBSLAUNBR (
  KEY_FIELD_NM
, KEY_VAL
, KEY_SQN
, FST_USR_ID
, FST_SYS_DCD
, FST_CRT_DTM
, LST_UPD_ID
, LST_SYS_DCD
, LST_UPD_DTM
)
SELECT
  'MPIC_PICK_NO' AS KEY_FIELD_NM
, CTR_CD || PIC_BIZ_DCD || '31114' AS KEY_VAL
, MAX(RIGHT(PIC_NO, 5)) AS KEY_SQN
, 'SYSTEM'
, 'S'
, CURRENT_TIMESTAMP
, 'SYSTEM'
, 'S'
, CURRENT_TIMESTAMP
FROM MBSASSTD.TBSHEMPIC
WHERE INST_DT = '20231114'
AND PIC_BIZ_DCD = 'P'
AND CTR_CD <> 'EZA'
GROUP BY CTR_CD, PIC_BIZ_DCD
;
 
UPDATE MBSASSTD.TBSLAUNBR SET
  KEY_SQN = 10553
, LST_UPD_ID = 'SYSTEM'
, LST_SYS_DCD = 'S'
, LST_UPD_DTM = CURRENT_TIMESTAMP
WHERE KEY_FIELD_NM = 'MPIC_PICK_NO'
AND KEY_VAL = 'EZAP31114'
;
 
SELECT * FROM MBSASSTD.TBSLAUNBR
WHERE KEY_FIELD_NM = 'MPIC_PICK_NO'
;
 
-- HEB0290U
call admin_cmd('load from ( select * from MBSASMDTBAKHPT.TBSHEMORP_05_20231213 ) of cursor REPLACE into MBSASSTD.TBSHEMORP nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSLOMPAC ) of cursor REPLACE into MBSASSTD.TBSLOMPAC nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHGMDHI ) of cursor REPLACE into MBSASSTD.TBSHGMDHI nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSLOMCAS ) of cursor REPLACE into MBSASSTD.TBSLOMCAS nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHGMINH ) of cursor REPLACE into MBSASSTD.TBSHGMINH nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHGMINO ) of cursor REPLACE into MBSASSTD.TBSHGMINO nonrecoverable');
DELETE FROM MBSASSTD.TBSHGMATD WHERE FST_CRT_DTM > '2023-12-14';
--DELETE FROM MBSASSTD.TBSLOMPAC WHERE ORD_NO NOT IN (SELECT ORD_NO FROM MBSASSTD.TBSHEMORP);

INSERT INTO MBSASSTD.TBSLOMPAC 
(PAC_NO, CTR_CD, WHS_CD, PAC_BIZ_DCD, PAC_YEAR, PAC_MN, PAC_DY, PAC_SQN, MCTR_CD, BOX_NO, PIC_NO, TRSF_CTR_CD, TRSF_WHS_CD, TRSF_MCTR_CD, PAC_LN_CD, PACD_LN_CD, PICMD_CD, ORD_NO, ORD_LN, ORD_SFX, ORD_PTNO, CONF_PTNO, PAC_PTNO, HKC_DCD, PIC_QTY, PAC_QTY, CNL_OSD_DCD, PAC_CNL_TCD, CNL_QTY, LG_CTL_CD, OSD_QTY, MAV_UPC, MVC_DIFF_AMT, CUR_CD, EXP_CPRC, EXP_UPRC, WGT, CBM, PIC_DT, PIC_TM, PIC_PER_ID, SRD_DT, PAC_DT, PAC_TM, PAC_PER_ID, PAC_CNL_DT, PAC_CNL_TM, PAC_CNL_PER_ID, CASED_DT, CASED_TM, CASED_PER_ID, CTNR_LNK_DT, CTNR_LNK_TM, CTNR_LNK_WKR_ID, STUF_NO, CTNR_NO, CTNR_CTR_CD, CTNR_BS_DT, STUF_DT, STUF_TM, STUF_PER_ID, INV_NO, INV_DT, INV_TM, INV_PER_ID, SHP_DT, SHP_TM, SHP_PER_ID, TRSF_YN, TRSFI_NO, TRSF_DT, TRSF_TM, TRSF_HDLR_ID, CMY_CD, DST_CD, DST_LCCD, DST_MCCD, DST_SCCD, ORD_TCD, SHE_CD, SPY_CD, LG_SPY_CD, CTL_CD, INV_PRCS_SCD, CPACK_CD, SRC_CD, PT_ACC_DCD, CHA_CD, EXP_FROC_DCD, NTN_CD, RGNL_YN, DROPSHIP_YN, DROPSHIP_RFNO, ITM_RSLT_DCD, CDK_YN, CDK_RFNO, BATT_SER_YN, BATT_SER_NO, SER_YN, ZONGR_CD, ADJ_OTAG, SND_PROC_SCD, FST_USR_ID, FST_SYS_DCD, FST_CRT_DTM, LST_UPD_ID, LST_SYS_DCD, LST_UPD_DTM) 
(SELECT PAC_NO, CTR_CD, WHS_CD, PAC_BIZ_DCD, PAC_YEAR, PAC_MN, PAC_DY, PAC_SQN, MCTR_CD, BOX_NO, PIC_NO, TRSF_CTR_CD, TRSF_WHS_CD, TRSF_MCTR_CD, PAC_LN_CD, PACD_LN_CD, PICMD_CD, ORD_NO, ORD_LN, ORD_SFX, ORD_PTNO, CONF_PTNO, PAC_PTNO, HKC_DCD, PIC_QTY, PAC_QTY, CNL_OSD_DCD, PAC_CNL_TCD, CNL_QTY, LG_CTL_CD, OSD_QTY, MAV_UPC, MVC_DIFF_AMT, CUR_CD, EXP_CPRC, EXP_UPRC, WGT, CBM, PIC_DT, PIC_TM, PIC_PER_ID, SRD_DT, PAC_DT, PAC_TM, PAC_PER_ID, PAC_CNL_DT, PAC_CNL_TM, PAC_CNL_PER_ID, CASED_DT, CASED_TM, CASED_PER_ID, CTNR_LNK_DT, CTNR_LNK_TM, CTNR_LNK_WKR_ID, STUF_NO, CTNR_NO, CTNR_CTR_CD, CTNR_BS_DT, STUF_DT, STUF_TM, STUF_PER_ID, INV_NO, INV_DT, INV_TM, INV_PER_ID, SHP_DT, SHP_TM, SHP_PER_ID, TRSF_YN, TRSFI_NO, TRSF_DT, TRSF_TM, TRSF_HDLR_ID, CMY_CD, DST_CD, DST_LCCD, DST_MCCD, DST_SCCD, ORD_TCD, SHE_CD, SPY_CD, LG_SPY_CD, CTL_CD, INV_PRCS_SCD, CPACK_CD, SRC_CD, PT_ACC_DCD, CHA_CD, EXP_FROC_DCD, NTN_CD, RGNL_YN, DROPSHIP_YN, DROPSHIP_RFNO, ITM_RSLT_DCD, CDK_YN, CDK_RFNO, BATT_SER_YN, BATT_SER_NO, SER_YN, ZONGR_CD, ADJ_OTAG, SND_PROC_SCD, FST_USR_ID, FST_SYS_DCD, FST_CRT_DTM, LST_UPD_ID, LST_SYS_DCD, LST_UPD_DTM FROM MBSASMDTBAK.TBSLOMPAC WHERE ORD_NO IN (SELECT ORD_NO FROM MBSASSTD.TBSHEMORP));

SELECT count(*) FROM MBSASMDTBAK.TBSLOMPAC WHERE ORD_NO IN (SELECT ORD_NO FROM MBSASSTD.TBSHEMORP);
-- HEB0300U



-- HEB0090U ����, TBSHEMORP �� ���� �ʿ�. �׷��� 110���� ���ư��� ��.  TBSMPMAUO: �����ǸŰ�å����û�װ������
DELETE FROM MBSASSTD.TBSMPMAUO WHERE FST_CRT_DTM >= '2023-11-15';

-- HEB0100U

-- HEB0170U ����
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEOLOG ) of cursor REPLACE into MBSASSTD.TBSHEOLOG nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHAMDST ) of cursor REPLACE into MBSASSTD.TBSHAMDST nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMALD ) of cursor REPLACE into MBSASSTD.TBSHEMALD nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSHEMALS ) of cursor REPLACE into MBSASSTD.TBSHEMALS nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSIAUEIV ) of cursor REPLACE into MBSASSTD.TBSIAUEIV nonrecoverable');
call admin_cmd('load from ( select * from MBSASMDTBAK.TBSIAUBIV ) of cursor REPLACE into MBSASSTD.TBSIAUBIV nonrecoverable');

-- HEB0180U

-- HEB0470U

-- HEB0560U IFSHA0390
call admin_cmd('load from (database proddb select * from MBSASIFT.IFSHA0390 ) of cursor REPLACE into MBSASIFT.IFSHA0390 nonrecoverable');

-- HEB0580U IFSHA0300
call admin_cmd('load from (database proddb select * from MBSASIFT.IFSHA0300 ) of cursor REPLACE into MBSASIFT.IFSHA0300 nonrecoverable');