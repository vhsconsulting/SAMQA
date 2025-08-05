-- liquibase formatted sql
-- changeset SAMQA:1754373930357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_n3.sql:null:a1e63934e5641747ee9a7cd703fa2e92c0f6a441:create

create index samqa.claim_n3 on
    samqa.claim (
        pers_patient
    );

