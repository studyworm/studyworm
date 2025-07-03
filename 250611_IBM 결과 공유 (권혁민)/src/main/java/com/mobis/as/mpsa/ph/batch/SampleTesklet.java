package com.mobis.as.mpsa.ph.batch;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.mobis.as.mpsa.ph.service.Cbcphb710aService;
import com.mobis.as.mpsa.ph.service.SampleService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class SampleTesklet implements Tasklet {

	@Autowired
	private SampleService sampleService;
	
	@Autowired
	private Cbcphb710aService cbcphb710aService;
	
    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {
       
    	log.info("Run SampleTasklet");

//    	sampleService.execute();
    	
    	String dt = "testDt";
        String lib = "testLib";
        String fle = "testFle";
        String mbr = "testMbr";
        
    	cbcphb710aService.execute(dt,lib,fle,mbr);
        log.info("End SampleTasklet");

        return RepeatStatus.FINISHED;
    
    }

    
}