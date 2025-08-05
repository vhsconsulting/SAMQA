-- liquibase formatted sql
-- changeset SAMQA:1754373931353 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enterprise_idx2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enterprise_idx2.sql:null:c0278bb5a4283e7fbe4c531d67c2be2298c13bb9:create

create index samqa.enterprise_idx2 on
    samqa.enterprise (
        name,
        entrp_code,
        address,
        zip
    );

