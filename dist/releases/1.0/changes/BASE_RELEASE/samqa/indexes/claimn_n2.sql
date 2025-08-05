-- liquibase formatted sql
-- changeset SAMQA:1754373930438 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n2.sql:null:2a29ca35ec0427a3301c89f87bf5cc0bc3e58b05:create

create index samqa.claimn_n2 on
    samqa.claimn (
        claim_date_end
    );

