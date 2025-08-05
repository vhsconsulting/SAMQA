-- liquibase formatted sql
-- changeset SAMQA:1754373930496 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_pers.sql:null:5b0c3caea7bf4e284f5f27f794a5f3a0c10692a7:create

create index samqa.claimn_pers on
    samqa.claimn (
        pers_id
    );

