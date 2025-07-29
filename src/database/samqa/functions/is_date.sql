create or replace function samqa.is_date (
    p_in     in varchar2,
    p_format in varchar2 default 'MMDDRRRR'
) return varchar2 is
    t_date date;
begin
    if p_in is null then
        return 'Y';
    end if;
    begin
        t_date := to_date ( p_in,
                            p_format );
        return 'Y';
    exception
        when others then
            return 'N';
    end;

end;
/


-- sqlcl_snapshot {"hash":"55de98cea81d5652614593ea15e9950e30bd4b27","type":"FUNCTION","name":"IS_DATE","schemaName":"SAMQA","sxml":""}