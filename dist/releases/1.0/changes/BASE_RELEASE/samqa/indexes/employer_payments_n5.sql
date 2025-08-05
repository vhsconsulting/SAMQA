-- liquibase formatted sql
-- changeset SAMQA:1754373931183 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n5.sql:null:a5b84d4bc0ee42bc76af4a93e64d039755609687:create

create index samqa.employer_payments_n5 on
    samqa.employer_payments (
        plan_type
    );

