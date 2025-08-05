-- liquibase formatted sql
-- changeset SAMQA:1754373932710 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_n6.sql:null:6ee1cb775f269615fa0c556bbdf258cb6defcc8c:create

create index samqa.payment_n6 on
    samqa.payment (
        pay_num
    );

