-- liquibase formatted sql
-- changeset SAMQA:1754373931054 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n2.sql:null:3733ccab352e8e2ca09e5d52d5a63e892f6011f0:create

create index samqa.employer_payment_detail_n2 on
    samqa.employer_payment_detail (
        check_num
    );

