create or replace package body samqa.pc_web_compliance as

   --Following Function Retrieves Profile Detail Of Employer Of Erisa Pop Form And Cobra
    function get_employer_info (
        p_entrp_id   in number,
        p_entrp_code in varchar2
    ) return tbl_plan
        pipelined
        deterministic
    is
        l_rec rec_plan;
        l_cnt number := 0;
    begin
        for x in (/*SELECT B.ACCOUNT_TYPE,
                       B.ACC_NUM,
                       START_DATE,
                       B.PLAN_CODE,
                       C.PLAN_NAME,
                       A.ENTRP_ID,
                       B.ACC_ID,
                       TO_CHAR (PLAN_START_DATE, 'mm/dd/rrrr')
                       || '-'
                       || TO_CHAR (PLAN_END_DATE, 'mm/dd/rrrr') PLAN_YEAR,
                       TO_CHAR (NVL (PLAN_START_DATE, START_DATE), 'mm/dd/rrrr') EFFECTIVE_DATE,
                       TO_CHAR (PLAN_END_DATE, 'mm/dd/rrrr') END_DATE,
                       DECODE (ACCOUNT_STATUS, 1, 'Active', 'In-active')
                       ACCOUNT_STATUS
                  FROM ENTERPRISE A,
                       ACCOUNT B,
                       PLAN_CODES C,
                       BEN_PLAN_ENROLLMENT_SETUP D
                 WHERE A.ENTRP_ID = B.ENTRP_ID
                   AND B.PLAN_CODE = C.PLAN_CODE
                   AND B.ACC_ID = D.ACC_ID(+)
                    AND ACCOUNT_TYPE IN ('COBRA')
                    AND P_ENTRP_ID IS NOT NULL
                    AND REPLACE (A.ENTRP_CODE, '-') IN
                           (SELECT REPLACE (ENTRP_CODE, '-')
                              FROM ENTERPRISE
                             WHERE ENTRP_ID = P_ENTRP_ID)
             UNION*/
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                b.plan_code,
                c.plan_name,
                a.entrp_id,
                b.acc_id,
                to_char(
                    nvl(e.start_date, b.start_date),
                    'mm/dd/rrrr'
                )
                || '-'
                || to_char(
                    nvl(e.end_date, b.end_date),
                    'mm/dd/rrrr'
                )                                                    plan_year,
                to_char(
                    nvl(e.start_date, b.start_date),
                    'mm/dd/rrrr'
                )                                                    effective_date,
                to_char(
                    nvl(e.end_date, b.end_date),
                    'mm/dd/rrrr'
                )                                                    end_date,
                    --EMployer Online Portal
                decode(account_status, 1, 'Active', 3, 'Pending Activation',
                       11, 'Pending Bank Verification', 'In-active') account_status,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                enterprise                a,
               --Employer Online.Add complete flag
                (
                    select
                        complete_flag,
                        acc_id,
                        acc_num,
                        entrp_id,
                        account_type,
                        account_status,
                        plan_code,
                        to_date(to_char(start_date, 'ddmm')
                                || to_char(trunc(sysdate, 'rr') - 1,
                                           'rr'),
                                'ddmmrr') start_date,
                        end_date,
                        show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
                    from
                        account
                )                         b,
                plan_codes                c,
                ben_plan_enrollment_setup d,
                (
                    select
                        acc_id,
                        max(start_date) start_date,
                        max(end_date)   end_date
                    from
                        ben_plan_renewals
                    where
                        plan_type = 'COBRA'
                    group by
                        acc_id
                )                         e
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and b.acc_id = d.acc_id (+)
                and b.acc_id = e.acc_id (+)
                --Employer Online Portal.We show active accts
                and account_status in ( 1, 11 )  -- 11 swamy Ticket#12764(12527)
                and b.complete_flag = 1 -- Enrollment complete
                and account_type = 'COBRA'
                and p_entrp_code is not null
--                AND ADD_MONTHS(STARt_DATE,12)-1 BETWEEN SYSDATE AND SYSDATE+90
                and replace(a.entrp_code, '-') = replace(p_entrp_code, '-')
            union all
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                    --B.PLAN_CODE,
                    --to_number(NVL(BEN_PLAN_NUMBER,B.PLAN_CODE)),
                to_number(ben_plan_number)                           plan_code,
                c.plan_name,
                a.entrp_id,
                b.acc_id,
                to_char(plan_start_date, 'mm/dd/rrrr')
                || '-'
                || to_char(plan_end_date, 'mm/dd/rrrr')              plan_year,
                to_char(plan_start_date, 'mm/dd/rrrr')               effective_date,
                to_char(plan_end_date, 'mm/dd/rrrr')                 end_date,
                     --EMployer Online Portal
                decode(account_status, 1, 'Active', 3, 'Pending Activation',
                       11, 'Pending Bank Verification', 'In-active') account_status,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                enterprise                a,
                account                   b,
                plan_codes                c,
                ben_plan_enrollment_setup d
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and b.acc_id = d.acc_id (+)
               --Employer Online Portal.We show active accts
                and account_status in ( 1, 11 )  -- 11 swamy Ticket#12764(12527)
                and complete_flag = 1 -- Enrollment complete
                and status = 'A'
                and account_type = 'POP'--and sysdate between plan_end_date-90and plan_end_date+60
                and replace(a.entrp_code, '-') = replace(p_entrp_code, '-')
                and plan_end_date = (
                    select
                        max(plan_end_date)
                    from
                        enterprise                a,
                        account                   b,
                        ben_plan_enrollment_setup c
                    where
                            a.entrp_id = b.entrp_id
                        and b.acc_id = c.acc_id
                                                      --Employer Online Portal
                        and complete_flag = 1 -- Enrollment complete
                        and account_status in ( 1, 3, 11 ) -- 11 swamy Ticket#12764(12527)
                        and status = 'A'
                        and account_type = 'POP'
                                                      --AND TRUNC(PLAN_END_DATE)BETWEEN TRUNC(SYSDATE)AND TRUNC(SYSDATE)+90
                        and replace(entrp_code, '-') = replace(p_entrp_code, '-')
                    group by
                        account_type
                )
            union all
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                    --to_number(NVL(BEN_PLAN_NUMBER,B.PLAN_CODE)),
                to_number(ben_plan_number),
                c.plan_name,
                a.entrp_id,
                b.acc_id,
                to_char(plan_start_date, 'mm/dd/rrrr')
                || '-'
                || to_char(plan_end_date, 'mm/dd/rrrr')              plan_year,
                to_char(plan_start_date, 'mm/dd/rrrr')               effective_date,
                to_char(plan_end_date, 'mm/dd/rrrr'),
                    --EMployer Online Portal
                decode(account_status, 1, 'Active', 3, 'Pending Activation',
                       11, 'Pending Bank Verification', 'In-active') account_status,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                enterprise                a,
                account                   b,
                plan_codes                c,
                ben_plan_enrollment_setup d
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and b.acc_id = d.acc_id (+)
                --Employer Online Portal.We show active accts
                and account_status in ( 1, 11 )  -- 11 swamy Ticket#12764(12527)
                and complete_flag = 1 -- enrollment complete
                and status = 'A'
                and account_type = 'ERISA_WRAP'--and sysdate between plan_end_date-90and plan_end_date+60
                and replace(a.entrp_code, '-') = replace(p_entrp_code, '-')
                and rownum = 1
                and plan_start_date = (
                    select
                        max(plan_start_date)
                    from
                        enterprise                a,
                        account                   b,
                        ben_plan_enrollment_setup c
                    where
                            a.entrp_id = b.entrp_id
                        and b.acc_id = c.acc_id (+)
                                             --Employer Online Portal
                        and complete_flag = 1 -- Complete
                        and account_status in ( 1, 3, 11 )  -- 11 swamy Ticket#12764(12527)
                        and status = 'A'
                        and account_type = 'ERISA_WRAP'
                                            --AND TRUNC(PLAN_END_DATE)BETWEEN TRUNC(SYSDATE)AND TRUNC(SYSDATE)+90
                        and replace(entrp_code, '-') = replace(p_entrp_code, '-')
                    group by
                        account_type
                )
            union all
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                    --B.PLAN_CODE,
                    --to_number(NVL(BEN_PLAN_NUMBER,B.PLAN_CODE)),
                to_number(ben_plan_number),
                c.plan_name,
                a.entrp_id,
                b.acc_id,
                to_char(plan_start_date, 'mm/dd/rrrr')
                || '-'
                || to_char(plan_end_date, 'mm/dd/rrrr')              plan_year,
                to_char(plan_start_date, 'mm/dd/rrrr')               effective_date,
                to_char(plan_end_date, 'mm/dd/rrrr'),
                    --EMployer Online Portal
                decode(account_status, 1, 'Active', 3, 'Pending Activation',
                       11, 'Pending Bank Verification', 'In-active') account_status,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                enterprise                a,
                account                   b,
                plan_codes                c,
                ben_plan_enrollment_setup d
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and b.acc_id = d.acc_id (+)
                --Employer Online Portal.We show active accts
                and account_status in ( 1, 11 )  -- 11 swamy Ticket#12764(12527)
                and complete_flag = 1 -- enrollment complete
                and status = 'A'
                and account_type = 'FORM_5500'
                and replace(a.entrp_code, '-') = replace(p_entrp_code, '-')
                --Employer Portal:To eliminate scenario where user creates plan with same dates
                --AND PLAN_START_DATE = (   SELECT MAX (PLAN_START_DATE)
                and ben_plan_id = (
                    select
                        max(ben_plan_id)
                    from
                        enterprise                a,
                        account                   b,
                        ben_plan_enrollment_setup c
                    where
                            a.entrp_id = b.entrp_id
                        and b.acc_id = c.acc_id
                                             --Employer Online Portal
                        and complete_flag = 1 -- Enrollment complete
                        and account_status in ( 1, 3, 11 )  -- 11 swamy Ticket#12764(12527)
                        and status = 'A'
                        and account_type = 'FORM_5500'
                                             --AND TRUNC(PLAN_END_DATE)BETWEEN TRUNC(SYSDATE)AND TRUNC(SYSDATE)+90
                        and replace(entrp_code, '-') = replace(p_entrp_code, '-')
                    group by
                        account_type
                )
        ) loop
            l_rec := null;
            l_rec.account_type := x.account_type;
            l_rec.plan_code := x.plan_code;
            l_rec.plan_name := x.plan_name;
            l_rec.acc_num := x.acc_num;
            l_rec.acc_id := x.acc_id;
            l_rec.plan_year := x.plan_year;
            l_rec.entrp_id := x.entrp_id;
            l_rec.effective_date := x.effective_date;
            l_rec.end_date := x.end_date;
            l_rec.account_status := x.account_status;
            l_rec.show_account_online := x.show_account_online;   -- Added by Swamy for Ticket#9332 on 06/11/2020
        -- Added By Joshi for 10430.
            l_rec.inactive_plan_flag := 'N';
            if x.acc_id is not null then
                for y in (
                    select
                        max(plan_end_date) plan_end_date
                    from
                        account                   a,
                        ben_plan_enrollment_setup b
                    where
                            a.acc_id = b.acc_id
                        and a.acc_id = x.acc_id
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                ) loop
                    if x.account_type = 'FORM_5500' then
                    -- For FORM5500 resubmit option is changed from 365 to 730 days as per Ticket#11131
                        if trunc(sysdate) - y.plan_end_date >= 730 then
                            l_rec.inactive_plan_flag := 'Y';
                        end if;

                    else
                        if ( sysdate - y.plan_end_date ) > 365 then
                            l_rec.inactive_plan_flag := 'Y';
                        end if;
                    end if;
                end loop;
            end if;
/*         IF X.ACC_NUM LIKE 'GCOB%' THEN
            SELECT COUNT (*)
              INTO L_REC.EMP_COUNT
              FROM ACCOUNT A,
                   ENTERPRISE B,
                   PERSON C,
                   ACCOUNT D
             WHERE A.ENTRP_ID       = B.ENTRP_ID
               AND B.ENTRP_ID       = C.ENTRP_ID
               AND C.PERS_ID        = D.PERS_ID
               AND D.ACCOUNT_STATUS = 1
               AND A.ACC_NUM        = X.ACC_NUM;
         END IF;*/
            l_rec.emp_count := nvl(
                pc_entrp.count_active_person(x.entrp_id),
                0
            );

            pipe row ( l_rec );
        end loop;
    end;

   --following function retrieves plan details of a person
    function get_employee_info (
        p_acc_id in number,
        p_ssn    in varchar2
    ) return tbl_ee_plan
        pipelined
    is
        rec rec_ee_plan;
    begin
        for i in (
            select
                account_type,
                acc_num,
                to_char(start_date, 'mm/dd/rrrr')
                || '-'
                || to_char(end_date, 'mm/dd/rrrr')               plan_year,
                b.plan_code,
                plan_name,
                a.pers_id,
                acc_id,
                to_char(start_date, 'mm/dd/rrrr')                effective_date,
                decode(account_status, 1, 'Active', 'In-active') account_status,
                a.person_type     -- Added by Swamy for Ticket#9656 on 24/03/2021
            from
                person     a,
                account    b,
                plan_codes c
            where
                    a.pers_id = b.pers_id
                and b.plan_code = c.plan_code
                and ( acc_id = p_acc_id
                      or replace(ssn, '-') = replace(p_ssn, '-') )
        ) loop
            if
                i.account_type = 'COBRA'
                and i.account_status <> 'Active'
            then
                rec := null;
            else
                rec.account_type := i.account_type;
                rec.acc_num := i.acc_num;
                rec.plan_year := i.plan_year;
                rec.plan_code := i.plan_code;
                rec.plan_name := i.plan_name;
                rec.pers_id := i.pers_id;
                rec.acc_num := i.acc_num;
                rec.effective_date := i.effective_date;
                rec.account_status := i.account_status;
                rec.person_type := i.person_type;      -- Added by Swamy for Ticket#9656 on 24/03/2021
            end if;

            pipe row ( rec );
        end loop;
    end;

   --following function retrieves invoice details; it is not being called from anywhere
    function get_invoice_dtl (
        p_acc_id in number
    ) return tbl_invoice
        pipelined
    is
        rec rec_invoice;
    begin
        for i in (
            select
                invoice_id,
                invoice_reason,
                invoice_date,
                invoice_due_date,
                invoice_amount,
                status
            from
                ar_invoice
            where
                acc_id = p_acc_id
        ) loop
            rec.invoice_id := i.invoice_id;
            rec.invoice_reason := i.invoice_reason;
            rec.invoice_date := i.invoice_date;
            rec.invoice_due_date := i.invoice_due_date;
            rec.invoice_amount := i.invoice_amount;
            rec.status := i.status;
            pipe row ( rec );
        end loop;
    end;

   --get cobra employee list i.e NPM or QB
    -- Commented by Swamy for SQL Injection for Qualified Benefeciary Tab in Cobra Product. (White hat www Vid: 48289429)
  /* FUNCTION GET_COBRA_EE_LIST (P_ACC_ID      IN  NUMBER,
                               P_PERSON_TYPE IN  VARCHAR2)
      RETURN TBL_EMP
      PIPELINED
   IS
      REC   REC_EMP;
   BEGIN
      FOR I
         IN (SELECT D.ACC_NUM,
                    SUBSTR (FIRST_NAME, 1, 20) FIRST_NAME,
                    SUBSTR (LAST_NAME, 1, 20) LAST_NAME            --,d.acc_id
               FROM ACCOUNT A,
                    ENTERPRISE B,
                    PERSON C,
                    ACCOUNT D
              WHERE     A.ENTRP_ID = B.ENTRP_ID
                    AND B.ENTRP_ID = C.ENTRP_ID
                    AND C.PERS_ID = D.PERS_ID(+)
                    AND A.ACC_ID = P_ACC_ID
                    AND PERSON_TYPE = P_PERSON_TYPE)
      LOOP
         REC.ACC_NUM := I.ACC_NUM;
         REC.FIRST_NAME := I.FIRST_NAME;
         REC.LAST_NAME := I.LAST_NAME;
         --      rec.acc_id     := i.acc_id;
         PIPE ROW (REC);
      END LOOP;
   END;
   */

    -- Added by Swamy for SQL Injection for Qualified Benefeciary Tab in Cobra Product. (White hat www Vid: 48289429)
    --get cobra employee list i.e NPM or QB
    function get_cobra_ee_list (
        p_acc_id      in number,
        p_person_type in varchar2,
        p_first_name  in varchar2,
        p_last_name   in varchar2,
        p_acc_num     in varchar2,
        p_sort_column in varchar2,
        p_sort_order  in varchar2
    ) return tbl_emp
        pipelined
        deterministic
    is
	  -- Variable Declaration
        l_record_t    rec_emp;
        v_sql_cur     l_cursor;
        v_sql         varchar2(4000);
        v_sql_name    varchar2(400);
        v_sort_order  varchar2(400);
        v_sort_column varchar2(400);
    begin
        v_sql := 'SELECT D.ACC_NUM,
                    SUBSTR (FIRST_NAME, 1, 20) FIRST_NAME,
                    SUBSTR (LAST_NAME, 1, 20) LAST_NAME
               FROM ACCOUNT A,
                    ENTERPRISE B,
                    PERSON C,
                    ACCOUNT D
              WHERE     A.ENTRP_ID = B.ENTRP_ID
                    AND B.ENTRP_ID = C.ENTRP_ID
                    AND C.PERS_ID = D.PERS_ID(+)
                    AND A.ACC_ID = '''
                 || p_acc_id
                 || '''
                    AND C.PERSON_TYPE = '''
                 || p_person_type
                 || '''';
        if nvl(p_acc_num, '*') <> '*' then
            v_sql_name := v_sql_name
                          || ' AND UPPER(D.ACC_NUM) = UPPER('''
                          || p_acc_num
                          || ''')';
        end if;

        if nvl(p_first_name, '*') <> '*' then
            v_sql_name := ' AND UPPER(C.FIRST_NAME) = UPPER('''
                          || p_first_name
                          || ''')';
        end if;

        if nvl(p_last_name, '*') <> '*' then
            v_sql_name := v_sql_name
                          || ' AND UPPER(C.LAST_NAME) = UPPER('''
                          || p_last_name
                          || ''')';
        end if;

        if nvl(p_sort_order, '*') in ( 'ASC', 'DESC' ) then
            v_sort_order := p_sort_order;
        else
            v_sort_order := 'DESC';
        end if;

        if upper(nvl(p_sort_column, '*')) in ( 'ACC_NUM', 'FIRST_NAME', 'LAST_NAME' ) then
            v_sort_column := ' ORDER BY '
                             || p_sort_column
                             || ' '
                             || v_sort_order;
        else
            v_sort_column := ' ORDER BY LAST_NAME ' || v_sort_order;
        end if;

        v_sql := v_sql
                 || v_sql_name
                 || v_sort_column;
        open v_sql_cur for v_sql;

        loop
            fetch v_sql_cur into
                l_record_t.acc_num,
                l_record_t.first_name,
                l_record_t.last_name;
            exit when v_sql_cur%notfound;
            pipe row ( l_record_t );
        end loop;

        close v_sql_cur;
    exception
        when others then
            null;
    end get_cobra_ee_list;
-- End of Addition by Swamy for SQL Injection for Qualified Benefeciary Tab in Cobra Product. (White hat www Vid: 48289429)

    function get_ee_dtl (
        p_acc_num in varchar2
    ) return tbl_cob
        pipelined
    is
        rec rec_cob;
    begin
        for i in (
            select
                plan_name,
                to_char(start_date, 'mm/dd/rrrr')
                || '-'
                || to_char(end_date, 'mm/dd/rrrr') year,
                to_char(start_date, 'mm/dd/rrrr')  start_date
               --start_date,decode(account_status,1,'Active','In-active')account_status
            from
                account    a,
                plan_codes b
            where
                    a.plan_code = b.plan_code
                and acc_num = p_acc_num
        ) loop
         --      rec.acc_num:=i.acc_num;
            rec.plan_name := i.plan_name;
            rec.year := i.year;
            rec.effective_date := i.start_date;
         --      rec.account_status:=i.account_status;
         -- for giving annual election there should be row in ben plan enrollment setup table
         -- but for cobra records there is no row in this table therefore annual election cannot be given at present
         --pc_benefit_plans.get_annual_election(p_er_ben_plan_id IN NUMBER,p_acc_id IN NUMBER)
            pipe row ( rec );
        end loop;
    end;

   --following function retrieves date wise cobra income details from income table
    function get_cobra_payments (
        p_ssn  in varchar2,
        p_year in varchar2
    ) return tbl_cobra_payment
        pipelined
    is
        rec rec_cobra_payment;
    begin
        for i in (
            select
                to_char(fee_date, 'mm/dd/rrrr') fee_date,
                amount
            from
                account a,
                income  b
            where
                    a.acc_id = b.acc_id
                and account_type = 'COBRA'
                and to_char(fee_date, 'rrrr') = nvl(p_year,
                                                    to_char(fee_date, 'rrrr'))
                and pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        replace(ssn, '-') = replace(p_ssn, '-')
                )
            order by
                fee_date
        ) loop
            rec.fee_date := i.fee_date;
            rec.amount := i.amount;
            pipe row ( rec );
        end loop;
    end;

    function get_cobra_pymnts_mob (
        p_ssn in varchar2
    )--,
                             -- P_YEAR   IN  VARCHAR2)
     return tbl_cobra_payment
        pipelined
    is
        rec rec_cobra_payment;
        n   number := 0;
    begin
        for i in (
            select
                *
            from
                (
                    select
                        fee_date,
                        amount,
                        fee_name,
                        a.acc_id
                    from
                        account   a,
                        income    b,
                        fee_names c,
                        person    e
                    where
                            a.acc_id = b.acc_id
                        and b.fee_code = c.fee_code
                        and account_type = 'COBRA'
                        and a.pers_id = e.pers_id
                        and replace(ssn, '-') = replace(p_ssn, '-')
                         -- AND TO_CHAR (FEE_DATE, 'rrrr') = P_YEAR
                    order by
                        fee_date desc
                )
            where
                rownum < 6
        ) loop
            rec.fee_date := to_char(i.fee_date, 'mm/dd/rrrr');
            rec.amount := i.amount;
            rec.fee_name := i.fee_name;
            pipe row ( rec );
        end loop;
    end;

    function get_er_erisa_dtl (
        p_entrp_id in number
    ) return tbl_erisa
        pipelined
    is
        rec           rec_erisa;
        cnt           number;
        cnt1          number;
        l_ben_plan_id number;
    begin
        for i in (
            select
                entity_type,
                plan_code,
                ben_plan_id,
                nvl(grandfathered, 'N')          grandfathered,
                nvl(clm_lang_in_spd, 'N')        clm_lang_in_spd,
                nvl(
                    pc_entrp.get_eligible_count(p_entrp_id),
                    no_of_eligible
                )                                no_of_eligible,
                ben_plan_number,
                (
                    select
                        sum(census_numbers)
                    from
                        enterprise_census
                    where
                            entity_id = b.entrp_id
                        and census_code = 'NO_OF_EMPLOYEES'
                )                                no_of_employees,
                a.note                           note,
                nvl(c.erissa_erap_doc_type, 'R') erissa_wrap_doc_type
            from
                enterprise                a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.entrp_id = b.entrp_id
                and b.acc_id = c.acc_id
                and a.entrp_id = p_entrp_id
                and c.status = 'A'
                and c.plan_start_date = (
                    select
                        max(plan_start_date)
                    from
                        ben_plan_enrollment_setup
                    where
                        acc_id = c.acc_id
                )   -- Added by Joshi for erissa plan fix.

        ) loop
         --REC.BEN_PLAN_ID      := L_BEN_PLAN_ID;
            rec.ben_plan_id := i.ben_plan_id;
            rec.entity_type := i.entity_type;
            rec.plan_code := i.plan_code;
            rec.grandfathered := i.grandfathered;
            rec.clm_lang_in_spd := i.clm_lang_in_spd;
            rec.no_of_eligible := i.no_of_eligible;
            rec.ben_plan_number := i.ben_plan_number;
            rec.included_plans := 'All Benefits of the Plan';
            rec.no_of_employees := i.no_of_employees;
            rec.note := i.note;
            rec.erissa_wrap_doc_type := i.erissa_wrap_doc_type;  -- Added by Joshi for 7791(Renewal).

            select
                count(*)
            into cnt1
            from
                entrp_relationships
            where
                    entrp_id = p_entrp_id
                and relationship_type = 'AFFILIATED_ER'
                and status = 'A'
                and end_date is null;

            if cnt1 > 0 then
                rec.affiliated_er := 'Y';
            end if;
            cnt1 := 0;
            select
                count(*)
            into cnt1
            from
                entrp_relationships
            where
                    entrp_id = p_entrp_id
                and relationship_type = 'CONTROLLED_GROUP'
                and status = 'A'
                and end_date is null;

            if cnt1 > 0 then
                rec.controlled_group := 'Y';
            end if;
            pipe row ( rec );
        end loop;
    end;

    function get_benefit_codes (
        p_entrp_id    number,
        p_ben_plan_id in number default null,
        p_lookup_name in varchar2 default null
    ) return tbl_ben_codes
        pipelined
    is
        rec           rec_ben_codes;
        cnt           number;
        l_ben_plan_id number;
    begin
   /* For Ticket#2592 */
        if p_ben_plan_id is not null then
        /* FOR I IN(SELECT NVL((SELECT benefit_code_id from BENEFIT_CODES WHERE BENEFIT_CODE_NAME=B.LOOKUP_CODE AND  ENTITY_ID = P_BEN_PLAN_ID),0) BENEFIT_CODE_ID
                      ,LOOKUP_CODE  BENEFIT_CODE_NAME
                      ,MEANING
                      ,NVL((SELECT ELIGIBILITY FROM BENEFIT_CODES WHERE BENEFIT_CODE_NAME=B.LOOKUP_CODE AND  ENTITY_ID = P_BEN_PLAN_ID),0)ELIGIBILITY
                      ,NVL((SELECT ER_CONT_PREF FROM BENEFIT_CODES WHERE BENEFIT_CODE_NAME=B.LOOKUP_CODE AND  ENTITY_ID = P_BEN_PLAN_ID),0)ER_CONT_PREF
                      ,NVL((SELECT EE_CONT_PREF FROM BENEFIT_CODES WHERE BENEFIT_CODE_NAME=B.LOOKUP_CODE AND  ENTITY_ID = P_BEN_PLAN_ID),0)EE_CONT_PREF
                   FROM LOOKUPS B
                 WHERE LOOKUP_NAME ='SUBSIDIARY_CONTRACTS'
                 )*/
            for i in (
                select
                    benefit_code_id,
                    benefit_code_name,
                    meaning,
                    eligibility,
                    er_cont_pref,
                    ee_cont_pref
                from
                    benefit_codes a,
                    lookups       b
                where
                        benefit_code_name = lookup_code (+)
                    and entity_id = p_ben_plan_id
                    and lookup_name = 'SUBSIDIARY_CONTRACTS'
            ) loop
                rec.benefit_code_id := i.benefit_code_id;
                rec.benefit_code_name := i.benefit_code_name;
                rec.meaning := i.meaning;
                rec.eligibility := i.eligibility;
                rec.er_cont_pref := i.er_cont_pref;
                rec.ee_cont_pref := i.ee_cont_pref;
                pipe row ( rec );
            end loop;

        else

     -- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294(Also specific Ticket# 6229)
	 -- For Erisa online Enrollment, the Eligibility should not contain lookup code ELIGIB7,ELIGIB4
            if p_lookup_name = 'ELIGIBILITY_OPTIONS' then
                for i in (
                    select
                        lookup_code,
                        meaning
                    from
                        lookups b
                    where
                            lookup_name = p_lookup_name
                        and ( lookup_code not in ( 'ELIGIB7', 'ELIGIB4' ) )
                ) loop
                    rec.benefit_code_id := null;
                    rec.benefit_code_name := i.lookup_code;
                    rec.meaning := i.meaning;
                    rec.eligibility := null;
                    rec.er_cont_pref := null;
                    rec.ee_cont_pref := null;
                    pipe row ( rec );
                end loop;

            elsif p_lookup_name = 'ELIGIBILITY_OPTIONS_OTHER' then
	    -- For Erisa online Enrollment, the Eligibility should not contain lookup code ELIGIB14
                for i in (
                    select
                        lookup_code,
                        meaning
                    from
                        lookups b
                    where
                            lookup_name = p_lookup_name
                        and ( lookup_code not in ( 'ELIGIB16' ) )
                ) loop
                    rec.benefit_code_id := null;
                    rec.benefit_code_name := i.lookup_code;
                    rec.meaning := i.meaning;
                    rec.eligibility := null;
                    rec.er_cont_pref := null;
                    rec.ee_cont_pref := null;
                    pipe row ( rec );
                end loop;
            else
     -- End By Swamy ticket# 6229

                for i in (
                    select
                        lookup_code,
                        meaning
                    from
                        lookups b
                    where
                        lookup_name = p_lookup_name
                ) loop
                    rec.benefit_code_id := null;
                    rec.benefit_code_name := i.lookup_code;
                    rec.meaning := i.meaning;
                    rec.eligibility := null;
                    rec.er_cont_pref := null;
                    rec.ee_cont_pref := null;
                    pipe row ( rec );
                end loop;
            end if; -- Added Swamy ticket# 6229

        end if;
    end;


   --following function retrieves list of pdf files
    function get_pdf_file_list (
        p_entrp_id in varchar2
    ) return tbl_file
        pipelined
    is
        rec               rec_file;
        l_plan_name       varchar2(500);
        l_ben_plan_number number;
        cnt               number := 0;
    begin
        for x in (
            select
                ben_plan_number,
                ben_plan_id,
                pc_lookups.get_meaning(ben_plan_number, 'BEN_PLAN_NUMBER') plan_name,
                to_char(plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plan_end_date, 'MM/DD/YYYY')                    plan_year
            from
                ben_plan_enrollment_setup
            where
                    entrp_id = p_entrp_id
                and status = 'A'  --- 8030 ticket 04/09/2019
            order by
                plan_end_date desc
        ) loop
            rec.plan_name := x.plan_name;
            rec.year := x.plan_year;
            for xx in (
                select
                    attachment_id,
                    document_name,
                    entity_id
                from
                    file_attachments
                where
                        entity_name = 'BEN_PLAN_ENROLLMENT_SETUP'
                    and entity_id = x.ben_plan_id
                    and nvl(document_purpose, '*') <> '*' --  Added by Swamy for Ticket#12105 01042024 
				   --AND  NVL(show_online,'N') = 'Y'   
            ) loop
                rec.file_name := xx.document_name;
                rec.attachment_id := xx.attachment_id;
                cnt := cnt + 1;
                pipe row ( rec );
            end loop;

            if cnt = 0 then
                pipe row ( rec );
            end if;
        end loop;
    end get_pdf_file_list;

    function get_file_attachment (
        p_attachment_id number
    ) return blob is
        l_blob blob;
    begin
        select
            attachment
        into l_blob
        from
            file_attachments
        where
            attachment_id = p_attachment_id;

        return l_blob;
    end get_file_attachment;

   --following function is being used in mobile apps only by Jay Bharat (not used by P.Mohanty)
   --there is no data for 2015 in income table for cobra records therefore year is passed as in parameter
    function get_cobra_ee_detail (
        p_ssn in varchar2--,
                                 --P_YEAR   IN  VARCHAR2
    ) return tbl_cobra_ee_detail
        pipelined
    is
        rec rec_cobra_ee_detail;
    begin
        for i in (
            select
                plan_name,
                acc_num,
                acc_id,
                pers_id,
                pc_lookups.get_account_status(a.account_status) account_status,
                to_char(start_date, 'mm/dd/rrrr')               start_date--,
            from
                account    a,
                plan_codes b
            where
                    a.plan_code = b.plan_code
                and account_type = 'COBRA'
                and a.account_status = 1
                and pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        replace(ssn, '-') = replace(p_ssn, '-')
                )
        ) loop
            rec.plan_name := i.plan_name;
            rec.acc_num := i.acc_num;
            rec.account_status := i.account_status;
            rec.effective_date := i.start_date;
            rec.contribution := 0;
            for x in (
                select
                    nvl(
                        sum(amount),
                        0
                    ) cont,
                    to_char(
                        min(fee_date),
                        'mm/dd/rrrr'
                    )
                    || '-'
                    || to_char(
                        max(fee_date),
                        'mm/dd/rrrr'
                    ) fee_date
                from
                    income
                where
                        acc_id = i.acc_id
                    and fee_code != 12
            ) loop
                rec.contribution := x.cont;
                rec.period := x.fee_date;
            end loop;

            pipe row ( rec );
        end loop;
    end get_cobra_ee_detail;

   --there is no data for 2015 in income table for cobra records therefore year is passed as in parameter
    function get_cobra_contribution (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return tbl_cobra_cont
        pipelined
    is
        rec  rec_cobra_cont;
        amnt number;
    begin
        for x in (
            select
                nvl(
                    sum(amount),
                    0
                ) cont,
                to_char(
                    min(fee_date),
                    'mm/dd/rrrr'
                )
                || '-'
                || to_char(
                    max(fee_date),
                    'mm/dd/rrrr'
                ) fee_date
            from
                income  a,
                account i
            where
                    a.acc_id = i.acc_id
                and i.acc_num = p_acc_num
                and fee_code in ( 0, 3, 4, 6, 110 )
                and to_char(fee_date, 'rrrr') = p_year
        ) loop
            rec.contribution := x.cont;
            rec.period := x.fee_date;
            pipe row ( rec );
        end loop;
    end get_cobra_contribution;

    function get_broker_info (
        p_acc_num in varchar2
    ) return tbl_broker
        pipelined
    is
        rec rec_broker;
    begin
        for i in (
            select
                first_name,
                email
            from
                person
            where
                pers_id = (
                    select
                        broker_id
                    from
                        account
                    where
                        acc_num = p_acc_num
                )
        ) loop
            rec.broker_name := i.first_name;
            rec.email := i.email;
            pipe row ( rec );
        end loop;
    end;

    function get_rate_plan_cost (
        p_entity_id      in varchar2,
        p_rate_plan_name in varchar2
    ) return varchar2 is
        l_census         number;
        l_rate_plan_cost varchar2(20);
    begin
        select
            census_numbers
        into l_census
        from
            enterprise_census
        where
                entity_id = p_entity_id
            and census_code = 'NO_OF_ELIGIBLE';

        for i in (
            select
                b.rate_plan_cost
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.account_type = 'COBRA'
                and b.coverage_type = p_rate_plan_name
                and l_census between b.minimum_range and b.maximum_range
            order by
                minimum_range desc
        ) loop
            l_rate_plan_cost := i.rate_plan_cost;
        end loop;

        return nvl(
            to_char(l_rate_plan_cost),
            'CUSTOM'
        );
    end get_rate_plan_cost;

    function get_all_rate_plan_cost (
        p_entity_id    in varchar2,
        p_product_type varchar2
    ) return tbl_rate_plan_cost
        pipelined
    is
        rec              rec_rate_plan_cost;
        l_census         number;
        l_rate_plan_cost varchar2(20);
    begin
        select
            max(census_numbers)
        into l_census
        from
            enterprise_census
        where
                entity_id = p_entity_id
            and census_code = 'NO_OF_ELIGIBLE';

        for j in (
            select
                a.rate_plan_id,
                b.rate_plan_detail_id,
                nvl(b.minimum_range, 1) minimum_range,
                b.rate_plan_cost,
                b.coverage_type
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.account_type = p_product_type
                and b.minimum_range >= nvl(l_census, 0)
            order by
                minimum_range desc
        ) loop
            rec.rate_plan_id := j.rate_plan_id;
            rec.rate_plan_detail_id := j.rate_plan_detail_id;
            l_rate_plan_cost := nvl(
                to_char(j.rate_plan_cost),
                'CUSTOM'
            );
            rec.rate_plan_name := j.coverage_type;
            rec.rate_plan_cost := l_rate_plan_cost;
            pipe row ( rec );
        end loop;

    end;

    function get_cobra_suite (
        p_rate_plan_detail_id number,
        flg                   number
    ) return tbl_cobra_suite
        pipelined
    is

        rec              rec_cobra_suite;
        l_min_range      varchar2(20);
        l_max_range      varchar2(20);
        l_rate_plan_name varchar2(100) :=
            case
                when flg is null then
                    'OPEN_ENROLLMENT_SUITE'
                else 'OPTIONAL_COBRA_SERVICE_CP'
            end;
    begin
        for i in (
            select
                rate_plan_detail_id,
                rate_plan_name,
                minimum_range,
                maximum_range,
                rate_plan_cost
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and account_type = 'COBRA'
                and b.coverage_type = l_rate_plan_name
                and b.rate_plan_detail_id = p_rate_plan_detail_id
        ) loop
            rec.rate_plan_detail_id := i.rate_plan_detail_id;
            rec.rate_plan_name := i.rate_plan_name;
            rec.min_range := i.minimum_range;
            rec.max_range := i.maximum_range;
            rec.rate_plan_cost := i.rate_plan_cost;
            pipe row ( rec );
        end loop;
    end;

    function last_renew (
        p_entrp_id number
    ) return tbl_last_renew
        pipelined
    is
        rec rec_last_renew;
    begin
        for i in (
            select
                a.rate_code,
                total_line_amount
            from
                (
                    select
                        max(ar.invoice_id)   invoice_id,
                        max(ar.rate_plan_id) rate_plan_id
                    from
                        ar_invoice       ar,
                        ar_invoice_lines a
                    where
                            ar.invoice_id = a.invoice_id
                        and ar.entity_id = p_entrp_id
                        and a.rate_code = '30'
                )                ar,
                ar_invoice_lines a
            where
                ar.invoice_id = a.invoice_id
        ) loop
            for xx in (
                select distinct
                    rpd.coverage_type
                from
                    rate_plans       rp,
                    rate_plan_detail rpd
                where
                        rp.rate_plan_id = rpd.rate_plan_id
                    and rp.rate_plan_name = 'COBRA_STANDARD_FEES'
                    and rpd.rate_code = i.rate_code
            ) loop
                rec.rate_plan_name := xx.coverage_type;
            end loop;

            rec.amount := i.total_line_amount;
            pipe row ( rec );
        end loop;
    end last_renew;

    function get_contact_info (
        p_ein varchar2
    ) return tbl_broker
        pipelined
    is
        rec rec_broker;
    begin
        for i in (
            select
                a.contact_id,
                a.first_name
                || ' '
                || a.last_name name,
                a.email,
                'BROKER'       entity_type
            from
                contact      a,
                contact_role c
            where
                    a.entity_id = p_ein
                and nvl(a.status, 'A') = 'A'
                and c.role_type in ( 'BROKER' )
                and a.contact_id = c.contact_id
                and c.effective_end_date is null
                and a.email is not null
                and a.can_contact = 'Y'
            union
            select
                a.contact_id,
                a.first_name
                || ' '
                || a.last_name,
                a.email,
                'GA' entity_type
            from
                contact      a,
                contact_role c
            where
                    a.entity_id = p_ein
                and nvl(a.status, 'A') = 'A'
                and c.role_type in ( 'GA' )
                and a.contact_id = c.contact_id
                and c.effective_end_date is null
                and a.email is not null
                and a.can_contact = 'Y'
        ) loop
            rec.contact_id := i.contact_id;
            rec.broker_name := i.name;
            rec.email := i.email;
            rec.entity_type := i.entity_type;
            pipe row ( rec );
        end loop;
    end get_contact_info;

    procedure update_contact_info (
        p_contact_id      number,
        p_entrp_id        number,
        p_first_name      varchar2,
        p_email           varchar2,
        p_account_type    varchar2,
        p_contact_type    varchar2,
        p_user_id         varchar2,
        p_ref_entity_id   varchar2,
        p_ref_entity_type varchar2,
        p_send_invoice    varchar2,
        p_status          varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        cnt          number;
        l_contact_id number;
        l_cnt        number;
    begin
        l_cnt := 0;
        l_contact_id := null;
        pc_log.log_error('here web compliance', 'In proc');
        pc_log.log_error('UPDATE_CONTACT_INFO', 'P_CONTACT_ID' || p_contact_id);
        pc_log.log_error('UPDATE_CONTACT_INFO', 'P_FIRST_NAME' || p_first_name);
        pc_log.log_error('UPDATE_CONTACT_INFO', 'P_EMAIL' || p_email);
        pc_log.log_error('UPDATE_CONTACT_INFO', 'INVOICE' || p_send_invoice);
        l_contact_id := p_contact_id;
        if
            nvl(p_status, 'A') = 'A'
            and p_email is not null
            and l_contact_id is not null
        then
            insert into contact_leads (
                contact_id,
                entity_id,
                entity_type,
                first_name,
                email,
                account_type,
                ref_entity_id,
                ref_entity_type,
                send_invoice,
                contact_type,
                updated,
                user_id,
                creation_date
            )
                select
                    l_contact_id,
                    pc_entrp.get_tax_id(p_entrp_id),
                    'ENTERPRISE',
                    p_first_name,
                    p_email,
                    p_account_type,
                    p_ref_entity_id,
                    p_ref_entity_type,
                    p_send_invoice,
                    p_contact_type,
                    'N',
                    p_user_id,
                    sysdate
                from
                    dual
                where
                    not exists (
                        select
                            *
                        from
                            contact_role
                        where
                                contact_id = l_contact_id
                            and role_type = p_account_type
                    )
                        and not exists (
                        select
                            *
                        from
                            contact_leads                         -- added by jaggi #11368 #11601
                        where
                                contact_id = l_contact_id
                            and account_type = p_account_type
                    );

            if l_contact_id is not null then
           -- added by jaggi #11368 #11601
                for x in (
                    select
                        count(*) cnt
                    from
                        contact
                    where
                        contact_id = l_contact_id
                ) loop
                    l_cnt := x.cnt;
                end loop;

                if l_cnt = 0 then
                    insert into contact (
                        contact_id,
                        first_name,
                        last_name,
                        entity_id,
                        entity_type,
                        email,
                        status,
                        start_date,
                        last_updated_by,
                        created_by,
                        last_update_date,
                        creation_date,
                        can_contact,
                        contact_type,
                        user_id,
                        account_type
                    )
                        select
                            contact_id,
                            substr(first_name,
                                   0,
                                   instr(first_name, ' ', 1, 1) - 1),
                            substr(first_name,
                                   instr(first_name, ' ', 1, 1) + 1,
                                   length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                            entity_id,
                            'ENTERPRISE',
                            email,
                            'A',
                            sysdate,
                            p_user_id,
                            p_user_id,
                            sysdate,
                            sysdate,
                            'Y',
                            contact_type,
                            p_user_id,
                            p_account_type
                        from
                            contact_leads
                        where
                            contact_id = l_contact_id;

                else
                    update contact
                    set
                        email = p_email,
                        first_name = substr(p_first_name,
                                            0,
                                            instr(p_first_name, ' ', 1, 1) - 1),
                        last_name = substr(p_first_name,
                                           instr(p_first_name, ' ', 1, 1) + 1,
                                           length(p_first_name) - instr(p_first_name, ' ', 1, 1) + 1)
                    where
                        contact_id = l_contact_id;

                end if;

                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by
                )
                    select
                        contact_role_seq.nextval,
                        l_contact_id,
                        p_contact_type,
                        p_account_type,
                        sysdate,
                        p_user_id,
                        p_user_id
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                contact_role
                            where
                                    role_type = p_contact_type
                                and contact_id = l_contact_id
                        );
            -- end here
                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by
                )
                    select
                        contact_role_seq.nextval,
                        l_contact_id,
                        p_account_type,
                        p_account_type,
                        sysdate,
                        p_user_id,
                        p_user_id
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                contact_role
                            where
                                    role_type = p_account_type
                                and contact_id = l_contact_id
                        );

              /*Ticket#6717 */
                if p_send_invoice in ( '1', 'Y' ) then
                    insert into contact_role e (
                        contact_role_id,
                        contact_id,
                        role_type,
                        account_type,
                        effective_date,
                        created_by,
                        last_updated_by
                    ) values ( contact_role_seq.nextval,
                               l_contact_id,
                               'FEE_BILLING',
                               p_account_type,
                               sysdate,
                               p_user_id,
                               p_user_id );

                end if;

            end if;

        end if;

        pc_log.log_error('UPDATE_CONTACT_INFO', 'L_CONTACT_ID' || l_contact_id);
        if
            l_contact_id is null
            and p_email is not null
        then
            if l_contact_id is null then
                l_contact_id := contact_seq.nextval;
            end if;
            pc_log.log_error('UPDATE_CONTACT_INFO', 'L_CONTACT_ID' || l_contact_id);
            insert into contact_leads (
                contact_id,
                entity_id,
                entity_type,
                first_name,
                email,
                account_type,
                ref_entity_id,
                ref_entity_type,
                send_invoice,
                contact_type,
                updated,
                user_id,
                creation_date
            )
                select
                    l_contact_id,
                    pc_entrp.get_tax_id(p_entrp_id),
                    'ENTERPRISE',
                    p_first_name,
                    p_email,
                    p_account_type,
                    p_ref_entity_id,
                    p_ref_entity_type,
                    p_send_invoice,
                    p_contact_type,
                    'N',
                    p_user_id,
                    sysdate
                from
                    dual;

            pc_log.log_error('UPDATE_CONTACT_INFO', 'SQL%ROWCOUNT' || sql%rowcount);
            insert into contact (
                contact_id,
                first_name,
                last_name,
                entity_id,
                entity_type,
                email,
                status,
                start_date,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                can_contact,
                contact_type,
                user_id,
                account_type
            )   --6700  ACCOUNT_TYPE rprabu 02/07/2019
                select
                    contact_id,
                    substr(first_name,
                           0,
                           instr(first_name, ' ', 1, 1) - 1),
                    substr(first_name,
                           instr(first_name, ' ', 1, 1) + 1,
                           length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                    entity_id,
                    'ENTERPRISE',
                    email,
                    'A',
                    sysdate,
                    p_user_id,
                    p_user_id,
                    sysdate,
                    sysdate,
                    'Y',
                    contact_type,
                    p_user_id,
                    p_account_type    --6700  ACCOUNT_TYPE rprabu 02/07/2019
                from
                    contact_leads
                where
                    contact_id = l_contact_id;

                --Especially for compliance we need to have both account type and role type defined

            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       l_contact_id,
                       p_account_type,
                       p_account_type,
                       sysdate,
                       p_user_id,
                       p_user_id );

                --Especially for compliance we need to have both account type and role type defined
            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       l_contact_id,
                       p_contact_type,
                       p_account_type,
                       sysdate,
                       p_user_id,
                       p_user_id );

            /*Ticket#6555.If send invoice is yes then FEE billing should come up as an option */
            if p_send_invoice in ( '1', 'Y' ) then
                pc_log.log_error('in Invoice loop', p_send_invoice);
                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           l_contact_id,
                           'FEE_BILLING',
                           p_account_type,
                           sysdate,
                           p_user_id,
                           p_user_id );

            end if;

        end if;

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
            pc_log.log_error('UPDATE_CONTACT_INFO', 'Error ' || sqlerrm);
    end update_contact_info;

    function get_broker_info_from_ein (
        p_entrp_code varchar2
    ) return tbl_broker_info
        pipelined
    is
        rec rec_broker_info;
    begin
       --   FOR I IN(SELECT  distinct B.BROKER_ID,B.NAME, B.BROKER_LIC,EMAIL
       --       FROM    ACCOUNT A,BROKER_V B,ENTERPRISE E
       --       WHERE   A.BROKER_ID = B.BROKER_ID AND A.ENTRP_ID = E.ENTRP_ID
       --       AND     E.ENTRP_CODE = P_ENTRP_CODE)
        for i in (
            select distinct
                c.broker_id,
                e.first_name
                || ' '
                || e.last_name  name,
                b.broker_lic,
                e.email,
                nvl(b.ga_id, 0) ga_id
            from
                broker     b,
                account    c,
                enterprise d,
                person     e
            where
                    b.broker_id = c.broker_id
                and c.entrp_id = d.entrp_id
                and entrp_code = p_entrp_code
                and e.pers_id = b.broker_id
        ) loop
            rec.broker_id := i.broker_id;
            rec.broker_name := i.name;
            rec.broker_lic := i.broker_lic;
            rec.email := i.email;
            rec.ga_id := i.ga_id;
            pipe row ( rec );
        end loop;
    end;

    procedure insrt_ar_quote_headers (
        p_quote_name                varchar2,
        p_quote_number              varchar2,
        p_total_quote_price         varchar2,
        p_quote_date                varchar2,
        p_payment_method            varchar2,
        p_entrp_id                  number,
        p_bank_acct_id              number,
        p_ben_plan_id               number,
        p_user_id                   number,
        p_quote_source              in varchar2 default 'ONLINE',
        p_product                   in varchar2,
        p_billing_frequency         in varchar2 default 'A', -- 8471 Joshi
        p_optional_payment_method   varchar2 default null,    -- Added by Jaggi #11262
        p_optional_fee_bank_acct_id number default null,    -- Added by Jaggi #11262
        x_quote_header_id           out number,
        x_return_status             out varchar2,
        x_error_message             out varchar2
    ) is
        l_acc_id      number;
        l_ben_plan_id number;
    begin
        pc_log.log_error('INSRT_AR_QUOTE_HEADERS', 'P_BEN_PLAN_ID' || p_ben_plan_id);
        pc_log.log_error('INSRT_AR_QUOTE_HEADERS', 'P_BILLING_FREQUENCY' || p_billing_frequency);
        pc_log.log_error('INSRT_AR_QUOTE_HEADERS', 'P_ENTRP_ID' || p_entrp_id);
        insert into ar_quote_headers (
            quote_header_id,
            quote_number,
            quote_name,
            quote_status,
            quote_source,
            total_quote_price,
            quote_date,
            payment_method,
            entrp_id,
            bank_acct_id,
            ben_plan_id,
            batch_number,
            billing_frequency,
            optional_fee_payment_method,
            optional_fee_bank_acct_id,                -- Added by Jaggi #11262
            created_by
        ) values ( quote_header_id_seq.nextval,
                   quote_header_id_seq.currval,
                   pc_entrp.get_entrp_name(p_entrp_id)
                   || ':'
                   || quote_header_id_seq.currval,
                   'A',
                   p_quote_source,
                   p_total_quote_price,
                   to_date(p_quote_date, 'MM/DD/RRRR'),
                   p_payment_method,
                   p_entrp_id,
                   p_bank_acct_id,
                   p_ben_plan_id,  -- Commented and Added P_BEN_PLAN_ID by Swamy for Ticket#11364 -- case when p_product <> 'COBRA' THEN P_BEN_PLAN_ID ELSE NULL END,
                   case
                       when p_product in ( 'COBRA', 'FORM_5500' ) then
                           p_ben_plan_id
                       else
                           null
                   end,
                   p_billing_frequency,
                   p_optional_payment_method,                  -- Added by Jaggi #11262
                   p_optional_fee_bank_acct_id,                -- Added by Jaggi #11262
                   p_user_id ) returning quote_header_id into x_quote_header_id;

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
    end;

    procedure insrt_ar_quote_lines (
        p_quote_header_id     number,
        p_rate_plan_id        number,
        p_rate_plan_detail_id number,
        p_line_list_price     number,
        p_notes               varchar2,
        p_user_id             number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is
    begin
        pc_log.log_error('INSRT_AR_QUOTE_LINES', 'P_RATE_PLAN_DETAIL_ID ' || p_rate_plan_detail_id);
        pc_log.log_error('INSRT_AR_QUOTE_LINES', 'RATE_PLAN_ID ' || p_rate_plan_id);
        insert into ar_quote_lines (
            quote_line_id,
            quote_header_id,
            rate_plan_id,
            rate_plan_detail_id,
            line_list_price,
            notes,
            created_by
        ) values ( quote_line_id_seq.nextval,
                   p_quote_header_id,
                   p_rate_plan_id,
                   p_rate_plan_detail_id,
                   p_line_list_price,
                   p_notes,
                   p_user_id );

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
    end;
    -- do not use this we already have other codes
    function get_acc_num (
        p_entrp_code varchar2
    ) return tbl_acc_num
        pipelined
    is
        rec rec_acc_num;
    begin
        for i in (
            select
                acc_num,
                acc_id,
                account_type
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = b.entrp_id
                and entrp_code = p_entrp_code
            union
            select
                acc_num,
                acc_id,
                account_type
            from
                person  a,
                account b
            where
                    a.pers_id = b.pers_id
                and replace(ssn, '-') = p_entrp_code
        ) loop
            rec.acc_num := i.acc_num;
            rec.account_type := i.account_type;
            rec.acc_id := i.acc_id;
            pipe row ( rec );
        end loop;
    end;

    function get_acc_typ (
        p_invoice_id number
    ) return varchar2 is
        l_account_type varchar2(20);
    begin
        select
            account_type
        into l_account_type
        from
            account    a,
            ar_invoice b
        where
                a.acc_id = b.acc_id
            and invoice_id = p_invoice_id;

        return l_account_type;
    end;

    function get_broker_or_ga (
        p_acc_id number
    ) return varchar2 is
        cnt_ga      number := 0;
        cnt_br      number := 0;
        l_broker_ga varchar2(100);
    begin

--SELECT COUNT(*)INTO CNT_ga FROM ACCOUNT A,GENERAL_AGENT B WHERE A.GA_ID=B.GA_ID AND A.GA_ID IS NOT NULL AND ACC_ID = P_ACC_ID;
        select
            count(1)
        into cnt_ga
        from
            general_agent     a,
            sales_team_member b,
            account           ac
        where
                a.ga_id = b.entity_id
            and b.entity_type = 'GENERAL_AGENT'
            and b.end_date is null
            and b.status = 'A'
            and b.emplr_id = ac.entrp_id
            and ac.acc_id = p_acc_id
            and rownum = 1;

        select
            count(1)
        into cnt_br
        from
            account a,
            broker  b
        where
                a.broker_id = b.broker_id
            and a.broker_id != 0
            and acc_id = p_acc_id;

        if cnt_ga + cnt_br >= 2 then
            l_broker_ga := 'BOTH';
        end if;
        if
            cnt_ga > 0
            and cnt_br = 0
        then
            l_broker_ga := 'GA';
        end if;
        if
            cnt_ga = 0
            and cnt_br > 0
        then
            l_broker_ga := 'BROKER';
        end if;
        if
            cnt_br = 0
            and cnt_ga = 0
        then
            l_broker_ga := 'NONE';
        end if;
        return l_broker_ga;
    end get_broker_or_ga;

    procedure upsert_erisa_stage (
        p_entrp_id             number,
        p_acc_id               number,
        p_ben_plan_id          number,
        p_entity_type          varchar2,
        p_grandfathered        varchar2,
        p_clm_lang_in_spd      varchar2,
                                  /*Ticket#5518 */
        p_administered         in varchar2 default null,
        p_subsidy_in_spd_apndx in varchar2 default null,
        p_col_bargain          in varchar2 default null,
        p_ben_plan_number      number,
        p_no_of_eligible       number,
        p_no_of_employees      number,
        p_affiliated_er        varchar2,
        p_controlled_group     varchar2,
        p_note                 varchar2,
        p_bank_acct_num        varchar2,
        p_plan_include         varchar2,
        p_form55_opted         varchar2,
        p_erissa_erap_doc_type in varchar2 default null, -- added by Joshi for renewal
        p_fiscal_end_date      in varchar2,              -- Added by Swamy for Ticket#
        p_user_id              number,
        p_ben_plan_name        varchar2,                 -- added by jaggi #9905
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
        cnt             number;
        v_ben_plan_name varchar2(100);
    begin
        pc_log.log_error('P_AFFILIATED_ER', p_affiliated_er);
        if p_entrp_id is null
           or p_acc_id is null
        or p_ben_plan_id is null then
            return;
        end if;
        select
            count(*)
        into cnt
        from
            online_renewals
        where
                entrp_id = p_entrp_id
            and acc_id = p_acc_id
            and ben_plan_id = p_ben_plan_id;

        if cnt = 1 then
            update online_renewals
            set
                entity_type = p_entity_type,
                grandfathered = p_grandfathered,
                clm_lang_in_spd = p_clm_lang_in_spd,
                ben_plan_number = p_ben_plan_number,
                no_of_eligible = p_no_of_eligible,
                no_of_employees = p_no_of_employees,
                affiliated_er = p_affiliated_er,
                controlled_group = p_controlled_group,
                note = p_note,
                bank_acct_num = p_bank_acct_num,
                plan_include = p_plan_include,
                form55_opted = p_form55_opted,
                erissa_erap_doc_type = p_erissa_erap_doc_type, -- added by Joshi 7791(renewal)
                fiscal_end_date = to_date(p_fiscal_end_date, 'MM/DD/YYYY'), -- added by Joshi 7791(renewal)
                updated = 'N',
                creation_date = sysdate,
                created_by = p_user_id
            where
                    entrp_id = p_entrp_id
                and acc_id = p_acc_id
                and ben_plan_id = p_ben_plan_id;

        elsif cnt = 0 then
            insert into online_renewals (
                renewal_id,
                entrp_id,
                acc_id,
                ben_plan_id,
                entity_type,
                grandfathered,
                clm_lang_in_spd,
                affiliated_er,
                controlled_group,
                ben_plan_number,
                no_of_eligible,
                no_of_employees,
                note,
                bank_acct_num,
                plan_include,
                form55_opted,
                no_of_eligible_old,
                affiliated_er_old,
                controlled_group_old,
                erissa_erap_doc_type,
                fiscal_end_date,
                                       --PLAN_INCLUDE_OLD,
                updated,
                creation_date,
                created_by,
                old_entity_type
            ) values ( online_renewal_seq.nextval,
                       p_entrp_id,
                       p_acc_id,
                       p_ben_plan_id,
                       p_entity_type,
                       p_grandfathered,
                       p_clm_lang_in_spd,
                       p_affiliated_er,
                       p_controlled_group,
                       p_ben_plan_number,
                       p_no_of_eligible,
                       p_no_of_employees,
                       p_note,
                       p_bank_acct_num,
                       p_plan_include,
                       p_form55_opted,
                       (
                           select
                               no_of_eligible
                           from
                               enterprise
                           where
                               entrp_id = p_entrp_id
                       ),
                       (
                           select
                               decode(status, 'A', 'Y', 'N')
                           from
                               entrp_relationships
                           where
                                   entrp_id = p_entrp_id
                               and relationship_type = 'AFFILIATED_ER'
                               and status = 'A'
                               and rownum = 1
                       ),
                       (
                           select
                               decode(status, 'A', 'Y', 'N')
                           from
                               entrp_relationships
                           where
                                   entrp_id = p_entrp_id
                               and relationship_type = 'CONTROLLED_GROUP'
                               and status = 'A'
                               and rownum = 1
                       ),
                       p_erissa_erap_doc_type,
                       to_date(p_fiscal_end_date, 'MM/DD/YYYY'), -- 7791
                       'N',
                       sysdate,
                       p_user_id,
                       (
                           select
                               entity_type
                           from
                               enterprise
                           where
                               entrp_id = p_entrp_id
                       ) );

        end if;

        pc_log.log_error('UPSERT_ERISA_STAGE', 'Before Update ' || sqlerrm);

		-- Added by for 7791(Renewal)
        if nvl(p_erissa_erap_doc_type, 'R') = 'R' then
            v_ben_plan_name := substr(
                pc_entrp.get_entrp_name(p_entrp_id),
                1,
                75
            )
                               || ' Health and Welfare Plan';
        else
            v_ben_plan_name := 'EVERGREEN_'
                               || substr(
                pc_entrp.get_entrp_name(p_entrp_id),
                1,
                64
            )
                               || ' Health and Welfare Plan';
        end if;

        update ben_plan_enrollment_setup
        set
            ben_plan_number = p_ben_plan_number,
            grandfathered = p_grandfathered,
            clm_lang_in_spd = p_clm_lang_in_spd
              --Ticket#5518
            ,
            self_administered = p_administered,
            wrap_plan_5500 = p_form55_opted,
            subsidy_in_spd_apndx = p_subsidy_in_spd_apndx,
            is_collective_plan = p_col_bargain,
            erissa_erap_doc_type = p_erissa_erap_doc_type                         -- added by Joshi for 7791(renewal)
--              , BEN_PLAN_NAME = v_ben_plan_name                                    -- added by Joshi for 7791(renewal)
            ,
            ben_plan_name = nvl(p_ben_plan_name, v_ben_plan_name)               -- added by Jaggi for 9905(erisa-renewal)
            ,
            fiscal_end_date = to_date(p_fiscal_end_date, 'MM/DD/YYYY')            -- Added by Swamy for Ticket#7791
        where
            ben_plan_id = p_ben_plan_id;

        update enterprise
        set
            note = p_note,
            no_of_eligible = p_no_of_eligible,
            entity_type = p_entity_type
              --Ticket#5518
            ,
            no_of_ees = p_no_of_employees
        where
            entrp_id = p_entrp_id;

         /*Ticket#5518 */
       /*  UPDATE ENTERPRISE_CENSUS
         SET census_numbers = P_NO_OF_EMPLOYEES
         where entity_type = 'NO_OF_EMPLOYEES'
         and entity_id = P_ENTRP_ID;
      */  -- Commented and added below by Prabhu

        /*Ticket#5518 */
        update enterprise_census
        set
            census_numbers = p_no_of_employees
        where
                census_code = 'NO_OF_EMPLOYEES'  ----    entity_type commented for ticket#7898 rprabu 06/04/2020
            and entity_id = p_entrp_id;

        /*Ticket#7898  NO_OF_ELIGIBLE  */
        update enterprise_census
        set
            census_numbers = p_no_of_eligible
        where
                census_code = 'NO_OF_ELIGIBLE'
            and entity_id = p_entrp_id;

        if p_affiliated_er = 'N' then
            update entrp_relationships
            set
                status = 'I'
            where
                    entrp_id = p_entrp_id
                and relationship_type = 'AFFILIATED_ER'
                and status = 'A';

        end if;

        if p_controlled_group = 'N' then
            update entrp_relationships
            set
                status = 'I'
            where
                    entrp_id = p_entrp_id
                and relationship_type = 'CONTROLLED_GROUP'
                and status = 'A';

        end if;

        x_return_status := 'S';
        pc_log.log_error('UPSERT_ERISA_STAGE', 'Out of Proc ' || sqlerrm);
    exception
        when others then
            x_error_message := sqlcode
                               || ' = '
                               || sqlerrm;
            x_return_status := 'E';
            pc_log.log_error('UPSERT_ERISA_STAGE', 'error ' || sqlerrm);
    end upsert_erisa_stage;

    procedure upsert_erisa_ben_codes (
        p_entity_id             number,
        p_benefit_code_id       number,
        p_benefit_code_name     varchar2,
        p_eligibility           varchar2,
        p_er_cont_pref          varchar2,
        p_ee_cont_pref          varchar2,
        p_contrib_lng           varchar2,
        p_refer_to_doc          varchar2,
        p_eligibility_refer_doc varchar2, -- Added by Joshi for 7791(Renewal)
        p_other_desc            varchar2, /*Ticket#5518*/
        p_user_id               number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    ) is

        cnt                  number;
        l_ben_code_id        number;
        l_benefit_code_count number := 0;
        l_entity_type        varchar2(100) := null;
    begin
        pc_log.log_error('UPSERT_ERISA_BEN_CODES', 'P_BENEFIT_CODE_ID' || p_benefit_code_id);
        pc_log.log_error('UPSERT_ERISA_BEN_CODES', 'P_BENEFIT_CODE_NAME' || p_benefit_code_name);
        pc_log.log_error('UPSERT_ERISA_BEN_CODES', 'P_ENTITY_ID' || p_entity_id);
        pc_log.log_error('UPSERT_ERISA_BEN_CODES', 'P_ELIGIBILITY' || p_eligibility);
        pc_log.log_error('UPSERT_ERISA_BEN_CODES', 'P_ER_CONT_PREF' || p_er_cont_pref);
        pc_log.log_error('UPSERT_ERISA_BEN_CODES', 'P_EE_CONT_PREF' || p_ee_cont_pref);

    /*
     IF (P_BENEFIT_CODE_ID IS NOT NULL OR P_BENEFIT_CODE_ID <> '') THEN
       SELECT COUNT (*)
         INTO CNT
         FROM BENEFIT_CODES
        WHERE ENTITY_ID = P_ENTITY_ID AND BENEFIT_CODE_ID = P_BENEFIT_CODE_ID;
       PC_LOG.LOG_ERROR('UPSERT_ERISA_BEN_CODES','CNT'||CNT);
      END iF;
       IF nvl(CNT,0) = 1
       THEN
          UPDATE BENEFIT_CODES
             SET ELIGIBILITY = P_ELIGIBILITY
                ,ER_CONT_PREF=P_ER_CONT_PREF
                ,EE_CONT_PREF=P_EE_CONT_PREF
                ,ER_EE_CONTRIB_LNG = P_CONTRIB_LNG /*Ticket#5518*/
        --   WHERE ENTITY_ID = P_ENTITY_ID
        --   AND BENEFIT_CODE_ID = P_BENEFIT_CODE_ID;

      -- END IF;
     -- ELSE  --cnt is 0
        --     PC_LOG.LOG_ERROR('UPSERT_ERISA_BEN_CODES','CNT'||CNT);
        --     PC_LOG.LOG_ERROR('UPSERT_ERISA_BEN_CODES','P_BENEFIT_CODE_NAME'||P_BENEFIT_CODE_NAME);

        /* delete everything earier and just insert again. So this handles scenarios where user changes selection */
        --DELETE FROM BENEFIT_CODES WHERE ENTITY_ID = P_ENTITY_ID;

        select
            count(*)
        into l_benefit_code_count
        from
            benefit_codes
        where
                benefit_code_name = p_benefit_code_name
            and entity_id = p_entity_id
            and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
            and upper(benefit_code_name) <> 'OTHER';

        if l_benefit_code_count = 0 then  --To avoid duplicates
            if p_benefit_code_name is not null then
          /* From website during renewal we need to distinguish between codes seleced for welface chart and other sections */
                if p_eligibility is null then
                    l_entity_type := 'BEN_PLAN_RENEWAL';
                else
                    l_entity_type := 'SUBSIDIARY_CONTRACT';
                end if;

                insert into benefit_codes (
                    entity_id,
                    entity_type,
                    benefit_code_id,
                    benefit_code_name,
                    eligibility,
                    er_cont_pref,
                    ee_cont_pref,
                    er_ee_contrib_lng,/*Ticket#5518 */
                    refer_to_doc,
                    eligibility_refer_to_doc, -- added by Joshi 7791 (renewal).
                    description,
                    created_by
                ) values ( p_entity_id,
                           l_entity_type,
                           benefit_code_seq.nextval,
                           p_benefit_code_name,
                           (
                               select
                                   description
                               from
                                   lookups
                               where
                                   lookup_code = p_eligibility
                           ),
                           p_er_cont_pref,
                           p_ee_cont_pref,
                           (
                               select
                                   description
                               from
                                   lookups
                               where
                                   lookup_code = p_contrib_lng
                           ),
                           p_refer_to_doc,
                           p_eligibility_refer_doc,
                           p_other_desc,
                           p_user_id );/*Ticket#5518 */
            end if; /* End of Name Loop */
        end if; /* End of Duplicate Code */

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
            pc_log.log_error('UPSERT_ERISA_BEN_CODES', 'SQLERRM' || sqlerrm);
    end;

    procedure insert_alert (
        p_subject in varchar2,
        p_message in varchar2
    ) is
        l_notification_id number;
    begin
        pc_notifications.insert_notifications(
            p_from_address    => 'oracle@sterlingadministration.com',
            p_to_address      => 'IT-Team@sterlingadministration.com',--'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com',
            p_cc_address      => 'IT-Team@sterlingadministration.com',--'customer.service@sterlingadministration.com',
            p_subject         => p_subject,
            p_message_body    => p_message,
            p_user_id         => 0,
            p_acc_id          => null,
            x_notification_id => l_notification_id
        );

        update email_notifications
        set
            mail_status = 'READY'
        where
            notification_id = l_notification_id;

    end;
   -- NOT USED
    procedure post_renewal_details (
        p_user_id       in number,
        x_file_name     out varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        post_renewals_det post_renewals_det_tbl;
        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            long;
        l_file_id         number;
        no_posting exception;
    begin
       --Nightly Report of all Renewals for ERISA/POP
        x_return_status := 'S';
        select
            *
        bulk collect
        into post_renewals_det
        from
            (
                select
                    '"'
                    || a.name
                    || '"'                                   employer_name,
                    acc_num,
                    b.account_type,
                    to_char(c.plan_start_date, 'MM/DD/YYYY') eff_date,
                    to_char(c.plan_end_date, 'MM/DD/YYYY')   end_date,
                    null                                     doc_change,
                    null                                     doc_update,
                    null                                     acc_manager,
                    null                                     sales_rep,
                    null                                     inv_to_brkr,
                    null                                     brkr_info_cnf,
                    null                                     brkr_name,
                    null                                     brkr_email
--         BULK COLLECT INTO POST_RENEWALS_DET
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = c.acc_id
                    and b.account_type in ( 'ERISA_WRAP', 'POP' )
                    and b.account_status = 1
                    and trunc(c.renewal_date) = trunc(sysdate - 1)
                union
                select
                    '"'
                    || a.name
                    || '"' employer_name,
                    acc_num,
                    b.account_type,
                    to_char(c.start_date, 'MM/DD/YYYY'),
                    to_char(c.end_date, 'MM/DD/YYYY'),
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null
--         BULK COLLECT INTO POST_RENEWALS_DET
                from
                    enterprise        a,
                    account           b,
                    ben_plan_renewals c
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = c.acc_id
                    and b.account_type = 'COBRA'
                    and b.account_status = 1
                    and trunc(c.creation_date) = trunc(sysdate - 1)
            );

        if post_renewals_det.count = 0 then
            raise no_posting;
        else
            l_file_id := pc_file_upload.insert_file_seq('DAILY_RENEWAL_POP_ERISA');
            l_file_name := 'Daily_Renewal_Pop_Erisa_'
                           || l_file_id
                           || '_'
                           || to_char(sysdate, 'YYYYMMDDHH24MISS')
                           || '.CSV';

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;--dbms_output.put_line(L_FILE_NAME);

            l_utl_id := utl_file.fopen('DAILY_RENEWAL_POP_ERISA', l_file_name, 'W');
            l_line := 'Employer Name'
                      || ','
                      || 'Account Number'
                      || ','
                      || 'Product'
                      || ','
                      || 'Effective Date'
                      || ','
                      || 'end Date'
                      || ','
                      || 'Document Change'
                      || ','
                      || 'Update on Document';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            for i in 1..post_renewals_det.count loop
                l_line := post_renewals_det(i).employer_name
                          || ','
                          || post_renewals_det(i).account_number
                          || ','
                          || post_renewals_det(i).product
                          || ','
                          || post_renewals_det(i).eff_date
                          || ','
                          || post_renewals_det(i).end_date
                          || ','
                          || post_renewals_det(i).doc_change
                          || ','
                          || post_renewals_det(i).doc_update;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

            utl_file.fclose(file => l_utl_id);
        end if;

        x_file_name := l_file_name;
        x_error_message := null;
        commit;
    exception
        when no_posting then
            null;
        when others then
            x_error_message := sqlerrm
                               || ' '
                               || sqlcode;
            insert_alert('Error in creating Renewal File in Proc PC_WEB_COMPLIANCE.POST_RENEWAL_DETAILS', x_error_message);
    end post_renewal_details;
   -- NOT USED
    procedure past_renewal_details (
        p_user_id       in number,
        x_file_name     out varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        past_renewals_det past_renewals_det_tbl;
        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            long;
        l_file_id         number;
        no_posting exception;
    begin
       --2 Days Past Renewals Report of all Plans for ERISA/POP/COBRA
        x_return_status := 'S';
        select
            *
        bulk collect
        into past_renewals_det
        from
            (
                select
                    '"'
                    || a.name
                    || '"'                                      employer_name,
                    acc_num,
                    b.account_type,
                    to_char(c.plan_start_date, 'MM/DD/YYYY')    eff_date,
                    to_char(c.plan_end_date, 'MM/DD/YYYY')      end_date,
                    null                                        doc_change,
                    pc_account.get_salesrep_name(b.salesrep_id) sales_rep,
                    null                                        doc_update,
                    null                                        acc_manager,
                    null                                        inv_to_brkr,
                    null                                        brkr_info_cnf,
                    null                                        brkr_name,
                    null                                        brkr_email
--         BULK COLLECT INTO PAST_RENEWALS_DET
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = c.acc_id
                    and b.account_type in ( 'ERISA_WRAP', 'POP' )
                    and b.account_status = 1
                    and trunc(c.plan_end_date) + 2 = trunc(sysdate - 1)
                union
                select
                    '"'
                    || a.name
                    || '"' employer_name,
                    acc_num,
                    b.account_type,
                    to_char(c.start_date, 'MM/DD/YYYY'),
                    to_char(c.end_date, 'MM/DD/YYYY'),
                    null,
                    pc_account.get_salesrep_name(b.salesrep_id),
                    null,
                    null,
                    null,
                    null,
                    null,
                    null
                from
                    enterprise        a,
                    account           b,
                    ben_plan_renewals c
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = c.acc_id
                    and b.account_type = 'COBRA'
                    and account_status = 1
                    and trunc(nvl(c.end_date,
                                  add_months(b.start_date, 12))) + 2 = trunc(sysdate - 1)
            );

        if past_renewals_det.count = 0 then
            raise no_posting;
        else
            l_file_id := pc_file_upload.insert_file_seq('DAILY_RENEW_POP_ERISA_PAST_DUE');
            l_file_name := 'Past_Due_Renewal_Pop_Erisa_'
                           || l_file_id
                           || '_'
                           || to_char(sysdate, 'YYYYMMDDHH24MISS')
                           || '.CSV';

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DAILY_RENEW_POP_ERISA_PAST_DUE', l_file_name, 'W');
            l_line := 'Employer Name'
                      || ','
                      || 'Account Number'
                      || ','
                      || 'Product'
                      || ','
                      || 'Effective Date'
                      || ','
                      || 'End Date'
                      || ','
                      || 'Account Manager'
                      || ','
                      || 'Sales Representative';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            for i in 1..past_renewals_det.count loop
                l_line := past_renewals_det(i).employer_name
                          || ','
                          || past_renewals_det(i).account_number
                          || ','
                          || past_renewals_det(i).product
                          || ','
                          || past_renewals_det(i).eff_date
                          || ','
                          || past_renewals_det(i).end_date
                          || ','
                          || past_renewals_det(i).acc_manager
                          || ','
                          || past_renewals_det(i).sales_rep;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

            utl_file.fclose(file => l_utl_id);
        end if;

        x_file_name := l_file_name;
        x_error_message := null;
        commit;
    exception
        when no_posting then
            null;
        when others then
            x_error_message := sqlerrm
                               || ' '
                               || sqlcode;
            insert_alert('Error in creating File in Proc PC_WEB_COMPLIANCE.PAST_RENEWAL_DETAILS', x_error_message);
    end past_renewal_details;
   -- NOT USED
    procedure post_weekly_renewal_details /*(
                    P_USER_ID       IN  NUMBER
                   ,X_FILE_NAME     OUT VARCHAR2
                   ,X_ERROR_MESSAGE OUT VARCHAR2
                   ,X_RETURN_STATUS OUT VARCHAR2)*/ is

        post_renewals_week_det post_renewals_week_det_tbl;
        l_utl_id               utl_file.file_type;
        l_file_name            varchar2(3200);
        l_line                 long;
        l_file_id              number;
        no_posting exception;
    begin
       --Nightly Report of Weekly Renewals for ERISA/POP/COBRA
--       X_RETURN_STATUS := 'S';

/*       SELECT replace(A.NAME,',')EMPLOYER_NAME,
              regexp_replace(acc_num,'[[:cntrl:]]')acc_num,
              B.ACCOUNT_TYPE,
              TO_CHAR(C.PLAN_start_DATE,'MM/DD/YYYY')eff_DATE,
              TO_CHAR(C.PLAN_END_DATE,'MM/DD/YYYY')END_DATE,
              NULL,
              (SELECT M.NAME||' ('||K.EMAIL||')'
                 FROM ACCOUNT L, SALESREP M, EMPLOYEE K
                WHERE L.ACC_ID      = B.ACC_ID
                  AND L.SALESREP_ID = M.SALESREP_ID
                  AND K.EMP_ID      = M.EMP_ID) SALES_REP,
              NULL,
              NULL,
              (SELECT replace(max(K.FIRST_NAME||' '||K.LAST_NAME),',')BROKER_NAME
                 FROM BROKER_ASSIGNMENTS L,
                      BROKER M,
                      PERSON K
                WHERE L.ENTRP_ID  = A.ENTRP_ID
                  AND M.BROKER_ID = (SELECT MAX(BROKER_ID)
                                       FROM BROKER_ASSIGNMENTS
                                      WHERE ENTRP_ID  = L.ENTRP_ID
                                        AND PERS_ID IS NULL)
                  AND M.BROKER_ID = L.BROKER_ID
                  AND K.PERS_ID   = M.BROKER_ID
                  AND L.PERS_ID IS NULL) BROKER_NAME,
              (SELECT max(K.EMAIL)BROKER_EMAIL
                 FROM BROKER_ASSIGNMENTS L,
                      BROKER M,
                      PERSON K
                WHERE L.ENTRP_ID  = A.ENTRP_ID
                  AND M.BROKER_ID = (SELECT MAX(BROKER_ID)
                                       FROM BROKER_ASSIGNMENTS
                                      WHERE ENTRP_ID  = L.ENTRP_ID
                                        AND PERS_ID IS NULL)
                  AND M.BROKER_ID = L.BROKER_ID
                  AND K.PERS_ID   = M.BROKER_ID
                  AND L.PERS_ID IS NULL) BROKER_EMAIL,
              NULL,
              NULL
         BULK COLLECT INTO POST_RENEWALS_WEEK_DET
         FROM ENTERPRISE A,
              ACCOUNT B,
              BEN_PLAN_ENROLLMENT_SETUP C
        WHERE A.ENTRP_ID  = B.ENTRP_ID
          AND B.ACC_ID    = C.ACC_ID
          AND B.ACCOUNT_TYPE IN ('ERISA_WRAP','POP')
          AND B.ACCOUNT_STATUS   =1
          AND trunc(C.RENEWAL_DATE)     = TRUNC(SYSDATE-1);*/

        post_renewals_week_det := null;
        with slsrp as (
            select
                c.entrp_id,
                first_name,
                email
            from
                person             a,
                broker             b,
                broker_assignments c
            where
                    a.pers_id = b.broker_id
                and b.broker_id = c.broker_id
                and c.pers_id is null
                and b.broker_id = (
                    select
                        max(broker_id)
                    from
                        broker_assignments
                    where
                            entrp_id = c.entrp_id
                        and pers_id is null
                )
        )
        select distinct
            replace(a.name, ',')                     name,
            regexp_replace(acc_num, '[[:cntrl:]]')   acc_num,
            account_type,
            to_char(c.plan_start_date, 'MM/DD/YYYY') eff_date,
            to_char(c.plan_end_date, 'MM/DD/YYYY')   end_date,
            null,
            null,
            'acnt mgr'                               acnt_mgr,
            replace(e.name, ',')
            || ' ('
            || f.email
            || ')'                                   salesrep,
            case
                when h.entrp_id is null then
                    'N'
                else
                    'Y'
            end                                      send_invoice,
            null                                     brkr_info,
            replace(g.first_name, ',')               brkr_name,
            g.email                                  brkr_email
        bulk collect
        into post_renewals_week_det
        from
            enterprise                a,
            account                   b,
            ben_plan_enrollment_setup c,
            broker_assignments        d,
            slsrp                     g,
            salesrep                  e,
            employee                  f,
            (
                select distinct
                    entrp_id
                from
                    send_invoice
            )                         h
        where
                a.entrp_id = b.entrp_id
            and b.acc_id = c.acc_id
            and b.salesrep_id = e.salesrep_id
            and a.entrp_id = d.entrp_id (+)
            and e.emp_id = f.emp_id
            and a.entrp_id = g.entrp_id
            and a.entrp_id = h.entrp_id (+)
            and account_type in ( 'ERISA_WRAP', 'POP' )
            and b.account_status = 1
            and trunc(c.renewal_date) = trunc(sysdate);

        if post_renewals_week_det.count = 0 then
            raise no_posting;
        else
            l_file_id := pc_file_upload.insert_file_seq('WEEKLY_RENEWAL_POP_ERISA_COBRA');
            l_file_name := 'Weekly_Renewal_Pop_Erisa_Cobra_'
                           || l_file_id
                           || '_'
                           || to_char(sysdate, 'YYYYMMDDHH24MISS')
                           || '.CSV';

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('WEEKLY_RENEWAL_POP_ERISA_COBRA', l_file_name, 'W');
            l_line := 'Employer Name'
                      || ','
                      || 'Account Number'
                      || ','
                      || 'Product'
                      || ','
                      || 'Effective Date'
                      || ','
                      || 'End Date'
                      || ','
                      || 'Account Manager'
                      || ','
                      || 'Sales Representative'
                      || ','
                      || 'Invoice to Broker (Yes/No)'
                      || ','
                      || 'Broker Information confirmed (Yes/No)'
                      || ','
                      || 'Broker Name'
                      || ','
                      || 'Broker Email Address';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            for i in 1..post_renewals_week_det.count loop
                l_line := post_renewals_week_det(i).employer_name
                          || ','
                          || post_renewals_week_det(i).account_number
                          || ','
                          || post_renewals_week_det(i).product
                          || ','
                          || post_renewals_week_det(i).eff_date
                          || ','
                          || post_renewals_week_det(i).end_date
                          || ','
                          || post_renewals_week_det(i).acc_manager
                          || ','
                          || post_renewals_week_det(i).sales_rep
                          || ','
                          || post_renewals_week_det(i).inv_to_brkr
                          || ','
                          || post_renewals_week_det(i).brkr_info_cnf
                          || ','
                          || nvl(post_renewals_week_det(i).brkr_name,
                                 'No Broker On Record')
                          || ','
                          || post_renewals_week_det(i).brkr_email;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

            utl_file.fclose(file => l_utl_id);
        end if;

--         X_FILE_NAME := L_FILE_NAME;
--         X_ERROR_MESSAGE := NULL;

        commit;
    exception
        when no_posting then
            null;
        when others then
--              X_ERROR_MESSAGE := SQLERRM||' '||SQLCODE;
            insert_alert('Error in creating Renewal File in Proc PC_WEB_COMPLIANCE.POST_WEEKLY_RENEWAL_DETAILS', sqlerrm);
    end post_weekly_renewal_details;


       -- To be Sent to intake everyday
    function display_pop_renewal (
        p_acc_id in number
    ) return varchar2 is
        l_return_val varchar2(1000);
    begin
        for x in (
            select
                invoice_id
            from
                ar_invoice
            where
                    acc_id = p_acc_id
                and status = 'PROCESSED'
        ) loop
           --RETURN 'INV_PENDING:'||x.invoice_id;
            l_return_val := 'INV_PENDING:' || x.invoice_id;
        end loop;

        if l_return_val is null then
            for x in (
                select
                    a.acc_id
                from
                    account                   a,
                    ben_plan_enrollment_setup b
                where
                        account_type = 'POP'
                    and a.plan_code = 512
                    and a.acc_id = p_acc_id
                    and a.acc_id = b.acc_id
                    and b.plan_type = 'NDT'
                    and b.plan_end_date = trunc(sysdate + 90)
                    and end_date is null
                    and account_status = 1
            ) loop
               --RETURN 'DUE_FOR_RENEWAL';
                l_return_val := 'DUE_FOR_RENEWAL';
            end loop;

        end if;

        return nvl(l_return_val, 'N');
    end display_pop_renewal;
   -- NOT USED
    function get_bank_name (
        p_entrp_id number
    ) return tbl_bank_name
        pipelined
    is
        cnt number;
        rec rec_bank_name;
    begin
        pipe row ( rec );
    end;

    function get_er_plans (
        p_acc_id       number,
        p_product_type in varchar2 default null,
        p_tax_id       in varchar2 default null
    ) return tbl_rnwl
        pipelined
    is

        l_entrp_code            varchar2(20);
        cnt                     number;
        rec                     rec_rnwl;--L_BEN_PLAN_ID NUMBER;
        l_inv_count             number := 0;
        l_renewal_resubmit_flag varchar2(1);
        l_max_plan_id           number;
        l_plan_start_date       date; -- Added by Swamy for Ticket#11636
        l_prev_plan_start_date  date; -- Added by Swamy for Ticket#11636

    begin
        if p_product_type in ( 'ERISA_WRAP' ) then
            -- Added by Swamy for Ticket#10431(Renewal Resubmit)
            for j in (
                select
                    renewal_resubmit_flag
                from
                    account
                where
                    acc_id = p_acc_id
            ) loop
                l_renewal_resubmit_flag := j.renewal_resubmit_flag;
            end loop;

            for k in (
                select
                    max(ben_plan_id) ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                    acc_id = p_acc_id
            ) loop
                l_max_plan_id := k.ben_plan_id;
            end loop;

            if l_renewal_resubmit_flag = 'Y' then
                for m in (
                    select
                        max(ben_plan_id) ben_plan_id
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and ben_plan_id <> l_max_plan_id
                ) loop
                    l_max_plan_id := m.ben_plan_id;
                end loop;
            end if;
             --
            for i in (
                select
                    b.acc_id,
                    acc_num,
                    ben_plan_id,
                    strip_bad(a.entrp_code)                      ein,
                    nvl(product_type, account_type)              product_type,
                    decode(plan_type, 'NEW', 'RENEW', plan_type) plan_type,
                    plan_start_date                              plan_start_date,
                    plan_end_date                                plan_end_date,
                    b.renewal_resubmit_flag      -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                    ,
                    b.renewal_resubmit_assigned_to -- Added by jaggi #11636
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = c.acc_id
                    and account_status = 1
                    and b.acc_id = p_acc_id
                    and ben_plan_id = l_max_plan_id --( SELECT MAX(BEN_PLAN_ID) FROM BEN_PLAN_ENROLLMENT_SETUP BP WHERE ACC_ID = B.ACC_ID )    -- Commented and Added l_max_plan_id by Swamy for Ticket#10431(Renewal Resubmit)
                    and account_type in ( 'ERISA_WRAP' )
                    and not exists (
                        select
                            1
                        from
                            account_preference ap
                        where
                                b.acc_id = ap.acc_id
                            and ap.allow_online_renewal = 'N'
                    )
                order by
                    ben_plan_id desc
            )   --- rprabu 7456 on 08/04/2019
             loop
           --  IF (i.PLAN_END_DATE < SYSDATE
          --    OR (I.PLAN_END_DATE BETWEEN TRUNC(SYSDATE)- 60 AND  TRUNC(SYSDATE)+ 90))
         --  AND I.PLAN_START_DATE < SYSDATE
         --Ticket#7580.Plans ending in 2017 should not come up for renewal
           --IF (I.PLAN_END_DATE BETWEEN TRUNC(SYSDATE)- 180 AND  TRUNC(SYSDATE)+ 90) AND I.PLAN_START_DATE < SYSDATE
           -- Added by Joshi for 7522

                if (
                    ( i.plan_end_date between trunc(sysdate) - pc_web_er_renewal.g_after_days and trunc(sysdate) + pc_web_er_renewal.g_prior_days
                    )
                    and ( i.plan_start_date < sysdate )
                )
           --OR (NVL(i.renewal_resubmit_flag,'N') = 'Y' AND i.BEN_PLAN_ID <> l_max_plan_id)  -- Added OR Cond. by Swamy for Ticket#10431(Renewal Resubmit)
                 then
                    rec.acc_id := i.acc_id;
                    rec.acc_num := i.acc_num;
                    rec.ben_plan_id := i.ben_plan_id;
                    rec.product_type := i.product_type;
                    rec.plan_type := i.plan_type;
                    rec.ein := i.ein;
                    rec.plan_name := pc_lookups.get_account_type(i.product_type);
                    rec.renewal_resubmit_assigned_to := i.renewal_resubmit_assigned_to; -- Added by jaggi #11636

                    rec.plan_year := to_char(i.plan_start_date, 'mm/dd/rrrr')
                                     || '-'
                                     || to_char(i.plan_end_date, 'mm/dd/rrrr');

                    rec.new_plan_year := to_char(i.plan_end_date + 1, 'mm/dd/rrrr')
                                         || '-'
                                         || to_char(
                        last_day(add_months(i.plan_end_date, 12)),
                        'mm/dd/rrrr'
                    );
           --  IF P_PRODUCT_TYPE = 'POP' THEN
             --   REC.NEW_PLAN_YEAR:=TO_CHAR(I.PLAN_END_DATE+1,'mm/dd/rrrr')||'-'||TO_CHAR(LAST_DAY(ADD_MONTHS(I.PLAN_END_DATE,60)),'mm/dd/rrrr');
            -- END IF;
                    for k in (
                        select
                            creation_date
                        from
                            ben_plan_denials
                        where
                            ben_plan_id = rec.ben_plan_id
                    ) loop
                        rec.declined := 'Y';
                        rec.declined_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end loop;

                    rec.renewed := 'N';  -- Added by Swamy for Ticket#9384
                    for k in (
                        select
                            creation_date
                        from
                            ben_plan_renewals
                        where
                                acc_id = rec.acc_id
                            and ben_plan_id >= rec.ben_plan_id    -- Equalto Added by Swamy for Ticket#9384
                            and i.renewal_resubmit_flag = 'N'
                    )   -- 10431 swamy
                     loop
                        rec.renewed := 'Y';
                        rec.renewal_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end loop;

                    rec.declined := nvl(rec.declined, 'N');
                    rec.renewed := nvl(rec.renewed, 'N');

            -- Start Added by Swamy for Ticket#9384
                    rec.plan_end_date := i.plan_end_date;
                    if trunc(sysdate) <= trunc(i.plan_end_date + 1) then
                        rec.renewal_deadline := i.plan_end_date;
                    end if;

                    for m in (
                        select
                            flag
                        from
                            table ( pc_web_compliance.is_plan_renewed_already(i.acc_id, i.product_type) )
                    ) loop
                        rec.is_renewed := m.flag;
                    end loop;
			-- End of Addition by Swamy for Ticket#9384

                    if rec.acc_id is not null then
                        rec.renewal_resubmit_flag := i.renewal_resubmit_flag;  -- 10431 Joshi
                        pipe row ( rec );
                    end if;

                end if;
            end loop;

        end if;

        if p_product_type in ( 'POP' ) then
            -- Added by Swamy for Ticket#10431(Renewal Resubmit)
            for j in (
                select
                    renewal_resubmit_flag
                from
                    account
                where
                    acc_id = p_acc_id
            ) loop
                l_renewal_resubmit_flag := j.renewal_resubmit_flag;
            end loop;

            /* commented by Joshi for prod issue INC18122
               FOR k IN (SELECT MAX(BEN_PLAN_ID) BEN_PLAN_ID FROM BEN_PLAN_ENROLLMENT_SETUP where acc_id = p_acc_id) LOOP
                l_max_plan_id := k.BEN_PLAN_ID;
               END LOOP; */

               -- Added by Joshi for prod issue INC18122 /12563
            for k in (
                select
                    bo.ben_plan_id
                from
                    ben_plan_enrollment_setup bo
                where
                        bo.acc_id = p_acc_id
                    and trunc(bo.plan_start_date) = (
                        select
                            max(trunc(bi.plan_start_date))
                        from
                            ben_plan_enrollment_setup bi
                        where
                            bi.acc_id = bo.acc_id
                    )
            ) loop
                l_max_plan_id := k.ben_plan_id;
            end loop;

            if l_renewal_resubmit_flag = 'Y' then
                for m in (
                    select
                        max(ben_plan_id) ben_plan_id
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and ben_plan_id <> l_max_plan_id
                ) loop
                    l_max_plan_id := m.ben_plan_id;
                end loop;
            end if;
             --

            for i in (
                select
                    b.acc_id,
                    acc_num,
                    ben_plan_id,
                    strip_bad(a.entrp_code)                      ein,
                    nvl(product_type, account_type)              product_type,
                    decode(plan_type, 'NEW', 'RENEW', plan_type) plan_type,
                    plan_start_date                              plan_start_date,
                    plan_end_date                                plan_end_date,
                    b.renewal_resubmit_flag      -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = c.acc_id
                    and account_status = 1
                    and b.acc_id = p_acc_id
                    and c.plan_type <> 'NDT'  --NDT plans should not come up for POP
                    and ben_plan_id = l_max_plan_id --( SELECT MAX(BEN_PLAN_ID) FROM BEN_PLAN_ENROLLMENT_SETUP BP WHERE ACC_ID = B.ACC_ID AND C.PLAN_TYPE = BP.PLAN_TYPE) ---- Commented and Added l_max_plan_id by swamy 10431 --NDT plans should not come up for POP
                    and account_type in ( 'POP' )
                    and not exists (
                        select
                            1
                        from
                            account_preference ap
                        where
                                b.acc_id = ap.acc_id
                            and ap.allow_online_renewal = 'N'
                    )
            ) loop
                pc_log.log_error('PC_WEB_COMPLIANCE.GET_ER_PLANS', 'I.PLAN_END_DATE :='
                                                                   || i.plan_end_date
                                                                   || ' I.PLAN_START_DATE :='
                                                                   || i.plan_start_date);
           -- Commented the below code by swamy for Ticket#7456, As per the test case, there were 2 plans, with sysdate = 10-APR-2019
           -- Plan 1) BASIC_POP with plan_start_date = 22-APR-13 and Plan_end_date=30-JUN-18
           -- Plan 2) COMP_POP_RENEW with plan_start_date = 01-JUL-18 and Plan_end_date=30-JUN-19
           -- Only the latest record should be taken into consideration, but due to the "OR" cond.2 records were picking up by the system.
           -- As there are 2 records system was taking BASIC_POP as the plan_type which was passed as in parameter to function emp_plan_renewal_disp_pop
           -- The function emp_plan_renewal_disp_pop returned "N" as there was no record with BASIC_POP, as the system was looking for "COMP_POP_RENEW".

                if
                    (/*i.PLAN_END_DATE < SYSDATE
              OR */ ( i.plan_end_date between trunc(sysdate) - pc_web_er_renewal.g_after_days and trunc(sysdate) + pc_web_er_renewal.g_prior_days
                    ) )
                    and i.plan_start_date < sysdate
                then
                    rec.acc_id := i.acc_id;
                    rec.acc_num := i.acc_num;
                    rec.ben_plan_id := i.ben_plan_id;
                    rec.product_type := i.product_type;
                    rec.plan_type := i.plan_type;
                    rec.ein := i.ein;
                    rec.plan_name := pc_lookups.get_account_type(i.product_type);
                    rec.plan_year := to_char(i.plan_start_date, 'mm/dd/rrrr')
                                     || '-'
                                     || to_char(i.plan_end_date, 'mm/dd/rrrr');

                    rec.new_plan_year := to_char(i.plan_end_date + 1, 'mm/dd/rrrr')
                                         || '-'
                                         || to_char(
                        last_day(add_months(i.plan_end_date, 12)),
                        'mm/dd/rrrr'
                    );

                    if p_product_type = 'POP' then
                        rec.new_plan_year := to_char(i.plan_end_date + 1, 'mm/dd/rrrr')
                                             || '-'
                                             || to_char(
                            last_day(add_months(i.plan_end_date, pc_web_er_renewal.g_after_days)),
                            'mm/dd/rrrr'
                        );
                    end if;

                    for k in (
                        select
                            creation_date
                        from
                            ben_plan_denials
                        where
                            ben_plan_id = rec.ben_plan_id
                    ) loop
                        rec.declined := 'Y';
                        rec.declined_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end loop;
			 -- Start Added by Swamy for Ticket#9384
                    rec.renewed := 'N';
                    rec.plan_end_date := i.plan_end_date;
                    if trunc(sysdate) <= trunc(i.plan_end_date + 1) then
                        rec.renewal_deadline := i.plan_end_date;
                    end if;

                    for k in (
                        select
                            flag
                        from
                            table ( pc_web_compliance.is_plan_renewed_already(i.acc_id, i.product_type) )
                    ) loop
                        rec.is_renewed := k.flag;
                    end loop;
            -- End of Addition by Swamy for Ticket#9384

                    for k in (
                        select
                            creation_date
                        from
                            ben_plan_renewals
                        where
                                acc_id = rec.acc_id
                            and ben_plan_id > rec.ben_plan_id    -- Equalto Added by Swamy for Ticket#9384
                            and i.renewal_resubmit_flag = 'N'
                    )   -- 10431 swamy
                     loop
                        rec.renewed := 'Y';
                        rec.renewal_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end loop;

                    rec.declined := nvl(rec.declined, 'N');
                    rec.renewed := nvl(rec.renewed, 'N');
                    pc_log.log_error('PC_WEB_COMPLIANCE.GET_ER_PLANS', 'REC.acc_id:=' || rec.acc_id);
                    if rec.acc_id is not null then
                        rec.renewal_resubmit_flag := i.renewal_resubmit_flag; -- 10431 Joshi
                        pipe row ( rec );
                    end if;

                end if;

            end loop;

        end if;

        if p_product_type = 'COBRA' then

            -- Added by Swamy for Ticket#11636
            for j in (
                select
                    nvl(renewal_resubmit_flag, 'N') renewal_resubmit_flag
                from
                    account
                where
                    acc_id = p_acc_id
            ) loop
                l_renewal_resubmit_flag := j.renewal_resubmit_flag;
            end loop;

            for j in (
                select
                    max(plan_start_date) plan_start_date
                from
                    ben_plan_enrollment_setup
                where
                    acc_id = p_acc_id
            ) loop
                l_plan_start_date := j.plan_start_date;
            end loop;

            for k in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and plan_start_date = l_plan_start_date
            ) loop
                l_max_plan_id := k.ben_plan_id;
            end loop;

            if l_renewal_resubmit_flag = 'Y' then
                for j in (
                    select
                        max(plan_start_date) plan_start_date
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and plan_start_date < l_plan_start_date
                ) loop
                    l_prev_plan_start_date := j.plan_start_date;
                end loop;

                for k in (
                    select
                        ben_plan_id
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and plan_start_date = l_prev_plan_start_date
                ) loop
                    l_max_plan_id := k.ben_plan_id;
                end loop;

            end if;
             -- 

            for x in (
                select
                    a.acc_id,
                    a.ben_plan_id,
                    b.acc_num,
                    b.entrp_id,
                    a.plan_start_date start_date,
                    a.plan_end_date   plan_end_date,
                    b.renewal_resubmit_assigned_to,
                    b.renewal_resubmit_flag
                from
                    ben_plan_enrollment_setup a,
                    account                   b
                where
                        a.acc_id = p_acc_id
                    and a.status = 'A'
                    and a.acc_id = b.acc_id
                    and plan_type in ( 'COBRA', 'COBRA_RENEW' )
                    and a.plan_start_date <= trunc(sysdate)   -- Added by Swamy for Ticket#10483 21/10/21
                  --AND A.BEN_PLAN_ID = ( SELECT MAX(BEN_PLAN_ID) FROM BEN_PLAN_ENROLLMENT_SETUP BP WHERE ACC_ID = A.ACC_ID )--SK updated on 06/04/2021 to pull max plan
                    and a.ben_plan_id = l_max_plan_id  -- Added by Swamy for Ticket#11636
                    and not exists (
                        select
                            1
                        from
                            account_preference ap
                        where
                                a.acc_id = ap.acc_id
                            and ap.allow_online_renewal = 'N'
                    )
                group by
                    a.acc_id,
                    b.acc_num,
                    b.entrp_id,
                    a.ben_plan_id,
                    a.plan_start_date,
                    a.plan_end_date,
                    b.renewal_resubmit_assigned_to,
                    b.renewal_resubmit_flag
                -- having max(a.plan_end_date) BETWEEN trunc(SYSDATE-180) AND trunc(SYSDATE+90)
                having
                    max(a.plan_end_date) between trunc(sysdate - pc_web_er_renewal.g_after_days) and trunc(sysdate + pc_web_er_renewal.g_prior_days
                    )
            ) loop
                l_inv_count := 1;

         --  IF   (ADD_MONTHS(X.start_date,12)-1 < SYSDATE
         --  OR   ADD_MONTHS(X.start_date,12)-1 > SYSDATE+90)
         --  AND x.ACCOUNT_STATUS = 1

                rec.acc_id := x.acc_id;
                rec.acc_num := x.acc_num;
                rec.ben_plan_id := x.ben_plan_id;--SK Added instead of passign null value. 06/04/2021
                rec.product_type := 'COBRA';
                rec.plan_type := 'COBRA';
                rec.plan_name := 'COBRA';
                rec.renewal_resubmit_assigned_to := x.renewal_resubmit_assigned_to; -- Added by jaggi #11636
                rec.renewal_resubmit_flag := x.renewal_resubmit_flag; -- Added by jaggi #11636
             -- REC.PLAN_YEAR:=TO_CHAR(X.start_date,'mm/dd/rrrr')||'-'||TO_CHAR(ADD_MONTHS(X.start_date,12)-1,'mm/dd/rrrr');   --Commented and added below by Swamy as per shavee
             -- REC.NEW_PLAN_YEAR:=TO_CHAR(ADD_MONTHS(X.start_date,12),'mm/dd/rrrr')
             --            ||'-'||TO_CHAR(ADD_MONTHS(ADD_MONTHS(X.start_date,12),12)-1,'mm/dd/rrrr');
                rec.plan_year := to_char(x.start_date, 'mm/dd/rrrr')
                                 || '-'
                                 || to_char(x.plan_end_date, 'mm/dd/rrrr');   -- Added by swamy as  per shavee email plan year end is not coming correct in case if it is not 12 months plan year.
                rec.new_plan_year := to_char(x.plan_end_date + 1, 'mm/dd/rrrr')
                                     || '-'
                                     || to_char(
                    last_day(add_months(x.plan_end_date, 12)),
                    'mm/dd/rrrr'
                );  -- Added by swamy as  per shavee email New plan year end is not coming correct in case if it is not 12 months plan year.
                rec.ein := pc_entrp.get_tax_id(x.entrp_id);

           /* FOR K IN ( SELECT CREATION_DATE
                     FROM  BEN_PLAN_DENIALS
                    WHERE  ACC_ID= REC.ACC_ID
                    ) */ -- commented by Joshi for prod issue INC23060 and added below
                for k in (
                    select
                        creation_date
                    from
                        ben_plan_denials
                    where
                        ben_plan_id = rec.ben_plan_id
                ) loop
                    if k.creation_date is not null then
                        rec.declined := 'Y';
                        rec.declined_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end if;
                end loop;

                for k in (
                    select
                        max(creation_date) creation_date
                    from
                        ben_plan_renewals
                    where
                            acc_id = rec.acc_id
                        and ben_plan_id >= x.ben_plan_id   -- Added by Swamy for Ticket#11636
                        and x.renewal_resubmit_flag = 'N'  -- Added by Swamy for Ticket#11636
                           --AND    START_DATE BETWEEN ADD_MONTHS(X.start_date,12) AND ADD_MONTHS(ADD_MONTHS(X.start_date,12),12)-1 --Renewal phase#2
                ) loop

			 -- Start Added by Swamy for Ticket#9384
                    rec.renewed := 'N';
                    rec.renewal_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    rec.plan_end_date := x.plan_end_date;
                    if trunc(sysdate) <= trunc(x.plan_end_date + 1) then
                        rec.renewal_deadline := x.plan_end_date;
                    end if;

                    for m in (
                        select
                            flag
                        from
                            table ( pc_web_compliance.is_plan_renewed_already(x.acc_id, 'COBRA') )
                    ) loop
                        rec.is_renewed := m.flag;
                    end loop;
            -- End of Addition by Swamy for Ticket#9384

                    if k.creation_date is not null then  -- Commented by Swamy for Ticket#11636
                        rec.renewed := 'Y';
                        rec.renewal_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end if;

                end loop;

                rec.declined := nvl(rec.declined, 'N');
                rec.renewed := nvl(rec.renewed, 'N');
                if rec.acc_id is not null then
                    pipe row ( rec );
                end if;
            end loop;

        end if;

   ---- added by rprabu for 7792 on 09/07/2019
        if p_product_type = 'FORM_5500' then
 /*
	FOR X IN  (select a.ACC_ID,b.acc_num,b.entrp_id,    (a.plan_start_date) start_date
                  ,  (a.plan_end_date) plan_end_date , a.ben_plan_name
                 From ben_plan_enrollment_setup a ,ACCOUNT B
                  where a.acc_id = p_acc_id
          ---        AND   a.status = 'A'    --- Ticket 8138 17/09/2019
                 AND NVL(RENEWAL_FLAG,'N')  = 'N' ---    8030
                  AND a.acc_id = b.acc_id
			      AND rownum  = 1	--- 7992 ticket
                  AND B.account_type  in ('FORM_5500','FORM_5500_RENEW')
                 AND NOT EXISTS (SELECT 1
                                    FROM ACCOUNT_PREFERENCE AP
                                   WHERE a.ACC_ID = AP.ACC_ID
                                   AND   AP.ALLOW_ONLINE_RENEWAL = 'N')
		          AND   '20-jun-2017'  BETWEEN Trunc( (plan_end_date) +30 ) AND Trunc(add_months( (plan_end_date),7) )   -- 7792 12/08/2019 Ticket # 8141  added trunc rprabu
             --   AND   Trunc(SYSDATE)  BETWEEN Trunc( (plan_end_date) +30 ) AND Trunc(add_months( (plan_end_date),7) )   -- 7792 12/08/2019 Ticket # 8141  added trunc rprabu
                    )
                 */

			/* commented by Joshi for INC28950. 
            -- Added by Swamy for Ticket#11705 16/08/2023
            FOR J IN (SELECT MAX(plan_start_date) plan_start_date FROM BEN_PLAN_ENROLLMENT_SETUP where acc_id = p_acc_id AND status IN ('P','A')) LOOP  -- Added AND status Cond. by Swamy 05022024 #12018
                l_plan_start_date         := j.plan_start_date;
            END LOOP; 

           FOR k IN (SELECT BEN_PLAN_ID FROM BEN_PLAN_ENROLLMENT_SETUP where acc_id = p_acc_id and plan_start_date =  l_plan_start_date) LOOP
            l_max_plan_id := k.BEN_PLAN_ID;
           END LOOP; 
			*/

-- added by swamy for email_blast
            for x in (
                select
                    a.acc_id,
                    b.acc_num,
                    b.entrp_id,
                    ( a.plan_start_date ) start_date,
                    ( a.plan_end_date )   plan_end_date,
                    ben_plan_id -- added by swamy for email_blast
                    ,
                    a.ben_plan_name,
                    b.broker_id,
                    b.am_id,
                    e.entrp_email,
                    b.account_status,
                    b.end_date,
                    e.name,
                    e.entrp_code
                from
                    ben_plan_enrollment_setup a,
                    account                   b,
                    enterprise                e
                where
                        a.acc_id = p_acc_id
                    and e.entrp_id = b.entrp_id
                    and a.entrp_id = e.entrp_id
                    and a.acc_id = b.acc_id
                    and rownum = 1	--- 7992 ticket  display issue ticket#8873 rprabu 21/03/2020
                    and a.status in ( 'A', 'P' )       --- Renewal Issue 19/03/2020 Rprabu
                    and b.account_status = '1'
                    and b.end_date is null
                 -- and e.entrp_email is not null    -- Ticket 8780, Commented by Swamy for Production issue, if the mail is null, renewal page displaying blank when user clicks on renew now link. .
                    and nvl(renewal_flag, 'N') = 'N' ---    8030
                    and b.account_type in ( 'FORM_5500', 'FORM_5500_RENEW' )
                  --And Ben_Plan_Id = l_max_plan_id    -- Added by Swamy for Ticket#11705 16/08/2023  --( Select Max(Ben_Plan_Id) From Ben_Plan_Enrollment_Setup Bp  Where Acc_Id = B.Acc_Id  And Ben_Plan_Number = A.Ben_Plan_Number)  -- Ben_Plan_Number added for Renewal Issue 19/03/2020 Rprabu
                    and ben_plan_id in (
                        select
                            ben_plan_id  -- commented above and added by joshi for  INC28950. get all ben plan based on ben plan number. 
                        from
                            (
                                select
                                    ben_plan_id, row_number()
                                                 over(partition by acc_id, ben_plan_number
                                                      order by
                                                          plan_start_date desc
                                    ) as rn
                                from
                                    ben_plan_enrollment_setup
                                where
                                    acc_id = a.acc_id
                            )
                        where
                            rn = 1
                    )
                    and not exists (
                        select
                            1
                        from
                            account_preference ap
                        where
                                a.acc_id = ap.acc_id
                            and ap.allow_online_renewal = 'N'
                    )
--                  And   Trunc(Sysdate)  Between Trunc( (Plan_End_Date) +30 ) And Trunc(Add_Months( (Plan_End_Date),7) )   -- 7792 12/08/2019 Ticket # 8141  added trunc rprabu
                    and trunc(sysdate) between trunc((plan_end_date) + 30) and trunc(add_months((plan_end_date), 12)) -- Replaced 7 with 12 by jaggi for Ticket#11036
            ) loop
                l_inv_count := 1;
                rec.acc_id := x.acc_id;
                rec.acc_num := x.acc_num;
                rec.ben_plan_id := null;
                rec.product_type := 'FORM_5500';
                rec.plan_type := 'FORM_5500';
                rec.plan_name := 'FORM 5500';   ----X.BEN_PLAN_NAME;
          -- REC.PLAN_YEAR:=TO_CHAR(X.start_date,'mm/dd/rrrr')||'-'||TO_CHAR(ADD_MONTHS(X.start_date,12)-1,'mm/dd/rrrr');Uncomment
                rec.plan_year := to_char(x.start_date, 'mm/dd/rrrr')
                                 || '-'
                                 || to_char(x.plan_end_date, 'mm/dd/rrrr'); --Sk Added to send email blasts.-- added for Ticket #8955 rprabu
                rec.new_plan_year := to_char(x.plan_end_date + 1, 'mm/dd/rrrr')
                                     || '-'
                                     || to_char(
                    add_months(x.plan_end_date, 12),
                    'mm/dd/rrrr'
                );   	 -- added for Ticket #8955 rprabu
		 --- REC.NEW_PLAN_YEAR:=TO_CHAR(ADD_MONTHS(X.start_date,12),'mm/dd/rrrr')||'-'||TO_CHAR(ADD_MONTHS(ADD_MONTHS(X.start_date,12),12)-1,'mm/dd/rrrr'); commented for Ticket #8955
                rec.ein := pc_entrp.get_tax_id(x.entrp_id);
                for k in (
                    select
                        creation_date
                    from
                        ben_plan_denials
                    where
                        acc_id = rec.acc_id
                ) loop
                    if k.creation_date is not null then
                        rec.declined := 'Y';
                        rec.declined_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end if;
                end loop;

                for k in (
                    select
                        max(creation_date) creation_date
                    from
                        ben_plan_renewals
                    where
                            acc_id = rec.acc_id
                        and trunc(end_date) >= trunc(sysdate)                   ---------- to_Date( '03/01/2020','mm/dd/yyyy' )   --- 8083
                        and trunc(start_date) <= trunc(sysdate)
                        and renewed_plan_id is not null --- 7992 rprabu 20/08/2019
                ) loop

    		   -- Start Added by Swamy for Ticket#9384
                    rec.renewed := 'N';
                    for k in (
                        select
                            flag
                        from
                            table ( pc_web_compliance.is_plan_renewed_already(x.acc_id, 'FORM_5500') )
                    ) loop
                        rec.is_renewed := k.flag;
                    end loop;
               -- End of Addition by Swamy for Ticket#9384

                    if k.creation_date is not null then
                        rec.renewed := 'Y';
                        rec.renewal_date := to_char(k.creation_date, 'MM/DD/YYYY');
                    end if;

                end loop;

                rec.declined := nvl(rec.declined, 'N');
                rec.renewed := nvl(rec.renewed, 'N');
                rec.ben_plan_id := x.ben_plan_id;   -- Added by swamy for email_blast
                rec.broker_id := x.broker_id;     -- Added by swamy for email_blast
                rec.am_id := x.am_id;         -- Added by swamy for email_blast
                rec.entrp_email := x.entrp_email;   -- Added by swamy for email_blast
                rec.entrp_name := x.name;          -- Added by swamy for email_blast
                rec.tax_id := x.entrp_code;    -- Added by swamy for email_blast
                rec.plan_end_date := x.plan_end_date; -- Added by swamy for email_blast
                rec.renewal_deadline := x.plan_end_date; -- Added by Swamy for Ticket#9384

                if rec.acc_id is not null then
                    pipe row ( rec );
                end if;
            end loop;
        end if;

    end get_er_plans;

    function is_plan_renewed_already (
        p_acc_id       in number,
        p_account_type in varchar2
    ) return tbl_rnwd
        pipelined
    is
        l_ben_status varchar2(1);
        rec          rec_rnwd;
    begin
        if p_account_type in ( 'ERISA_WRAP' ) then
            for i in (
                select
                    decode(a.renewal_resubmit_flag, 'Y', 'N', 'Y') next_yr_status,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                    to_char(ee_plan.creation_date, 'mm/dd/rrrr')   creation_date,
                    ben_plan_id   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                from
                    account                   a,
                    ben_plan_enrollment_setup ee_plan
                where
                        a.acc_id = ee_plan.acc_id
                    and ee_plan.acc_id = p_acc_id
                    and ee_plan.status = 'A'
                    and ee_plan.plan_start_date > sysdate
                    and ee_plan.plan_end_date > sysdate
                    and account_type = p_account_type
                    and not exists (
                        select
                            1
                        from
                            ben_plan_denials
                        where
                            ben_plan_id = ee_plan.ben_plan_id
                    )
            ) loop
                l_ben_status := i.next_yr_status;
                rec.dated := i.creation_date;
            -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                rec.renewed_ben_plan_id := i.ben_plan_id;
                for j in (
                    select
                        renewal_batch_number
                    from
                        ben_plan_renewals
                    where
                        renewed_plan_id = i.ben_plan_id
                ) loop
                    rec.batch_number := j.renewal_batch_number;
                end loop;

            end loop;

            rec.flag := nvl(l_ben_status, 'N');
            pipe row ( rec );
        end if;

--- FORM_5500 7792 rprabu
        if p_account_type in ( 'FORM_5500' ) then /* Added FORM_5500 for ticket 7792  */
       /*  FOR I
         IN (SELECT 'Y' NEXT_YR_STATUS,
                    TO_CHAR(B.CREATION_DATE,'mm/dd/rrrr') CREATION_DATE
               FROM ACCOUNT A,BEN_PLAN_RENEWALS B , ben_plan_enrollment_Setup C
              WHERE A.ACC_ID=B.ACC_ID AND A.ACC_ID=P_ACC_ID
              AND ACCOUNT_STATUS=1
              AND b.BEN_PLAN_ID  = c.BEN_PLAN_ID
              AND C.status = 'A'
                    AND TO_CHAR (B.START_DATE, 'YYYY')>=TO_CHAR (SYSDATE, 'YYYY')-- + 1
                    + CASE WHEN TO_CHAR(B.END_DATE,'rrrr')>TO_CHAR(SYSDATE,'rrrr')THEN 0 ELSE 1 END
                    AND ACCOUNT_TYPE=P_ACCOUNT_TYPE
                    AND NOT EXISTS(SELECT 1 FROM BEN_PLAN_DENIALS WHERE ACC_ID=A.ACC_ID))
        LOOP
           L_BEN_STATUS := I.NEXT_YR_STATUS;
            REC.DATED    := I.CREATION_DATE;
        END LOOP;
		 */

            rec.flag := 'N';   ---- NVL (L_BEN_STATUS, 'N');
            pipe row ( rec );
        end if;

        if p_account_type in ( 'POP' ) then /* Added POP for ticket 5020 */
         /*FOR I
         IN (SELECT 'Y' NEXT_YR_STATUS,
                    TO_CHAR(B.CREATION_DATE,'mm/dd/rrrr')CREATION_DATE
               FROM ACCOUNT A,BEN_PLAN_RENEWALS B
              WHERE A.ACC_ID=B.ACC_ID AND A.ACC_ID=P_ACC_ID
              AND ACCOUNT_STATUS=1
                    AND TO_CHAR (B.START_DATE, 'YYYY')>=TO_CHAR (SYSDATE, 'YYYY')-- + 1
                    + CASE WHEN TO_CHAR(B.END_DATE,'rrrr')>TO_CHAR(SYSDATE,'rrrr')THEN 0 ELSE 1 END
                    AND ACCOUNT_TYPE=P_ACCOUNT_TYPE
                    AND NOT EXISTS(SELECT 1 FROM BEN_PLAN_DENIALS WHERE ACC_ID=A.ACC_ID))*/
		 -- Commented the above code and added the below code by Swamy for Ticket#8504,similar to code written for Erisa_wrap.
            for i in (
                select
                    decode(a.renewal_resubmit_flag, 'Y', 'N', 'Y') next_yr_status,    -- 10431 swamy 'Y' NEXT_YR_STATUS,
                    to_char(ee_plan.creation_date, 'mm/dd/rrrr')   creation_date,
                    ben_plan_id  -- 10431 swamy
                from
                    account                   a,
                    ben_plan_enrollment_setup ee_plan
                where
                        a.acc_id = ee_plan.acc_id
                    and ee_plan.acc_id = p_acc_id
                    and ee_plan.status = 'A'
                    and ee_plan.plan_start_date > sysdate
                    and ee_plan.plan_end_date > sysdate
                    and account_type = p_account_type
                    and not exists (
                        select
                            1
                        from
                            ben_plan_denials
                        where
                            ben_plan_id = ee_plan.ben_plan_id
                    )
            ) loop
                l_ben_status := i.next_yr_status;
                rec.dated := i.creation_date;
                rec.renewed_ben_plan_id := i.ben_plan_id; -- 10431 swamy
                for j in (
                    select
                        renewal_batch_number
                    from
                        ben_plan_renewals
                    where
                        renewed_plan_id = i.ben_plan_id
                ) loop
                    rec.batch_number := j.renewal_batch_number;
                end loop;

            end loop;

            rec.flag := nvl(l_ben_status, 'N');
            pipe row ( rec );
        end if;

        if p_account_type = 'COBRA' then
         /*FOR I
         IN (SELECT 'Y' NEXT_YR_STATUS,
                    TO_CHAR(B.CREATION_DATE,'mm/dd/rrrr')CREATION_DATE
               FROM ACCOUNT A,BEN_PLAN_RENEWALS B
              WHERE A.ACC_ID=B.ACC_ID AND A.ACC_ID=P_ACC_ID
              AND ACCOUNT_STATUS=1
                    AND TO_CHAR (B.START_DATE, 'YYYY')>=TO_CHAR (SYSDATE, 'YYYY')-- + 1
                    + CASE WHEN TO_CHAR(B.END_DATE,'rrrr')>TO_CHAR(SYSDATE,'rrrr')THEN 0 ELSE 1 END
                    AND ACCOUNT_TYPE=P_ACCOUNT_TYPE
--AND EE_PLAN.PLAN_TYPE=P_PLAN_TYPE AND PLAN_TYPE NOT IN('TRN','PKG','UA1')
                    AND NOT EXISTS(SELECT 1 FROM BEN_PLAN_DENIALS WHERE ACC_ID=A.ACC_ID))*/
		 -- Commented the above code and added the below code by Swamy for Ticket#8504,similar to code written for Erisa_wrap.
            for i in (
                select
                    decode(a.renewal_resubmit_flag, 'Y', 'N', 'Y') next_yr_status, --'Y' NEXT_YR_STATUS, -- Added by Swamy for Ticket#11636
                    to_char(ee_plan.creation_date, 'mm/dd/rrrr')   creation_date
                from
                    account                   a,
                    ben_plan_enrollment_setup ee_plan
                where
                        a.acc_id = ee_plan.acc_id
                    and ee_plan.acc_id = p_acc_id
                    and ee_plan.status = 'A'
                    and ee_plan.plan_start_date > sysdate
                    and ee_plan.plan_end_date > sysdate
                    and account_type = p_account_type
                    and not exists (
                        select
                            1
                        from
                            ben_plan_denials
                        where
                            ben_plan_id = ee_plan.ben_plan_id
                    )
            ) loop
                l_ben_status := i.next_yr_status;
                rec.dated := i.creation_date;
            end loop;

            rec.flag := nvl(l_ben_status, 'N');
            pipe row ( rec );
        end if;

    exception
        when others then
            null;
    end is_plan_renewed_already;

    function emp_plan_renewal_disp_cobra (
        p_acc_id in number
    ) return varchar2 is

        l_inv_count       number := 0;
        l_deny_count      number := 0;
        l_appr_count      number := 0;
        l_renew           varchar2(1) := 'N';
        l_max_plan_id     number := 0;
        l_plan_start_date date;
    begin

       -- We check when this group was invoiced
       -- if invoiced we will take the same for renewal
      /*FOR X IN (  select ACC_ID,MAX(a.plan_start_date) start_date,  MAX(a.Plan_end_date) end_date
                  from ben_plan_enrollment_setup a
                  where acc_id = p_acc_id
                  and   status = 'A'
                  and plan_type in ('COBRA','COBRA_RENEW')
                  GROUP BY A.ACC_ID
                  --having max(a.plan_end_date) BETWEEN trunc(SYSDATE-180) AND trunc(SYSDATE+90) )
                  having max(a.plan_end_date) BETWEEN trunc(SYSDATE-PC_WEB_ER_RENEWAL.G_AFTER_DAYS) AND trunc(SYSDATE+PC_WEB_ER_RENEWAL.G_PRIOR_DAYS)) -- #7522 Joshi
      LOOP*/

         -- Added by Swamy for Ticket#11636 
        for j in (
            select
                max(plan_start_date) plan_start_date
            from
                ben_plan_enrollment_setup
            where
                acc_id = p_acc_id
        ) loop
            l_plan_start_date := j.plan_start_date;
        end loop;

        for k in (
            select
                ben_plan_id
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and plan_start_date = l_plan_start_date
        ) loop
            l_max_plan_id := k.ben_plan_id;
        end loop;

        for x in (
            select
                a.acc_id,
                max(a.plan_start_date) start_date,
                max(a.plan_end_date)   end_date
            from
                ben_plan_enrollment_setup a,
                account                   b
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.status = 'A'
                and ( ( nvl(b.renewal_resubmit_flag, 'N') = 'Y'
                        and a.ben_plan_id < l_max_plan_id )
                      or nvl(b.renewal_resubmit_flag, 'N') = 'N' )   -- Added by Swamy for Ticket#11636
                and a.plan_type in ( 'COBRA', 'COBRA_RENEW', 'RENEW' )
            group by
                a.acc_id
            having
                max(a.plan_end_date) between trunc(sysdate - pc_web_er_renewal.g_after_days) and trunc(sysdate + pc_web_er_renewal.g_prior_days
                )
        ) -- #7522 Joshi
         loop
            l_inv_count := 1;
            select
                count(*)
            into l_deny_count
            from
                ben_plan_denials
            where
                acc_id = x.acc_id;

            if l_deny_count > 0 then
                return 'N';
            end if;
            if l_deny_count = 0 then
                select
                    flag
                into l_renew
                from
                    table ( pc_web_compliance.is_plan_renewed_already(p_acc_id, 'COBRA') );
              /*  FOR K IN ( SELECT COUNT(*) CNT
                       FROM  BEN_PLAN_RENEWALS
                      WHERE  ACC_ID= p_acc_id
                      --AND    CREATION_DATE BETWEEN X.start_date AND ADD_MONTHS(X.start_date,12)-1
                      --Modified for Back button issue.
                      AND    CREATION_DATE BETWEEN X.start_date AND SYSDATE
            )
               LOOP
                 IF K.CNT > 0 THEN
                   RETURN 'N';
                END IF;
               END LOOP;
               RETURN 'Y';*/
                if l_renew = 'N' then
                    return 'Y';
                else
                    return 'N';
                end if;
            end if;

        end loop;
       -- if never invoiced then we will go by creation date

        return nvl(l_renew, 'N');
    exception
        when others then
           -- RAISE;
            return 'N';
    end emp_plan_renewal_disp_cobra;

    function emp_plan_renewal_disp_erisa (
        p_acc_id in number
    ) return varchar2 is

        l_count                 number := 0;
        l_entrp_id              number;
        l_ben_plan_id           number;
        l_entrp_code            varchar2(20);
        is_renewed              varchar2(1);
        is_declined             varchar2(1) := 'N';
        l_plan_start_date       date; -- Added by Swamy for Ticket#11533
        l_prev_plan_start_date  date; -- Added by Swamy for Ticket#11533
        l_renewal_resubmit_flag varchar2(1);
        l_max_plan_id           number;
        l_deny_count            number := 0;  -- Added by Swamy for Ticket#11533
    begin

           -- Added by Swamy for Ticket#11533(Renewal for Broker and GA for Erisa)  
        for j in (
            select
                renewal_resubmit_flag
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_renewal_resubmit_flag := j.renewal_resubmit_flag;
        end loop;

        for k in (
            select
                max(ben_plan_id) ben_plan_id
            from
                ben_plan_enrollment_setup
            where
                acc_id = p_acc_id
        ) loop
            l_max_plan_id := k.ben_plan_id;
        end loop;

        if l_renewal_resubmit_flag = 'Y' then
            for m in (
                select
                    max(ben_plan_id) ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and ben_plan_id <> l_max_plan_id
            ) loop
                l_max_plan_id := m.ben_plan_id;
            end loop;
        end if;
             --

        select
            count(*)
        into l_count
        from
            enterprise                a,
            account                   b,
            plan_codes                c,
            ben_plan_enrollment_setup d
        where
                a.entrp_id = b.entrp_id
            and b.plan_code = c.plan_code
            and b.acc_id = d.acc_id (+)
            and account_status = 1
            and account_type = 'ERISA_WRAP'
            and ben_plan_id = l_max_plan_id -- Added by Swamy for Ticket#11533
                --AND TRUNC(PLAN_END_DATE)  BETWEEN TRUNC(SYSDATE)-180  AND TRUNC(SYSDATE)+90
            and trunc(plan_end_date) between trunc(sysdate - pc_web_er_renewal.g_after_days) and trunc(sysdate + pc_web_er_renewal.g_prior_days
            )
            and b.acc_id = p_acc_id
            and plan_start_date < sysdate;

        if nvl(l_count, 0) = 0 then
            return 'N';
        else
            select
                count(*)
            into l_deny_count
            from
                ben_plan_denials
            where
                acc_id = p_acc_id;   -- Added by Swamy for Ticket#11533
            if l_deny_count > 0 then
                return 'N';
            else
                select
                    flag
                into is_renewed
                from
                    table ( pc_web_compliance.is_plan_renewed_already(p_acc_id, 'ERISA_WRAP') );

            end if;

        end if;

        if
            is_renewed = 'N'
            and is_declined = 'N'
        then
            return 'Y';
        else
            return 'N';
        end if;

    exception
        when others then
            return 'N';
    end emp_plan_renewal_disp_erisa;
     /*Ticket#5020.POP renewal */
/*   FUNCTION EMP_PLAN_RENEWAL_DISP_POP(P_ACC_ID IN NUMBER,P_PLAN_TYPE IN VARCHAR2)RETURN VARCHAR2
   IS
         L_COUNT  NUMBER := 0;
         L_ENTRP_ID NUMBER;L_BEN_PLAN_ID NUMBER;
         L_ENTRP_CODE VARCHAR2(20);IS_RENEWED VARCHAR2(1);IS_DECLINED VARCHAR2(1):='N';
         l_deny_count  NUMBER;
   BEGIN
    pc_log.log_error('PC_EMPLOYER_ENROLL.EMP_PLAN_RENEWAL_DISP_POP','P_ACC_ID :='||P_ACC_ID||' P_PLAN_TYPE :='||P_PLAN_TYPE);
       SELECT COUNT(*) INTO L_COUNT
               FROM ENTERPRISE A,
                    ACCOUNT B,
                    PLAN_CODES C,
                    BEN_PLAN_ENROLLMENT_SETUP D
         WHERE A.ENTRP_ID = B.ENTRP_ID
                AND B.PLAN_CODE = C.PLAN_CODE
                AND B.ACC_ID = D.ACC_ID(+)
                AND ACCOUNT_STATUS  = 1
                AND ACCOUNT_TYPE = 'POP'
                --AND D.PLAN_TYPE = P_PLAN_TYPE  --- 7794 commented for the Ticket#7794 rprabhu 07/04/2020
                --AND TRUNC(PLAN_END_DATE)  BETWEEN TRUNC(SYSDATE)-100  AND TRUNC(SYSDATE)+90
                -- AND TRUNC(PLAN_END_DATE)  BETWEEN TRUNC(SYSDATE)-180  AND TRUNC(SYSDATE)+90
				 AND TRUNC(PLAN_END_DATE)  BETWEEN TRUNC(SYSDATE)- PC_WEB_ER_RENEWAL.G_AFTER_DAYS  AND TRUNC(SYSDATE)+PC_WEB_ER_RENEWAL.G_PRIOR_DAYS -- Joshi #7762
                 AND B.ACC_ID = P_ACC_ID AND PLAN_START_DATE < SYSDATE;

         IF NVL(L_COUNT,0) = 0 THEN
             RETURN 'N';
         ELSE
             SELECT COUNT(*)
             INTO l_deny_count
             FROM BEN_PLAN_DENIALS WHERE ACC_ID = P_ACC_ID;
             IF l_deny_count > 0 THEN
                  RETURN 'N';
              END IF;
              IF l_deny_count =0 THEN
                 SELECT FLAG INTO IS_RENEWED  FROM TABLE(PC_WEB_COMPLIANCE.IS_PLAN_RENEWED_ALREADY(P_ACC_ID,'POP'));
              END IF;
         END IF;

         IF IS_RENEWED='N' AND  IS_DECLINED='N' tHEN
            RETURN 'Y';
         ELSE
            RETURN 'N';
         END IF;
    EXCEPTION
       WHEN OTHERS THEN
            RETURN 'N';

   END EMP_PLAN_RENEWAL_DISP_POP;
*/

 -- Commented above and added below by Swamy for Ticket#8686 on 14/08/2020
    function emp_plan_renewal_disp_pop (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return varchar2 is

        l_ben_plan_id           number := 0;
        l_deny_count            number := 0;
        l_plan_type             ben_plan_enrollment_setup.plan_type%type;
        l_renewal_resubmit_flag varchar2(1);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.EMP_PLAN_RENEWAL_DISP_POP', 'P_ACC_ID :='
                                                                         || p_acc_id
                                                                         || ' P_PLAN_TYPE :='
                                                                         || p_plan_type);
      -- For a particular account get all the ben plan which is about to renew with 60/90 days policy
        for i in (
            select
                max(ben_plan_id)                     ben_plan_id,
                max(nvl(renewal_resubmit_flag, 'N')) renewal_resubmit_flag   -- 10431 swamy
            from
                account                   b,
                ben_plan_enrollment_setup d
            where
                    b.acc_id = d.acc_id (+)
                and b.account_status = 1
                and b.account_type = 'POP'
                and d.status = 'A'
                and trunc(d.plan_end_date) between trunc(sysdate) - pc_web_er_renewal.g_after_days and trunc(sysdate) + pc_web_er_renewal.g_prior_days
                and b.acc_id = p_acc_id
                and d.plan_start_date < sysdate
        ) loop
            l_ben_plan_id := i.ben_plan_id;
            l_renewal_resubmit_flag := i.renewal_resubmit_flag; -- 10431 swamy
        end loop;
         -- No plan exixts for renewal
        if nvl(l_ben_plan_id, 0) = 0 then
            return 'N';
        else
             -- Check if the record is denied.
            for p in (
                select
                    count(*) cnt
                from
                    ben_plan_denials
                where
                    acc_id = p_acc_id
            ) loop
                l_deny_count := p.cnt;
            end loop;

            if l_deny_count > 0 then
                return 'N';
            end if;

            -- Check if the plan is already renewed through Online
            for k in (
                select
                    1
                from
                    ben_plan_renewals r
                where
                        r.ben_plan_id = l_ben_plan_id
                    and acc_id = p_acc_id
                    and l_renewal_resubmit_flag = 'N'
            ) loop   -- 10431 swamy
                return 'N';
            end loop;

            -- Get the Plan type of the plan
            for n in (
                select
                    plan_type
                from
                    ben_plan_enrollment_setup
                where
                        ben_plan_id = l_ben_plan_id
                    and acc_id = p_acc_id
            ) loop
                l_plan_type := n.plan_type;
            end loop;

			-- Check if the plan is renewed through SAM apex, bcos renewal through sam will not insert the renewed record in ben_plan_renewals.
            -- If renewed already then ben_plan_id will be greater than the current ben_plan_id to be renewed.
			/* commented by Joshi for 12563
            FOR m IN (SELECT ben_plan_id 
                                FROM BEN_PLAN_ENROLLMENT_SETUP 
                                WHERE plan_type = l_plan_type
                                   AND ben_plan_id > L_ben_plan_id
                                   AND acc_id = P_ACC_ID 
                                   AND status = 'A'
                                   AND l_renewal_resubmit_flag = 'N')
            LOOP -- 10431 swamy
			   RETURN 'N';
			END LOOP;
            */

            for m in (
                select
                    bo.ben_plan_id
                from
                    ben_plan_enrollment_setup bo
                where
                        plan_type = l_plan_type
                    and acc_id = p_acc_id
                    and status = 'A'
                    and l_renewal_resubmit_flag = 'N'
                    and plan_start_date > (
                        select
                            plan_start_date
                        from
                            ben_plan_enrollment_setup bi
                        where
                                bi.acc_id = bo.acc_id
                            and bi.plan_type = bo.plan_type
                            and ben_plan_id = l_ben_plan_id
                    )
            ) loop -- 10431 swamy
                return 'N';
            end loop;

        end if;

      -- If the plan not renewed through online or through sam, then show the renewal link
        if
            nvl(l_ben_plan_id, 0) > 0
            and l_deny_count = 0
        then
            return 'Y';
        end if;

    exception
        when others then
            return 'N';
    end emp_plan_renewal_disp_pop;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

     /*Ticket# 7792 rprabu 09/07/2019 */
    function emp_plan_renwl_disp_form_5500 (
        p_acc_id in number
    ) return varchar2 is

        l_count         varchar2(3000);
        l_entrp_id      number;
        l_ben_plan_id   number;
        l_entrp_code    varchar2(20);
        is_renewed      varchar2(1);
        x_return_status varchar2(300);
        x_error_message varchar2(300);
        l_deny_count    number;
        l_renewal_count number(5) := 0; -- 8030 rprabu14/08/2019
        rec             rec_rnwl;
    begin
        l_renewal_count := 0;
        is_renewed := 'N';
        select
            count(ben_plan_id)
        into l_renewal_count
        from
            enterprise                a,
            account                   b,
            plan_codes                c,
            ben_plan_enrollment_setup d
        where
                a.entrp_id = b.entrp_id
            and b.plan_code = c.plan_code
            and b.acc_id = d.acc_id (+)
            and account_status = 1
            ---    AND D.STATUS = 'A'
            and d.status in ( 'A', 'P' ) -- Added by Joshi for ticket INC14379(12472)
            and account_type = 'FORM_5500'
            and b.acc_id = p_acc_id
            and trunc(sysdate) between trunc(plan_end_date + 30) and trunc(add_months(plan_end_date, 12))   -- Replaced 7 with 12 by jaggi for Ticket#11036
            and nvl(renewal_flag, 'N') = 'N'
            and d.acc_id = p_acc_id
            and not exists (
                select
                    1
                from
                    account_preference ap
                where
                        b.acc_id = ap.acc_id
                    and ap.allow_online_renewal = 'N'
            )  -- Added by Swamy for Ticket#8639 on 03/02/2020
                 -- Added by Joshi for Ticket#11036
            and not exists (
                select
                    1
                from
                    plan_notices
                where
                        entrp_id = a.entrp_id
                    and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                    and entity_id = d.ben_plan_id
                    and notice_type = 'FINAL_REPORT'
            );

        if l_renewal_count > 0 then
            is_renewed := 'Y';
        end if;
        select
            count(*)
        into l_deny_count
        from
            ben_plan_denials
        where
            acc_id = p_acc_id;

        if l_deny_count > 0 then
            return 'N';
        end if;
        if is_renewed = 'Y' then
            return 'Y';
        else
            return 'N';
        end if;
    exception
        when others then
            x_return_status := 'E';
            x_error_message := 'Error in Exporting FT Williams file ' || sqlerrm;
    end emp_plan_renwl_disp_form_5500;
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------

    procedure upload_ft_williams (
        p_file_name     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) as

        l_file         utl_file.file_type;
        l_buffer       raw(32767);
        l_amount       binary_integer := 32767;
        l_pos          integer := 1;
        l_blob         blob;
        l_blob_len     integer;
        exc_no_file exception;
        l_create_ddl   varchar2(32000);
        lv_dest_file   varchar2(300);
        l_sqlerrm      varchar2(32000);
        l_create_error exception;
        l_batch_number number;
        l_valid_plan   number(10);
        l_acc_id       number(10);
        x_batch_number number;
    begin
        x_return_status := 'S';
        lv_dest_file := substr(p_file_name,
                               instr(p_file_name, '/', 1) + 1,
                               length(p_file_name) - instr(p_file_name, '/', 1));

        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = p_file_name;

            l_file := utl_file.fopen('ERISA_UPLOAD_DIR', p_file_name, 'w');--, 32767);
            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length

            -- Open / Creates the destination file.
            -- Read chunks of the BLOB and write them to the file
            -- until complete.
            while l_pos < l_blob_len loop
                dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
                utl_file.put_raw(l_file, l_buffer, true);
                l_pos := l_pos + l_amount;
            end loop;
            -- Close the file.
            utl_file.fclose(l_file);

            -- Delete file from wwv_flow_files
            delete from wwv_flow_files
            where
                name = p_file_name;

        exception
            when others then
                null;
        end;

        begin
            execute immediate 'ALTER TABLE ERISA_FILE_UPLOAD location (ERISA_UPLOAD_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                x_error_message := 'Error in Changing location of file' || sqlerrm;
                raise l_create_error;
        end;

        upload_ft_williams_staging(p_user_id, x_batch_number, x_error_message, x_return_status);
        if x_return_status <> 'S' then
            raise l_create_error;
        end if;
    exception
        when l_create_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := 'Error in Exporting FT Williams file ' || sqlerrm;
    end upload_ft_williams;

    procedure upload_ft_williams_staging (
        p_user_id       in number,
        x_batch_number  out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        x_batch_number := erisa_file_upload_seq.nextval;
        insert into erisa_file_upload_staging (
            batch_num,
            created_date,
            created_by,
            last_updated_date,
            last_updated_by,
            ftwcustomerid,
            ftwplanid,
            plantype,
            checklist,
            checklistversion,
            respforplan,
            companyname,
            companyemployerid,
            entitytype,
            customerid,
            planid,
            plannumber,
            planline1,
            planline2,
            origeffectdate,
            amendrestate,
            effectivedate,
            planyearend,
            planyearendshort,
            planyearendshortbegin,
            planyearendshortend,
            spddate,
            filenumber,
            udf1,
            udf2,
            udf3,
            udf4,
            udf5,
            subsidiarycontracts,
            subsidiarycontractslisted,
            excludeother,
            excludeothertext,
            planadmin,
            planadminformat,
            indemnifyadmin,
            indemnifycustom,
            customeffdate,
            customlanguage,
            participantidmethod,
            claimsspd,
            plansubjectcobraspd,
            cobracontact,
            cobrasubmitpartyname,
            cobrasubmitpartyaddress,
            cobrasubmitpartyphone,
            cobranotifydatespd,
            plansubjecthippaspd,
            plansubjectfmlaspd,
            plansubjecthippaportspd,
            newbornlangspd,
            whcralangspd,
            grandfather,
            subsidiarycontractsspd,
            subsidiarycontractsspdtext,
            eligspd,
            eligspdtext,
            contribspd,
            contribspdtext,
            schedulecontractone,
            scheduleeligone,
            schedulecontracttwo,
            scheduleeligtwo,
            schedulecontractthree,
            scheduleeligthree,
            schedulecontractfour,
            scheduleeligfour,
            schedulecontractfive,
            scheduleeligfive,
            schedulecontractsix,
            scheduleeligsix,
            schedulecontractseven,
            scheduleeligseven,
            schedulecontracteight,
            scheduleeligeight,
            schedulecontractnine,
            scheduleelignine,
            schedulecontractten,
            scheduleeligten,
            joinderlist,
            customlanguagespd
        )
            select
                x_batch_number,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                ftwcustomerid,
                ftwplanid,
                plantype,
                checklist,
                checklistversion,
                respforplan,
                companyname,
                companyemployerid,
                entitytype,
                customerid,
                planid,
                plannumber,
                planline1,
                planline2,
                origeffectdate,
                amendrestate,
                effectivedate,
                planyearend,
                planyearendshort,
                planyearendshortbegin,
                planyearendshortend,
                spddate,
                filenumber,
                udf1,
                udf2,
                udf3,
                udf4,
                udf5,
                subsidiarycontracts,
                subsidiarycontractslisted,
                excludeother,
                excludeothertext,
                planadmin,
                planadminformat,
                indemnifyadmin,
                indemnifycustom,
                customeffdate,
                customlanguage,
                participantidmethod,
                claimsspd,
                plansubjectcobraspd,
                cobracontact,
                cobrasubmitpartyname,
                cobrasubmitpartyaddress,
                cobrasubmitpartyphone,
                cobranotifydatespd,
                plansubjecthippaspd,
                plansubjectfmlaspd,
                plansubjecthippaportspd,
                newbornlangspd,
                whcralangspd,
                grandfather,
                subsidiarycontractsspd,
                subsidiarycontractsspdtext,
                eligspd,
                eligspdtext,
                contribspd,
                contribspdtext,
                schedulecontractone,
                scheduleeligone,
                schedulecontracttwo,
                scheduleeligtwo,
                schedulecontractthree,
                scheduleeligthree,
                schedulecontractfour,
                scheduleeligfour,
                schedulecontractfive,
                scheduleeligfive,
                schedulecontractsix,
                scheduleeligsix,
                schedulecontractseven,
                scheduleeligseven,
                schedulecontracteight,
                scheduleeligeight,
                schedulecontractnine,
                scheduleelignine,
                schedulecontractten,
                scheduleeligten,
                joinderlist,
                customlanguagespd
            from
                erisa_file_upload
            where
                ftwcustomerid is not null;

        x_error_message := null;
        x_return_status := 'S';
    exception
        when others then
            x_error_message := 'Error in Uploading to Staging Bank Card Transactions ' || sqlerrm;
            x_return_status := 'E';
    end upload_ft_williams_staging;
    -- NOT USED
    procedure send_invoice (
        p_entrp_id      number,
        p_email         varchar2,
        p_flag          varchar2,
        p_user_id       number,
        p_ben_plan_id   in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        cnt            number;
        l_account_type varchar2(30);
        l_acc_id       number;
    begin
        null;
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
    end send_invoice;

    function get_cobra_ee_notify (
        p_acc_id number
    ) return varchar2 is
        l_subject varchar2(1000);
    begin
        select
            amount
            || ' RECEIVED ON '
            || to_char(fee_date, 'MM/DD/RRRR')
        into l_subject
        from
            income
        where
                acc_id = p_acc_id
            and fee_date = (
                select
                    max(fee_date)
                from
                    income
                where
                    acc_id = p_acc_id
            );

        return l_subject;
    end;

    function is_plan_declined_cobra (
        p_acc_id in number
    ) return tbl_rnwd
        pipelined
    is
        rec rec_rnwd;
    begin
        for i in (
            select
                'Y'                                  flg,
                to_char(creation_date, 'mm/dd/rrrr') creation_date
            from
                ben_plan_denials
            where --BEN_PLAN_ID = P_ER_BEN_PLAN_ID
                  --AND
                acc_id = p_acc_id
        )
                 -- AND ACCEPT_FLAG = 'N')
         loop
            rec.flag := i.flg;
            rec.dated := i.creation_date;
        end loop;

        rec.flag := nvl(rec.flag, 'N');
        pipe row ( rec );
    end;

    function check_email (
        p_email varchar2
    ) return number is
        cnt number;
    begin
        select
            count(*)
        into cnt
        from
            contact_leads
        where
            lower(email) = lower(p_email);

        if cnt = 0 then
            select
                count(*)
            into cnt
            from
                contact
            where
                lower(email) = lower(p_email);

        end if;

        if cnt > 0 then
            return 1;
        else
            return 0;
        end if;
    end;

    procedure update_er_account_cobra (
        p_acc_id                number,
        p_new_plan_year         varchar2,
        p_user_id               number,
        p_pay_acct_fees         varchar2,   --Renewal Phase#2  from 8471 Jagadeesh
        p_optional_fee_paid_by  varchar2,   --  added by jaggi #11262.
        p_no_of_eligible        number,
        p_authorize_req_id      number,
        p_policy_number         pc_online_enrollment.varchar2_tbl,
        p_plan_number           pc_online_enrollment.varchar2_tbl,
        p_carrier_name          pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_name  pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_email pc_online_enrollment.varchar2_tbl,
        p_carrier_phone_no      pc_online_enrollment.varchar2_tbl,
        p_authorize_option      pc_online_enrollment.varchar2_tbl,
        p_is_authorized         pc_online_enrollment.varchar2_tbl,
        p_nav_code              pc_online_enrollment.varchar2_tbl,
        p_staging_batch_number  in number,     -- Added by swamy for Ticket#11364
        p_source                in varchar2,  -- Added by swamy for Ticket#11364
        x_batch_number          out number,
        x_renewed_plan_id       out number,    -- Added by swamy for Ticket#11364
        x_return_status         out varchar2,
        x_error_message         out varchar2
    ) is

        l_entrp_id        number;
        cnt               number;
        l_start_date      date;
        l_end_date        date;
        l_flag            varchar2(1) := 'N';
        row_set           ben_plan_enrollment_setup%rowtype;
        l_renewed_plan_id number; --Renewal phase#2
        l_ben_plan_id     number;
        l_plan_name       varchar2(100);--Ticket#4408(Ben Plan name populated)
        l_return_status   varchar2(1);
        l_error_message   varchar2(32000);
        l_broker_id       number;
        v_resubmit_flag   varchar2(1); -- Added by Swamy for Ticket#11636

    begin
        x_return_status := 'S';
        pc_log.log_error('UPDATE_ER_ACCOUNT_COBRA', 'PHP called this proc');
        select
            entrp_id
        into l_entrp_id
        from
            account
        where
            acc_id = p_acc_id;  -- Moved from down to top Added by Swamy for Ticket#11636

        v_resubmit_flag := pc_account.get_renewal_resubmit_flag(l_entrp_id);  -- Added by Swamy for Ticket#11636
    -- 
        if nvl(v_resubmit_flag, 'N') = 'N' then   -- IF cond.Added by Swamy for Ticket#11636  
          --Now that for COBRA we have entries in plan Setup table.Hence we need
          --not go to ar_invoice table.Renewal Phase#2
            for x in (
                select
                    max(a.plan_start_date) start_date,
                    max(a.plan_end_date)   end_date
                from
                    ben_plan_enrollment_setup a
                where
                        acc_id = p_acc_id
                    and status = 'A'
                    and plan_type in ( 'COBRA', 'COBRA_RENEW' )
                group by
                    a.acc_id
              -- having max(a.plan_end_date) BETWEEN trunc(SYSDATE-180) AND trunc(SYSDATE+90)      )
              -- #7957 logic changes as per renewal logic link Joshi
                having
                    max(a.plan_end_date) between trunc(sysdate - pc_web_er_renewal.g_after_days) and trunc(sysdate + pc_web_er_renewal.g_prior_days
                    )
            ) --
             loop
                l_start_date := to_date ( x.end_date, 'dd/mm/RRRR' ) + 1;
                l_end_date := add_months(l_start_date, 12) - 1;

              --Fetch original ben plan ID to populate Ben plan renewals table #Added 02/08#Ticket#4408 For Loop added for Ticket#9729
                for j in (
                    select
                        ben_plan_id,
                        ben_plan_name
                    from
                        ben_plan_enrollment_setup a
                    where
                            acc_id = p_acc_id
                        and status = 'A'
                        and plan_type in ( 'COBRA', 'COBRA_RENEW' )
                        and plan_start_date = x.start_date
                        and plan_end_date = x.end_date
                    order by
                        ben_plan_id
                ) loop
                --#Added 02/08
                    l_ben_plan_id := j.ben_plan_id;
                    l_plan_name := j.ben_plan_name;
                    pc_log.log_error('UPDATE_ER_ACCOUNT_COBRA', 'BEN PLAN ID...'
                                                                || l_ben_plan_id
                                                                || ' l_plan_name :='
                                                                || l_plan_name);
                end loop;

            end loop;

            pc_log.log_error('UPDATE_ER_ACCOUNT_COBRA', 'L_START_DATE' || l_start_date);
            pc_log.log_error('UPDATE_ER_ACCOUNT_COBRA', 'L_END_DATE' || l_end_date);

            --X_BATCH_NUMBER := BATCH_NUM_SEQ.NEXTVAL;   -- Commented by swamy for Ticket#11364

            --SELECT ENTRP_ID INTO L_ENTRP_ID FROM ACCOUNT WHERE ACC_ID = P_ACC_ID;

             --Renewal Phase#2.We need to create entry in Ben_plan_setup table for COBRA too
            insert into ben_plan_enrollment_setup (
                ben_plan_id,
                acc_id,
                ben_plan_name,
                plan_start_date,
                plan_end_date,
                plan_type,
                renewal_date,
                renewal_flag,
                effective_date,
                status,
                entrp_id  /*PROD issue raise that entrp id was null fro plan records Ticket#6312*/,
                creation_date,
                created_by
            ) values ( ben_plan_seq.nextval,
                       p_acc_id
                      --,'COBRA'
                       ,
                       l_plan_name --#Ticket#4408
                       ,
                       l_start_date,
                       l_end_date,
                       'COBRA_RENEW',
                       sysdate,
                       'Y',
                       l_start_date,
                       'A',
                       l_entrp_id  /*PROD issue raise that entrp id was null fro plan records */,
                       sysdate,
                       p_user_id ) returning ben_plan_id into l_renewed_plan_id;
              --Renewal Phase#2--End

             --Added BEN PLAN ID Ticket#4408
            insert into ben_plan_renewals (
                ben_plan_id,
                acc_id,
                plan_type,
                start_date,
                end_date,
                pay_acct_fees,--Renewal Phase#2
                optional_fee_paid_by, -- #11262
                created_by,
                creation_date,
                renewal_batch_number,
                renewed_plan_id,
                source
            )--Renewal Phase#2.Populate renewed plan ID
             values ( l_ben_plan_id,
                       p_acc_id,
                       'COBRA',
                       l_start_date,
                       l_end_date,
                       p_pay_acct_fees,
                       p_optional_fee_paid_by, -- #11262
                       p_user_id,
                       sysdate,
                       l_ben_plan_id  -- changed from X_BATCH_NUMBER to L_BEN_PLAN_ID by swamy for Ticket#11364
                       ,
                       l_renewed_plan_id,
                       'ONLINE' );

            pc_log.log_error('UPDATE_ER_ACCOUNT_COBRA', 'Before Setup Table' || l_end_date);
        else  -- Added by Swamy for Ticket#11636
            for k in (
                select
                    renewed_plan_id
                from
                    online_compliance_staging
                where
                        entrp_id = l_entrp_id
                    and batch_number = p_staging_batch_number
                    and source = 'RENEWAL'
            ) loop
                l_renewed_plan_id := k.renewed_plan_id;
            end loop;
        end if; -- Added by Swamy for Ticket#11636

        if nvl(p_no_of_eligible, 0) <> 0 then
            insert into enterprise_census (
                entity_id,
                entity_type,
                census_code,
                census_numbers,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                ben_plan_id
            ) values ( l_entrp_id,
                       'ENTERPRISE',
                       'NO_OF_ELIGIBLE',
                       p_no_of_eligible,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       l_renewed_plan_id   -- Added by Swamy for Ticket#11636
                        );
                 -- Jagadeesh
            update enterprise
            set
                no_of_eligible = p_no_of_eligible
            where
                entrp_id = l_entrp_id;

        end if;

        if p_source <> 'RENEWAL' then
           --8471 Jagadeesh
            for i in p_carrier_name.first..p_carrier_name.last loop
                insert into carrier_notification (
                    entrp_id,
                    entity_id,
                    entity_type,
                    plan_number,
                    policy_number,
                    cariier_name,
                    carrier_contact_name,
                    carrier_contact_email,
                    carrier_phone_no,
                    carrier_addr,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( l_entrp_id,
                           l_renewed_plan_id,
                           'BEN_PLAN_ENROLLMENT_SETUP',
                           p_plan_number(i),
                           p_policy_number(i),
                           p_carrier_name(i),
                           p_carrier_contact_name(i),
                           p_carrier_contact_email(i),
                           p_carrier_phone_no(i),
                           null,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id );

            end loop;
        else
          -- added by swamy for Ticket#11364
            for i in (
                select
                    *
                from
                    carrier_notification_staging
                where
                        entrp_id = l_entrp_id
                    and batch_number = p_staging_batch_number
                    and entity_type = 'BEN_PLAN_RENEWAL'
            ) loop
                insert into carrier_notification (
                    entrp_id,
                    entity_id,
                    entity_type,
                    plan_number,
                    policy_number,
                    cariier_name,
                    carrier_contact_name,
                    carrier_contact_email,
                    carrier_phone_no,
                    carrier_addr,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( l_entrp_id,
                           l_renewed_plan_id,
                           'BEN_PLAN_RENEWAL',
                           i.plan_number,
                           i.policy_number,
                           i.cariier_name,
                           i.carrier_contact_name,
                           i.carrier_contact_email,
                           i.carrier_phone_no,
                           null,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id );

            end loop;
        end if;

        x_renewed_plan_id := l_renewed_plan_id;   -- Added by Swamy for Ticket#11364
            --
        pc_log.log_error('UPDATE_ER_ACCOUNT_COBRA', 'Before broker mail' || l_entrp_id);

            -- Added by Jaggi
        for y in (
            select
                broker_id
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            y.broker_id := l_broker_id;
        end loop;

        pc_broker.update_broker_auth(
            p_acc_id           => p_acc_id,
            p_broker_id        => l_broker_id,
            p_authorize_req_id => p_authorize_req_id,
            p_authorize_option => p_authorize_option,
            p_is_authorized    => p_is_authorized,
            p_nav_code         => p_nav_code,
            p_user_id          => p_user_id,
            x_error_status     => l_return_status,
            x_error_message    => l_error_message
        );

          -- Added by Swamy for Ticket#10747
          --Send Notifications using PC_NOTIFICATIONS
        pc_notifications.notify_broker_ren_decl_plan(
            p_acc_id       => p_acc_id,
            p_user_id      => p_user_id,
            p_entrp_id     => l_entrp_id,
            p_ben_pln_name => 'COBRA',
            p_ren_dec_flg  => 'R',
            p_acc_num      => pc_account.get_acc_num_from_acc_id(p_acc_id)
                    --      P_Ben_Plan_ID   => L_RENEWED_PLAN_ID,    -- Added by Swamy for Ticket#11364
                    --      P_PAY_ACCT_FEES => P_PAY_ACCT_FEES       -- Added by Swamy for Ticket#11364
        );

        pc_notifications.notify_er_ren_decl_plan(
            p_acc_id       => p_acc_id,
            p_ename        => pc_entrp.get_entrp_name(l_entrp_id),
            p_email        => pc_users.get_email_from_user_id(p_user_id),
            p_user_id      => p_user_id,
            p_entrp_id     => l_entrp_id,
            p_ben_plan_id  => l_renewed_plan_id,    -- Added by Swamy for Ticket#11364 --NULL,
            p_ben_pln_name => 'COBRA',
            p_ren_dec_flg  => 'R',
            p_acc_num      => pc_account.get_acc_num_from_acc_id(p_acc_id)
                                     -- P_PAY_ACCT_FEES => P_PAY_ACCT_FEES       -- Added by Swamy for Ticket#11364
        );

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            pc_log.log_error('UPDATE_ER_ACCOUNT_COBRA', '  SQLCODE  ...'
                                                        || sqlcode
                                                        || sqlerrm);
            x_return_status := 'E';
    end update_er_account_cobra;

     -- NOT USED
    function attach_mail return tbl_attach_mail
        pipelined
    is
        rec rec_attach_mail;
    begin
        select
            directory_path || '/'
        into rec.dir_path
        from
            all_directories
        where
            directory_name = 'GP';

        rec.subject := 'DAILY_RENEWAL_COBRA';
        for i in (
            select
                file_name
            from
                external_files
            where
                    file_action = rec.subject
                and trunc(creation_date) = trunc(sysdate - 1)
        ) loop
            rec.file_name := i.file_name;
            rec.to_address := 'vhsteam@sterlingadministration.com';
--     rec.to_address:='Dhanya.Kumar@sterlingadministration.com';
            rec.message := i.file_name;
            pipe row ( rec );
            rec.file_name := i.file_name;
            rec.to_address := 'Compliance@sterlingadministration.com';
            rec.message := i.file_name;
            pipe row ( rec );
        end loop;

        rec.subject := 'DAILY_RENEWAL_ERISA';
        for i in (
            select
                file_name
            from
                external_files
            where
                    file_action = rec.subject
                and trunc(creation_date) = trunc(sysdate - 1)
        ) loop
            rec.file_name := i.file_name;
            rec.to_address := 'vhsteam@sterlingadministration.com';
--     REC.TO_ADDRESS:='Rupesh.Aujikar@sterlingadministration.com,Dhanya.Kumar@sterlingadministration.com';
            rec.message := i.file_name;
            pipe row ( rec );
            rec.file_name := i.file_name;
            rec.to_address := 'Compliance@sterlingadministration.com';
            rec.message := i.file_name;
            pipe row ( rec );
            rec.file_name := i.file_name;
            rec.to_address := 'finance.department@sterlingadministration.com';
            rec.message := i.file_name;
            pipe row ( rec );
        end loop;

        rec.subject := 'WEEKLY_RENEWAL_POP_ERISA_COBRA';
        select
            directory_path || '/'
        into rec.dir_path
        from
            all_directories
        where
            directory_name = rec.subject;

        for i in (
            select
                file_name
            from
                external_files
            where
                    file_action = rec.subject
                and trunc(creation_date) = trunc(sysdate - 1)
        ) loop
            rec.file_name := i.file_name;
            rec.to_address := 'Dan.tidball@sterlingadministration.com';--weekly/erisa-cobra-pop/ renewal past due/employer renewal
            rec.message := i.file_name;
--     REC.TO_ADDRESS:='Rupesh.Aujikar@sterlingadministration.com,Sumana.Jyoti@sterlingadministration.com';--rec.to_address:='Jay.Bharat@sterlingadministration.com';
            pipe row ( rec );
        end loop;

        rec.subject := 'DAILY_RENEW_POP_ERISA_PAST_DUE';
        select
            directory_path || '/'
        into rec.dir_path
        from
            all_directories
        where
            directory_name = rec.subject;

        for i in (
            select
                file_name
            from
                external_files
            where
                    file_action = rec.subject
                and trunc(creation_date) = trunc(sysdate - 1)
        ) loop
            rec.file_name := i.file_name;
            rec.to_address := 'Dan.tidball@sterlingadministration.com';--weekly/erisa-cobra-pop/ renewal past due/employer renewal
            rec.message := i.file_name;
--     REC.TO_ADDRESS:='Rupesh.Aujikar@sterlingadministration.com,Sumana.Jyoti@sterlingadministration.com';--rec.to_address:='Jay.Bharat@sterlingadministration.com';
            pipe row ( rec );
        end loop;

        rec.subject := 'DAILY_RENEWAL_POP_ERISA';
        select
            directory_path || '/'
        into rec.dir_path
        from
            all_directories
        where
            directory_name = rec.subject;

        for i in (
            select
                file_name
            from
                external_files
            where
                    file_action = rec.subject
                and trunc(creation_date) = trunc(sysdate - 1)
        ) loop
            rec.file_name := i.file_name;
            rec.to_address := 'Dan.tidball@sterlingadministration.com';--weekly/erisa-cobra-pop/ renewal past due/employer renewal
            rec.message := i.file_name;
--     REC.TO_ADDRESS:='Rupesh.Aujikar@sterlingadministration.com,Sumana.Jyoti@sterlingadministration.com';--rec.to_address:='Jay.Bharat@sterlingadministration.com';
            pipe row ( rec );
        end loop;
     --https://dev.sterlinghsa.com/mail/reportsonline.php
    end;
-- added by Jaggi #9866
    function get_employer_plan_info (
        p_entrp_id     in varchar2,
        p_account_type in varchar2
    ) return tbl_employer_plan_info
        pipelined
    is
        rec rec_employer_plan_info;
    begin
        if p_account_type = 'FORM_5500' then
            for x in (
                select
                    max(b.plan_start_date)                                     plan_start_date,
                    max(b.plan_end_date)                                       plan_end_date,
                    b.ben_plan_number,
                    max(pc_lookups.get_meaning(b.plan_type, 'PLAN_TYPE_5500')) plan_type
                from
                    ben_plan_enrollment_setup b,
                    account                   a
                where
                        a.acc_id = b.acc_id
                    and a.entrp_id = p_entrp_id
                    and b.status = 'A'
                group by
                    b.ben_plan_number
                order by
                    plan_end_date desc
            ) loop
                for xx in (
                    select
                        ben_plan_name
                    from
                        ben_plan_enrollment_setup
                    where
                            entrp_id = p_entrp_id
                        and ben_plan_number = x.ben_plan_number
                        and plan_start_date = x.plan_start_date
                        and plan_end_date = x.plan_end_date
                ) loop
                    rec.year := to_char(x.plan_start_date, 'MM/DD/YYYY')
                                || '-'
                                || to_char(x.plan_end_date, 'MM/DD/YYYY');

                    rec.ben_plan_name := xx.ben_plan_name;
                    rec.plan_type := x.plan_type;
                    pipe row ( rec );
                end loop;
            end loop;

        else
            for x in (
                select
                    to_char(b.plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(b.plan_end_date, 'MM/DD/YYYY') plan_year,
                    b.ben_plan_name,
                    case
                        when a.account_type = 'ERISA_WRAP' then
                            pc_lookups.get_meaning(b.plan_type, 'PLAN_TYPE_WRAP')
                        else
                            b.plan_type
                    end                                       plan_type
                from
                    ben_plan_enrollment_setup b,
                    account                   a
                where
                        a.acc_id = b.acc_id
                    and a.entrp_id = p_entrp_id
                    and b.status = 'A'
                    and nvl(b.effective_end_date, b.plan_end_date) + nvl(b.runout_period_days, 0) + nvl(b.grace_period, 0) > sysdate
                order by
                    b.plan_end_date desc
            ) loop
                rec.year := x.plan_year;
                rec.ben_plan_name := x.ben_plan_name;
                rec.plan_type := x.plan_type;
                pipe row ( rec );
            end loop;
        end if;
    end get_employer_plan_info;

  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
    function get_resubmit_batch_number (
        p_entrp_id  in number,
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return tbl_rnw
        pipelined
    is

        l_ben_plan_id  number := 0;
        l_batch_number number := 0;
        cursor cur_erisa_renewal is
        select
            d.ben_plan_id
        from
            enterprise                a,
            account                   b,
            plan_codes                c,
            ben_plan_enrollment_setup d
        where
                a.entrp_id = b.entrp_id
            and b.plan_code = c.plan_code
            and b.acc_id = d.acc_id (+)
            and account_status = 1
            and account_type = 'ERISA_WRAP'
                --AND TRUNC(PLAN_END_DATE)  BETWEEN TRUNC(SYSDATE)-180  AND TRUNC(SYSDATE)+90
            and trunc(plan_end_date) between trunc(sysdate - pc_web_er_renewal.g_after_days) and trunc(sysdate + pc_web_er_renewal.g_prior_days
            )
            and b.acc_id = p_acc_id
            and plan_start_date < sysdate;

        rec            rec_rn;--L_BEN_PLAN_ID NUMBER;

    begin
        if p_plan_type = 'ERISA_WRAP' then
            open cur_erisa_renewal;
            fetch cur_erisa_renewal into l_ben_plan_id;
            close cur_erisa_renewal;
            if nvl(l_ben_plan_id, 0) > 0 then
                for i in (
                    select
                        renewed_plan_id,
                        renewal_batch_number
                    from
                        ben_plan_renewals
                    where
                            ben_plan_id = l_ben_plan_id
                        and acc_id = p_acc_id
                        and plan_type = p_plan_type
                ) loop
                    rec.renewed_ben_plan_id := i.renewed_plan_id;
                    rec.batch_number := i.renewal_batch_number;
                    pipe row ( rec );
                end loop;
            end if;

        elsif p_plan_type = 'POP' then
            for i in (
                select
                    max(ben_plan_id) ben_plan_id --max(decode(plan_type,'BASIC_POP_RENEW','BASIC_POP','COMP_POP_RENEW','COMP_POP',upper(plan_type))) plan_type
                from
                    account                   b,
                    ben_plan_enrollment_setup d
                where
                        b.acc_id = d.acc_id (+)
                    and b.account_status = 1
                    and b.account_type = 'POP'
                    and d.status = 'A'
                    and trunc(d.plan_end_date) between trunc(sysdate) - pc_web_er_renewal.g_after_days and trunc(sysdate) + pc_web_er_renewal.g_prior_days
                    and b.acc_id = p_acc_id
                    and d.plan_start_date < sysdate
            ) loop
                l_ben_plan_id := i.ben_plan_id;
            end loop;

            if nvl(l_ben_plan_id, 0) > 0 then
                for i in (
                    select
                        renewed_plan_id,
                        renewal_batch_number
                    from
                        ben_plan_renewals
                    where
                            ben_plan_id = l_ben_plan_id
                        and acc_id = p_acc_id
                ) loop -- and upper(PLAN_TYPE) = l_plan_type) loop
                    rec.renewed_ben_plan_id := i.renewed_plan_id;
                    rec.batch_number := i.renewal_batch_number;
                    pipe row ( rec );
                end loop;

            end if;

        end if;

        pc_log.log_error('GET_resubmit_batch_number', 'Before Setup p_plan_type'
                                                      || p_plan_type
                                                      || 'p_acc_id :='
                                                      || p_acc_id
                                                      || ' REC.renewed_ben_plan_id :='
                                                      || rec.renewed_ben_plan_id
                                                      || ' p_entrp_id :='
                                                      || p_entrp_id
                                                      || ' REC.batch_number :='
                                                      || rec.batch_number);

    end get_resubmit_batch_number;

  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
    procedure delete_resubmit_data (
        p_acc_id              in number,
        p_entrp_id            in number,
        p_batch_number        in number,
        p_renewed_ben_plan_id in number,
        p_ben_plan_id         in number,
        p_account_type        in varchar2,
        p_eligibility_id      in number
    ) is
    begin
        pc_log.log_error('delete_resubmit_data', 'Before Setup P_Account_Type'
                                                 || p_account_type
                                                 || 'p_batch_number :='
                                                 || p_batch_number);
        if p_account_type = 'ERISA_WRAP' then
            delete from benefit_codes
            where
                entity_id = p_renewed_ben_plan_id;

            delete from plan_notices
            where
                entity_id = p_renewed_ben_plan_id;

            delete from erisa_aca_eligibility
            where
                ben_plan_id = p_renewed_ben_plan_id;

            delete from notes
            where
                    entity_id = p_renewed_ben_plan_id
                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                and note_action = 'SPECIAL_INSTRUCTIONS';

            delete from plan_employer_contacts
            where
                entity_id = p_renewed_ben_plan_id;

            delete from ar_quote_lines
            where
                quote_header_id in (
                    select
                        quote_header_id
                    from
                        ar_quote_headers
                    where
                        ben_plan_id = p_renewed_ben_plan_id
                );

            delete from ar_quote_headers
            where
                ben_plan_id = p_renewed_ben_plan_id;

            delete from enterprise_census
            where
                    ben_plan_id = p_renewed_ben_plan_id
                and census_code = 'NO_OF_EMPLOYEES';

            delete from enterprise_census
            where
                    ben_plan_id = p_renewed_ben_plan_id
                and census_code = 'NO_OF_ELIGIBLE';

            for j in (
                select
                    entity_id
                from
                    entrp_relationships
                where
                        entrp_id = p_entrp_id
                    and entity_type = 'ENTERPRISE'
                    and relationship_type = 'AFFILIATED_ER'
            ) loop
                delete from enterprise
                where
                        en_code = '10'
                    and entrp_id = j.entity_id;

            end loop;
    --DELETE FROM enterprise WHERE En_Code = '10' AND ENTRP_ID in (select entity_id FROM ENTRP_RELATIONSHIPS WHERE entrp_id = p_entrp_id AND Entity_Type   = 'ENTERPRISE' and RELATIONSHIP_TYPE    = 'AFFILIATED_ER');
            delete from entrp_relationships
            where
                    entrp_id = p_entrp_id
                and entity_type = 'ENTERPRISE'
                and relationship_type = 'AFFILIATED_ER';

            for k in (
                select
                    entity_id
                from
                    entrp_relationships
                where
                        entrp_id = p_entrp_id
                    and entity_type = 'ENTERPRISE'
                    and relationship_type = 'CONTROLLED_GROUP'
            ) loop
                delete from enterprise
                where
                        en_code = '11'
                    and entrp_id = k.entity_id;

            end loop;
    --DELETE FROM enterprise WHERE En_Code = '11' AND ENTRP_ID in (select entity_id FROM ENTRP_RELATIONSHIPS WHERE entrp_id = p_entrp_id AND Entity_Type   = 'ENTERPRISE' and RELATIONSHIP_TYPE    = 'CONTROLLED_GROUP');
            delete from entrp_relationships
            where
                    entrp_id = p_entrp_id
                and entity_type = 'ENTERPRISE'
                and relationship_type = 'CONTROLLED_GROUP';

            for m in (
                select
                    contact_id
                from
                    contact
                where
                        entity_type = 'ENTERPRISE'
                    and entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = 'ERISA_WRAP'
            ) loop
                delete from contact_role
                where
                        contact_id = m.contact_id
                    and account_type = p_account_type;

            end loop;
     --DELETE FROM CONTACT WHERE ENTITY_TYPE = 'ENTERPRISE' AND ENTITY_ID = PC_ENTRP.GET_TAX_ID(P_ENTRP_ID) AND account_type = 'ERISA_WRAP';
            for i in (
                select
                    contact_id,
                    entity_id,
                    account_type,
                    contact_type
                from
                    contact_leads a
                where
                        account_type = p_account_type
                    and entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and contact_flg = 'Y'
            ) loop
                delete from contact
                where
                        entity_type = 'ENTERPRISE'
                    and contact_id = i.contact_id
                    and entity_id = i.entity_id
                    and account_type = p_account_type;

            end loop;

	/*FOR I IN (SELECT Contact_Id
		            ,Entity_Id
		            ,Account_Type
                    ,Contact_Type
	           FROM Contact_Leads A
	          WHERE Account_Type = P_Account_Type
	            AND Entity_Id = Pc_Entrp.Get_Tax_Id(P_Entrp_Id)
                AND Contact_flg = 'Y'  ) LOOP
     DELETE FROM CONTACT WHERE ENTITY_TYPE = 'ENTERPRISE' AND CONTACT_ID = i.CONTACT_ID AND ENTITY_ID = i.ENTITY_ID;
     DELETE FROM CONTACT_ROLE WHERE CONTACT_ID = i.CONTACT_ID AND ref_CONTACT_ID = i.ENTITY_ID AND role_type = 'FEE_BILLING' ;
     DELETE FROM CONTACT_ROLE WHERE CONTACT_ID = i.CONTACT_ID AND ref_CONTACT_ID = i.ENTITY_ID AND role_type = i.Contact_Type AND Account_Type = i.Account_Type;

	END LOOP;
    */
            delete from external_sales_team_leads
            where
                ref_entity_id = p_renewed_ben_plan_id;

        elsif p_account_type = 'POP' then
            delete from benefit_codes
            where
                    entity_id = p_renewed_ben_plan_id
                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP';

            delete from ar_quote_headers
            where
                ben_plan_id = p_renewed_ben_plan_id;

            delete from custom_eligibility_req
            where
                entity_id = p_renewed_ben_plan_id;

            delete from plan_employer_contacts
            where
                batch_number = p_batch_number;

            for j in (
                select
                    entity_id
                from
                    entrp_relationships
                where
                        entrp_id = p_entrp_id
                    and entity_type = 'ENTERPRISE'
                    and relationship_type = 'AFFILIATED_ER'
            ) loop
                delete from enterprise
                where
                        en_code = '10'
                    and entrp_id = j.entity_id;

            end loop;

            delete from entrp_relationships
            where
                    entrp_id = p_entrp_id
                and entity_type = 'ENTERPRISE'
                and relationship_type = 'AFFILIATED_ER';

            for k in (
                select
                    entity_id
                from
                    entrp_relationships
                where
                        entrp_id = p_entrp_id
                    and entity_type = 'ENTERPRISE'
                    and relationship_type = 'CONTROLLED_GROUP'
            ) loop
                delete from enterprise
                where
                        en_code = '11'
                    and entrp_id = k.entity_id;

            end loop;

            delete from entrp_relationships
            where
                    entrp_id = p_entrp_id
                and entity_type = 'ENTERPRISE'
                and relationship_type = 'CONTROLLED_GROUP';

            pc_log.log_error('delete_resubmit_data', 'Before Setup rowcount'
                                                     || sql%rowcount
                                                     || 'p_batch_number :='
                                                     || p_batch_number);

            for m in (
                select
                    contact_id
                from
                    contact
                where
                        entity_type = 'ENTERPRISE'
                    and entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = 'ERISA_WRAP'
            ) loop
                delete from contact_role
                where
                        contact_id = m.contact_id
                    and account_type = p_account_type;

            end loop;

            delete from contact
            where
                    entity_type = 'ENTERPRISE'
                and entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and account_type = 'ERISA_WRAP';

            delete from external_sales_team_leads
            where
                    ref_entity_id = p_renewed_ben_plan_id
                and ref_entity_type = 'BEN_PLAN_RENEWALS'
                and lead_source = 'RENEWAL';

        elsif p_account_type = 'COBRA' then  -- Added by Swamy for Ticket#11636
            delete from ar_quote_lines
            where
                quote_header_id in (
                    select
                        quote_header_id
                    from
                        ar_quote_headers
                    where
                            ben_plan_id = p_renewed_ben_plan_id
                        and entrp_id = p_entrp_id
                );

            delete from ar_quote_headers
            where
                    ben_plan_id = p_renewed_ben_plan_id
                and entrp_id = p_entrp_id;

            delete from enterprise_census
            where
                    ben_plan_id = p_renewed_ben_plan_id
                and census_code = 'NO_OF_ELIGIBLE'
                and entity_type = 'ENTERPRISE'
                and entity_id = p_entrp_id;

            delete from file_attachments
            where
                    batch_number = p_batch_number
                and entity_name = 'ACCOUNT'
                and entity_id = p_acc_id;

	/*FOR I IN (SELECT Contact_Id
		            ,Entity_Id
		            ,Account_Type
                    ,Contact_Type
	           FROM Contact_Leads A
	          WHERE Account_Type = P_Account_Type
	            AND Entity_Id = Pc_Entrp.Get_Tax_Id(P_Entrp_Id)
                AND Contact_flg = 'Y' 
                AND ref_entity_type = 'BEN_PLAN_RENEWALS') LOOP
     pc_log.log_error('delete_resubmit_data', 'Before Setup i.CONTACT_ID '||i.CONTACT_ID||'i.ENTITY_ID := '||i.ENTITY_ID||' i.Contact_Type := '||i.Contact_Type||' i.Account_Type := '||i.Account_Type);
     DELETE FROM CONTACT WHERE ENTITY_TYPE = 'ENTERPRISE' AND CONTACT_ID = i.CONTACT_ID AND ENTITY_ID = i.ENTITY_ID AND ACCOUNT_TYPE = 'COBRA';
     DELETE FROM CONTACT_ROLE WHERE CONTACT_ID = i.CONTACT_ID AND NVL(ref_CONTACT_ID,i.ENTITY_ID) = i.ENTITY_ID AND role_type in (i.Contact_Type,i.Account_Type,'FEE_BILLING' ) AND Account_Type = i.Account_Type;
	END LOOP;
    */
        end if;

    end delete_resubmit_data;

-- Added by Swamy for Ticket#11364
    procedure populate_cobra_renewal_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        v_prev_batch                  number := null;
        v_plan_start_date             varchar2(100);
        v_plan_end_date               varchar2(100);
        l_page_validity               varchar2(1);
        v_acc_id                      account.acc_id%type;
        v_plan_name                   ben_plan_enrollment_setup.ben_plan_name%type;
        v_quote_header_id             number;
        v_prev_quote_header_id        number;
        l_remit_bank_name             bank_accounts.bank_name%type;
        l_remit_routing_number        varchar2(9);
        l_remit_bank_acc_num          bank_accounts.bank_acct_num%type;
        l_remit_bank_acc_type         bank_accounts.bank_acct_type%type;
        l_entity_type                 varchar2(100);
        l_broker_id                   number;
        l_ga_id                       number;
        l_bank_name                   bank_accounts.bank_name%type;
        l_routing_number              varchar2(9);
        l_bank_acc_num                bank_accounts.bank_acct_num%type;
        l_bank_acc_type               bank_accounts.bank_acct_type%type;
        l_prev_entity_id              bank_accounts.entity_id%type;
        l_prev_entity_type            bank_accounts.entity_type%type;
        l_bank_actt_id                bank_accounts.bank_acct_id%type;
        l_opt_bank_name               bank_accounts.bank_name%type;
        l_opt_bank_routing_num        bank_accounts.bank_routing_num%type;
        l_opt_bank_acct_num           bank_accounts.bank_acct_num%type;
        l_opt_bank_acct_type          bank_accounts.bank_acct_type%type;
        l_opt_bank_acct_id            bank_accounts.bank_routing_num%type;
	-- Below Added by Swamy for Ticket#12534
        l_giac_response               varchar2(100);
        l_giac_verify                 varchar2(100);
        l_giac_authenticate           varchar2(100);
        l_bank_acct_verified          varchar2(100);
        l_business_name               varchar2(100);
        x_user_bank_acct_stg_id       number;
        l_remit_giac_response         varchar2(100);
        l_remit_giac_verify           varchar2(100);
        l_remit_giac_authenticate     varchar2(100);
        l_remit_bank_acct_verified    varchar2(100);
        l_remit_business_name         varchar2(100);
        x_remit_user_bank_acct_stg_id number;
        l_annual_optional_remit       varchar2(100);
        l_giac_verified_response      varchar2(100);
        l_optional_fee_payment_method varchar2(100);
        l_fees_payment_flag           varchar2(100);
        x_bank_status                 varchar2(100);
    begin
        pc_log.log_error('POPULATE_COBRA_RENEWAL_STAGE', '**1 p_batch_number'
                                                         || p_batch_number
                                                         || 'p_entrp_id :='
                                                         || p_entrp_id
                                                         || ' p_ben_plan_id :='
                                                         || p_ben_plan_id
                                                         || 'p_user_id :='
                                                         || p_user_id);
    -- Get the Previous Batch Number if available.
        for q in (
            select
                max(batch_number) batch_number
            from
                online_compliance_staging a,
                account                   b
            where
                    a.entrp_id = b.entrp_id
                and a.entrp_id = p_entrp_id
                and b.account_type = 'COBRA'
                and batch_number <> p_batch_number
        ) loop
            v_prev_batch := q.batch_number;
        end loop;

        v_acc_id := pc_entrp.get_acc_id(p_entrp_id);
        l_page_validity := 'V';

   -- If renewal_resubmit_flag is Y, and user did not do renewal, then for the next renewal the renewal_resubmit_flag should become as N.
        for j in (
            select
                nvl(renewal_resubmit_flag, 'N') renewal_resubmit_flag
            from
                account
            where
                acc_id = v_acc_id
        ) loop  -- Added by Swamy for Ticket#11636
            update account
            set
                renewal_resubmit_flag = 'N',
                renewal_resubmit_assigned_to = null
            where
                    entrp_id = p_entrp_id
                and account_type = 'COBRA';

        end loop;

        pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);
        if nvl(l_entity_type, '*') = '*' then
            pc_general_agent.get_ga_id(p_user_id, l_entity_type, l_ga_id);
        end if;

        l_entity_type := nvl(l_entity_type, 'EMPLOYER');
        for j in (
            select
                to_char((a.plan_end_date + 1), 'MM/DD/YYYY') as plan_start_date,
                ( to_char((add_months((a.plan_end_date + 1), 60) - 1),
                          'MM/DD/YYYY') )                              as plan_end_date,
                a.ben_plan_name     -- Added by Jaggi #9905
            from
                ben_plan_enrollment_setup a
            where
                    acc_id = v_acc_id
                and ben_plan_id = (
                    select
                        max(ben_plan_id)
                    from
                        ben_plan_enrollment_setup bp
                    where
                        a.acc_id = bp.acc_id
                )
        ) loop
            v_plan_start_date := j.plan_start_date;
            v_plan_end_date := j.plan_end_date;
            v_plan_name := j.ben_plan_name;     -- Added by Jaggi #9905
        end loop;

        pc_log.log_error('POPULATE_COBRA_RENEWAL_STAGE', '**2 v_prev_batch' || v_prev_batch);

   -- Added for Prod Ticket#11612 by Swamy
   -- When there is no record in the staging table, insert record with RENEWAL as source
        if v_prev_batch is null then
            insert into online_compliance_staging (
                record_id,
                entrp_id,
                source,
                batch_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                inactive_plan_flag
            ) values ( compliance_staging_seq.nextval,
                       p_entrp_id,
                       'RENEWAL',
                       p_batch_number,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       nvl(
                           pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                           'N'
                       ) );

        else
            for x in (
                select
                    a.*
                from
                    online_compliance_staging a
                where
                        a.entrp_id = p_entrp_id
                    and batch_number = v_prev_batch
            ) loop
            -- Added by Joshi 11980 
                l_bank_name := x.bank_name;
                l_routing_number := x.routing_number;
                l_bank_acc_num := x.bank_acc_num;
                l_bank_acc_type := x.bank_acc_type;
                l_bank_actt_id := x.bank_acct_id;
                l_opt_bank_name := x.optional_bank_name;
                l_opt_bank_routing_num := x.optional_routing_number;
                l_opt_bank_acct_num := x.optional_bank_acc_num;
                l_opt_bank_acct_type := x.optional_bank_acc_type;
                l_opt_bank_acct_id := x.optional_fee_bank_acct_id;
                if l_entity_type in ( 'BROKER', 'GA' ) then
                    l_bank_name := null;
                    l_routing_number := null;
                    l_bank_acc_num := null;
                    l_bank_acc_type := null;
                    l_bank_actt_id := null;
                    l_opt_bank_name := null;
                    l_opt_bank_routing_num := null;
                    l_opt_bank_acct_num := null;
                    l_opt_bank_acct_type := null;
                    l_opt_bank_acct_id := null;
                end if;

                insert into online_compliance_staging (
                    record_id,
                    entrp_id,
                    no_off_ees,
                    state_of_org,
                    fiscal_yr_end,
                    type_of_entity,
                    batch_number,
                    bank_name,
                    routing_number,
                    bank_acc_num,
                    bank_acc_type,
                    error_message,
                    created_by,
                    creation_date,
                    remittance_flag,
                    fees_payment_flag,
                    salesrep_flag,
                    salesrep_id,
                    send_invoice,
                    page2,
                    page3_contact,
                    page3_payment,
                    entity_name_desc,
                    org_eff_date,
                    eff_date_sterling,
                    no_of_eligible,
                    affliated_flag,
                    cntrl_grp_flag,
                    page1_company,
                    page1_plan,
                    source,
                    acct_payment_fees,
                    carrier_notify_flag,
                    page1_plan_sponsor,
                    city,
                    zip,
                    address,
                    contact_name,
                    email,
                    signed_by,
                    sign_type,
                    bank_acct_id,
                    company_tax,
                    bank_authorize,
                    inactive_plan_flag,
                    state_main_office,
                    state_govern_law,
                    affliated_diff_ein,
                    type_entity_other,
                    optional_fee_paid_by,
                    optional_fee_payment_method,
                    optional_fee_bank_acct_id,
                    optional_bank_name,
                    optional_routing_number,
                    optional_bank_acc_num,
                    optional_bank_acc_type,
                    remit_bank_authorize,
                    optional_bank_authorize,
                    annual_fee_bank_created_by,
                    optional_fee_bank_created_by
                ) values ( compliance_staging_seq.nextval,
                           x.entrp_id,
                           x.no_off_ees,
                           x.state_of_org,
                           x.fiscal_yr_end,
                           x.type_of_entity,
                           p_batch_number,
                           l_bank_name,
                           l_routing_number,
                           l_bank_acc_num,
                           l_bank_acc_type,
                           x.error_message,
                           p_user_id,
                           sysdate,
                           x.remittance_flag,
                           x.fees_payment_flag,
                           x.salesrep_flag,
                           x.salesrep_id,
                           x.send_invoice,
                           x.page2,
                           x.page3_contact,
                           x.page3_payment,
                           x.entity_name_desc,
                           x.org_eff_date,
                           x.eff_date_sterling,
                           x.no_of_eligible,
                           x.affliated_flag,
                           x.cntrl_grp_flag,
                           x.page1_company,
                           x.page1_plan,
                           'RENEWAL',
                           x.acct_payment_fees,
                           x.carrier_notify_flag,
                           x.page1_plan_sponsor,
                           x.city,
                           x.zip,
                           x.address,
                           x.contact_name,
                           x.email,
                           x.signed_by,
                           x.sign_type,
                           l_bank_actt_id,
                           x.company_tax,
                           x.bank_authorize,
                           x.inactive_plan_flag,
                           x.state_main_office,
                           x.state_govern_law,
                           x.affliated_diff_ein,
                           x.type_entity_other,
                           x.optional_fee_paid_by,
                           x.optional_fee_payment_method,
                           l_opt_bank_acct_id,
                           l_opt_bank_name,
                           l_opt_bank_routing_num,
                           l_opt_bank_acct_num,
                           l_opt_bank_acct_type,
                           x.remit_bank_authorize,
                           x.optional_bank_authorize,
                           x.annual_fee_bank_created_by,
                           x.optional_fee_bank_created_by );

            end loop;
        end if;  -- Added by swamy for Ticket#11683 07/07/2023, even if v_prev_batch is null we need to add bank and remittance bank details for renewal 

        pc_log.log_error('POPULATE_COBRA_RENEWAL_STAGE', '**2.1 l_entity_type'
                                                         || l_entity_type
                                                         || 'v_acc_id :='
                                                         || v_acc_id);
         -- For EMployer login, the remittancee bank account should be displayed.
         -- For Broker, Remittance bank account should not be displayed.
        if l_entity_type = 'EMPLOYER' then
            pc_log.log_error('POPULATE_COBRA_RENEWAL_STAGE', '**2.11 l_entity_type'
                                                             || l_entity_type
                                                             || 'v_acc_id :='
                                                             || v_acc_id);
            for b in (
                select
                    bank_acct_id,
                    bank_routing_num,
                    bank_acct_num,
                    bank_name,
                    bank_acct_type,
                    giac_response,
                    giac_verify,
                    giac_authenticate,
                    bank_acct_verified,
                    business_name
                from
                    bank_accounts
                where
                        status = 'A'
                    and bank_account_usage = 'INVOICE'
                    and entity_id = v_acc_id
                    and entity_type = 'ACCOUNT'
            ) loop
                l_bank_name := b.bank_name;
                l_routing_number := b.bank_routing_num;
                l_bank_acc_num := b.bank_acct_num;
                l_bank_acc_type := b.bank_acct_type;
                l_giac_response := b.giac_response;
                l_giac_verify := b.giac_verify;
                l_giac_authenticate := b.giac_authenticate;
                l_bank_acct_verified := b.bank_acct_verified;
                l_business_name := b.business_name;
                if nvl(l_opt_bank_acct_id, 0) = b.bank_acct_id then
                    l_annual_optional_remit := 'O';
                  --   l_optional_fee_payment_method := 'ACH';
                else
                    l_annual_optional_remit := 'A';
                   --  l_fees_payment_flag     := 'ACH';
                end if;

            end loop;

            pc_log.log_error('POPULATE_COBRA_RENEWAL_STAGE', '**2.2 calling insert_user_bank_acct_staging l_entity_type'
                                                             || l_entity_type
                                                             || 'v_acc_id :='
                                                             || v_acc_id);
        -- Added by Swamy for Ticket#12534 
            if nvl(l_bank_name, '*') <> '*' then   -- Added By Swamy for Ticket#INC30684
                pc_user_bank_acct.insert_user_bank_acct_staging(
                    p_user_bank_acct_stg_id  => null,
                    p_entrp_id               => p_entrp_id,
                    p_batch_number           => p_batch_number,
                    p_account_type           => 'COBRA',
                    p_acct_usage             => 'INVOICE',
                    p_display_name           => l_bank_name,
                    p_bank_acct_type         => l_bank_acc_type,
                    p_bank_routing_num       => l_routing_number,
                    p_bank_acct_num          => l_bank_acc_num,
                    p_bank_name              => l_bank_name,
                    p_validity               => 'V',
                    p_bank_authorize         => null,
                    p_user_id                => p_user_id,
                    p_entity_type            => l_entity_type,
                    p_giac_response          => l_giac_response,
                    p_giac_verify            => l_giac_verify,
                    p_giac_authenticate      => l_giac_authenticate,
                    p_bank_acct_verified     => l_bank_acct_verified,
                    p_bank_status            => 'A',
                    p_business_name          => l_business_name,
                    p_giac_verified_response => 'V',
                    p_annual_optional_remit  => l_annual_optional_remit,
                    x_user_bank_acct_stg_id  => x_user_bank_acct_stg_id,
                    x_error_status           => x_error_status,
                    x_error_message          => x_error_message
                );
            end if;

            for rb in (
                select
                    bank_routing_num,
                    bank_acct_num,
                    bank_name,
                    bank_acct_type,
                    giac_response,
                    giac_verify,
                    giac_authenticate,
                    bank_acct_verified,
                    business_name
                from
                    bank_accounts
                where
                        status = 'A'
                    and bank_account_usage = 'COBRA_DISBURSE'
                    and entity_id = v_acc_id
                    and entity_type = 'ACCOUNT'
            ) loop
                l_remit_bank_name := rb.bank_name;
                l_remit_routing_number := rb.bank_routing_num;
                l_remit_bank_acc_num := rb.bank_acct_num;
                l_remit_bank_acc_type := rb.bank_acct_type;
                l_remit_giac_response := rb.giac_response;
                l_remit_giac_verify := rb.giac_verify;
                l_remit_giac_authenticate := rb.giac_authenticate;
                l_remit_bank_acct_verified := rb.bank_acct_verified;
                l_remit_business_name := rb.business_name;
            end loop;
        -- Added by Swamy for Ticket#12534 
            pc_log.log_error('POPULATE_COBRA_RENEWAL_STAGE', '**2.4 calling insert_user_bank_acct_staging l_entity_type'
                                                             || l_entity_type
                                                             || 'v_acc_id :='
                                                             || v_acc_id);
            if nvl(l_remit_bank_name, '*') <> '*' then    -- Added By Swamy for Ticket#INC30684
                pc_user_bank_acct.insert_user_bank_acct_staging(
                    p_entrp_id               => p_entrp_id,
                    p_batch_number           => p_batch_number,
                    p_user_bank_acct_stg_id  => null,
                    p_account_type           => 'COBRA',
                    p_acct_usage             => 'COBRA_DISBURSE',
                    p_display_name           => l_remit_bank_name,
                    p_bank_acct_type         => l_remit_bank_acc_type,
                    p_bank_routing_num       => l_remit_routing_number,
                    p_bank_acct_num          => l_remit_bank_acc_num,
                    p_bank_name              => l_remit_bank_name,
                    p_validity               => 'V',
                    p_bank_authorize         => null,
                    p_user_id                => p_user_id,
                    p_entity_type            => l_entity_type,
                    p_giac_response          => l_remit_giac_response,
                    p_giac_verify            => l_remit_giac_verify,
                    p_giac_authenticate      => l_remit_giac_authenticate,
                    p_bank_acct_verified     => l_remit_bank_acct_verified,
                    p_bank_status            => 'A',
                    p_business_name          => l_remit_business_name,
                    p_giac_verified_response => 'V',
                    p_annual_optional_remit  => 'R',
                    x_user_bank_acct_stg_id  => x_remit_user_bank_acct_stg_id,
                    x_error_status           => x_error_status,
                    x_error_message          => x_error_message
                );
            end if;        
		-- Commented by Swamy for Ticket#12534 
              /*UPDATE online_compliance_staging
                  SET bank_name = l_bank_name
                     ,routing_number = l_routing_number
                     ,bank_acc_type = l_bank_acc_type
                     ,bank_acc_num = l_bank_acc_num
                     ,fees_payment_flag =  'Ach'
                     ,remit_bank_name = l_remit_bank_name
                     ,remit_routing_number = l_remit_routing_number
                     ,remit_bank_acc_type = l_remit_bank_acc_type
                     ,remit_bank_acc_num = l_remit_bank_acc_num
                WHERE source       = 'RENEWAL'
                  AND entrp_id     = p_entrp_id
                  AND batch_number = p_batch_number;*/

              -- Added by Swamy for Ticket#12534         
              /* UPDATE online_compliance_staging
                  SET fees_payment_flag =  'ACH'
                WHERE source       = 'RENEWAL'
                  AND entrp_id     = p_entrp_id
                  AND batch_number = p_batch_number;*/
        end if;

        delete from contact_leads
        where
                entity_id = pc_entrp.get_tax_id(p_entrp_id)
            and account_type = 'COBRA'
            and ref_entity_id = p_ben_plan_id;

        pc_web_er_renewal.upsert_contact_leads(
            p_entrp_id      => p_entrp_id,
            p_user_id       => p_user_id,
            p_ben_plan_id   => p_ben_plan_id,
            p_account_type  => 'COBRA',
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        v_quote_header_id := null;
        for m in (
            select
                a.*
            from
                ar_quote_headers_staging a
            where
                    a.entrp_id = p_entrp_id
                and batch_number = v_prev_batch
        ) loop
            insert into ar_quote_headers_staging (
                quote_header_id,
                quote_name,
                quote_number,
                total_quote_price,
                discount_amount,
                quote_status,
                quote_date,
                quote_source,
                entrp_id,
                batch_number,
                notes,
                payment_method,
                bank_acct_id,
                ben_plan_id,
                account_type,
                creation_date,
                created_by,
                enrollment_detail_id,
                billing_frequency
            ) values ( compliance_quote_seq.nextval,
                       m.quote_name,
                       m.quote_number,
                       m.total_quote_price,
                       m.discount_amount,
                       m.quote_status,
                       m.quote_date,
                       m.quote_source,
                       m.entrp_id,
                       p_batch_number,
                       m.notes,
                       m.payment_method,
                       m.bank_acct_id,
                       m.ben_plan_id,
                       m.account_type,
                       sysdate,
                       p_user_id,
                       m.enrollment_detail_id,
                       m.billing_frequency ) returning quote_header_id into v_quote_header_id;

            for n in (
                select
                    a.*
                from
                    ar_quote_lines_staging a
                where
                        a.quote_header_id = m.quote_header_id
                    and batch_number = v_prev_batch
            ) loop
                insert into ar_quote_lines_staging (
                    quote_line_id,
                    quote_header_id,
                    reason_code,
                    rate_plan_id,
                    rate_plan_detail_id,
                    line_list_price,
                    list_adjusted_amount,
                    list_adjusted_percent,
                    adjustment_reason,
                    start_date,
                    end_date,
                    invoice_to_entity_id,
                    notes,
                    batch_number,
                    creation_date,
                    created_by,
                    rate_plan_name
                ) values ( compliance_quote_lines_seq.nextval,
                           v_quote_header_id,
                           n.reason_code,
                           n.rate_plan_id,
                           n.rate_plan_detail_id,
                           n.line_list_price,
                           n.list_adjusted_amount,
                           n.list_adjusted_percent,
                           n.adjustment_reason,
                           n.start_date,
                           n.end_date,
                           n.invoice_to_entity_id,
                           n.notes,
                           p_batch_number,
                           sysdate,
                           p_user_id,
                           n.rate_plan_name );

            end loop;

        end loop;

        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'COBRA',
            p_page_no       => 1,
            p_block_name    => 'PLAN_OPTIONS',
            p_validity      => l_page_validity,
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );
 --END IF;  -- Commented and moved on top by Sway for Ticket#11683 07/07/2023

    exception
        when others then
            x_error_message := 'Error in Pre-Population of Cobra renewal pc_web_compliance.POPULATE_COBRA_RENEWAL_STAGE ' || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('POPULATE_COBRA_RENEWAL_STAGE', 'OTHERS ' || x_error_message);
    end populate_cobra_renewal_stage;

-- Added by Swamy for Ticket#11364
    procedure upsert_carrier_notification_staging (
        p_entrp_id              in number,
        p_user_id               in number,
        p_policy_number         in pc_online_enrollment.varchar2_tbl,
        p_plan_number           in pc_online_enrollment.varchar2_tbl,
        p_carrier_name          in pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_name  in pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_email in pc_online_enrollment.varchar2_tbl,
        p_carrier_phone_no      in pc_online_enrollment.varchar2_tbl,
        p_batch_number          in number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    ) is
    begin
        delete from carrier_notification_staging
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id
            and entity_type = 'BEN_PLAN_RENEWAL';

        for i in p_carrier_name.first..p_carrier_name.last loop
            insert into carrier_notification_staging (
                batch_number,
                entrp_id,
                entity_id,
                entity_type,
                plan_number,
                policy_number,
                cariier_name,
                carrier_contact_name,
                carrier_contact_email,
                carrier_phone_no,
                carrier_addr,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( p_batch_number,
                       p_entrp_id,
                       null,  -- This is the Ben plan ID
                       'BEN_PLAN_RENEWAL',
                       p_plan_number(i),
                       p_policy_number(i),
                       p_carrier_name(i),
                       p_carrier_contact_name(i),
                       p_carrier_contact_email(i),
                       p_carrier_phone_no(i),
                       null,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id );

        end loop;

    exception
        when others then
            x_error_message := 'Error in Insert into carrier_notification_staging of Cobra renewal pc_web_compliance.UPsert_carrier_notification_staging ' || sqlerrm
            ;
            rollback;
           -- X_RETURN_STATUS := 'E';
    end upsert_carrier_notification_staging;

-- Added by Jaggi #11364
    function get_carrier_notification_staging (
        p_entrp_id     in number,
        p_batch_number in number
    ) return tbl_carrier_notif
        pipelined
    is
        l_rec rec_carrier_notif_stg;
    begin
        for j in (
            select
                *
            from
                carrier_notification_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_rec.entity_type := j.entity_type;
            l_rec.plan_number := j.plan_number;
            l_rec.policy_number := j.policy_number;
            l_rec.cariier_name := j.cariier_name;
            l_rec.carrier_contact_name := j.carrier_contact_name;
            l_rec.carrier_contact_email := j.carrier_contact_email;
            l_rec.carrier_phone_no := j.carrier_phone_no;
            l_rec.carrier_addr := j.carrier_addr;
            l_rec.carrier_notify_id := j.carrier_notify_id;
            pipe row ( l_rec );
        end loop;
    end get_carrier_notification_staging;

-- added by Jaggi #11368
    procedure populate_fsa_hra_renewal_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_entity_type  varchar2(100);
        l_broker_id    number;
        l_ga_id        number;
        l_ben_plan_id  number;
        l_account_type varchar2(20);
        l_user_id      number;
        l_entrp_code   varchar2(20);
    begin
        x_error_status := 'S';
        pc_log.log_error('POPULATE_FSA_HRA_RENEWAL_STAGE', '**1 p_batch_number'
                                                           || p_batch_number
                                                           || 'p_entrp_id :='
                                                           || p_entrp_id
                                                           || 'p_user_id :='
                                                           || p_user_id);

        for q in (
            select
                b.account_type,
                e.entrp_code
            from
                account    b,
                enterprise e
            where
                    b.entrp_id = e.entrp_id
                and b.entrp_id = p_entrp_id
        ) loop
            l_account_type := q.account_type;
            l_entrp_code := q.entrp_code;
        end loop;

        for x in (
            select
                user_id
            from
                online_users
            where
                tax_id = l_entrp_code
        ) loop
            l_user_id := x.user_id;
        end loop;

        delete from contact_leads
        where
                entity_id = pc_entrp.get_tax_id(p_entrp_id)
            and account_type = l_account_type;

        pc_web_er_renewal.upsert_contact_leads(
            p_entrp_id      => p_entrp_id,
            p_user_id       => l_user_id,
            p_ben_plan_id   => l_ben_plan_id,
            p_account_type  => l_account_type,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

    exception
        when others then
            x_error_message := 'Error in Pre-Population of FSA/HRA renewal pc_web_compliance.POPULATE_FSA_HRA_RENEWAL_STAGE ' || sqlerrm
            ;
            x_error_status := 'E';
    end populate_fsa_hra_renewal_stage;

end;
/


-- sqlcl_snapshot {"hash":"f9424285741fb9a62c8c256a660c4d84b2a8638e","type":"PACKAGE_BODY","name":"PC_WEB_COMPLIANCE","schemaName":"SAMQA","sxml":""}