-- liquibase formatted sql
-- changeset SAMQA:1754373931279 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_detail_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_detail_n3.sql:null:444f3c4afaf0565b4e9e9eb0393cddf842d503f6:create

create index samqa.enrollment_edi_detail_n3 on
    samqa.enrollment_edi_detail (
        maintenance_cd
    );

