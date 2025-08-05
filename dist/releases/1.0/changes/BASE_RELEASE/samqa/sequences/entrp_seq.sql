-- liquibase formatted sql
-- changeset SAMQA:1754374148548 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\entrp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/entrp_seq.sql:null:d794384cb3e1f4a68d571e94fb0b33f9227a31ee:create

create sequence samqa.entrp_seq minvalue 1 maxvalue 999999999 increment by 1 start with 64651 nocache noorder nocycle nokeep noscale global
;

