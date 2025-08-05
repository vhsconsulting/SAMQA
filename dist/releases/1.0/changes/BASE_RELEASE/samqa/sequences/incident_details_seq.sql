-- liquibase formatted sql
-- changeset SAMQA:1754374148991 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\incident_details_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/incident_details_seq.sql:null:ae85d9c5798f95790acc7674c933ad8729b24d8c:create

create sequence samqa.incident_details_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 26021 cache 20 noorder
nocycle nokeep noscale global;

