
-- DB 반영 자료 1차 S ---  S
--- 1차 BIV(사업소)에 MLOC 있는데  LOC 테이블에 LOC없는 건 처리
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
						UBIV.STK_CTL_QTY   -- 재고 통제 수량
						+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
						+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
						+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
						+ UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	LOC_STK_QTY   /* 로케이션재고수량*/
					,   (
						UBIV.STK_CTL_QTY   -- 재고 통제 수량
						+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
						+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
						+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
						)						AS	AVS_QTY       /* 가용재고수량*/
					,	(
						 UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	WSND_QTY		/* 출고대기수량*/	
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
						UBIV.STK_CTL_QTY   -- 재고 통제 수량
						+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
						+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
						+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
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
              MCTR_CD       /* 복합거점코드*/
            , WHS_CD        /* 창고코드*/
            , LOC_NO        /* 로케이션번호*/
            , PTNO          /* 부품번호*/
            , HKC_DCD       /* 현대기아구분코드*/
            , LOC_STK_QTY   /* 로케이션재고수량*/
            , AVS_QTY       /* 가용재고수량*/
            , WSND_QTY      /* 출고대기수량*/
            , PRI_CD        /* PR구분코드*/
            , ZON_CD        /* ZONE코드*/
            , AIS           /* AISLE*/
            , SCN           /* SECTION*/
            , LVL           /* LEVEL*/
            , POS           /* POSITION*/
            , LOC_SNO       /* 로케이션일련번호*/
            , BATT_SER_YN   /* 배터리시리얼여부*/
            , BATT_SER_NO   /* 배터리시리얼번호*/
            , VIR_YN        /* 가상여부*/
            , LOC_USE_DCD   /* 로케이션사용구분코드*/
            , FST_STR_DT    /* 최초저장일자*/
            , FST_STR_TM    /* 최초저장시각*/
            , LST_STR_DT    /* 최종저장일자*/
            , LST_STR_TM    /* 최종저장시각*/
            , LST_SND_DT    /* 최종출고일자*/
            , LST_SND_TM    /* 최종출고시각*/
            , MEMO          /* 메모*/
            , FST_USR_ID    /* 최초사용자ID*/
            , FST_SYS_DCD   /* 최초시스템구분코드*/
            , FST_CRT_DTM   /* 최초생성일시*/
            , LST_UPD_ID    /* 최종수정자ID*/
            , LST_SYS_DCD   /* 최종시스템구분코드*/
            , LST_UPD_DTM   /* 최종수정일시*/
        )
        VALUES
        (
              DBIV.MCTR_CD                     /* 복합거점코드*/
            , DBIV.WHS_CD                          /* 창고코드*/
            , DBIV.MLOC_NO                  /* 로케이션번호*/
            , DBIV.PTNO                                                               /* 부품번호*/
            , DBIV.HKC_DCD                                                                /* 현대기아구분코드*/
            , DBIV.LOC_STK_QTY                                                  /* 로케이션재고수량*/
            , (CASE WHEN DBIV.AVS_QTY < 0 THEN 0 ELSE DBIV.AVS_QTY END)                                                /* 가용재고수량*/
            , DBIV.WSND_QTY                                                     /* 출고대기수량*/
            , 'P'                                                               /* PR구분코드*/
            , SUBSTRING(DBIV.MLOC_NO,1,3)   /* ZONE코드*/
            , SUBSTRING(DBIV.MLOC_NO,4,2)   /* AISLE*/
            , SUBSTRING(DBIV.MLOC_NO,6,2)   /* SECTION*/
            , SUBSTRING(DBIV.MLOC_NO,8,2)   /* LEVEL*/
            , SUBSTRING(DBIV.MLOC_NO,10,1)  /* POSITION*/
            , DBIV.MLOC_NO                  /* 로케이션일련번호*/
            , ''                                                                /* 배터리시리얼여부*/
            , ''                                                                /* 배터리시리얼번호*/
            , ''                                                                /* 가상여부*/
            , ''                                                                /* 로케이션사용구분코드*/
            , ''                                                                /* 최초저장일자*/
            , ''                                                                /* 최초저장시각*/
            , ''                                                                /* 최종저장일자*/
            , ''                                                                /* 최종저장시각*/
            , ''                                                                /* 최종출고일자*/
            , ''                                                                /* 최종출고시각*/
            , '1차 작업'                                                                /* 메모*/
            , 'DT088474M'                         /* 최초사용자ID*/
            , 'P'                         /* 최초시스템구분코드*/
            , CURRENT_TIMESTAMP                                                 /* 최초생성일시*/
            , 'DT088474M'                         /* 최종수정자ID*/
            , 'P'                       /* 최종시스템구분코드*/
            , CURRENT_TIMESTAMP                                                 /* 최종수정일시*/
        )
