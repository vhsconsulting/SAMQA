create or replace procedure samqa.delete_dup_cov_tier as
    l_ben_plan_id number;
    l_count       number := 0;
begin
    for x in (
        select
            b.acc_num,
            a.plan_start_date,
            a.plan_end_date,
            a.plan_type,
            a.ben_plan_id,
            count(coverage_id)
        from
            ben_plan_enrollment_setup a,
            account                   b,
            ben_plan_coverages        c
        where
                a.acc_id = b.acc_id
            and c.ben_plan_id = a.ben_plan_id
            and a.plan_type in ( 'FSA', 'LPF' )
        group by
            b.acc_num,
            a.plan_start_date,
            a.plan_end_date,
            a.plan_type,
            a.ben_plan_id
        having
            count(coverage_id) > 1
    ) loop
        l_count := 0;
        for xx in (
            select
                coverage_id
            from
                ben_plan_coverages
            where
                ben_plan_id = x.ben_plan_id
        ) loop
            l_count := l_count + 1;
            if l_count > 1 then
                delete from ben_plan_coverages
                where
                    coverage_id = xx.coverage_id;

            end if;
        end loop;

    end loop;
end delete_dup_cov_tier;
/


-- sqlcl_snapshot {"hash":"5abacc6e967f73386af4499d9c026cfbecd09d6c","type":"PROCEDURE","name":"DELETE_DUP_COV_TIER","schemaName":"SAMQA","sxml":""}