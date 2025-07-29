create or replace 
PACKAGE BODY SAMQA.pc_encrypt
AS
--DO NOT FORGET TO WRAP THIS BEFORE LOADING INTO DATABASE
--IF IT IS NOT WRAPPED, THE KEY WILL BE EXPOSED
--THE WRAP UTILITY IS LOCATED IN THE \BIN DIRECTORY (WRAP.EXE)
  G_CHARACTER_SET VARCHAR2(10) := 'AL32UTF8';
  G_STRING VARCHAR2(32) := '12345678901234567890123456789012';
  G_KEY RAW(250) := utl_i18n.string_to_raw
                      ( data => G_STRING,
                        dst_charset => G_CHARACTER_SET );
  G_ENCRYPTION_TYPE PLS_INTEGER := dbms_crypto.encrypt_aes256 
                                    + dbms_crypto.chain_cbc 
                                    + dbms_crypto.pad_pkcs5;
  
  FUNCTION encrypt_ssn( p_ssn IN VARCHAR2 ) RETURN RAW deterministic
  IS
    l_ssn RAW(32) := UTL_I18N.STRING_TO_RAW( p_ssn, G_CHARACTER_SET );
    l_encrypted RAW(32);
  BEGIN
    l_ssn := utl_i18n.string_to_raw
              ( data => p_ssn,
                dst_charset => G_CHARACTER_SET );

    l_encrypted := dbms_crypto.encrypt
                   ( src => l_ssn,
                     typ => G_ENCRYPTION_TYPE,
                     key => G_KEY );
                     
    RETURN l_encrypted;
  END encrypt_ssn;
  
  FUNCTION decrypt_ssn( p_ssn IN RAW ) RETURN VARCHAR2 deterministic
  IS
    l_decrypted RAW(32);
    l_decrypted_string VARCHAR2(32);
  BEGIN
    l_decrypted := dbms_crypto.decrypt
                    ( src => p_ssn,
                      typ => G_ENCRYPTION_TYPE,
                      key => G_KEY );

    l_decrypted_string := utl_i18n.raw_to_char
                            ( data => l_decrypted,
                              src_charset => G_CHARACTER_SET );
    RETURN l_decrypted_string;
  END decrypt_ssn;
  
END pc_encrypt;
/



-- sqlcl_snapshot {"hash":"451345e19d42585a53ff2afa637f50a3791ccfcf","type":"PACKAGE_BODY","name":"PC_ENCRYPT","schemaName":"SAMQA","sxml":""}