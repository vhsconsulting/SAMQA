-- liquibase formatted sql
-- changeset SAMQA:1754373930266 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_interface_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_interface_n1.sql:null:ddfc919eb405e979f2e6b041f6b93537f5672e13:create

create index samqa.claim_interface_n1 on
    samqa.claim_interface (
        member_id
    );

