-- liquibase formatted sql
-- changeset SAMQA:1754373932853 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_idx1.sql:null:eb6542e7c8c2a28ea0ddf9189af18b3e6b017ba6:create

create index samqa.person_idx1 on
    samqa.person (
        last_name,
        ssn,
        relat_code,
        zip
    );

