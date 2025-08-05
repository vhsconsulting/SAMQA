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


-- sqlcl_snapshot {"hash":"a4e3e6829b246324faca487c4185ca938c9f6c43","type":"PACKAGE_SPEC","name":"PC_ENCRYPT","schemaName":"SAMQA","sxml":""}