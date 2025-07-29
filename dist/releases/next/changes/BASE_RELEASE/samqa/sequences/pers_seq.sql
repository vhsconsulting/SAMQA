-- liquibase formatted sql
-- changeset SAMQA:1753779762776 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\pers_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/pers_seq.sql:null:f662bf595dcc2a40ceb5fc8e1c2926642e6070ad:create

create sequence samqa.pers_seq minvalue 1 maxvalue 999999999 increment by 1 start with 3898309 nocache noorder nocycle nokeep noscale
global;

