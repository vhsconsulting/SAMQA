-- liquibase formatted sql
-- changeset SAMQA:1753779761632 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\entrp_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/entrp_staging_seq.sql:null:d60ddd141280c6e1f6a9f0a9ef702a8ec5752b1e:create

create sequence samqa.entrp_staging_seq minvalue 1 maxvalue 999999999 increment by 1 start with 385653 nocache noorder nocycle nokeep
noscale global;

