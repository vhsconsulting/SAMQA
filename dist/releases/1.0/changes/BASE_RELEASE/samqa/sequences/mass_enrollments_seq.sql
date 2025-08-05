-- liquibase formatted sql
-- changeset SAMQA:1754374149277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mass_enrollments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mass_enrollments_seq.sql:null:9a7463ada4361a23247f42fc7aaba8d708755713:create

create sequence samqa.mass_enrollments_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 12149297 cache 20
noorder nocycle nokeep noscale global;

