create or replace package body samqa.pc_cobrapoint_migration is

    procedure migrate_cobra_employer as

        l_entrp_id            number;
        type client_aat is
            table of client%rowtype index by pls_integer;
        l_client              client_aat;
        l_acc_num             varchar2(30);
        x_error_message       varchar2(255);
        x_return_status       varchar2(255);
        l_salesteam_member_id number;
        l_setup_fee           number := 0;
        l_employee_id         number;
    begin
  -- Excluding the clients that is inactive and dont need to be imported into SAM

        update_client_id_renewed(null, 'COBRA');
        select
            *
        bulk collect
        into l_client
        from
            client
        where
            clientid not in (
                select distinct
                    clientid
                from
                    spm
            )   -- Added by Swamy for Ticket#9656 on 24/03/2021
        order by
            clientid;

        for i in 1..l_client.count loop
            l_entrp_id := null;
            l_entrp_id := get_entrp_id_for_vendor(l_client(i).clientid,
                                                  'COBRA');
            l_employee_id := null;
       --    dbms_output.put_line('client id '||l_client(i).clientid||' l_entrp_id '||l_entrp_id);
            for x in (
                select
                    emp_id
                from
                    employee    e,
                    clientgroup cg
                where
                        to_char(e.emp_id) = cg.clientgroupname
                    and cg.clientgroupid = l_client(i).clientgroupid
            ) loop
                l_employee_id := x.emp_id;
            end loop;

            if l_entrp_id is not null then
                update enterprise
                set
                    address = l_client(i).address1
                              || ' '
                              || l_client(i).address2,
                    city = l_client(i).city,
                    state = l_client(i).state,
                    zip = l_client(i).postalcode,
                    entrp_phones = l_client(i).phone,
                    entrp_fax = l_client(i).fax,
                    name = l_client(i).clientname
                where
                    entrp_id = l_entrp_id;

            else
                dbms_output.put_line('ein '
                                     || l_client(i).ein
                                     || ' entrp_id '
                                     || l_client(i).clientid);

                l_setup_fee := 0;
                for x in (
                    select
                        a.startdate,
                        a.setupfee
                    from
                        clientfee a
                    where
                        clientid = l_client(i).clientid
                ) loop
                    l_setup_fee := x.setupfee;
                end loop;

                l_acc_num := null;
                x_return_status := 'S';
                x_error_message := null;
                pc_employer_enroll.create_employer(
                    p_name                   => l_client(i).clientname,
                    p_ein_number             => l_client(i).ein,
                    p_address                => l_client(i).address1
                                 || ' '
                                 || l_client(i).address2,
                    p_city                   => l_client(i).city,
                    p_state                  => l_client(i).state,
                    p_zip                    => l_client(i).postalcode,
                    p_account_type           => 'COBRA',
                    p_start_date             => to_char(to_date(l_client(i).billingstartdate,
        'DD-MON-RR'),
                                            'MM/DD/YYYY'),
                    p_phone                  => l_client(i).phone,
                    p_email                  => null,
                    p_fax                    => l_client(i).fax,
                    p_contact_name           => null,
                    p_contact_phone          => null,
                    p_broker_id              => get_broker(l_client(i).clientid),
                    p_salesrep_id            => null,
                    p_ga_id                  => null,
                    p_plan_code              => 514,
                    p_card_allowed           => 1,
                    p_setup_fee              => l_setup_fee,
                    p_note                   => 'Migrated from All Data',
                    p_pin_mailer             => 'N',
                    p_cust_svc_rep           => l_employee_id,
                    p_allow_eob              => 'N',
                    p_teamster_group         => 'N',
                    p_user_id                => 0,
                    p_takeover_flag          => 'N',
                    p_total_employees        => 0,
                    p_maint_fee_flag         => null,
                    x_acc_num                => l_acc_num,
                    x_error_message          => x_error_message,
                    x_return_status          => x_return_status,
                    p_allow_online_renewal   => null,
                    p_allow_election_changes => null
                );

                if x_return_status <> 'S' then
                    dbms_output.put_line('x_error_message ' || x_error_message);
                    log_error('CLIENT',
                              l_client(i).clientid,
                              l_client(i).ein,
                              x_error_message);

                end if;

                dbms_output.put_line('ein '
                                     || l_client(i).ein
                                     || ' entrp_id '
                                     || l_client(i).clientid
                                     || ' l_acc_num '
                                     || l_acc_num);

                l_entrp_id := pc_entrp.get_entrp_id(l_acc_num);
            end if;

            l_salesteam_member_id := null;
            for x in (
                select
                    entity_id
                from
                    sales_team_member
                where
                    end_date is null
                    and entity_type = 'CS_REP'
                    and emplr_id = l_entrp_id
            ) loop
                l_salesteam_member_id := x.entity_id;
            end loop;

            if
                nvl(l_salesteam_member_id, -1) <> nvl(l_employee_id, -1)
                and l_employee_id is not null
            then
                pc_sales_team.upsert_sales_team_member(
                    p_entity_type           => 'CS_REP',
                    p_entity_id             => l_employee_id,
                    p_mem_role              => 'PRIMARY',
                    p_entrp_id              => l_entrp_id,
                    p_start_date            => sysdate,
                    p_end_date              => null,
                    p_status                => 'A',
                    p_user_id               => 0,
                    p_pay_commission        => 'Y',
                    p_note                  => 'From create enrollment',
                    p_no_of_days            => null,
                    px_sales_team_member_id => l_salesteam_member_id,
                    x_return_status         => x_return_status,
                    x_error_message         => x_error_message
                );
            end if;

            update enterprise
            set
                dba_name = l_client(i).dbaname,
                cobra_id_number = l_client(i).clientid
            where
                entrp_id = l_entrp_id;

        end loop;

        update_client_id_renewed(null, 'COBRA');
    end migrate_cobra_employer;

   -- Commented the below code and added the new code provided by vanitha by Swamy for Ticket#9656 on 24/03/2021
  /* 04/14/2017 , Vanitha: to update the client id since cobrapoint doesnt allow to term
  PROCEDURE update_client_id_renewed(p_tax_id IN NUMBER)
  IS
  BEGIN
       FOR X IN (
                 SELECT  E.entrp_code  ,E.ENTRP_ID, C.CLIENTID
                  FROM  ENTERPRISE E, CLIENT C,ACCOUNT B
                  WHERE E.entrp_code = TO_CHAR(C.EIN)
                  AND   E.ENTRP_ID = B.ENTRP_ID
                  AND B.DECLINE_DATE IS NULL
                  AND   B.ACCOUNT_TYPE = 'COBRA'
                  AND   B.ACCOUNT_STATUS <> 4
                  AND   NOT EXISTS ( SELECT * FROM COBRA_ER_TERMINATED_ACCOUNTS T WHERE T.CLIENT_ID = C.CLIENTID)
                  AND   E.COBRA_ID_NUMBER IS NULL)
        LOOP
          UPDATE ENTERPRISE
           SET   cobra_id_number = x.clientid
          WHERE  entrp_id = x.entrp_id;

        END LOOP;
          FOR X IN (
                 SELECT  E.entrp_code  ,E.ENTRP_ID, C.CLIENTID
                  FROM  ENTERPRISE E, CLIENT C,ACCOUNT B
                  WHERE E.entrp_code = TO_CHAR(C.EIN)
                  AND   E.ENTRP_ID = B.ENTRP_ID
                  AND B.DECLINE_DATE IS NULL
                  AND   B.ACCOUNT_TYPE = 'COBRA'
                  AND   B.ACCOUNT_STATUS <> 4 AND e.cobra_id_number <> c.clientid
                  AND   NOT EXISTS ( SELECT * FROM COBRA_ER_TERMINATED_ACCOUNTS T WHERE T.CLIENT_ID = C.CLIENTID))
        LOOP
          UPDATE ENTERPRISE
           SET   cobra_id_number = x.clientid
          WHERE  entrp_id = x.entrp_id;

        END LOOP;
        FOR X IN (
       SELECT max(clientid) clientid,  ENTRP_ID
          FROM  CLIENT A ,(SELECT  E.entrp_code  ,E.ENTRP_ID
                  FROM  ENTERPRISE E, CLIENT C,ACCOUNT B
                  WHERE E.entrp_code = TO_CHAR(C.EIN)
                  AND   E.ENTRP_ID = B.ENTRP_ID
                  AND   B.ACCOUNT_TYPE = 'COBRA' AND B.DECLINE_DATE IS NULL
                  AND   C.EIN NOT IN (999999999,100000026)
                   AND   B.ACCOUNT_STATUS <> 4
                  AND   NOT EXISTS ( SELECT * FROM COBRA_ER_TERMINATED_ACCOUNTS T WHERE T.CLIENT_ID = C.CLIENTID)
                  GROUP BY E.entrp_code ,E.ENTRP_ID
                  HAVING  COUNT(C.CLIENTID) > 1 ) X
          WHERE X.ENTRP_CODE = TO_CHAR(A.EIN)
          group by ENTRP_ID)
        LOOP
          UPDATE ENTERPRISE
           SET   cobra_id_number = x.clientid
          WHERE  entrp_id = x.entrp_id;

        END LOOP;
  END update_client_id_renewed;
  */

   -- Added by Swamy for Ticket#9656 on 24/03/2021
    procedure update_client_id_renewed (
        p_tax_id       in number,
        p_account_type in varchar2 default 'COBRA'
    ) is
    begin
        for x in (
            select
                e.entrp_code,
                e.entrp_id,
                c.clientid
            from
                enterprise e,
                client     c,
                account    b
            where
                    e.entrp_code = to_char(c.ein)
                and e.entrp_id = b.entrp_id
                and b.decline_date is null
                and b.account_type = p_account_type
                and b.account_status <> 4
                and not exists (
                    select
                        *
                    from
                        cobra_er_terminated_accounts t
                    where
                        t.client_id = c.clientid
                )
                and e.cobra_id_number is null
        ) loop
            update enterprise
            set
                cobra_id_number = x.clientid
            where
                entrp_id = x.entrp_id;

        end loop;

        for x in (
            select
                e.entrp_code,
                e.entrp_id,
                c.clientid
            from
                enterprise e,
                client     c,
                account    b
            where
                    e.entrp_code = to_char(c.ein)
                and e.entrp_id = b.entrp_id
                and b.decline_date is null
                and b.account_type = p_account_type
                and b.account_status <> 4
                and e.cobra_id_number <> c.clientid
                and not exists (
                    select
                        *
                    from
                        cobra_er_terminated_accounts t
                    where
                        t.client_id = c.clientid
                )
        ) loop
            update enterprise
            set
                cobra_id_number = x.clientid
            where
                entrp_id = x.entrp_id;

        end loop;

        for x in (
            select
                max(clientid) clientid,
                entrp_id
            from
                client a,
                (
                    select
                        e.entrp_code,
                        e.entrp_id
                    from
                        enterprise e,
                        client     c,
                        account    b
                    where
                            e.entrp_code = to_char(c.ein)
                        and e.entrp_id = b.entrp_id
                        and b.account_type = p_account_type
                        and b.decline_date is null
                        and c.ein not in ( 999999999, 100000026 )
                        and b.account_status <> 4
                        and not exists (
                            select
                                *
                            from
                                cobra_er_terminated_accounts t
                            where
                                t.client_id = c.clientid
                        )
                    group by
                        e.entrp_code,
                        e.entrp_id
                    having
                        count(c.clientid) > 1
                )      x
            where
                x.entrp_code = to_char(a.ein)
            group by
                entrp_id
        ) loop
            update enterprise
            set
                cobra_id_number = x.clientid
            where
                entrp_id = x.entrp_id;

        end loop;

    end update_client_id_renewed;

    procedure migrate_client_contact is

        type contct_aat is
            table of clientcontact%rowtype index by pls_integer;
        l_contact       contct_aat;
        l_contact_id    number;
        l_ein           varchar2(30);
        x_error_message varchar2(255);
        x_return_status varchar2(255);
    begin
        select
            a.*
        bulk collect
        into l_contact
        from
            clientcontact a,
            client        b
        where
            a.firstname is not null
            and a.clientid = b.clientid;

        for i in 1..l_contact.count loop
            l_contact_id := null;
            l_contact_id := pc_contact.get_contact_id_for_cobra(l_contact(i).clientcontactid);
            if l_contact_id is not null then
                update contact
                set
                    phone = l_contact(i).phone
                            ||
                            case
                                when l_contact(i).phoneextension is null then
                                    ''
                                else
                                    'ext:' || l_contact(i).phoneextension
                            end,
                    fax = l_contact(i).fax,
                    email = l_contact(i).email,
                    status =
                        case
                            when l_contact(i).active = 1 then
                                'A'
                            else
                                'I'
                        end
                where
                    contact_id = l_contact_id;

            else
                for x in (
                    select
                        entrp_code
                    from
                        enterprise
                    where
                        cobra_id_number = l_contact(i).clientid
                ) loop
                    pc_contact.create_contact(
                        p_first_name    => l_contact(i).firstname,
                        p_last_name     => l_contact(i).lastname,
                        p_middle_name   => l_contact(i).middleinitial,
                        p_title         => l_contact(i).contacttype,
                        p_gender        => null,
                        p_entity_id     => x.entrp_code,
                        p_phone         => l_contact(i).phone
                                   ||
                                   case
                                       when l_contact(i).phoneextension is null then
                                           ''
                                       else
                                           'ext:' || l_contact(i).phoneextension
                                   end,
                        p_fax           => l_contact(i).fax,
                        p_email         => l_contact(i).email,
                        p_user_id       => 0,
                        x_contact_id    => l_contact_id,
                        x_return_status => x_return_status,
                        x_error_message => x_error_message
                    );

                    if x_return_status <> 'S' then
                        log_error('CLIENTCONTACT',
                                  l_contact(i).clientcontactid,
                                  l_contact(i).clientid,
                                  x_error_message);

                    else
                        insert into contact_role (
                            contact_role_id,
                            contact_id,
                            role_type,
                            description,
                            effective_date,
                            created_by,
                            last_updated_by,
                            cobra_id_number
                        ) values ( contact_role_seq.nextval,
                                   l_contact_id,
                                   'COBRA',
                                   'Cobra Contact',
                                   sysdate,
                                   0,
                                   0,
                                   l_contact(i).clientcontactid );

                    end if;

                end loop;
            end if;

        end loop;

    end migrate_client_contact;

