-- liquibase formatted sql
-- changeset SAMQA:1754374081697 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_sales_team.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_sales_team.sql:null:d8c9cc949583091dba16a30f0b6cec0db6ec0951:create

create or replace package body samqa.pc_sales_team is

    procedure cre_sales_team_member (
        entity_type_in           in sales_team_member.entity_type%type,
        entity_id_in             in sales_team_member.entity_id%type,
        mem_role_in              in sales_team_member.mem_role%type,
        emplr_id_in              in sales_team_member.emplr_id%type,
        start_date_in            in sales_team_member.start_date%type,
        end_date_in              in sales_team_member.end_date%type,
        status_in                in sales_team_member.status%type,
        creation_date_in         in sales_team_member.creation_date%type,
        created_by_in            in sales_team_member.created_by%type,
        last_update_date_in      in sales_team_member.last_update_date%type,
        last_updated_by_in       in sales_team_member.last_updated_by%type,
        pay_commission_in        in sales_team_member.pay_commission%type,
        notes_in                 in sales_team_member.notes%type,
        no_of_days_in            in sales_team_member.no_of_days%type,
        sales_team_member_id_out out sales_team_member.sales_team_member_id%type
    ) is
    begin
        insert into sales_team_member (
            sales_team_member_id,
            entity_type,
            entity_id,
            mem_role,
            emplr_id,
            start_date,
            end_date,
            status,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            pay_commission,
            notes,
            no_of_days
        ) values ( sales_team_seq.nextval,
                   entity_type_in,
                   entity_id_in,
                   mem_role_in,
                   emplr_id_in,
                   nvl(start_date_in, sysdate),
                   end_date_in,
                   nvl(status_in, 'A'),
                   nvl(creation_date_in, sysdate),
                   created_by_in,
                   nvl(last_update_date_in, sysdate),
                   last_updated_by_in,
                   pay_commission_in,
                   notes_in,
                   no_of_days_in ) returning sales_team_member_id into sales_team_member_id_out;

   -- commented and added by Joshi for 5022. update primary salesrep in the account table.
   -- IF entity_type_in = 'SALES_REP' THEN
        if
            entity_type_in = 'SALES_REP'
            and mem_role_in = 'PRIMARY'
        then
            update account
            set
                salesrep_id = entity_id_in,
                last_updated_by = last_updated_by_in
            where
                entrp_id = emplr_id_in;

            update account
            set
                salesrep_id = entity_id_in,
                last_updated_by = last_updated_by_in
            where
                pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        entrp_id = emplr_id_in
                );

        end if;

   -- update the secondary salesrep in account table.
        if
            entity_type_in = 'SALES_REP'
            and mem_role_in = 'SECONDARY'
        then
            update account
            set
                am_id = entity_id_in,
                last_updated_by = last_updated_by_in
            where
                entrp_id = emplr_id_in;

            update account
            set
                am_id = entity_id_in,
                last_updated_by = last_updated_by_in
            where
                pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        entrp_id = emplr_id_in
                );

        end if;

    end cre_sales_team_member;

    procedure updt_sales_team_member (
        sales_team_member_id_in in sales_team_member.sales_team_member_id%type,
        entity_type_in          in sales_team_member.entity_type%type,
        entity_id_in            in sales_team_member.entity_id%type,
        mem_role_in             in sales_team_member.mem_role%type,
        emplr_id_in             in sales_team_member.emplr_id%type,
        start_date_in           in sales_team_member.start_date%type,
        end_date_in             in sales_team_member.end_date%type,
        status_in               in sales_team_member.status%type,
        last_update_date_in     in sales_team_member.last_update_date%type,
        last_updated_by_in      in sales_team_member.last_updated_by%type,
        pay_commission_in       in sales_team_member.pay_commission%type,
        notes_in                in sales_team_member.notes%type,
        no_of_days_in           in sales_team_member.no_of_days%type
    ) is
    begin
        update sales_team_member
        set
            entity_type = entity_type_in,
            entity_id = entity_id_in,
            mem_role = mem_role_in,
            emplr_id = emplr_id_in,
            start_date = start_date_in,
            end_date = end_date_in,
            status = nvl(status_in, 'A'),
            last_update_date = nvl(last_update_date_in, sysdate),
            last_updated_by = last_updated_by_in,
            pay_commission = pay_commission_in,
            notes = notes_in,
            no_of_days = no_of_days_in
        where
            sales_team_member_id = sales_team_member_id_in;

    end updt_sales_team_member;

    function get_general_agent_name (
        p_ga_id in number
    ) return varchar2 is
        l_name varchar2(200);
    begin
        select
            agency_name
        into l_name
        from
            general_agent
        where
            ga_id = p_ga_id;

        return l_name;
    exception
        when no_data_found then
            dbms_output.put_line('Error in Get General Name');
            return null;
    end;

    function get_sales_rep_name (
        p_salesrep_id in number
    ) return varchar2 is
        l_name varchar2(200);
    begin
        select
            name
        into l_name
        from
            salesrep
        where
            salesrep_id = p_salesrep_id;

        return l_name;
    exception
        when no_data_found then
            dbms_output.put_line('Error in GET_SALES_REP_NAME');
            return null;
    end;

-- Added by Joshi for 5022.
    function get_sales_rep_role (
        p_salesrep_id in number
    ) return varchar2 is
        l_role_desc varchar2(200);
    begin
        select
            pc_lookups.get_meaning(role_type, 'SALES_TEAM_ROLE')
        into l_role_desc
        from
            salesrep
        where
            salesrep_id = p_salesrep_id;

        return l_role_desc;
    exception
        when no_data_found then
      --dbms_output.put_line('Error in GET_SALES_REP_ROLE');
            return null;
    end;

    function validate_secondary (
        p_entity_id in number,
        p_emplr_id  in number
    ) return varchar2 is
        l_count number;
    begin
        select
            count(1)
        into l_count
        from
            sales_team_member
        where
                mem_role = 'PRIMARY'
            and entity_type = 'SALES_REP'
            and emplr_id = p_emplr_id
            and entity_id = p_entity_id;

        if l_count = 0 then
            return 'N';
        else
            return 'Y';
        end if;
    exception
        when no_data_found then
            return 'N';
    end;

    function get_cust_srvc_rep_name (
        p_custrep_id in number
    ) return varchar2 is
        l_cust_rep_name varchar2(100);
    begin
        select
            ( first_name
              || ' '
              || last_name ) name
        into l_cust_rep_name
        from
            employee
        where
            emp_id = p_custrep_id;

        return l_cust_rep_name;
    exception
        when no_data_found then
            dbms_output.put_line('Error in Get Customer Name');
            return null;
    end get_cust_srvc_rep_name;

    function get_cust_srvc_rep_name_for_er (
        p_entrp_id in number
    ) return varchar2 is
        l_cust_rep_name varchar2(100);
    begin
     --WM_CONCAT(First_Name||' '||Last_Name) Name commented by joshi for 12C upgrade as WM_CONCAT is obsolete
        select
            listagg(first_name
                    || ' '
                    || last_name, ',') within group(
            order by
                first_name
            ) name
        into l_cust_rep_name
        from
            employee
        where
            emp_id in (
                select
                    entity_id
                from
                    sales_team_member
                where
                        emplr_id = p_entrp_id
                    and entity_type = 'CS_REP'
                    and status = 'A'
                    and end_date is null
            );

        return l_cust_rep_name;
    exception
        when no_data_found then
            dbms_output.put_line('Error in Get Customer Name');
            return null;
    end get_cust_srvc_rep_name_for_er;

