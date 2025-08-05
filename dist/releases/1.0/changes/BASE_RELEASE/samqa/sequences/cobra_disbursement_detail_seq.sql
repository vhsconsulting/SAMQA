-- liquibase formatted sql
-- changeset SAMQA:1754374147966 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cobra_disbursement_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cobra_disbursement_detail_seq.sql:null:a04ea264de0f730e8dbf7e63ce84a21b539dabec:create

create sequence samqa.cobra_disbursement_detail_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 615343
cache 20 noorder nocycle nokeep noscale global;

