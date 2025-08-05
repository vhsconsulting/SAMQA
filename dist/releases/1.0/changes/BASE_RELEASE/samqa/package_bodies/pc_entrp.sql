-- liquibase formatted sql
-- changeset SAMQA:1754374026837 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_entrp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_entrp.sql:null:aab9685218895a4696f36025a4673439345b7c25:create

create or replace package body samqa.pc_entrp is

-- ??? ??.??????????? ?????????? ???-?? ????? ? ??? ??????????????????
    function count_person (
        entrp_id_in in enterprise.entrp_id%type
    ) return number is

        cursor c1 (
            p_entrp_id enterprise.entrp_id%type
        ) is
        select
            count(1) c
        from
            person a
        where
            entrp_id = p_entrp_id;

        r1 c1%rowtype;
    begin
        open c1(entrp_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_person;

    function card_allowed (
        entrp_id_in in number
    ) return number is
        l_card_allowed number;
    begin
        for x in (
            select
                card_allowed
            from
                enterprise
            where
                entrp_id = entrp_id_in
        ) loop
            l_card_allowed := x.card_allowed;
        end loop;

        return l_card_allowed;
    end card_allowed;

    function count_active_person (
        entrp_id_in    in enterprise.entrp_id%type,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null
    ) return number is

        cursor c1 (
            p_entrp_id enterprise.entrp_id%type
        ) is
        select
            count(1) c
        from
            person  a,
            account b
        where
                a.entrp_id = p_entrp_id
            and a.pers_id = b.pers_id
            and b.account_status <> 4;

        l_count number := 0;
    begin
        if p_account_type in ( 'HSA', 'LSA' ) then    -- LSA Added by Swamy for Ticket#9912 (10221) on 20/08/2021
            open c1(entrp_id_in);
            fetch c1 into l_count;
            close c1;
        elsif p_account_type = 'COBRA' then
            select
                count(distinct pe.pers_id)
            into l_count
            from
                plan_elections pe,
                person         a
            where
                pe.status in ( 'PR', 'P', 'E' )
                and a.pers_id = pe.pers_id
                and a.entrp_id = entrp_id_in;

        else
            for x in (
                select
                    count(distinct(e.acc_id)) cnt
                from
                    person                    d,
                    account                   k,
                    enterprise                b,
                    ben_plan_enrollment_setup e
                where
                        d.pers_id = k.pers_id
                    and d.entrp_id = b.entrp_id
                    and k.acc_id = e.acc_id
                    and d.entrp_id = entrp_id_in
                    and e.plan_type = nvl(p_plan_type, e.plan_type)
                    /*If Plan type is not passed it calculates for all plans */
                    --AND E.STATUS                                                       = 'A'
                   -- AND e.plan_start_date                                             <= SYSDATE
                    and e.plan_end_date + nvl(grace_period, 0) + nvl(runout_period_days, 0) >= sysdate
                    and ( e.effective_end_date + nvl(runout_period_days, 0) > sysdate
                          or e.effective_end_date is null )
                      -- AND NVL(e.effective_date,SYSDATE)                                  <= SYSDATE
                    and k.account_type = p_account_type
                group by
                    d.entrp_id
            ) loop
                l_count := x.cnt;
            end loop;
        end if;

        return l_count;
    end count_active_person;

    function count_person_status (
        entrp_id_in in enterprise.entrp_id%type,
        p_status    in number
    ) return number is

        cursor c1 (
            p_entrp_id enterprise.entrp_id%type
        ) is
        select
            count(1) c
        from
            person  a,
            account b
        where
                a.entrp_id = p_entrp_id
            and a.pers_id = b.pers_id
            and b.account_status = p_status;

        r1 c1%rowtype;
    begin
        open c1(entrp_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_person_status;

    function get_entrp_id (
        p_acc_num in varchar2
    ) return number is
        l_entrp_id number;
    begin
        for x in (
            select
                entrp_id
            from
                account
            where
                acc_num = p_acc_num
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        return l_entrp_id;
    exception
        when others then
            null;
    end;

    function get_entrp_id_from_name (
        p_entrp_name in varchar2
    ) return number is
        l_entrp_id number;
    begin
        select
            entrp_id
        into l_entrp_id
        from
            enterprise
        where
            upper(replace(
                strip_bad(name),
                ' ',
                ''
            )) = upper(replace(
                strip_bad(p_entrp_name),
                ' ',
                ''
            ));

        return l_entrp_id;
    exception
        when others then
            return null;
    end;

    function get_acc_num (
        p_entrp_id in number
    ) return varchar2 is
        l_acc_num varchar2(3200);
    begin
        select
            acc_num
        into l_acc_num
        from
            account
        where
            entrp_id = p_entrp_id;

        return l_acc_num;
    exception
        when others then
            return null;
    end;

    function get_bps_acc_num (
        p_entrp_id in number
    ) return varchar2 is
        l_acc_num varchar2(3200);
    begin
        select
            bps_acc_num
        into l_acc_num
        from
            account
        where
            entrp_id = p_entrp_id;

        return l_acc_num;
    exception
        when others then
            return null;
    end;

    function get_bps_acc_num_from_acc_id (
        p_acc_id in number
    ) return varchar2 is
        l_acc_num varchar2(3200);
    begin
        select
            a.bps_acc_num
        into l_acc_num
        from
            account a,
            account b,
            person  c
        where
                b.acc_id = p_acc_id
            and c.pers_id = b.pers_id
            and c.entrp_id = a.entrp_id
            and a.account_status = 1;

        return l_acc_num;
    exception
        when others then
            return null;
    end;

    function get_entrp_name (
        p_entrp_id in number
    ) return varchar2 is
        l_name varchar2(3200);
    begin
        select
            name
        into l_name
        from
            enterprise
        where
            entrp_id = p_entrp_id;

        return l_name;
    exception
        when others then
            return null;
    end;

    procedure end_date_employer is
    begin
      -- End Date employers who does not have contribution
      -- for 2 years and all employees closed the accounts

        for x in (
            select
                e.acc_num,
                f.name,
                e.entrp_id
            from
                account    e,
                enterprise f
            where
                e.entrp_id is not null
                and e.end_date is null
                and e.entrp_id = f.entrp_id
                and e.account_type = 'HSA'
                and not exists (
                    select
                        *
                    from
                        income
                    where
                            contributor = e.entrp_id
                        and fee_date > trunc(trunc(sysdate, 'YYYY') - 365 * 2,
                                             'YYYY')
                )
                and e.start_date < trunc(trunc(sysdate, 'YYYY') - 365 * 2,
                                         'YYYY')
                and pc_entrp.count_person(e.entrp_id) = (
                    select
                        count(*)
                    from
                        person  a,
                        account b
                    where
                            a.entrp_id = e.entrp_id
                        and a.pers_id = b.pers_id
                        and b.account_status = 4
                )
        ) loop
            update account
            set
                end_date = sysdate,
                account_status = 4,
                last_update_date = sysdate,
                last_updated_by = 0,
                note = note || ', End dated employer for no activity '
            where
                    acc_num = x.acc_num
                and entrp_id = x.entrp_id
                and entrp_id is not null
                and account_type = 'HSA';
        /*UPDATE PERSON
        SET    ENTRP_ID = NULL
            ,   LAST_UPDATE_DATE = SYSDATE
            ,   LAST_UPDATED_BY = 0
            ,   NOTE = NOTE ||', Employer end dated so detaching the employees '
        WHERE ENTRP_ID = C.ENTRP_ID;*/
        end loop;
     -- End Date employers who does not have contribution
      -- for 2 years

        for x in (
            select
                e.acc_num,
                f.name,
                e.entrp_id
            from
                account    e,
                enterprise f
            where
                e.entrp_id is not null
                and e.end_date is null
                and e.entrp_id = f.entrp_id
                and e.account_type = 'HSA'
                and not exists (
                    select
                        *
                    from
                        income
                    where
                            contributor = e.entrp_id
                        and fee_date > trunc(trunc(sysdate, 'YYYY') - 365 * 2,
                                             'YYYY')
                )
                and e.start_date < trunc(trunc(sysdate, 'YYYY') - 365 * 2,
                                         'YYYY')
        ) loop
            update account
            set
                end_date = sysdate,
                account_status = 4,
                last_update_date = sysdate,
                last_updated_by = 0,
                note = note || ', End dated employer for no activity '
            where
                    acc_num = x.acc_num
                and entrp_id = x.entrp_id
                and entrp_id is not null
                and account_type = 'HSA';

        /*UPDATE PERSON
        SET    ENTRP_ID = NULL
            ,   LAST_UPDATE_DATE = SYSDATE
            ,   LAST_UPDATED_BY = 0
            ,   NOTE = NOTE ||', Employer end dated so detaching the employees '
        WHERE ENTRP_ID = C.ENTRP_ID;*/
        end loop;

     -- Inactive the rate plans for HSA/LSA terminated employers.
     -- Added by Joshi for #11540 on 04/14/2023
        for x in (
            select
                entrp_id,
                acc_id,
                account_status,
                trunc(end_date) term_date,
                last_updated_by
            from
                account
            where
                account_type in ( 'HSA', 'LSA' )
                and entrp_id is not null
                and end_date is not null
                and trunc(end_date) = trunc(sysdate)
        ) loop
            if x.account_status <> 4 then
                update account
                set
                    account_status = 4,
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                    entrp_id = x.entrp_id;

            end if;

            update rate_plans
            set
                status = 'I',
                effective_end_date = trunc(sysdate),
                last_update_date = sysdate,
                last_updated_by = 0
            where
                    entity_id = x.entrp_id
                and entity_type = 'EMPLOYER'
                and status = 'A';

        end loop;

    end end_date_employer;

    function get_entrp_id_from_ein (
        p_tax_id in varchar2
    ) return number is
        l_entrp_id number;
    begin
        for x in (
            select
                entrp_id
            from
                enterprise
            where
                replace(entrp_code, '-') = replace(
                    replace(p_tax_id, '-', ''),
                    ' ',
                    ''
                )
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        return l_entrp_id;
    exception
        when others then
            null;
    end;

    function get_entrp_id_from_ein_act (
        p_tax_id       in varchar2,
        p_account_type in varchar2 default 'HSA'
    ) return number is
        l_entrp_id number;
    begin
        for x in (
            select
                a.entrp_id
            from
                enterprise a,
                account    b
            where
                    replace(entrp_code, '-') = replace(
                        replace(p_tax_id, '-', ''),
                        ' ',
                        ''
                    )
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
                and b.decline_date is null   -- Added by Swamy for ticket#12008 on 25012024
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;
 /*ELSE
     FOR X IN ( SELECT A.ENTRP_ID FROM ENTERPRISE A, ACCOUNT B
               WHERE REPLACE(ENTRP_CODE,'-') = REPLACE(REPLACE(p_tax_id,'-',''),' ','')
               AND   A.ENTRP_ID = B.ENTRP_ID
               AND   b.ACCOUNT_TYPE = p_account_type)
    LOOP
      L_ENTRP_ID := X.ENTRP_ID;
    END LOOP;

 END IF;*/
        return l_entrp_id;
    exception
        when others then
            null;
    end get_entrp_id_from_ein_act;

    function get_acc_id_from_ein (
        p_tax_id       in varchar2,
        p_account_type in varchar2 default 'HSA'
    ) return number is
        l_acc_id number;
    begin
        for x in (
            select
                acc_id
            from
                enterprise a,
                account    b
            where
                    replace(
                        replace(entrp_code, '-', ''),
                        ' ',
                        ''
                    ) = replace(
                        replace(p_tax_id, '-', ''),
                        ' ',
                        ''
                    )
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
        ) loop
            l_acc_id := x.acc_id;
        end loop;

        return l_acc_id;
    exception
        when others then
            null;
    end;

    function get_payroll_integration (
        p_entrp_id in number
    ) return varchar2 is
        l_flag varchar2(1);
    begin
        select
            payroll_integration
        into l_flag
        from
            account
        where
            entrp_id = p_entrp_id;

        return l_flag;
    exception
        when others then
            return 'N';
    end get_payroll_integration;

    function get_acc_id (
        p_entrp_id in number
    ) return number is
        l_acc_id number;
    begin
        select
            acc_id
        into l_acc_id
        from
            account
        where
            entrp_id = p_entrp_id;

        return l_acc_id;
    exception
        when others then
            return null;
    end;

    function get_entrp_id_for_cobra (
        p_cobra_number in number
    ) return number is
        l_entrp_id number;
    begin
        for x in (
            select
                e.entrp_id
            from
                enterprise e,
                account    a
            where
                    cobra_id_number = p_cobra_number
                and e.entrp_id = a.entrp_id
                and a.account_type = 'COBRA'
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        return l_entrp_id;
    exception
        when others then
            null;
    end;

    function get_eligible_count (
        p_entrp_id in number
    ) return number is
        l_census_numbers number;
    begin
        for x in (
            select
                a.census_numbers
            from
                enterprise_census a
            where
                    a.census_code = 'NO_OF_ELIGIBLE'
                and entity_id = p_entrp_id
                and entity_type = 'ENTERPRISE'
                and last_update_date = (
                    select
                        max(last_update_date)
                    from
                        enterprise_census
                    where
                            census_code = 'NO_OF_ELIGIBLE'
                        and entity_id = a.entity_id
                )
        ) loop
            l_census_numbers := x.census_numbers;
        end loop;

        return l_census_numbers;
    exception
        when others then
            null;
    end get_eligible_count;

    function allow_exp_enroll (
        p_entrp_id in number
    ) return varchar2 is
        l_flag varchar2(1) := 'Y';
    begin
        for x in (
            select
                allow_exp_enroll
            from
                account_preference
            where
                entrp_id = p_entrp_id
        ) loop
            l_flag := x.allow_exp_enroll;
        end loop;

        return l_flag;
    exception
        when others then
            return 'Y';
    end allow_exp_enroll;

    function get_tax_id (
        p_entrp_id in number
    ) return varchar2 is
        l_tax_id varchar2(30);
    begin
        for x in (
            select
                entrp_code
            from
                enterprise
            where
                entrp_id = p_entrp_id
        ) loop
            l_tax_id := x.entrp_code;
        end loop;

        return l_tax_id;
    end get_tax_id;

    procedure insert_enterprise (
        p_name                in varchar2,
        p_ein_number          in varchar2,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zip                 in varchar2,
        p_contact_name        in varchar2,
        p_phone               in varchar2,
        p_fax_id              in varchar2,
        p_email               in varchar2,
        p_fee_plan_type       in number,
        p_card_allowed        in varchar2,
        p_office_phone_number in varchar2  /* 7857*/,
        p_industry_type       in varchar2 default null    -----9141 rprabu 03/08/2020
        ,
        x_entrp_id            out number,
        x_error_status        out varchar2,
        x_error_message       out varchar2
    ) as
    begin
        pc_log.log_error('PC_ENTRP.CREATE_ENTERPRISE', 'Inserting Enterprise');
        insert into enterprise (
            entrp_id,
            en_code,
            name,
            entrp_code,
            address,
            city,
            state,
            zip,
            entrp_pay,
            entrp_contact,
            entrp_phones,
            entrp_fax,
            entrp_email,
            note,
            card_allowed,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            office_phone_number,   /* 7857 */
            industry_type      -----9141 rprabu 03/08/2020
        ) values ( entrp_seq.nextval,
                   1,
                   p_name,
                   p_ein_number,
                   p_address,
                   p_city,
                   p_state,
                   p_zip,
                   p_fee_plan_type,
                   p_contact_name,
                   p_phone,
                   p_fax_id,
                   p_email,
                   'Online Enrollment',
                   decode(
                       upper(p_card_allowed),
                       'Y',
                       0,
                       'YES',
                       0,
                       'NO',
                       1,
                       'N',
                       1,
                       p_card_allowed
                   ),
                   sysdate,
                   421,
                   sysdate,
                   421,
                   p_office_phone_number,
                   p_industry_type      -----9141 rprabu 03/08/2020
                    ) returning entrp_id into x_entrp_id;

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_ENTRP.CREATE_ENTERPRISE', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end insert_enterprise;

 -- Below Function added by Swamy for Ticket#7756
 -- Function to get the State Code for an Employer
    function get_state (
        p_entrp_id in number
    ) return varchar2 is
        l_state varchar2(100);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.GET_STATE', 'In function');
        for x in (
            select
                state
            from
                enterprise
            where
                entrp_id = p_entrp_id
        ) loop
            l_state := x.state;
        end loop;

        return l_state;
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.GET_STATE', sqlerrm);
            return ( null );
    end get_state;

 -- Added by jaggi Ticket#11119
    function get_city (
        p_entrp_id in number
    ) return varchar2 is
        l_city varchar2(100);
    begin
        pc_log.log_error('pc_entrp.GET_CITY', 'In function');
        for x in (
            select
                upper(city) city
            from
                enterprise
            where
                entrp_id = p_entrp_id
        ) loop
            l_city := x.city;
        end loop;

        return l_city;
    exception
        when others then
            pc_log.log_error('pc_entrp.l_city', sqlerrm);
            return ( null );
    end get_city;

 -- Added by Joshi for  12775
    function get_active_entrp_id_from_ein_act (
        p_tax_id       in varchar2,
        p_account_type in varchar2 default 'HSA'
    ) return number is
        l_entrp_id number;
    begin
        for x in (
            select
                a.entrp_id
            from
                enterprise a,
                account    b
            where
                    replace(entrp_code, '-') = replace(
                        replace(p_tax_id, '-', ''),
                        ' ',
                        ''
                    )
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
                and b.account_status = 1
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        return l_entrp_id;
    exception
        when others then
            null;
    end get_active_entrp_id_from_ein_act;

end pc_entrp;
/

