-- liquibase formatted sql
-- changeset SAMQA:1754373931066 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n3.sql:null:355e9c9c3cea4bd3a91db7f6388eee1a796f1eea:create

create index samqa.employer_payment_detail_n3 on
    samqa.employer_payment_detail (
        reason_code,
        service_type,
        plan_start_date,
        plan_end_date
    );

