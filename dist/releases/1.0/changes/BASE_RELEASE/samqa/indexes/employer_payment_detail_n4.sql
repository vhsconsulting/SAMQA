-- liquibase formatted sql
-- changeset SAMQA:1754373931075 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n4.sql:null:f1e7ed33c92369074f40821949d06d1fa236c21c:create

create index samqa.employer_payment_detail_n4 on
    samqa.employer_payment_detail (
        product_type
    );

