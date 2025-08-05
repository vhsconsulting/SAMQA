-- liquibase formatted sql
-- changeset SAMQA:1754374026500 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_enroll_utility_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_enroll_utility_pkg.sql:null:405bb773e1a8675c2953b1337cd902f26e5208dc:create

create or replace package body samqa.pc_enroll_utility_pkg is

    function get_person_info (
        p_ssn in varchar2
    ) return person_t
        pipelined
        deterministic
    is
        l_person_row person_row_t;
    begin
        for x in (
            select
                first_name,
                middle_name,
                last_name,
                to_char(birth_date, 'MM/DD/YYYY')       birth_date,
                title,
                gender,
                address,
                city,
                state,
                zip,
                replace(
                    strip_bad(phone_day),
                    '-'
                )                                       phone_day,
                passport,
                drivlic,
                nvl(email,
                    pc_users.get_email_from_taxid(ssn)) email
            from
                person
            where
                    ssn = format_ssn(p_ssn)
                and rownum = 1
        ) loop
            l_person_row.first_name := x.first_name;
            l_person_row.middle_name := x.middle_name;
            l_person_row.last_name := x.last_name;
            l_person_row.birth_date := x.birth_date;
            l_person_row.title := x.title;
            l_person_row.gender := x.gender;
            l_person_row.address := x.address;
            l_person_row.city := x.city;
            l_person_row.state := x.state;
            l_person_row.zip := x.zip;
            l_person_row.day_phone := x.phone_day;
            l_person_row.passport := x.passport;
            l_person_row.driv_lic := x.drivlic;
            l_person_row.email := x.email;
            if x.drivlic is not null then
                l_person_row.id_number := x.drivlic;
                l_person_row.id_type := 'D';
            end if;

            if x.passport is not null then
                l_person_row.id_number := x.passport;
                l_person_row.id_type := 'P';
            end if;
    --  l_person_row.email := pc_users.get_email_from_taxid(p_ssn);
            pipe row ( l_person_row );
        end loop;
    end get_person_info;

