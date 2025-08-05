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


-- sqlcl_snapshot {"hash":"e54cc0b45f6ef48064544ada1f7caf53d8a11d98","type":"FUNCTION","name":"ISALPHANUMERIC","schemaName":"SAMQA","sxml":""}