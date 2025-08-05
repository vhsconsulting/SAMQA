-- liquibase formatted sql
-- changeset SAMQA:1754374147991 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cobra_disbursements_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cobra_disbursements_seq.sql:null:3ebbc27392d01bc4465ef2d0fda358ccefb459e3:create

create sequence samqa.cobra_disbursements_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 265366 cache
20 noorder nocycle nokeep noscale global;

