-- liquibase formatted sql
-- changeset SAMQA:1754373930512 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\cobra_disbursements.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/cobra_disbursements.sql:null:b5846e969feabc7acd6cfd098db4e6d830351a93:create

create index samqa.cobra_disbursements on
    samqa.cobra_disbursements (
        client_id
    );

