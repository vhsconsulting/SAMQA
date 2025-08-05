-- liquibase formatted sql
-- changeset SAMQA:1754373930628 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_n4.sql:null:c9726bf3699ccd9eadcceca2931a66c9213c2c5c:create

create index samqa.contact_n4 on
    samqa.contact (
        status
    );

