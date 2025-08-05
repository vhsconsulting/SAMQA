-- liquibase formatted sql
-- changeset SAMQA:1754374073796 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_param.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_param.sql:null:7377936af52ee645276bcdbbd12830f3a1704561:create

create or replace package body samqa.pc_param is

-- GET current VALUE by parameter code
    function get_value (
        param_code_in in param.param_code%type
    ) return param.param_value%type is

        cursor c1 (
            p_parm_code param.param_code%type
        ) is
        select
            param_value
        from
            system_parameters
        where
                param_code = p_parm_code
            and to_char(effective_date, 'YYYY') = to_char(sysdate, 'YYYY');

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(upper(param_code_in));
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.param_value;
        else
            return null;
        end if;
    end get_value;

    function get_fsa_irs_limit (
        param_code_in in param.param_code%type,
        p_plan_type   in varchar2,
        dat_in        in date
    ) return param.param_value%type is

        cursor c1 (
            p_parm_code param.param_code%type
        ) is
        select
            param_value
        from
            system_parameters
        where
                param_code = p_parm_code
            and to_char(effective_date, 'YYYY') = to_char(dat_in, 'YYYY')
            and account_type = 'FSA'
            and plan_type = p_plan_type
        order by
            effective_date desc;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(upper(param_code_in));
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.param_value;
        else
            return get_value(param_code_in);
        end if;
    end get_fsa_irs_limit;
-- GET parameter VALUE on date_in
    function get_value (
        param_code_in in param.param_code%type,
        dat_in        in date
    ) return param.param_value%type is

        cursor c1 (
            p_parm_code param.param_code%type
        ) is
        select
            param_value
        from
            system_parameters
        where
                param_code = p_parm_code
            and to_char(effective_date, 'YYYY') = to_char(dat_in, 'YYYY')
        order by
            effective_date desc;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(upper(param_code_in));
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.param_value;
        else
            return get_value(param_code_in);
        end if;
    end get_value;

    function get_system_value (
        param_code_in in param.param_code%type,
        dat_in        in date
    ) return param.param_value%type is

        cursor c1 (
            p_parm_code param.param_code%type
        ) is
        select
            param_value
        from
            system_parameters
        where
                param_code = p_parm_code
            and to_char(effective_date, 'YYYY') = to_char(dat_in, 'YYYY')
        order by
            effective_date desc;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(upper(param_code_in));
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.param_value;
        else
            return get_value(param_code_in);
        end if;
    end get_system_value;

    function get_gl_account return varchar2 is
        l_acc_num varchar2(30);
    begin
        for x in (
            select
                account_num
            from
                payment_acc_info
            where
                account_type = 'GL_ACCOUNT'
        ) loop
            l_acc_num := x.account_num;
        end loop;

        return l_acc_num;
    end get_gl_account;

    function get_cash_account (
        p_acc_num in varchar2
    ) return varchar2 is
        l_acc_num varchar2(30);
    begin
        for x in (
            select
                nvl((
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                        substr(account_type, 1, 3) like substr(p_acc_num, 1, 3)
                                                        || '%'
                        and status = 'A'
                ),
                    (
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                            substr(account_type, 1, 3) = 'SHA'
                        and status = 'A'
                )) account_num
            from
                dual
        ) loop
            l_acc_num := x.account_num;
        end loop;

        return l_acc_num;
    end get_cash_account;

end pc_param;
/

