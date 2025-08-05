-- liquibase formatted sql
-- changeset SAMQA:1754373930676 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\crm_employer_mv_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/crm_employer_mv_n1.sql:null:d63abd89ea0415957d0de0612e421b4c6e20d11b:create

create index samqa.crm_employer_mv_n1 on
    samqa.crm_employer_mv (
        acc_num_c
    );

