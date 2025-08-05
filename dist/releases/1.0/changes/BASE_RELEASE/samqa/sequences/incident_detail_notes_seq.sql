-- liquibase formatted sql
-- changeset SAMQA:1754374148975 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\incident_detail_notes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/incident_detail_notes_seq.sql:null:830bfc3e80c6e296584ef8264a961fb9b8950774:create

create sequence samqa.incident_detail_notes_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20
noorder nocycle nokeep noscale global;

