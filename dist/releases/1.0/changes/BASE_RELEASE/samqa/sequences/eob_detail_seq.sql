-- liquibase formatted sql
-- changeset SAMQA:1754374148579 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eob_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eob_detail_seq.sql:null:c3a222aca4680db96497ea3630f36bbf725a0227:create

create sequence samqa.eob_detail_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 3725 nocache noorder nocycle
nokeep noscale global;

