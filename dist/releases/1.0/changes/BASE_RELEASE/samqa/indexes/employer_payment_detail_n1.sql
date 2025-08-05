-- liquibase formatted sql
-- changeset SAMQA:1754373931046 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payment_detail_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payment_detail_n1.sql:null:e5d0dcc1a2ca43137ceeb52ab5281a7045da8626:create

create index samqa.employer_payment_detail_n1 on
    samqa.employer_payment_detail (
        entrp_id
    );

