package com.mobis.as.mpsa.ph.repository;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SampleRepository {
	
	HashMap<String, Object> selectNowDate();

	List<HashMap<String, Object>> selectOcfList();
	
}
