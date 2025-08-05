-- liquibase formatted sql
-- changeset SAMQA:1754373928997 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\activity_statement_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/activity_statement_n3.sql:null:af86381a4b5239ff859db6adebfa042e46826c05:create

create index samqa.activity_statement_n3 on
    samqa.activity_statement (
        batch_number
    );

