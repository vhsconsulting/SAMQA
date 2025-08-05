-- liquibase formatted sql
-- changeset SAMQA:1754374150196 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\termination_interface_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/termination_interface_seq.sql:null:8f560cb4ddd6eb4da6faadc4eeda60999866cf23:create

create sequence samqa.termination_interface_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 172775 cache
20 noorder nocycle nokeep noscale global;

