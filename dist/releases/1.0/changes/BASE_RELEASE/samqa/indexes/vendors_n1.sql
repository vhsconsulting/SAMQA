-- liquibase formatted sql
-- changeset SAMQA:1754373933594 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\vendors_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/vendors_n1.sql:null:64f4b6eddc22d65136aae148c96f38a383d54753:create

create index samqa.vendors_n1 on
    samqa.vendors (
        acc_num
    );

