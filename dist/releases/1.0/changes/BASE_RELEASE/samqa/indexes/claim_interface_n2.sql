-- liquibase formatted sql
-- changeset SAMQA:1754373930275 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_interface_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_interface_n2.sql:null:76fba7ed6916fae22ec05bb5fa85cf57aeea3dd8:create

create index samqa.claim_interface_n2 on
    samqa.claim_interface (
        acc_id
    );

