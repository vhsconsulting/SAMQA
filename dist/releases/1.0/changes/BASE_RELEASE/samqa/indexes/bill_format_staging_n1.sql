-- liquibase formatted sql
-- changeset SAMQA:1754373929708 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bill_format_staging_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bill_format_staging_n1.sql:null:eddb3c83cd2228f3bbfa41bff9a15975797a7910:create

create index samqa.bill_format_staging_n1 on
    samqa.bill_format_staging (
        batch_number
    );

