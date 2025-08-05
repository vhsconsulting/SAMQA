-- liquibase formatted sql
-- changeset SAMQA:1754373928014 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_user_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_user_name.sql:null:a82730ec735e208543be7c54646118885201d8a9:create

create or replace function samqa.get_user_name (
    p_user_id in number
) return varchar2 is
    tmpvar varchar2(30);
/******************************************************************************
   NAME:       GET_USER_NAME
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        4/6/2009          1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     GET_USER_NAME
      Sysdate:         4/6/2009
      Date and Time:   4/6/2009, 1:14:31 AM, and 4/6/2009 1:14:31 AM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
begin
    select
        user_name
    into tmpvar
    from
        sam_users
    where
        user_id = p_user_id;

    return tmpvar;
exception
    when no_data_found then
        return null;
    when others then
       -- Consider logging the error and then re-raise
        raise;
end get_user_name;
/

