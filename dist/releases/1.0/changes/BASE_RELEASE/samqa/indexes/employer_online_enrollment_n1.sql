-- liquibase formatted sql
-- changeset SAMQA:1754373931030 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_online_enrollment_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_online_enrollment_n1.sql:null:c974907636a7e47543441e505c3c94405bdb8fed:create

create index samqa.employer_online_enrollment_n1 on
    samqa.employer_online_enrollment (
        acc_num,
        entrp_id
    );

