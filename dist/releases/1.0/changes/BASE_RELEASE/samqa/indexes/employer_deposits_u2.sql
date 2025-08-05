-- liquibase formatted sql
-- changeset SAMQA:1754373930961 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_deposits_u2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_deposits_u2.sql:null:cd97f608370559b96378e34658877b23d2869f23:create

create index samqa.employer_deposits_u2 on
    samqa.employer_deposits (
        list_bill
    );

