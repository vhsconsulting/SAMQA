-- liquibase formatted sql
-- changeset SAMQA:1754373928810 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_n9_ga_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_n9_ga_id.sql:null:dcda8f477ea2f9436447c6b794cf8592491504f0:create

create index samqa.account_n9_ga_id on
    samqa.account (
        ga_id
    );

