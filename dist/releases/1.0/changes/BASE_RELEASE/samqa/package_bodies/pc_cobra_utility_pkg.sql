-- liquibase formatted sql
-- changeset SAMQA:1754373984236 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_cobra_utility_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_cobra_utility_pkg.sql:null:d20296572e1afe20b925922b01204852f84ebbf5:create

create or replace package body samqa.pc_cobra_utility_pkg as

    function is_cobra_sso_allowed (
        p_tax_id in varchar2
    ) return varchar2 is
        l_flag varchar2(255) := 'N';
    begin
        for x in (
            select
                count(*) cnt
            from
                client        a,
                clientcontact b
            where
                    a.ein = replace(p_tax_id, '-')
                and a.allowclientsso = 1
                and b.allowsso = 1
                and b.active = 1
                and a.clientid = b.clientid
        ) loop
            if x.cnt > 0 then
                l_flag := 'Y';
            end if;
        end loop;

        return l_flag;
    end is_cobra_sso_allowed;

    function get_client_sso_info (
        p_ein in varchar2
    ) return cobra_sso_t
        pipelined
        deterministic
    is
        l_client_row cobra_sso_row_t;
    begin
        for x in (
            select
                a.clientid,
                b.ssoidentifier
            from
                client        a,
                clientcontact b
            where
                    a.ein = replace(p_ein, '-')
                and a.allowclientsso = 1
                and b.allowsso = 1
                and a.clientid = b.clientid
                and b.active = 1
        ) loop
            l_client_row.client_id := x.clientid;
            l_client_row.sso_identifier := x.ssoidentifier;
        end loop;

        pipe row ( l_client_row );
    end get_client_sso_info;

    function get_qb_sso_info (
        p_ssn in varchar2
    ) return cobra_sso_t
        pipelined
        deterministic
    is
        l_qb_row cobra_sso_row_t;
    begin
        for x in (
            select
                a.clientid,
                b.ssoidentifier
            from
                client a,
                qb     b
            where
                    b.ssn = format_ssn(p_ssn)
                and a.allowclientsso = 1
                and b.allowsso = 1
                and a.clientid = b.clientid
                and b.active = 1
        ) loop
            l_qb_row.client_id := x.clientid;
            l_qb_row.sso_identifier := x.ssoidentifier;
            pipe row ( l_qb_row );
        end loop;
    end get_qb_sso_info;


   ---- 14/10/2021  CP project  start rprabu
    function get_plans_ui (
        p_entrp_id        in number,
        p_division_id     in number,
        p_plan_bundle_id  in number,
        p_division_option varchar2
    ) return sys_refcursor is
        thecursor  sys_refcursor;
        l_pers_id  number := 0;
        l_record_t plan_record_t;
        l_sql      varchar2(3200);
    begin
        if p_entrp_id is not null then
            if p_division_id is not null then
                open thecursor for select
                                                          json_arrayagg(
                                                              json_object(
                                                                  key 'Entrp_id' value a.entrp_id,
                                                                          key 'COBRA_plan_id' value a.cobra_plan_id,
                                                                          key 'Member_Type' value 'Qualified Beneficiary',
                                                                          key 'Rate_Type' value nvl(
                                                                      pc_lookups.get_meaning(rate_type, 'COBRA_RATE_TYPE'),
                                                                      'No Rate'
                                                                  ),
                                                                          key 'Plan_name' value plan_name,
                                                                          key 'plan_type' value nvl(
                                                                      pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPE'),
                                                                      pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPES')
                                                                  ),
                                                                          key 'Plan_start_Date' value plan_start_date,
                                                                          key 'Carrier_name' value carrier_name,
                                                                          key 'carrier_phone_no' value carrier_phone_no,
                                                                          key 'Plan_start_Date' value plan_start_date,
                                                                          key 'Carrier_Contact_Name' value carrier_contact_name,
                                                                          key ' Carrier_Enrollment_Contact, ' value 'No',
                                                                          key ' Benefit_Termination_Type, ' value pc_lookups.get_meaning
                                                                          (coverage_terminate, 'BEN_TERM_TYPE'),
                                                                          key 'WAITINGPERIOD' value waitingperiod,
                                                                          key 'Insured_Type' value ' ',
                                                                          key 'Division_name' value c.division_name
                                                              )
                                                          returning varchar2(32000))
                                                      from
                                                          cobra_plans        a,
                                                          cobra_plan_rates   b,
                                                          employer_divisions c
                                   where
                                           a.entrp_id = p_entrp_id
                                       and a.entrp_id = c.entrp_id
                                       and a.division_id = c.division_id (+)
                                       and a.cobra_plan_id = b.cobra_plan_id (+)
                                       and ( ( p_division_option = 'A' )
                                             or ( p_division_id is null
                                                  and a.division_id is null
                                                  and p_division_option = 'N' )
                                             or ( p_division_option = 'O'
                                                  and p_division_id is not null
                                                  and a.division_id = p_division_id ) )
                                       and ( ( p_plan_bundle_id is null )
                                             or ( p_plan_bundle_id is not null
                                                  and a.plan_bundle_id = p_plan_bundle_id ) );

                return thecursor;
            else
                open thecursor for select
                                                          json_arrayagg(
                                                              json_object(
                                                                  key 'Entrp_id' value a.entrp_id,
                                                                          key 'COBRA_plan_id' value a.cobra_plan_id,
                                                                          key 'Member_Type' value 'Qualified Beneficiary',
                                                                          key 'Rate_Type' value nvl(
                                                                      pc_lookups.get_meaning(rate_type, 'COBRA_RATE_TYPE'),
                                                                      'No Rate'
                                                                  ),
                                                                          key 'Plan_name' value plan_name,
                                                                          key 'plan_type' value nvl(
                                                                      pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPE'),
                                                                      pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPES')
                                                                  ),
                                                                          key 'Plan_start_Date' value plan_start_date,
                                                                          key 'Carrier_name' value carrier_name,
                                                                          key 'carrier_phone_no' value carrier_phone_no,
                                                                          key 'Plan_start_Date' value plan_start_date,
                                                                          key 'Carrier_Contact_Name' value carrier_contact_name,
                                                                          key ' Carrier_Enrollment_Contact, ' value 'No',
                                                                          key ' Benefit_Termination_Type, ' value pc_lookups.get_meaning
                                                                          (coverage_terminate, 'BEN_TERM_TYPE'),
                                                                          key 'WAITINGPERIOD' value waitingperiod,
                                                                          key 'Insured_Type' value ' ',
                                                                          key 'Division_name' value c.division_name
                                                              )
                                                          returning varchar2(32000))
                                                      from
                                                          cobra_plans        a,
                                                          cobra_plan_rates   b,
                                                          employer_divisions c
                                   where
                                           a.entrp_id = p_entrp_id
                                       and a.entrp_id = c.entrp_id
                                       and ( a.division_id is null
                                             or p_division_option = 'A' )
                                       and a.cobra_plan_id = b.cobra_plan_id (+)
                                       and ( ( p_plan_bundle_id is null
                                               and a.plan_bundle_id is null )
                                             or ( p_division_option = 'A' )
                                             or ( p_plan_bundle_id is not null
                                                  and a.plan_bundle_id = p_plan_bundle_id ) );

                return thecursor;
            end if;

        end if;
    end;

   ---- 17/08/2021  CP project  start

    function get_plans (
        p_entrp_id        in number,
        p_division_id     in number,
        p_plan_bundle_id  in number,
        p_division_option varchar2
    ) return plan_t
        pipelined
        deterministic
    is

        l_pers_id  number := 0;
        l_record_t plan_record_t;
        l_sql      varchar2(3200);
        cursor c_cur1 is
        select
            a.entrp_id,
            a.cobra_plan_id,
            'Qualified Beneficiary'                                     member_type,
            nvl(
                pc_lookups.get_meaning(rate_type, 'COBRA_RATE_TYPE'),
                'No Rate'
            )                                                           rate_type,
            plan_name,
            nvl(
                pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPE'),
                pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPES')
            )                                                           plan_type,
            plan_start_date,
            carrier_name,
            carrier_phone_no,
            carrier_contact_name,
            'No'                                                        carrier_enrollment_contact,
            pc_lookups.get_meaning(coverage_terminate, 'BEN_TERM_TYPE') benefit_termination_type,
            waitingperiod,
            null                                                        insured_type,
            c.division_name
        from
            cobra_plans        a,
            cobra_plan_rates   b,
            employer_divisions c
        where
                a.entrp_id = p_entrp_id
            and a.entrp_id = c.entrp_id
            and a.division_id = c.division_id (+)
            and nvl(b.end_date, sysdate) >= sysdate
            and a.cobra_plan_id = b.cobra_plan_id (+)
            and ( ( p_division_option = 'A' )
                  or ( p_division_id is null
                       and a.division_id is null
                       and p_division_option = 'N' )
                  or ( p_division_option = 'O'
                       and p_division_id is not null
                       and a.division_id = p_division_id ) )
            and ( ( p_plan_bundle_id is null )
                  or ( p_plan_bundle_id is not null
                       and a.plan_bundle_id = p_plan_bundle_id ) );

        cursor c_cur2 is
        select
            a.entrp_id,
            a.cobra_plan_id,
            'Qualified Beneficiary'                                     member_type,
            nvl(
                pc_lookups.get_meaning(rate_type, 'COBRA_RATE_TYPE'),
                'No Rate'
            )                                                           rate_type,
            plan_name,
            nvl(
                pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPE'),
                pc_lookups.get_meaning(plan_type, 'COBRA_PLAN_TYPES')
            )                                                           plan_type,
            plan_start_date,
            carrier_name,
            carrier_phone_no,
            carrier_contact_name,
            'No'                                                        carrier_enrollment_contact,
            pc_lookups.get_meaning(coverage_terminate, 'BEN_TERM_TYPE') benefit_termination_type,
            waitingperiod,
            null                                                        insured_type,
            null                                                        division_name
        from
            cobra_plans      a,
            cobra_plan_rates b
        where
                a.entrp_id = p_entrp_id
            and nvl(b.end_date, sysdate) >= sysdate
            and ( a.division_id is null
                  or p_division_option = 'A' )
            and a.cobra_plan_id = b.cobra_plan_id (+)
            and ( ( p_plan_bundle_id is null
                    and a.plan_bundle_id is null )
                  or ( p_division_option = 'A' )
                  or ( p_plan_bundle_id is not null
                       and a.plan_bundle_id = p_plan_bundle_id ) );

    begin
        pc_log.log_error('get_COBRA_employees', 'sql P_Entrp_id :  ' || p_entrp_id);
        pc_log.log_error('get_COBRA_employees', 'sql p_plan_bundle_id :  ' || p_plan_bundle_id);
        pc_log.log_error('get_COBRA_employees', 'sql P_Division_option :  ' || p_division_option);
        if p_entrp_id is not null then
            if p_division_id is not null then
                open c_cur1;
                loop
                    fetch c_cur1 into l_record_t;
                    exit when c_cur1%notfound;
                    pipe row ( l_record_t );
                end loop;

                close c_cur1;
            else
                open c_cur2;
                loop
                    fetch c_cur2 into l_record_t;
                    exit when c_cur2%notfound;
                    pipe row ( l_record_t );
                end loop;

                close c_cur2;
            end if;
        else
            pipe row ( l_record_t );
        end if;

    end get_plans;

  ------ rprabu 17/05/2021
    function get_npm_employee (
        p_ssn in varchar2
    ) return employee_npm_t
        pipelined
        deterministic
    is

        l_pers_id  number := 0;
        l_record_t npm_record_t;
        l_sql      varchar2(3200);
        cursor c_cur is
        select
            entrp_id,
            employer_name,
            division_code,
            division_name,
            ssn,
            masked_ssn,
            first_name,
            last_name,
            address,
            phone_day,
            email,
            to_char(hire_date, 'MM/DD/YYYY') hire_date,
            use_family,
            send_general_right_letter,
            waive_covr,
            null                             valid_qb,
            pers_id,
            er_acc_id,
            er_acc_num,
            person_type
        from
            employee_npm_qb_v
        where
                ssn = p_ssn
            and rownum < 2;

        cursor c_cur_qb is
        select
            decode(pers_id, null, 'N', 'Y') valid_qb
        from
            person
        where
                ssn = p_ssn
            and person_type = 'QB';

    begin
        if p_ssn is not null then
            open c_cur;
            loop
                fetch c_cur into l_record_t;
                exit when c_cur%notfound;
                open c_cur_qb;
                fetch c_cur_qb into l_record_t.valid_qb;
                l_record_t.valid_qb := nvl(l_record_t.valid_qb, 'N');
                close c_cur_qb;
                pipe row ( l_record_t );
            end loop;

        else
            pipe row ( l_record_t );
        end if;
    end get_npm_employee;

    function get_qb_npm (
        p_entrp_id in number
    ) return employee_t
        pipelined
        deterministic
    is

        l_record_t employee_record_t;
        l_sql      varchar2(3200);

 --   ,Qual_event_date Varchar2(255)
        cursor c_cur is
        select
            mod(rownum, 2)                         rn,
            a.entrp_id,
            a.first_name,
            a.last_name,
            a.ssn,
            a.division_code,
            pc_person.get_division_name(a.pers_id) division_name,
            to_char(a.hire_date, 'MM/DD/YYYY')     hire_date,
            a.pers_id,
            b.acc_id                               er_acc_id,
            b.acc_num                              er_acc_num,
            pc_person.acc_num(a.pers_id)           acc_num,
            pc_entrp.get_entrp_name(a.entrp_id)    employer_name,
            a.person_type,
            case
                when person_type = 'QB' then
                    pc_lookups.get_meaning(b.account_status, 'ACCOUNT_STATUS')
                else
                    '-'
            end                                    account_status,
            to_char(a.birth_date, 'MM/DD/YYYY')    birth_date,
            (
                select
                    to_char(c.event_date, 'MM/DD/YYYY')
                from
                    qualifying_event c
                where
                        c.pers_id = a.pers_id
                    and rownum < 2
            )                                      event_date
        from
            person  a,
            account b
        where
                a.entrp_id = b.entrp_id (+)
            and a.person_type in ( 'QB', 'NPM' )
            and a.entrp_id = p_entrp_id;

    begin
        for rec in c_cur loop
            l_record_t := rec;
            pipe row ( l_record_t );
        end loop;
    end get_qb_npm;

   ------rprabu 14/05/2021
    function get_cobra_employees (
        p_er_accnum    in varchar2,
        p_search_by    in varchar2,
        p_search_value in varchar2,
        p_member_type  in varchar2,
        p_sort_by      in varchar2,
        p_sort_order   in varchar2
    ) return employee_t
        pipelined
        deterministic
    is

        l_acc_id   number;
        type r_cursor is ref cursor;
        c_cur      r_cursor;
        l_record_t employee_record_t;
        l_sql      varchar2(3200);
        p_entrp_id number;
    begin
        select
            entrp_id
        into p_entrp_id
        from
            account
        where
            acc_num = p_er_accnum;

        if p_er_accnum is not null then
            l_sql := 'SELECT * FROM table(pc_cobra_utility_pkg.get_QB_NPM('
                     || p_entrp_id
                     || ')) WHERE 1 = 1';
        end if;

        if p_member_type is not null then
            l_sql := l_sql
                     || ' AND Person_Type =    '''
                     || p_member_type
                     || '''';
        end if;

        if p_search_value is not null then
            if p_search_by in ( 'LAST_NAME', 'FIRST_NAME', 'EE_ACC_NUM', 'PERS_ID' ) then
                l_sql := l_sql
                         || ' AND  UPPER('
                         || p_search_by
                         || ')  LIKE ''%'
                         || upper(p_search_value)
                         || '%''';

            else
                l_sql := l_sql
                         || ' AND '
                         || p_search_by
                         || ' = '''
                         || p_search_value
                         || '''';
            end if;
        end if;

        if p_sort_by is null then
            l_sql := l_sql || ' ORDER BY  LAST_NAME ASC';
        else
            if p_sort_by in ( 'NAME', 'FIRST_NAME', 'LAST_NAME', 'ACC_NUM', 'HIRE_DATE',
                              'PERS_ID', 'ACC_ID', 'ER_ACC_ID' ) then
                if p_sort_by = 'ACC_NUM' then
                    l_sql := l_sql
                             || ' ORDER BY EE_ACC_NUM  '
                             || ' '
                             || nvl(p_sort_order, '');

                else
                    l_sql := l_sql
                             || ' ORDER BY  '
                             || p_sort_by
                             || ' '
                             || nvl(p_sort_order, '');
                end if;

            else
                l_sql := l_sql || ' ORDER BY  LAST_NAME  ASC  ';
            end if;
        end if;

        pc_log.log_error('get_COBRA_employees', 'sql ' || l_sql);
        open c_cur for l_sql;

        loop
            fetch c_cur into l_record_t;
            exit when c_cur%notfound;
            pipe row ( l_record_t );
        end loop;

        close c_cur;
    exception
        when others then
            pc_log.log_error('pc_cobra_utility_pkg', sqlerrm);
            raise;
    end get_cobra_employees;

   ------ rprabu 18/05/2021
    procedure update_division (
        p_entrp_id      number,
        p_pers_id       number,
        p_division_code varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
    begin
        if p_division_code is not null then
            update person
            set
                division_code = p_division_code
            where
                    pers_id = p_pers_id
                and entrp_id = p_entrp_id;

        end if;

        x_error_status := 'S';
        x_error_message := null;
    exception
        when others then
            null;
    end;

   ---- 17/08/2021  CP project  end

end pc_cobra_utility_pkg;
/

