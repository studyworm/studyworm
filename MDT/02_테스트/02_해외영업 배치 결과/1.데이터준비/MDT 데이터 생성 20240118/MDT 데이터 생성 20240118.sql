
-- DB �ݿ� �ڷ� 1�� S ---  S
--- 1�� BIV(�����)�� MLOC �ִµ�  LOC ���̺� LOC���� �� ó��
MERGE INTO	MBSASSTD.TBSLAULOC  ULOC
USING	(
		SELECT  SBIV.*
		FROM	(
				SELECT  UBIV.MLOC_NO
					,	UBIV.BRN_CD 	AS	MCTR_CD
					,	UBIV.BRN_CD
					,	UBIV.WHS_CD 
					,	UBIV.PTNO 
					,	IFNULL(IFNULL(UDPM.HKC_DCD, MBSASSTD.FN_IPFHKCDCD(UBIV.BRN_CD)) , '') AS HKC_DCD
					,   (
						UBIV.STK_CTL_QTY   -- ��� ���� ����
						+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
						+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
						+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
						+ UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	LOC_STK_QTY   /* �����̼�������*/
					,   (
						UBIV.STK_CTL_QTY   -- ��� ���� ����
						+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
						+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
						+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
						)						AS	AVS_QTY       /* ����������*/
					,	(
						 UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	WSND_QTY		/* ��������*/	
					,	ROW_NUMBER() OVER(PARTITION BY 	UBIV.MLOC_NO ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
				FROM	MBSASSTD.TBSIAUBIV	UBIV
				JOIN	MBSASSTD.TBSIAUBMT	UBMT
				ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
				LEFT
				JOIN    MBSASSTD.TBSTAUDPM	UDPM
				ON      UDPM.PTNO 			=	UBIV.PTNO 
				WHERE 	1 = 1
				AND     UBMT.BRN_FUNC_DCD != 'M'
				AND     (
						UBIV.STK_CTL_QTY   -- ��� ���� ����
						+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
						+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
						+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
						+ UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)	> 0
				AND		LENGTH(TRIM(UBIV.MLOC_NO )) > 0
				AND     NOT EXISTS	(
									SELECT	ULOC.LOC_NO 
									FROM 	MBSASSTD.TBSLAULOC  ULOC
									WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD
									AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
									AND     ULOC.LOC_NO     =	UBIV.MLOC_NO
									--AND     ULOC.PTNO     	=	UBIV.PTNO
									)
				
				)	SBIV
		WHERE 	SBIV.S_SEQ = 1
		)	DBIV
ON		(
				ULOC.MCTR_CD	= DBIV.BRN_CD 
		AND     ULOC.WHS_CD 	= DBIV.WHS_CD 
		AND     ULOC.LOC_NO 	= DBIV.MLOC_NO 
		)
WHEN NOT MATCHED THEN 
        INSERT  
        (
              MCTR_CD       /* ���հ����ڵ�*/
            , WHS_CD        /* â���ڵ�*/
            , LOC_NO        /* �����̼ǹ�ȣ*/
            , PTNO          /* ��ǰ��ȣ*/
            , HKC_DCD       /* �����Ʊ����ڵ�*/
            , LOC_STK_QTY   /* �����̼�������*/
            , AVS_QTY       /* ����������*/
            , WSND_QTY      /* ��������*/
            , PRI_CD        /* PR�����ڵ�*/
            , ZON_CD        /* ZONE�ڵ�*/
            , AIS           /* AISLE*/
            , SCN           /* SECTION*/
            , LVL           /* LEVEL*/
            , POS           /* POSITION*/
            , LOC_SNO       /* �����̼��Ϸù�ȣ*/
            , BATT_SER_YN   /* ���͸��ø��󿩺�*/
            , BATT_SER_NO   /* ���͸��ø����ȣ*/
            , VIR_YN        /* ���󿩺�*/
            , LOC_USE_DCD   /* �����̼ǻ�뱸���ڵ�*/
            , FST_STR_DT    /* ������������*/
            , FST_STR_TM    /* ��������ð�*/
            , LST_STR_DT    /* ������������*/
            , LST_STR_TM    /* ��������ð�*/
            , LST_SND_DT    /* �����������*/
            , LST_SND_TM    /* �������ð�*/
            , MEMO          /* �޸�*/
            , FST_USR_ID    /* ���ʻ����ID*/
            , FST_SYS_DCD   /* ���ʽý��۱����ڵ�*/
            , FST_CRT_DTM   /* ���ʻ����Ͻ�*/
            , LST_UPD_ID    /* ����������ID*/
            , LST_SYS_DCD   /* �����ý��۱����ڵ�*/
            , LST_UPD_DTM   /* ���������Ͻ�*/
        )
        VALUES
        (
              DBIV.MCTR_CD                     /* ���հ����ڵ�*/
            , DBIV.WHS_CD                          /* â���ڵ�*/
            , DBIV.MLOC_NO                  /* �����̼ǹ�ȣ*/
            , DBIV.PTNO                                                               /* ��ǰ��ȣ*/
            , DBIV.HKC_DCD                                                                /* �����Ʊ����ڵ�*/
            , DBIV.LOC_STK_QTY                                                  /* �����̼�������*/
            , (CASE WHEN DBIV.AVS_QTY < 0 THEN 0 ELSE DBIV.AVS_QTY END)                                                /* ����������*/
            , DBIV.WSND_QTY                                                     /* ��������*/
            , 'P'                                                               /* PR�����ڵ�*/
            , SUBSTRING(DBIV.MLOC_NO,1,3)   /* ZONE�ڵ�*/
            , SUBSTRING(DBIV.MLOC_NO,4,2)   /* AISLE*/
            , SUBSTRING(DBIV.MLOC_NO,6,2)   /* SECTION*/
            , SUBSTRING(DBIV.MLOC_NO,8,2)   /* LEVEL*/
            , SUBSTRING(DBIV.MLOC_NO,10,1)  /* POSITION*/
            , DBIV.MLOC_NO                  /* �����̼��Ϸù�ȣ*/
            , ''                                                                /* ���͸��ø��󿩺�*/
            , ''                                                                /* ���͸��ø����ȣ*/
            , ''                                                                /* ���󿩺�*/
            , ''                                                                /* �����̼ǻ�뱸���ڵ�*/
            , ''                                                                /* ������������*/
            , ''                                                                /* ��������ð�*/
            , ''                                                                /* ������������*/
            , ''                                                                /* ��������ð�*/
            , ''                                                                /* �����������*/
            , ''                                                                /* �������ð�*/
            , '1�� �۾�'                                                                /* �޸�*/
            , 'DT088474M'                         /* ���ʻ����ID*/
            , 'P'                         /* ���ʽý��۱����ڵ�*/
            , CURRENT_TIMESTAMP                                                 /* ���ʻ����Ͻ�*/
            , 'DT088474M'                         /* ����������ID*/
            , 'P'                       /* �����ý��۱����ڵ�*/
            , CURRENT_TIMESTAMP                                                 /* ���������Ͻ�*/
        )
; 


-- DB �ݿ� �ڷ� 2�� S --- 
-- BIV(�����) ��� ������ �ι� ��������  LOCATION�� ���� �ι� �̶�� INSERT ���⼭ ���� LOCATION�� ���� �ι��̶�� �����Ͽ� �ű� LOC�� ä�� ���

			INSERT 
			INTO MBSASSTD.TBSLAULOC  (
				  	MCTR_CD
				  ,	WHS_CD
				  ,	LOC_NO
				  ,	PTNO
				  ,	HKC_DCD
				  ,	LOC_STK_QTY
				  ,	AVS_QTY
				  ,	WSND_QTY
				  ,	PRI_CD
				  ,	ZON_CD
				  ,	AIS 
				  ,	SCN
				  ,	LVL
				  ,	POS 
				  ,	LOC_SNO 
				  ,	BATT_SER_YN
				  ,	BATT_SER_NO
				  ,	VIR_YN
				  ,	LOC_USE_DCD
				  ,	FST_STR_DT
				  ,	FST_STR_TM
				  ,	LST_STR_DT
				  ,	LST_STR_TM
				  ,	LST_SND_DT
				  ,	LST_SND_TM
				  ,	MEMO
				  ,	FST_USR_ID
				  ,	FST_SYS_DCD
				  ,	FST_CRT_DTM
				  ,	LST_UPD_ID
				  ,	LST_SYS_DCD
				  ,	LST_UPD_DTM
			 )
			 
 WITH AISLE_ARR(AISLE_NUM, AISLE_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS AISLE_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS AISLE_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT AISLE_NUM + 1, LPAD(AISLE_NUM + 1,2,0)
                  FROM AISLE_ARR
                 WHERE AISLE_NUM < TO_NUMBER('99')
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('20')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS LEVEL_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS LEVEL_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT LEVEL_NUM + 1, LPAD(LEVEL_NUM + 1,2,0)
                  FROM LEVEL_ARR
                 WHERE LEVEL_NUM < TO_NUMBER('25')
            )
            , POSITION_ARR(POSITION_NUM, POSITION_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT ASCII('A') AS POSITION_NUM, 'A' AS POSITION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT POSITION_NUM + 1, CHR(POSITION_NUM+1)
                  FROM POSITION_ARR
                 WHERE POSITION_NUM < ASCII('Z')
            )
            , MCTR_WHS_LIST AS (
            	            		 
            		SELECT  DISTINCT 
            				IBIV.MCTR_CD
            			, 	IBIV.WHS_CD
            		 	, 	IBIV.ZON_CD 
					FROM	(
							SELECT  UBIV.BRN_CD	AS	MCTR_CD
								,	UBIV.WHS_CD 
								,   SUBSTRING(TRIM(UBIV.MLOC_NO ), 1, 3) AS ZON_CD
							FROM	MBSASSTD.TBSIAUBIV	UBIV
							JOIN	MBSASSTD.TBSIAUBMT	UBMT
							ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
							LEFT
							JOIN    MBSASSTD.TBSTAUDPM	UDPM
							ON      UDPM.PTNO 			=	UBIV.PTNO 
							WHERE 	1 = 1
							AND     UBMT.BRN_FUNC_DCD != 'M'
							AND     (
									UBIV.STK_CTL_QTY   -- ��� ���� ����
									+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
									+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
									+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
									+ UBIV.WS_NSND_QTY
									+ UBIV.WFLD_BDPC_DO_QTY
									+ UBIV.BFLD_BDPC_DO_QTY
									)	> 0
							AND		LENGTH(TRIM(UBIV.MLOC_NO )) > 0
							AND     NOT EXISTS	(
												SELECT	ULOC.LOC_NO 
												FROM 	MBSASSTD.TBSLAULOC  ULOC
												WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD
												AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
												--AND     ULOC.LOC_NO     =	UBIV.MLOC_NO
												AND     ULOC.PTNO     	=	UBIV.PTNO
												)
						
							)	IBIV
		
            )
           
            SELECT	NLDT.MCTR_CD
		       	, 	NLDT.WHS_CD
            	,	NLDT.LOC_NO
            	,	SBIV.PTNO 
            	,	SBIV.HKC_DCD
            	, 	SBIV.LOC_STK_QTY   /* �����̼�������*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY    /* ����������*/
            	, 	SBIV.WSND_QTY      /* ��������*/
            	,	'P'	AS PRI_CD        /* PR�����ڵ�*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* ���͸��ø��󿩺�*/
	            , '' AS BATT_SER_NO   /* ���͸��ø����ȣ*/
	            , '' AS VIR_YN        /* ���󿩺�*/
	            , '' AS LOC_USE_DCD   /* �����̼ǻ�뱸���ڵ�*/
	            , '' AS FST_STR_DT    /* ������������*/
	            , '' AS FST_STR_TM    /* ��������ð�*/
	            , '' AS LST_STR_DT    /* ������������*/
	            , '' AS LST_STR_TM    /* ��������ð�*/
	            , '' AS LST_SND_DT    /* �����������*/
	            , '' AS LST_SND_TM    /* �������ð�*/
	            , '2�� �۾�' AS MEMO          /* �޸�*/
	            , 'DT088474M' AS FST_USR_ID    /* ���ʻ����ID*/
	            , 'P'   AS FST_SYS_DCD   /* ���ʽý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* ���ʻ����Ͻ�*/
	            , 'DT088474M' AS LST_UPD_ID    /* ����������ID*/
	            , 'P' AS LST_SYS_DCD   /* �����ý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* ���������Ͻ�*/
              	--,	NLDT.S_SEQ
           FROM	(
		            SELECT MWLT.MCTR_CD
		                 , MWLT.WHS_CD
		            	 , MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR AS LOC_NO
		                 , MWLT.ZON_CD AS ZON_CD
		                 , AA.AISLE_CHAR AS AIS
		                 , SA.SECTION_CHAR AS SCN
		                 , LA.LEVEL_CHAR AS LVL
		                 , PA.POSITION_CHAR AS POS
		               
		                 ,	ROW_NUMBER() OVER(PARTITION BY 	MWLT.MCTR_CD ,	MWLT.WHS_CD,	MWLT.ZON_CD ORDER BY AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR )	AS S_SEQ
		              FROM AISLE_ARR AA
		              INNER JOIN SECTION_ARR SA ON 1=1
		              INNER JOIN LEVEL_ARR LA ON 1=1
		              INNER JOIN POSITION_ARR PA ON 1=1
		              INNER JOIN MCTR_WHS_LIST AS MWLT ON 1=1

		              WHERE 1=1 --ULOC.LOC_NO IS NULL
		                            
		              AND     NOT EXISTS	(
											SELECT	ULOC.LOC_NO 
											FROM 	MBSASSTD.TBSLAULOC  ULOC
											WHERE 	1 = 1
											AND		ULOC.MCTR_CD	= MWLT.MCTR_CD
						                    AND 	ULOC.WHS_CD 	= MWLT.WHS_CD
						                    AND 	ULOC.LOC_NO 	=  MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR
											)  

					)	NLDT
				JOIN 
					(
					SELECT  UBIV.MLOC_NO
						,	UBIV.BRN_CD AS	MCTR_CD
						,	UBIV.BRN_CD
						,	UBIV.WHS_CD 
						,	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) AS	ZON_CD 
						,	UBIV.PTNO 
						,	IFNULL(IFNULL(UDPM.HKC_DCD, MBSASSTD.FN_IPFHKCDCD(UBIV.BRN_CD)) , '') AS HKC_DCD
						,   (
							UBIV.STK_CTL_QTY   -- ��� ���� ����
							+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
							+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
							+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
							+ UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	LOC_STK_QTY   /* �����̼�������*/
						,   (
							UBIV.STK_CTL_QTY   -- ��� ���� ����
							+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
							+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
							+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
							)						AS	AVS_QTY       /* ����������*/
						,	(
							 UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	WSND_QTY		/* ��������*/
						,	ROW_NUMBER() OVER(PARTITION BY 	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
					FROM	MBSASSTD.TBSIAUBIV	UBIV
					JOIN	MBSASSTD.TBSIAUBMT	UBMT
					ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
					LEFT
					JOIN    MBSASSTD.TBSTAUDPM	UDPM
					ON      UDPM.PTNO 			=	UBIV.PTNO 
					WHERE 	1 = 1
					AND     UBMT.BRN_FUNC_DCD != 'M'
					AND     (
							UBIV.STK_CTL_QTY   -- ��� ���� ����
							+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
							+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
							+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
							+ UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)	> 0
					AND		LENGTH(TRIM(UBIV.MLOC_NO )) > 0
					-- AND     UBIV.MLOC_NO = '11Z010101H'
					AND     NOT EXISTS	(
										SELECT	ULOC.LOC_NO 
										FROM 	MBSASSTD.TBSLAULOC  ULOC
										WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD
										AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
										--AND     ULOC.LOC_NO     =	UBIV.MLOC_NO
										AND     ULOC.PTNO     	=	UBIV.PTNO
										)
					
					)	SBIV
				ON	SBIV.MCTR_CD = NLDT.MCTR_CD
	            AND SBIV.WHS_CD =  NLDT.WHS_CD
	            AND SBIV.ZON_CD = NLDT.ZON_CD
				AND SBIV.S_SEQ = NLDT.S_SEQ
				ORDER 
					BY NLDT.MCTR_CD
			       	, 	NLDT.WHS_CD
	            	,	NLDT.LOC_NO
	            	,	SBIV.PTNO 
	;

-- DB �ݿ� �ڷ� 2-1�� S --- 2236(01.18) 
--- 2������ �۾��� ���� ä�� �� LOC �� ���� ��� ���̺� �ش� ��ǰ ��ȣ�� MLOC���� UPDATE �Ѵ�. 

MERGE	
INTO	MBSASSTD.TBSIAUBIV	UBIV 
USING	(
		SELECT	ULOC.MCTR_CD
			,  	ULOC.WHS_CD 
			,   ULOC.LOC_NO 
			,   ULOC.PTNO 
		FROM 	MBSASSTD.TBSLAULOC  ULOC 
		WHERE   1 = 1
		AND 	ULOC.MCTR_CD IN 	(
									   		SELECT  DISTINCT 
						            				IBIV.MCTR_CD
											FROM	(
													SELECT  UBIV.BRN_CD	AS	MCTR_CD
													FROM	MBSASSTD.TBSIAUBIV	UBIV
													JOIN	MBSASSTD.TBSIAUBMT	UBMT
													ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
													WHERE 	1 = 1
													AND     UBMT.BRN_FUNC_DCD != 'M'
													)	IBIV
									) 
		AND     ULOC.MEMO 		= '2�� �۾�'
		) DT
ON		(
				UBIV.BRN_CD 	= DT.MCTR_CD 
		AND     UBIV.WHS_CD 	= DT.WHS_CD 
		AND     UBIV.PTNO 		= DT.PTNO 
		)
WHEN  MATCHED THEN 
        UPDATE 
        SET		UBIV.MLOC_NO 	=	DT.LOC_NO
;
 
-- DB �ݿ� �ڷ� 3�� S ---  500125 (01.18) 
--- 3�� EIV(��ǰ��)�� MLOC �ִµ�  LOC ���̺� LOC���� �� ó��


MERGE INTO	MBSASSTD.TBSLAULOC  ULOC
USING	(
		SELECT  SBIV.*
		FROM	(
				SELECT  UBIV.MLOC_NO
					,	UBIV.BRN_CD	AS	MCTR_CD
					,	UBIV.BRN_CD
					,	UBIV.WHS_CD 
					,	UBIV.PTNO 
					,	IFNULL(IFNULL(UDPM.HKC_DCD, MBSASSTD.FN_IPFHKCDCD(UBIV.BRN_CD)) , '') AS HKC_DCD
					,   (
						UBIV.STK_CTL_QTY   -- ��� ���� ����
						+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
						+ UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	LOC_STK_QTY   /* �����̼�������*/
					,   (
						UBIV.STK_CTL_QTY   -- ��� ���� ����
						+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
						)						AS	AVS_QTY       /* ����������*/
					,	(
						 UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	WSND_QTY		/* ��������*/	
					,	ROW_NUMBER() OVER(PARTITION BY 	UBIV.MLOC_NO ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
				FROM	MBSASSTD.TBSIAUEIV	UBIV
				LEFT
				JOIN    MBSASSTD.TBSTAUDPM	UDPM
				ON      UDPM.PTNO 			=	UBIV.PTNO 
				WHERE 	1 = 1
				AND     (
						UBIV.STK_CTL_QTY   -- ��� ���� ����
						+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
						+ UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)	> 0
				AND		LENGTH(TRIM(UBIV.MLOC_NO )) > 0
				AND     NOT EXISTS	(
									SELECT	ULOC.LOC_NO 
									FROM 	MBSASSTD.TBSLAULOC  ULOC
									WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD 
									AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
									AND     ULOC.LOC_NO     =	UBIV.MLOC_NO
									)
				
				)	SBIV
		WHERE 	SBIV.S_SEQ = 1
		)	DBIV
ON		(
				ULOC.MCTR_CD	= DBIV.BRN_CD 
		AND     ULOC.WHS_CD 	= DBIV.WHS_CD 
		AND     ULOC.LOC_NO 	= DBIV.MLOC_NO 
		)
WHEN NOT MATCHED THEN 
        INSERT  
        (
              MCTR_CD       /* ���հ����ڵ�*/
            , WHS_CD        /* â���ڵ�*/
            , LOC_NO        /* �����̼ǹ�ȣ*/
            , PTNO          /* ��ǰ��ȣ*/
            , HKC_DCD       /* �����Ʊ����ڵ�*/
            , LOC_STK_QTY   /* �����̼�������*/
            , AVS_QTY       /* ����������*/
            , WSND_QTY      /* ��������*/
            , PRI_CD        /* PR�����ڵ�*/
            , ZON_CD        /* ZONE�ڵ�*/
            , AIS           /* AISLE*/
            , SCN           /* SECTION*/
            , LVL           /* LEVEL*/
            , POS           /* POSITION*/
            , LOC_SNO       /* �����̼��Ϸù�ȣ*/
            , BATT_SER_YN   /* ���͸��ø��󿩺�*/
            , BATT_SER_NO   /* ���͸��ø����ȣ*/
            , VIR_YN        /* ���󿩺�*/
            , LOC_USE_DCD   /* �����̼ǻ�뱸���ڵ�*/
            , FST_STR_DT    /* ������������*/
            , FST_STR_TM    /* ��������ð�*/
            , LST_STR_DT    /* ������������*/
            , LST_STR_TM    /* ��������ð�*/
            , LST_SND_DT    /* �����������*/
            , LST_SND_TM    /* �������ð�*/
            , MEMO          /* �޸�*/
            , FST_USR_ID    /* ���ʻ����ID*/
            , FST_SYS_DCD   /* ���ʽý��۱����ڵ�*/
            , FST_CRT_DTM   /* ���ʻ����Ͻ�*/
            , LST_UPD_ID    /* ����������ID*/
            , LST_SYS_DCD   /* �����ý��۱����ڵ�*/
            , LST_UPD_DTM   /* ���������Ͻ�*/
        )
        VALUES
        (
              DBIV.MCTR_CD                     /* ���հ����ڵ�*/
            , DBIV.WHS_CD                          /* â���ڵ�*/
            , DBIV.MLOC_NO                  /* �����̼ǹ�ȣ*/
            , DBIV.PTNO                                                               /* ��ǰ��ȣ*/
            , DBIV.HKC_DCD                                                                /* �����Ʊ����ڵ�*/
            , DBIV.LOC_STK_QTY                                                  /* �����̼�������*/
            , CASE WHEN DBIV.AVS_QTY < 0 THEN 0 ELSE DBIV.AVS_QTY END                                                     /* ����������*/
            , DBIV.WSND_QTY                                                     /* ��������*/
            , 'P'                                                               /* PR�����ڵ�*/
            , SUBSTRING(DBIV.MLOC_NO,1,3)   /* ZONE�ڵ�*/
            , SUBSTRING(DBIV.MLOC_NO,4,2)   /* AISLE*/
            , SUBSTRING(DBIV.MLOC_NO,6,2)   /* SECTION*/
            , SUBSTRING(DBIV.MLOC_NO,8,2)   /* LEVEL*/
            , SUBSTRING(DBIV.MLOC_NO,10,1)  /* POSITION*/
            , DBIV.MLOC_NO                  /* �����̼��Ϸù�ȣ*/
            , ''                                                                /* ���͸��ø��󿩺�*/
            , ''                                                                /* ���͸��ø����ȣ*/
            , ''                                                                /* ���󿩺�*/
            , ''                                                                /* �����̼ǻ�뱸���ڵ�*/
            , ''                                                                /* ������������*/
            , ''                                                                /* ��������ð�*/
            , ''                                                                /* ������������*/
            , ''                                                                /* ��������ð�*/
            , ''                                                                /* �����������*/
            , ''                                                                /* �������ð�*/
            , '3�� �۾�'                                                                /* �޸�*/
            , 'DT088474M'                         /* ���ʻ����ID*/
            , 'P'                         /* ���ʽý��۱����ڵ�*/
            , CURRENT_TIMESTAMP                                                 /* ���ʻ����Ͻ�*/
            , 'DT088474M'                         /* ����������ID*/
            , 'P'                       /* �����ý��۱����ڵ�*/
            , CURRENT_TIMESTAMP                                                 /* ���������Ͻ�*/
        )
; 
            
            
-- DB �ݿ� �ڷ� 4�� S ---  11671 (01.04)
--- 3�� EIV(��ǰ��)�� MLOC �ִµ�  LOC ���̺� LOC���� �� ó��




-- BIV(�����) ��� ������ �ι� ��������  LOCATION�� ���� �ι� �̶�� INSERT ���⼭ ���� LOCATION�� ���� �ι��̶�� �����Ͽ� �ű� LOC�� ä�� ���


           
			INSERT 
			INTO MBSASSTD.TBSLAULOC  (
				  	MCTR_CD
				  ,	WHS_CD
				  ,	LOC_NO
				  ,	PTNO
				  ,	HKC_DCD
				  ,	LOC_STK_QTY
				  ,	AVS_QTY
				  ,	WSND_QTY
				  ,	PRI_CD
				  ,	ZON_CD
				  ,	AIS 
				  ,	SCN
				  ,	LVL
				  ,	POS 
				  ,	LOC_SNO 
				  ,	BATT_SER_YN
				  ,	BATT_SER_NO
				  ,	VIR_YN
				  ,	LOC_USE_DCD
				  ,	FST_STR_DT
				  ,	FST_STR_TM
				  ,	LST_STR_DT
				  ,	LST_STR_TM
				  ,	LST_SND_DT
				  ,	LST_SND_TM
				  ,	MEMO
				  ,	FST_USR_ID
				  ,	FST_SYS_DCD
				  ,	FST_CRT_DTM
				  ,	LST_UPD_ID
				  ,	LST_SYS_DCD
				  ,	LST_UPD_DTM
			 )
 WITH AISLE_ARR(AISLE_NUM, AISLE_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS AISLE_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS AISLE_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT AISLE_NUM + 1, LPAD(AISLE_NUM + 1,2,0)
                  FROM AISLE_ARR
                 WHERE AISLE_NUM < TO_NUMBER('20')
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('20')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS LEVEL_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS LEVEL_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT LEVEL_NUM + 1, LPAD(LEVEL_NUM + 1,2,0)
                  FROM LEVEL_ARR
                 WHERE LEVEL_NUM < TO_NUMBER('25')
            )
            , POSITION_ARR(POSITION_NUM, POSITION_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT ASCII('A') AS POSITION_NUM, 'A' AS POSITION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT POSITION_NUM + 1, CHR(POSITION_NUM+1)
                  FROM POSITION_ARR
                 WHERE POSITION_NUM < ASCII('Z')
            )
            , MCTR_WHS_LIST AS (
            		 
            		SELECT  DISTINCT 
            				IBIV.MCTR_CD
            			, 	IBIV.WHS_CD
            		 	, 	IBIV.ZON_CD 
					FROM	(
							SELECT  UBIV.BRN_CD AS	MCTR_CD
								,	UBIV.WHS_CD 
								,   SUBSTRING(TRIM(UBIV.MLOC_NO ), 1, 3) AS ZON_CD
							FROM	MBSASSTD.TBSIAUEIV	UBIV
							LEFT
							JOIN    MBSASSTD.TBSTAUDPM	UDPM
							ON      UDPM.PTNO 			=	UBIV.PTNO 
							WHERE 	1 = 1
							AND     (
									UBIV.STK_CTL_QTY   -- ��� ���� ����
									+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
									+ UBIV.WS_NSND_QTY
									+ UBIV.WFLD_BDPC_DO_QTY
									+ UBIV.BFLD_BDPC_DO_QTY
									)	> 0
							AND		LENGTH(TRIM(UBIV.MLOC_NO )) > 0
							AND     NOT EXISTS	(
												SELECT	ULOC.LOC_NO 
												FROM 	MBSASSTD.TBSLAULOC  ULOC
												WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD 
												AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
												AND     ULOC.PTNO     	=	UBIV.PTNO
												)
												
							--AND 	UBIV.BRN_CD 	!=	'RPE'				-- (CASE WHEN LENGTH(TRIM(UBIV.MCTR_CD )) = 0 THEN UBIV.BRN_CD ELSE  UBIV.MCTR_CD END)
							)	IBIV
		
            )
            SELECT	NLDT.MCTR_CD
		       	, 	NLDT.WHS_CD
            	,	NLDT.LOC_NO
            	,	SBIV.PTNO 
            	,	SBIV.HKC_DCD
            	, 	SBIV.LOC_STK_QTY   /* �����̼�������*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY       /* ����������*/
            	, 	SBIV.WSND_QTY      /* ��������*/
            	,	CASE WHEN SBIV.S_SEQ = 1 THEN 'P' ELSE 'R' END	AS PRI_CD        /* PR�����ڵ�*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* ���͸��ø��󿩺�*/
	            , '' AS BATT_SER_NO   /* ���͸��ø����ȣ*/
	            , '' AS VIR_YN        /* ���󿩺�*/
	            , '' AS LOC_USE_DCD   /* �����̼ǻ�뱸���ڵ�*/
	            , '' AS FST_STR_DT    /* ������������*/
	            , '' AS FST_STR_TM    /* ��������ð�*/
	            , '' AS LST_STR_DT    /* ������������*/
	            , '' AS LST_STR_TM    /* ��������ð�*/
	            , '' AS LST_SND_DT    /* �����������*/
	            , '' AS LST_SND_TM    /* �������ð�*/
	            , '4�� �۾�' AS MEMO          /* �޸�*/
	            , 'DT088474M' AS FST_USR_ID    /* ���ʻ����ID*/
	            , 'P'   AS FST_SYS_DCD   /* ���ʽý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* ���ʻ����Ͻ�*/
	            , 'DT088474M' AS LST_UPD_ID    /* ����������ID*/
	            , 'P' AS LST_SYS_DCD   /* �����ý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* ���������Ͻ�*/
            --  	,	NLDT.S_SEQ
           FROM	(
		            SELECT MWLT.MCTR_CD
		                 , MWLT.WHS_CD
		            	 , MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR AS LOC_NO
		                 , MWLT.ZON_CD AS ZON_CD
		                 , AA.AISLE_CHAR AS AIS
		                 , SA.SECTION_CHAR AS SCN
		                 , LA.LEVEL_CHAR AS LVL
		                 , PA.POSITION_CHAR AS POS
		               
		                 ,	ROW_NUMBER() OVER(PARTITION BY 	MWLT.MCTR_CD ,	MWLT.WHS_CD,	MWLT.ZON_CD ORDER BY AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR )	AS S_SEQ
		              FROM AISLE_ARR AA
		              INNER JOIN SECTION_ARR SA ON 1=1
		              INNER JOIN LEVEL_ARR LA ON 1=1
		              INNER JOIN POSITION_ARR PA ON 1=1
		              INNER JOIN MCTR_WHS_LIST AS MWLT ON 1=1

		              WHERE 1=1 --ULOC.LOC_NO IS NULL
		                            
		              AND     NOT EXISTS	(
											SELECT	ULOC.LOC_NO 
											FROM 	MBSASSTD.TBSLAULOC  ULOC
											WHERE 	1 = 1
											AND		ULOC.MCTR_CD	= MWLT.MCTR_CD
						                    AND 	ULOC.WHS_CD 	= MWLT.WHS_CD
						                    AND 	ULOC.LOC_NO 	=  MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR
											)  

					)	NLDT
				JOIN 
					(
					SELECT  UBIV.MLOC_NO
						,	UBIV.BRN_CD 	AS	MCTR_CD
						,	UBIV.BRN_CD
						,	UBIV.WHS_CD 
						,	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) AS	ZON_CD 
						,	UBIV.PTNO 
						,	IFNULL(IFNULL(UDPM.HKC_DCD, MBSASSTD.FN_IPFHKCDCD(UBIV.BRN_CD)) , '') AS HKC_DCD
						,   (
							UBIV.STK_CTL_QTY   -- ��� ���� ����
							+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
							+ UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	LOC_STK_QTY   /* �����̼�������*/
						,   (
							UBIV.STK_CTL_QTY   -- ��� ���� ����
							+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
							)						AS	AVS_QTY       /* ����������*/
						,	(
							 UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	WSND_QTY		/* ��������*/	
						,	ROW_NUMBER() OVER(PARTITION BY 	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
					FROM	MBSASSTD.TBSIAUEIV	UBIV
					LEFT
					JOIN    MBSASSTD.TBSTAUDPM	UDPM
					ON      UDPM.PTNO 			=	UBIV.PTNO 
					WHERE 	1 = 1
					AND     (
							UBIV.STK_CTL_QTY   -- ��� ���� ����
							+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
							+ UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)	> 0
					AND		LENGTH(TRIM(UBIV.MLOC_NO )) > 0
					AND     NOT EXISTS	(
										SELECT	ULOC.LOC_NO 
										FROM 	MBSASSTD.TBSLAULOC  ULOC
										WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD
										AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
										AND     ULOC.PTNO     	=	UBIV.PTNO
										)
					
					)	SBIV
				ON	SBIV.MCTR_CD = NLDT.MCTR_CD
	            AND SBIV.WHS_CD =  NLDT.WHS_CD
	            AND SBIV.ZON_CD = NLDT.ZON_CD
				AND SBIV.S_SEQ = NLDT.S_SEQ
				ORDER 
					BY NLDT.MCTR_CD
			       	, 	NLDT.WHS_CD
	            	,	NLDT.LOC_NO
	            	,	SBIV.PTNO 
	;


-- DB �ݿ� �ڷ� 4-1�� S --- 11671 (01.18)
--- 4������ �۾��� ���� ä�� �� LOC �� ���� ��� ���̺� �ش� ��ǰ ��ȣ�� MLOC���� UPDATE �Ѵ�. 

MERGE	
INTO	MBSASSTD.TBSIAUEIV	UBIV 
USING	(
		SELECT	ULOC.MCTR_CD
			,  	ULOC.WHS_CD 
			,   ULOC.LOC_NO 
			,   ULOC.PTNO 
		FROM 	MBSASSTD.TBSLAULOC  ULOC 
		WHERE   1 = 1
		AND 	ULOC.MCTR_CD IN 	(
									SELECT 	DISTINCT BRN_CD
									FROM 	MBSASSTD.TBSIAUEIV	UBIV
									) 
		AND     ULOC.MEMO 		= '4�� �۾�'
		) DT
ON		(
				UBIV.BRN_CD 	= DT.MCTR_CD 
		AND     UBIV.WHS_CD 	= DT.WHS_CD 
		AND     UBIV.PTNO 		= DT.PTNO 
		)
WHEN  MATCHED THEN 
        UPDATE 
        SET		UBIV.MLOC_NO 	=	DT.LOC_NO
;									


-- DB �ݿ� �ڷ� 5�� S --- 455 (01.18)
--- PRI_CD�� R�� UPDATE -------------------------------------------------------------------------------

MERGE 
INTO	MBSASSTD.TBSLAULOC  ULOC 
USING	(
		SELECT 	SLOC.MCTR_CD 
			,   SLOC.WHS_CD 
			,   SLOC.UBIV_PTNO		
			, 	SLOC.ULOC_PTNO
			,   SLOC.UBIV_LOC_NO 	
			,	SLOC.ULOC_LOC_NO 
			,	SLOC.S_SEQ
			,	LENGTH(TRIM(SLOC.UBIV_LOC_NO))
		FROM 	(
				SELECT	ULOC.MCTR_CD 
					,   ULOC.WHS_CD 
					,   UBIV.PTNO 		AS 	UBIV_PTNO		
					, 	ULOC.PTNO 		AS 	ULOC_PTNO
					,   UBIV.MLOC_NO	AS	UBIV_LOC_NO 	
					,	ULOC.LOC_NO 	AS	ULOC_LOC_NO 
					,	ROW_NUMBER() OVER(PARTITION BY 	ULOC.MCTR_CD  ,	ULOC.WHS_CD ,	ULOC.PTNO ORDER BY UBIV.MLOC_NO,  ULOC.LOC_NO )	AS S_SEQ
					--,	ULOC.* 
				FROM 	MBSASSTD.TBSLAULOC  ULOC
				LEFT 	
				JOIN	MBSASSTD.TBSIAUBIV  UBIV
				ON		UBIV.BRN_CD 		=	ULOC.MCTR_CD 
				AND     UBIV.WHS_CD 		=	ULOC.WHS_CD 
				AND     UBIV.PTNO 			=	ULOC.PTNO 
				AND     UBIV.MLOC_NO 		=	ULOC.LOC_NO 
				WHERE 	1 = 1	
				AND    	ULOC.MCTR_CD	IN (
											SELECT  DISTINCT UBIV.BRN_CD
											FROM	MBSASSTD.TBSIAUBIV	UBIV
											JOIN	MBSASSTD.TBSIAUBMT	UBMT
											ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
											WHERE 	1 = 1
											AND     UBMT.BRN_FUNC_DCD != 'M'
											)
				AND     ULOC.PRI_CD	=	'P'
				) SLOC
		WHERE 	1 = 1
		AND     SLOC.UBIV_LOC_NO IS NULL
		AND     SLOC.S_SEQ > 1
		--AND     SLOC.MCTR_CD 		=	'CCA'
		--AND     SLOC.WHS_CD 		=	'M01'
		--AND     SLOC.ULOC_PTNO 		=	'0K72A43800C' --'87620F6730ABP' -- '0K72A43800C'
		--ORDER 
		--	BY	SLOC.MCTR_CD 
		--	,   SLOC.WHS_CD 
		--	,   SLOC.ULOC_PTNO 
		--	,   SLOC.ULOC_LOC_NO
		--	,	SLOC.S_SEQ
		)	DT
ON    	(
				ULOC.MCTR_CD	=	DT.MCTR_CD
		AND   	ULOC.WHS_CD  	=	DT.WHS_CD
		AND   	ULOC.LOC_NO 	=	DT.ULOC_LOC_NO
		)
WHEN MATCHED THEN 
		UPDATE 
		SET		ULOC.PRI_CD	= 'R'
;		



-- DB �ݿ� �ڷ� 6�� S --- 0 (01.18) 
--- PRI_CD�� R�� UPDATE -------------------------------------------------------------------------------

MERGE 
INTO	MBSASSTD.TBSLAULOC  ULOC 
USING	(
		SELECT 	SLOC.MCTR_CD 
			,   SLOC.WHS_CD 
			,   SLOC.UBIV_PTNO		
			, 	SLOC.ULOC_PTNO
			,   SLOC.UBIV_LOC_NO 	
			,	SLOC.ULOC_LOC_NO 
			,	SLOC.S_SEQ
			,	LENGTH(TRIM(SLOC.UBIV_LOC_NO))
		FROM 	(
				SELECT	ULOC.MCTR_CD 
					,   ULOC.WHS_CD 
					,   UBIV.PTNO 		AS 	UBIV_PTNO		
					, 	ULOC.PTNO 		AS 	ULOC_PTNO
					,   UBIV.MLOC_NO	AS	UBIV_LOC_NO 	
					,	ULOC.LOC_NO 	AS	ULOC_LOC_NO 
					,	ROW_NUMBER() OVER(PARTITION BY 	ULOC.MCTR_CD  ,	ULOC.WHS_CD ,	ULOC.PTNO ORDER BY UBIV.MLOC_NO, ULOC.LOC_NO )	AS S_SEQ
					--,	ULOC.* 
				FROM 	MBSASSTD.TBSLAULOC  ULOC
				LEFT 	
				JOIN	MBSASSTD.TBSIAUEIV  UBIV
				ON		UBIV.BRN_CD 		=	ULOC.MCTR_CD 
				AND     UBIV.WHS_CD 		=	ULOC.WHS_CD 
				AND     UBIV.PTNO 			=	ULOC.PTNO 
				AND     UBIV.MLOC_NO 		=	ULOC.LOC_NO 
				WHERE 	1 = 1	
				AND     ULOC.PRI_CD	=	'P'
				AND 	ULOC.MCTR_CD IN 	(
											SELECT 	DISTINCT BRN_CD
											FROM 	MBSASSTD.TBSIAUEIV	UBIV
											) 
				--AND     ULOC.LOC_STK_QTY = 0
				--AND     LENGTH(TRIM(ULOC.MEMO)) = 0
				) SLOC
		WHERE 	1 = 1
		AND     SLOC.UBIV_LOC_NO IS NULL
		AND     SLOC.S_SEQ > 1
		--AND     SLOC.MCTR_CD 		=	'CCA'
		--AND     SLOC.WHS_CD 		=	'M01'
		--AND     SLOC.ULOC_PTNO 		=	'0K72A43800C' --'87620F6730ABP' -- '0K72A43800C'
		--ORDER 
		--	BY	SLOC.MCTR_CD 
		--	,   SLOC.WHS_CD 
		--	,   SLOC.ULOC_PTNO 
		--	,   SLOC.ULOC_LOC_NO
		--	,	SLOC.S_SEQ
		)	DT
ON    	(
				ULOC.MCTR_CD	=	DT.MCTR_CD
		AND   	ULOC.WHS_CD  	=	DT.WHS_CD
		AND   	ULOC.LOC_NO 	=	DT.ULOC_LOC_NO
		)
WHEN MATCHED THEN 
		UPDATE 
		SET		ULOC.PRI_CD	= 'R'
;		


-- DB �ݿ� �ڷ� 7�� S --- 7256 (01.18) 
--- EZA 'UUU' ZONE LOC ���� -------------------------------------------------------------------------------
									
										
 			INSERT 
			INTO MBSASSTD.TBSLAULOC  (
				  	MCTR_CD
				  ,	WHS_CD
				  ,	LOC_NO
				  ,	PTNO
				  ,	HKC_DCD
				  ,	LOC_STK_QTY
				  ,	AVS_QTY
				  ,	WSND_QTY
				  ,	PRI_CD
				  ,	ZON_CD
				  ,	AIS 
				  ,	SCN
				  ,	LVL
				  ,	POS 
				  ,	LOC_SNO 
				  ,	BATT_SER_YN
				  ,	BATT_SER_NO
				  ,	VIR_YN
				  ,	LOC_USE_DCD
				  ,	FST_STR_DT
				  ,	FST_STR_TM
				  ,	LST_STR_DT
				  ,	LST_STR_TM
				  ,	LST_SND_DT
				  ,	LST_SND_TM
				  ,	MEMO
				  ,	FST_USR_ID
				  ,	FST_SYS_DCD
				  ,	FST_CRT_DTM
				  ,	LST_UPD_ID
				  ,	LST_SYS_DCD
				  ,	LST_UPD_DTM
			 )
 
WITH 	AISLE_ARR AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT '00' AISLE_CHAR FROM	SYSIBM.SYSDUMMY1
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('99')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS LEVEL_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS LEVEL_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT LEVEL_NUM + 1, LPAD(LEVEL_NUM + 1,2,0)
                  FROM LEVEL_ARR
                 WHERE LEVEL_NUM < TO_NUMBER('99')
            )
            , POSITION_ARR AS ( SELECT 'A' POSITION_CHAR FROM	SYSIBM.SYSDUMMY1 )
            , MCTR_WHS_LIST AS (
            		SELECT  'EZA' AS MCTR_CD
            			, 	'M01' AS WHS_CD
            		 	, 	'UUU' AS ZON_CD 
					FROM	SYSIBM.SYSDUMMY1
		
            )
            
            SELECT	NLDT.MCTR_CD
		       	, 	NLDT.WHS_CD
            	,	NLDT.LOC_NO
            	,	SBIV.PTNO 
            	,	'H'  AS HKC_DCD
            	, 	SBIV.LOC_STK_QTY   /* �����̼�������*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY    /* ����������*/
            	, 	SBIV.WSND_QTY      /* ��������*/
            	,	'P'	AS PRI_CD        /* PR�����ڵ�*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* ���͸��ø��󿩺�*/
	            , '' AS BATT_SER_NO   /* ���͸��ø����ȣ*/
	            , '' AS VIR_YN        /* ���󿩺�*/
	            , '' AS LOC_USE_DCD   /* �����̼ǻ�뱸���ڵ�*/
	            , '' AS FST_STR_DT    /* ������������*/
	            , '' AS FST_STR_TM    /* ��������ð�*/
	            , '' AS LST_STR_DT    /* ������������*/
	            , '' AS LST_STR_TM    /* ��������ð�*/
	            , '' AS LST_SND_DT    /* �����������*/
	            , '' AS LST_SND_TM    /* �������ð�*/
	            , '5�� �۾�' AS MEMO          /* �޸�*/
	            , 'DT088474M' AS FST_USR_ID    /* ���ʻ����ID*/
	            , 'P'   AS FST_SYS_DCD   /* ���ʽý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* ���ʻ����Ͻ�*/
	            , 'DT088474M' AS LST_UPD_ID    /* ����������ID*/
	            , 'P' AS LST_SYS_DCD   /* �����ý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* ���������Ͻ�*/
              	--,	NLDT.S_SEQ
           FROM	(

            
            		SELECT MWLT.MCTR_CD
		                 , MWLT.WHS_CD
		            	 , MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR AS LOC_NO
		                 , MWLT.ZON_CD AS ZON_CD
		                 , AA.AISLE_CHAR AS AIS
		                 , SA.SECTION_CHAR AS SCN
		                 , LA.LEVEL_CHAR AS LVL
		                 , PA.POSITION_CHAR AS POS
		               
		                 ,	ROW_NUMBER() OVER(PARTITION BY 	MWLT.MCTR_CD ,	MWLT.WHS_CD,	MWLT.ZON_CD ORDER BY AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR )	AS S_SEQ
		              FROM AISLE_ARR AA
		              INNER JOIN SECTION_ARR SA ON 1=1
		              INNER JOIN LEVEL_ARR LA ON 1=1
		              INNER JOIN POSITION_ARR PA ON 1=1
		              INNER JOIN MCTR_WHS_LIST AS MWLT ON 1=1

		              WHERE 1=1 --ULOC.LOC_NO IS NULL
		                             
		       		) NLDT
			JOIN 
					(
					SELECT  UBIV.MLOC_NO
						,	UBIV.BRN_CD AS	MCTR_CD
						,	UBIV.BRN_CD
						,	UBIV.WHS_CD 
						,	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) AS	ZON_CD 
						,	UBIV.PTNO 
						,	IFNULL(IFNULL(UDPM.HKC_DCD, MBSASSTD.FN_IPFHKCDCD(UBIV.BRN_CD)) , '') AS HKC_DCD
						,   (
							UBIV.GNRL_GDS_STK_QTY	-- �Ϲݻ�ǰ������
						+	UBIV.KIT_GDS_STK_QTY	-- KIT��ǰ������
						+	UBIV.POI_GDS_STK_QTY	-- POI��ǰ������
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND�Ҵ����
						+	UBIV.OUTB_OPIC_QTY		-- OUTBOUND��ŷ������
							)						AS	LOC_STK_QTY   /* �����̼�������*/
						,   (
							UBIV.GNRL_GDS_STK_QTY	-- �Ϲݻ�ǰ������
						+	UBIV.KIT_GDS_STK_QTY	-- KIT��ǰ������
						+	UBIV.POI_GDS_STK_QTY	-- POI��ǰ������
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND�Ҵ����
							)						AS	AVS_QTY       /* ����������*/
						,	UBIV.OUTB_OPIC_QTY		AS	WSND_QTY		/* ��������*/
						,	ROW_NUMBER() OVER(PARTITION BY 	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
					FROM	MBSASSTD.TBSIAMEIM	UBIV 
					JOIN	MBSASSTD.TBSIAUBMT	UBMT
					ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
					LEFT
					JOIN    MBSASSTD.TBSTAUDPM	UDPM
					ON      UDPM.PTNO 			=	UBIV.PTNO 
					WHERE 	1 = 1
					AND     UBIV.BRN_CD			=	'EZA'

					AND     UBIV.MLOC_NO = 'UUU'
					AND     NOT EXISTS	(
										SELECT	ULOC.LOC_NO 
										FROM 	MBSASSTD.TBSLAULOC  ULOC
										WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD
										AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
										AND     ULOC.PTNO     	=	UBIV.PTNO
										)
					)	SBIV
				ON	SBIV.MCTR_CD = NLDT.MCTR_CD
	            AND SBIV.WHS_CD =  NLDT.WHS_CD
	            AND SBIV.ZON_CD = NLDT.ZON_CD
				AND SBIV.S_SEQ = NLDT.S_SEQ
				ORDER 
					BY NLDT.MCTR_CD
			       	, 	NLDT.WHS_CD
	            	,	NLDT.LOC_NO
	            	,	SBIV.PTNO 
	;
	
	
-- DB �ݿ� �ڷ� 8�� S ---  61007 (01.18)
--- EZB 'SAS' ZONE LOC ���� -------------------------------------------------------------------------------


INSERT 
			INTO MBSASSTD.TBSLAULOC  (
				  	MCTR_CD
				  ,	WHS_CD
				  ,	LOC_NO
				  ,	PTNO
				  ,	HKC_DCD
				  ,	LOC_STK_QTY
				  ,	AVS_QTY
				  ,	WSND_QTY
				  ,	PRI_CD
				  ,	ZON_CD
				  ,	AIS 
				  ,	SCN
				  ,	LVL
				  ,	POS 
				  ,	LOC_SNO 
				  ,	BATT_SER_YN
				  ,	BATT_SER_NO
				  ,	VIR_YN
				  ,	LOC_USE_DCD
				  ,	FST_STR_DT
				  ,	FST_STR_TM
				  ,	LST_STR_DT
				  ,	LST_STR_TM
				  ,	LST_SND_DT
				  ,	LST_SND_TM
				  ,	MEMO
				  ,	FST_USR_ID
				  ,	FST_SYS_DCD
				  ,	FST_CRT_DTM
				  ,	LST_UPD_ID
				  ,	LST_SYS_DCD
				  ,	LST_UPD_DTM
			 )

WITH 	AISLE_ARR(AISLE_NUM, AISLE_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS AISLE_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS AISLE_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT AISLE_NUM + 1, LPAD(AISLE_NUM + 1,2,0)
                  FROM AISLE_ARR
                 WHERE AISLE_NUM < TO_NUMBER('10')
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('99')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
                SELECT TO_NUMBER('01') AS LEVEL_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS LEVEL_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT LEVEL_NUM + 1, LPAD(LEVEL_NUM + 1,2,0)
                  FROM LEVEL_ARR
                 WHERE LEVEL_NUM < TO_NUMBER('99')
            )
            , POSITION_ARR AS ( SELECT 'A' POSITION_CHAR FROM	SYSIBM.SYSDUMMY1 )
--            , POSITION_ARR(POSITION_NUM, POSITION_CHAR) AS ( /* �������� �Է� ������ ��ȸ*/
--                SELECT ASCII('A') AS POSITION_NUM, 'A' AS POSITION_CHAR
--                  FROM SYSIBM.SYSDUMMY1
--                 UNION ALL
--                SELECT POSITION_NUM + 1, CHR(POSITION_NUM+1)
--                  FROM POSITION_ARR
--                 WHERE POSITION_NUM < ASCII('Z')
--            )
            , MCTR_WHS_LIST AS (
            		SELECT  'EZB' AS MCTR_CD
            			, 	'M01' AS WHS_CD
            		 	, 	'SAS' AS ZON_CD 
					FROM	SYSIBM.SYSDUMMY1
		
            )
            
            SELECT	NLDT.MCTR_CD
		       	, 	NLDT.WHS_CD
            	,	NLDT.LOC_NO
            	,	SBIV.PTNO 
            	,	'H'  AS HKC_DCD
            	, 	SBIV.LOC_STK_QTY   /* �����̼�������*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY    /* ����������*/
            	, 	SBIV.WSND_QTY      /* ��������*/
            	,	'P'	AS PRI_CD        /* PR�����ڵ�*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* ���͸��ø��󿩺�*/
	            , '' AS BATT_SER_NO   /* ���͸��ø����ȣ*/
	            , '' AS VIR_YN        /* ���󿩺�*/
	            , '' AS LOC_USE_DCD   /* �����̼ǻ�뱸���ڵ�*/
	            , '' AS FST_STR_DT    /* ������������*/
	            , '' AS FST_STR_TM    /* ��������ð�*/
	            , '' AS LST_STR_DT    /* ������������*/
	            , '' AS LST_STR_TM    /* ��������ð�*/
	            , '' AS LST_SND_DT    /* �����������*/
	            , '' AS LST_SND_TM    /* �������ð�*/
	            , '6�� �۾�' AS MEMO          /* �޸�*/
	            , 'DT088474M' AS FST_USR_ID    /* ���ʻ����ID*/
	            , 'P'   AS FST_SYS_DCD   /* ���ʽý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* ���ʻ����Ͻ�*/
	            , 'DT088474M' AS LST_UPD_ID    /* ����������ID*/
	            , 'P' AS LST_SYS_DCD   /* �����ý��۱����ڵ�*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* ���������Ͻ�*/
              	--,	NLDT.S_SEQ
           FROM	(

            
            		SELECT MWLT.MCTR_CD
		                 , MWLT.WHS_CD
		            	 , MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR AS LOC_NO
		                 , MWLT.ZON_CD AS ZON_CD
		                 , AA.AISLE_CHAR AS AIS
		                 , SA.SECTION_CHAR AS SCN
		                 , LA.LEVEL_CHAR AS LVL
		                 , PA.POSITION_CHAR AS POS
		               
		                 ,	ROW_NUMBER() OVER(PARTITION BY 	MWLT.MCTR_CD ,	MWLT.WHS_CD,	MWLT.ZON_CD ORDER BY AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR )	AS S_SEQ
		              FROM AISLE_ARR AA
		              INNER JOIN SECTION_ARR SA ON 1=1
		              INNER JOIN LEVEL_ARR LA ON 1=1
		              INNER JOIN POSITION_ARR PA ON 1=1
		              INNER JOIN MCTR_WHS_LIST AS MWLT ON 1=1
		              /*
		              LEFT JOIN MBSASSTD.TBSLAULOC AS ULOC 
		                      ON ULOC.MCTR_CD = MWLT.MCTR_CD
		                     AND ULOC.WHS_CD = MWLT.WHS_CD
		                     AND ULOC.LOC_NO =  MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR
		           		*/
		              WHERE 1=1 --ULOC.LOC_NO IS NULL
		                            
--		              AND     NOT EXISTS	(
--											SELECT	ULOC.LOC_NO 
--											FROM 	MBSASSTD.TBSLAULOC  ULOC
--											WHERE 	1 = 1
--											AND		ULOC.MCTR_CD	= MWLT.MCTR_CD
--						                    AND 	ULOC.WHS_CD 	= MWLT.WHS_CD
--						                    AND 	ULOC.LOC_NO 	=  MWLT.ZON_CD || AA.AISLE_CHAR || SA.SECTION_CHAR || LA.LEVEL_CHAR || PA.POSITION_CHAR
--											)  
		       		) NLDT
			JOIN 
					(
					SELECT  UBIV.MLOC_NO
						,	UBIV.BRN_CD AS	MCTR_CD
						,	UBIV.BRN_CD
						,	UBIV.WHS_CD 
						,	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) AS	ZON_CD 
						,	UBIV.PTNO 
						,	IFNULL(IFNULL(UDPM.HKC_DCD, MBSASSTD.FN_IPFHKCDCD(UBIV.BRN_CD)) , '') AS HKC_DCD
						,   (
							UBIV.GNRL_GDS_STK_QTY	-- �Ϲݻ�ǰ������
						+	UBIV.KIT_GDS_STK_QTY	-- KIT��ǰ������
						+	UBIV.POI_GDS_STK_QTY	-- POI��ǰ������
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND�Ҵ����
						+	UBIV.OUTB_OPIC_QTY		-- OUTBOUND��ŷ������
							)						AS	LOC_STK_QTY   /* �����̼�������*/
						,   (
							UBIV.GNRL_GDS_STK_QTY	-- �Ϲݻ�ǰ������
						+	UBIV.KIT_GDS_STK_QTY	-- KIT��ǰ������
						+	UBIV.POI_GDS_STK_QTY	-- POI��ǰ������
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND�Ҵ����
							)						AS	AVS_QTY       /* ����������*/
						,	UBIV.OUTB_OPIC_QTY		AS	WSND_QTY		/* ��������*/
						,	ROW_NUMBER() OVER(PARTITION BY 	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
					FROM	MBSASSTD.TBSIAMEIM	UBIV 
					JOIN	MBSASSTD.TBSIAUBMT	UBMT
					ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
					LEFT
					JOIN    MBSASSTD.TBSTAUDPM	UDPM
					ON      UDPM.PTNO 			=	UBIV.PTNO 
					WHERE 	1 = 1
					AND     UBIV.BRN_CD			=	'EZB'
--					AND     (
--							UBIV.STK_CTL_QTY   -- ��� ���� ����
--							+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
--							+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
--							+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
--							)	> 0
--					AND		LENGTH(TRIM(UBIV.MLOC_NO )) > 0
					-- AND     UBIV.MLOC_NO = '11Z010101H'
					AND     UBIV.MLOC_NO = 'SAS'
					AND     NOT EXISTS	(
										SELECT	ULOC.LOC_NO 
										FROM 	MBSASSTD.TBSLAULOC  ULOC
										WHERE 	ULOC.MCTR_CD 	=	UBIV.BRN_CD
										AND     ULOC.WHS_CD		= 	UBIV.WHS_CD 		
										--AND     ULOC.LOC_NO     =	UBIV.MLOC_NO
										AND     ULOC.PTNO     	=	UBIV.PTNO
										)
					)	SBIV
				ON	SBIV.MCTR_CD = NLDT.MCTR_CD
	            AND SBIV.WHS_CD =  NLDT.WHS_CD
	            AND SBIV.ZON_CD = NLDT.ZON_CD
				AND SBIV.S_SEQ = NLDT.S_SEQ
				ORDER 
					BY NLDT.MCTR_CD
			       	, 	NLDT.WHS_CD
	            	,	NLDT.LOC_NO
	            	,	SBIV.PTNO 
	;
	
	
-- DB �ݿ� �ڷ� 9�� S --- 1280623 (01.18) 
--- SCR ���� ǰ�� ��� ���� �ش� ǰ�� PRI LOC�� UPDATE  -------------------------------------------------------------------------------	
	
	
MERGE 
INTO	MBSASSTD.TBSLAULOC	ULOC 
USING	(
			SELECT  UBIV.MLOC_NO
				,	UBIV.BRN_CD
				,	UBIV.WHS_CD 
				,	UBIV.PTNO 
				,   (
					UBIV.STK_CTL_QTY   -- ��� ���� ����
					+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
					+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
					+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
					+ UBIV.WS_NSND_QTY
					+ UBIV.WFLD_BDPC_DO_QTY
					+ UBIV.BFLD_BDPC_DO_QTY
					)						AS	LOC_STK_QTY   /* �����̼�������*/
				,   (
					UBIV.STK_CTL_QTY   -- ��� ���� ����
					+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
					+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
					+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
					)						AS	AVS_QTY       /* ����������*/
				,	(
					 UBIV.WS_NSND_QTY
					+ UBIV.WFLD_BDPC_DO_QTY
					+ UBIV.BFLD_BDPC_DO_QTY
					)						AS	WSND_QTY		/* ��������*/
			FROM	MBSASSTD.TBSIAUBIV	UBIV
			JOIN	MBSASSTD.TBSIAUBMT	UBMT
			ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
			WHERE 	1 = 1
			AND     UBMT.BRN_FUNC_DCD IN ('S', 'C', 'R')
			--AND     UBMT.BRN_CD != 'CCB'
			AND     (
					UBIV.STK_CTL_QTY   -- ��� ���� ����
					+ UBIV.GNRL_GDS_STK_QTY	-- �Ϲ� ��ǰ ��� ����
					+ UBIV.KIT_GDS_STK_QTY	-- KIT ��ǰ ��� ����
					+ UBIV.POI_GDS_STK_QTY	-- POI ��ǰ ��� ����
					+ UBIV.WS_NSND_QTY
					+ UBIV.WFLD_BDPC_DO_QTY
					+ UBIV.BFLD_BDPC_DO_QTY
					)	> 0	
		)	AA
ON 		(
			ULOC.MCTR_CD =	AA.BRN_CD
		AND	ULOC.WHS_CD  = 	AA.WHS_CD
		AND	ULOC.PTNO    =  AA.PTNO
		AND	ULOC.PRI_CD  =  'P'
		)
WHEN 	MATCHED THEN 
		UPDATE 
			SET	ULOC.LOC_STK_QTY = 	AA.LOC_STK_QTY
			,	ULOC.AVS_QTY  	 =	AA.AVS_QTY
			,	ULOC.WSND_QTY  	 =	AA.WSND_QTY
;
	

-- DB �ݿ� �ڷ� 10�� S --- 43285 (01.18)  
--- TBSUWUWSF LOC_NO UPDATE  -------------------------------------------------------------------------------	
	
MERGE 
INTO	MBSASSTD.TBSUWUWSF	UWSF
USING	(
			SELECT 	ULOC.MCTR_CD 
				,	ULOC.WHS_CD 
				,	ULOC.PTNO 
				,	ULOC.LOC_NO  
			FROM 	MBSASSTD.TBSLAULOC	ULOC 
			JOIN	MBSASSTD.TBSIAUBMT	UBMT
			ON		ULOC.MCTR_CD	=	UBMT.BRN_CD 
			WHERE 	1 = 1
			AND     UBMT.BRN_FUNC_DCD IN ('S', 'C', 'R')
			--AND     ULOC.MCTR_CD  != 'CCB'
			-- AND     ULOC.MCTR_CD  = 'SCA'
			AND		ULOC.PRI_CD  =  'P'
		)	AA
ON 		(
			UWSF.ALLO_BRN_CD  =	AA.MCTR_CD
		AND	UWSF.ALLO_WHS_CD  = AA.WHS_CD
		AND	UWSF.ALLO_PTNO    = AA.PTNO
		AND UWSF.ALLO_PRSS_CD =	'1'
		)
WHEN 	MATCHED THEN 
		UPDATE 
			SET	UWSF.LOC_NO = 	AA.LOC_NO
;
		
-- DB �ݿ� �ڷ� 11�� S --- 4546(12.18) 3S
--- TBSITUTRF SND_LOC_NO UPDATE  -------------------------------------------------------------------------------


MERGE 
INTO	MBSASSTD.TBSITUTRF	UTRF
USING	(
			SELECT 	ULOC.MCTR_CD 
				,	ULOC.WHS_CD 
				,	ULOC.PTNO 
				,	ULOC.LOC_NO  
			FROM 	MBSASSTD.TBSLAULOC	ULOC 
			JOIN	MBSASSTD.TBSIAUBMT	UBMT
			ON		ULOC.MCTR_CD	=	UBMT.BRN_CD 
			WHERE 	1 = 1
			AND     UBMT.BRN_FUNC_DCD IN ('S', 'C', 'R')
			--AND     ULOC.MCTR_CD  != 'CCB'
			--AND     ULOC.MCTR_CD  = 'SCA'
			AND		ULOC.PRI_CD  =  'P'
		)	AA
ON 		(
			UTRF.SND_BRN_CD  =	AA.MCTR_CD
		AND	UTRF.SND_WHS_CD  = AA.WHS_CD
		AND	UTRF.PTNO    = AA.PTNO
		AND UTRF.TRF_PROC_PRGG_SCD  =	'1'
		)
WHEN 	MATCHED THEN 
		UPDATE 
			SET	UTRF.SND_LOC_NO = 	AA.LOC_NO
;