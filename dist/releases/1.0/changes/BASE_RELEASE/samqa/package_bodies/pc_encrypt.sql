-- liquibase formatted sql
-- changeset SAMQA:1754374024615 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_encrypt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_encrypt.sql:null:44378ae47487c2fbc15bd9c89fc6562409970b64:create

create or replace package body samqa.pc_encrypt as
--DO NOT FORGET TO WRAP THIS BEFORE LOADING INTO DATABASE
--IF IT IS NOT WRAPPED, THE KEY WILL BE EXPOSED
--THE WRAP UTILITY IS LOCATED IN THE \BIN DIRECTORY (WRAP.EXE)
    g_character_set   varchar2(10) := 'AL32UTF8';
    g_string          varchar2(32) := '12345678901234567890123456789012';
    g_key             raw(250) := utl_i18n.string_to_raw(
        data        => g_string,
        dst_charset => g_character_set
    );
    g_encryption_type pls_integer := dbms_crypto.encrypt_aes256 + dbms_crypto.chain_cbc + dbms_crypto.pad_pkcs5;

    function encrypt_ssn (
        p_ssn in varchar2
    ) return raw
        deterministic
    is

        l_ssn       raw(32) := utl_i18n.string_to_raw(p_ssn, g_character_set);
        l_encrypted raw(32);
    begin
        l_ssn := utl_i18n.string_to_raw(
            data        => p_ssn,
            dst_charset => g_character_set
        );
        l_encrypted := dbms_crypto.encrypt(
            src => l_ssn,
            typ => g_encryption_type,
            key => g_key
        );

        return l_encrypted;
    end encrypt_ssn;

    function decrypt_ssn (
        p_ssn in raw
    ) return varchar2
        deterministic
    is
        l_decrypted        raw(32);
        l_decrypted_string varchar2(32);
    begin
        l_decrypted := dbms_crypto.decrypt(
            src => p_ssn,
            typ => g_encryption_type,
            key => g_key
        );

        l_decrypted_string := utl_i18n.raw_to_char(
            data        => l_decrypted,
            src_charset => g_character_set
        );
        return l_decrypted_string;
    end decrypt_ssn;

end pc_encrypt;
/

