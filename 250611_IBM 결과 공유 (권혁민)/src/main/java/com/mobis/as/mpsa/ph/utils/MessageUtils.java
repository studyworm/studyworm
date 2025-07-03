package com.mobis.as.mpsa.ph.utils;
public class MessageUtils {
    public static String fnccmm200q(String code, String lang) {
        if (code == null || lang == null) return null;

        // 예제용 메시지 매핑
        if (code.equals("E101")) {
            if (lang.equalsIgnoreCase("ENG")) return "Invalid customer ID";
            if (lang.equalsIgnoreCase("KOR")) return "고객 ID가 잘못되었습니다";
        }

        return "Unknown message";
    }
}