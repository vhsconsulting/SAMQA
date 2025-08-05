-- liquibase formatted sql
-- changeset SAMQA:1754374149244 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mass_enroll_history_seq_no.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mass_enroll_history_seq_no.sql:null:00d8035169854799597dcb4374a88172f8c047ab:create

create sequence samqa.mass_enroll_history_seq_no minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1714020 cache
20 noorder nocycle nokeep noscale global;

