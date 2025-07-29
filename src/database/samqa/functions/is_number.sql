create or replace function samqa.is_number (
    str_in in varchar2
) return varchar2 is
    n number;
begin
    n := to_number ( str_in );
    return 'Y';
exception
    when value_error then
        return 'N';
end;
/


-- sqlcl_snapshot {"hash":"1f079a7f25518eec7a5090592df4173cab16a037","type":"FUNCTION","name":"IS_NUMBER","schemaName":"SAMQA","sxml":""}