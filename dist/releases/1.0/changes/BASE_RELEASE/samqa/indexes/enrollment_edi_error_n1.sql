-- liquibase formatted sql
-- changeset SAMQA:1754373931295 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_error_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_error_n1.sql:null:df6742da00a85ba80ce55c5df957bacf30b108ae:create

create index samqa.enrollment_edi_error_n1 on
    samqa.enrollment_edi_detail_error (
        detail_id
    );

