package com.mobis.as.mpsa.ph.domain;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Cbcphb780aDTO {

    private PfcicpoiRow pfcicpoiRow;
    private PfcpHarmRow pfcpHarmRow;
    private PfcpHocfRow pfcpHocfRow;
    private String p1Rtnmsg;
    private String poiCxlFlg;
    private String poiCxlTyp;
    private String poiPoCfmCd;
    private String wSysDate;
    private String wLogusr;
    private String wSysHms;
    private String poiPoiNo;
    private String p1Rtncd;
    private String w2Logmcd;
    private String w2Logmsg;

    @Data
    public static class PfcpHocfRow {
        private String ocfOrdNo;       
        private String ocfPrfmNo;      
        private String ocfCfmDt;       
        private BigDecimal ocfTotAmt;  
        private BigDecimal ocfTqt;     
        private Integer ocfTotItm;     
        private Integer ocfTotVol;    
        private Integer ocfTotWg;     
        private String ocfOrdLn;      
        private String ocfOrdSf;       
        private String ocfOrdOsf;     
        private String ocfCfmPno;     
        private String ocfCfmPnm;     
        private Integer ocfNorQt;     
        private Integer ocfAbnQt;     
        private BigDecimal ocfUpri;    
        private String ocfAmdCd;       
        private String ocfOrdPno;      
        private String ocfEtd;         
        private String ocfItmdTrd;     
        private String ocfSerNo;       
        private String ocfJobDt;       
        private String ocfJobMbr;     
        private String ocfJobFle;     
        private String ocfJobLib;     
        private String ocfCfmCmp;     
        private String ocfSndYn;     
    }

    @Data
    public static class PfcicpoiRow {
        private String poiCmpKnd;
        private String poiPno;
        private String poiPoCplDt;
        private String poiPoDtlPrc;
        private Integer poiFstPoQt;
        private String poiFstCmpKnd;
        private String poiFstPno;
        private String poiUpdDt;
        private String poiUpdUsr;
        private String poiUpdTim;
        private String poiCxlFlg;
        private String poiCxlTyp;
        private String poiPoCfmCd;
        private String poiPoiNo;
        private String poiDateTime;
        private String poiIpdc;
        private String poiPdc;
        private Integer poiOordQt;
    }

    @Data
    public static class PfcpHarmRow {
        private String armIpdc;
        private String armAtpNo;
        private String armAtpLn;
        private String armDueDt;
        private Integer armDueQt;
        private String armAtpDt;
        private Integer armAtpQt;
        private Integer armObeyQt;
        private String armPoiNo;
        private String armInsDt;
        private String armInsTim;
        private String armInsUsr;
        private String armUpdDt;
        private String armUpdTim;
        private String armUpdUsr;
    }

    // PFCICINV-ROW
    @Data
    public static class PfcicinvRow {
        // Define fields as per the database table or PfcicinvRow structure
        private String invCmpKnd;
        private String invPno;
        private String invPdc;
        private String invIpdc;
        // Add other fields as necessary
    }

    // WORK-AREA1
    @Data
    public static class WorkArea1 {
        private String poiReadFlag;
        private String endSw;
        private String errSw;
        private String rtnmsg;
        private String dtPdc;
        private String dtDateTime;
        private String fileStatus;
        private String wCmpKnd;
        private Integer wErrCnt;
        private Integer wReadCnt;
        private WkParm wkParm;
        private String wtDate;
        private String wtMbr;
        private String wtFle;
        private String wtLib;
        private Integer wrFstPoQt;
        private String wrFstCmpKnd;
        private String wrFstPno;
        private String wrPnoChgSw;
        private String wrPoiNo;
        private String w2Logrtc;
        private String w2Logsql;
        private String w2Logmsg;
        private String wLogtm;
    }

    // WK-PARM
    @Data
    public static class WkParm {
        private String wkParm1;
        private String wkParm2;
        private String wkParm3;
        private String wkParm4;
    }

    // P3-PARM
    @Data
    public static class P3Parm {
        private String p3Proc;
        private String p3PoiNo;
        private String p3RefOrdNo;
        private String p3RefOrdLn;
        private String p3RefOrdSf;
        private String p3CmpKnd;
        private String p3Pno;
        private BigDecimal p3PordQt;
        private BigDecimal p3PoPri;
        private String p3OPoiNo;
        private String p3OrdSf;
        private String p3Ipdc;
        private String p3Pdc;
    }

    @Data
    public static class P9Parm {
        private String p9Ipdc;
        private String p9Pdc;
        private String p9CmpKnd;
        private String p9Pno;
    }

    private WorkArea1 workArea1;
    private P3Parm p3Parm;
    private P6Parm p6Parm;
    private SamfileRedf samfileRedf;

    // P5-PROC-TYP
    private String p5ProcTyp;

    // P5-DATE
    private String p5Date;

    // P5-POI-NO
    private String p5PoiNo;

    // P5-CXL-TYP
    private String p5CxlTyp;

    // P5-QTY-TYP
    private String p5QtyTyp;

    // P5-PRC-QTY
    private BigDecimal p5PrcQty;

    // P5-PO-PRI
    private BigDecimal p5PoPri;

    // SAMFILE-DATA and SAMFILE-REDF
    private String samfileData;
    @Data
    public static class SamfileRedf {
        private String samOrdNo;
        private String samPrfmNo;
        private String samCfmDt;
        private BigDecimal samTotAmt;
        private BigDecimal samTqt;
        private Integer samTotItm;
        private Integer samTotVol;
        private Integer samTotWg;
        private String samOrdLn;
        private String samOrdSf;
        private String samOrdOsf;
        private String samCfmPno;
        private String samCfmPnm;
        private Integer samNorQt;
        private Integer samAbnQt;
        private BigDecimal samUpri;
        private String samAmdCd;
        private String samOrdPno;
        private String samEtd;
        private String samItmdTrd;
        private String samCfmCmp;
    }

    // P6-PARM
    @Data
    public static class P6Parm {
        private String p6Comm;
        private String p6JobDt;
        private String p6Prcs;
        private String p6Cpdc;
        private String p6PoiNo;
    }

    // P9-IPDC
    private String p9Ipdc;

    // P9-PDC
    private String p9Pdc;

    // P9-CMP-KND
    private String p9CmpKnd;

    // P9-PNO
    private String p9Pno;

    // LINKAGE SECTION
    private String p2Date;
    private String p2Lib;
    private String p2Fle;
    private String p2Mbr;
}