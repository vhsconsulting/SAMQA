create or replace package samqa.pc_log as

/******************************************************************************
   NAME:       pc_log
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29.03.2005      MAL       1. Created this package.
******************************************************************************/

    function ip2name (
        ip_in in varchar2
    ) return varchar2;

    function whoami return varchar2;

    procedure audi (
        tbl_in  in varchar2,
        fld_in  in varchar2,
        old_in  in varchar2,
        new_in  in varchar2,
        cod1_in in varchar2,
        cod2_in in varchar2 := null,
        cod3_in in varchar2 := null
    );

    curuser varchar2(100);
    procedure log_error (
        p_action  in varchar2,
        p_message in varchar2
    );

    procedure log_app_error (
        p_package_name    in varchar2,
        p_procedure_name  in varchar2,
        p_call_stack      in varchar2,
        p_error_stack     in varchar2,
        p_error_backtrace in varchar2,
        p_params          in varchar2 default null
    );

    procedure app_logs (
        p_error_backtrace in varchar2,
        p_params          in varchar2 default null
    );

  -- Added by Reddy for Server migration.
    procedure log_batch_job_result (
        p_job_name       in varchar2,
        p_error_code     in number,
        p_error_message  in varchar2,
        p_component_info in clob,
        p_start_date     in date default sysdate,
        p_end_date       in date default sysdate
    );

end pc_log;
/


-- sqlcl_snapshot {"hash":"57eb63af74defceca1b75bf9993632f8c2e8d865","type":"PACKAGE_SPEC","name":"PC_LOG","schemaName":"SAMQA","sxml":""}