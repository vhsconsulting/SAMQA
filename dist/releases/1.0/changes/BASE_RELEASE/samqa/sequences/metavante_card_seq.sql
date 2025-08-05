-- liquibase formatted sql
-- changeset SAMQA:1754374149312 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\metavante_card_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/metavante_card_seq.sql:null:541217ae61a7bd92d6cee87d8d3b968ff4b705bf:create

create sequence samqa.metavante_card_seq minvalue 0 maxvalue 999999999999999999999999999 increment by 1 start with 2091475059 nocache
noorder nocycle nokeep noscale global;

