-- liquibase formatted sql
-- changeset SAMQA:1754374150095 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\scheduler_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/scheduler_stage_seq.sql:null:f03104f8b61afa6f5e019c221546eb53eee02d3a:create

create sequence samqa.scheduler_stage_seq minvalue 1 maxvalue 999999999 increment by 1 start with 81742 nocache noorder nocycle nokeep
noscale global;

