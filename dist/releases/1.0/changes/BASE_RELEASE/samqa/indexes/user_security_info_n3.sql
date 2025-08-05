-- liquibase formatted sql
-- changeset SAMQA:1754373933594 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\user_security_info_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/user_security_info_n3.sql:null:25513845b44605275ac88202da4a047a019288fd:create

create index samqa.user_security_info_n3 on
    samqa.user_security_info (
        pw_question3
    );

