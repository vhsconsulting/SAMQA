-- liquibase formatted sql
-- changeset SAMQA:1754373930074 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_4.sql:null:bf52e3177bda87fb63157656e7d2a453049c031a:create

create index samqa.claim_4 on
    samqa.claim (
        pers_id
    );

