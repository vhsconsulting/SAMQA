-- liquibase formatted sql
-- changeset SAMQA:1754373927880 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_reason_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_reason_name.sql:null:3dfbbad468f7a6c8cf4ee29b88144c2683ff255f:create

create or replace function samqa.get_reason_name (
    p_mode        in varchar2,
    p_reason_code in varchar2
) return varchar2 is
    l_reason_name varchar2(300);
begin
    if p_mode = 'I' then
        select
            fee_name
        into l_reason_name
        from
            fee_names e
        where
            e.fee_code = p_reason_code;

    elsif p_mode = 'F' then
        l_reason_name := 'Fee Bucket';
    else
        select
            reason_name
        into l_reason_name
        from
            pay_reason a
        where
            a.reason_code = p_reason_code;

    end if;

    return l_reason_name;
end;
/

