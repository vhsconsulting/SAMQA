-- liquibase formatted sql
-- changeset SAMQA:1754373927775 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_prefix_user_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_prefix_user_id.sql:null:ae68d824dfa949491c66df7459e6eb6958fd6241:create

create or replace function samqa.get_prefix_user_id (
    p_prefix in varchar2
) return number is
    l_user_id number;
begin
    l_user_id := null;
    pc_log.log_error('get_prefix_user_id ',
                     p_prefix
                     || ' '
                     || length(replace(p_prefix, ' ', '')));

    for x in (
        select
            *
        from
            sam_users
        where
                substr(user_name, 1, 2) = replace(p_prefix, ' ', '')
            and user_name not in ( 'jraj', 'pghosh' )
        order by
            user_id
    ) loop
        pc_log.log_error('get_prefix_user_id,user_name ', x.user_name);
        l_user_id := x.user_id;
    end loop;

    return l_user_id;
end get_prefix_user_id;
/

