-- liquibase formatted sql
-- changeset SAMQA:1754373931287 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_detail_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_detail_n4.sql:null:a7498df239ab210ba9b7b98bcebfdee2551b62d0:create

create index samqa.enrollment_edi_detail_n4 on
    samqa.enrollment_edi_detail (
        person_type
    );

