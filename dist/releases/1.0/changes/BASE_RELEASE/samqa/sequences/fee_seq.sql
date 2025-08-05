-- liquibase formatted sql
-- changeset SAMQA:1754374148787 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\fee_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/fee_seq.sql:null:edfcef7eef3c26d3d9e2a96d3e69d154621e51ab:create

create sequence samqa.fee_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 61 cache 20 noorder nocycle nokeep
noscale global;

