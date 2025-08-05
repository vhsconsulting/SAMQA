-- liquibase formatted sql
-- changeset SAMQA:1754373930447 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n3.sql:null:34d38a2b9bac202783ab5e87082619f8148f2ca6:create

create index samqa.claimn_n3 on
    samqa.claimn (
        claim_date_start
    );

