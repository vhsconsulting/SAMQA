-- liquibase formatted sql
-- changeset SAMQA:1754374147603 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\batch_num_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/batch_num_seq.sql:null:f87534ce1d9ab63678991509fb6be8b72bef5f47:create

create sequence samqa.batch_num_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2720604 cache 20 noorder
nocycle nokeep noscale global;

