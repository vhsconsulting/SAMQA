-- liquibase formatted sql
-- changeset SAMQA:1754373930943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_deposits_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_deposits_n7.sql:null:7c5688d09ff1f2f141b9c496ab4257c882867c80:create

create index samqa.employer_deposits_n7 on
    samqa.employer_deposits (
        pay_code
    );

