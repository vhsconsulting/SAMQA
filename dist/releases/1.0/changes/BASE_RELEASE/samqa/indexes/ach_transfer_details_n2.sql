-- liquibase formatted sql
-- changeset SAMQA:1754373928869 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_transfer_details_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_transfer_details_n2.sql:null:7aa9b83d6d2e186e34fb8e9e16f60a7aaa680f44:create

create index samqa.ach_transfer_details_n2 on
    samqa.ach_transfer_details (
        transaction_id,
        acc_id
    );

