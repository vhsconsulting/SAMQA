-- liquibase formatted sql
-- changeset SAMQA:1754374147978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cobra_disbursement_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cobra_disbursement_staging_seq.sql:null:e2c878cf670667ce07085166518195571b8a2457:create

create sequence samqa.cobra_disbursement_staging_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 895228
cache 20 noorder nocycle nokeep noscale global;

