-- liquibase formatted sql
-- changeset SAMQA:1754374148911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\gp_ap_ar_txn_outbnd_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/gp_ap_ar_txn_outbnd_seq.sql:null:1d37b0b036aa824484ba5df1159ac06b387b9c77:create

create sequence samqa.gp_ap_ar_txn_outbnd_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1354321 cache
20 noorder nocycle nokeep noscale global;

