package com.mobis.as.mpsa.ph.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.batch.item.validator.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mobis.as.mpsa.ph.domain.Cbcphb710aDTO;
import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO;
import com.mobis.as.mpsa.ph.domain.CbcuZw010rDTO;
import com.mobis.as.mpsa.ph.domain.Cbcuzw011rDTO;
import com.mobis.as.mpsa.ph.repository.Cbcphb710aRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class Cbcphb710aService {

    private final Cbcphb710aRepository repository;
    private final CbcuZw010rService cbcuzw010rService;
    private final Cbcuzw011rService cbcuzw011rService;
    private final Cbcphb780aService cbcphb780aService;

    @Autowired
    public Cbcphb710aService(Cbcphb710aRepository repository,
                             CbcuZw010rService cbcuzw010rService,
                             Cbcphb780aService cbcphb780aService,
                             Cbcuzw011rService cbcuzw011rService) {
        this.repository = repository;
        this.cbcuzw010rService = cbcuzw010rService;
        this.cbcphb780aService = cbcphb780aService;
        this.cbcuzw011rService = cbcuzw011rService;
    }

    @Transactional
    public void execute(String dt, String lib, String fle, String mbr) {
        Cbcphb710aDTO dto = new Cbcphb710aDTO();
        initProcess(dto, dt, lib, fle, mbr);
        runMainProcess(dto);
        handleSuccess(dto);
    }

    private void initProcess(Cbcphb710aDTO dto, String dt, String lib, String fle, String mbr) {
        dto.getWorkArea().setDt(dt);
        dto.getWorkArea().setLib(lib);
        dto.getWorkArea().setFle(fle);
        dto.getWorkArea().setMbr(mbr);
        dto.setWtPdc(fle.substring(4, 6));
        dto.setDtDateTime(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
        log.info("Process started with parameters: dt={}, lib={}, fle={}, mbr={}", dt, lib, fle, mbr);

        // Create a new CbcuZw010rDTO object
        CbcuZw010rDTO cbcuZw010rDTO = new CbcuZw010rDTO();
        cbcuZw010rDTO.setLnkArea(dto.getWorkArea().getDt() + dto.getWorkArea().getLib() + dto.getWorkArea().getFle() + dto.getWorkArea().getMbr());
        cbcuZw010rDTO.getPfcuzlogRow().setLogDat(dto.getWtPdc().substring(0, 8)); // Example logic

        // Call the processLogData method with the CbcuZw010rDTO object
        cbcuzw010rService.processLogData(cbcuZw010rDTO);
    }

    private void runMainProcess(Cbcphb710aDTO dto) {
        List<Cbcphb710aDTO> records = repository.findRecordsForProcessing(dto.getWCmpKnd());
        for (Cbcphb710aDTO record : records) {
            processRecord(record, dto);
        }
        if (dto.getWInsCnt() > 0) {
 
            Cbcphb780aDTO cbcphb780aDTO = new Cbcphb780aDTO();
            cbcphb780aDTO.setP2Date(dto.getWorkArea().getDt());
            cbcphb780aDTO.setP2Lib(dto.getWorkArea().getLib());
            cbcphb780aDTO.setP2Fle(dto.getWorkArea().getFle());
            cbcphb780aDTO.setP2Mbr(dto.getWorkArea().getMbr());
            		
            cbcphb780aService.initProcess(cbcphb780aDTO);
            cbcphb780aService.mainProcess(cbcphb780aDTO);
            cbcphb780aService.normalEnd(cbcphb780aDTO);
            
        }
    }

    private void processRecord(Cbcphb710aDTO record, Cbcphb710aDTO dto) {
        try {
            validateRecord(record, dto);
            saveConfirmation(record, dto);
        } catch (Exception e) {
            handleError(dto, e, record);
        }
    }

    private void validateRecord(Cbcphb710aDTO record, Cbcphb710aDTO dto) {
        if (record.getSamfileRedf().getSamOrdNo().isEmpty()) {
            throw new ValidationException("Order Number is empty");
        }
        if (record.getSamfileRedf().getSamOrdLn().isEmpty()) {
            throw new ValidationException("Order Line Number is empty");
        }
        if (record.getSamfileRedf().getSamCfmPno().isEmpty()) {
            throw new ValidationException("Confirm Part Number is empty");
        }
    }

    private void saveConfirmation(Cbcphb710aDTO record, Cbcphb710aDTO dto) {
        Cbcphb710aDTO existingRecord = repository.checkExistingRecord(record);
        if (existingRecord != null) {
            log.error("Duplicate record found for Order No: {}", record.getSamfileRedf().getSamOrdNo());
            throw new ValidationException("Record already exists");
        }
        repository.insertConfirmationData(record);
        dto.incrementW_insCnt();
    }

    private void handleError(Cbcphb710aDTO dto, Exception e, Cbcphb710aDTO record) {
        dto.incrementW_errCnt();
        log.error("Error during processing: {}", e.getMessage());
        log.error("Record details: {}", record);

        Cbcuzw011rDTO logDto = new Cbcuzw011rDTO();
        logDto.setLnkArea(dto.getWorkArea().getDt() + dto.getWorkArea().getLib() + dto.getWorkArea().getFle() + dto.getWorkArea().getMbr());
        logDto.setLn2Area("Error occurred during PO processing");

        cbcuzw011rService.initializeLogArea(logDto);
        Cbcuzw011rDTO.PfcuzlogRow row = logDto.getPfcuzlogRow();
        row.setLogRtc("E");
        row.setLogSql(e.getMessage());
        row.setLogMsg(record.toString());
        row.setLogMcd("710A_ERR");

        cbcuzw011rService.retrieveNextLogSe2(logDto);
        cbcuzw011rService.insertLogData(logDto);
    }

    private void handleSuccess(Cbcphb710aDTO dto) {
        log.info("Process completed successfully. Total records processed: {}", dto.getWReadCnt());
        log.info("Total records inserted: {}", dto.getWInsCnt());
        log.info("Total errors encountered: {}", dto.getWErrCnt());
    }
}