-- liquibase formatted sql
-- changeset SAMQA:1754373930406 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n11.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n11.sql:null:9122a3517375197ca302be4190388670886140b8:create

create index samqa.claimn_n11 on
    samqa.claimn (
        pay_reason
    );

