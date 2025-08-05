-- liquibase formatted sql
-- changeset SAMQA:1754374052145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_log.sql:null:e0b7f0501db97673c641dee6f9bece894e00ef43:create

create or replace package body samqa.pc_log as

/******************************************************************************
   NAME:       pc_log
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29.03.2005      MAL       1. Created this package body.
******************************************************************************/

    function ip2name (
        ip_in in varchar2
    ) return varchar2 is
        cursor c1 is
        select
            uname
        from
            userip
        where
            ip_addr = ip_in;

        r1 c1%rowtype;
    begin
        open c1;
        fetch c1 into r1;
        close c1;
        return nvl(r1.uname, ip_in);
    end;

    function whoami return varchar2 is
        vstr varchar2(100);
    begin
        if pc_log.curuser is null then
       --vstr := ip2name(Pc_Sec_Web.get_ip_address);
            pc_log.curuser := user
                              || ' '
                              || userenv('TERMINAL')
                              || ' '
                              || vstr;

            dbms_output.put_line('User ' || pc_log.curuser);
        end if;

        return pc_log.curuser;
    end;

    procedure audi (
        tbl_in  in varchar2,
        fld_in  in varchar2,
        old_in  in varchar2,
        new_in  in varchar2,
        cod1_in in varchar2,
        cod2_in in varchar2 := null,
        cod3_in in varchar2 := null
    ) is
/* ???????????? ? ????????? ??????.   29.03.2005 mal */
    begin
        if nvl(old_in, '|') <> nvl(new_in, '|') then
            insert into all_audit (
                who,
                table_name,
                field_name,
                old_value,
                new_value,
                cod1,
                cod2,
                cod3
            ) values ( pc_log.curuser,
                       tbl_in,
                       fld_in,
                       old_in,
                       new_in,
                       cod1_in,
                       cod2_in,
                       cod3_in );

        end if;
    exception
        when others then
            raise_application_error(-20002, 'AUDI '
                                            || tbl_in
                                            || ' '
                                            || fld_in
                                            || ' '
                                            || sqlerrm
                                            || ' '
                                            || pc_log.curuser);
    end audi;

    procedure log_error (
        p_action  in varchar2,
        p_message in varchar2
    ) as

        pragma autonomous_transaction;
        owner_name  varchar2(100);
        caller_name varchar2(100);
        line_number number;
        caller_type varchar2(100);
    begin
        owa_util.who_called_me(owner_name, caller_name, line_number, caller_type);
        insert into website_logs (
            log_id,
            component,
            message,
            creation_date
        ) values ( website_log_seq.nextval,
                   caller_name,
                   ' line # '
                   || line_number
                   || ' action : '
                   || p_action
                   || ' '
                   || ' message : '
                   || p_message,
                   sysdate );

        commit;
    end;

    procedure log_app_error (
        p_package_name    in varchar2,
        p_procedure_name  in varchar2,
        p_call_stack      in varchar2,
        p_error_stack     in varchar2,
        p_error_backtrace in varchar2,
        p_params          in varchar2 default null
    ) as

        pragma autonomous_transaction;
        owner_name  varchar2(100);
        caller_name varchar2(100);
        line_number number;
        caller_type varchar2(100);
    begin
        owa_util.who_called_me(owner_name, caller_name, line_number, caller_type);
        insert into error_log (
            error_id,
            pkg_name,
            proc_name,
            call_stack,
            error_stack,
            error_bktrc,
            params
        ) values ( app_error_seq.nextval,
                   p_package_name,
                   p_procedure_name,
                   p_call_stack,
                   p_error_stack,
                   p_error_backtrace,
                   p_params );

        commit;
    end;

    procedure app_logs (
        p_error_backtrace in varchar2,
        p_params          in varchar2 default null
    ) as

        pragma autonomous_transaction;
        owner_name  varchar2(100);
        caller_name varchar2(100);
        line_number number;
        caller_type varchar2(100);
    begin
        owa_util.who_called_me(owner_name, caller_name, line_number, caller_type);
        insert into error_log (
            error_id,
            pkg_name,
            error_bktrc
        ) values ( app_error_seq.nextval,
                   caller_name,
                   p_error_backtrace );

        commit;
    end app_logs;

    procedure log_batch_job_result (
        p_job_name       in varchar2,
        p_error_code     in number,
        p_error_message  in varchar2,
        p_component_info in clob,
        p_start_date     in date default sysdate,
        p_end_date       in date default sysdate
    ) as
        pragma autonomous_transaction;
    begin
        insert into batch_jobs_result_log (
            batch_log_id,
            job_name,
            error_code,
            error_message,
            component_info,
            creation_date,
            start_date,
            end_date
        ) values ( log_batch_sequence.nextval,
                   p_job_name,
                   p_error_code,
                   p_error_message,
                   p_component_info,
                   sysdate,
                   p_start_date,
                   p_end_date );

        commit;
    end log_batch_job_result;

end;
/

