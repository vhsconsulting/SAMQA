-- liquibase formatted sql
-- changeset SAMQA:1754373928894 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_transfer_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_transfer_n2.sql:null:2c1814c7cf35e1ae427a6894f480df190559e34c:create

create index samqa.ach_transfer_n2 on
    samqa.ach_transfer (
        transaction_type
    );

