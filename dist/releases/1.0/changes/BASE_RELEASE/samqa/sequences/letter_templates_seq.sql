-- liquibase formatted sql
-- changeset SAMQA:1754374149167 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\letter_templates_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/letter_templates_seq.sql:null:6d9c69b63ccbbc3cc876a96603c4c662d2c4dbc7:create

create sequence samqa.letter_templates_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 321 cache 20 noorder
nocycle nokeep noscale global;

