-- liquibase formatted sql
-- changeset SAMQA:1754373928110 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\is_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/is_date.sql:null:55de98cea81d5652614593ea15e9950e30bd4b27:create

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

