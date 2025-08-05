-- liquibase formatted sql
-- changeset SAMQA:1754374148769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\fee_names_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/fee_names_seq.sql:null:11f66cd4e2bbeacc0285ed5abe64337c651b4d24:create

create sequence samqa.fee_names_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 170 cache 20 noorder nocycle
nokeep noscale global;

