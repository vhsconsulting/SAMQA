-- liquibase formatted sql
-- changeset SAMQA:1754373928981 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\activity_statement_detail_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/activity_statement_detail_n1.sql:null:14e0aa6c3e3fd50585453bbfa999956d2186f4c9:create

create index samqa.activity_statement_detail_n1 on
    samqa.activity_statement_detail (
        statement_id
    );

