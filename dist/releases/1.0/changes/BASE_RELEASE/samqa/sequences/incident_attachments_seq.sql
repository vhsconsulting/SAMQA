-- liquibase formatted sql
-- changeset SAMQA:1754374148975 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\incident_attachments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/incident_attachments_seq.sql:null:1d2b8f8eb217c338b81d0343bcf0ffc63a0f04cf:create

create sequence samqa.incident_attachments_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 13323 cache
20 noorder nocycle nokeep noscale global;

