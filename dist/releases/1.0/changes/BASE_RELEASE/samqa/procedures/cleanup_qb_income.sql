-- liquibase formatted sql
-- changeset SAMQA:1754374142948 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\cleanup_qb_income.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/cleanup_qb_income.sql:null:bae2b6cbad7c8e61e70f2e56bc613c5e6b8350a0:create

create or replace procedure samqa.cleanup_qb_income as
begin
    delete from income
    where
        rowid in (
            select
                i.rowid
            from
                income  i, account a
            where
                    i.acc_id = a.acc_id
                and a.account_type = 'COBRA'
                and fee_date > add_months(sysdate, -18)
        );

    commit;
end;
/

