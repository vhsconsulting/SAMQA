-- liquibase formatted sql
-- changeset SAMQA:1754373928886 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_transfer_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_transfer_n1.sql:null:4fb7cacc0ed0ae2550a9a18a9768433d065e3c74:create

create index samqa.ach_transfer_n1 on
    samqa.ach_transfer (
        acc_id,
        bank_acct_id,
        transaction_type
    );

