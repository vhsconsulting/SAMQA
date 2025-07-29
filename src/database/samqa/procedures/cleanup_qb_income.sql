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


-- sqlcl_snapshot {"hash":"bae2b6cbad7c8e61e70f2e56bc613c5e6b8350a0","type":"PROCEDURE","name":"CLEANUP_QB_INCOME","schemaName":"SAMQA","sxml":""}