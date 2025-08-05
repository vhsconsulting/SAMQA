-- liquibase formatted sql
-- changeset SAMQA:1754373931105 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n9.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n9.sql:null:472f3662bd5a3db89191ce275954ff504cf93aeb:create

create index samqa.employer_payment_detail_n9 on
    samqa.employer_payment_detail (
        change_num,
        transaction_source
    );

