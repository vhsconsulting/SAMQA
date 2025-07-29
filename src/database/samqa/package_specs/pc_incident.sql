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


-- sqlcl_snapshot {"hash":"1da49dca1840ed97f9b4830cff1f5f4262e62708","type":"PACKAGE_SPEC","name":"PC_INCIDENT","schemaName":"SAMQA","sxml":""}