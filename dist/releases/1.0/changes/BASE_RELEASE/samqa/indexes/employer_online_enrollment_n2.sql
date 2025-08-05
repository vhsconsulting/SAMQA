-- liquibase formatted sql
-- changeset SAMQA:1754373931038 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_online_enrollment_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_online_enrollment_n2.sql:null:0b7a36bd8ac4b0496526e0d50bcb038596d44a97:create

create index samqa.employer_online_enrollment_n2 on
    samqa.employer_online_enrollment (
        ein_number
    );

