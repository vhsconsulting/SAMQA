-- liquibase formatted sql
-- changeset SAMQA:1754373927142 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\f_er_fsa_hra_funding.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/f_er_fsa_hra_funding.sql:null:a3ededf92a38b49893b90ea7d99007db7141c86a:create

create or replace function samqa.f_er_fsa_hra_funding (
    p_entrp_code varchar2,
    p_plan_type  varchar2
) return pc_web_dashboard.tbl_graph
    pipelined
is
    l_record pc_web_dashboard.rec_graph;
begin
    for x in (
        select
            to_char(from_date, 'RRRRMM') fee_mon,
            sum(check_amount)            amount
        from
            (
                select
                    to_date('01/'
                            || to_char(
                        add_months(sysdate, level - 1),
                        'MON'
                    )
                            || '/'
                            || to_char(sysdate, 'YYYY'),
                            'DD-MON-YYYY')   from_date,
                    last_day(to_date('01/'
                                     || to_char(
                        add_months(sysdate, level - 1),
                        'MON'
                    )
                                     || '/'
                                     || to_char(sysdate, 'YYYY'),
                             'DD-MON-YYYY')) end_date,
                    to_char(
                        add_months(sysdate, level - 1),
                        'MM'
                    )                        mm
                from
                    dual
                connect by
                    level <= 12
                order by
                    mm
            )                 d,
            account           b,
            employer_deposits c
        where
                b.entrp_id = c.entrp_id
            and account_status = 1
            and reason_code not in ( 11, 12 )
            and c.entrp_id in (
                select
                    entrp_id
                from
                    enterprise
                where
                    replace(entrp_code, '-') = replace(p_entrp_code, '-')
            )
            and ( plan_type = p_plan_type
                  or plan_type in (
                select distinct
                    plan_type
                from
                    ben_plan_enrollment_setup
                where
                        entrp_id = b.entrp_id
                    and ben_plan_name = p_plan_type
            ) )
            and trunc(check_date) >= d.from_date
            and trunc(check_date) <= d.end_date
        group by
            to_char(from_date, 'RRRRMM')
        order by
            to_char(from_date, 'RRRRMM')
    ) loop
        l_record.amount := x.amount;
        l_record.mnth_yr := x.fee_mon;
        pipe row ( l_record );
    end loop;
exception
    when others then
        pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
end;
/

