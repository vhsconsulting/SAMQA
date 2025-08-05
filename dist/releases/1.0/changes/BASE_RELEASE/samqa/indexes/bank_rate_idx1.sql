-- liquibase formatted sql
-- changeset SAMQA:1754373929368 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bank_rate_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bank_rate_idx1.sql:null:94841da6bfc8e4456c1dbc39d68112f4de466530:create

create index samqa.bank_rate_idx1 on
    samqa.bank_rate (
        entrp_id,
        bank_code
    );

