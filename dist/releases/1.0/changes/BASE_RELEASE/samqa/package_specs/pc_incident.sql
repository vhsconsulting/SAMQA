-- liquibase formatted sql
-- changeset SAMQA:1754374138073 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_incident.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_incident.sql:null:1da49dca1840ed97f9b4830cff1f5f4262e62708:create

create or replace package samqa.pc_incident as 

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
    );

end pc_incident;
/

