-- liquibase formatted sql
-- changeset SAMQA:1754373933171 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\receivable_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/receivable_n1.sql:null:88a4ed2435602cfbcc81026658c7fb871e617ab7:create

create index samqa.receivable_n1 on
    samqa.receivable (
        acc_id
    );

