-- liquibase formatted sql
-- changeset SAMQA:1754373930199 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_detail_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_detail_n2.sql:null:ebcc187956bc392db02e64d95b79757925855bb7:create

create index samqa.claim_detail_n2 on
    samqa.claim_detail (
        service_price,
        service_date,
        service_end_date,
        service_name
    );

