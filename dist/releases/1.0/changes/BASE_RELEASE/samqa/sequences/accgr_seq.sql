-- liquibase formatted sql
-- changeset SAMQA:1754374147364 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\accgr_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/accgr_seq.sql:null:7ba235f344a19cfc425543cd0172aeac23619248:create

create sequence samqa.accgr_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 71356 nocache noorder nocycle nokeep noscale
global;

