-- liquibase formatted sql
-- changeset SAMQA:1754374148213 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ded_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ded_detail_seq.sql:null:759b4c02730aa5af72a63e6ef56d2815aa57dcfc:create

create sequence samqa.ded_detail_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1375 nocache noorder nocycle
nokeep noscale global;

