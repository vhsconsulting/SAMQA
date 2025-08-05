-- liquibase formatted sql
-- changeset SAMQA:1754373931145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n2.sql:null:d56fd45e2702d5fb0fc419856297b932785d0f42:create

create index samqa.employer_payments_n2 on
    samqa.employer_payments (
        reason_code,
        entrp_id
    );

