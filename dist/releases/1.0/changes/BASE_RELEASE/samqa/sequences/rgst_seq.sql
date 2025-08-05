-- liquibase formatted sql
-- changeset SAMQA:1754374149909 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\rgst_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/rgst_seq.sql:null:19bbf66a7ba8adc5b1ce218506b88b1906ff2a9d:create

create sequence samqa.rgst_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder nocycle nokeep
noscale global;

