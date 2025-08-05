-- liquibase formatted sql
-- changeset SAMQA:1754373931537 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\fraud_verifications_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/fraud_verifications_n1.sql:null:07d30e30cd712c2e27c9c8fa557996f798e99637:create

create index samqa.fraud_verifications_n1 on
    samqa.fraud_verifications (
        acc_id
    );

