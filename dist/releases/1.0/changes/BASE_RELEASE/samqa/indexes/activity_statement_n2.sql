-- liquibase formatted sql
-- changeset SAMQA:1754373928989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\activity_statement_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/activity_statement_n2.sql:null:493d664c6b2a162f71ff760064e3ce75e0836ed8:create

create index samqa.activity_statement_n2 on
    samqa.activity_statement (
        begin_date,
        end_date
    );

