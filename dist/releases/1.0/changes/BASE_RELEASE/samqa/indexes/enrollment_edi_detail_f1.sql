-- liquibase formatted sql
-- changeset SAMQA:1754373931244 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_detail_f1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_detail_f1.sql:null:12a74d014294b9d260069ee7912b2f8cb258276d:create

create index samqa.enrollment_edi_detail_f1 on
    samqa.enrollment_edi_detail (
        status_cd
    );

