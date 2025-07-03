package com.mobis.as.mpsa.ph.batch;
import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

@Slf4j
@Configuration
public class SampleStep {

    @Bean
    public Step configureSampleStep(JobRepository jobRepository, Tasklet sampleTasklet, PlatformTransactionManager platformTransactionManager) {
        return new StepBuilder("sampleStep", jobRepository)
                .tasklet(sampleTasklet, platformTransactionManager)
                .build();
    }
}