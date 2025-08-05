-- liquibase formatted sql
-- changeset SAMQA:1754373929787 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bps_sam_balances_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bps_sam_balances_u1.sql:null:b22a5ead52157f4250f772c09ec50594aa568e86:create

create index samqa.bps_sam_balances_u1 on
    samqa.bps_sam_balances (
        acc_num
    );

