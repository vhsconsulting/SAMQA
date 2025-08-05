-- liquibase formatted sql
-- changeset SAMQA:1754373932617 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_details_idx2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_details_idx2.sql:null:0662ea75fab7cab433726dcd95b37ab2f37d8f7a:create

create index samqa.pay_details_idx2 on
    samqa.pay_details (
        acc_id
    );

