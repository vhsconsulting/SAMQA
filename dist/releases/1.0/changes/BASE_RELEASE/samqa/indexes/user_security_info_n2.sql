-- liquibase formatted sql
-- changeset SAMQA:1754373933580 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\user_security_info_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/user_security_info_n2.sql:null:4aa6634ea239a5b4a11321ab9e4057f4a93ec01b:create

create index samqa.user_security_info_n2 on
    samqa.user_security_info (
        pw_question2
    );

