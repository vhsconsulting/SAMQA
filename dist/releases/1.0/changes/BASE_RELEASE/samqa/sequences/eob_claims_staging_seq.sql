-- liquibase formatted sql
-- changeset SAMQA:1754374148563 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eob_claims_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eob_claims_staging_seq.sql:null:2032d755f9e5ca60d4bcd5b4d54b593d5de0d88b:create

create sequence samqa.eob_claims_staging_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 25779 nocache
noorder nocycle nokeep noscale global;

