-- liquibase formatted sql
-- changeset SAMQA:1754373930953 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_deposits_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_deposits_u1.sql:null:19479ae9ca8c7e754b192abb24212f4f0855570a:create

create index samqa.employer_deposits_u1 on
    samqa.employer_deposits (
        employer_deposit_id
    );

