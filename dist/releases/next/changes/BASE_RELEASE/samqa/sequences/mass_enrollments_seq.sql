-- liquibase formatted sql
-- changeset SAMQA:1753779762363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mass_enrollments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mass_enrollments_seq.sql:null:3957669bd7d8dd35e9e86cc7b3a1c3af44ffa4c8:create

create sequence samqa.mass_enrollments_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 12149217 cache 20
noorder nocycle nokeep noscale global;

