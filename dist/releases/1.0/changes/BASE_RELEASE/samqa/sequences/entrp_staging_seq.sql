-- liquibase formatted sql
-- changeset SAMQA:1754374148548 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\entrp_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/entrp_staging_seq.sql:null:e0481106ccdbbb94899e523ca3df060acb5c5d04:create

create sequence samqa.entrp_staging_seq minvalue 1 maxvalue 999999999 increment by 1 start with 385817 nocache noorder nocycle nokeep
noscale global;

