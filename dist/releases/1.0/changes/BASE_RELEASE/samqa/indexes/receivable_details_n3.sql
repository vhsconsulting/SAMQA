-- liquibase formatted sql
-- changeset SAMQA:1754373933163 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\receivable_details_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/receivable_details_n3.sql:null:884136cd94776f9d1031e7f7dc24c3006e8d2726:create

create index samqa.receivable_details_n3 on
    samqa.receivable_details (
        group_number
    );

