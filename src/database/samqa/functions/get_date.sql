create or replace function samqa.get_date (
    p_in     in varchar2,
    p_format in varchar2 default 'MMDDYYYY'
) return varchar2 is
    t_date date;
begin
    begin
        t_date := to_date ( p_in,
                            p_format );
        return t_date;
    exception
        when others then
            null;
    end;
end;
/


-- sqlcl_snapshot {"hash":"cb96be7ce390dce01469587b30bb7bb89cb06df0","type":"FUNCTION","name":"GET_DATE","schemaName":"SAMQA","sxml":""}