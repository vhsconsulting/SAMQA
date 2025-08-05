-- liquibase formatted sql
-- changeset SAMQA:1754374147889 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\claim_edi_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/claim_edi_det_seq.sql:null:fa32ba161ad8a258aa6b161c97f0a3fc0e66a8de:create

create sequence samqa.claim_edi_det_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder
nocycle nokeep noscale global;

