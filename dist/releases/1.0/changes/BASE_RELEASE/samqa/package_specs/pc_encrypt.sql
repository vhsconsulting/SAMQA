-- liquibase formatted sql
-- changeset SAMQA:1754374137319 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_encrypt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_encrypt.sql:null:a4e3e6829b246324faca487c4185ca938c9f6c43:create

create or replace package samqa.pc_encrypt as
    function encrypt_ssn (
        p_ssn in varchar2
    ) return raw
        deterministic;

    function decrypt_ssn (
        p_ssn in raw
    ) return varchar2
        deterministic;

end pc_encrypt;
/

