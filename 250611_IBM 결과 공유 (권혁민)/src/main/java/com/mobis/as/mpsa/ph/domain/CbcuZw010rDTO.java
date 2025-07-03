package com.mobis.as.mpsa.ph.domain;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CbcuZw010rDTO {

    // LINKAGE SECTION
    private String lnkArea;

    // Assuming LOG-AREA is defined in PFCUZLOG copybook
    private PfcuzlogRow pfcuzlogRow;

    // Inner static class for PfcuzlogRow
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PfcuzlogRow {
        // Fields as per PFCUZLOG copybook
        // Example fields based on common logging information
        private String logDat;
        private String logPdc;
        private String logPgm;
        private String logUsr;
        private Integer logSeq;
        private String logStm;
        private String logEtm;
        private String logRtc;
        private String logSql;
        private String logMsg;
        private String logIp;

        // Add other fields as defined in PFCUZLOG copybook
    }

    // Adding the missing inner classes
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class P9NbrKy1 {
        private String p9NbrKy1;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class P9NbrKy2 {
        private String p9NbrKy2;
    }
}