/*
   PROCEDURE migrate_client_plans
   AS
       TYPE plans_aat
           IS TABLE OF ClientPlanQB%ROWTYPE
              INDEX BY PLS_INTEGER;
      l_plans    plans_aat;
      l_plan_id   NUMBER;
      l_ein        VARCHAR2(30);
   BEGIN
        SELECT a.*
        BULK COLLECT INTO l_plans
        FROM ClientPlanQB a, Client b
        AND   a.clientid = b.clientid;

        FOR i IN 1 .. l_plans.COUNT LOOP
           l_plan_id := null;
           l_plan_id := pc_benefit_plans.get_plan_id_for_cobra(l_plans(i).clientplanqbid);
           l_entrp_id := NULL;
           l_entrp_id := pc_entrp.get_entrp_id_for_cobra(l_client(i).clientid);

          IF l_entrp_id IS NOT NULL AND l_plan_id IS NULL THEN

                INSERT INTO ben_plan_enrollment_setup
                (ben_plan_id
                ,entrp_id
                ,cobra_id_number
                ,ben_plan_name
                ,ben_plan_number
                ,plan_type
                ,funding_type
                ,carrier_id
                ,termination_type
                ,insured_type
                ,waiting_period
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ) VALUES (
                ,BEN_PLAN_SEQ.nextval
                ,l_entrp_id
                ,l_plans(i).ClientPlanQBID
                ,l_plans(i).PlanName
                ,l_plans(i).CarrierPlanIdentification
                ,l_plans(i).InsuranceType
                ,l_plans(i).ratetype
                ,l_plans(i).carrierid
                ,l_plans(i).BenefitTerminationType
                ,l_plans(i).InsuredType
                ,l_plans(i).WaitingPeriod
                ,SYSDATE
                ,0
                ,SYSDATE
                ,0
                ) RETURNING ben_plan_id into l_plan_id;

                  UPDATE ben_plan_enrollment_setup
                    SET  cobra_id_number = l_Contact(i).ClientPlanQBID
                  WHERE  ben_plan_id = l_plan_id;

         END LOOP;

   END migrate_client_plans;

*/

    procedure migrate_client_division as

        type divisions_aat is
            table of clientdivision%rowtype index by pls_integer;
        l_divisions     divisions_aat;
        l_division_id   number;
        l_entrp_id      number;
        l_ein           varchar2(30);
        x_error_message varchar2(255);
        x_return_status varchar2(255);
    begin
        select
            a.*
        bulk collect
        into l_divisions
        from
            clientdivision a,
            client         b--, ClientDivisionQBPlan c
        where
            a.clientid = b.clientid;
       -- AND     a.clientdivisionid = c.clientdivisionid
      --  AND     strip_bad(replace(c.selected,chr(13),'')) = 1;

        for i in 1..l_divisions.count loop
            l_division_id := null;
            l_division_id := pc_employer_divisions.get_division_id_for_cobra(l_divisions(i).clientdivisionid);
            l_entrp_id := null;
            l_entrp_id := pc_entrp.get_entrp_id_for_cobra(l_divisions(i).clientid);
            if l_division_id is null then
                pc_employer_divisions.insert_employer_division(
                    p_division_code => l_divisions(i).clientdivisionid,
                    p_division_name => l_divisions(i).divisionname,
                    p_description   => 'COBRA division',
                    p_address1      => l_divisions(i).address1,
                    p_address2      => l_divisions(i).address2,
                    p_city          => l_divisions(i).city,
                    p_state         => l_divisions(i).state,
                    p_zip           => l_divisions(i).postalcode,
                    p_phone         => l_divisions(i).phone,
                    p_fax           => l_divisions(i).fax,
                    p_vendor_ref    => l_divisions(i).clientdivisionid,
                    p_vendor        => 'COBRA',
                    p_entrp_id      => l_entrp_id,
                    p_user_id       => 0,
                    x_division_id   => l_division_id,
                    x_return_status => x_return_status,
                    x_error_message => x_error_message
                );

                if x_return_status <> 'S' then
                    log_error('CLIENTDIVISION',
                              l_divisions(i).clientdivisionid,
                              l_divisions(i).divisionname,
                              x_error_message);

                else
                    update employer_divisions
                    set
                        cobra_id_number = l_divisions(i).clientdivisionid
                    where
                        division_id = l_division_id;

                end if;

            else
                update employer_divisions
                set
                    cobra_id_number = l_divisions(i).clientdivisionid,
                    entrp_id = l_entrp_id
                where
                    division_id = l_division_id;

            end if;

        end loop;

    end migrate_client_division;

    procedure migrate_division_contact is

        type contct_aat is
            table of clientdivisionrec index by pls_integer;
        l_contact       contct_aat;
        l_contact_id    number;
        l_ein           varchar2(30);
        x_error_message varchar2(255);
        x_return_status varchar2(255);
    begin
        select
            a.*,
            b.clientid
        bulk collect
        into l_contact
        from
            clientdivisioncontact a,
            clientdivision        b
        where
            a.firstname is not null
            and a.clientdivisionid = b.clientdivisionid;

        for i in 1..l_contact.count loop
            l_contact_id := null;
            l_contact_id := pc_contact.get_contact_id_for_cobra(l_contact(i).clientdivisioncontactid);
            if l_contact_id is not null then
                update contact
                set
                    phone = l_contact(i).phone
                            ||
                            case
                                when l_contact(i).phoneextension is null then
                                    ''
                                else
                                    'ext:' || l_contact(i).phoneextension
                            end,
                    fax = l_contact(i).fax,
                    email = l_contact(i).email,
                    status =
                        case
                            when l_contact(i).active = 1 then
                                'A'
                            else
                                'I'
                        end
                where
                    contact_id = l_contact_id;

            else
                for x in (
                    select
                        entrp_code
                    from
                        enterprise
                    where
                        cobra_id_number = l_contact(i).clientid
                ) loop
                    pc_contact.create_contact(
                        p_first_name    => l_contact(i).firstname,
                        p_last_name     => l_contact(i).lastname,
                        p_middle_name   => null,
                        p_title         => l_contact(i).contacttype,
                        p_gender        => null,
                        p_entity_id     => x.entrp_code,
                        p_phone         => l_contact(i).phone
                                   ||
                                   case
                                       when l_contact(i).phoneextension is null then
                                           ''
                                       else
                                           'ext:' || l_contact(i).phoneextension
                                   end,
                        p_fax           => l_contact(i).fax,
                        p_email         => l_contact(i).email,
                        p_user_id       => 0,
                        x_contact_id    => l_contact_id,
                        x_return_status => x_return_status,
                        x_error_message => x_error_message
                    );

                    if x_return_status <> 'S' then
                        log_error('CLIENTDIVISIONCONTACT',
                                  l_contact(i).clientdivisioncontactid,
                                  l_contact(i).clientid,
                                  x_error_message);

                    else
                        insert into contact_role (
                            contact_role_id,
                            contact_id,
                            role_type,
                            description,
                            effective_date,
                            created_by,
                            last_updated_by,
                            cobra_id_number
                        ) values ( contact_role_seq.nextval,
                                   l_contact_id,
                                   'COBRA_DIVISION',
                                   'Cobra Contact',
                                   sysdate,
                                   0,
                                   0,
                                   l_contact(i).clientdivisioncontactid );

                    end if;

                end loop;
            end if;

        end loop;

    end migrate_division_contact;
