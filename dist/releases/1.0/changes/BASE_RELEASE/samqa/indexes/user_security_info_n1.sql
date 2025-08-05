-- liquibase formatted sql
-- changeset SAMQA:1754373933580 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\user_security_info_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/user_security_info_n1.sql:null:c9e86c6c6bbf1f348c469ee8a3f9c03534a90246:create

create index samqa.user_security_info_n1 on
    samqa.user_security_info (
        pw_question1
    );

