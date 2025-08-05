-- liquibase formatted sql
-- changeset SAMQA:1754373930471 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n6.sql:null:b9c04eb1efb4203813a592e84d7962b821aa20e6:create

create index samqa.claimn_n6 on
    samqa.claimn (
        claim_status
    );

