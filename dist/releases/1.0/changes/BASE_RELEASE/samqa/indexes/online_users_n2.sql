-- liquibase formatted sql
-- changeset SAMQA:1754373932553 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_users_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_users_n2.sql:null:ad27b2f3e5f4c2281612b709c6cb4705d3f3ac7a:create

create index samqa.online_users_n2 on
    samqa.online_users (
        tax_id
    );

