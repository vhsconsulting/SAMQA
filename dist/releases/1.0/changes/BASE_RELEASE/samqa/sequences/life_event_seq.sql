-- liquibase formatted sql
-- changeset SAMQA:1754374149182 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\life_event_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/life_event_seq.sql:null:3819ceda26e943f20176191b1b0046c5eedb7b6c:create

create sequence samqa.life_event_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 25305 nocache noorder nocycle
nokeep noscale global;

