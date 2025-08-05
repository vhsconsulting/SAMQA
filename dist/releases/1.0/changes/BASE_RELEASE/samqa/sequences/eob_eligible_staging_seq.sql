-- liquibase formatted sql
-- changeset SAMQA:1754374148595 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eob_eligible_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eob_eligible_staging_seq.sql:null:888a5decf78777391fbc942215ffb2bc08fbca02:create

create sequence samqa.eob_eligible_staging_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 2 nocache noorder
nocycle nokeep noscale global;

