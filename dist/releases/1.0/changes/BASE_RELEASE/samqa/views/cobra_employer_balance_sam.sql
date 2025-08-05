-- liquibase formatted sql
-- changeset SAMQA:1754374170762 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cobra_employer_balance_sam.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cobra_employer_balance_sam.sql:null:f6025cf11cb3a6efe9d22d1c45b19c92f3685e54:create

create or replace force editionable view samqa.cobra_employer_balance_sam (
    entrp_id,
    check_amount,
    transaction_date,
    fee_name,
    note,
    balance
) as
    select
        entrp_id,
        check_amount,
        transaction_date,
        fee_name,
        note,
        sum(check_amount)
        over(
            order by
                transaction_date, entrp_id
            range unbounded preceding
        ) balance
    from
        (
            select
                entrp_id,
                sum(check_amount) check_amount,
                transaction_date,
                fee_name,
                note
            from
                (
                    select
                        entrp_id,
                        check_amount,
                        transaction_date,
                        fee_name,
                        note
                    from
                        cobra_employer_balances_v a
                )
            group by
                entrp_id,
                transaction_date,
                fee_name,
                note
        );

