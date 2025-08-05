-- liquibase formatted sql
-- changeset SAMQA:1754373927354 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_date.sql:null:cb96be7ce390dce01469587b30bb7bb89cb06df0:create

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

