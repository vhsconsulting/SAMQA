-- liquibase formatted sql
-- changeset SAMQA:1754373931261 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_detail_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_detail_n10.sql:null:1f136e33b39e67371d15e4e4cb12d162e6307063:create

create index samqa.enrollment_edi_detail_n10 on
    samqa.enrollment_edi_detail (
        ssn
    );

