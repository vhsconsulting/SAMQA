-- liquibase formatted sql
-- changeset SAMQA:1754373931089 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n6.sql:null:eac57a33776c45a8df5ccdddcbea2c24fc861912:create

create index samqa.employer_payment_detail_n6 on
    samqa.employer_payment_detail (
        employer_payment_id
    );

