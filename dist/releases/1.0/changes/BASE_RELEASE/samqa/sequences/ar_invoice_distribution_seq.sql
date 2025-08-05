-- liquibase formatted sql
-- changeset SAMQA:1754374147517 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ar_invoice_distribution_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ar_invoice_distribution_seq.sql:null:ce5380c3b90af9ac3f6e25d2731c374ed9867f13:create

create sequence samqa.ar_invoice_distribution_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 7266375 cache
20 noorder nocycle nokeep noscale global;

