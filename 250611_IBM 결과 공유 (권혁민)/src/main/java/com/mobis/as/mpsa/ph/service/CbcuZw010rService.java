package com.mobis.as.mpsa.ph.service;
import java.time.LocalTime;

import org.springframework.stereotype.Service;

import com.mobis.as.mpsa.ph.domain.CbcuZw010rDTO;
import com.mobis.as.mpsa.ph.repository.CbcuZw010rRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class CbcuZw010rService {

    private final CbcuZw010rRepository cbcuZw010rRepository;
    private final CbcuZw030rService cbcuZw030rService;

    public CbcuZw010rService(CbcuZw010rRepository cbcuZw010rRepository,
                             CbcuZw030rService cbcuZw030rService) {
        this.cbcuZw010rRepository = cbcuZw010rRepository;
        this.cbcuZw030rService = cbcuZw030rService;
    }

    public void execute(String dt, String lib, String fle, String mbr) {
        CbcuZw010rDTO dto = new CbcuZw010rDTO();
        dto.setLnkArea("some-value"); // Assuming some initialization is needed

        initializeLogArea(dto);
        processLogData(dto);
    }

    public void initializeLogArea(CbcuZw010rDTO dto) {
        dto.setPfcuzlogRow(new CbcuZw010rDTO.PfcuzlogRow());
        // Initialize other areas if needed

        if (dto.getPfcuzlogRow().getLogStm() == null || dto.getPfcuzlogRow().getLogStm().isEmpty()
                && (dto.getPfcuzlogRow().getLogEtm() == null || dto.getPfcuzlogRow().getLogEtm().isEmpty())) {
            dto.getPfcuzlogRow().setLogStm(LocalTime.now().toString());
            dto.getPfcuzlogRow().setLogEtm(LocalTime.now().toString());
        }
    }

    public void processLogData(CbcuZw010rDTO dto) {
        if (dto.getPfcuzlogRow().getLogSeq() == 0) {
            generateLogSeq(dto);
            cbcuZw010rRepository.insertLogData(dto.getPfcuzlogRow());
        } else {
            updateLogData(dto);
        }
    }

    public void generateLogSeq(CbcuZw010rDTO dto) {
        CbcuZw010rDTO.P9NbrKy1 p9NbrKy1 = new CbcuZw010rDTO.P9NbrKy1();
        p9NbrKy1.setP9NbrKy1("LOGSEQ");

        CbcuZw010rDTO.P9NbrKy2 p9NbrKy2 = new CbcuZw010rDTO.P9NbrKy2();
        p9NbrKy2.setP9NbrKy2(dto.getPfcuzlogRow().getLogDat() + dto.getPfcuzlogRow().getLogPdc() + dto.getPfcuzlogRow().getLogPgm() + dto.getPfcuzlogRow().getLogUsr());

        // cbcuzw030rService is not declared yet
        String logSeq = cbcuZw030rService.execute(p9NbrKy1.getP9NbrKy1(), p9NbrKy2.getP9NbrKy2(), "06", null);
        dto.getPfcuzlogRow().setLogSeq(Integer.parseInt(logSeq));
    }

    public void updateLogData(CbcuZw010rDTO dto) {
        cbcuZw010rRepository.updateLogData(dto.getPfcuzlogRow());
    }
}