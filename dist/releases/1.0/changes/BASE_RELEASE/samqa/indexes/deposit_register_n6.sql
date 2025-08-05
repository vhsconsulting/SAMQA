-- liquibase formatted sql
-- changeset SAMQA:1754373930827 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deposit_register_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deposit_register_n6.sql:null:de3e7361d671868a5584ad15b1b3528e62b2ecbb:create

create index samqa.deposit_register_n6 on
    samqa.deposit_register (
        entrp_id,
        list_bill
    );