/*
   PROCEDURE migrate_client_division_plan
   AS
      TYPE plans_aat
           IS TABLE OF ClientDivisionQBPlan%ROWTYPE
              INDEX BY PLS_INTEGER;
      l_plans     plans_aat;
      l_division_id    NUMBER;
      l_entrp_id       NUMBER;
      l_ein            VARCHAR2(30);

   BEGIN
        SELECT a.*
        BULK COLLECT INTO l_plans
        FROM ClientDivisionQBPlan   a
        WHERE a.selected = 1   ;

        FOR i IN 1 .. l_plans.COUNT
        LOOP
           FOR x IN ( SELECT  division_code
                       FROM  employer_divisions
                      WHERE  cobra_id_number = l_plans(i).ClientDivisionID)
           LOOP
                  UPDATE ben_plan_enrollment_setup
                    SET  division_code = x.division_code
                  WHERE   cobra_id_number = l_Contact(i).ClientPlanQBID;

           END LOOP;
        END LOOP;

  END migrate_client_division_plan;
 */
    procedure migrate_npm (
        p_ssn in varchar2 default null
    ) is

        type npm_aat is
            table of npm%rowtype index by pls_integer;
        l_npm              npm_aat;
        l_pers_id          number;
        l_entrp_id         number;
        l_ein              varchar2(30);
        l_clientdivisionid number;
    begin
        select
            *
        bulk collect
        into l_npm
        from
            npm
        where
            ssn = nvl(p_ssn, ssn);

        for i in 1..l_npm.count loop
            l_entrp_id := null;
            l_clientdivisionid := null;
            l_pers_id := null;
            if l_clientdivisionid is null
               or l_clientdivisionid <> l_npm(i).clientdivisionid then
                for x in (
                    select
                        b.entrp_id,
                        a.clientdivisionid
                    from
                        clientdivision a,
                        enterprise     b
                    where
                            clientdivisionid = l_npm(i).clientdivisionid
                        and a.clientid = b.cobra_id_number
                ) loop
                    l_clientdivisionid := x.clientdivisionid;
                    l_entrp_id := x.entrp_id;
                end loop;
            end if;
     --       log_error('NPM',l_npm(i).MEMBERID,'ENTRP ID ',l_entrp_id);

            for x in (
                select
                    pers_id
                from
                    person a
                where
                        entrp_id = l_entrp_id
                    and orig_sys_vendor_ref = to_char(l_npm(i).memberid)
                    and person_type = 'NPM'
            ) loop
                l_pers_id := x.pers_id;
            end loop;
     --       log_error('NPM',l_npm(i).MEMBERID,'l_pers_id',l_pers_id);

            if l_pers_id is not null then
                begin
                    update person
                    set
                        address = l_npm(i).address1
                                  || ' '
                                  || l_npm(i).address2,
                        city = l_npm(i).city,
                        state = substr(l_npm(i).state,
                                       1,
                                       2),
                        zip = l_npm(i).postalcode,
                        phone_day = l_npm(i).phone,
                        phone_even = l_npm(i).phone2,
                        email = l_npm(i).email,
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                        pers_id = l_pers_id;

                exception
                    when others then
                        log_error('NPM',
                                  l_npm(i).memberid,
                                  format_ssn(l_npm(i).ssn),
                                  sqlerrm);
                end;
            elsif l_entrp_id is not null then
                begin
                    insert into person (
                        pers_id,
                        first_name,
                        middle_name,
                        last_name,
                        ssn,
                        address,
                        city,
                        state,
                        zip,
                        phone_day,
                        phone_even,
                        email,
                        relat_code,
                        note,
                        entrp_id,
                        person_type,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        orig_sys_vendor_ref,
                        division_code
                    ) values ( pers_seq.nextval,
                               l_npm(i).firstname,
                               l_npm(i).middleinitial,
                               l_npm(i).lastname,
                               format_ssn(l_npm(i).ssn),
                               l_npm(i).address1
                               || ' '
                               || l_npm(i).address2,
                               l_npm(i).city,
                               substr(l_npm(i).state,
                                      1,
                                      2),
                               l_npm(i).postalcode,
                               l_npm(i).phone,
                               l_npm(i).phone2,
                               l_npm(i).email,
                               1,
                               'Created from COBRA system',
                               l_entrp_id,
                               'NPM',
                               l_npm(i).dateentered,
                               0,
                               l_npm(i).dateentered,
                               0,
                               l_npm(i).memberid,
                               l_clientdivisionid );

                exception
                    when others then
                        log_error('NPM',
                                  l_npm(i).memberid,
                                  format_ssn(l_npm(i).ssn),
                                  sqlerrm);
                end;
            end if;

            if length(l_npm(i).state) > 2 then
                log_error('NPM',
                          l_npm(i).memberid,
                          format_ssn(l_npm(i).ssn),
                          'No of characters in state cannot exceed more than 2 characters');
            end if;

            for x in (
                select
                    count(*) cnt
                from
                    person
                where
                        entrp_id = l_entrp_id
                    and ssn = format_ssn(l_npm(i).ssn)
            ) loop
                if x.cnt = 0 then
                    log_error('NPM',
                              l_npm(i).memberid,
                              format_ssn(l_npm(i).ssn),
                              'Cannot create NPM due to unknown error');

                end if;
            end loop;

        end loop;

    end migrate_npm;

    function get_broker (
        p_client_id in varchar2
    ) return number is
        l_broker_id number := 0;
    begin
        for x in (
            select
                e.broker_id
            from
                brokerclient c,
                cobra_broker d,
                broker_v     e
            where
                    c.brokerid = d.brokerid
                and replace(e.tax_id, '-') = to_char(d.ein)
                and strip_bad(replace(c.clientid,
                                      chr(13),
                                      '')) = p_client_id
        ) loop
            l_broker_id := x.broker_id;
        end loop;

        return l_broker_id;
    end get_broker;

    procedure migrate_qb (
        p_ssn in varchar2 default null
    ) is

        type qb_aat is
            table of qb%rowtype index by pls_integer;
        l_qb               qb_aat;
        l_pers_id          number;
        l_entrp_id         number;
        l_clientdivisionid number;
        l_salesrep_id      number;
        l_broker_id        number;
        l_ein              varchar2(30);
        l_start_date       date;
    begin
        select
            *
        bulk collect
        into l_qb
        from
            qb
        where
            ssn = nvl(p_ssn, ssn);

        for i in 1..l_qb.count loop
            l_clientdivisionid := null;
            l_entrp_id := null;
            l_salesrep_id := null;
            l_broker_id := null;
            if l_clientdivisionid is null
               or l_clientdivisionid <> l_qb(i).clientdivisionid then
                for x in (
                    select
                        b.entrp_id,
                        a.clientdivisionid,
                        c.broker_id,
                        c.salesrep_id
                    from
                        clientdivision a,
                        enterprise     b,
                        account        c
                    where
                            clientdivisionid = l_qb(i).clientdivisionid
                        and a.clientid = b.cobra_id_number
                        and b.entrp_id = c.entrp_id
                        and c.account_type = 'COBRA'
                ) loop
                    l_clientdivisionid := x.clientdivisionid;
                    l_entrp_id := x.entrp_id;
                    l_salesrep_id := x.salesrep_id;
                    l_broker_id := x.broker_id;
                end loop;
            end if;

            l_pers_id := null;
            if l_entrp_id is not null then
                for x in (
                    select
                        pers_id
                    from
                        person a
                    where
                            entrp_id = l_entrp_id
                        and orig_sys_vendor_ref = to_char(l_qb(i).memberid)
                        and person_type = 'QB'
                ) loop
                    l_pers_id := x.pers_id;

                     -- added this for sprint ticket 5603
                    update person
                    set
                        pers_end_date = sysdate
                    where
                            orig_sys_vendor_ref = to_char(l_qb(i).memberid)
                        and person_type = 'QB'
                        and entrp_id <> l_entrp_id;

                end loop;
                                 -- added this for sprint ticket 5603

                for x in (
                    select
                        a.pers_id,
                        pc_entrp.get_entrp_name(a.entrp_id),
                        a.entrp_id,
                        pers_end_date,
                        acc.acc_num
                    from
                        person  a,
                        account acc
                    where
                            orig_sys_vendor_ref = to_char(l_qb(i).memberid)
                        and a.pers_id = acc.pers_id
                        and acc.account_type = 'COBRA'
                        and person_type = 'QB'
                        and a.pers_end_date is not null
                        and acc.account_status = 1
                ) loop
                    update account
                    set
                        account_status = 4,
                        end_date = sysdate
                    where
                        pers_id = x.pers_id;

                end loop;

                l_start_date := null;
                for xx in (
                    select
                        min(nvl(eventdate, originalenrollmentdate)) eventdate
                    from
                        qbevent
                    where
                        memberid = l_qb(i).memberid
                ) loop
                    l_start_date := xx.eventdate;
                end loop;

                if l_pers_id is not null then
                    begin
                        update person
                        set
                            address = l_qb(i).address1
                                      || ' '
                                      || l_qb(i).address2,
                            city = l_qb(i).city,
                            state = substr(l_qb(i).state,
                                           1,
                                           2),
                            zip = substr(l_qb(i).postalcode,
                                         1,
                                         5),
                            phone_day = l_qb(i).phone,
                            phone_even = l_qb(i).phone2,
                            email = l_qb(i).email,
                            last_update_date = sysdate,
                            last_updated_by = 0,
                            division_code = l_qb(i).clientdivisionid
                        where
                            pers_id = l_pers_id;

                    exception
                        when others then
                            log_error('QB',
                                      l_qb(i).memberid,
                                      format_ssn(l_qb(i).ssn),
                                      sqlerrm);
                    end;
                else
                    begin
                        insert into person (
                            pers_id,
                            first_name,
                            middle_name,
                            last_name,
                            ssn,
                            address,
                            city,
                            state,
                            zip,
                            phone_day,
                            phone_even,
                            email,
                            relat_code,
                            note,
                            gender,
                            birth_date,
                            entrp_id,
                            person_type,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            orig_sys_vendor_ref,
                            division_code
                        ) values ( pers_seq.nextval,
                                   l_qb(i).firstname,
                                   substr(l_qb(i).middleinitial,
                                          1,
                                          1),
                                   l_qb(i).lastname,
                                   format_ssn(l_qb(i).ssn),
                                   l_qb(i).address1
                                   || ' '
                                   || l_qb(i).address2,
                                   l_qb(i).city,
                                   substr(l_qb(i).state,
                                          1,
                                          2),
                                   substr(l_qb(i).postalcode,
                                          1,
                                          5),
                                   l_qb(i).phone,
                                   l_qb(i).phone2,
                                   l_qb(i).email,
                                   1,
                                   'Created from COBRA system',
                                   l_qb(i).gender,
                                   l_qb(i).dob,
                                   l_entrp_id,
                                   'QB',
                                   l_qb(i).entereddatetime,
                                   (
                                       select
                                           user_id
                                       from
                                           employee
                                       where
                                               upper(email) = upper(l_qb(i).enteredbyuser)
                                           and rownum = 1
                                   ),
                                   sysdate,
                                   (
                                       select
                                           user_id
                                       from
                                           employee
                                       where
                                               upper(email) = upper(l_qb(i).enteredbyuser)
                                           and rownum = 1
                                   ),
                                   l_qb(i).memberid,
                                   l_clientdivisionid ) returning pers_id into l_pers_id;

                    exception
                        when others then
                            log_error('QB',
                                      l_qb(i).memberid,
                                      format_ssn(l_qb(i).ssn),
                                      sqlerrm);
                    end;
                end if;

                begin
                    insert into account (
                        acc_id,
                        pers_id,
                        entrp_id,
                        acc_num,
                        plan_code,
                        start_date,
                        broker_id,
                        note,
                        salesrep_id,
                        account_type,
                        reg_date,
                        account_status,
                        complete_flag,
                        signature_on_file,
                        hsa_effective_date,
                        verified_by
                    )
                        select
                            acc_seq.nextval,
                            l_pers_id,
                            null,
                            pc_account.generate_acc_num(514, null),
                            514,
                            nvl(l_start_date,
                                l_qb(i).entereddatetime),
                            l_broker_id,
                            'Created from COBRA System',
                            l_salesrep_id,
                            'COBRA',
                            l_qb(i).entereddatetime,
                            decode(l_qb(i).active,
                                   1,
                                   1,
                                   0,
                                   4),
                            1,
                            'Y',
                            l_start_date,
                            (
                                select
                                    user_id
                                from
                                    employee
                                where
                                        upper(email) = upper(l_qb(i).enteredbyuser)
                                    and rownum = 1
                            )
                        from
                            dual
                        where
                            not exists (
                                select
                                    *
                                from
                                    account
                                where
                                    pers_id = l_pers_id
                            );

                exception
                    when others then
                        log_error('QB',
                                  l_qb(i).memberid,
                                  format_ssn(l_qb(i).ssn),
                                  sqlerrm);
                end;

                if length(l_qb(i).state) > 2 then
                    log_error('QB',
                              l_qb(i).memberid,
                              format_ssn(l_qb(i).ssn),
                              'No of characters in state cannot exceed more than 2 characters');
                end if;

                for x in (
                    select
                        count(*) cnt
                    from
                        person
                    where
                            entrp_id = l_entrp_id
                        and division_code = to_char(l_clientdivisionid)
                        and ssn = format_ssn(l_qb(i).ssn)
                ) loop
                    if x.cnt = 0 then
                        log_error('QB',
                                  l_qb(i).memberid,
                                  format_ssn(l_qb(i).ssn),
                                  'Cannot create/update QB due to SSN change from the file to what exists in SAM');

                    end if;
                end loop;

            else
                log_error('QB',
                          l_qb(i).memberid,
                          format_ssn(l_qb(i).ssn),
                          'Cannot create QB due to null client id ');
            end if;

        end loop;

    end migrate_qb;

    procedure migrate_qb_dependent is

        type qb_dep_aat is
            table of qbdependent%rowtype index by pls_integer;
        l_qb         qb_dep_aat;
        l_pers_id    number;
        l_pers_main  number;
        l_entrp_id   number;
        l_ein        varchar2(30);
        l_start_date date;
    begin
        select
            *
        bulk collect
        into l_qb
        from
            qbdependent;

        for i in 1..l_qb.count loop
            l_pers_id := pc_person.get_pers_id_for_cobra(
                strip_bad(replace(l_qb(i).qbdependentid,
                                  chr(13),
                                  '')),
                'QBDEPENDENT'
            );

            l_pers_main := pc_person.get_pers_id_for_cobra(
                strip_bad(replace(l_qb(i).memberid,
                                  chr(13),
                                  '')),
                'QB'
            );

            if l_pers_id is null then
                begin
                    insert into person (
                        pers_id,
                        first_name,
                        middle_name,
                        last_name,
                        ssn,
                        address,
                        city,
                        state,
                        zip,
                        phone_day,
                        phone_even,
                        email,
                        relat_code,
                        note,
                        gender,
                        birth_date,
                        entrp_id,
                        person_type,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        orig_sys_vendor_ref,
                        pers_main
                    )
                        select
                            pers_seq.nextval,
                            l_qb(i).firstname,
                            l_qb(i).middleinitial,
                            l_qb(i).lastname,
                            format_ssn(l_qb(i).ssn),
                            l_qb(i).address1
                            || ' '
                            || l_qb(i).address2,
                            l_qb(i).city,
                            substr(l_qb(i).state,
                                   1,
                                   2),
                            l_qb(i).postalcode,
                            l_qb(i).phone,
                            l_qb(i).phone2,
                            l_qb(i).email,
                            case
                                when l_qb(i).relationship in ( 'SPOUSE', 'DOMESTICPARTNER' ) then
                                    2
                                when l_qb(i).relationship = 'CHILD' then
                                    3
                                else
                                    9
                            end,
                            'Created from COBRA system',
                            l_qb(i).gender,
                            l_qb(i).dob,
                            entrp_id,
                            'QBDEPENDENT',
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            strip_bad(replace(l_qb(i).qbdependentid,
                                              chr(13),
                                              '')),
                            l_pers_main
                        from
                            person
                        where
                            pers_id = l_pers_main;

                exception
                    when others then
                        log_error('QBDEPENDENT',
                                  l_qb(i).qbdependentid,
                                  format_ssn(l_qb(i).ssn),
                                  sqlerrm);
                end;
            end if;

        end loop;

    end migrate_qb_dependent;

    procedure log_error (
        p_entity_type   in varchar2,
        p_entity_id     in number,
        p_entity_key    in varchar2,
        p_error_message in varchar2
    ) is
        pragma autonomous_transaction;
    begin
        insert into cobra_interface_error (
            interface_err_id,
            entity_type,
            entity_id,
            entity_key,
            error_message,
            creation_date,
            created_by
        ) values ( cobra_interface_error_seq.nextval,
                   p_entity_type,
                   p_entity_id,
                   p_entity_key,
                   p_error_message,
                   sysdate,
                   0 );

        commit;
    end log_error;

    procedure migrate_payments is

        l_payment        payment_att;
        type number_tbl is
            table of number index by pls_integer;
        l_change_num     number_tbl;
        c_limit          pls_integer := 1000;
        errors           pls_integer;
        ecode            number;
        dml_errors exception;
        pragma exception_init ( dml_errors, -24381 );
        l_migrated_count number := 0;
    begin
         /*
           -- Update the voided amounts
           OPEN void_cur;

           LOOP
              FETCH void_cur
              BULK COLLECT INTO l_change_num;

               FORALL i in l_change_num.first .. l_change_num.last
                UPDATE INCOME
                SET amount = 0
                  , NOTE   =substr( NOTE||' Voided Payment',1,3200)
                  , LAST_UPDATED_DATE = SYSDATE
                WHERE change_num = l_change_num(i);
              EXIT WHEN void_cur%NOTFOUND ;
           END LOOP;
           CLOSE void_cur;

            FOR X IN (   SELECT qp.qbpaymentid,
                        CAST(QP.EnteredDateTime AS DATE) EnteredDateTime,
                        QP.PostmarkDate,
                        Qp.DepositDate,
                        QP.PaymentAmount,
                        QP.CheckNumber,
                        QP.BatchNumber,
                        QP.PAYMENTMETHOD
                        , A.ACC_ID,qp.memberid
                FROM
                QBPayment  QP,
                Person P, Account A
                WHERE P.pers_id = a.pers_id
                AND   a.account_type = 'COBRA'
                AND   p.person_type = 'QB'
                AND   qp.ISvoid = 0
                AND   p.Orig_Sys_Vendor_Ref = to_char(qP.memberid)
                group by qp.qbpaymentid,
                        CAST(QP.EnteredDateTime AS DATE) ,
                        QP.PostmarkDate,
                        Qp.DepositDate,
                        QP.PaymentAmount,
                        QP.CheckNumber,
                        QP.BatchNumber,
                        QP.PAYMENTMETHOD
                        , A.ACC_ID,qp.memberid
                having count(distinct QP.CheckNumber) > 1 )
            LOOP
                 log_error('QBPAYMENT',x.acc_id
                                     , x.checknumber
                                     , 'Duplicate Receipts are found for the Same Payment in COBRA system');
            END LOOP;

           OPEN payment_cur;

           LOOP
              FETCH payment_cur
              BULK COLLECT INTO l_payment
              LIMIT c_limit;
              -- FORALL i in l_payment.first .. l_payment.last  SAVE EXCEPTIONS
                  FOR i IN 1 .. l_payment.count
                  LOOP
                     BEGIN

                       INSERT INTO INCOME
                        (CHANGE_NUM
                        , ACC_ID
                        , FEE_DATE
                        , FEE_CODE
                        , AMOUNT
                        , PAY_CODE
                        , CC_NUMBER
                        , NOTE
                        , TRANSACTION_TYPE
                        , CREATED_BY
                        , CREATION_DATE
                        , LAST_UPDATED_BY
                        , LAST_UPDATED_DATE
                        , ORIG_DOC_REF)
                        VALUES
                        (CHANGE_SEQ.NEXTVAL
                        ,l_payment(i).acc_id
                        ,l_payment(i).depositdate
                        ,4
                        ,l_payment(i).amount
                        ,l_payment(i).paymentmethod
                        ,l_payment(i).checknumber
                        ,substr(l_payment(i).note,1,3200)
                        ,'I'
                        ,0
                        ,l_payment(i).CREATION_DATE
                        ,0
                        ,l_payment(i).CREATION_DATE
                        ,l_payment(i).qbpaymentid);
                        -- Send notification to QB that we received paymeent

                          PC_NOTIFICATIONS.NOTIFY_COBRA_RECEIPTS(l_payment(i).acc_id);
                     EXCEPTION
                         WHEN OTHERS THEN
                              log_error('QBPAYMENT',l_payment(i).acc_id
                                             , l_payment(i).checknumber
                                             , SQLERRM);
                     END ;
                 END LOOP;

            exit when payment_cur%NOTFOUND;
            END LOOP;

           CLOSE payment_cur;
*/
        for x in (
            select
                q.memberid
            from
                client c,
                qb     q
            where
                    q.memberid = - 1
                and c.clientid in (
                    select
                        e.cobra_id_number
                    from
                        account    a, enterprise e
                    where
                            a.migrated_flag = 'Y'
                        and a.entrp_id is not null
                        and a.account_type = 'COBRA'
                        and a.entrp_id = e.entrp_id
                )
                and c.clientid = q.clientid
        ) loop
            select
                count(*)
            into l_migrated_count
            from
                income  a,
                account b,
                person  c
            where
                    c.orig_sys_vendor_ref = to_char(x.memberid)
                and c.pers_id = b.pers_id
                and b.account_type = 'COBRA'
                and a.acc_id = b.acc_id
                and a.fee_code = 4;

            if l_migrated_count = 0 then
                insert into income (
                    change_num,
                    acc_id,
                    fee_date,
                    fee_code,
                    amount,
                    amount_add,
                    ee_fee_amount,
                    pay_code,
                    cc_number,
                    note,
                    transaction_type,
                    due_date,
                    postmark_date,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_updated_date,
                    list_bill,
                    orig_doc_ref
                )
                    select
                        change_seq.nextval,
                        q.acc_id,
                        q.depositdate,
                        4,
                        0,
                        q.premium_amount,
                        q.admin_fee,
                        q.paymentmethod,
                        q.checknumber,
                        'Premium Posting for '
                        || nvl(q.planname, '')
                        || 'paymentid:'
                        || nvl(q.qbpaymentid, '')
                        || ':Member id :'
                        || nvl(q.memberid, '')
                        || ' on '
                        || to_char(q.premiumduedate, 'MM/DD/YYYY'),
                        'I',
                        premiumduedate,
                        postmarkdate,
                        0,
                        q.entereddatetime,
                        0,
                        q.entereddatetime,
                        change_seq.currval,
                        q.qbpaymentid
                    from
                        (
                            select
                                q.memberid,
                                q.planname,
                                q.depositdate     depositdate,
                                q.premiumduedate,
                                q.postmarkdate,
                                case
                                    when allocatedamount > premiumamount then
                                        allocatedamount - premiumamount
                                    when allocatedamount < premiumamount then
                                        allocatedamount
                                    else
                                        0
                                end               admin_fee,
                                allocatedamount - (
                                    case
                                        when allocatedamount > premiumamount then
                                            allocatedamount - premiumamount
                                        when allocatedamount < premiumamount then
                                            allocatedamount
                                        else
                                            0
                                    end
                                )                 premium_amount,
                                q.allocatedamount,
                                q.adminfee,
                                q.premiumamount,
                                q.qbpaymentid,
                                q.checknumber,
                                q.entereddatetime entereddatetime,
                                case
                                    when q.paymentmethod in ( 'CHECK', 'CPSPAYMENT' ) then
                                        1
                                    when q.paymentmethod in ( 'CPSACH', 'ONLINEACH', 'CPSPAYMENT', 'SCHEDULEDPAYMENT', 'CUSTOMERACH' )
                                    then
                                        5
                                    when q.paymentmethod = 'NONCASHNONREMITTED' then
                                        11
                                    else
                                        9
                                end               paymentmethod,
                                p.pers_id,
                                a.acc_num,
                                a.acc_id
                            from
                                qbpayment q,
                                person    p,
                                account   a,
                                qb        m
                            where
                                    p.ssn = m.ssn
                                and q.memberid = m.memberid
                                and p.orig_sys_vendor_ref = to_char(m.memberid)
                                and q.premiumduedate is not null
                                and q.isvoid = 0
                                and p.pers_id = a.pers_id
                                and p.person_type = 'QB'
                                and a.account_type = 'COBRA'
                                and p.orig_sys_vendor_ref = to_char(q.memberid)
                                and m.memberid = x.memberid
                                and not exists (
                                    select
                                        *
                                    from
                                        income ii
                                    where
                                            ii.acc_id = a.acc_id
                                        and ii.fee_date = q.depositdate
                                        and ii.orig_doc_ref is not null
                                        and ii.orig_doc_ref = to_char(q.qbpaymentid)
                                )
                        ) q;

            else
                insert into income (
                    change_num,
                    acc_id,
                    fee_date,
                    fee_code,
                    amount,
                    amount_add,
                    ee_fee_amount,
                    pay_code,
                    cc_number,
                    note,
                    transaction_type,
                    due_date,
                    postmark_date,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_updated_date,
                    list_bill,
                    orig_doc_ref
                )
                    select
                        change_seq.nextval,
                        q.acc_id,
                        q.depositdate,
                        4,
                        0,
                        q.premium_amount,
                        q.admin_fee,
                        q.paymentmethod,
                        q.checknumber,
                        'Premium Posting for '
                        || nvl(q.planname, '')
                        || 'paymentid:'
                        || nvl(q.qbpaymentid, '')
                        || ':Member id :'
                        || nvl(q.memberid, '')
                        || ' on '
                        || to_char(q.premiumduedate, 'MM/DD/YYYY'),
                        'I',
                        premiumduedate,
                        postmarkdate,
                        0,
                        q.entereddatetime,
                        0,
                        q.entereddatetime,
                        change_seq.currval,
                        q.qbpaymentid
                    from
                        (
                            select
                                q.memberid,
                                q.planname,
                                q.depositdate     depositdate,
                                q.premiumduedate,
                                q.postmarkdate,
                                case
                                    when allocatedamount > premiumamount then
                                        allocatedamount - premiumamount
                                    when allocatedamount < premiumamount then
                                        allocatedamount
                                    else
                                        0
                                end               admin_fee,
                                allocatedamount - (
                                    case
                                        when allocatedamount > premiumamount then
                                            allocatedamount - premiumamount
                                        when allocatedamount < premiumamount then
                                            allocatedamount
                                        else
                                            0
                                    end
                                )                 premium_amount,
                                q.allocatedamount,
                                q.adminfee,
                                q.premiumamount,
                                q.qbpaymentid,
                                q.checknumber,
                                q.entereddatetime entereddatetime,
                                case
                                    when q.paymentmethod in ( 'CHECK', 'CPSPAYMENT' ) then
                                        1
                                    when q.paymentmethod in ( 'CPSACH', 'ONLINEACH', 'CPSPAYMENT', 'SCHEDULEDPAYMENT', 'CUSTOMERACH' )
                                    then
                                        5
                                    when q.paymentmethod = 'NONCASHNONREMITTED' then
                                        11
                                    else
                                        9
                                end               paymentmethod,
                                p.pers_id,
                                a.acc_num,
                                a.acc_id
                            from
                                qbpayment q,
                                person    p,
                                account   a,
                                qb        m
                            where
                                    p.ssn = m.ssn
                                and q.memberid = m.memberid
                                and p.orig_sys_vendor_ref = to_char(m.memberid)
                                and q.premiumduedate is not null
                                and q.isvoid = 0
                                and p.orig_sys_vendor_ref is not null
                                and p.pers_id = a.pers_id
                                and p.person_type = 'QB'
                                and a.account_type = 'COBRA'
                                and p.orig_sys_vendor_ref = to_char(q.memberid)
                                and m.memberid = x.memberid
                       -- AND    trunc(Q.entereddatetime) >= trunc(sysdate-3)
                                and not exists (
                                    select
                                        *
                                    from
                                        income ii
                                    where
                                            ii.acc_id = a.acc_id
                                        and ii.fee_date = q.depositdate
                                        and ii.orig_doc_ref is not null
                                        and ii.orig_doc_ref = to_char(q.qbpaymentid)
                                )
                        ) q;

            end if;

        end loop;

        null;
    exception
        when others then
            raise;
    end migrate_payments;

    procedure run_migration is
    begin
     /*  begin
            pc_cobrapoint_migration.migrate_cobra_employer;
            commit;
        exception
             when others then
                dbms_output.put_line('Error in migrating employer' ||SQLERRM);
         end;

        -- The below pc_cobrapoint_migration.migrate_SPM_employer procedure Added by Swamy for Ticket#9656 on 24/03/2021
        BEGIN
            pc_cobrapoint_migration.migrate_SPM_employer;
            COMMIT;
        EXCEPTION
             WHEN OTHERS THEN
                PC_LOG.LOG_ERROR('Insert pc_cobrapoint_migration.run_migration in migrate_SPM_employer others ',SQLERRM);
         END;

		begin
            pc_cobrapoint_migration.migrate_client_contact;
            commit;
       exception
             when others then
                dbms_output.put_line('Error in migrating client contact ' ||SQLERRM);
         end;
         begin

            pc_cobrapoint_migration.migrate_client_division;
            commit;
       exception
             when others then
                dbms_output.put_line('Error in migrating client division ' ||SQLERRM);
         end;
         begin
             pc_cobrapoint_migration.migrate_division_contact;
             commit;
       exception
             when others then
                dbms_output.put_line('Error in migrating division contact' ||SQLERRM);
         end;
         begin
               pc_cobrapoint_migration.migrate_npm;
                  commit;
       exception
             when others then
                dbms_output.put_line('Error in migrating npm' ||SQLERRM);
         end;
         begin

               pc_cobrapoint_migration.migrate_qb;
                  commit;
          exception
             when others then
                dbms_output.put_line('Error in migrating QB' ||SQLERRM);
         end;
         begin

                  pc_cobrapoint_migration.migrate_qb_dependent;
                  commit;
       exception
             when others then
                dbms_output.put_line('Error in migrating QB dependent' ||SQLERRM);
         end;

         -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
         BEGIN
               pc_cobrapoint_migration.migrate_spm;
               COMMIT;
          EXCEPTION
             WHEN OTHERS THEN
                PC_LOG.LOG_ERROR('Insert pc_cobrapoint_migration.run_migration in migrate_spm others ',SQLERRM);
         END;

	     begin

         pc_cobrapoint_migration.migrate_payments;
                  commit;
       exception
             when others then
                dbms_output.put_line('Error in migrating QB payments' ||SQLERRM);
         end;
             */
        null;
    end run_migration;

    function get_client_sso (
        p_ein in varchar2
    ) return ssorec_t
        pipelined
        deterministic
    is
        l_record       ssorec;
        l_cnt          number := 0;
        l_account_type varchar2(30);
    begin
        pc_log.log_error('get_client_sso', ' p_ein' || p_ein);
        if user = 'SAM' then
            l_record.customerid := 335;
        else
            l_record.customerid := 336;
        end if;

        select
            count(*),
            a.account_type
        into
            l_cnt,
            l_account_type
        from
            account    a,
            enterprise p
        where
                a.entrp_id = p.entrp_id
            and p.entrp_code = p_ein
        group by
            a.account_type;
   --   AND    A.MIGRATED_FLAG = 'Y';
        if
            l_cnt > 0
            and l_account_type = 'RB'
        then
            for x in (
                select
                    a.ssoidentifier ssoidentifier,
                    b.clientid
                from
                    clientcontact a,
                    client        b
                where
                        a.clientid = b.clientid
                    and a.allowsso = 1
                    and a.active = 1
                    and a.firstname is not null
                    and a.lastname is not null
                    and b.ein = to_number(regexp_replace(p_ein, '[^[:digit:]]+', ''))
                    and not exists (
                        select
                            *
                        from
                            cobra_er_terminated_accounts c
                        where
                            c.client_id = b.clientid
                    )
                    and rownum = 1
            ) loop
                l_record.ssoidentifier := x.ssoidentifier;
                l_record.clientid := x.clientid;
                l_record.ein := p_ein;
               --   l_record.SSOIDENTIFIER := 'bf8e5d5a-f3f5-40e1-9666-ec07987b8311';
               --   l_record.CLIENTID := 1;

                pipe row ( l_record );
            end loop;
        else
            pipe row ( l_record );
        end if;
       --  l_record.SSOIDENTIFIER := 'bf8e5d5a-f3f5-40e1-9666-ec07987b8311';
        --  l_record.CLIENTID := 1;
        --  PIPE ROW (l_record);

    exception
        when others then
            null;
    end get_client_sso;

    function get_qb_sso (
        p_ssn in varchar2
    ) return ssorec_t
        pipelined
        deterministic
    is
        l_record ssorec;
        l_cnt    number := 0;
    begin
        if user = 'SAM' then
            l_record.customerid := 335;
        else
            l_record.customerid := 336;
        end if;

        select
            count(*)
        into l_cnt
        from
            account a,
            person  p
        where
                a.pers_id = p.pers_id
            and p.ssn = format_ssn(p_ssn)
            and a.migrated_flag = 'Y';

        if l_cnt = 0 then
            for x in (
                select
                    lower(b.ssoidentifier) ssoidentifier,
                    b.memberid,
                    b.clientid
                from
                    client a,
                    qb     b
                                                   /*, (SELECT SSN, MAX(ENTEREDDATETIME) ENTEREDDATETIME  FROM QB where ssn  = format_ssn(p_ssn ) GROUP BY SSN )  BC
                                                   WHERE  b.ssn   = BC.SSN
                                                         B.ENTEREDDATETIME = BC.ENTEREDDATETIME */ --Sk commented on 10/04/2022
                where
                        a.clientid = b.clientid
                    and b.active = 1
                    and b.allowsso = '1'
                    and b.ssn = format_ssn(p_ssn)
                    and not exists (
                        select
                            *
                        from
                            cobra_ee_terminated_accounts c
                        where
                            c.qb_id = b.memberid
                    )--Sk added on 10/04/2022
                    and rownum = 1
            ) loop
                l_record.ssoidentifier := x.ssoidentifier;
                l_record.memberid := x.memberid;
                l_record.clientid := x.clientid;
        
           --       l_record.SSOIDENTIFIER := '3b7b6f3e-19ab-4f59-8e9a-69637a9a5be5';
           --       l_record.MEMBERID :=4;
           --       l_record.CLIENTID := 1;

                pipe row ( l_record );
            end loop;
        else
            pipe row ( l_record );
        end if;
    --      l_record.SSOIDENTIFIER := '3b7b6f3e-19ab-4f59-8e9a-69637a9a5be5';
    --      l_record.MEMBERID :=4;
    --      l_record.CLIENTID := 1;

        --  PIPE ROW (l_record);
    end get_qb_sso;

   -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
    procedure migrate_spm is

        type spm_aat is
            table of spm%rowtype index by pls_integer;
        l_spm              spm_aat;
        l_pers_id          number;
        l_entrp_id         number;
        l_clientdivisionid number;
        l_salesrep_id      number;
        l_broker_id        number;
        l_ein              varchar2(30);
        l_start_date       date;
    begin
        select
            *
        bulk collect
        into l_spm
        from
            spm;

        for i in 1..l_spm.count loop
            l_clientdivisionid := null;
            l_entrp_id := null;
            l_salesrep_id := null;
            l_broker_id := null;
            if l_clientdivisionid is null
               or l_clientdivisionid <> l_spm(i).clientdivisionid then
                for x in (
                    select
                        b.entrp_id,
                        a.clientdivisionid,
                        c.broker_id,
                        c.salesrep_id
                    from
                        clientdivision a,
                        enterprise     b,
                        account        c
                    where
                            clientdivisionid = l_spm(i).clientdivisionid
                        and a.clientid = b.cobra_id_number
                        and b.entrp_id = c.entrp_id
                        and c.account_type = 'RB'
                ) loop
                    l_clientdivisionid := x.clientdivisionid;
                    l_entrp_id := x.entrp_id;
                    l_salesrep_id := x.salesrep_id;
                    l_broker_id := x.broker_id;
                end loop;
            end if;

            l_pers_id := null;
            if l_entrp_id is not null then
                for x in (
                    select
                        pers_id
                    from
                        person a
                    where
                            entrp_id = l_entrp_id
                        and orig_sys_vendor_ref = to_char(l_spm(i).memberid)
                        and person_type = 'SPM'
                ) loop
                    l_pers_id := x.pers_id;

                     -- added this for sprint ticket 5603
                    update person
                    set
                        pers_end_date = sysdate
                    where
                            orig_sys_vendor_ref = to_char(l_spm(i).memberid)
                        and person_type = 'SPM'
                        and entrp_id <> l_entrp_id;

                end loop;

                for x in (
                    select
                        a.pers_id,
                        pc_entrp.get_entrp_name(a.entrp_id),
                        a.entrp_id,
                        pers_end_date,
                        acc.acc_num
                    from
                        person  a,
                        account acc
                    where
                            orig_sys_vendor_ref = to_char(l_spm(i).memberid)
                        and a.pers_id = acc.pers_id
                        and acc.account_type = 'RB'
                        and person_type = 'SPM'
                        and a.pers_end_date is not null
                        and acc.account_status = 1
                ) loop
                    update account
                    set
                        account_status = 4,
                        end_date = sysdate
                    where
                        pers_id = x.pers_id;

                end loop;

                l_start_date := l_spm(i).hipaaenrollmentdate;
                if l_pers_id is not null then
                    begin
                        update person
                        set
                            address = l_spm(i).address1
                                      || ' '
                                      || l_spm(i).address2,
                            city = l_spm(i).city,
                            state = substr(l_spm(i).state,
                                           1,
                                           2),
                            zip = substr(l_spm(i).postalcode,
                                         1,
                                         5),
                            phone_day = l_spm(i).phone,
                            phone_even = l_spm(i).phone2,
                            email = l_spm(i).email,
                            last_update_date = sysdate,
                            last_updated_by = 0
                        where
                            pers_id = l_pers_id;

                    exception
                        when others then
                            log_error('SPM',
                                      l_spm(i).memberid,
                                      format_ssn(l_spm(i).ssn),
                                      sqlerrm);
                    end;
                else
                    begin
                        insert into person (
                            pers_id,
                            first_name,
                            middle_name,
                            last_name,
                            ssn,
                            address,
                            city,
                            state,
                            zip,
                            phone_day,
                            phone_even,
                            email,
                            relat_code,
                            note,
                            gender,
                            birth_date,
                            entrp_id,
                            person_type,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            orig_sys_vendor_ref,
                            division_code
                        ) values ( pers_seq.nextval,
                                   l_spm(i).firstname,
                                   substr(l_spm(i).middleinitial,
                                          1,
                                          1),
                                   l_spm(i).lastname,
                                   format_ssn(l_spm(i).ssn),
                                   l_spm(i).address1
                                   || ' '
                                   || l_spm(i).address2,
                                   l_spm(i).city,
                                   substr(l_spm(i).state,
                                          1,
                                          2),
                                   substr(l_spm(i).postalcode,
                                          1,
                                          5),
                                   l_spm(i).phone,
                                   l_spm(i).phone2,
                                   l_spm(i).email,
                                   1,
                                   'Created from COBRA system',
                                   l_spm(i).gender,
                                   l_spm(i).dob,
                                   l_entrp_id,
                                   'SPM',
                                   l_spm(i).entereddatetime,
                                   (
                                       select
                                           user_id
                                       from
                                           employee
                                       where
                                               upper(email) = upper(l_spm(i).enteredbyuser)
                                           and rownum = 1
                                   ),
                                   l_spm(i).entereddatetime,
                                   (
                                       select
                                           user_id
                                       from
                                           employee
                                       where
                                               upper(email) = upper(l_spm(i).enteredbyuser)
                                           and rownum = 1
                                   ),
                                   l_spm(i).memberid,
                                   l_clientdivisionid ) returning pers_id into l_pers_id;

                    exception
                        when others then
                            log_error('SPM',
                                      l_spm(i).memberid,
                                      format_ssn(l_spm(i).ssn),
                                      sqlerrm);
                    end;
                end if;

                begin
                    insert into account (
                        acc_id,
                        pers_id,
                        entrp_id,
                        acc_num,
                        plan_code,
                        start_date,
                        broker_id,
                        note,
                        salesrep_id,
                        account_type,
                        reg_date,
                        account_status,
                        complete_flag,
                        signature_on_file,
                        hsa_effective_date,
                        verified_by
                    )
                        select
                            acc_seq.nextval,
                            l_pers_id,
                            null,
                            pc_account.generate_acc_num(522, null),
                            522,
                            nvl(l_start_date,
                                l_spm(i).entereddatetime),
                            l_broker_id,
                            'Created from COBRA System',
                            l_salesrep_id,
                            'RB',
                            l_spm(i).entereddatetime,
                            decode(l_spm(i).active,
                                   1,
                                   1,
                                   0,
                                   4),
                            1,
                            'Y',
                            l_start_date,
                            (
                                select
                                    user_id
                                from
                                    employee
                                where
                                        upper(email) = upper(l_spm(i).enteredbyuser)
                                    and rownum = 1
                            )
                        from
                            dual
                        where
                            not exists (
                                select
                                    *
                                from
                                    account
                                where
                                    pers_id = l_pers_id
                            );

                exception
                    when others then
                        log_error('SPM',
                                  l_spm(i).memberid,
                                  format_ssn(l_spm(i).ssn),
                                  sqlerrm);
                end;

                if length(l_spm(i).state) > 2 then
                    log_error('SPM',
                              l_spm(i).memberid,
                              format_ssn(l_spm(i).ssn),
                              'No of characters in state cannot exceed more than 2 characters');
                end if;

                for x in (
                    select
                        count(*) cnt
                    from
                        person
                    where
                            entrp_id = l_entrp_id
                        and division_code = to_char(l_clientdivisionid)
                        and ssn = format_ssn(l_spm(i).ssn)
                ) loop
                    if x.cnt = 0 then
                        log_error('SPM',
                                  l_spm(i).memberid,
                                  format_ssn(l_spm(i).ssn),
                                  'Cannot create/update SPM due to SSN change from the file to what exists in SAM');

                    end if;
                end loop;

            else
                log_error('SPM',
                          l_spm(i).memberid,
                          format_ssn(l_spm(i).ssn),
                          'Cannot create SPM due to null client id ');
            end if;

        end loop;

    end migrate_spm;

   -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
    function get_spm_sso (
        p_ssn in varchar2
    ) return ssorec_t
        pipelined
        deterministic
    is
        l_record ssorec;
    begin
        if user = 'SAM' then
            l_record.customerid := 335;
        else
            l_record.customerid := 336;
        end if;

        for x in (
            select
                lower(b.ssoidentifier) ssoidentifier,
                b.memberid,
                b.clientid
            from
                client a,
                spm    b,
                (
                    select
                        ssn,
                        max(entereddatetime) entereddatetime
                    from
                        spm
                    where
                        format_ssn(ssn) = format_ssn(p_ssn)
                    group by
                        ssn
                )      bc
            where
                    b.ssn = bc.ssn
                and b.entereddatetime = bc.entereddatetime
                and a.clientid = b.clientid
                and b.active = 1
                and b.allowsso = '1'
                and format_ssn(b.ssn) = format_ssn(p_ssn)
        ) loop
            l_record.ssoidentifier := x.ssoidentifier;
            l_record.memberid := x.memberid;
            l_record.clientid := x.clientid;
            pipe row ( l_record );
        end loop;

    end get_spm_sso;

   -- The below procedure Added by Swamy for Ticket#9656 on 24/03/2021
    procedure migrate_spm_employer as

        l_entrp_id            number;
        type client_aat is
            table of client%rowtype index by pls_integer;
        l_client              client_aat;
        l_acc_num             varchar2(30);
        x_error_message       varchar2(255);
        x_return_status       varchar2(255);
        l_salesteam_member_id number;
        l_setup_fee           number := 0;
        l_employee_id         number;
    begin
        update_client_id_renewed(null, 'RB');
   -- Excluding the clients that is inactive and dont need to be imported into SAM
        select
            *
        bulk collect
        into l_client
        from
            client
        where
            clientid in (
                select distinct
                    clientid
                from
                    spm
            )
        order by
            clientid;

        for i in 1..l_client.count loop
            l_entrp_id := null;
            l_entrp_id := get_entrp_id_for_vendor(l_client(i).clientid,
                                                  'RB');
            l_employee_id := null;
            for x in (
                select
                    emp_id
                from
                    employee    e,
                    clientgroup cg
                where
                        to_char(e.emp_id) = cg.clientgroupname
                    and cg.clientgroupid = l_client(i).clientgroupid
            ) loop
                l_employee_id := x.emp_id;
            end loop;

            if l_entrp_id is not null then
                update enterprise
                set
                    address = l_client(i).address1
                              || ' '
                              || l_client(i).address2,
                    city = l_client(i).city,
                    state = l_client(i).state,
                    zip = l_client(i).postalcode,
                    entrp_phones = l_client(i).phone,
                    entrp_fax = l_client(i).fax,
                    name = l_client(i).clientname
                where
                    entrp_id = l_entrp_id;

            else
                l_setup_fee := 0;
                for x in (
                    select
                        a.startdate,
                        a.setupfee
                    from
                        clientfee a
                    where
                        clientid = l_client(i).clientid
                ) loop
                    l_setup_fee := x.setupfee;
                end loop;

                l_acc_num := null;
                x_return_status := 'S';
                x_error_message := null;
                pc_employer_enroll.create_employer(
                    p_name                   => l_client(i).clientname,
                    p_ein_number             => l_client(i).ein,
                    p_address                => l_client(i).address1
                                 || ' '
                                 || l_client(i).address2,
                    p_city                   => l_client(i).city,
                    p_state                  => l_client(i).state,
                    p_zip                    => l_client(i).postalcode,
                    p_account_type           => 'RB',
                    p_start_date             => to_char(to_date(l_client(i).billingstartdate,
        'DD-MON-RR'),
                                            'MM/DD/YYYY'),
                    p_phone                  => l_client(i).phone,
                    p_email                  => null,
                    p_fax                    => l_client(i).fax,
                    p_contact_name           => null,
                    p_contact_phone          => null,
                    p_broker_id              => get_broker(l_client(i).clientid),
                    p_salesrep_id            => null,
                    p_ga_id                  => null,
                    p_plan_code              => 522,
                    p_card_allowed           => 1,
                    p_setup_fee              => l_setup_fee,
                    p_note                   => 'Migrated from All Data',
                    p_pin_mailer             => 'N',
                    p_cust_svc_rep           => l_employee_id,
                    p_allow_eob              => 'N',
                    p_teamster_group         => 'N',
                    p_user_id                => 0,
                    p_takeover_flag          => 'N',
                    p_total_employees        => 0,
                    p_maint_fee_flag         => null,
                    x_acc_num                => l_acc_num,
                    x_error_message          => x_error_message,
                    x_return_status          => x_return_status,
                    p_allow_online_renewal   => null,
                    p_allow_election_changes => null
                );

                if x_return_status <> 'S' then
                    log_error('CLIENT',
                              l_client(i).clientid,
                              l_client(i).ein,
                              x_error_message);
                end if;

                l_entrp_id := pc_entrp.get_entrp_id(l_acc_num);
            end if;

            l_salesteam_member_id := null;
            for x in (
                select
                    entity_id
                from
                    sales_team_member
                where
                    end_date is null
                    and entity_type = 'CS_REP'
                    and emplr_id = l_entrp_id
            ) loop
                l_salesteam_member_id := x.entity_id;
            end loop;

            if
                nvl(l_salesteam_member_id, -1) <> nvl(l_employee_id, -1)
                and l_employee_id is not null
            then
                pc_sales_team.upsert_sales_team_member(
                    p_entity_type           => 'CS_REP',
                    p_entity_id             => l_employee_id,
                    p_mem_role              => 'PRIMARY',
                    p_entrp_id              => l_entrp_id,
                    p_start_date            => sysdate,
                    p_end_date              => null,
                    p_status                => 'A',
                    p_user_id               => 0,
                    p_pay_commission        => 'Y',
                    p_note                  => 'From create enrollment',
                    p_no_of_days            => null,
                    px_sales_team_member_id => l_salesteam_member_id,
                    x_return_status         => x_return_status,
                    x_error_message         => x_error_message
                );
            end if;

            update enterprise
            set
                dba_name = l_client(i).dbaname,
                cobra_id_number = l_client(i).clientid
            where
                entrp_id = l_entrp_id;

        end loop;

        update_client_id_renewed(null, 'RB');
    end migrate_spm_employer;

end pc_cobrapoint_migration;
/


-- sqlcl_snapshot {"hash":"bcc29e950ad6b0f109412383b05405061ba0fb48","type":"PACKAGE_BODY","name":"PC_COBRAPOINT_MIGRATION","schemaName":"SAMQA","sxml":""}