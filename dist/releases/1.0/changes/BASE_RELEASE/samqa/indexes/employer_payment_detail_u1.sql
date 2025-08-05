-- liquibase formatted sql
-- changeset SAMQA:1754373931113 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_u1.sql:null:e7d7d3bd92df1a6679eb31fd57a44b013d28efa7:create

create index samqa.employer_payment_detail_u1 on
    samqa.employer_payment_detail (
        change_num
    );

