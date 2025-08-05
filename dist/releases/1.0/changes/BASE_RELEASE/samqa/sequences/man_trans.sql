-- liquibase formatted sql
-- changeset SAMQA:1754374149232 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\man_trans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/man_trans.sql:null:9bb0f4b5a1d749623f227cc51aacb9c14e1349e7:create

create sequence samqa.man_trans minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1263246 cache 20 noorder nocycle
nokeep noscale global;

