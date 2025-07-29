create or replace procedure samqa.migrate_coverage is
    x_return_status varchar2(300);
    x_error_message varchar2(3200);
begin
    for x in (
        select
            *
        from
            ben_plan_enrollment_setup
        where
            ben_plan_id_main is null
            and entrp_id is not null
            and plan_type in ( 'FSA', 'LPF' )
            and ( plan_end_date >= trunc(sysdate, 'YYYY') - 30 )
            and ( nvl(grace_period, 0) = 0
                  or grace_period = null )
            and status = 'A'
            and not exists (
                select
                    *
                from
                    ben_plan_coverages
                where
                    ben_plan_coverages.ben_plan_id = ben_plan_enrollment_setup.ben_plan_id
            )
    ) loop
        pc_benefit_plans.create_fsa_coverage(x.ben_plan_id, 'SINGLE', 0);
        pc_benefit_plans.add_fsa_cov_tier(
            p_ben_plan_id   => x.ben_plan_id,
            p_entrp_id      => x.entrp_id,
            p_user_id       => 0,
            x_return_status => x_return_status,
            x_error_message => x_error_message
        );

    end loop;
end migrate_coverage;
/


-- sqlcl_snapshot {"hash":"cfe06368d29e1522f2fe0a5d9ee1b858c00a2481","type":"PROCEDURE","name":"MIGRATE_COVERAGE","schemaName":"SAMQA","sxml":""}