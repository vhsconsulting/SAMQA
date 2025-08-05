-- liquibase formatted sql
-- changeset SAMQA:1754373933145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\receivable_details_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/receivable_details_n1.sql:null:2373a197316d9bdf8b0979a450e24732999b9ed9:create

create index samqa.receivable_details_n1 on
    samqa.receivable_details (
        acc_id
    );

