package com.mobis.as.mpsa.ph.repository;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mobis.as.mpsa.ph.domain.Cbcphb780aDTO;

/**
 * Repository interface for Cbcphb780a related database operations.
 */
@Mapper
public interface Cbcphb780aRepository {

    /**
     * Fetches data from PFCPHOCF table based on given conditions.
     * 
     * @param dto Cbcphb780aDTO object containing the conditions.
     * @return List of Cbcphb780aDTO.PfcpHocfRow objects.
     */
    List<Cbcphb780aDTO.PfcpHocfRow> selectPfcpHocf(Cbcphb780aDTO dto);

    /**
     * Fetches data from PFCICPOI table based on reference order details.
     * 
     * @param dto Cbcphb780aDTO object containing the reference order details.
     * @return Cbcphb780aDTO.PfcicpoiRow object.
     */
    Cbcphb780aDTO.PfcicpoiRow selectPfcicpoiByRefOrd(Cbcphb780aDTO dto);

    /**
     * Fetches data from PFCICPOI table based on POI_NO.
     * 
     * @param dto Cbcphb780aDTO object containing the POI_NO.
     * @return Cbcphb780aDTO.PfcicpoiRow object.
     */
    Cbcphb780aDTO.PfcicpoiRow selectPfcicpoiByPoiNo(Cbcphb780aDTO dto);

    /**
     * Fetches data from PFCICINV table based on given conditions.
     * 
     * @param dto Cbcphb780aDTO object containing the conditions.
     * @return Cbcphb780aDTO.PfcicinvRow object.
     */
    Cbcphb780aDTO.PfcicinvRow selectPfcicinv(Cbcphb780aDTO dto);

    /**
     * Updates PFCICPOI table based on given conditions.
     * 
     * @param dto Cbcphb780aDTO object containing the update details.
     * @return Number of rows affected.
     */
    int updatePfcicpoi(Cbcphb780aDTO dto);

    /**
     * Updates PFCPHOCF table based on given conditions.
     * 
     * @param dto Cbcphb780aDTO object containing the update details.
     * @return Number of rows affected.
     */
    int updatePfcpHocf(Cbcphb780aDTO dto);

    /**
     * Inserts a new record into PFCPHARM table.
     * 
     * @param dto Cbcphb780aDTO.PfcpHarmRow object containing the insert details.
     * @return Number of rows affected.
     */
    int insertPfcpHarm(Cbcphb780aDTO.PfcpHarmRow dto);

    /**
     * Deletes records from PFCPHARM table based on given conditions.
     * 
     * @param dto Cbcphb780aDTO object containing the conditions.
     * @return Number of rows affected.
     */
    int deletePfcpHarm(Cbcphb780aDTO dto);
}