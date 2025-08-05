create or replace function samqa.date_or_null (
    p_date in varchar2
) return date as
begin
    return to_date ( p_date, 'YYYY-MM-DD' );
exception
    when others then
        return null;
end date_or_null;
/


-- sqlcl_snapshot {"hash":"455181cd99257ce2b1b2f60c89561640253041f3","type":"FUNCTION","name":"DATE_OR_NULL","schemaName":"SAMQA","sxml":""}