-- liquibase formatted sql
-- changeset SAMQA:1754374147777 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cards_v_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cards_v_seq.sql:null:0990453f3e75f544ac07ed7fa8bbeeb3977a9773:create

create sequence samqa.cards_v_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 46 cache 20 noorder nocycle
nokeep noscale global;

