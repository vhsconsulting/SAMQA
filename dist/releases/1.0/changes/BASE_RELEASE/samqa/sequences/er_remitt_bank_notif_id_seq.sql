-- liquibase formatted sql
-- changeset SAMQA:1754374148658 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\er_remitt_bank_notif_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/er_remitt_bank_notif_id_seq.sql:null:c5c913ae7c3ab9fcb80a82f85801aa6971808bc2:create

create sequence samqa.er_remitt_bank_notif_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 221 cache
20 noorder nocycle nokeep noscale global;

