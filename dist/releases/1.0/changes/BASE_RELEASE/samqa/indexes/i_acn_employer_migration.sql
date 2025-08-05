-- liquibase formatted sql
-- changeset SAMQA:1754373931559 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\i_acn_employer_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/i_acn_employer_migration.sql:null:4509e1b13ebdc2990c7a3a42f7401c158e6cc1e4:create

create index samqa.i_acn_employer_migration on
    samqa.acn_employer_migration (
        batch_number
    );

