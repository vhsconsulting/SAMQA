-- liquibase formatted sql
-- changeset SAMQA:1754373929694 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\beneficiary_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/beneficiary_idx1.sql:null:e05a836522b4827c3598032ee77d82c789eaa5cf:create

create index samqa.beneficiary_idx1 on
    samqa.beneficiary (
        beneficiary_name,
        beneficiary_type,
        relat_code
    );

