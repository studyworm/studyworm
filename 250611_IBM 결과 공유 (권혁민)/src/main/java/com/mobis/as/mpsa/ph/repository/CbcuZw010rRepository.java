package com.mobis.as.mpsa.ph.repository;
import org.apache.ibatis.annotations.Mapper;

import com.mobis.as.mpsa.ph.domain.CbcuZw010rDTO;

/**
 * Repository interface for CbcuZw010r, encapsulating database operations.
 */
@Mapper
public interface CbcuZw010rRepository {

    /**
     * Inserts new log data into MCHPTFLE.PFCUZLOG.
     * 
     * @param dto PfcuzlogRow object containing log data to be inserted.
     * @return The number of rows affected by the insert operation.
     */
    int insertLogData(CbcuZw010rDTO.PfcuzlogRow dto);

    /**
     * Updates existing log data in MCHPTFLE.PFCUZLOG.
     * 
     * @param dto PfcuzlogRow object containing log data to be updated.
     * @return The number of rows affected by the update operation.
     */
    int updateLogData(CbcuZw010rDTO.PfcuzlogRow dto);
}