-- liquibase formatted sql
-- changeset SAMQA:1754373931082 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n5.sql:null:958be7b88e360716504b094453d54b9b0bcac409:create

create index samqa.employer_payment_detail_n5 on
    samqa.employer_payment_detail (
        paid_date
    );

