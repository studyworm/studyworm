package com.mobis.as.mpsa.ph.domain;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Cbcuzw011rDTO {

    // LINKAGE SECTION fields
    private String lnkArea;
    private String ln2Area;
    private PfcuzlogRow pfcuzlogRow;
    // Assuming LOG-AREA and LO2-AREA are part of the linkage section or working storage
    // and are represented by lnkArea and ln2Area respectively

    // Static inner class for PFCUZLOG-ROW
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PfcuzlogRow {
        // Fields from PFCUZLOG copybook
        // Example fields, actual fields should be derived from PFCUZLOG copybook
        private String logDat;
        private String logPdc;
        private String logPgm;
        private String logUsr;
        private String logSeq;
        private Integer logSe2;
        private String logStm;
        private String logRtc;
        private String logSql;
        private String logMsg;
        private String logMcd;
        private String logMtx;

        // Other fields as defined in PFCUZLOG
    }

}