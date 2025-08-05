-- liquibase formatted sql
-- changeset SAMQA:1754373930455 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n4.sql:null:8dd0f0f91bc4ccee6095b1974bf93c9ef15e7daf:create

create index samqa.claimn_n4 on
    samqa.claimn (
        pers_patient
    );

