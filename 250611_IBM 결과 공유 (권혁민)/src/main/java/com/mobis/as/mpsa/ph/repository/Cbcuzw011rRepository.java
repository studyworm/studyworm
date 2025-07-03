package com.mobis.as.mpsa.ph.repository;
import org.apache.ibatis.annotations.Mapper;

import com.mobis.as.mpsa.ph.domain.Cbcuzw011rDTO;

/**
 * Repository interface for Cbcuzw011r.
 * 
 * @author [Your Name]
 */
@Mapper
public interface Cbcuzw011rRepository {

    /**
     * Select the next LOGSE2 value from MCHPTFLE.PFCUZLOG.
     * 
     * @param DTO PfcuzlogRow object containing log data
     * @return PfcuzlogRow object with the next LOGSE2 value
     */
    Cbcuzw011rDTO.PfcuzlogRow selectNextLogSe2(Cbcuzw011rDTO.PfcuzlogRow dto);

    /**
     * Call the function FNCCMM200Q(:LOGMCD, 'ENG') from MCAPTFLE.DUMMY.
     * 
     * @param DTO PfcuzlogRow object containing log data
     * @return PfcuzlogRow object with the result of FNCCMM200Q
     */
    Cbcuzw011rDTO.PfcuzlogRow callFnccmm200q(Cbcuzw011rDTO.PfcuzlogRow dto);

    /**
     * Insert new log data into MCHPTFLE.PFCUZLOG.
     * 
     * @param dto PfcuzlogRow object containing log data to be inserted
     * @return the number of rows affected by the insert operation
     */
    int insertLogData(Cbcuzw011rDTO.PfcuzlogRow dto);
}