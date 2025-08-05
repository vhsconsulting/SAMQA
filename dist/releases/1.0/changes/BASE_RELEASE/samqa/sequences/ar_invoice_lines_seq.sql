-- liquibase formatted sql
-- changeset SAMQA:1754374147529 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ar_invoice_lines_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ar_invoice_lines_seq.sql:null:ec8e4f017734e8e767763890323207783192681a:create

create sequence samqa.ar_invoice_lines_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1221188 cache 20
noorder nocycle nokeep noscale global;

