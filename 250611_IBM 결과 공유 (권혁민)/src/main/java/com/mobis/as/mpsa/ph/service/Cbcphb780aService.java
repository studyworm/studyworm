package com.mobis.as.mpsa.ph.service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO;
import com.mobis.as.mpsa.ph.repository.Cbcphb780aRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class Cbcphb780aService {

    private final Cbcphb780aRepository cbcphb780aRepository;

    public void execute(Cbcphb780aDTO dto) {
        initProcess(dto);
        mainProcess(dto);
        normalEnd(dto);
    }

    public void initProcess(Cbcphb780aDTO dto) {
        dto.getWorkArea1().setErrSw("0");
        dto.getWorkArea1().setWErrCnt(0);
        dto.getWorkArea1().setWReadCnt(0);

        dateTimeRtn(dto);

        dto.getWorkArea1().setWtDate(dto.getP2Date());
        dto.getWorkArea1().setWtLib(dto.getP2Lib());
        dto.getWorkArea1().setWtFle(dto.getP2Fle());
        dto.getWorkArea1().setWtMbr(dto.getP2Mbr());

        // CALL "CBCUZW010R" USING LOG-AREA
        // TODO: CALL CBCUZW010R
    }

    private void dateTimeRtn(Cbcphb780aDTO dto) {
        try {
            Cbcphb780aDTO.PfcicpoiRow row = cbcphb780aRepository.selectPfcicpoiByRefOrd(dto);
            if (row != null) {
                dto.getWorkArea1().setDtDateTime(row.getPoiDateTime());
            } else {
                String dtDateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
                dto.getWorkArea1().setDtDateTime(dtDateTime);
                String wSysDate = dtDateTime.substring(0, 8);
                String wSysTime = dtDateTime.substring(8);
                dto.getWorkArea1().setWtDate(wSysDate);
                // Other assignments as needed
            }
        } catch (Exception e) {
            log.error("Error in S0100-DATE-TIME-RTN: {}", e.getMessage());
        }
    }

    public void mainProcess(Cbcphb780aDTO dto) {
        dto.getWorkArea1().setWCmpKnd(dto.getP2Fle().substring(2, 3));
        dto.getWorkArea1().setWtDate(dto.getP2Date());
        dto.getWorkArea1().setWtMbr(dto.getP2Mbr());
        dto.getWorkArea1().setWtFle(dto.getP2Fle());
        dto.getWorkArea1().setWtLib(dto.getP2Lib());

        List<Cbcphb780aDTO.PfcpHocfRow> pfcpHocfRows = fetchOcfRecords(dto);
        for (Cbcphb780aDTO.PfcpHocfRow record : pfcpHocfRows) {
            dto.setPfcpHocfRow(record);
            ocfMain(dto);
            dto.getWorkArea1().setWReadCnt(dto.getWorkArea1().getWReadCnt() + 1);
        }
    }

    private void ocfMain(Cbcphb780aDTO dto) {
        dto.getWorkArea1().setPoiReadFlag(" ");
        moveOcfData(dto);
        dto.getWorkArea1().setErrSw(" ");
        dataCheck(dto);
        if (dto.getWorkArea1().getErrSw().equals(" ")) {
            processOcf(dto);
        }
    }

    private void processOcf(Cbcphb780aDTO dto) {
        dto.getWorkArea1().setWrPoiNo(dto.getP5PoiNo());
        dto.getWorkArea1().setWrPnoChgSw(" ");
        if (dto.getSamfileRedf().getSamNorQt() == 0) {
            cancelPo(dto);
        } else if (dto.getSamfileRedf().getSamOrdSf().compareTo(" ") > 0 && dto.getWorkArea1().getPoiReadFlag().equals("N")) {
            insertPo(dto);
        } else {
            updatePo(dto);
        }
        if (dto.getWorkArea1().getErrSw().equals(" ")) {
            updateOcf(dto);
            try {
                // TODO: cbcphb780aRepository.commit
            } catch (Exception e) {
                log.error("Error committing work: {}", e.getMessage());
            }
        }
    }

    private void moveOcfData(Cbcphb780aDTO dto) {
        Cbcphb780aDTO.SamfileRedf samfileRedf = dto.getSamfileRedf();
        samfileRedf.setSamOrdNo(dto.getWorkArea1().getWkParm().getWkParm1());
        samfileRedf.setSamPrfmNo(dto.getP3Parm().getP3RefOrdNo());
        samfileRedf.setSamCfmDt(dto.getP5Date());
        samfileRedf.setSamTotAmt(dto.getP5PrcQty());
        samfileRedf.setSamTqt(dto.getP5PrcQty());
        samfileRedf.setSamTotItm(dto.getWorkArea1().getWrFstPoQt());
        samfileRedf.setSamTotVol(dto.getWorkArea1().getWrFstPoQt());
        samfileRedf.setSamTotWg(dto.getWorkArea1().getWrFstPoQt());
        samfileRedf.setSamOrdLn(dto.getP3Parm().getP3RefOrdLn());
        samfileRedf.setSamOrdSf(dto.getP3Parm().getP3OrdSf());
        samfileRedf.setSamOrdOsf(dto.getP3Parm().getP3OrdSf());
        samfileRedf.setSamCfmPno(dto.getP9Pno());
        samfileRedf.setSamCfmPnm("");
        samfileRedf.setSamNorQt(0);
        samfileRedf.setSamAbnQt(0);
        samfileRedf.setSamUpri(dto.getP5PoPri());
        samfileRedf.setSamAmdCd("");
        samfileRedf.setSamOrdPno(dto.getP9Pno());
        samfileRedf.setSamEtd("");
        samfileRedf.setSamItmdTrd("");
    }

    private List<Cbcphb780aDTO.PfcpHocfRow> fetchOcfRecords(Cbcphb780aDTO dto) {
        List<Cbcphb780aDTO.PfcpHocfRow> pfcpHocfRows = new ArrayList<>();
        try {
            pfcpHocfRows = cbcphb780aRepository.selectPfcpHocf(dto);
        } catch (Exception e) {
            log.error("Error in S2900-OCF-FETCH-RTN: {}", e.getMessage());
        }
        return pfcpHocfRows;
    }

    private void dataCheck(Cbcphb780aDTO dto) {
        if (dto.getSamfileRedf().getSamOrdSf().equals(" ")) {
            fetchPoi(dto);
        } else {
            fetchPoi2(dto);
        }

        if (!dto.getWorkArea1().getPoiReadFlag().equals("N")) {
            if (dto.getSamfileRedf().getSamNorQt() == 0) {
                Cbcphb780aDTO.PfcicpoiRow pfcicpoiRow = cbcphb780aRepository.selectPfcicpoiByRefOrd(dto);
                if (pfcicpoiRow != null && (pfcicpoiRow.getPoiPoDtlPrc().equals("F") || pfcicpoiRow.getPoiPoDtlPrc().equals("D"))) {
                    dto.getWorkArea1().setErrSw("E");
                    String logMsg = "ERR)PFCICPOI:3100     FINSHED DATA | " + dto.getSamfileRedf().getSamOrdNo() + dto.getSamfileRedf().getSamOrdLn() + dto.getSamfileRedf().getSamOrdSf() + dto.getSamfileRedf().getSamCfmPno();
                    log.error(logMsg);
                }
            }
        }
    }

    private void fetchPoi(Cbcphb780aDTO dto) {
        Cbcphb780aDTO.PfcicpoiRow pfcicpoiRow = cbcphb780aRepository.selectPfcicpoiByRefOrd(dto);
    }

    private void fetchPoi2(Cbcphb780aDTO dto) {
    }

    private void cancelPo(Cbcphb780aDTO dto) {
        dto.setP5ProcTyp("D");
        dto.setP5Date(dto.getWorkArea1().getWtDate());
        dto.setP5PoiNo(dto.getWorkArea1().getWrPoiNo());
        dto.setP5CxlTyp("CM");
        dto.setP5QtyTyp("P");
        dto.setP5PrcQty(BigDecimal.ZERO);
        dto.setP5PoPri(dto.getSamfileRedf().getSamUpri());

        // TODO: CALL CBCICB077A

        dto.getWorkArea1().setRtnmsg(dto.getP1Rtnmsg());
        if ("N".equals(dto.getP1Rtncd())) {
            dto.getWorkArea1().setErrSw("E");
            return;
        }

        try {
            Cbcphb780aDTO updateDto = Cbcphb780aDTO.builder()
                    .poiCxlFlg("C")
                    .poiCxlTyp("CC")
                    .poiPoCfmCd("C")
                    .samAmdCd(dto.getSamfileRedf().getSamAmdCd())
                    .samEtd(dto.getSamfileRedf().getSamEtd())
                    .wSysDate(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")))
                    .wLogusr("your_log_user") // Replace with actual log user
                    .wSysHms(LocalTime.now().format(DateTimeFormatter.ofPattern("HHmmss")))
                    .poiPoiNo(dto.getP5PoiNo())
                    .build();
            int updateCount = cbcphb780aRepository.updatePfcicpoi(updateDto);
            if (updateCount == 0) {
                // Handle update failure
            }
        } catch (Exception e) {
            log.error("Error updating PFCICPOI: {}", e.getMessage());
            dto.getWorkArea1().setErrSw("E");
            return;
        }

        if (" ".equals(dto.getWorkArea1().getWrPnoChgSw())) {
            deleteArm(dto);
        }
    }

    private void updatePo(Cbcphb780aDTO dto) {
        if (!dto.getOcfCfmCmp().equals(dto.getPoiCmpKnd()) || !dto.getOcfCfmPno().equals(dto.getPoiPno())) {
            dto.getWorkArea1().setWrPnoChgSw("Y");
            cancelPo(dto);
            if (!dto.getWorkArea1().getErrSw().isEmpty()) {
                dto.getWorkArea1().setErrSw("");
            }
        }

        try {
            dto.getPfcicpoiRow().setPoiCmpKnd(dto.getOcfCfmCmp());
            dto.getPfcicpoiRow().setPoiPno(dto.getOcfCfmPno());
            dto.getPfcicpoiRow().setPoiPoCplDt("");
            dto.getPfcicpoiRow().setPoiPoDtlPrc("5");
            dto.getPfcicpoiRow().setPoiFstPoQt(dto.getWorkArea1().getWrFstPoQt());
            dto.getPfcicpoiRow().setPoiFstCmpKnd(dto.getPoiCmpKnd());
            dto.getPfcicpoiRow().setPoiFstPno(dto.getPoiPno());
            dto.getPfcicpoiRow().setPoiUpdDt(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
            dto.getPfcicpoiRow().setPoiUpdUsr("CBCPHB780A");
            dto.getPfcicpoiRow().setPoiUpdTim(LocalTime.now().format(DateTimeFormatter.ofPattern("HHmmss")));
            cbcphb780aRepository.updatePfcicpoi(dto);
        } catch (Exception e) {
            log.error("Error updating PFCICPOI: {}", e.getMessage());
        }

        try {
            Cbcphb780aDTO.PfcicpoiRow pfcicpoiRow = cbcphb780aRepository.selectPfcicpoiByPoiNo(dto);
            dto.setPfcicpoiRow(pfcicpoiRow);
        } catch (Exception e) {
            log.error("Error selecting PFCICPOI: {}", e.getMessage());
        }

        try {
            Cbcphb780aDTO.PfcicinvRow pfcicinvRow = cbcphb780aRepository.selectPfcicinv(dto);
            dto.setPfcicinvRow(pfcicinvRow);
        } catch (Exception e) {
            log.error("Error selecting PFCICINV: {}", e.getMessage());
        }

        if (dto.getPfcicinvRow() == null) {
            dto.getP9Parm().setP9Ipdc(dto.getPoiIpdc());
            dto.getP9Parm().setP9Pdc(dto.getPoiPdc());
            dto.getP9Parm().setP9CmpKnd(dto.getOcfCfmCmp());
            dto.getP9Parm().setP9Pno(dto.getOcfCfmPno());
            // TODO: CALL CBCICB075A
            if (false) { // assuming P1-RTNCD is "Y"
                dto.getWorkArea1().setRtnmsg("Success");
            } else {
                StringBuilder logMsg = new StringBuilder();
                logMsg.append(String.format("%-20s", "S3100-ORD-CHK"));
                logMsg.append(String.format("%-20s", "Inventory Not Found"));
                logMsg.append(String.format("%-3s", dto.getPoiPdc()));
                logMsg.append(String.format("%-1s", dto.getOcfCfmCmp()));
                logMsg.append(String.format("%-20s", dto.getOcfCfmPno()));

                dto.getWorkArea1().setW2Logmsg(logMsg.toString());
                dto.getW2Logmcd().setW2Logmcd("20046");
                int sqlCode = 0; // Replace with actual SQL code if available
                dto.getWorkArea1().setW2Logsql(String.valueOf(sqlCode));
                errorWrite(dto);
                return;
            }
        }
    }

    private void updatePo2(Cbcphb780aDTO dto) {
        if ("D".equals(dto.getSamfileRedf().getSamItmdTrd()) || "F".equals(dto.getSamfileRedf().getSamItmdTrd())) {
            Cbcphb780aDTO.PfcicpoiRow pfcicpoiRow = cbcphb780aRepository.selectPfcicpoiByPoiNo(dto);
            if (pfcicpoiRow != null && !"5".equals(pfcicpoiRow.getPoiPoDtlPrc())) {
                dto.getWorkArea1().setWrPoiNo(dto.getSamfileRedf().getSamOrdNo());
                cbcphb780aRepository.updatePfcicpoi(dto);
            }
        }

        dto.setP5ProcTyp("C");
        dto.setP5Date(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        dto.setP5PoiNo(dto.getSamfileRedf().getSamOrdNo());
        dto.setP5CxlTyp(" ");
        dto.setP5QtyTyp("P");
        dto.setP5PrcQty(BigDecimal.valueOf(dto.getSamfileRedf().getSamNorQt()));
        dto.setP5PoPri(dto.getSamfileRedf().getSamUpri());

        // TODO: CALL CBCICB077A

        if ("N".equals(dto.getP1Rtncd())) {
            dto.getWorkArea1().setErrSw("E");
            return;
        }

        Cbcphb780aDTO.PfcicpoiRow pfcicpoiRow = cbcphb780aRepository.selectPfcicpoiByPoiNo(dto);
        if (pfcicpoiRow == null) {
            log.error("Error fetching PFCICPOI data");
            dto.getWorkArea1().setErrSw("E");
            return;
        }

        if (pfcicpoiRow.getPoiOordQt().equals(dto.getSamfileRedf().getSamAbnQt())) {
            dto.setPoiCxlFlg("C");
        } else {
            dto.setPoiCxlFlg("M");
        }

        try {
            cbcphb780aRepository.updatePfcicpoi(dto);
        } catch (Exception e) {
            log.error("Error updating PFCICPOI data");
            dto.getWorkArea1().setErrSw("E");
        }
    }

    private void insertPo(Cbcphb780aDTO dto) {
        dto.getWorkArea1().setWrFstPoQt(dto.getSamfileRedf().getSamNorQt());
        dto.getWorkArea1().setWrFstCmpKnd(dto.getSamfileRedf().getSamCfmCmp());
        dto.getWorkArea1().setWrFstPno(dto.getSamfileRedf().getSamCfmPno());

        Cbcphb780aDTO.P3Parm p3Parm = new Cbcphb780aDTO.P3Parm();
        p3Parm.setP3Proc("A");
        p3Parm.setP3RefOrdNo(dto.getSamfileRedf().getSamOrdNo());
        p3Parm.setP3RefOrdLn(dto.getSamfileRedf().getSamOrdLn());
        p3Parm.setP3RefOrdSf(dto.getSamfileRedf().getSamOrdSf());
        p3Parm.setP3CmpKnd(dto.getSamfileRedf().getSamCfmCmp());
        p3Parm.setP3Pno(dto.getSamfileRedf().getSamCfmPno());
        p3Parm.setP3PordQt(dto.getSamfileRedf().getSamNorQt());
        p3Parm.setP3PoPri(dto.getSamfileRedf().getSamUpri());
        dto.setP3Parm(p3Parm);

        // TODO: CALL CBCICB102A
        if (dto.getWorkArea1().getRtnmsg().equals("N")) {
            dto.getWorkArea1().setErrSw("E");
            return;
        }

        Cbcphb780aDTO.PfcicpoiRow pfcicpoiRow = cbcphb780aRepository.selectPfcicpoiByPoiNo(dto);
        if (pfcicpoiRow == null) {
            log.error("ERR)PFCICPOI: 4300-1  INSERT ERR|| {} {} {} {}", dto.getP3Parm().getP3OPoiNo(), dto.getSamfileRedf().getSamOrdNo(), dto.getSamfileRedf().getSamOrdLn(), dto.getSamfileRedf().getSamOrdSf());
            dto.getWorkArea1().setErrSw("E");
            return;
        }

        if (pfcicpoiRow.getPoiOordQt().equals(dto.getSamfileRedf().getSamAbnQt())) {
            pfcicpoiRow.setPoiCxlFlg("C");
        } else {
            pfcicpoiRow.setPoiCxlFlg("M");
        }

        pfcicpoiRow.setPoiFstPoQt(dto.getWorkArea1().getWrFstPoQt());
        pfcicpoiRow.setPoiFstCmpKnd(dto.getWorkArea1().getWrFstCmpKnd());
        pfcicpoiRow.setPoiFstPno(dto.getWorkArea1().getWrFstPno());

        dto.setPfcicpoiRow(pfcicpoiRow);
        int updateCount = cbcphb780aRepository.updatePfcicpoi(dto);
        if (updateCount == 0) {
            log.error("ERR)PFCICPOI: 4300-2 UPDATE ERROR  {} {} {}", dto.getSamfileRedf().getSamOrdNo(), dto.getSamfileRedf().getSamOrdLn(), dto.getSamfileRedf().getSamOrdSf());
            dto.getWorkArea1().setErrSw("E");
            return;
        }

        Cbcphb780aDTO.P6Parm p6Parm = new Cbcphb780aDTO.P6Parm();
        p6Parm.setP6PoiNo(pfcicpoiRow.getPoiPoiNo());
        dto.setP6Parm(p6Parm);

        insertArm(dto);
    }

    private void updateOcf(Cbcphb780aDTO dto) {
        try {
            cbcphb780aRepository.updatePfcpHocf(dto);
            if (cbcphb780aRepository.updatePfcpHocf(dto) == 0) {
                // Handle update failure if needed
            }
        } catch (Exception e) {
            dto.getWorkArea1().setErrSw("N");
            dto.getWorkArea1().setWErrCnt(dto.getWorkArea1().getWErrCnt() + 1);
            log.error("ERR)PFCPHOCF: 7600 UPDATE ERROR {} {} {} {}", dto.getSamfileRedf().getSamOrdNo(), dto.getSamfileRedf().getSamPrfmNo(), dto.getSamfileRedf().getSamCfmDt(), dto.getSamfileRedf().getSamOrdLn());
        }
    }

    private void insertArm(Cbcphb780aDTO dto) {
        // Initialize WK-PARM
        dto.getWorkArea1().getWkParm().setWkParm1("ARM_ATP_SEQ");
        dto.getWorkArea1().getWkParm().setWkParm2(dto.getP9Ipdc().substring(0, 3) + dto.getWorkArea1().getWtDate().substring(0, 6));
        dto.getWorkArea1().getWkParm().setWkParm3("06");
        // TODO: CALL CBCUZW030R
        // Initialize PFCPHARM-ROW
        Cbcphb780aDTO.PfcpHarmRow pfcpHarmRow = new Cbcphb780aDTO.PfcpHarmRow();
        pfcpHarmRow.setArmIpdc(dto.getP9Ipdc());
        pfcpHarmRow.setArmAtpNo(dto.getP9Ipdc().substring(0, 3) + dto.getWorkArea1().getWtDate().substring(0, 6) + dto.getWorkArea1().getWkParm().getWkParm4().substring(0, 6));
        pfcpHarmRow.setArmAtpLn("01");
        pfcpHarmRow.setArmDueDt(dto.getSamfileRedf().getSamEtd());
        pfcpHarmRow.setArmDueQt(dto.getSamfileRedf().getSamNorQt());
        pfcpHarmRow.setArmAtpDt(dto.getSamfileRedf().getSamCfmDt());
        pfcpHarmRow.setArmAtpQt(dto.getSamfileRedf().getSamNorQt());
        pfcpHarmRow.setArmObeyQt(0);
        pfcpHarmRow.setArmPoiNo(dto.getP5PoiNo());
        pfcpHarmRow.setArmInsDt(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        pfcpHarmRow.setArmInsTim(LocalTime.now().format(DateTimeFormatter.ofPattern("HHmmss")));
        pfcpHarmRow.setArmInsUsr(dto.getWorkArea1().getWtMbr());
        pfcpHarmRow.setArmUpdDt(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        pfcpHarmRow.setArmUpdTim(LocalTime.now().format(DateTimeFormatter.ofPattern("HHmmss")));
        pfcpHarmRow.setArmUpdUsr(dto.getWorkArea1().getWtMbr());
        try {
            cbcphb780aRepository.insertPfcpHarm(pfcpHarmRow);
        } catch (Exception e) {
            if (e.getMessage().contains("-803")) {
                log.error("ERR)PFCPHARM: 4700 DUPLI ERROR {}", pfcpHarmRow.getArmAtpNo());
            } else {
                log.error("ERR)PFCPHARM: 4700 INSERT ERROR {}", pfcpHarmRow.getArmAtpNo());
            }
        }
    }

    private void deleteArm(Cbcphb780aDTO dto) {
        try {
            cbcphb780aRepository.deletePfcpHarm(dto);
            if (cbcphb780aRepository.deletePfcpHarm(dto) == 0) {
                // No action for SQLCODE = 0 or 100
            } else {
                // Handle other SQLCODE values
                dto.getWorkArea1().setW2Logrtc(" ");
                dto.getWorkArea1().setW2Logsql(String.valueOf(100)); // Assuming 100 is the SQLCODE
                dto.getWorkArea1().setW2Logmsg("ERR)PFCPHARM:DELETE ERROR     " + dto.getP5PoiNo());
                errorWrite(dto);
            }
        } catch (Exception e) {
            // Handle exception
            log.error("Error in S4750-ARM-DELETE-RTN: {}", e.getMessage());
        }
    }

    private void errorWrite(Cbcphb780aDTO dto) {
        // Implement error writing logic here
        log.error(dto.getWorkArea1().getW2Logmsg());
    }

    public void normalEnd(Cbcphb780aDTO dto) {
        try {
            dateTimeRtn(dto);
            String currentTime = dto.getWorkArea1().getDtDateTime().substring(8, 16);
            dto.getWorkArea1().setWLogtm(currentTime);
            dto.getWorkArea1().setRtnmsg("");
        } catch (Exception e) {
            log.error("Error during normal end: {}", e.getMessage());
        }
    }
}