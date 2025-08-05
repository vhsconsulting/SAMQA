-- liquibase formatted sql
-- changeset SAMQA:1754374148225 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ded_rule_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ded_rule_seq.sql:null:0e61ad9a1c9246ad33d214ee00784b83d36aefd3:create

create sequence samqa.ded_rule_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1500 nocache noorder nocycle
nokeep noscale global;

