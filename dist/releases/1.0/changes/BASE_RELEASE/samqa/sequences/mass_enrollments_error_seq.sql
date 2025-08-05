-- liquibase formatted sql
-- changeset SAMQA:1754374149262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mass_enrollments_error_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mass_enrollments_error_seq.sql:null:a2d91eaacf1190c8a19af37db7179d7fa913b63c:create

create sequence samqa.mass_enrollments_error_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20
noorder nocycle nokeep noscale global;

