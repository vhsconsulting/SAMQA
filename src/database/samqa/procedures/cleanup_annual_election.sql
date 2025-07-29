create or replace procedure samqa.cleanup_annual_election (
    p_entrp_id in number,
    p_acc_num  in varchar2 default null
) is
begin
    for x in (
        select
            e.first_name,
            e.last_name,
            d.acc_num,
            sum(b.amount) total_election,
            bp.annual_election,
            bp.plan_start_date,
            bp.plan_end_date,
            bp.ben_plan_id
        from
            income                    a,
            income                    b,
            ben_plan_enrollment_setup bp,
            account                   d,
            person                    e
        where
                a.fee_code = 17
            and a.creation_date >= trunc(sysdate, 'MM')
            and a.acc_id = b.acc_id
            and a.acc_id = bp.acc_id
            and bp.acc_id = d.acc_id
            and a.plan_type = b.plan_type
            and e.pers_id = d.pers_id
            and b.plan_type = bp.plan_type
            and b.fee_code = 12
            and b.fee_date between bp.plan_start_date and bp.plan_end_date
            and a.fee_date between bp.plan_start_date and bp.plan_end_date
            and e.entrp_id = p_entrp_id
            and d.acc_num = nvl(p_acc_num, d.acc_num)
        group by
            e.first_name,
            e.last_name,
            d.acc_num,
            bp.annual_election,
            bp.plan_start_date,
            bp.plan_end_date,
            bp.ben_plan_id
        having
            sum(b.amount) <> bp.annual_election
    ) loop
        update ben_plan_enrollment_setup
        set
            annual_election = x.total_election
        where
            ben_plan_id = x.ben_plan_id;

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"5fa8ad4eae92605d7f8dc46bd0d1045dca8c3b81","type":"PROCEDURE","name":"CLEANUP_ANNUAL_ELECTION","schemaName":"SAMQA","sxml":""}