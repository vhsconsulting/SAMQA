-- liquibase formatted sql
-- changeset SAMQA:1754374150171 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\system_parameters_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/system_parameters_seq.sql:null:9df67f1453e54fef4cdd3b8e90a1f54217078070:create

create sequence samqa.system_parameters_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 62 cache 20 noorder
nocycle nokeep noscale global;

