-- liquibase formatted sql
-- changeset SAMQA:1754373927030 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\custom_hash.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/custom_hash.sql:null:b4cecde706d2f493f5f9d0c2a4f4bde238941712:create

create or replace function samqa.custom_hash (
    p_username in varchar2,
    p_password in varchar2
) return varchar2 is
    l_password varchar2(4000);
    l_salt     varchar2(4000) := '65KCKP86IDUXN1ZP4MI7K3HSPOIQ76';
begin

-- This function should be wrapped, as the hash algorhythm is exposed here.
-- You can change the value of l_salt or the method of which to call the
-- DBMS_OBFUSCATOIN toolkit, but you much reset all of your passwords
-- if you choose to do this.

    l_password := utl_raw.cast_to_raw(dbms_obfuscation_toolkit.md5(input_string => p_password
                                                                                   || substr(l_salt, 10, 13)
                                                                                   || p_username
                                                                                   || substr(l_salt, 4, 10)));

    return l_password;
end;
/

