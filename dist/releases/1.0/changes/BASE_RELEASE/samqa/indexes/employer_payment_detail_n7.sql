-- liquibase formatted sql
-- changeset SAMQA:1754373931097 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n7.sql:null:ade01f5c1ae7f313a592cacaa295cb6751157a31:create

create index samqa.employer_payment_detail_n7 on
    samqa.employer_payment_detail (
        check_number
    );

