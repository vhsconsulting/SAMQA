-- liquibase formatted sql
-- changeset SAMQA:1754373927758 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_monthly_max.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_monthly_max.sql:null:460db38955dbda41b7401e23e99bb817e6dfa10e:create

create or replace function samqa.get_monthly_max (
    p_pers_id  in number,
    p_claim_id in number
) return number is
    l_amt number := 0;
begin
    select
        sum(nvl(c.service_price, 0))
    into l_amt
    from
        claimn       a,
        claim_detail c
    where
            a.pers_id = p_pers_id
        and a.service_type = 'TRN'
                -- AND   c.claim_id = a.claim_id
        and a.claim_status not in ( 'DENIED', 'CANCELED', 'CANCELLED' )
        and a.claim_id <> p_claim_id
        and a.claim_id = c.claim_id
        and ( trunc(c.service_date, 'MM') = trunc(to_date('16-MAR-2014'), 'MM')
              or trunc(c.service_end_date, 'MM') = trunc(to_date('16-MAR-2014'), 'MM')
              or trunc(c.service_date, 'MM') = trunc(to_date('31-MAR-2014'), 'MM')
              or trunc(c.service_end_date, 'MM') = trunc(to_date('31-MAR-2014'), 'MM') );

    return l_amt;
exception
    when no_data_found then
        return 0;
    when others then
        raise;
end;
/

