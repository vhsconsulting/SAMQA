create or replace function samqa.format_money (
    p_value_num number
) return varchar2 is
    returnstring varchar2(100);
begin
    if ( p_value_num >= 1000000 ) then
        returnstring := ltrim(to_char(p_value_num, '$999,999,999.00'));
    elsif
        ( p_value_num < 1000000 )
        and ( p_value_num >= 1000 )
    then
        returnstring := ltrim(to_char(p_value_num, '$999,999.00'));
    elsif p_value_num = 0 then
        returnstring := '$0.00';
    elsif p_value_num < 0 then
        returnstring := '('
                        || ltrim(to_char(p_value_num, '$999,999.00'))
                        || ')';
    else
        returnstring := ltrim(to_char(p_value_num, '$999.00'));
    end if;

    return returnstring;
exception
    when others then
        raise_application_error(-20123,
                                'Error occurred in MONEY '
                                || 'function for incoming value:'
                                || to_char(p_value_num)
                                || ' and outgoing value:'
                                || returnstring);
end format_money;
/


-- sqlcl_snapshot {"hash":"d4bed71a95f0ec9f65393a3c639cc55c472e84b9","type":"FUNCTION","name":"FORMAT_MONEY","schemaName":"SAMQA","sxml":""}