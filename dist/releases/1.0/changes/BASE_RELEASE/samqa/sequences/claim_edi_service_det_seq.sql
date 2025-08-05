-- liquibase formatted sql
-- changeset SAMQA:1754374147914 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\claim_edi_service_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/claim_edi_service_det_seq.sql:null:2cd6df145cf0d21339b69787c833aa75cb964ed1:create

create sequence samqa.claim_edi_service_det_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20
noorder nocycle nokeep noscale global;

