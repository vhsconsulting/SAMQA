-- liquibase formatted sql
-- changeset SAMQA:1754373931303 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_header.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_header.sql:null:75d9065f0b65ee914dfbfdd044d2ddeb0e7c133e:create

create index samqa.enrollment_edi_header on
    samqa.enrollment_edi_header (
        header_id
    );

