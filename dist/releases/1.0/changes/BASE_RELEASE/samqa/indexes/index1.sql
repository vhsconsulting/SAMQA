-- liquibase formatted sql
-- changeset SAMQA:1754373931706 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\index1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/index1.sql:null:65ac0a3a55c9a7897c51aaba3f227525f4910007:create

create index samqa.index1 on
    samqa.notes (
        entity_id,
        entity_type,
        creation_date
    );

