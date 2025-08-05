-- liquibase formatted sql
-- changeset SAMQA:1754373982769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_claim_web_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_claim_web_pkg.sql:null:2780c8d53870f40d252d401935f243aa20c232e5:create

create or replace package body samqa.pc_claim_web_pkg is

    function get_er_claim_summary (
        p_entrp_id in number
    ) return claim_summary_t
        pipelined
        deterministic
    is
        l_record claim_summary_rec;
    begin
        for x in (
            select
                b.entrp_id,
                a.service_type,
                pc_lookups.get_fsa_plan_type(a.service_type) service_type_meaning,
                count(a.claim_id)                            no_of_claims,
                sum(claim_amount)                            total_claim,
                sum(approved_amount)                         approved_amount,
                sum(denied_amount)                           denied_amount,
                c.account_type,
                trunc(a.approved_date)                       approved_date
            from
                claimn  a,
                person  b,
                account c
            where
                    a.entrp_id = p_entrp_id
                and a.pers_id = b.pers_id
                and c.pers_id = b.pers_id
                and a.claim_status not in ( 'ERROR', 'CANCELLED' )
                and trunc(a.approved_date) > trunc(sysdate, 'YYYY')
            group by
                b.entrp_id,
                a.service_type,
                b.entrp_id,
                c.account_type,
                trunc(a.approved_date)
        ) loop
            l_record.service_type := x.service_type;
            l_record.service_type_meaning := x.service_type_meaning;
            l_record.no_of_claims := x.no_of_claims;
            l_record.total_claim := x.total_claim;
            l_record.approved_amount := x.approved_amount;
            l_record.denied_amount := x.denied_amount;
            l_record.account_type := x.account_type;
            l_record.approved_date := to_char(x.approved_date, 'MM/DD/YYYY');
            pipe row ( l_record );
        end loop;
    end get_er_claim_summary;

end pc_claim_web_pkg;
/

