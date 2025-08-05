-- liquibase formatted sql
-- changeset SAMQA:1754373930684 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\crm_employer_mv_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/crm_employer_mv_n2.sql:null:bf09e52145035784d9a59062cc4c178dcf572475:create

create index samqa.crm_employer_mv_n2 on
    samqa.crm_employer_mv (
        acc_id_c
    );

