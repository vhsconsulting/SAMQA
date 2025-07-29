create or replace package samqa.pc_param is

/*
  System parameters
  07.02.2006 MAL + get_value(param_code_in, dat_in)
*/
-- GET current VALUE by parameter code
    function get_value (
        param_code_in in param.param_code%type
    ) return param.param_value%type;
-- GET parameter VALUE on date_in
    function get_value (
        param_code_in in param.param_code%type,
        dat_in        in date
    ) return param.param_value%type;

    function get_system_value (
        param_code_in in param.param_code%type,
        dat_in        in date
    ) return param.param_value%type;

    function get_gl_account return varchar2;

    function get_cash_account (
        p_acc_num in varchar2
    ) return varchar2;

    function get_fsa_irs_limit (
        param_code_in in param.param_code%type,
        p_plan_type   in varchar2,
        dat_in        in date
    ) return param.param_value%type;

end pc_param;
/


-- sqlcl_snapshot {"hash":"7a1fb6ca4c8898f0679c764e03fc925dd1ce14d8","type":"PACKAGE_SPEC","name":"PC_PARAM","schemaName":"SAMQA","sxml":""}