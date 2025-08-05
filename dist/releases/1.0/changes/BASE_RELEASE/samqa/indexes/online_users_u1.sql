-- liquibase formatted sql
-- changeset SAMQA:1754373932561 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_users_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_users_u1.sql:null:187f902554434df3596ba0cb564f2f74afe2f797:create

create unique index samqa.online_users_u1 on
    samqa.online_users (
        user_id
    );

