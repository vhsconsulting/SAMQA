-- liquibase formatted sql
-- changeset SAMQA:1754373930611 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_n2.sql:null:cef30e660238922e81400f11dab40eb6a4afb060:create

create index samqa.contact_n2 on
    samqa.contact (
        contact_type
    );

