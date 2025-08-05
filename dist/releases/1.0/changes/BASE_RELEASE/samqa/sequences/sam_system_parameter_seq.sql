-- liquibase formatted sql
-- changeset SAMQA:1754374150012 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sam_system_parameter_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sam_system_parameter_seq.sql:null:2ba57423b80b2583b02ce156d48e82bc5816d899:create

create sequence samqa.sam_system_parameter_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 981 cache 20
noorder nocycle nokeep noscale global;

