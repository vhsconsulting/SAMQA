-- liquibase formatted sql
-- changeset SAMQA:1753779760690 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\batch_num_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/batch_num_seq.sql:null:2709571f066e61c7f2a41881ccde504b3560c7a5:create

create sequence samqa.batch_num_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2720264 cache 20 noorder
nocycle nokeep noscale global;

