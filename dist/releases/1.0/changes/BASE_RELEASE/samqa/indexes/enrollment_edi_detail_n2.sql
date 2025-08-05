-- liquibase formatted sql
-- changeset SAMQA:1754373931270 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_detail_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_detail_n2.sql:null:3f3909c09cc585a16cd2ab7b463bda1097113c64:create

create index samqa.enrollment_edi_detail_n2 on
    samqa.enrollment_edi_detail (
        orig_system_ref
    );

