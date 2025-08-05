-- liquibase formatted sql
-- changeset SAMQA:1754373928138 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\isalphanumeric.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/isalphanumeric.sql:null:e54cc0b45f6ef48064544ada1f7caf53d8a11d98:create

create or replace function samqa.isalphanumeric (
    p_string in varchar2
) return varchar2 is
begin
    if trim(translate(p_string, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+_-.0123456789', ' ')) is not null then
        return trim(translate(p_string, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+_-.0123456789', ' '));
    else
        return null;
    end if;
end;
/