---------------------------rprabu 12/09/2023 

    function get_cust_srvc_rep_email_for_er (
        p_entrp_id in number
    ) return varchar2 is
        l_cust_rep_name varchar2(3000);
    begin
        select
            listagg(email, ',') within group(
            order by
                email
            ) name
        into l_cust_rep_name
        from
            employee
        where
            emp_id in (
                select
                    entity_id
                from
                    sales_team_member
                where
                        emplr_id = p_entrp_id
                    and entity_type = 'CS_REP'
                    and status = 'A'
                    and end_date is null
            );

        return l_cust_rep_name;
    exception
        when no_data_found then
         -----  dbms_output.put_line('Error in Get Customer Name');

            return null;
    end get_cust_srvc_rep_email_for_er;   
---------------------------rprabu 12/09/2023 

    function get_contact_email_for_er (
        p_entrp_id in number
    ) return varchar2 is
        l_contact_email varchar2(3000);
    begin
        select
            listagg(email, ',') within group(
            order by
                email
            ) email
        into l_contact_email
        from
            contact
        where
                entity_id = pc_entrp.get_tax_id(p_entrp_id)
            and status = 'A'
            and user_id is null
            and pc_contact.get_contact_roles(contact_id) in ( 'COBRA', 'Primary', 'Secondary' );

        return l_contact_email;
    exception
        when no_data_found then
         -----  dbms_output.put_line('Error in Get Customer Name');
            return null;
    end get_contact_email_for_er;   

---------------------------rprabu 21/09/2023 

    function get_carrier_email_for_er (
        p_entrp_id in number
    ) return varchar2 is
        l_carrier_email varchar2(3000);
    begin
        select
            listagg(carrier_contact_email, ',') within group(
            order by
                carrier_contact_email
            ) email
        into l_carrier_email
        from
            carrier_notification a,
            account              b
        where
            carrier_contact_email is not null    --- order by  entrp_id desc 
            and a.entrp_id = b.entrp_id
            and a.entrp_id = p_entrp_id;

        return l_carrier_email;
    exception
        when no_data_found then
         -----  dbms_output.put_line('Error in Get Customer Name');

            return null;
    end get_carrier_email_for_er;   

