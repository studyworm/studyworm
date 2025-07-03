package com.mobis.as.mpsa.ph.domain;

import java.math.BigDecimal;

import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO.P3Parm;
import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO.P6Parm;
import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO.PfcicpoiRow;
import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO.PfcpHarmRow;
import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO.PfcpHocfRow;
import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO.SamfileRedf;
import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO.WorkArea1;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Cbcphb710aDTO {

    // WORK-AREA
    private String dtPdc;
    private String dtDateTime;
    private String wtPdc;
    private Integer wErrCnt;
    private Integer wReadCnt;
    private Integer wInsCnt;
    private Integer wKeySeq;
    private WorkArea workArea;

    @Data
    public static class WorkArea {
        private String Dt;
        private String Date;
        private String Mbr;
        private String Fle;
        private String Lib;
    }

    // HOST-DATA-AREA
    private String fileStatus;
    private String wCmpKnd;

    // SAMFILE-DATA and SAMFILE-REDF
    private String samfileData;
    private SamfileRedf samfileRedf;

    @Data
    public static class SamfileRedf {
        /**
         * Order Number(Refer to Attach#1)
         */
        private String samOrdNo;

        /**
         * Proforma Invoice Number
         */
        private String samPrfmNo;

        /**
         * Confirm Date
         */
        private String samCfmDt;

        /**
         * Total Amount
         */
        private BigDecimal samTotAmt;

        /**
         * Total Pieces
         */
        private Integer samTqt;

        /**
         * Total Items
         */
        private Integer samTotItm;

        /**
         * Total Volume
         */
        private Integer samTotVol;

        /**
         * Total Weight
         */
        private Integer samTotWg;

        /**
         * Line Item Number
         */
        private String samOrdLn;

        /**
         * Line Item Number Suffix
         */
        private String samOrdSf;

        /**
         * Confirm Part Nmber
         */
        private String samCfmPno;

        /**
         * Part Name
         */
        private String samCfmPnm;

        /**
         * Normal Quantity about OK Item when Co
         */
        private Integer samNorQt;

        /**
         * Abnormal Quantity about Error Item wh
         */
        private Integer samAbnQt;

        /**
         * Unit Price
         */
        private BigDecimal samUpri;

        /**
         * Amend Code(Refer to Attach#2)
         */
        private String samAmdCd;

        /**
         * Ordered Part Number
         */
        private String samOrdPno;

        /**
         * Estimated Time of Departure(VOR Only)
         */
        private String samEtd;

        /**
         * Intermediary Trade
         */
        private String samItmdTrd;
    }

    // LINKAGE SECTION
    private String p2Dt;
    private String p2Lib;
    private String p2Fle;
    private String p2Mbr;

    public void incrementW_insCnt() {
        this.wInsCnt = (this.wInsCnt == null) ? 1 : this.wInsCnt + 1;
    }

    public void incrementW_errCnt() {
        this.wErrCnt = (this.wErrCnt == null) ? 1 : this.wErrCnt + 1;
    }
}