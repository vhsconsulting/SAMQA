-- liquibase formatted sql
-- changeset SAMQA:1754373927734 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_lookup_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_lookup_code.sql:null:62cc28e428a4abf5562fcafb4a86d9d8393ff7dc:create

create or replace function samqa.get_lookup_code (
    p_lookup_name in varchar2,
    p_description in varchar2
) return varchar2 is
    l_lookup_code varchar2(30);
begin
    select
        lookup_code
    into l_lookup_code
    from
        lookups
    where
            lookup_name = p_lookup_name
        and upper(description) like upper(p_description)
                                    || '%';

    return l_lookup_code;
end get_lookup_code;
/

