-- liquibase formatted sql
-- changeset SAMQA:1753779761619 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\entrp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/entrp_seq.sql:null:49b5edc42df986c21496b5639439d289466e6d67:create

create sequence samqa.entrp_seq minvalue 1 maxvalue 999999999 increment by 1 start with 64548 nocache noorder nocycle nokeep noscale global
;