-- Added by Joshi to retrieve the personal details based on the ER.
    function get_person_info (
        p_ssn in varchar2,
        p_ein in varchar2
    ) return person_t
        pipelined
        deterministic
    is
        l_person_row person_row_t;
    begin
        for x in (
            select
                p.first_name,
                p.middle_name,
                p.last_name,
                to_char(p.birth_date, 'MM/DD/YYYY')       birth_date,
                p.title,
                p.gender,
                p.address,
                p.city,
                p.state,
                p.zip,
                replace(
                    strip_bad(p.phone_day),
                    '-'
                )                                         phone_day,
                p.passport,
                p.drivlic,
                nvl(p.email,
                    pc_users.get_email_from_taxid(p.ssn)) email
            from
                person     p,
                enterprise e
            where
                    p.ssn = format_ssn(p_ssn)
                and p.entrp_id = e.entrp_id
                and replace(e.entrp_code, '-') = replace(p_ein, '-')
        ) loop
            l_person_row.first_name := x.first_name;
            l_person_row.middle_name := x.middle_name;
            l_person_row.last_name := x.last_name;
            l_person_row.birth_date := x.birth_date;
            l_person_row.title := x.title;
            l_person_row.gender := x.gender;
            l_person_row.address := x.address;
            l_person_row.city := x.city;
            l_person_row.state := x.state;
            l_person_row.zip := x.zip;
            l_person_row.day_phone := x.phone_day;
            l_person_row.passport := x.passport;
            l_person_row.driv_lic := x.drivlic;
            l_person_row.email := x.email;
            if x.drivlic is not null then
                l_person_row.id_number := x.drivlic;
                l_person_row.id_type := 'D';
            end if;

            if x.passport is not null then
                l_person_row.id_number := x.passport;
                l_person_row.id_type := 'P';
            end if;
    --  l_person_row.email := pc_users.get_email_from_taxid(p_ssn);
            pipe row ( l_person_row );
        end loop;
    end get_person_info;

    function does_account_exist (
        p_ssn          in varchar2,
        p_account_type in varchar2
    ) return varchar2 is
        l_exist varchar2(1) := 'N';
    begin
        for x in (
            select
                b.pers_id,
                a.acc_id,
                a.acc_num
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and a.account_type = p_account_type
                and b.ssn = format_ssn(p_ssn)
                and a.account_status <> 4
        ) loop
            l_exist := 'Y';
        end loop;

        return l_exist;
    end does_account_exist;

    function does_person_exist (
        p_ssn          in varchar2,
        p_dob          in date,
        p_account_type in varchar2
    ) return varchar2 is
        l_exist varchar2(1) := 'N';
    begin
        for x in (
            select
                b.pers_id,
                a.acc_id,
                a.acc_num
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and a.account_type = p_account_type
                and b.ssn = format_ssn(p_ssn)
                and b.birth_date = p_dob
                and a.account_status <> 4
        ) loop
            l_exist := 'Y';
        end loop;

        return l_exist;
    end does_person_exist;

    function get_product_lookup (
        p_ein in varchar2,
        p_ssn in varchar2,
        p_dob in varchar2
    ) return product_lookup_t
        pipelined
        deterministic
    as
        l_record product_lookup_row;
    begin
        pc_log.log_error('get_product_lookup:p_ein', p_ein);
        pc_log.log_error('get_product_lookup:p_ssn', p_ssn);
        pc_log.log_error('get_product_lookup:p_dob', p_dob);
        for x in (
            select
                'HSA'                          product_code,
                'Health Saving Accounts (HSA)' product_description,
                b.entrp_id                     entrp_id,
                'NEW'                          action
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.account_type = 'HSA'
  --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'HSA') = 'N'
            union
            select
                'FSA',
                'Flexible Spending Account (FSA)',
                b.entrp_id fsa_entrp_id,
                'NEW'      action
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
--    AND     A.ACCOUNT_TYPE = 'FSA'
 --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'FSA') = 'N'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            a.acc_id = c.acc_id
                        and c.plan_end_date > sysdate
                        and c.status in ( 'P', 'A' )
                        and ( c.effective_end_date is null
                              or c.effective_end_date > sysdate )
                        and c.product_type = 'FSA'
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id,
                'NEW'      action
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
--    AND     A.ACCOUNT_TYPE = 'FSA'
 --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'FSA') = 'N'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            a.acc_id = c.acc_id
                        and c.plan_end_date > sysdate
                        and c.status in ( 'P', 'A' )
                        and ( c.effective_end_date is null
                              or c.effective_end_date > sysdate )
                        and c.product_type = 'HRA'
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id,
                'NEW'      action
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.account_type = 'HRA'
   --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'HRA') = 'N'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            a.acc_id = c.acc_id
                        and c.plan_end_date > sysdate
                        and c.status in ( 'P', 'A' )
                        and ( c.effective_end_date is null
                              or c.effective_end_date > sysdate )
                        and c.product_type = 'HRA'
                )
            union
            select
                'FSA',
                'Flexible Spending Account (FSA)',
                b.entrp_id fsa_entrp_id,
                'NEW'      action
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
                and c.status in ( 'A', 'P' )
   --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
    --AND     C.PLAN_TYPE NOT IN ('HRA','HR5','HR4','HRP','ACO')
                and a.account_type = 'FSA'
                and c.plan_end_date > sysdate
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'FSA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                        and d.status = 'R'
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id fsa_entrp_id,
                'NEW'      action
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
                and c.status in ( 'A', 'P' )
   --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and c.product_type = 'HRA'
                and a.account_type = 'FSA'
                and c.plan_end_date > sysdate
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'FSA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                        and d.status = 'R'
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id fsa_entrp_id,
                'NEW'      action
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
   --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and c.status in ( 'A', 'P' )
                and c.product_type = 'HRA'
                and c.plan_end_date > sysdate
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'FSA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                        and d.status = 'R'
                )
            union
            select
                'FSA',
                'Flexible Spending Account (FSA)',
                b.entrp_id fsa_entrp_id,
                'RENEW'    action
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
   --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and c.status in ( 'A', 'P' )
                and ( c.effective_end_date is null
                      or c.effective_end_date > sysdate )
    --AND     C.PLAN_TYPE NOT IN ('HRA','HR5','HR4','HRP','ACO')
                and c.product_type = 'FSA'
                and c.plan_end_date > sysdate
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'FSA') = 'Y'
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id,
                'RENEW'    action
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
   --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and c.status in ( 'P', 'A' )
                and ( c.effective_end_date is null
                      or c.effective_end_date > sysdate )
                and c.product_type = 'HRA'
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'FSA') = 'Y'
                and c.plan_end_date > sysdate
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id,
                'RENEW'    action
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
   --For Ticket#3432.Inactive Products should not show up in Enrollment express'
                and a.account_status = 1
                and c.status in ( 'P', 'A' )
                and ( c.effective_end_date is null
                      or c.effective_end_date > sysdate )
                and c.product_type = 'HRA'
                and c.plan_end_date > sysdate
                and does_person_exist(p_ssn, to_date(p_dob, 'MM/DD/YYYY'), 'HRA') = 'Y'
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                )
        ) loop
            if pc_entrp.allow_exp_enroll(x.entrp_id) = 'Y' then  --For online_enroll
                l_record.product_code := x.product_code;
                l_record.product_description := x.product_description;
                l_record.entrp_id := x.entrp_id;
                l_record.action := x.action;
                pipe row ( l_record );
            end if;
        end loop;

    end get_product_lookup;

    function get_er_product_lookup (
        p_ein in varchar2
    ) return product_lookup_t
        pipelined
        deterministic
    as
        l_record product_lookup_row;
    begin
        for x in (
            select distinct
                case
                    when a.account_type = 'HSA' then
                        'HSA'
                    when a.account_type = 'HRA' then
                        'HRA'
                    else
                        c.product_type
                end        product_code,
                case
                    when a.account_type = 'HSA' then
                        'Health Saving Accounts (HSA)'
                    when a.account_type = 'HRA' then
                        'Health Reimbursement Arrangement (HRA)'
                    when c.product_type = 'HRA' then
                        'Health Reimbursement Arrangement (HRA)'
                    when c.product_type = 'FSA' then
                        'Flexible Spending Account(FSA)'
                end        product_description,
                b.entrp_id entrp_id,
                null       action,
                a.plan_code
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and c.acc_id = a.acc_id
                and a.account_type in ( 'FSA', 'HRA', 'HSA' )
                and c.status = 'A'
            union
            select
                'HSA',
                'Health Saving Accounts (HSA)',
                b.entrp_id,
                null action,
                a.plan_code
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.account_type = 'HSA'
        ) loop
            l_record.product_code := x.product_code;
            l_record.product_description := x.product_description;
            l_record.entrp_id := x.entrp_id;
            l_record.action := x.action;
            l_record.plan_code := x.plan_code;
            pipe row ( l_record );
        end loop;
    end get_er_product_lookup;

    function get_enrolled_products (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return product_lookup_t
        pipelined
        deterministic
    as
        l_record product_lookup_row;
    begin
        for x in (
            select
                'HSA'                          product_code,
                'Health Saving Accounts (HSA)' product_description,
                b.entrp_id                     entrp_id
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.account_type = 'HSA'
                and does_account_exist(p_ssn, 'HSA') = 'Y'
            union
            select
                'FSA',
                'Flexible Spending Account (FSA)',
                b.entrp_id fsa_entrp_id
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.account_type = 'FSA'
                and does_account_exist(p_ssn, 'FSA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            a.acc_id = c.acc_id
                        and c.plan_end_date > sysdate
                        and c.status = 'A'
                        and ( c.effective_end_date is null
                              or c.effective_end_date > sysdate )
                        and c.product_type = 'FSA'
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.account_type = 'FSA'
                and does_account_exist(p_ssn, 'FSA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            a.acc_id = c.acc_id
                        and c.plan_end_date > sysdate
                        and c.status = 'A'
                        and ( c.effective_end_date is null
                              or c.effective_end_date > sysdate )
                        and c.product_type = 'HRA'
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.account_type = 'HRA'
                and does_account_exist(p_ssn, 'HRA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            a.acc_id = c.acc_id
                        and c.plan_end_date > sysdate
                        and c.status = 'A'
                        and ( c.effective_end_date is null
                              or c.effective_end_date > sysdate )
                        and c.product_type = 'HRA'
                )
            union
            select
                'FSA',
                'Flexible Spending Account (FSA)',
                b.entrp_id fsa_entrp_id
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
                and ( c.effective_end_date is null
                      or c.effective_end_date > sysdate )
                and c.product_type = 'FSA'
                and c.status = 'A'
                and a.account_type = 'FSA'
                and does_account_exist(p_ssn, 'FSA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
                and ( c.effective_end_date is null
                      or c.effective_end_date > sysdate )
                and c.product_type = 'HRA'
                and a.account_type = 'FSA'
                and c.status = 'A'
                and does_account_exist(p_ssn, 'FSA') = 'Y'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                )
            union
            select
                'HRA',
                'Health Reimbursement Arrangements (HRA)',
                b.entrp_id hra_entrp_id
            from
                account                   a,
                enterprise                b,
                ben_plan_enrollment_setup c
            where
                    replace(b.entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.acc_id = c.acc_id
                and ( c.effective_end_date is null
                      or c.effective_end_date > sysdate )
                and c.product_type = 'HRA'
                and c.status = 'A'
                and a.account_type = 'HRA'
                and does_account_exist(p_ssn, 'HRA') = 'Y'
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, b.entrp_id)
                        and d.ben_plan_id_main = c.ben_plan_id
                )
        ) loop
            l_record.product_code := x.product_code;
            l_record.product_description := x.product_description;
            l_record.entrp_id := x.entrp_id;
            pipe row ( l_record );
        end loop;
    end get_enrolled_products;

    function get_carrier_info (
        p_tax_id    in varchar2,
        p_prod_type in varchar2
    ) return carrier_t
        pipelined
        deterministic
    is
        l_carrier_row carrier_row_t;
        l_count       number := 0;
    begin
        if nvl(p_prod_type, 'HSA') = 'HSA' then
            for x in (
                --SLN commented SELECT  a.NAME||' '||SINGLE_DEDUCTIBLE||'/'||FAMILY_DEDUCTIBLE name
                select
                    a.name                                  name,
                    b.carrier_id,
                    'EMPLOYER_HEALTH_PLAN'                  insure_plan_type,
                    to_char(b.effective_date, 'MM/DD/YYYY') effective_date
                from
                    employer_health_plans b,
                    enterprise            c,
                    myhealthplan          a
                where
                        replace(c.entrp_code, '-') = replace(p_tax_id, '-')
                    and b.entrp_id = c.entrp_id
                    and b.carrier_id = a.entrp_id
                    and b.show_online_flag = 'Y'
                    and b.effective_end_date is null
            ) loop
                l_carrier_row.carrier_name := x.name;
                l_carrier_row.carrier_id := x.carrier_id;
                l_carrier_row.insure_plan_type := x.insure_plan_type;
                l_carrier_row.effective_date := x.effective_date;
                l_count := l_count + 1;
                pipe row ( l_carrier_row );
            end loop;
        end if;

        if l_count = 0
        or ( p_prod_type in ( 'HRA', 'FSA' ) ) then
            for x in (
                select
                    name,
                    entrp_id          carrier_id,
                    'ALL_HEALTH_PLAN' insure_plan_type
                from
                    enterprise
                where
                        en_code = 3
                    and not exists (
                        select
                            *
                        from
                            employer_health_plans
                        where
                            carrier_id = enterprise.entrp_id
                    )
            ) loop
                l_carrier_row.carrier_name := x.name;
                l_carrier_row.carrier_id := x.carrier_id;
                l_carrier_row.insure_plan_type := x.insure_plan_type;
                pipe row ( l_carrier_row );
            end loop;

        end if;

    end get_carrier_info;

    function get_ee_carrier_info (
        p_tax_id in varchar2
    ) return carrier_t
        pipelined
        deterministic
    is
        l_carrier_row carrier_row_t;
    begin
        for x in (
            select
                e.name                              name,
                e.entrp_id                          carrier_id,
                'EMPLOYEE_HEALTH_PLAN'              insure_plan_type,
                to_char(a.start_date, 'MM/DD/YYYY') effective_date
            from
                person     b,
                account    c,
                insure     a,
                enterprise e
            where
                    b.ssn = format_ssn(p_tax_id)
                and b.pers_id = c.pers_id
                and c.account_type in ( 'HRA', 'FSA', 'HSA' )
                and a.pers_id = c.pers_id
                and a.insur_id = e.entrp_id
        ) loop
            l_carrier_row.carrier_name := x.name;
            l_carrier_row.carrier_id := x.carrier_id;
            l_carrier_row.insure_plan_type := x.insure_plan_type;
            l_carrier_row.effective_date := x.effective_date;
            pipe row ( l_carrier_row );
        end loop;
    end get_ee_carrier_info;

    function get_annual_election (
        p_ein in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                plans.plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(plans.effective_date, 'MM/DD/YYYY')   effective_date,
                nvl(plans.minimum_election, 0)                minimum_election,
                nvl(plans.maximum_election, 0)                maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY') plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')  plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')    plan_end_date
            from
                fsa_hra_er_ben_plans_v plans,
                enterprise             er
            where
                    replace(er.entrp_code, '-') = replace(p_ein, '-')
                and plans.entrp_id = er.entrp_id
                and plans.plan_end_date > sysdate
                and plans.status = 'A'
           --  AND     plans.plan_type NOT IN ('HRA','HRP','HR5','HR4','ACO')
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.effective_date := x.effective_date;
            l_benefit_plan_row.minimum_election := x.minimum_election;
            l_benefit_plan_row.maximum_election := x.maximum_election;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            pipe row ( l_benefit_plan_row );
        end loop;
    end get_annual_election;

    function get_dependents (
        p_ssn in varchar2
    ) return dependents_t
        pipelined
        deterministic
    is
        l_dep_row dependent_row_t;
    begin
        for x in (
            select
                first_name,
                middle_name,
                last_name,
                gender,
                relat_code,
                ssn,
                birth_date
            from
                dependant_v
            where
                subscriber_ssn = format_ssn(p_ssn)
        ) loop
            l_dep_row.first_name := x.first_name;
            l_dep_row.middle_name := x.middle_name;
            l_dep_row.last_name := x.last_name;
            l_dep_row.gender := x.gender;
            l_dep_row.relat_code := x.relat_code;
            l_dep_row.ssn := replace(x.ssn, '-');
            l_dep_row.birth_date := x.birth_date;
            pipe row ( l_dep_row );
        end loop;
    end get_dependents;

    function get_not_enrolled_deps (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return dependents_t
        pipelined
        deterministic
    is
        l_dep_row dependent_row_t;
    begin
        for x in (
            select distinct
                first_name,
                middle_name,
                last_name,
                gender,
                initcap(relative) relative,
                format_ssn(ssn)   ssn,
                birth_date
            from
                mass_enroll_dependant
            where
                    subscriber_ssn = format_ssn(p_ssn)
                and batch_number = p_batch_number
                and ssn is not null
                and trunc(months_between(sysdate,
                                         format_to_date(birth_date))) / 12 >= 10
        ) loop
            l_dep_row.first_name := x.first_name;
            l_dep_row.middle_name := x.middle_name;
            l_dep_row.last_name := x.last_name;
            l_dep_row.gender := x.gender;
            l_dep_row.relat_code := x.relative;
            l_dep_row.ssn := x.ssn;
            l_dep_row.birth_date := x.birth_date;
            pipe row ( l_dep_row );
        end loop;
    end get_not_enrolled_deps;

    function get_ee_benefit_plan (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                plans.plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(
                    greatest(plans.effective_date, plans.plan_start_date),
                    'MM/DD/YYYY'
                )                                             effective_date,
                nvl(plans.minimum_election, 0)                minimum_election,
                case
                    when plans.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                        nvl(plans.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plans.plan_type, sysdate) * 12)
                    else
                        nvl(plans.maximum_election, 0)
                end                                           maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY') plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')  plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')    plan_end_date,
                er.entrp_id,
                plans.product_type
            from
                fsa_hra_er_ben_plans_v plans,
                enterprise             er
            where
                    replace(er.entrp_code, '-') = replace(p_ein, '-')
                and plans.entrp_id = er.entrp_id
                and plans.plan_end_date > sysdate
                and plans.status = 'A'
                and plans.plan_type not in ( 'NDT', 'RENEW', 'COMP_POP', 'BASIC_POP' ) /* Ticket 2739 */
        --     AND     plans.plan_type NOT IN ('HRA','HRP','HR5','HR4','ACO')
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
                and not exists (
                    select
                        *
                    from
                        account                   a,
                        person                    b,
                        ben_plan_enrollment_setup c
                    where
                            a.pers_id = b.pers_id
                        and a.account_type in ( 'HRA', 'FSA' )
                        and a.acc_id = c.acc_id
                        and c.ben_plan_id_main = plans.ben_plan_id
                        and b.ssn = format_ssn(p_ssn)
                )
            union
            select
                plans.plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(
                    greatest(plans.effective_date, plans.plan_start_date),
                    'MM/DD/YYYY'
                )                                             effective_date,
                nvl(plans.minimum_election, 0)                minimum_election,
                case
                    when plans.plan_type in ( 'TRN', 'PKG' ) then
                        nvl(plans.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plans.plan_type, sysdate) * 12)
                    else
                        nvl(plans.maximum_election, 0)
                end                                           maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY') plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')  plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')    plan_end_date,
                er.entrp_id,
                plans.product_type
            from
                fsa_hra_er_ben_plans_v plans,
                enterprise             er
            where
                    replace(er.entrp_code, '-') = replace(p_ein, '-')
                and plans.entrp_id = er.entrp_id
                and plans.plan_end_date > sysdate
                and plans.status = 'A'
                and plans.plan_type not in ( 'NDT', 'RENEW', 'COMP_POP', 'BASIC_POP' ) /* Ticket 2739 */
        --     AND     plans.plan_type NOT IN ('HRA','HRP','HR5','HR4','ACO')
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
                and exists (
                    select
                        *
                    from
                        account                   a,
                        person                    b,
                        ben_plan_enrollment_setup c
                    where
                            a.pers_id = b.pers_id
                        and a.account_type in ( 'HRA', 'FSA' )
                        and a.acc_id = c.acc_id
                        and c.status = 'R'
                        and c.ben_plan_id_main = plans.ben_plan_id
                        and b.ssn = format_ssn(p_ssn)
                )
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.effective_date := x.effective_date;
            l_benefit_plan_row.minimum_election := x.minimum_election;
            l_benefit_plan_row.maximum_election := x.maximum_election;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            l_benefit_plan_row.entrp_id := x.entrp_id;
            l_benefit_plan_row.product_type := x.product_type; -- added by Joshi for webform
            pipe row ( l_benefit_plan_row );
        end loop;
    end get_ee_benefit_plan;

    function get_enrolled_benefit_plan (
        p_acc_id       in number,
        p_product_type in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                case
                    when pc_lookups.get_meaning(plans.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA' then
                        pc_lookups.get_meaning(plans.plan_type, 'FSA_PLAN_TYPE')
                        || '-'
                        || plans.ben_plan_name
                    else
                        pc_lookups.get_meaning(plans.plan_type, 'FSA_PLAN_TYPE')
                end                                                                      plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(
                    greatest(plans.effective_date, plans.plan_start_date),
                    'MM/DD/YYYY'
                )                                                                        effective_date,
                plans.annual_election                                                    minimum_election,
                case
                    when plans.plan_type in ( 'TRN', 'PKG' ) then
                        nvl(plans.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plans.plan_type, sysdate) * 12)
                    else
                        nvl(plans.maximum_election, 0)
                end                                                                      maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY')                            plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')                             plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')                               plan_end_date,
                pc_lookups.get_meaning(plans.status, 'BEN_PLAN_STATUS')                  status,
                plans.status                                                             status_code,
                pc_benefit_plans.get_cov_tier_name(plans.ben_plan_id_main, plans.acc_id) cov_tier_name,
                runout_period_days,
                grace_period,
                plans.product_type,
                plans.acc_id,
                plans.annual_election,
                case
                    when trunc(plans.plan_start_date) <= trunc(sysdate)
                         and trunc(plans.plan_end_date) > trunc(sysdate) then
                        'Y'
                    else
                        'N'
                end                                                                      current_year
            from
                ben_plan_enrollment_setup plans
            where
                    plans.acc_id = p_acc_id
                and plans.plan_end_date > sysdate
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
                and plans.status <> 'R'
                and plans.product_type = p_product_type
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.effective_date := x.effective_date;
            l_benefit_plan_row.minimum_election := x.minimum_election;
            l_benefit_plan_row.maximum_election := x.maximum_election;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            l_benefit_plan_row.status := x.status;
            l_benefit_plan_row.coverage_tier := x.cov_tier_name;
            l_benefit_plan_row.runout_period_days := x.runout_period_days;
            l_benefit_plan_row.grace_period := x.grace_period;
            l_benefit_plan_row.status_code := x.status_code;
            l_benefit_plan_row.product_type := x.product_type;
            l_benefit_plan_row.acc_id := x.acc_id;
            l_benefit_plan_row.annual_election := x.annual_election;
            l_benefit_plan_row.current_year := x.current_year;
            pipe row ( l_benefit_plan_row );
        end loop;
    end get_enrolled_benefit_plan;

    function get_benefit_plan (
        p_ben_plan_id in number
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                case
                    when pc_lookups.get_meaning(plans.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA' then
                        pc_lookups.get_meaning(plans.plan_type, 'FSA_PLAN_TYPE')
                        || '-'
                        || plans.ben_plan_name
                    else
                        pc_lookups.get_meaning(plans.plan_type, 'FSA_PLAN_TYPE')
                end                                                                      plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(
                    greatest(plans.effective_date, plans.plan_start_date),
                    'MM/DD/YYYY'
                )                                                                        effective_date,
                plans.annual_election                                                    minimum_election,
                case
                    when plans.plan_type in ( 'TRN', 'PKG' ) then
                        nvl(plans.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plans.plan_type, sysdate) * 12)
                    else
                        nvl(plans.maximum_election, 0)
                end                                                                      maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY')                            plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')                             plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')                               plan_end_date,
                pc_lookups.get_meaning(plans.status, 'BEN_PLAN_STATUS')                  status,
                plans.status                                                             status_code,
                pc_benefit_plans.get_cov_tier_name(plans.ben_plan_id_main, plans.acc_id) cov_tier_name,
                plans.life_event_code,
                runout_period_days,
                grace_period,
                plans.acc_id,
                plans.product_type,
                plans.batch_number,
                plans.ben_plan_id_main
            from
                ben_plan_enrollment_setup plans
            where
                plans.ben_plan_id = p_ben_plan_id
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.effective_date := x.effective_date;
            l_benefit_plan_row.minimum_election := x.minimum_election;
            l_benefit_plan_row.maximum_election := x.maximum_election;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            l_benefit_plan_row.status := x.status;
            l_benefit_plan_row.coverage_tier := x.cov_tier_name;
            l_benefit_plan_row.runout_period_days := x.runout_period_days;
            l_benefit_plan_row.grace_period := x.grace_period;
            l_benefit_plan_row.status_code := x.status_code;
            l_benefit_plan_row.pay_cycle := null;
            l_benefit_plan_row.first_payroll_date := null;
            l_benefit_plan_row.pay_contrb := null;
            l_benefit_plan_row.annual_election := x.minimum_election;
            l_benefit_plan_row.life_event_code := x.life_event_code;
            l_benefit_plan_row.product_type := x.product_type;
            l_benefit_plan_row.acc_id := x.acc_id;
            l_benefit_plan_row.batch_number := x.batch_number;
            l_benefit_plan_row.ben_plan_id_main := x.ben_plan_id_main;
            for xx in (
                select distinct
                    pay_cycle,
                    first_payroll_date,
                    pay_contrb
                from
                    pay_details
                where
                        ben_plan_id = p_ben_plan_id
                    and acc_id = x.acc_id
            ) loop
                l_benefit_plan_row.pay_cycle := xx.pay_cycle;
                l_benefit_plan_row.first_payroll_date := xx.first_payroll_date;
                l_benefit_plan_row.pay_contrb := xx.pay_contrb;
            end loop;

            pipe row ( l_benefit_plan_row );
        end loop;
    end get_benefit_plan;

    function get_enrollment_status (
        p_batch_number in varchar2
    ) return enrollment_status_t
        pipelined
        deterministic
    is
        l_record enrollment_status_row_t;
    begin
        for x in (
            select
                decode(a.enrollment_status, 'Success', 'S', 'Error', 'E',
                       enrollment_status)                                     enrollment_status,
                a.acc_num,
                pc_lookups.get_account_type(a.account_type)                   account_type,
                a.account_type                                                acc_type,
                b.plan_type,
                pc_benefit_plans.get_plan_name(b.plan_type, b.er_ben_plan_id) plan_type_meaning,
                nvl(b.status, a.error_message)                                error_message,
                a.enrollment_id,
                b.er_ben_plan_id,
                nvl(a.fraud_flag, 'N')                                        fraud_flag
            from
                online_enrollment   a,
                online_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and a.enrollment_id = b.enrollment_id (+)
        ) loop
            l_record.acc_num := x.acc_num;
            l_record.account_type := x.account_type;
            l_record.acct_type := x.acc_type;
            l_record.enrollment_status := x.enrollment_status;
            l_record.plan_type_meaning := x.plan_type_meaning;
            l_record.fraud_flag := x.fraud_flag;
            l_record.plan_type := x.plan_type;
            l_record.error_message := x.error_message;
            for xx in (
                select
                    plan_start_date,
                    plan_end_date
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = x.er_ben_plan_id
            ) loop
                l_record.plan_start_date := to_char(xx.plan_start_date, 'MM/DD/YYYY');
                l_record.plan_end_date := to_char(xx.plan_end_date, 'MM/DD/YYYY');
            end loop;

            l_record.error_message := nvl(l_record.error_message, x.error_message);
            l_record.enrollment_id := x.enrollment_id;
            pipe row ( l_record );
        end loop;
    end get_enrollment_status;

    function does_dependent_exist (
        p_ssn          in varchar2,
        p_account_type in varchar2
    ) return varchar2 is
        l_exist varchar2(1);
    begin
        for x in (
            select
                count(*) cnt
            from
                person  a,
                account b,
                person  c
            where
                    a.ssn = format_ssn(p_ssn)
                and b.account_type = p_account_type
                and a.pers_id = b.pers_id
                and a.pers_main = c.pers_id
        ) loop
            if x.cnt > 0 then
                l_exist := 'Y';
            end if;
        end loop;

        return nvl(l_exist, 'N');
    end does_dependent_exist;

    function get_qual_events (
        p_acc_id in number,
        p_source in varchar2 default 'EVENT_CHANGE'
    ) return lookup_t
        pipelined
        deterministic
    is
        l_record lookup_row_t;
    begin
        for x in (
            select
                lookup_code,
                description
            from
                lookups l
            where
                    l.lookup_name = 'LIFE_EVENT_CODE'
				  --and lookup_code NOT IN ('NEW_HIRE','OPEN_ENROLLMENT', 'COBRA')
                and lookup_code not in ( 'ADDRESS_CHANGE', 'COURT_ORDER', 'DEP_CHANGE', 'EMPR_CHANGE', 'LOA_NO_CONTRIBUTION',
                                         'LOA_POST_TAX_CONTRIBUTION', 'LOSS_OF_MEDICARE', 'MARITAL_STATUS_CHANGE', 'MEDICARE', 'NEW_HIRE'
                                         ,
                                         'OPEN_ENROLLMENT', 'TERM_PLAN' )  --#9742 By Jaggi 'OTHER' added
                and p_source = 'EVENT_CHANGE'
            union
            select
                lookup_code,
                description
            from
                lookups l
            where
                    l.lookup_name = 'LIFE_EVENT_CODE'
--               AND lookup_code = 'COBRA'
                and lookup_code not in ( 'ADDRESS_CHANGE', 'COURT_ORDER', 'DEP_CHANGE', 'EMPR_CHANGE', 'LOA_NO_CONTRIBUTION',
                                         'LOA_POST_TAX_CONTRIBUTION', 'LOSS_OF_MEDICARE', 'MARITAL_STATUS_CHANGE', 'MEDICARE', 'NEW_HIRE'
                                         ,
                                         'OPEN_ENROLLMENT', 'TERM_PLAN' )   --#9742 By Jaggi 'OTHER' added
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                        effective_end_date is not null
                        and c.status = 'A'
                        and effective_end_date + 90 > sysdate
                        and c.plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        and acc_id = p_acc_id
                )
                and p_source = 'EVENT_CHANGE'
            union
            select
                lookup_code,
                description
            from
                lookups l
            where
                    l.lookup_name = 'LIFE_EVENT_CODE'
                and lookup_code in ( 'COURT_ORDER', 'DEP_CHANGE', 'MARITAL_STATUS_CHANGE', 'MEDICARE', 'NEW_HIRE',
                                     'OPEN_ENROLLMENT' )
                and p_source = 'ENROLLMENT'
            union
            -- added by Joshi for Webform enrollment.
            select
                lookup_code,
                description
            from
                lookups l
            where
                    l.lookup_name = 'LIFE_EVENT_CODE'
                and lookup_code in ( 'NEW_HIRE', 'OPEN_ENROLLMENT' )
                and p_source = 'WEBFORM_ENROLL'
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            pipe row ( l_record );
        end loop;
    end get_qual_events;

    function get_pending_employees (
        p_entrp_id  in varchar2,
        p_plan_type in varchar2
    ) return pending_plans_t
        pipelined
        deterministic
    is
        l_record pending_plans_row_t;
    begin
        pc_log.log_error('get_pending_employees', 'entrp id ' || p_entrp_id);
        if p_plan_type = 'HRA' then
            for x in (
                select
                    d.first_name
                    ||
                    case
                        when d.middle_name is null then
                                ''
                        else
                            ' ' || d.middle_name
                    end
                    || ' '
                    || d.last_name                                                   name,
                    a.plan_type,
                    pc_benefit_plans.get_plan_name(a.plan_type, a.ben_plan_id)       plan_type_meaing,
                    to_char(a.effective_date, 'mm/dd/yyyy')                          effective_date,
                    a.annual_election,
                    a.life_event_code,
                    to_char(a.plan_start_date, 'mm/dd/yyyy')                         plan_start_date,
                    to_char(a.plan_end_date, 'mm/dd/yyyy')                           plan_end_date,
                    a.ben_plan_id,
                    a.acc_id,
                    d.pers_id,
                    pc_benefit_plans.get_cov_tier_name(a.ben_plan_id_main, a.acc_id) cov_tier_name,
                    c.acc_num
                from
                    ben_plan_enrollment_setup a,
                    account                   c,
                    person                    d
                where
                        a.status = 'P'
                    and a.acc_id = c.acc_id
                    and c.pers_id = d.pers_id
                    and a.product_type = 'HRA'
                    and d.entrp_id = p_entrp_id
            ) loop
                l_record.name := x.name;
                l_record.plan_type := x.plan_type;
                l_record.plan_type_meaning := x.plan_type_meaing;
                l_record.effective_date := x.effective_date;
                l_record.annual_election := x.annual_election;
                l_record.life_event_code := x.life_event_code;
                l_record.plan_start_date := x.plan_start_date;
                l_record.plan_end_date := x.plan_end_date;
                l_record.ben_plan_id := x.ben_plan_id;
                l_record.acc_id := x.acc_id;
                l_record.pers_id := x.pers_id;
                l_record.cov_tier_name := x.cov_tier_name;
                l_record.acc_num := x.acc_num;
                pipe row ( l_record );
            end loop;

        else
            for x in (
                select
                    d.first_name
                    ||
                    case
                        when d.middle_name is null then
                                ''
                        else
                            ' ' || d.middle_name
                    end
                    || ' '
                    || d.last_name                                                   name,
                    a.plan_type,
                    pc_benefit_plans.get_plan_name(a.plan_type, a.ben_plan_id)       plan_type_meaing,
                    to_char(a.effective_date, 'mm/dd/yyyy')                          effective_date,
                    a.annual_election,
                    a.life_event_code,
                    to_char(a.plan_start_date, 'mm/dd/yyyy')                         plan_start_date,
                    to_char(a.plan_end_date, 'mm/dd/yyyy')                           plan_end_date,
                    a.ben_plan_id,
                    a.acc_id,
                    d.pers_id,
                    pc_benefit_plans.get_cov_tier_name(a.ben_plan_id_main, a.acc_id) cov_tier_name,
                    c.acc_num
                from
                    ben_plan_enrollment_setup a,
                    account                   c,
                    person                    d
                where
                        a.status = 'P'
                    and a.acc_id = c.acc_id
                    and c.pers_id = d.pers_id
                    and a.product_type = 'FSA'
                    and d.entrp_id = p_entrp_id
            ) loop
                l_record.name := x.name;
                l_record.plan_type := x.plan_type;
                l_record.plan_type_meaning := x.plan_type_meaing;
                l_record.effective_date := x.effective_date;
                l_record.annual_election := x.annual_election;
                l_record.life_event_code := x.life_event_code;
                l_record.pay_cycle := null;
                l_record.first_payroll_date := null;
                l_record.pay_contrb := null;
                l_record.acc_num := x.acc_num;
                for xx in (
                    select distinct
                        pay_cycle,
                        first_payroll_date,
                        pay_contrb
                    from
                        pay_details
                    where
                            ben_plan_id = x.ben_plan_id
                        and acc_id = x.acc_id
                ) loop
                    l_record.pay_cycle := xx.pay_cycle;
                    l_record.first_payroll_date := xx.first_payroll_date;
                    l_record.pay_contrb := xx.pay_contrb;
                end loop;

                l_record.plan_start_date := x.plan_start_date;
                l_record.plan_end_date := x.plan_end_date;
                l_record.ben_plan_id := x.ben_plan_id;
                l_record.acc_id := x.acc_id;
                l_record.pers_id := x.pers_id;
                l_record.cov_tier_name := x.cov_tier_name;
                pipe row ( l_record );
            end loop;
        end if;

    end get_pending_employees;

    function debit_card_allowed (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return yes_no_t
        pipelined
        deterministic
    is
        l_record yes_no_row_t;
        l_count  number := 0;
        l_exists varchar2(1) := 'N';
    begin
        for x in (
            select
                a.entrp_id,
                b.account_type,
                a.card_allowed allowed
            from
                enterprise a,
                account    b
            where
                    replace(entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                and a.card_allowed = 0
                and b.account_type in ( 'HSA', 'FSA', 'HRA' )
        ) loop
            if x.allowed = 0 then
                l_count := 0;
                l_exists := 'N';
                for xx in (
                    select
                        pc_person.count_debit_card(a.pers_id) card_count
                    from
                        person  a,
                        account b
                    where
                            a.pers_id = b.pers_id
                        and a.entrp_id = x.entrp_id
                        and b.account_type = x.account_type
                        and a.ssn = format_ssn(p_ssn)
                ) loop
                    l_exists := 'Y';
                    if xx.card_count = 0 then
                        l_count := 1;
                    end if;
                end loop;

                if ( l_exists = 'N'
                or l_count = 1 ) then
                    l_record.debit_card_flag := x.account_type;
                    pipe row ( l_record );
                end if;

            end if;
        end loop;
    end debit_card_allowed;

    function get_coverage_tier (
        p_ein in varchar2
    ) return coverage_tier_t
        pipelined
        deterministic
    is
        l_record coverage_tier_row_t;
    begin
        for x in (
            select
                b.coverage_tier_name,
                b.coverage_id,
                b.annual_election,
                nvl(a.new_hire_contrib, 'NONE') new_hire_contrib,
                a.ben_plan_id
            from
                ben_plan_enrollment_setup a,
                ben_plan_coverages        b
            where
                a.entrp_id in (
                    select
                        a.entrp_id
                    from
                        enterprise a, account    b
                    where
                            replace(a.entrp_code, '-') = replace(p_ein, '-')
                        and a.entrp_id = b.entrp_id
                        and b.account_type in ( 'HRA', 'FSA' )
                )
                and a.product_type = 'HRA'
          --    AND TRUNC(a.plan_start_date) <= trunc(SYSDATE)
                and a.status = 'A'
                and trunc(a.plan_end_date) >= trunc(sysdate)
                and a.ben_plan_id = b.ben_plan_id
            order by
                a.plan_type
        ) loop
            l_record.cov_tier_name := x.coverage_tier_name;
            l_record.cov_tier_id := x.coverage_id;
            l_record.annual_election := x.annual_election;
            l_record.calculation_method := x.new_hire_contrib;
            l_record.ben_plan_id := x.ben_plan_id;
            pipe row ( l_record );
        end loop;
    end get_coverage_tier;

    function get_coverage_tier (
        p_ein         in varchar2,
        p_ben_plan_id in number
    ) return coverage_tier_t
        pipelined
        deterministic
    is
        l_record coverage_tier_row_t;
    begin
        pc_log.log_error('get_coverage_tier', 'p_ein' || p_ein);
        pc_log.log_error('get_coverage_tier', 'p_ben_plan_id' || p_ben_plan_id);
        for x in (
            select
                b.coverage_tier_name,
                b.coverage_id,
                b.annual_election,
                nvl(a.new_hire_contrib, 'NONE') new_hire_contrib,
                a.ben_plan_id
            from
                ben_plan_enrollment_setup a,
                ben_plan_coverages        b
            where
                a.entrp_id in (
                    select
                        a.entrp_id
                    from
                        enterprise a, account    b
                    where
                            replace(a.entrp_code, '-') = replace(p_ein, '-')
                        and a.entrp_id = b.entrp_id
                        and b.account_type in ( 'HRA', 'FSA' )
                )
                and a.product_type = 'HRA'
             -- AND TRUNC(a.plan_start_date) <= trunc(SYSDATE)
                and a.ben_plan_id = p_ben_plan_id
                and a.status = 'A'
                and trunc(a.plan_end_date) >= trunc(sysdate)
                and a.ben_plan_id = b.ben_plan_id
            order by
                a.plan_type
        ) loop
            l_record.cov_tier_name := x.coverage_tier_name;
            l_record.cov_tier_id := x.coverage_id;
            l_record.annual_election := x.annual_election;
            l_record.calculation_method := x.new_hire_contrib;
            l_record.ben_plan_id := x.ben_plan_id;
            pipe row ( l_record );
        end loop;

    end get_coverage_tier;

    function get_hex_conn_details (
        p_ssn          in varchar2,
        p_batch_number in varchar2
    ) return hex_conn_t
        pipelined
        deterministic
    is
        l_record hex_conn_row_t;
    begin

	   -- IF pc_insure.get_eob_status(p_ssn) = 'SHOW_CONNECT' THEN
        for x in (
            select
                a.first_name,
                a.middle_name,
                a.last_name,
                a.email,
                a.employer_name,
                a.user_id,
                a.account_list
            from
                hex_login_v       a,
                online_enrollment b
            where
                    a.pers_id = b.pers_id
                and b.batch_number = p_batch_number
        ) loop
            l_record.first_name := x.first_name;
            l_record.middle_name := x.middle_name;
            l_record.last_name := x.last_name;
            l_record.email := x.email;
            l_record.employer_name := x.employer_name;
            l_record.user_id := x.user_id;
            l_record.account_list := x.account_list;
            pipe row ( l_record );
        end loop;

	   -- END IF;
    end get_hex_conn_details;

    function get_welcome_email (
        p_batch_number in number
    ) return welcome_email_t
        pipelined
        deterministic
    is
        l_record welcome_email_row_t;
    begin
        for x in (
            select
                enrollment_id,
                first_name,
                last_name,
                email,
                decode(user_name,
                       null,
                       pc_users.get_user_name(pc_users.get_user(ssn, 'S')),
                       user_name)                        user_name,
                pc_users.check_user_registered(ssn, 'S') registered,
                acc_num,
                pc_users.is_confirmed(ssn, 'S')          confirmed,
                decode(
                    substr(acc_num, 1, 3),
                    'HRA',
                    'HRA',
                    'FSA',
                    'FSA',
                    'HSA'
                )                                        account_type,
                pc_entrp.get_acc_num(entrp_id)           employer_id
            from
                online_enrollment
            where
                acc_id is not null
                and acc_num is not null
                and enrollment_status = 'S'
                and batch_number = p_batch_number
                and nvl(fraud_flag, 'N') = 'N'
        ) loop
            l_record.enrollment_id := x.enrollment_id;
            l_record.first_name := x.first_name;
            l_record.last_name := x.last_name;
            l_record.email := x.email;
            l_record.user_name := x.user_name;
            l_record.registered := x.registered;
            l_record.acc_num := x.acc_num;
            l_record.confirmed := x.confirmed;
            l_record.account_type := x.account_type;
            l_record.employer_id := x.employer_id;
            pipe row ( l_record );
        end loop;
    end get_welcome_email;

    function get_not_enrolled_plans (
        p_batch_number in number
    ) return pending_plans_t
        pipelined
        deterministic
    is
        l_record_t pending_plans_row_t;
    begin
        pc_log.log_error('get_not_enrolled_plans', 'p_batch_number' || p_batch_number);
        for x in (
            select
                plan_type,
                pc_benefit_plans.get_plan_name(plan_type, er_ben_plan_id)  plan_type_meaning,
                to_char(to_date(effective_date), 'MM/DD/YYYY')             effective_date,
                annual_election,
                pc_lookups.get_meaning(qual_event_code, 'LIFE_EVENT_CODE') life_event_code,
                pc_lookups.get_meaning(pay_cycle, 'PAYROLL_FREQUENCY')     pay_cycle,
                first_payroll_date,
                pay_contrb,
                er_ben_plan_id
            from
                online_hfsa_enroll_stage
            where
                    batch_number = p_batch_number
                and pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') = 'FSA'
        ) loop
            pc_log.log_error('get_not_enrolled_plans', 'got rows');
            l_record_t.plan_type_meaning := x.plan_type_meaning;
            l_record_t.plan_type := x.plan_type;
            l_record_t.annual_election := x.annual_election;
            l_record_t.effective_date := x.effective_date;
            l_record_t.life_event_code := x.life_event_code;
            l_record_t.pay_cycle := x.pay_cycle;
            l_record_t.first_payroll_date := x.first_payroll_date;
            l_record_t.pay_contrb := x.pay_contrb;
            for xx in (
                select
                    plan_start_date,
                    plan_end_date
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = x.er_ben_plan_id
            ) loop
                l_record_t.plan_start_date := to_char(xx.plan_start_date, 'MM/DD/YYYY');
                l_record_t.plan_end_date := to_char(xx.plan_end_date, 'MM/DD/YYYY');
            end loop;

            pipe row ( l_record_t );
        end loop;

    end get_not_enrolled_plans;

    function is_stacked_account (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return varchar2 is
        l_stacked_flag varchar2(1) := 'N';
    begin
        if p_ssn is null then
            for x in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup plans,
                    enterprise                er,
                    account                   acc
                where
                        replace(er.entrp_code, '-') = replace(p_ein, '-')
                    and plans.entrp_id = er.entrp_id
                    and plans.entrp_id = acc.entrp_id
                    and acc.account_type = 'FSA'
                    and plans.plan_end_date > sysdate
                    and plans.status = 'A'
                    and pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA'
                    and ( plans.effective_end_date is null
                          or plans.effective_end_date > sysdate )
            ) loop
                if x.cnt > 0 then
                    l_stacked_flag := 'Y';
                end if;
            end loop;
        else
         -- Swamy 17/11/2020, For user cmtellez in DEV, when the user clicks the left side link of HSA account, the system was taking long time to load the HSA account summary page.
		 -- Hence commented the below conditions. This was fixed as part of Ticket#9332 though there is no connection between this fix and the developement of the Ticket#.
            for x in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup plans,
                    enterprise                er,
                    account                   acc
                where
                        replace(er.entrp_code, '-') = replace(p_ein, '-')
                    and plans.entrp_id = er.entrp_id
                    and plans.entrp_id = acc.entrp_id
                    and acc.account_type = 'FSA'
                    and plans.plan_end_date > sysdate
                    and plans.status = 'A'
                    and pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA'
                    and ( plans.effective_end_date is null
                          or plans.effective_end_date > sysdate )
                    and ( exists (
                        select
                            *
                        from
                            ben_plan_enrollment_setup d
                        where
                            d.acc_id = pc_account.get_acc_id_from_ssn(p_ssn, er.entrp_id)
                    ) )
            )
                                       /*AND     D.BEN_PLAN_ID_MAIN = plans.BEN_PLAN_ID)   -- Commented by Swamy as part of testing of Ticket#9332.
                   or       EXISTS (SELECT * FROM BEN_PLAN_ENROLLMENT_SETUP D
                                       WHERE   D.ACC_ID = PC_ACCOUNT.get_acc_id_from_ssn(P_SSN,ER.ENTRP_ID)
                                       AND     D.BEN_PLAN_ID_MAIN <> plans.BEN_PLAN_ID)) )*/ loop
                if x.cnt > 0 then
                    l_stacked_flag := 'Y';
                end if;
            end loop;
        end if;

        return l_stacked_flag;
    end is_stacked_account;

    function validate_dob_ssn (
        p_ssn in varchar2,
        p_dob in varchar2
    ) return varchar2 is
        l_flag       varchar2(1) := 'N';
        l_pers_count number := 0;
    begin
        pc_log.log_error('validate_dob_ssn: p_ssn ', p_ssn);
        pc_log.log_error('validate_dob_ssn: p_dob ', p_dob);
        select
            count(*)
        into l_pers_count
        from
            person
        where
                ssn = format_ssn(p_ssn)
            and person_type = 'SUBSCRIBER';

        if l_pers_count > 0 then
            for x in (
                select
                    count(*) cnt
                from
                    person
                where
                        ssn = format_ssn(p_ssn)
                    and birth_date = to_date(p_dob, 'MM/DD/YYYY')
                    and person_type = 'SUBSCRIBER'
            ) loop
                if x.cnt > 0 then
                    l_flag := 'Y';
                else
                    l_flag := 'N';
                end if;
            end loop;
        else
            l_flag := 'Y';
        end if;

        return l_flag;
    end validate_dob_ssn;

    function get_hra_ppc (
        p_cov_tier_name in varchar2,
        p_hire_date     in varchar2,
        p_ben_plan_id   in number
    ) return number is
        l_annual_election  number;
        l_new_hire_contrib varchar2(1);
        l_ppc              number;
    begin
        for x in (
            select
                nvl(new_hire_contrib, 'N') new_hire_contrib,
                bc.annual_election,
                bp.plan_start_date,
                bp.plan_end_date
            from
                ben_plan_enrollment_setup bp,
                ben_plan_coverages        bc
            where
                    bp.ben_plan_id = p_ben_plan_id
                and bp.ben_plan_id = bc.ben_plan_id
                and bc.coverage_tier_name = p_cov_tier_name
        ) loop
            if x.new_hire_contrib = 'PRORATE' then
                l_ppc := x.annual_election / round(months_between(x.plan_end_date, x.plan_start_date));

                l_annual_election := l_ppc * ( round(abs(months_between(x.plan_end_date, to_date(p_hire_date, 'MM/DD/YYYY')))) );

            else
                l_annual_election := x.annual_election;
                l_ppc := x.annual_election / round(abs(months_between(x.plan_end_date, x.plan_start_date)));

            end if;
        end loop;

        return l_annual_election;
    end get_hra_ppc;

    function get_approved_plans (
        p_entrp_id     in number,
        p_batch_number in number
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                pc_benefit_plans.get_plan_name(plans.plan_type, plans.ben_plan_id) plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(plans.effective_date, 'MM/DD/YYYY')                        effective_date,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY')                      plan_year,
                plans.plan_start_date,
                plans.plan_end_date
            from
                ben_plan_enrollment_setup plans,
                ben_plan_approvals        bpa
            where
                    bpa.entrp_id = p_entrp_id
                and bpa.batch_number = p_batch_number
                and plans.ben_plan_id = bpa.ben_plan_id
                and bpa.status = 'A'
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.effective_date := x.effective_date;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            pipe row ( l_benefit_plan_row );
        end loop;
    end get_approved_plans;

    function get_pending_plans (
        p_entrp_id in number
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                plans.plan_type_meaning,
                plans.plan_type,
                bpa.ben_plan_id                                         ben_plan_id,
                to_char(plans.effective_date, 'MM/DD/YYYY')             effective_date,
                nvl(plans.minimum_election, 0)                          minimum_election,
                nvl(plans.maximum_election, 0)                          maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY')           plan_year,
                plans.plan_start_date,
                plans.plan_end_date,
                bpa.product_type,
                bpa.annual_election,
                bpa.acc_id,
                bpa.runout_period_days,
                bpa.grace_period,
                to_char(plans.open_enrollment_start_date, 'MM/DD/YYYY') open_enrollment_start_date,
                to_char(plans.open_enrollment_end_date, 'MM/DD/YYYY')   open_enrollment_end_date
            from
                fsa_hra_er_ben_plans_v    plans,
                ben_plan_enrollment_setup bpa
            where
                    plans.entrp_id = p_entrp_id
                and plans.ben_plan_id = bpa.ben_plan_id_main
                and bpa.status = 'P'
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.effective_date := x.effective_date;
            l_benefit_plan_row.minimum_election := x.minimum_election;
            l_benefit_plan_row.maximum_election := x.maximum_election;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            l_benefit_plan_row.open_enroll_start_date := x.open_enrollment_start_date;
            l_benefit_plan_row.open_enroll_end_date := x.open_enrollment_end_date;
            l_benefit_plan_row.status := 'Pending Activation';
            l_benefit_plan_row.status_code := 'P';
            if x.product_type = 'HRA' then
                for xx in (
                    select
                        annual_election,
                        coverage_tier_name
                    from
                        ben_plan_coverages
                    where
                        ben_plan_id = x.ben_plan_id
                ) loop
                    l_benefit_plan_row.coverage_tier := xx.coverage_tier_name;
                    l_benefit_plan_row.annual_election := xx.annual_election;
                end loop;
            else
                l_benefit_plan_row.annual_election := x.annual_election;
            end if;

            for xx in (
                select distinct
                    pay_cycle,
                    first_payroll_date,
                    pay_contrb
                from
                    pay_details
                where
                        ben_plan_id = x.ben_plan_id
                    and acc_id = x.acc_id
            ) loop
                l_benefit_plan_row.pay_cycle := xx.pay_cycle;
                l_benefit_plan_row.first_payroll_date := xx.first_payroll_date;
                l_benefit_plan_row.pay_contrb := xx.pay_contrb;
            end loop;

            l_benefit_plan_row.acc_id := x.acc_id;
            l_benefit_plan_row.acc_num := pc_account.get_acc_num_from_acc_id(x.acc_id);
            pipe row ( l_benefit_plan_row );
        end loop;
    end get_pending_plans;

    function can_hra_submit_claim (
        p_acc_id in number
    ) return varchar2 is

        l_count      number := 0;
        l_entrp      number := 0;
        l_is_stacked varchar2(1) := 'N';
    begin

    -- Added by Swamy for Ticket#11504 17/03/2023
    -- For stacked account during claims it should check for all the plans in the stacked account
        for j in (
            select
                p.entrp_id
            from
                person  p,
                account a
            where
                    p.pers_id = a.pers_id
                and a.acc_id = p_acc_id
        ) loop
            l_entrp := j.entrp_id;
            l_is_stacked := pc_account.is_stacked_account(l_entrp);
        end loop;

        if nvl(l_is_stacked, 'N') = 'N' then   -- If Con.Added by Swamy for Ticket#11504 17/03/2023
            for x in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA'
                    and nvl(
                        trunc(effective_end_date),
                        plan_end_date
                    ) + nvl(runout_period_days, 0) + nvl(grace_period, 0) + 1 > sysdate
            ) loop
                l_count := x.cnt;
            end loop;

    -- Added by Swamy for Ticket#11504 17/03/2023
        else
            for x in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') in ( 'HRA', 'FSA' )
                    and nvl(
                        trunc(effective_end_date),
                        plan_end_date
                    ) + nvl(runout_period_days, 0) + nvl(grace_period, 0) + 1 > sysdate
            ) loop
                l_count := x.cnt;
            end loop;
        end if;

        if l_count = 0 then
            return 'N';
        else
            return 'Y';
        end if;
    end can_hra_submit_claim;

    function get_enrollment (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return enrollment_t
        pipelined
        deterministic
    is
        l_record enrollment_rec;
    begin
        for x in (
            select
                enrollment_id,
                first_name,
                last_name,
                middle_name,
                title,
                gender,
                to_char(birth_date, 'MM/DD/YYYY')                       birth_date,
                ssn,
                decode(id_type, 'D', 'Driver License', 'P', 'Passport') id_type,
                id_number,
                address,
                city,
                state,
                zip,
                phone,
                email,
                carrier_id,
                health_plan_eff_date,
                entrp_id,
                plan_type,
                deductible,
                ip_address,
                account_type,
                batch_number,
                user_name,
                password_reminder_question,
                password_reminder_answer,
                plan_code,
                debit_card_flag
            from
                online_enrollment
            where
                    batch_number = p_batch_number
                and ssn = p_ssn
        ) loop
            l_record.enrollment_id := x.enrollment_id;
            l_record.first_name := x.first_name;
            l_record.last_name := x.last_name;
            l_record.middle_name := x.middle_name;
            l_record.title := x.title;
            l_record.gender := x.gender;
            l_record.birth_date := x.birth_date;
            l_record.ssn := x.ssn;
            l_record.id_type := x.id_type;
            l_record.id_number := x.id_number;
            l_record.address := x.address;
            l_record.city := x.city;
            l_record.state := x.state;
            l_record.zip := x.zip;
            l_record.phone := x.phone;
            l_record.email := x.email;
            l_record.carrier_id := x.carrier_id;
            l_record.health_plan_eff_date := x.health_plan_eff_date;
            l_record.entrp_id := x.entrp_id;
            l_record.plan_type := x.plan_type;
            l_record.deductible := x.deductible;
            l_record.ip_address := x.ip_address;
            l_record.account_type := x.account_type;
            l_record.batch_number := x.batch_number;
            l_record.user_name := x.user_name;
            l_record.password_reminder_question := x.password_reminder_question;
            l_record.password_reminder_answer := x.password_reminder_answer;
            l_record.plan_code := x.plan_code;
            l_record.debit_card_flag := x.debit_card_flag;
            pipe row ( l_record );
        end loop;
    end get_enrollment;

    function get_enroll_plan (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return enroll_plan_t
        pipelined
        deterministic
    is
        l_record enroll_plan_rec;
    begin
        for x in (
            select
                enroll_stage_id,
                plan_type,
                effective_date,
                annual_election,
                pay_contrb,
                pay_cycle,
                covg_tier_name,
                deductible,
                qual_event_code,
                first_payroll_date
            from
                online_hfsa_enroll_stage
            where
                    batch_number = p_batch_number
                and ssn = p_ssn
        ) loop
            l_record.enroll_stage_id := x.enroll_stage_id;
            l_record.plan_type := x.plan_type;
            l_record.effective_date := x.effective_date;
            l_record.annual_election := x.annual_election;
            l_record.pay_contrb := x.pay_contrb;
            l_record.pay_cycle := x.pay_cycle;
            l_record.covg_tier_name := x.covg_tier_name;
            l_record.deductible := x.deductible;
            l_record.qual_event_code := x.qual_event_code;
            l_record.first_payroll_date := x.first_payroll_date;
            pipe row ( l_record );
        end loop;
    end get_enroll_plan;

    function get_beneficiary (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return beneficiary_t
        pipelined
        deterministic
    is
        l_record beneficiary_rec;
    begin
        for x in (
            select
                mass_enrollment_id,
                first_name,
                middle_name,
                last_name,
                gender,
                beneficiary_type,
                beneficiary_relation,
                effective_date,
                distiribution
            from
                mass_enroll_dependant
            where
                    dep_flag = 'BENEFICIARY'
                and batch_number = p_batch_number
                and subscriber_ssn = p_ssn
        ) loop
            l_record.mass_enrollment_id := x.mass_enrollment_id;
            l_record.first_name := x.first_name;
            l_record.middle_name := x.middle_name;
            l_record.last_name := x.last_name;
            l_record.gender := x.gender;
            l_record.beneficiary_type := x.beneficiary_type;
            l_record.beneficiary_relation := x.beneficiary_relation;
            l_record.effective_date := x.effective_date;
            l_record.distiribution := x.distiribution;
            pipe row ( l_record );
        end loop;
    end get_beneficiary;

    function get_dependent (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return dependent_t
        pipelined
        deterministic
    is
        l_record dependent_rec;
    begin
        for x in (
            select
                mass_enrollment_id,
                first_name,
                middle_name,
                last_name,
                gender,
                birth_date,
                ssn,
                dep_flag,
                debit_card_flag,
                account_type
            from
                mass_enroll_dependant
            where
                    dep_flag = 'DEPENDANT'
                and batch_number = p_batch_number
                and subscriber_ssn = p_ssn
        ) loop
            l_record.mass_enrollment_id := x.mass_enrollment_id;
            l_record.first_name := x.first_name;
            l_record.middle_name := x.middle_name;
            l_record.last_name := x.last_name;
            l_record.gender := x.gender;
            l_record.birth_date := x.birth_date;
            l_record.dep_flag := x.dep_flag;
            l_record.debit_card_flag := x.debit_card_flag;
            l_record.account_type := x.account_type;
            pipe row ( l_record );
        end loop;
    end get_dependent;

    function show_enroll_plan (
        p_user_id in number
    ) return varchar2 is
    begin
        for x in (
            select
                b.entrp_id,
                (
                    select
                        count(*)
                    from
                        table ( pc_enroll_utility_pkg.get_ee_plan_open_enroll(
                            pc_entrp.get_tax_id(b.entrp_id),
                            b.ssn
                        ) )
                )                                     plan_count,
                pc_entrp.allow_exp_enroll(b.entrp_id) allow_enroll
            from
                online_users a,
                person       b,
                account      c
            where
                    user_id = p_user_id
                and a.tax_id = replace(b.ssn, '-')
                and c.pers_id = b.pers_id
                and c.account_type in ( 'HRA', 'FSA' )
        ) loop
            if
                x.plan_count > 0
                and x.allow_enroll = 'Y'
            then
                return 'Y';
            end if;
        end loop;
    -- IN CASE THE USER IS INACTIVATED BUT REJOINS AS NEW HIRE THEN WE WILL HAVE TO OPEN THIS UP
        for x in (
            select
                b.entrp_id,
                (
                    select
                        count(*)
                    from
                        ben_plan_enrollment_setup d
                    where
                            c.acc_id = d.acc_id
                        and d.status = 'A'
                        and effective_end_date is null
                        and plan_end_date > sysdate
                )                                     plan_count,
                pc_entrp.allow_exp_enroll(b.entrp_id) allow_enroll
            from
                online_users a,
                person       b,
                account      c
            where
                    user_id = p_user_id
                and a.tax_id = replace(b.ssn, '-')
                and c.pers_id = b.pers_id
                and c.account_type in ( 'HRA', 'FSA' )
        ) loop
            if
                x.plan_count = 0
                and x.allow_enroll = 'Y'
            then
                return 'Y';
            else
                return 'N';
            end if;
        end loop;

        return 'N';
    end show_enroll_plan;

    function get_enroll_detail_from_user (
        p_user_id in number
    ) return person_user_t
        pipelined
        deterministic
    is
        l_record person_user_row_t;
    begin
        for x in (
            select
                b.entrp_id,
                pc_entrp.get_tax_id(b.entrp_id)     ein,
                b.ssn,
                to_char(b.birth_date, 'MM/DD/YYYY') birth_date,
                c.acc_id,
                pc_entrp.get_acc_id(b.entrp_id)     er_acc_id
            from
                online_users a,
                person       b,
                account      c
            where
                    user_id = p_user_id
                and a.tax_id = replace(b.ssn, '-')
                and c.pers_id = b.pers_id
                and c.account_type in ( 'HRA', 'FSA' )
        ) loop
            l_record.entrp_id := x.entrp_id;
            l_record.ein := x.ein;
            l_record.ssn := x.ssn;
            l_record.birth_date := x.birth_date;
            l_record.stacked_account := is_stacked_account(x.ein, x.ssn);
            l_record.acc_id := x.acc_id;
            l_record.er_acc_id := x.er_acc_id;
        end loop;

        pipe row ( l_record );
    end get_enroll_detail_from_user;

    function get_ee_plan_open_enroll (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                plans.plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(
                    greatest(plans.effective_date, plans.plan_start_date),
                    'MM/DD/YYYY'
                )                                                       effective_date,
                nvl(plans.minimum_election, 0)                          minimum_election,
                case
                    when plans.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                        nvl(plans.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plans.plan_type, sysdate) * 12)
                    else
                        nvl(plans.maximum_election, 0)
                end                                                     maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY')           plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')            plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')              plan_end_date,
                to_char(plans.open_enrollment_start_date, 'MM/DD/YYYY') open_enrollment_start_date,
                to_char(plans.open_enrollment_end_date, 'MM/DD/YYYY')   open_enrollment_end_date
            from
                fsa_hra_er_ben_plans_v plans,
                enterprise             er
            where
                    replace(er.entrp_code, '-') = replace(p_ein, '-')
                and plans.entrp_id = er.entrp_id
                and plans.plan_end_date > sysdate
                and plans.status = 'A'
                and plans.plan_type not in ( 'NDT', 'RENEW', 'COMP_POP', 'BASIC_POP' ) /* Ticket 2739 */
                and plans.open_enrollment_start_date <= trunc(sysdate)
                and trunc(plans.open_enrollment_end_date) >= trunc(sysdate)
        --     AND     plans.plan_type NOT IN ('HRA','HRP','HR5','HR4','ACO')
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
                and not exists (
                    select
                        *
                    from
                        account                   a,
                        person                    b,
                        ben_plan_enrollment_setup c
                    where
                            a.pers_id = b.pers_id
                        and a.account_type in ( 'HRA', 'FSA' )
                        and a.acc_id = c.acc_id
                        and c.ben_plan_id_main = plans.ben_plan_id
                        and b.ssn = format_ssn(p_ssn)
                )
            union
            select
                plans.plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                to_char(
                    greatest(plans.effective_date, plans.plan_start_date),
                    'MM/DD/YYYY'
                )                                                       effective_date,
                nvl(plans.minimum_election, 0)                          minimum_election,
                case
                    when plans.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                        nvl(plans.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plans.plan_type, sysdate) * 12)
                    else
                        nvl(plans.maximum_election, 0)
                end                                                     maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY')           plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')            plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')              plan_end_date,
                to_char(plans.open_enrollment_start_date, 'MM/DD/YYYY') open_enrollment_start_date,
                to_char(plans.open_enrollment_end_date, 'MM/DD/YYYY')   open_enrollment_end_date
            from
                fsa_hra_er_ben_plans_v plans,
                enterprise             er
            where
                    replace(er.entrp_code, '-') = replace(p_ein, '-')
                and plans.entrp_id = er.entrp_id
                and plans.plan_end_date > sysdate
                and plans.status = 'A'
                and plans.plan_type not in ( 'NDT', 'RENEW', 'COMP_POP', 'BASIC_POP' ) /* Ticket 2739 */
                and plans.open_enrollment_start_date <= trunc(sysdate)
                and trunc(plans.open_enrollment_end_date) >= trunc(sysdate)
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
                and exists (
                    select
                        *
                    from
                        account                   a,
                        person                    b,
                        ben_plan_enrollment_setup c
                    where
                            a.pers_id = b.pers_id
                        and a.account_type in ( 'HRA', 'FSA' )
                        and a.acc_id = c.acc_id
                        and c.status = 'R' -- we want to show ER rejected plans as well as ER could have rejected by mistake
                        and c.ben_plan_id_main = plans.ben_plan_id
                        and b.ssn = format_ssn(p_ssn)
                )
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.effective_date := x.effective_date;
            l_benefit_plan_row.minimum_election := x.minimum_election;
            l_benefit_plan_row.maximum_election := x.maximum_election;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            l_benefit_plan_row.open_enroll_start_date := x.open_enrollment_start_date;
            l_benefit_plan_row.open_enroll_end_date := x.open_enrollment_end_date;
            pipe row ( l_benefit_plan_row );
        end loop;
    end get_ee_plan_open_enroll;

    function get_er_benefit_plan (
        p_entrp_id     in number,
        p_product_type in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic
    is
        l_benefit_plan_row benefit_plan_row_t;
    begin
        for x in (
            select
                plans.plan_type_meaning,
                plans.plan_type,
                plans.ben_plan_id,
                plans.minimum_election,
                case
                    when plans.plan_type in ( 'TRN', 'PKG' ) then
                        nvl(plans.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plans.plan_type, sysdate) * 12)
                    else
                        nvl(plans.maximum_election, 0)
                end                                           maximum_election,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(plans.plan_end_date, 'MM/DD/YYYY') plan_year,
                to_char(plans.plan_start_date, 'MM/DD/YYYY')  plan_start_date,
                to_char(plans.plan_end_date, 'MM/DD/YYYY')    plan_end_date,
                plans.runout_period_days,
                plans.grace_period,
                plans.product_type
            from
                fsa_hra_er_ben_plans_v plans
            where
                    plans.entrp_id = p_entrp_id
                and plans.plan_end_date > sysdate
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
                and plans.status = 'A'
                and plans.product_type = p_product_type
        ) loop
            l_benefit_plan_row.plan_name := x.plan_type_meaning;
            l_benefit_plan_row.plan_type := x.plan_type;
            l_benefit_plan_row.plan_id := x.ben_plan_id;
            l_benefit_plan_row.plan_year := x.plan_year;
            l_benefit_plan_row.plan_start_date := x.plan_start_date;
            l_benefit_plan_row.plan_end_date := x.plan_end_date;
            l_benefit_plan_row.runout_period_days := nvl(x.runout_period_days, 0);
            l_benefit_plan_row.grace_period := nvl(x.grace_period, 0);
            if x.product_type = 'HRA' then
                for xx in (
                    select
                        annual_election,
                        coverage_tier_name
                    from
                        ben_plan_coverages
                    where
                        ben_plan_id = x.ben_plan_id
                ) loop
                    l_benefit_plan_row.coverage_tier := xx.coverage_tier_name;
                    l_benefit_plan_row.maximum_election := xx.annual_election;
                    pipe row ( l_benefit_plan_row );
                end loop;
            else
                l_benefit_plan_row.minimum_election := x.minimum_election;
                l_benefit_plan_row.maximum_election := x.maximum_election;
                pipe row ( l_benefit_plan_row );
            end if;

        end loop;
    end get_er_benefit_plan;

    function get_acc_id_from_ssn (
        p_ssn          in varchar2,
        p_product_type in varchar2
    ) return number is
        l_acc_id number;
    begin
        for x in (
            select
                a.acc_id
            from
                account a,
                person  b
            where
                    a.account_type = p_product_type
                and a.pers_id = b.pers_id
                and b.ssn = format_ssn(p_ssn)
        ) loop
            l_acc_id := x.acc_id;
        end loop;

        return l_acc_id;
    end get_acc_id_from_ssn;
 /*
  FUNCTION get_pay_frequency(p_acc_num IN VARCHAR2) RETURN  lookup_t PIPELINED DETERMINISTIC
 IS
    l_record lookup_row_t;
    l_entrp_id NUMBER;
    l_exists   VARCHAR2(1):='N';
 BEGIN
    FOR X IN (SELECT P.entrp_id FROM ACCOUNT AC,PERSON P WHERE AC.PERS_ID=P.PERS_ID
              AND AC.ACC_NUM= p_acc_num)
    LOOP
        l_entrp_id := X.ENTRP_ID;
    END LOOP;
       pc_log.log_error('calculate_pay_period,l_entrp_id',l_entrp_id);

  //  IF l_entrp_id IS NOT NULL THEN
	 //   FOR X IN (SELECT NAME FROM PAY_CYCLE
	 //             WHERE entrp_id = l_entrp_id
	//	      AND STATUS = 'A'
	//	      AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
	//	      AND TRUNC(END_DATE) >= TRUNC(SYSDATE))
	//    LOOP
//		 l_record.LOOKUP_CODE := X.NAME;
//		 l_record.DESCRIPTION := X.NAME;

  //                PIPE ROW(l_record);
		// l_exists := 'Y';
      //      pc_log.log_error('calculate_pay_period,X.NAME',X.NAME);

	   // END LOOP;
    //END IF;
    IF l_exists = 'N' THEN
    	    FOR X IN (select lookup_code , meaning from lookups
	              where lookup_name = 'PAYROLL_FREQUENCY'
	                AND LOOKUP_CODE NOT IN ('TWICE_A_WEEK','ONCE','BIANNUALLY'))
            LOOP
                 l_record.LOOKUP_CODE := X.lookup_code;
                 l_record.DESCRIPTION := X.meaning;
                  PIPE ROW(l_record);

	    END LOOP;

    END IF;
 END get_pay_frequency;
 */
 /*  FUNCTION get_pay_frequency(p_acc_num IN VARCHAR2) RETURN  pay_freq_t PIPELINED DETERMINISTIC
 IS
    l_record pay_freq_rec;
    l_entrp_id NUMBER;
    l_exists   VARCHAR2(1):='N';
 BEGIN
    FOR X IN (SELECT P.entrp_id FROM ACCOUNT AC,PERSON P WHERE AC.PERS_ID=P.PERS_ID
              AND AC.ACC_NUM= p_acc_num)
    LOOP
        l_entrp_id := X.ENTRP_ID;
    END LOOP;
       pc_log.log_error('calculate_pay_period,l_entrp_id',l_entrp_id);
    IF l_entrp_id IS NOT NULL THEN
	    FOR X IN (SELECT distinct SCHEDULER_NAME NAME ,SCHEDULER_ID ,FREQUENCY,PAYMENT_START_DATE START_DATE,PAYMENT_END_DATE END_DATE
                FROM PAYROLL_CALENDAR
	              WHERE entrp_id = l_entrp_id
		            AND TRUNC(PAYMENT_START_DATE) <= TRUNC(SYSDATE)
		            AND TRUNC(PAYMENT_END_DATE) >= TRUNC(SYSDATE))
	    LOOP

            l_record.name := x.NAME;
            l_record.SCHEDULER_ID := x.SCHEDULER_ID;
            l_record.FREQUENCY := x.FREQUENCY;
            l_record.START_DATE := to_char(x.START_DATE,'MM/DD/YYYY');
            l_record.END_DATE := to_char(x.END_DATE,'MM/DD/YYYY');

            l_record.entrp_id := l_entrp_id;

            PIPE ROW(l_record);
	        	 l_exists := 'Y';
            pc_log.log_error('calculate_pay_period,X.NAME',X.NAME);

	    END LOOP;
    END IF;
    IF l_exists = 'N' THEN
    	  FOR X IN (SELECT distinct SCHEDULER_NAME NAME ,SCHEDULER_ID ,FREQUENCY,PAYMENT_START_DATE START_DATE,PAYMENT_END_DATE END_DATE
                FROM PAYROLL_CALENDAR
	              WHERE entrp_id is null
		            AND TRUNC(PAYMENT_START_DATE) <= TRUNC(SYSDATE)
		            AND TRUNC(PAYMENT_END_DATE) >= TRUNC(SYSDATE))
	    LOOP

            l_record.name := x.NAME;
            l_record.SCHEDULER_ID := x.SCHEDULER_ID;
            l_record.FREQUENCY := x.FREQUENCY;
            l_record.START_DATE := to_char(x.START_DATE,'MM/DD/YYYY');
            l_record.END_DATE := to_char(x.END_DATE,'MM/DD/YYYY');

            PIPE ROW(l_record);
	        	 l_exists := 'Y';
            pc_log.log_error('calculate_pay_period,X.NAME',X.NAME);

	    END LOOP;

    END IF;
 END get_pay_frequency;*/
    function get_pay_frequency (
        p_acc_num in varchar2
    ) return pay_freq_t
        pipelined
        deterministic
    is
        l_record   pay_freq_rec;
        l_entrp_id number;
        l_exists   varchar2(1) := 'N';
    begin
        for x in (
            select
                p.entrp_id
            from
                account ac,
                person  p
            where
                    ac.pers_id = p.pers_id
                and ac.acc_num = p_acc_num
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        pc_log.log_error('calculate_pay_period,l_entrp_id', l_entrp_id);
        if l_entrp_id is not null then
            for x in (
                select distinct
                    scheduler_name     name,
                    scheduler_id,
                    frequency,
                    payment_start_date start_date,
                    payment_end_date   end_date
                from
                    payroll_calendar
                where
                        entrp_id = l_entrp_id
                    and trunc(payment_end_date) >= trunc(sysdate)
            ) loop
                l_record.name := x.name;
                l_record.scheduler_id := x.scheduler_id;
                l_record.frequency := x.frequency;
                l_record.start_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.end_date := to_char(x.end_date, 'MM/DD/YYYY');
                l_record.entrp_id := l_entrp_id;
                pipe row ( l_record );
                l_exists := 'Y';
                pc_log.log_error('calculate_pay_period,X.NAME', x.name);
            end loop;
        end if;

        if l_exists = 'N' then
            for x in (
                select distinct
                    scheduler_name     name,
                    scheduler_id,
                    frequency,
                    payment_start_date start_date,
                    payment_end_date   end_date
                from
                    payroll_calendar pcr
                where
                    entrp_id is null
                    and trunc(payment_end_date) >= trunc(sysdate)
                    and not exists (
                        select
                            *
                        from
                            payroll_calendar pc
                        where
                                pc.entrp_id = l_entrp_id
                            and trunc(pc.payment_start_date) = trunc(pcr.payment_start_date)
                            and trunc(pc.payment_end_date) = trunc(pcr.payment_end_date)
                    )
            ) loop
                l_record.name := x.name;
                l_record.scheduler_id := x.scheduler_id;
                l_record.frequency := x.frequency;
                l_record.start_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.end_date := to_char(x.end_date, 'MM/DD/YYYY');
                l_exists := 'Y';
                pipe row ( l_record );
                pc_log.log_error('calculate_pay_period,X.NAME', x.name);
            end loop;
        end if;

    end get_pay_frequency;

    function get_er_pay_frequency (
        p_ein in varchar2
    ) return pay_freq_t
        pipelined
        deterministic
    is
        l_record   pay_freq_rec;
        l_entrp_id number;
        l_exists   varchar2(1) := 'N';
    begin
        l_entrp_id := pc_entrp.get_entrp_id_from_ein_act(p_ein, 'FSA');
        pc_log.log_error('calculate_pay_period,l_entrp_id', l_entrp_id);
        if l_entrp_id is not null then
            for x in (
                select distinct
                    scheduler_name     name,
                    scheduler_id,
                    frequency,
                    payment_start_date start_date,
                    payment_end_date   end_date
                from
                    payroll_calendar
                where
                        entrp_id = l_entrp_id
                    and trunc(payment_end_date) >= trunc(sysdate)
            ) loop
                l_record.name := x.name;
                l_record.scheduler_id := x.scheduler_id;
                l_record.frequency := x.frequency;
                l_record.start_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.end_date := to_char(x.end_date, 'MM/DD/YYYY');
                l_record.entrp_id := l_entrp_id;
                l_exists := 'Y';
                pipe row ( l_record );
                pc_log.log_error('calculate_pay_period,X.NAME', x.name);
            end loop;
        end if;

        if l_exists = 'N' then
            for x in (
                select distinct
                    scheduler_name     name,
                    scheduler_id,
                    frequency,
                    payment_start_date start_date,
                    payment_end_date   end_date
                from
                    payroll_calendar pcr
                where
                    entrp_id is null
                    and trunc(payment_end_date) >= trunc(sysdate)
                    and not exists (
                        select
                            *
                        from
                            payroll_calendar pc
                        where
                                pc.entrp_id = l_entrp_id
                            and trunc(pc.payment_start_date) = trunc(pcr.payment_start_date)
                            and trunc(pc.payment_end_date) = trunc(pcr.payment_end_date)
                    )
            ) loop
                l_record.name := x.name;
                l_record.scheduler_id := x.scheduler_id;
                l_record.frequency := x.frequency;
                l_record.start_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.end_date := to_char(x.end_date, 'MM/DD/YYYY');
                pipe row ( l_record );
                pc_log.log_error('calculate_pay_period,X.NAME', x.name);
            end loop;
        end if;

    end get_er_pay_frequency;

-- Added by Joshi for Webform enrollment
    function get_acc_id_from_ssn (
        p_ssn          in varchar2,
        p_ein          in varchar2,
        p_product_type in varchar2
    ) return number is
        l_acc_id number;
    begin
        for x in (
            select
                a.acc_id
            from
                employees_v a,
                person      b,
                enterprise  e
            where
                    a.account_type = p_product_type
                and a.pers_id = b.pers_id
                and b.ssn = format_ssn(p_ssn)
                and a.entrp_id = e.entrp_id
                and replace(e.entrp_code, '-') = replace(p_ein, '-')
        ) loop
            l_acc_id := x.acc_id;
        end loop;

        return l_acc_id;
    end get_acc_id_from_ssn;

-- Added by Joshi for Webform Enrollment
    function validate_ssn_plan (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return validate_ssn_rec_t
        pipelined
        deterministic
    is

        l_ssn_count             number;
        l_ssn_exist             varchar2(1);
        l_all_plans_enrolled    varchar2(1);
        l_active_plan_exist     varchar2(1);
        l_not_enrolled_count    number;
        l_active_plans_count    number;
        l_inactive_cur_plan_cnt number;
        l_validate_ssn_rec      validate_ssn_rec;
        l_debitcard_count       number;
    begin
        l_validate_ssn_rec.error_status := 'S';
        select
            count(*)
        into l_ssn_count
        from
            person     p,
            enterprise e
        where
                p.entrp_id = e.entrp_id
            and p.person_type = 'SUBSCRIBER'
            and replace(e.entrp_code, '-') = replace(p_ein, '-')
            and format_ssn(p.ssn) = p_ssn;

--Check if ER has active plans.
        select
            decode(
                count(*),
                0,
                'N',
                'Y'
            )
        into l_active_plan_exist
        from
            fsa_hra_er_ben_plans_v plans,
            enterprise             er
        where
                replace(er.entrp_code, '-') = replace(p_ein, '-')
            and plans.entrp_id = er.entrp_id
            and plans.plan_end_date > sysdate
            and plans.status = 'A'
            and plans.plan_type not in ( 'NDT', 'RENEW', 'COMP_POP', 'BASIC_POP' )
            and ( plans.effective_end_date is null
                  or plans.effective_end_date > sysdate );

        if l_active_plan_exist = 'N' then
            l_validate_ssn_rec.error_message := 'Employer has no active plans';
            l_validate_ssn_rec.error_status := 'E';
        else
            if l_ssn_count > 0 then
      -- check if Debit card already exist
                select
                    count(*)
                into l_debitcard_count
                from
                    person     p,
                    card_debit c
                where
                        p.pers_id = c.card_id
                    and p.person_type = 'SUBSCRIBER'
                    and format_ssn(p.ssn) = p_ssn;

                if l_debitcard_count > 0 then
                    l_validate_ssn_rec.debitcard_exist := 'Y';
                else
                    l_validate_ssn_rec.debitcard_exist := 'N';
                end if;

                l_validate_ssn_rec.ssn_exists := 'Y';
      --Check if EE is enrolled to all Plans offered by ER.
                select
                    count(*)
                into l_not_enrolled_count
                from
                    fsa_hra_er_ben_plans_v plans,
                    enterprise             er
                where
                        replace(er.entrp_code, '-') = replace(p_ein, '-')
                    and plans.entrp_id = er.entrp_id
                    and plans.plan_end_date > sysdate
                    and plans.status = 'A'
                    and plans.plan_type not in ( 'NDT', 'RENEW', 'COMP_POP', 'BASIC_POP' )
                    and ( plans.effective_end_date is null
                          or plans.effective_end_date > sysdate )
                    and not exists (
                        select
                            *
                        from
                            account                   a,
                            person                    b,
                            ben_plan_enrollment_setup c
                        where
                                a.pers_id = b.pers_id
                            and a.account_type in ( 'HRA', 'FSA' )
                            and a.acc_id = c.acc_id
                            and c.ben_plan_id_main = plans.ben_plan_id
                            and b.ssn = format_ssn(p_ssn)
                    );

                if l_not_enrolled_count = 0 then
      -- Check EE If any plans are inactive for current year.
                    select
                        count(*)
                    into l_inactive_cur_plan_cnt
                    from
                        account                   a,
                        person                    b,
                        ben_plan_enrollment_setup c
                    where
                            a.pers_id = b.pers_id
                        and b.person_type = 'SUBSCRIBER'
                        and a.account_type in ( 'HRA', 'FSA' )
                        and a.acc_id = c.acc_id
                        and b.ssn = format_ssn(p_ssn)
                        and c.status = 'I'
                        and nvl(
                            trunc(effective_end_date),
                            plan_end_date
                        ) + nvl(runout_period_days, 0) + nvl(grace_period, 0) + 1 > sysdate;

                    if l_inactive_cur_plan_cnt > 0 then
                        l_validate_ssn_rec.error_message := 'This Employee is not eligible for enrollment in your benefit plan(s) because the benefit plan'
                                                            || ' was inactivated/terminated within plan year and/or there are not any available benefit plans to enroll at this time.'
                                                            || ' Please contact us for further assistance';
                        l_validate_ssn_rec.error_status := 'E';
                    else
                        l_validate_ssn_rec.error_message := 'This Employee is already enrolled in all of the benefit plans you offer'
                        ;
                        l_validate_ssn_rec.error_status := 'E';
                    end if;

                else
                    l_validate_ssn_rec.active_plan_exist := 'Y';
                end if;

            else
                l_validate_ssn_rec.ssn_exists := 'N';
                l_validate_ssn_rec.debitcard_exist := 'N';
    -- check if EE belongs to other ER and have active plans.
                select
                    count(*)
                into l_active_plans_count
                from
                    account                   a,
                    person                    b,
                    ben_plan_enrollment_setup c
                where
                        a.pers_id = b.pers_id
                    and b.person_type = 'SUBSCRIBER'
                    and a.account_type in ( 'HRA', 'FSA' )
                    and a.acc_id = c.acc_id
                    and b.ssn = format_ssn(p_ssn)
                    and c.status = 'A'
                    and nvl(
                        trunc(effective_end_date),
                        plan_end_date
                    ) + nvl(runout_period_days, 0) + nvl(grace_period, 0) + 1 > sysdate;

                if l_active_plans_count > 0 then
                    l_validate_ssn_rec.error_message := 'This Employee is not eligible for enrollment in your benefit plan(s). Please contact us for further assistance'
                    ;
                    l_validate_ssn_rec.error_status := 'E';
                end if;

                l_validate_ssn_rec.active_plan_exist := 'Y';
            end if;
        end if;

        pipe row ( l_validate_ssn_rec );
    end validate_ssn_plan;

-- GA  ----jaggi 30/07/2020 9141
    function validate_ein (
        p_ein in varchar2
    ) return employer_ein_record_t
        pipelined
        deterministic
    is

        l_record                 employer_ein_row_t;
        l_count                  number;
        l_ga_count               number;
        l_not_enrolled_product   number;
        l_error_flag             varchar2(1);
        l_error_message          varchar2(255);
        l_not_registered_product number;
    begin
        l_record.ein := p_ein;
        l_record.error_flag := 'S';
        l_record.error_message := 'Successfull';
        select
            count(*)
        into l_count
        from
            enterprise a,
            account    b
        where
                entrp_code = p_ein
            and a.entrp_id = b.entrp_id;

    -- new EIN. so registration should be allowed     --- case 1
        if l_count = 0 then
            l_record.error_flag := 'S';
            l_record.error_message := 'Successfull';
        end if;

        select
            count(*)
        into l_not_registered_product
        from
            table ( pc_users.get_er_not_enrolled_plans(p_ein) )
        where
            acc_id is null;

        if
            l_count > 0
            and l_not_registered_product = 0
        then  --- case 2
            l_record.error_flag := 'E';
            l_record.error_message := 'All products are registered for this employer';
        end if;

        pipe row ( l_record );
    end validate_ein;

end pc_enroll_utility_pkg;
/

