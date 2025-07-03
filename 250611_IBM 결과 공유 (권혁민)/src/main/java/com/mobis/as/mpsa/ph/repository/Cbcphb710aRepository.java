package com.mobis.as.mpsa.ph.repository;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.mobis.as.mpsa.ph.domain.Cbcphb710aDTO;

@Mapper
public interface Cbcphb710aRepository {

    /**
     * Check if a record exists in PFCPHOCF table based on the given key fields.
     * 
     * @param vo Cbcphb710aVO object containing the key fields.
     * @return Cbcphb710aVO object if the record exists, null otherwise.
     */
    Cbcphb710aDTO checkExistingRecord(Cbcphb710aDTO vo);

    /**
     * Insert a new record into PFCPHOCF table.
     * 
     * @param vo Cbcphb710aVO object containing the data to be inserted.
     * @return The number of rows affected by the insert operation.
     */
    int insertConfirmationData(Cbcphb710aDTO vo);

    /**
     * Retrieve all SAMFILE-based confirmation records to be processed.
     * 
     * @param cmpKnd the company kind key to filter SAMFILE data
     * @return list of confirmation records from SAMFILE
     */
    List<Cbcphb710aDTO> findRecordsForProcessing(@Param("cmpKnd") String cmpKnd);
}