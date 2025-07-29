-- liquibase formatted sql
-- changeset SAMQA:1753779762326 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mass_enroll_history_seq_no.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mass_enroll_history_seq_no.sql:null:a100c5605a0fffa24560662a6494ef0364a1871a:create

create sequence samqa.mass_enroll_history_seq_no minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1714000 cache
20 noorder nocycle nokeep noscale global;

