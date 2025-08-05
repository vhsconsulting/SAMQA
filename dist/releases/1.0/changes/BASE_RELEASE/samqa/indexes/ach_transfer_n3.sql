-- liquibase formatted sql
-- changeset SAMQA:1754373928903 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_transfer_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_transfer_n3.sql:null:debea078788c9fe39ba3a6f64bf84a99e6205b35:create

create index samqa.ach_transfer_n3 on
    samqa.ach_transfer ( trunc(transaction_date) );

