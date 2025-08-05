-- liquibase formatted sql
-- changeset SAMQA:1754373931361 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enterprise_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enterprise_n3.sql:null:1b1830fc200b25c85110681f42dd1c63c30da7d1:create

create index samqa.enterprise_n3 on
    samqa.enterprise (
        entrp_main
    );

