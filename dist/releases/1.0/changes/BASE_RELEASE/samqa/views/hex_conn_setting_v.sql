-- liquibase formatted sql
-- changeset SAMQA:1754374175166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\hex_conn_setting_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/hex_conn_setting_v.sql:null:0145bc42f4035df5f6eee5c523595578f7caa643:create

create or replace force editionable view samqa.hex_conn_setting_v (
    eob_connection_status,
    allow_eob,
    carrier_supported,
    tax_id
) as
    select
        a.eob_connection_status,
        a.allow_eob,
        a.carrier_supported,
        replace(b.ssn, '-') tax_id
    from
        insure a,
        person b
    where
        a.pers_id = b.pers_id;

