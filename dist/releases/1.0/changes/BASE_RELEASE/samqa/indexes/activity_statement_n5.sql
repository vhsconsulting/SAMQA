-- liquibase formatted sql
-- changeset SAMQA:1754373929013 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\activity_statement_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/activity_statement_n5.sql:null:b34742490a6f2ef6958dc6a23ee51d4809124782:create

create index samqa.activity_statement_n5 on
    samqa.activity_statement (
        acc_num,
        begin_date,
        end_date
    );

