-- liquibase formatted sql
-- changeset SAMQA:1754374149293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\metavante_card_balance_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/metavante_card_balance_seq.sql:null:cf5dacfc023c8f0b9547b00a962d00f151ba02a1:create

create sequence samqa.metavante_card_balance_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 554200 cache
20 noorder nocycle nokeep noscale global;

