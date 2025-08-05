-- liquibase formatted sql
-- changeset SAMQA:1754373931120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_u2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_u2.sql:null:53064496e31d9f7b224ae93a1cb05e64c89f0f0d:create

create index samqa.employer_payment_detail_u2 on
    samqa.employer_payment_detail (
        transaction_id
    );

