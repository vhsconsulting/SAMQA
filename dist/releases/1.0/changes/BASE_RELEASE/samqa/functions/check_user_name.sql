-- liquibase formatted sql
-- changeset SAMQA:1754373927014 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\check_user_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/check_user_name.sql:null:84b38d5aa2c0bccb6c7590d155e6ff8c4f51e8c6:create

create or replace function samqa.check_user_name (
    p_user_name in varchar2
) return varchar2 is
begin
    if
        ( regexp_like(
            upper(p_user_name),
            '^.*[A-Z].*$'
        )
        or (
            regexp_like(
                upper(p_user_name),
                '^.*[A-Z].*$'
            )
            and regexp_like(
                upper(p_user_name),
                '^.*[0-9].*$'
            )
        ) )
        and not regexp_like(
            upper(p_user_name),
            '^.*[^A-Z,0-9].*$'
        )
    then
        return 'Y';
    else
        return 'N';
    end if;
end;
/

