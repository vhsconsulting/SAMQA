-- liquibase formatted sql
-- changeset SAMQA:1754374034275 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_incident.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_incident.sql:null:709c4fde8d04a7202cb20a17b9a62036fdc4e01d:create

create or replace package body samqa.pc_incident as
/*
   This package is used for INCIDENT TICKET SYSTEM
   All general functions
   Created by Yang, 20240320
*/

    procedure get_user_dept (
        p_user      in varchar2,
        p_dept_name out varchar2,
        p_dept_code out varchar2,
        p_emp_id    out number
    ) as
    begin
    -- TODO: Implementation required for PROCEDURE PC_INCIDENT.get_user_dept
        select
            nvl(b.dept_code, 'NONE'),
            nvl(b.dept_name, 'NONE'),
            a.emp_id
        into
            p_dept_code,
            p_dept_name,
            p_emp_id
        from
            employee   a,
            department b
        where
                a.dept_no = b.dept_no
            and a.user_id = get_user_id(p_user);

    exception
        when no_data_found then
            p_dept_name := 'NONE';
            p_dept_code := 'NONE';
    end;

end pc_incident;
/

