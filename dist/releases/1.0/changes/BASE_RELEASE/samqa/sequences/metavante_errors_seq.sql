-- liquibase formatted sql
-- changeset SAMQA:1754374149325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\metavante_errors_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/metavante_errors_seq.sql:null:d2c355e1bbd80e00ed7f2901fe22de06ebf3d57c:create

create sequence samqa.metavante_errors_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 123658396 cache 20
noorder nocycle nokeep noscale global;

