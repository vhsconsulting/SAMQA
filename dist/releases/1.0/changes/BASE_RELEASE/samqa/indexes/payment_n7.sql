-- liquibase formatted sql
-- changeset SAMQA:1754373932722 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_n7.sql:null:d055c4c22fd009faa5e290ab0227ecd1359efa94:create

create index samqa.payment_n7 on
    samqa.payment (
        pay_date
    );

