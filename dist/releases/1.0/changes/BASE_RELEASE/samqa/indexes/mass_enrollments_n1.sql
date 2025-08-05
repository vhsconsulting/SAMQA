-- liquibase formatted sql
-- changeset SAMQA:1754373931961 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enrollments_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enrollments_n1.sql:null:48c62a61e9ad88398938ea156812f32877b8c0b1:create

create index samqa.mass_enrollments_n1 on
    samqa.mass_enrollments (
        entrp_acc_id
    );