---------------------------rprabu 21/09/2023 
    function get_broker_email_for_er (
        p_entrp_id in number
    ) return varchar2 is
    begin
        for i in (
            select
                e.email
            from
                broker_assignments a,
                broker             d,
                person             e
            where
                    a.entrp_id = p_entrp_id
                and d.broker_id = a.broker_id
                and e.pers_id = d.broker_id
                and a.pers_id is null
                and a.effective_end_date is null
        ) loop
            return i.email;
        end loop;

        return null;
    end get_broker_email_for_er;

    procedure insert_broker_data (
        p_broker_id      in number,
        p_entrp_id       in number,
        p_pers_id        in number,
        p_effective_date in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
        l_count number;
    begin
        x_return_status := 'S';
        select
            count(*)
        into l_count
        from
            broker_assignments
        where
                broker_id = p_broker_id
            and entrp_id = p_entrp_id
            and pers_id is null
            and effective_end_date is null;

        if l_count > 0 then
            x_return_status := 'E';
            x_error_message := 'Employer has been assigned with this broker already';
        end if;
        l_count := 0;

     --How is this Validation applicable. After End dating the earlier broker , then only we can add new broker.
     /*  SELECT COUNT(*)
       INTO   l_count
       FROM   broker_assignments
       WHERE  effective_date > TO_DATE(p_effective_date,'MM/DD/YYYY')
         AND  entrp_id = p_entrp_id
         AND  pers_id IS NULL;
       pc_log.log_error('PC_BROKER.INSERT_BROKER_ASSIGN',l_count);
       IF l_count > 0 THEN
         x_return_status := 'E';
         x_error_message := 'A Broker has been already assigned with future effective date, Update the effective date of the broker
                          with future effective date and then add this broker';
       END IF;    */

        if
            x_return_status = 'S'
            and p_entrp_id is not null
            and p_pers_id is null
        then
            insert into broker_assignments (
                broker_assignment_id,
                broker_id,
                entrp_id,
                effective_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                status
            )
                select
                    broker_assignment_seq.nextval,
                    p_broker_id,
                    p_entrp_id,
                    nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    'A'
                from
                    dual;

            update account
            set
                broker_id = p_broker_id
            where
                entrp_id = p_entrp_id;

            pc_log.log_error('PC_BROKER', 'Effective date'
                                          || p_effective_date
                                          || 'entrp id '
                                          || p_entrp_id
                                          || 'broker id '
                                          || p_broker_id);

      --Here we are end dating the earlier broker associated with this Employer
            update broker_assignments
            set
                effective_end_date = nvl(to_date(p_effective_date, 'MM/DD/YYYY') - 1, sysdate)
            where
                    trunc(effective_date) <= nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate)
                and entrp_id = p_entrp_id
                and broker_id <> p_broker_id
                and effective_end_date is null;

        end if;

        if
            x_return_status = 'S'
            and p_pers_id is not null
        then
            insert into broker_assignments (
                broker_assignment_id,
                broker_id,
                entrp_id,
                pers_id,
                effective_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                status
            )
                select
                    broker_assignment_seq.nextval,
                    p_broker_id,
                    p_entrp_id,
                    p_pers_id,
                    nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    'A'
                from
                    dual;

            update account
            set
                broker_id = p_broker_id
            where
                pers_id = p_pers_id;

      --Here we are end dating the earlier broker associated with this Employer
            update broker_assignments
            set
                effective_end_date = nvl(to_date(p_effective_date, 'MM/DD/YYYY') - 1, sysdate)
            where
                    trunc(effective_date) <= nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate)
                and pers_id = p_pers_id
                and broker_id <> p_broker_id
                and effective_end_date is null;

        end if;

    end insert_broker_data;

    procedure validate_broker_data (
        p_broker_id          in number,
        p_entrp_id           in number,
        p_effective_date     in varchar2,
        p_effective_end_date in varchar2,
        p_user_id            in number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is
        l_count                number;
        p_broker_assignment_id number(10);
        e_error exception;
    begin
        x_return_status := 'S';
        dbms_output.put_line('In proc');
        begin
            select
                broker_assignment_id
            into p_broker_assignment_id
            from
                broker_assignments
            where
                    broker_id = p_broker_id
                and entrp_id = p_entrp_id
                and pers_id is null
                and effective_end_date is null;

        exception
            when others then
                p_broker_assignment_id := null;
        end;

        for x in (
            select
                q_start
            from
                (
                    select
                        add_months(
                            trunc(sysdate, 'yyyy'),
                            (rownum - 1) * 3
                        )     q_start,
                        add_months(
                            trunc(sysdate, 'yyyy'),
                            rownum * 3
                        ) - 1 q_end
                    from
                        all_objects
                    where
                        rownum <= 4
                )
            where
                    q_start < sysdate
                and q_end > sysdate
        ) loop
            if x.q_start > to_date ( p_effective_date, 'MM/DD/YYYY' ) then
                x_return_status := 'E';
                x_error_message := 'Effective date cannot be backdated beyond current quarter';
                raise e_error;
            end if;
        end loop;

        select
            count(*)
        into l_count
        from
            broker_assignments
        where
                broker_id = 209084
            and entrp_id = p_entrp_id
            and pers_id is null;

        if l_count > 0 then
            x_return_status := 'E';
            x_error_message := 'Employer is assigned to in-huse broker, Cannot change broker';
            raise e_error;
        end if;

        if p_entrp_id is not null then
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    broker_id = p_broker_id
                and entrp_id = p_entrp_id
                and effective_end_date is null
                and pers_id is null;

            dbms_output.put_line('Clount' || l_count);
            if
                l_count > 0
                and p_broker_assignment_id is null
            then
                dbms_output.put_line('In Wrong ID' || l_count);
                x_return_status := 'E';
                x_error_message := 'Employer has been assigned with this broker already';
                raise e_error;
            end if;

            l_count := 0;
            if p_broker_assignment_id is not null then
                dbms_output.put_line('In IF' || p_broker_assignment_id);
                select
                    count(*)
                into l_count
                from
                    broker_assignments a,
                    account            b
                where
                        a.broker_id = p_broker_id
                    and a.entrp_id = p_entrp_id
                    and a.entrp_id = b.entrp_id
                    and a.broker_id = b.broker_id
                    and a.effective_end_date is null
                    and a.pers_id is null;

                pc_log.log_error('PC_BROKER', 'count '
                                              || l_count
                                              || ' end date '
                                              || p_effective_end_date);
                if
                    l_count = 1
                    and p_effective_end_date is not null
                then
                    pc_log.log_error('PC_BROKER', 'In Error '
                                                  || l_count
                                                  || ' end date '
                                                  || p_effective_end_date);
                    x_return_status := 'E';
                    x_error_message := 'Cannot end date broker associated with account';
                    raise e_error;
                end if;

            end if;

            l_count := 0;
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    effective_date > to_date(p_effective_date, 'MM/DD/YYYY')
                and entrp_id = p_entrp_id
                and broker_id <> p_broker_id
                and effective_end_date is null
                and pers_id is null;

            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'A Broker has been already assigned with future effective date, Update the effective date of the broker
                       with future effective date and then add this broker';
                raise e_error;
            end if;

            l_count := 0;
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    trunc(effective_date) = to_date(p_effective_date, 'MM/DD/YYYY')
                and entrp_id = p_entrp_id
                and broker_id <> p_broker_id
                and effective_end_date is null
                and broker_id <> 0
                and pers_id is null;

            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'There is already a broker assigned with same effective date, Cannot assign this broker';
                raise e_error;
            end if;

        end if;

    end validate_broker_data;

    procedure assign_sales_team (
        p_entrp_id    in number,
        p_entity_type in varchar2,
        p_entity_id   in number,
        p_eff_date    in date,
        p_user_id     in number
    ) is

        l_count                number;
        l_broker_id            number;
        broker_not_found exception;
        l_sqlerrm              varchar2(3200);
        l_rowcount             number;
        l_sales_team_member_id number;
        l_sls_count            number;
        l_sls_count2           number;
    begin
        pc_log.log_error('pc_sales_team.assign_sales_team', 'In proc');
        select
            count(*)
        into l_sls_count
        from
            sales_team_member
        where
                emplr_id = p_entrp_id
            and entity_type = p_entity_type
            and status = 'A'
            and ( entity_id is null
                  or entity_id <> p_entity_id );

        if l_sls_count > 0 then
            update sales_team_member
            set
                end_date = nvl(p_eff_date, sysdate) - 1,
                status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
                and end_date is null
                and entity_id <> p_entity_id;

        end if;

        if p_entity_type <> 'SALES_REP' then
            l_sls_count := 0;
            select
                count(*)
            into l_sls_count
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and status = 'A'
                and entity_type = p_entity_type
                and ( entity_id is null
                      or entity_id = p_entity_id );

            if l_sls_count = 0 then
                pc_sales_team.cre_sales_team_member(
                    entity_type_in           => p_entity_type,
                    entity_id_in             => p_entity_id,
                    mem_role_in              => 'PRIMARY',
                    emplr_id_in              => p_entrp_id,
                    start_date_in            => nvl(p_eff_date, sysdate),
                    end_date_in              => null,
                    status_in                => 'A',
                    creation_date_in         => sysdate,
                    created_by_in            => p_user_id,
                    last_update_date_in      => sysdate,
                    last_updated_by_in       => p_user_id,
                    pay_commission_in        => 'Y',
                    notes_in                 => 'Assigning ' || initcap(p_entity_type),
                    no_of_days_in            => null,
                    sales_team_member_id_out => l_sales_team_member_id
                );
            end if;

        elsif p_entity_type = 'SALES_REP' then
            l_sls_count := 0;
            l_sls_count2 := 0;
            select
                count(*)
            into l_sls_count2
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and status = 'A'
                and entity_type = p_entity_type
                and entity_id is null;

            if l_sls_count2 <> 0 then
                pc_log.log_error('pc_sales_team.assign_sales_team', 'Updating entity id');
                update sales_team_member
                set
                    entity_id = p_entity_id
                where
                        entity_type = 'SALES_REP'
                    and emplr_id = p_entrp_id
                    and entity_id is null;

                update account
                set
                    salesrep_id = p_entity_id
                where
                    entrp_id = p_entrp_id;

                update account
                set
                    salesrep_id = p_entity_id
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            person
                        where
                            entrp_id = p_entrp_id
                    );

            end if;

            if l_sls_count2 = 0 then --No record for NULL entity ID

                select
                    count(*)
                into l_sls_count
                from
                    sales_team_member
                where
                        emplr_id = p_entrp_id
                    and status = 'A'
                    and entity_type = p_entity_type
                    and ( entity_id = p_entity_id );

                if l_sls_count = 0 then
                    pc_log.log_error('pc_sales_team.assign_sales_team', 'Create New Entry');
                    pc_sales_team.cre_sales_team_member(
                        entity_type_in           => p_entity_type,
                        entity_id_in             => p_entity_id,
                        mem_role_in              => 'PRIMARY',
                        emplr_id_in              => p_entrp_id,
                        start_date_in            => nvl(p_eff_date, sysdate),
                        end_date_in              => null,
                        status_in                => 'A',
                        creation_date_in         => sysdate,
                        created_by_in            => p_user_id,
                        last_update_date_in      => sysdate,
                        last_updated_by_in       => p_user_id,
                        pay_commission_in        => 'Y',
                        notes_in                 => 'Assigning ' || initcap(p_entity_type),
                        no_of_days_in            => null,
                        sales_team_member_id_out => l_sales_team_member_id
                    );

                    pc_log.log_error('SalesTeam', 'After Create');
                else --If we already have an entry in Sales table for this comination of ER and Salesrep

                    update account
                    set
                        salesrep_id = p_entity_id,
                        last_updated_by = p_user_id
                    where
                        entrp_id = p_entrp_id;

                    update account
                    set
                        salesrep_id = p_entity_id,
                        last_updated_by = p_user_id
                    where
                        pers_id in (
                            select
                                pers_id
                            from
                                person
                            where
                                entrp_id = p_entrp_id
                        );

                end if;

            end if; -- Null Entity ID
        end if;  --Entity Type Loop

    exception
        when others then
            pc_log.log_error('pc_sales_team.assign_sales_team', sqlerrm);
            raise_application_error(-20000, 'Error in processing your request, contact IT ' || sqlerrm);
    end assign_sales_team;

    procedure upsert_sales_team_member (
        p_entity_type           in varchar2,
        p_entity_id             in number,
        p_mem_role              in varchar2,
        p_entrp_id              in number,
        p_start_date            in date,
        p_end_date              in date,
        p_status                in varchar2,
        p_user_id               in number,
        p_pay_commission        in varchar2,
        p_note                  in varchar2,
        p_no_of_days            in number,
        px_sales_team_member_id in out number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    ) is

        l_count                number;
        l_broker_id            number;
        l_exist_broker_id      number; -- added by Jaggi #9902
        l_acc_id               number;  -- added by Jaggi #9902
        l_sales_rep_id         number;
        l_ga_id                number;
        l_cs_rep_id            number;
        broker_not_found exception;
        l_sqlerrm              varchar2(3200);
        l_rowcount             number;
        l_sales_team_member_id number;
        l_sls_count            number := 0;
        l_same_sls_count       number := 0;
        l_am_id                number;
        l_return_status        varchar2(1);
        l_return_message       varchar2(4000);
    begin
        x_return_status := 'S';
        pc_log.log_error('p_entity_id', p_entity_id);
        pc_log.log_error('p_mem_role', p_mem_role);
        --pc_log.log_error ('pc_sales_team', 'entered salesrep update');

    -- Added by Joshi for 5022. for salesmember role should be checked.
        if p_entity_type = 'SALES_REP' then
            select
                count(*)
            into l_sls_count
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
                and mem_role = p_mem_role
                and status = 'A'
                and ( entity_id is null
                      or entity_id <> p_entity_id );

        else
            select
                count(*)
            into l_sls_count
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
                and status = 'A'
                and ( entity_id is null
                      or entity_id <> p_entity_id );

        end if;
      --code ends here.

        if p_entity_type = 'SALES_REP' then
            l_sales_rep_id := p_entity_id;
        end if;
        if p_entity_type = 'BROKER' then
            l_broker_id := p_entity_id;
             -- added by jaggi #9902
            for j in (
                select
                    acc_id,
                    broker_id
                from
                    account
                where
                    entrp_id = p_entrp_id
            ) loop
                l_exist_broker_id := j.broker_id;
                l_acc_id := j.acc_id;
            end loop;

        end if;

        if p_entity_type = 'GENERAL_AGENT' then
            l_ga_id := p_entity_id;
        end if;
        if p_entity_type = 'CS_REP' then
            l_cs_rep_id := p_entity_id;
        end if;

       -- coded modified by Joshi for 5022. for salesrep deactivate existing salesrep with same role.
        if
            l_sls_count > 0
            and p_entity_type = 'SALES_REP'
        then
            pc_log.log_error('pc_sales_team', 'entered salesrep update');
            update sales_team_member
            set
                end_date = nvl(p_start_date, sysdate) - 1,
                status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
                and mem_role = p_mem_role
                and end_date is null
                and entity_id <> p_entity_id;

        elsif l_sls_count > 0 then
            pc_log.log_error('pc_sales_team', 'entered > count');
            update sales_team_member
            set
                end_date = nvl(p_start_date, sysdate) - 1,
                status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
                and end_date is null
                and entity_id <> p_entity_id;

        end if;

        l_same_sls_count := 0;
      -- Added by Joshi for 5022. same sales team member can parimary/secondary role.
        if p_entity_type = 'SALES_REP' then
            select
                count(*)
            into l_same_sls_count
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
                and mem_role = p_mem_role
                and status = 'A';
          -- AND    (ENTITY_ID IS NULL OR ENTITY_ID = P_ENTITY_ID);

        else
            select
                count(*)
            into l_same_sls_count
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
                and status = 'A'
                and ( entity_id is null
                      or entity_id = p_entity_id );

        end if;

        if l_same_sls_count = 0 then
            pc_sales_team.cre_sales_team_member(
                entity_type_in           => p_entity_type,
                entity_id_in             => p_entity_id,
                mem_role_in              => nvl(p_mem_role, 'PRIMARY'),
                emplr_id_in              => p_entrp_id,
                start_date_in            => p_start_date,
                end_date_in              => null,
                status_in                => 'A',
                creation_date_in         => sysdate,
                created_by_in            => p_user_id,
                last_update_date_in      => sysdate,
                last_updated_by_in       => p_user_id,
                pay_commission_in        => p_pay_commission,
                notes_in                 => 'Assigning ' || initcap(p_entity_type),
                no_of_days_in            => p_no_of_days,
                sales_team_member_id_out => l_sales_team_member_id
            );

            px_sales_team_member_id := l_sales_team_member_id;

                    -- hari added for   INC28081 - COBRA Welcome Letter 06/09/2025
            pc_log.log_error('PC_sales_team before calling run_cobra_welcome_letters p_entity_id/p_entity_type/p_entrp_id/l_same_sls_count/l_sls_count'
            , p_entity_id
                                                                                                                                                       || '/'
                                                                                                                                                       || p_entity_type
                                                                                                                                                       || '/'
                                                                                                                                                       || p_entrp_id
                                                                                                                                                       || '/'
                                                                                                                                                       || l_same_sls_count
                                                                                                                                                       || '/'
                                                                                                                                                       || l_sls_count
                                                                                                                                                       )
                                                                                                                                                       ;

            if
                p_entity_type = 'CS_REP'
                and l_sls_count = 0
            then
                pc_notices.run_cobra_welcome_letters(p_entrp_id);
            end if;

        else
            pc_sales_team.updt_sales_team_member(
                sales_team_member_id_in => px_sales_team_member_id,
                entity_type_in          => p_entity_type,
                entity_id_in            => p_entity_id,
                mem_role_in             => p_mem_role,
                emplr_id_in             => p_entrp_id,
                start_date_in           => nvl(p_start_date, sysdate),
                end_date_in             => p_end_date,
                status_in               =>
                           case
                               when p_end_date is not null then
                                   'I'
                               else
                                   p_status
                           end,
                last_update_date_in     => sysdate,
                last_updated_by_in      => p_user_id,
                pay_commission_in       => p_pay_commission,
                notes_in                => p_note,
                no_of_days_in           => p_no_of_days
            );
        end if;

      -- Validating the Broker, Salesrep etc
      --
        for x in (
            select
                sum(
                    case
                        when status = 'A' then
                            1
                        else
                            0
                    end
                ) active_count,
                sum(
                    case
                        when status = 'I' then
                            1
                        else
                            0
                    end
                ) inactive_count,
                entity_type
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and entity_type = p_entity_type
            group by
                entity_type
        ) loop
            if
                x.active_count = 0
                and x.inactive_count > 0
            then
                if x.entity_type = 'SALES_REP' then
                    l_sales_rep_id := null;
                end if;
                if x.entity_type = 'BROKER' then
                    l_broker_id := 0;
                end if;
                if x.entity_type = 'CS_REP' then
                    l_cs_rep_id := null;
                end if;
                if x.entity_type = 'GENERAL_AGENT' then
                    l_ga_id := null;
                end if;
            end if;
        end loop;

      -- commented and added by Joshi for 5022.
      -- update account table with primary/secondary salesrep_id
      --IF P_ENTITY_TYPE = 'SALES_REP' THEN
        if p_entity_type = 'SALES_REP' then
            l_sales_rep_id := null;
            for x in (
                select
                    entity_id,
                    mem_role
                from
                    sales_team_member
                where
                        emplr_id = p_entrp_id
                    and entity_type = 'SALES_REP'
                   --AND MEM_ROLE = 'PRIMARY'
                    and status = 'A'
            ) loop
                if
                    x.mem_role = 'PRIMARY'
                    and x.entity_id is not null
                then
                    l_sales_rep_id := x.entity_id;
                elsif
                    x.mem_role = 'SECONDARY'
                    and x.entity_id is not null
                then
                    l_am_id := x.entity_id;
                end if;
            end loop;

            update account c
            set
                salesrep_id = l_sales_rep_id,
                am_id = l_am_id,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                note = '**Salesrep assignment '
            where
                entrp_id = p_entrp_id;
         --and salesrep_id <> l_sales_rep_id;

            update account c
            set
                salesrep_id = l_sales_rep_id,
                am_id = l_am_id,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                note = '**Salesrep assignment '
            where
                pers_id is not null
        -- and salesrep_id <> l_sales_rep_id
                and pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        entrp_id = p_entrp_id
                );

        end if;

        if p_entity_type = 'BROKER' then
            if l_broker_id = 0 then
                update broker_assignments
                set
                    effective_end_date = nvl(
                        nvl(p_end_date, p_start_date),
                        sysdate
                    ) - 1,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                        entrp_id = p_entrp_id
                    and effective_end_date is null;

            else
                update broker_assignments
                set
                    effective_end_date = nvl(
                        nvl(p_end_date, p_start_date),
                        sysdate
                    ) - 1,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                        entrp_id = p_entrp_id
                    and broker_id <> nvl(l_broker_id, 0)
                    and trunc(effective_date) <= nvl(
                        nvl(p_end_date, p_start_date),
                        sysdate
                    )
                    and effective_end_date is null;

                if
                    l_same_sls_count = 0
                    and l_broker_id is not null
                    and l_broker_id <> 0
                then
                    insert into broker_assignments (
                        broker_assignment_id,
                        broker_id,
                        entrp_id,
                        effective_date,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        status
                    )
                        select
                            broker_assignment_seq.nextval,
                            nvl(l_broker_id, 0),
                            p_entrp_id,
                            nvl(p_start_date, sysdate),
                            sysdate,
                            p_user_id,
                            sysdate,
                            p_user_id,
                            'A'
                        from
                            dual
                        where
                            not exists (
                                select
                                    *
                                from
                                    broker_assignments
                                where
                                        entrp_id = p_entrp_id
                                    and broker_id = l_broker_id
                                    and effective_end_date is null
                            );

                end if;

            end if;

            update account c
            set
                broker_id = nvl(l_broker_id, 0),
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                note = '**Broker assignment '
            where
                    entrp_id = p_entrp_id
                and broker_id <> nvl(l_broker_id, 0);

            update account c
            set
                broker_id = nvl(l_broker_id, 0),
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                note = '**Broker assignment '
            where
                pers_id is not null
                and broker_id <> nvl(l_broker_id, 0)
                and pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        entrp_id = p_entrp_id
                );
             --added by Jaggi 9902 remove previous broker user's access
            if nvl(l_exist_broker_id, 0) <> nvl(l_broker_id, 0) then
                pc_broker.remove_broker_authorize(l_exist_broker_id, l_acc_id);
            end if;

            -- Added by Joshi for 11086. need to create authorization as when broker is assigned.
            if
                nvl(l_exist_broker_id, 0) = 0
                and nvl(l_broker_id, 0) > 0
            then
                pc_broker.create_broker_authorize(
                    p_broker_id        => l_broker_id,
                    p_acc_id           => l_acc_id,
                    p_broker_user_id   => null,
                    p_authorize_req_id => null,
                    p_user_id          => p_user_id,
                    x_error_status     => l_return_status,
                    x_error_message    => l_return_message
                );
            end if;

        end if;

        if p_entity_type = 'GENERAL_AGENT' then
            update account c
            set
                ga_id = l_ga_id,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                note = '**General Agent assignment '
            where
                entrp_id = p_entrp_id;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end upsert_sales_team_member;

    procedure assign_to_house_account is

        l_sales_team_member_id number;
        l_return_status        varchar2(30);
        l_error_message        varchar2(2500);
        l_exist_cnt            number := 0;
    begin
        for x in (
            select
                pers_id,
                acc_num,
                entrp_id,
                broker_id,
                salesrep_id
            from
                account
            where
                    trunc(sysdate - greatest(creation_date, start_date)) >= 60
                and account_type = 'HSA'
                and entrp_id is not null
                and salesrep_id is null
            union
            select
                pers_id,
                acc_num,
                entrp_id,
                broker_id,
                salesrep_id
            from
                account
            where
                    trunc(sysdate - greatest(creation_date, start_date)) >= 60
                and account_type = 'HSA'
                and entrp_id is not null
                and broker_id = 0
        ) loop
            if
                x.salesrep_id is null
                and x.entrp_id is not null
            then
                pc_sales_team.cre_sales_team_member(
                    entity_type_in           => 'SALES_REP',
                    entity_id_in             => 541 -- Sterling in house rep
                    ,
                    mem_role_in              => 'PRIMARY',
                    emplr_id_in              => x.entrp_id,
                    start_date_in            => sysdate,
                    end_date_in              => null,
                    status_in                => 'A',
                    creation_date_in         => sysdate,
                    created_by_in            => 0,
                    last_update_date_in      => sysdate,
                    last_updated_by_in       => 0,
                    pay_commission_in        => 'Y',
                    notes_in                 => 'Assigning Salesrep',
                    no_of_days_in            => 0,
                    sales_team_member_id_out => l_sales_team_member_id
                );
            end if;

            if
                x.broker_id = 0
                and x.entrp_id is not null
            then
      -- If a No broker has alreaby been assigned programatically thru PC_AUTO_PROCESS
        --then we should not make multiple entries
                select
                    count(1)
                into l_exist_cnt
                from
                    sales_team_member
                where
                        emplr_id = x.entrp_id
                    and entity_id = 209084;

                if l_exist_cnt = 0 then
                    pc_sales_team.cre_sales_team_member(
                        entity_type_in           => 'BROKER',
                        entity_id_in             => 209084,
                        mem_role_in              => null,
                        emplr_id_in              => x.entrp_id,
                        start_date_in            => sysdate,
                        end_date_in              => null,
                        status_in                => 'A',
                        creation_date_in         => sysdate,
                        created_by_in            => 0,
                        last_update_date_in      => sysdate,
                        last_updated_by_in       => 0,
                        pay_commission_in        => 'Y',
                        notes_in                 => 'Assigning Broker',
                        no_of_days_in            => 0,
                        sales_team_member_id_out => l_sales_team_member_id
                    );

                end if;

            end if;

        end loop;

        for x in (
            select
                a.pers_id,
                a.acc_num,
                b.entrp_id,
                e.broker_id,
                e.salesrep_id
            from
                account a,
                person  b,
                account e
            where
                    trunc(sysdate - greatest(a.creation_date, a.start_date)) >= 60
                and a.account_type = 'HSA'
                and a.account_status in ( 1, 2 )
                and a.pers_id is not null
                and a.salesrep_id is null
                and a.pers_id = b.pers_id
                and b.entrp_id = e.entrp_id
        ) loop
            update account
            set
                salesrep_id = nvl(x.salesrep_id, 541),
                last_update_date = sysdate
            where
                    pers_id = x.pers_id
                and salesrep_id is null;

            if x.broker_id = 0 then
                pc_sales_team.insert_broker_data(
                    p_broker_id      => 209084,
                    p_entrp_id       => x.entrp_id,
                    p_pers_id        => x.pers_id,
                    p_effective_date => to_char(sysdate, 'MM/DD/YYYY'),
                    p_user_id        => 0,
                    x_return_status  => l_return_status,
                    x_error_message  => l_error_message
                );

            end if;

            dbms_output.put_line('return status ' || l_return_status);
        end loop;

    end assign_to_house_account;

    function get_sales_rep_id (
        p_salesrep_name in varchar2
    ) return number is
        l_salesrep_id number(10);
    begin
        for x in (
            select
                salesrep_id
            from
                salesrep
            where
                upper(name) like upper(p_salesrep_name)
                                 || '%'
        ) loop
            l_salesrep_id := x.salesrep_id;
        end loop;

        return l_salesrep_id;
    exception
        when others then
            return null;
    end get_sales_rep_id;

    procedure export_salesrep_data (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) is

        l_file                 utl_file.file_type;
        l_buffer               raw(32767);
        l_amount               binary_integer := 32767;
        l_pos                  integer := 1;
        l_blob                 blob;
        l_blob_len             integer;
        exc_no_file exception;
        l_create_ddl           varchar2(32000);
        lv_dest_file           varchar2(300);
        l_sqlerrm              varchar2(32000);
        l_create_error exception;
        l_batch_number         number;
        l_valid_plan           number(10);
        l_acc_id               number(10);
        x_return_status        varchar2(10);
        x_error_message        varchar2(2000);
        l_sales_team_member_id number;
        v_entrp_id             number;     -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
        v_seq                  number;     -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
    begin
        x_batch_number := batch_num_seq.nextval;
        pc_log.log_error('PC FILE UPLOAD.Export_Salesrep_Data', 'pv_file_name :' || pv_file_name);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
    /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('REPORT_DIR', pv_file_name, 'w', 32767);
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
            pc_log.log_error('PC FILE UPLOAD.Export_Salesrep_Data', 'Before delete File');
            delete from wwv_flow_files
            where
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            execute immediate '
         ALTER TABLE sales_assignment_external
         location (REPORT_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of Salesrep file' || sqlerrm;
                raise l_create_error;
        end;

        pc_log.log_error('PC FILE UPLOAD.Export_Salesrep_Data', 'Extrenal Table');
        for x in (
            select
                entrp_id,
                pc_sales_team.get_sales_rep_id(b.sales_rep_name) salesrep_id,
                b.effective_date,
                a.acc_num,
                a.acc_id,       -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
                decode(
                    upper(b.salesrep_role),
                    'PRIMARY',
                    pc_sales_team.get_sales_rep_name(a.salesrep_id),
                    pc_sales_team.get_sales_rep_name(a.am_id)
                )                                                old_salesrep,
                b.sales_rep_name                                 new_salesrep,
                b.salesrep_role                                  salesrep_role
            from
                account                   a,
                sales_assignment_external b
            where
                    a.acc_num = b.acc_num
                and b.sales_rep_name is not null
                and b.salesrep_role is not null
                and b.effective_date is not null
        ) loop
            pc_log.log_error('PC FILE UPLOAD.Export_Salesrep_Data', 'In loop');
            x_return_status := 'S';    -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
            x_error_message := null;    -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
            v_seq := sales_assignment_staging_seq.nextval;   -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)

            insert into sales_assignment_staging (
                acc_num,
                salesrep_name,
                effective_date,
                old_salesrep_name,
                batch_num,
                creation_date,
                created_by,
                last_updated_by,
                last_update_date,
                salesrep_role,
                entrp_id,
                sales_stag_id       -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
            ) values ( x.acc_num,
                       x.new_salesrep,
                       x.effective_date,
                       x.old_salesrep,
                       x_batch_number ---Batch Num
                       ,
                       sysdate,
                       p_user_id,
                       p_user_id,
                       sysdate,
                       upper(x.salesrep_role) -- added by Joshi for 5353
                       ,
                       x.entrp_id -- added by Joshi for 5353
                       ,
                       v_seq          -- Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
                        );

            if upper(x.salesrep_role) not in ( 'PRIMARY', 'SECONDARY' ) then   -- Jagadeesh #7940
                x_return_status := 'E';
                x_error_message := 'Role should be only PRIMARY or SECONDARY';
            end if;
          /* pc_sales_team.assign_sales_team (P_ENTRP_ID   =>X.ENTRP_ID
                                , P_ENTITY_TYPE => 'SALES_REP'
                                , P_Entity_Id   => X.Salesrep_Id
                                , P_EFF_DATE    => to_date(x.effective_date,'mm-dd-rrrr')
                                , P_USER_ID     => p_user_id);
          */
            if nvl(x_return_status, 'S') = 'S' then
      -- Start Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
      -- Check if its an employer or an subscriber
                v_entrp_id := pc_entrp.get_entrp_id(x.acc_num);

	  -- If its subscriber
                if nvl(v_entrp_id, 0) = 0 then
                    pc_sales_team.update_account_subcriber(
                        p_acc_id        => x.acc_id,
                        p_acc_num       => x.acc_num,
                        p_salesrep_id   => x.salesrep_id,
                        p_mem_role      => upper(x.salesrep_role),
                        p_batch_number  => x_batch_number,
                        p_salesrep_name => x.new_salesrep,
                        x_return_status => x_return_status,
                        x_error_message => x_error_message
                    );

                else   -- End Swamy 11/07/2018 wrt Ticket#6074
          -- 5353: Joshi commented above and called upsert_sales_team_member as it is called from apex
          -- screen
                    if x.salesrep_id is not null then
                        pc_sales_team.upsert_sales_team_member(
                            p_entity_type           => 'SALES_REP',
                            p_entity_id             => x.salesrep_id,
                            p_mem_role              => upper(x.salesrep_role),
                            p_entrp_id              => x.entrp_id,
                            p_start_date            => to_date(x.effective_date, 'mm-dd-rrrr'),
                            p_end_date              => null,
                            p_status                => 'A',
                            p_user_id               => 0,
                            p_pay_commission        => null,
                            p_note                  => null,
                            p_no_of_days            => null,
                            px_sales_team_member_id => l_sales_team_member_id,
                            x_return_status         => x_return_status,
                            x_error_message         => x_error_message
                        );

                    end if;
                end if;   -- End Swamy 11/07/2018 wrt Ticket#6074
            end if;
	  -- Start Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
            if x_return_status = 'E' then
                update sales_assignment_staging
                set
                    error_message = x_error_message,
                    status = x_return_status
                where
                        batch_num = x_batch_number
                    and sales_stag_id = v_seq;

            end if;

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := ' Package Export_Salesrep_Data Others :=' || sqlerrm(sqlcode);
	  -- End Swamy 11/07/2018 wrt Ticket#6074
    end export_salesrep_data;

    function get_salesrep_detail (
        p_entrp_id in number,
        p_mem_role in varchar2
    ) return number is
        l_salesrep_id number(10);
    begin
        for x in (
            select
                entity_id
            from
                sales_team_member
            where
                    emplr_id = p_entrp_id
                and mem_role = p_mem_role
                and entity_type = 'SALES_REP'
                and status = 'A'
        ) loop
            l_salesrep_id := x.entity_id;
        end loop;

        return l_salesrep_id;
    exception
        when others then
            return null;
    end get_salesrep_detail;

  /*Ticket#5422 */
    function get_salesrep_email (
        p_salesrep_id in number
    ) return varchar2 is
        l_email varchar2(1000);
    begin
        select
            y.email
        into l_email
        from
            salesrep x,
            employee y
        where
                x.emp_id = y.emp_id
            and x.salesrep_id = p_salesrep_id;

        return l_email;
    exception
        when others then
            l_email := null;
            return l_email;
    end get_salesrep_email;

 -- Procedure Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
 -- Update The Salesrep And Account Manager Details For The Subscriber.
    procedure update_account_subcriber (
        p_acc_id        in number,
        p_acc_num       in varchar2,
        p_salesrep_id   in number,
        p_mem_role      in varchar2,
        p_batch_number  in number,
        p_salesrep_name in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

 -- For QA Ticket#6327
 -- Cursor to get the Account number of the Enterprise ID.
        cursor cur_entrp (
            vc_entrp_id in number
        ) is
        select
            acc_num
        from
            account
        where
            entrp_id = vc_entrp_id;

  -- Variable Declaration
        v_acc_num account.acc_num%type;

-- Exception Declaration
        erreur exception;
    begin
        pc_log.log_error('PC FILE UPLOAD.Update_Account_Subcriber Begin', 'P_Acc_Id :' || p_acc_id);
 -- Initializing The Error Status
        x_return_status := 'S';

    -- Raise exception if the Salesrep_Id is null
        if nvl(p_salesrep_id, 0) = 0 then
            x_return_status := 'E';
            x_error_message := 'There Is No Salesrep For  Account Number '
                               || p_acc_num
                               || ' , the salesrep name:= '
                               || p_salesrep_name
                               || ' is invalid';
            raise erreur;
        else
            for i in (
                select
                    status,
                    role_type
                from
                    salesrep
                where
                    salesrep_id = p_salesrep_id
            ) loop
                if i.status <> 'A' then
                    x_return_status := 'E';
                    x_error_message := 'The Salesrep Is Inactive';
                    raise erreur;
                end if;
		 -- Commented by swamy, as per discussion with BA team, the Bug Ticket#6319 is deffered.
        /*--Role_Type Added By Swamy For Bug On Ticket#6074, Bug Ticket#6319
        If Upper(P_Mem_Role) = 'PRIMARY' and Nvl(I.Role_Type,'*') <> 'SALESREP' Then
	       X_Return_Status := 'E';
	       X_Error_Message := 'The Salesrep Is Invalid';
	      Raise Erreur;
        ElsIf Upper(P_Mem_Role) = 'SECONDARY' and Nvl(I.Role_Type,'*') <> 'AM' Then
	       X_Return_Status := 'E';
	       X_Error_Message := 'The Account Manager Is Invalid';
	      Raise Erreur;
        End If;
		*/
            end loop;
        end if;

	-- Check If The Subscriber Belongs To Any Employer, If Yes Then Raise Exception
        for i in (
            select
                a.entrp_id,
                b.acc_num
            from
                person  a,
                account b
            where
                    nvl(a.entrp_id, 0) <> 0
                and a.pers_id = b.pers_id
                and b.acc_id = p_acc_id
        ) loop
            pc_log.log_error('PC FILE UPLOAD.Update_Account_Subcriber', 'I.Entrp_Id :' || i.entrp_id);
            if nvl(i.entrp_id, 0) <> 0 then
	     -- For QA Ticket#6327
                v_acc_num := null;
                open cur_entrp(i.entrp_id);
                fetch cur_entrp into v_acc_num;
                close cur_entrp;
         -- End For QA Ticket#6327
                x_return_status := 'E';
                x_error_message := 'The Subscriber '
                                   || p_acc_num
                                   || ' Is Already Attached To The Employer Account '
                                   || v_acc_num;
                raise erreur;
            end if;

        end loop;

        if x_return_status = 'S' then
      -- If In The Csv File, The Role Is Not Primary/Secondary, Then Raise Exception
            if nvl(
                upper(p_mem_role),
                '*'
            ) not in ( 'PRIMARY', 'SECONDARY' ) then
                x_error_message := ' The Role '
                                   || p_mem_role
                                   || ' for Account Number '
                                   || p_acc_num
                                   || ' is invalid, Please specify either Primary or Secondary';
                raise erreur;
            end if;

	  -- Update The Account Table For Salesrep When The Role Is Primary
            if upper(p_mem_role) = 'PRIMARY' then
                update account
                set
                    salesrep_id = p_salesrep_id
                where
                    acc_id = p_acc_id;
	  -- Update The Account Table For Account Manager When The Role Is Secondary
            elsif upper(p_mem_role) = 'SECONDARY' then
                update account
                set
                    am_id = p_salesrep_id
                where
                    acc_id = p_acc_id;

            end if;

        end if;

    exception
        when erreur then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := 'Package Update_Account_Subcriber Others For Account Number '
                               || p_acc_num
                               || ' Others '
                               || sqlerrm(sqlcode);
    end update_account_subcriber;
--End by Swamy on 11/07/2018 wrt Ticket#6074

-- Added by Joshi for 7703. get effective salerep based on invoice approval date.
    function get_sales_rep_id (
        p_entrp_id       in number,
        p_effective_date date,
        p_mem_role       in varchar2
    ) return number is
        l_salesrep_id number(10);
    begin
        for x in (
            select
                entity_id
            from
                sales_team_member
            where
                    p_effective_date >= start_date
                and ( ( end_date is not null
                        and end_date >= p_effective_date )
                      or end_date is null )
                and emplr_id = p_entrp_id
                and mem_role = p_mem_role
                and entity_type = 'SALES_REP'
        ) loop
            l_salesrep_id := x.entity_id;
        end loop;

        return l_salesrep_id;
    exception
        when others then
            return null;
    end get_sales_rep_id;

--- FOR COBRA Projects rprabu 30/06/2022
    function get_entity_id_er (
        p_entrp_id    in number,
        p_entity_name in varchar2
    )      --- get entity id for employer rprabu 19/09/2021
     return number is
        l_entity_id number;
    begin
        select
            entity_id
        into l_entity_id
        from
            sales_team_member
        where
                emplr_id = p_entrp_id
            and entity_type = p_entity_name
            and status = 'A'
            and end_date is null
            and rownum < 2;   ----  rprabu 15/12/2021 rownum added
        return l_entity_id;
    exception
        when no_data_found then
            l_entity_id := null;
            return l_entity_id;
    end;

--Added by Jaggi           
    function get_cust_srvc_rep_url_for_er (
        p_entrp_id in number
    ) return varchar2 is
        l_cust_rep_url varchar2(4000);
    begin
        select
            listagg(team_url, ',') within group(
            order by
                team_url
            ) url
        into l_cust_rep_url
        from
            employee
        where
            emp_id in (
                select
                    entity_id
                from
                    sales_team_member
                where
                        emplr_id = p_entrp_id
                    and entity_type = 'CS_REP'
                    and status = 'A'
                    and end_date is null
            );

        return l_cust_rep_url;
    exception
        when no_data_found then
            dbms_output.put_line('Error in Get TEAM_URL');
            return null;
    end get_cust_srvc_rep_url_for_er; 

--Added by Jaggi
    function get_cust_srvc_rep_phone_num_for_er (
        p_entrp_id in number
    ) return varchar2 is
        l_cust_rep_phone_num varchar2(3000);
    begin
        select
            listagg(day_phone, ',') within group(
            order by
                day_phone
            ) phone
        into l_cust_rep_phone_num
        from
            employee
        where
            emp_id in (
                select
                    entity_id
                from
                    sales_team_member
                where
                        emplr_id = p_entrp_id
                    and entity_type = 'CS_REP'
                    and status = 'A'
                    and end_date is null
            );

        return l_cust_rep_phone_num;
    exception
        when no_data_found then
         -----  dbms_output.put_line('Error in Get Customer Phone num');
            return null;
    end get_cust_srvc_rep_phone_num_for_er;

end pc_sales_team;
/

