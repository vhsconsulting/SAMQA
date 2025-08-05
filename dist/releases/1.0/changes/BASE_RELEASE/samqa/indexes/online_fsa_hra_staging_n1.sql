-- liquibase formatted sql
-- changeset SAMQA:1754373932484 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_fsa_hra_staging_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_fsa_hra_staging_n1.sql:null:a74736bef49b62b6dab3b793eeef08126ef099d4:create

create index samqa.online_fsa_hra_staging_n1 on
    samqa.online_fsa_hra_staging (
        entrp_id
    );