; 


-- DB 반영 자료 2차 S --- 
-- BIV(사업소) 재고 정보의 부번 기준으로  LOCATION에 없는 부번 이라면 INSERT 여기서 동일 LOCATION을 쓰는 부번이라면 정렬하여 신규 LOC을 채번 등록

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
			 
 WITH AISLE_ARR(AISLE_NUM, AISLE_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS AISLE_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS AISLE_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT AISLE_NUM + 1, LPAD(AISLE_NUM + 1,2,0)
                  FROM AISLE_ARR
                 WHERE AISLE_NUM < TO_NUMBER('99')
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('20')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS LEVEL_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS LEVEL_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT LEVEL_NUM + 1, LPAD(LEVEL_NUM + 1,2,0)
                  FROM LEVEL_ARR
                 WHERE LEVEL_NUM < TO_NUMBER('25')
            )
            , POSITION_ARR(POSITION_NUM, POSITION_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
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
									UBIV.STK_CTL_QTY   -- 재고 통제 수량
									+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
									+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
									+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
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
            	, 	SBIV.LOC_STK_QTY   /* 로케이션재고수량*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY    /* 가용재고수량*/
            	, 	SBIV.WSND_QTY      /* 출고대기수량*/
            	,	'P'	AS PRI_CD        /* PR구분코드*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* 배터리시리얼여부*/
	            , '' AS BATT_SER_NO   /* 배터리시리얼번호*/
	            , '' AS VIR_YN        /* 가상여부*/
	            , '' AS LOC_USE_DCD   /* 로케이션사용구분코드*/
	            , '' AS FST_STR_DT    /* 최초저장일자*/
	            , '' AS FST_STR_TM    /* 최초저장시각*/
	            , '' AS LST_STR_DT    /* 최종저장일자*/
	            , '' AS LST_STR_TM    /* 최종저장시각*/
	            , '' AS LST_SND_DT    /* 최종출고일자*/
	            , '' AS LST_SND_TM    /* 최종출고시각*/
	            , '2차 작업' AS MEMO          /* 메모*/
	            , 'DT088474M' AS FST_USR_ID    /* 최초사용자ID*/
	            , 'P'   AS FST_SYS_DCD   /* 최초시스템구분코드*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* 최초생성일시*/
	            , 'DT088474M' AS LST_UPD_ID    /* 최종수정자ID*/
	            , 'P' AS LST_SYS_DCD   /* 최종시스템구분코드*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* 최종수정일시*/
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
							UBIV.STK_CTL_QTY   -- 재고 통제 수량
							+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
							+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
							+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
							+ UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	LOC_STK_QTY   /* 로케이션재고수량*/
						,   (
							UBIV.STK_CTL_QTY   -- 재고 통제 수량
							+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
							+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
							+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
							)						AS	AVS_QTY       /* 가용재고수량*/
						,	(
							 UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	WSND_QTY		/* 출고대기수량*/
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
							UBIV.STK_CTL_QTY   -- 재고 통제 수량
							+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
							+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
							+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
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

-- DB 반영 자료 2-1차 S --- 2236(01.18) 
--- 2번에서 작업한 새로 채번 된 LOC 에 대해 재고 테이블에 해당 부품 번호의 MLOC으로 UPDATE 한다. 

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
		AND     ULOC.MEMO 		= '2차 작업'
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
 
-- DB 반영 자료 3차 S ---  500125 (01.18) 
--- 3차 EIV(부품팀)에 MLOC 있는데  LOC 테이블에 LOC없는 건 처리


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
						UBIV.STK_CTL_QTY   -- 재고 통제 수량
						+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
						+ UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	LOC_STK_QTY   /* 로케이션재고수량*/
					,   (
						UBIV.STK_CTL_QTY   -- 재고 통제 수량
						+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
						)						AS	AVS_QTY       /* 가용재고수량*/
					,	(
						 UBIV.WS_NSND_QTY
						+ UBIV.WFLD_BDPC_DO_QTY
						+ UBIV.BFLD_BDPC_DO_QTY
						)						AS	WSND_QTY		/* 출고대기수량*/	
					,	ROW_NUMBER() OVER(PARTITION BY 	UBIV.MLOC_NO ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
				FROM	MBSASSTD.TBSIAUEIV	UBIV
				LEFT
				JOIN    MBSASSTD.TBSTAUDPM	UDPM
				ON      UDPM.PTNO 			=	UBIV.PTNO 
				WHERE 	1 = 1
				AND     (
						UBIV.STK_CTL_QTY   -- 재고 통제 수량
						+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
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
              MCTR_CD       /* 복합거점코드*/
            , WHS_CD        /* 창고코드*/
            , LOC_NO        /* 로케이션번호*/
            , PTNO          /* 부품번호*/
            , HKC_DCD       /* 현대기아구분코드*/
            , LOC_STK_QTY   /* 로케이션재고수량*/
            , AVS_QTY       /* 가용재고수량*/
            , WSND_QTY      /* 출고대기수량*/
            , PRI_CD        /* PR구분코드*/
            , ZON_CD        /* ZONE코드*/
            , AIS           /* AISLE*/
            , SCN           /* SECTION*/
            , LVL           /* LEVEL*/
            , POS           /* POSITION*/
            , LOC_SNO       /* 로케이션일련번호*/
            , BATT_SER_YN   /* 배터리시리얼여부*/
            , BATT_SER_NO   /* 배터리시리얼번호*/
            , VIR_YN        /* 가상여부*/
            , LOC_USE_DCD   /* 로케이션사용구분코드*/
            , FST_STR_DT    /* 최초저장일자*/
            , FST_STR_TM    /* 최초저장시각*/
            , LST_STR_DT    /* 최종저장일자*/
            , LST_STR_TM    /* 최종저장시각*/
            , LST_SND_DT    /* 최종출고일자*/
            , LST_SND_TM    /* 최종출고시각*/
            , MEMO          /* 메모*/
            , FST_USR_ID    /* 최초사용자ID*/
            , FST_SYS_DCD   /* 최초시스템구분코드*/
            , FST_CRT_DTM   /* 최초생성일시*/
            , LST_UPD_ID    /* 최종수정자ID*/
            , LST_SYS_DCD   /* 최종시스템구분코드*/
            , LST_UPD_DTM   /* 최종수정일시*/
        )
        VALUES
        (
              DBIV.MCTR_CD                     /* 복합거점코드*/
            , DBIV.WHS_CD                          /* 창고코드*/
            , DBIV.MLOC_NO                  /* 로케이션번호*/
            , DBIV.PTNO                                                               /* 부품번호*/
            , DBIV.HKC_DCD                                                                /* 현대기아구분코드*/
            , DBIV.LOC_STK_QTY                                                  /* 로케이션재고수량*/
            , CASE WHEN DBIV.AVS_QTY < 0 THEN 0 ELSE DBIV.AVS_QTY END                                                     /* 가용재고수량*/
            , DBIV.WSND_QTY                                                     /* 출고대기수량*/
            , 'P'                                                               /* PR구분코드*/
            , SUBSTRING(DBIV.MLOC_NO,1,3)   /* ZONE코드*/
            , SUBSTRING(DBIV.MLOC_NO,4,2)   /* AISLE*/
            , SUBSTRING(DBIV.MLOC_NO,6,2)   /* SECTION*/
            , SUBSTRING(DBIV.MLOC_NO,8,2)   /* LEVEL*/
            , SUBSTRING(DBIV.MLOC_NO,10,1)  /* POSITION*/
            , DBIV.MLOC_NO                  /* 로케이션일련번호*/
            , ''                                                                /* 배터리시리얼여부*/
            , ''                                                                /* 배터리시리얼번호*/
            , ''                                                                /* 가상여부*/
            , ''                                                                /* 로케이션사용구분코드*/
            , ''                                                                /* 최초저장일자*/
            , ''                                                                /* 최초저장시각*/
            , ''                                                                /* 최종저장일자*/
            , ''                                                                /* 최종저장시각*/
            , ''                                                                /* 최종출고일자*/
            , ''                                                                /* 최종출고시각*/
            , '3차 작업'                                                                /* 메모*/
            , 'DT088474M'                         /* 최초사용자ID*/
            , 'P'                         /* 최초시스템구분코드*/
            , CURRENT_TIMESTAMP                                                 /* 최초생성일시*/
            , 'DT088474M'                         /* 최종수정자ID*/
            , 'P'                       /* 최종시스템구분코드*/
            , CURRENT_TIMESTAMP                                                 /* 최종수정일시*/
        )
; 
            
            
-- DB 반영 자료 4차 S ---  11671 (01.04)
--- 3차 EIV(부품팀)에 MLOC 있는데  LOC 테이블에 LOC없는 건 처리




-- BIV(사업소) 재고 정보의 부번 기준으로  LOCATION에 없는 부번 이라면 INSERT 여기서 동일 LOCATION을 쓰는 부번이라면 정렬하여 신규 LOC을 채번 등록


           
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
 WITH AISLE_ARR(AISLE_NUM, AISLE_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS AISLE_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS AISLE_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT AISLE_NUM + 1, LPAD(AISLE_NUM + 1,2,0)
                  FROM AISLE_ARR
                 WHERE AISLE_NUM < TO_NUMBER('20')
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('20')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS LEVEL_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS LEVEL_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT LEVEL_NUM + 1, LPAD(LEVEL_NUM + 1,2,0)
                  FROM LEVEL_ARR
                 WHERE LEVEL_NUM < TO_NUMBER('25')
            )
            , POSITION_ARR(POSITION_NUM, POSITION_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
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
									UBIV.STK_CTL_QTY   -- 재고 통제 수량
									+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
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
            	, 	SBIV.LOC_STK_QTY   /* 로케이션재고수량*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY       /* 가용재고수량*/
            	, 	SBIV.WSND_QTY      /* 출고대기수량*/
            	,	CASE WHEN SBIV.S_SEQ = 1 THEN 'P' ELSE 'R' END	AS PRI_CD        /* PR구분코드*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* 배터리시리얼여부*/
	            , '' AS BATT_SER_NO   /* 배터리시리얼번호*/
	            , '' AS VIR_YN        /* 가상여부*/
	            , '' AS LOC_USE_DCD   /* 로케이션사용구분코드*/
	            , '' AS FST_STR_DT    /* 최초저장일자*/
	            , '' AS FST_STR_TM    /* 최초저장시각*/
	            , '' AS LST_STR_DT    /* 최종저장일자*/
	            , '' AS LST_STR_TM    /* 최종저장시각*/
	            , '' AS LST_SND_DT    /* 최종출고일자*/
	            , '' AS LST_SND_TM    /* 최종출고시각*/
	            , '4차 작업' AS MEMO          /* 메모*/
	            , 'DT088474M' AS FST_USR_ID    /* 최초사용자ID*/
	            , 'P'   AS FST_SYS_DCD   /* 최초시스템구분코드*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* 최초생성일시*/
	            , 'DT088474M' AS LST_UPD_ID    /* 최종수정자ID*/
	            , 'P' AS LST_SYS_DCD   /* 최종시스템구분코드*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* 최종수정일시*/
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
							UBIV.STK_CTL_QTY   -- 재고 통제 수량
							+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
							+ UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	LOC_STK_QTY   /* 로케이션재고수량*/
						,   (
							UBIV.STK_CTL_QTY   -- 재고 통제 수량
							+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
							)						AS	AVS_QTY       /* 가용재고수량*/
						,	(
							 UBIV.WS_NSND_QTY
							+ UBIV.WFLD_BDPC_DO_QTY
							+ UBIV.BFLD_BDPC_DO_QTY
							)						AS	WSND_QTY		/* 출고대기수량*/	
						,	ROW_NUMBER() OVER(PARTITION BY 	SUBSTRING(TRIM(UBIV.MLOC_NO), 1, 3) ,	UBIV.BRN_CD,	UBIV.WHS_CD ORDER BY UBIV.PTNO )	AS S_SEQ
					FROM	MBSASSTD.TBSIAUEIV	UBIV
					LEFT
					JOIN    MBSASSTD.TBSTAUDPM	UDPM
					ON      UDPM.PTNO 			=	UBIV.PTNO 
					WHERE 	1 = 1
					AND     (
							UBIV.STK_CTL_QTY   -- 재고 통제 수량
							+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
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


-- DB 반영 자료 4-1차 S --- 11671 (01.18)
--- 4번에서 작업한 새로 채번 된 LOC 에 대해 재고 테이블에 해당 부품 번호의 MLOC으로 UPDATE 한다. 

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
		AND     ULOC.MEMO 		= '4차 작업'
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


-- DB 반영 자료 5차 S --- 455 (01.18)
--- PRI_CD를 R로 UPDATE -------------------------------------------------------------------------------

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



-- DB 반영 자료 6차 S --- 0 (01.18) 
--- PRI_CD를 R로 UPDATE -------------------------------------------------------------------------------

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


-- DB 반영 자료 7차 S --- 7256 (01.18) 
--- EZA 'UUU' ZONE LOC 생성 -------------------------------------------------------------------------------
									
										
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
 
WITH 	AISLE_ARR AS ( /* 열에대한 입력 구간별 조회*/
                SELECT '00' AISLE_CHAR FROM	SYSIBM.SYSDUMMY1
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('99')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
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
            	, 	SBIV.LOC_STK_QTY   /* 로케이션재고수량*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY    /* 가용재고수량*/
            	, 	SBIV.WSND_QTY      /* 출고대기수량*/
            	,	'P'	AS PRI_CD        /* PR구분코드*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* 배터리시리얼여부*/
	            , '' AS BATT_SER_NO   /* 배터리시리얼번호*/
	            , '' AS VIR_YN        /* 가상여부*/
	            , '' AS LOC_USE_DCD   /* 로케이션사용구분코드*/
	            , '' AS FST_STR_DT    /* 최초저장일자*/
	            , '' AS FST_STR_TM    /* 최초저장시각*/
	            , '' AS LST_STR_DT    /* 최종저장일자*/
	            , '' AS LST_STR_TM    /* 최종저장시각*/
	            , '' AS LST_SND_DT    /* 최종출고일자*/
	            , '' AS LST_SND_TM    /* 최종출고시각*/
	            , '5차 작업' AS MEMO          /* 메모*/
	            , 'DT088474M' AS FST_USR_ID    /* 최초사용자ID*/
	            , 'P'   AS FST_SYS_DCD   /* 최초시스템구분코드*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* 최초생성일시*/
	            , 'DT088474M' AS LST_UPD_ID    /* 최종수정자ID*/
	            , 'P' AS LST_SYS_DCD   /* 최종시스템구분코드*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* 최종수정일시*/
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
							UBIV.GNRL_GDS_STK_QTY	-- 일반상품재고수량
						+	UBIV.KIT_GDS_STK_QTY	-- KIT상품재고수량
						+	UBIV.POI_GDS_STK_QTY	-- POI상품재고수량
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND할당수량
						+	UBIV.OUTB_OPIC_QTY		-- OUTBOUND피킹대기수량
							)						AS	LOC_STK_QTY   /* 로케이션재고수량*/
						,   (
							UBIV.GNRL_GDS_STK_QTY	-- 일반상품재고수량
						+	UBIV.KIT_GDS_STK_QTY	-- KIT상품재고수량
						+	UBIV.POI_GDS_STK_QTY	-- POI상품재고수량
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND할당수량
							)						AS	AVS_QTY       /* 가용재고수량*/
						,	UBIV.OUTB_OPIC_QTY		AS	WSND_QTY		/* 출고대기수량*/
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
	
	
-- DB 반영 자료 8차 S ---  61007 (01.18)
--- EZB 'SAS' ZONE LOC 생성 -------------------------------------------------------------------------------


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

WITH 	AISLE_ARR(AISLE_NUM, AISLE_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS AISLE_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS AISLE_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT AISLE_NUM + 1, LPAD(AISLE_NUM + 1,2,0)
                  FROM AISLE_ARR
                 WHERE AISLE_NUM < TO_NUMBER('10')
            )
            , SECTION_ARR(SECTION_NUM, SECTION_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS SECTION_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS SECTION_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT SECTION_NUM + 1, LPAD(SECTION_NUM + 1,2,0)
                  FROM SECTION_ARR
                 WHERE SECTION_NUM < TO_NUMBER('99')
            )
            , LEVEL_ARR(LEVEL_NUM, LEVEL_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
                SELECT TO_NUMBER('01') AS LEVEL_NUM
                     , LPAD(TO_NUMBER('01'),2,0) AS LEVEL_CHAR
                  FROM SYSIBM.SYSDUMMY1
                 UNION ALL
                SELECT LEVEL_NUM + 1, LPAD(LEVEL_NUM + 1,2,0)
                  FROM LEVEL_ARR
                 WHERE LEVEL_NUM < TO_NUMBER('99')
            )
            , POSITION_ARR AS ( SELECT 'A' POSITION_CHAR FROM	SYSIBM.SYSDUMMY1 )
--            , POSITION_ARR(POSITION_NUM, POSITION_CHAR) AS ( /* 열에대한 입력 구간별 조회*/
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
            	, 	SBIV.LOC_STK_QTY   /* 로케이션재고수량*/
           		, 	CASE WHEN SBIV.AVS_QTY < 0 THEN 0 ELSE SBIV.AVS_QTY END  AS AVS_QTY    /* 가용재고수량*/
            	, 	SBIV.WSND_QTY      /* 출고대기수량*/
            	,	'P'	AS PRI_CD        /* PR구분코드*/
            	,	NLDT.ZON_CD
            	,	NLDT.AIS
                ,	NLDT.SCN
                ,	NLDT.LVL
                ,	NLDT.POS
                ,	NLDT.LOC_NO	AS LOC_SNO
                , '' AS BATT_SER_YN   /* 배터리시리얼여부*/
	            , '' AS BATT_SER_NO   /* 배터리시리얼번호*/
	            , '' AS VIR_YN        /* 가상여부*/
	            , '' AS LOC_USE_DCD   /* 로케이션사용구분코드*/
	            , '' AS FST_STR_DT    /* 최초저장일자*/
	            , '' AS FST_STR_TM    /* 최초저장시각*/
	            , '' AS LST_STR_DT    /* 최종저장일자*/
	            , '' AS LST_STR_TM    /* 최종저장시각*/
	            , '' AS LST_SND_DT    /* 최종출고일자*/
	            , '' AS LST_SND_TM    /* 최종출고시각*/
	            , '6차 작업' AS MEMO          /* 메모*/
	            , 'DT088474M' AS FST_USR_ID    /* 최초사용자ID*/
	            , 'P'   AS FST_SYS_DCD   /* 최초시스템구분코드*/
	            , CURRENT_TIMESTAMP AS FST_CRT_DTM   /* 최초생성일시*/
	            , 'DT088474M' AS LST_UPD_ID    /* 최종수정자ID*/
	            , 'P' AS LST_SYS_DCD   /* 최종시스템구분코드*/
	            , CURRENT_TIMESTAMP AS LST_UPD_DTM   /* 최종수정일시*/
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
							UBIV.GNRL_GDS_STK_QTY	-- 일반상품재고수량
						+	UBIV.KIT_GDS_STK_QTY	-- KIT상품재고수량
						+	UBIV.POI_GDS_STK_QTY	-- POI상품재고수량
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND할당수량
						+	UBIV.OUTB_OPIC_QTY		-- OUTBOUND피킹대기수량
							)						AS	LOC_STK_QTY   /* 로케이션재고수량*/
						,   (
							UBIV.GNRL_GDS_STK_QTY	-- 일반상품재고수량
						+	UBIV.KIT_GDS_STK_QTY	-- KIT상품재고수량
						+	UBIV.POI_GDS_STK_QTY	-- POI상품재고수량
						+	UBIV.OUTB_ALLO_QTY		-- OUTBOUND할당수량
							)						AS	AVS_QTY       /* 가용재고수량*/
						,	UBIV.OUTB_OPIC_QTY		AS	WSND_QTY		/* 출고대기수량*/
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
--							UBIV.STK_CTL_QTY   -- 재고 통제 수량
--							+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
--							+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
--							+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
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
	
	
-- DB 반영 자료 9차 S --- 1280623 (01.18) 
--- SCR 거점 품목별 재고 정보 해당 품목 PRI LOC에 UPDATE  -------------------------------------------------------------------------------	
	
	
MERGE 
INTO	MBSASSTD.TBSLAULOC	ULOC 
USING	(
			SELECT  UBIV.MLOC_NO
				,	UBIV.BRN_CD
				,	UBIV.WHS_CD 
				,	UBIV.PTNO 
				,   (
					UBIV.STK_CTL_QTY   -- 재고 통제 수량
					+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
					+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
					+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
					+ UBIV.WS_NSND_QTY
					+ UBIV.WFLD_BDPC_DO_QTY
					+ UBIV.BFLD_BDPC_DO_QTY
					)						AS	LOC_STK_QTY   /* 로케이션재고수량*/
				,   (
					UBIV.STK_CTL_QTY   -- 재고 통제 수량
					+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
					+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
					+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
					)						AS	AVS_QTY       /* 가용재고수량*/
				,	(
					 UBIV.WS_NSND_QTY
					+ UBIV.WFLD_BDPC_DO_QTY
					+ UBIV.BFLD_BDPC_DO_QTY
					)						AS	WSND_QTY		/* 출고대기수량*/
			FROM	MBSASSTD.TBSIAUBIV	UBIV
			JOIN	MBSASSTD.TBSIAUBMT	UBMT
			ON		UBIV.BRN_CD	=	UBMT.BRN_CD 
			WHERE 	1 = 1
			AND     UBMT.BRN_FUNC_DCD IN ('S', 'C', 'R')
			--AND     UBMT.BRN_CD != 'CCB'
			AND     (
					UBIV.STK_CTL_QTY   -- 재고 통제 수량
					+ UBIV.GNRL_GDS_STK_QTY	-- 일반 상품 재고 수량
					+ UBIV.KIT_GDS_STK_QTY	-- KIT 상품 재고 수량
					+ UBIV.POI_GDS_STK_QTY	-- POI 상품 재고 수량
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
	

-- DB 반영 자료 10차 S --- 43285 (01.18)  
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
		
-- DB 반영 자료 11차 S --- 4546(12.18) 3S
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