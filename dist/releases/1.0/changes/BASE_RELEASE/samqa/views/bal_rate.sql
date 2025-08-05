-- liquibase formatted sql
-- changeset SAMQA:1754374168338 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\bal_rate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/bal_rate.sql:null:0720b9f83e3c0a7aa09831895d7a7031dcec0c0d:create

create or replace force editionable view samqa.bal_rate (
    bank,
    low,
    hi,
    rate,
    dfrom,
    active,
    note
) as
    (
        select
            bank_code,
            low_balance,
            high_balance,
            interest_rate,
            effective_date,
            active,
            notes
        from
            bank_rate
    )
with check option;

