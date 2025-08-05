-- liquibase formatted sql
-- changeset SAMQA:1754373931435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\er_balance_gt_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/er_balance_gt_n2.sql:null:a6dbbde6c05fef337424335c8f2c00e9516a1bd4:create

create index samqa.er_balance_gt_n2 on
    samqa.er_balance_gt (
        product_type
    );

