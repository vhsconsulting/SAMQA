-- liquibase formatted sql
-- changeset SAMQA:1754373933178 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\receivable_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/receivable_n2.sql:null:e7e86bac1aee1716bd574e30e85a236bca545064:create

create index samqa.receivable_n2 on
    samqa.receivable (
        entrp_id
    );

