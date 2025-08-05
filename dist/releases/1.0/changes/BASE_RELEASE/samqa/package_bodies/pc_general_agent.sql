-- liquibase formatted sql
-- changeset SAMQA:1754374033090 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_general_agent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_general_agent.sql:null:95187a39684487fa547938ae1a4e507d1411912d:create

create or replace package body samqa.pc_general_agent is

-- ????????? ???????? ????? ?????? ? ??????? (PERSON, BROKER)
    procedure cre_ga (
        agency_name_in           in general_agent.agency_name%type,
        contact_name_in          in general_agent.contact_name%type   ---rprabu 10/06/2020 8890
        ,
        address_in               in general_agent.address%type,
        city_in                  in general_agent.city%type,
        state_in                 in general_agent.state%type,
        zip_in                   in general_agent.zip%type,
        phone_day_in             in general_agent.phone%type,
        email_in                 in general_agent.email%type,
        start_date_in            in general_agent.start_date%type,
        end_date_in              in general_agent.end_date%type,
        ga_lic_in                in general_agent.ga_lic%type,
        ga_rate_in               in general_agent.ga_rate%type,
        note_in                  in general_agent.note%type,
        salesrep_id_in           in general_agent.salesrep_id%type,
        p_user_id                in number,
        p_generate_combined_stmt in varchar2   -- Added by jaggi #9830
        ,
        ga_id_out                out general_agent.ga_id%type
    ) is
        pers_id_v person.pers_id%type;
    begin

   -- Insert broker
        insert into general_agent (
            ga_id,
            agency_name,
            contact_name,
            address,
            city,
            state,
            zip,
            phone,
            email,
            start_date,
            end_date,
            ga_lic,
            ga_rate,
            note,
            salesrep_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            generate_combined_stmt
        ) values ( ga_seq.nextval,
                   agency_name_in,
                   contact_name_in,
                   address_in,
                   city_in,
                   state_in,
                   zip_in,
                   phone_day_in,
                   email_in,
                   start_date_in,
                   end_date_in,
                   'GA'
                   || lpad(ga_lic_seq.nextval, 4, '0') -- -8890 rprabu 24/06/2020
                   ,
                   ga_rate_in,
                   note_in,
                   salesrep_id_in,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   p_generate_combined_stmt ) returning ga_id into ga_id_out;

    end cre_ga;
-- ????????? ?????????? ?????? ? ??????? (PERSON, BROKER)

    procedure upd_ga (
        ga_id_in                 in general_agent.ga_id%type,
        agency_name_in           in general_agent.agency_name%type,
        contact_name_in          in general_agent.contact_name%type   ---rprabu 10/06/2020 8890
        ,
        address_in               in general_agent.address%type,
        city_in                  in general_agent.city%type,
        state_in                 in general_agent.state%type,
        zip_in                   in general_agent.zip%type,
        phone_day_in             in general_agent.phone%type,
        email_in                 in general_agent.email%type,
        start_date_in            in general_agent.start_date%type,
        end_date_in              in general_agent.end_date%type,
        ga_lic_in                in general_agent.ga_lic%type,
        ga_rate_in               in general_agent.ga_rate%type,
        note_in                  in general_agent.note%type,
        salesrep_id_in           in general_agent.salesrep_id%type,
        p_user_id                in number,
        p_generate_combined_stmt in varchar2   -- Added by jaggi #9830
    ) is
    begin
     -- Insert broker
        update general_agent
        set
            agency_name = agency_name_in,
            address = address_in,
            city = city_in,
            state = state_in,
            zip = zip_in,
            phone = phone_day_in,
            email = email_in,
            start_date = start_date_in,
            end_date = end_date_in,
            ga_lic = upper(ga_lic_in),
            ga_rate = ga_rate_in,
            note = note_in,
            salesrep_id = salesrep_id_in,
            last_update_date = sysdate,
            last_updated_by = p_user_id,
            generate_combined_stmt = p_generate_combined_stmt
        where
            ga_id = ga_id_in;

    end upd_ga;

    procedure del_ga (
        ga_id_in  in general_agent.ga_id%type,
        p_user_id in number
    ) is
    begin
        update general_agent
        set
            end_date = sysdate,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            ga_id = ga_id_in;

    end del_ga;

    function get_er_count (
        p_ga_id in number
    ) return number is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            account
        where
                account.ga_id = p_ga_id
            and entrp_id is not null;

        return l_count;
    end get_er_count;

    function get_pers_count (
        p_ga_id      in number,
        p_acc_status in number
    ) return number is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            account a,
            person  b
        where
                a.pers_id = b.pers_id
            and a.account_status = p_acc_status
            and b.entrp_id in (
                select
                    entrp_id
                from
                    account
                where
                        account.ga_id = p_ga_id
                    and entrp_id is not null
            );

        return l_count;
    end get_pers_count;

-- Added by rprabu for Ticket#8890
-- Procedure to update the flg_agree column of the GA.
-- After GA creation, for the first time GA login, user will be prompted with a message to agree/Disagree
-- an agreement in electronic format. This update is done in the below procedure. This message will appear only for the first time Broker Login.
    procedure upd_general_agent_flg_agree (
        p_ga_id     in number,
        p_flg_agree in varchar2
    ) is
    begin
        update general_agent
        set
            flg_agree = p_flg_agree
        where
            ga_id = p_ga_id;

    exception
        when others then
      ---x_return_status := 'E';
            pc_log.log_error('PC_GENERAL_AGENT.Upd_General_Agent_Flg_Agree  ', sqlerrm);
    end upd_general_agent_flg_agree;

-- Added by rprabu for Ticket#8890
    procedure update_ga_online (
        p_ga_id         in general_agent.ga_id%type,
        p_first_name    in person.first_name%type,
        p_last_name     in person.last_name%type,
        p_address       in person.address%type,
        p_city          in person.city%type,
        p_state         in person.state%type,
        p_zip           in person.zip%type,
        p_phone         in person.phone_day%type,
        p_email         in person.email%type,
        p_agency_name   in broker.agency_name%type,
        p_user_id       in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';

  ---- Update GA Details
        update general_agent
        set
            contact_name = nvl(p_last_name, contact_name),
            address = nvl(p_address, address),
            zip = nvl(p_zip, zip),
            phone = nvl(p_phone, phone),
            city = nvl(p_city, city),
            state = nvl(p_state, state),
            email = nvl(p_email, email),
            agency_name = nvl(p_agency_name, agency_name),
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            ga_id = p_ga_id;

        update contact
        set
            phone = nvl(p_phone, phone),
            email = nvl(p_email, email),
            last_name = nvl(p_last_name, last_name),
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            user_id = p_user_id;

        ----------- rprabu 22/06/2020 8890
        update user_security_info
        set
            verified_phone_number = nvl(p_phone, verified_phone_number)
        where
            user_id = p_user_id;

        for i in (
            select
                user_name
            from
                online_users
            where
                user_id = to_number(p_user_id)
        ) loop
            update online_users
            set
                email = nvl(p_email, email),
                last_update_date = sysdate
            where
                user_name = i.user_name;

        end loop;

    exception
        when others then
            x_return_status := 'E';
            pc_log.log_error('PC_GENERAL_AGENT.Update_GA_online  ', sqlerrm);
    end update_ga_online;

	--------rprabu -3/08/2020 9141
    function get_ga_name (
        p_ga_id in number
    ) return varchar2 is
        l_ga_name varchar2(500);
    begin
        select
            agency_name
        into l_ga_name
        from
            general_agent
        where
            ga_id = p_ga_id;

        return l_ga_name;
    exception
        when no_data_found then
            return null;
    end get_ga_name;

	-- Pending  CLient Info ## added by rprabu 03/08/2020
    function get_pending_client_info (
        p_ga_id       in number,
        p_client_name varchar2,
        p_acct_type   varchar2,
        p_acct_status varchar2,
        p_broker_name varchar2
    ) return get_pending_client_info_t
        pipelined
        deterministic
    is
        l_pending_client_info get_pending_client_info_row_t;
        l_acct_status         varchar2(100);
    begin
        pc_log.log_error('PC_GENERAL_AGENT.Get_Pending_client_Info  P_ga_id', p_ga_id
                                                                              || ' P_client_name :='
                                                                              || p_client_name
                                                                              || ' P_acct_type :='
                                                                              || p_acct_type
                                                                              || ' p_acct_status :='
                                                                              || p_acct_status
                                                                              || 'P_Broker_Name :='
                                                                              || p_broker_name);

		  /*If p_acct_status = 'A' Then
			 l_acct_status := '1';
		 Elsif p_acct_status = 'P' Then
			  l_acct_status := '3'||','||'6'||','||'8'||','||'9'||','||'11' ;   -- 11 Added by Swamy for Ticket#(12534)12629
		  End if;
          */
        for x in (
            select
                name                                                     client_name,
                start_date,
                acc_num,
                entrp_code,
                account_type,
                pc_lookups.get_meaning(account_type, 'ACCOUNT_TYPE')     account_type_desc      -- 9525 rprabu 05/10/2020
                ,
                account_status,
                entrp_phones,
                pc_lookups.get_meaning(account_status, 'ACCOUNT_STATUS') status,
                complete_flag,
                industry_type,
                enrolled_by,
                pc_users.get_user(entrp_code, 'E', '2')                  user_id,
                pc_users.get_email_from_taxid(entrp_code)                email,
                pc_broker.get_broker_name(b.broker_id)                   broker_name                       -- Added by Jaggi ##9603
                ,
                b.created_by                                                                 -- Added by Jaggi ##9793
                ,
                resubmit_flag                                                                -- added by jaggi #10431
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = b.entrp_id
                and account_type = nvl(p_acct_type, account_type)
                and upper(name) like upper('%'
                                           || p_client_name
                                           || '%')
                and upper(pc_broker.get_broker_name(b.broker_id)) like upper('%'
                                                                             || p_broker_name
                                                                             || '%')              -- Added by Jaggi ##9832
                and p_ga_id = decode(p_acct_status, 'A', ga_id, 'P', enrolled_by)             -- 9141 dhanya discussion if ER linked another GA , it should displayed to Ga2 Like Broker ticket.
                and decline_date is null                                                             -- Added by Jaggi #9893
                and ( ( p_acct_status = 'A'
                        and b.account_status = 1 )
                      or ( p_acct_status = 'P'
                           and b.account_status in ( 3, 6, 8, 9, 11 ) ) )    -- Added by Swamy for Ticket#(12534)12629
                --AND INSTR( NVL(l_acct_status,Account_Status)  , Account_Status  )  > 0

        ) loop
            l_pending_client_info.client_name := x.client_name;
            l_pending_client_info.ein := x.entrp_code;
            l_pending_client_info.user_id := x.user_id;
            l_pending_client_info.email := x.email;
            l_pending_client_info.account_number := x.acc_num;
            l_pending_client_info.acct_type := x.account_type;
            l_pending_client_info.account_type_desc := x.account_type_desc;          -- 9525 rprabu 05/10/2020
            l_pending_client_info.account_status := x.account_status;
            l_pending_client_info.status := x.status;
            l_pending_client_info.general_agent_id := x.enrolled_by;
            l_pending_client_info.general_agent_name := pc_general_agent.get_ga_name(x.enrolled_by);
            l_pending_client_info.broker_name := x.broker_name;              -- Added by Jaggi ##9603
            l_pending_client_info.created_by := pc_users.get_user_name(x.created_by);              -- Added by Jaggi ##9793
            l_pending_client_info.phone_number := x.entrp_phones;
            l_pending_client_info.complete_flag := x.complete_flag;
            l_pending_client_info.industry_type := x.industry_type;
            l_pending_client_info.resubmit_flag := x.resubmit_flag;
            pipe row ( l_pending_client_info );
        end loop;

    exception
        when others then
            pc_log.log_error('PC_GENERAL_AGENT.Get_Pending_client_Info', sqlerrm);
    end get_pending_client_info;

-- Added by Jaggi #
    function get_ga_info (
        p_ga_id in number
    ) return ga_info_row_t
        pipelined
        deterministic
    is
        l_ga_info_rec ga_info_row_rec;
    begin
        for x in (
            select
                ga_id,
                agency_name,
                address,
                city,
                state,
                zip,
                phone,
                email,
                generate_combined_stmt,
                ga_lic  -- Added by Joshi for 12396
            from
                general_agent
            where
                ga_id = p_ga_id
        ) loop
            l_ga_info_rec.ga_id := x.ga_id;
            l_ga_info_rec.agency_name := x.agency_name;
            l_ga_info_rec.address := x.address;
            l_ga_info_rec.city := x.city;
            l_ga_info_rec.state := x.state;
            l_ga_info_rec.zip := x.zip;
            l_ga_info_rec.phone := x.phone;
            l_ga_info_rec.email := x.email;
            l_ga_info_rec.generate_combined_stmt := x.generate_combined_stmt;
            l_ga_info_rec.ga_lic := x.ga_lic; -- Added by Joshi for 12396

            pipe row ( l_ga_info_rec );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_GENERAL_AGENT.Get_Ga_Info', sqlerrm);
    end get_ga_info;

    -- Added by Joshi for GA consolidated stmt

    function is_ga_consolidate_stmt_enabled (
        p_ga_id in number
    ) return varchar2 is
        ls_ga_stmt_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                nvl(generate_combined_stmt, 'N') generate_combined_stmt
            from
                general_agent
            where
                ga_id = p_ga_id
        ) loop
            ls_ga_stmt_flag := x.generate_combined_stmt;
        end loop;

        return ( ls_ga_stmt_flag );
    end is_ga_consolidate_stmt_enabled;

-- Added by Swamy for Ticket#11364
    procedure get_ga_id (
        p_user_id     in number,
        p_entity_type out varchar2,
        p_ga_id       out number
    ) is
    begin
        for k in (
            select
                a.user_type,
                b.ga_id
            from
                online_users  a,
                general_agent b
            where
                    a.user_id = p_user_id
                and a.find_key = b.ga_lic
        ) loop
            if nvl(k.user_type, '*') = 'G' then
                p_entity_type := 'GA';
                p_ga_id := k.ga_id;
            end if;
        end loop;
    end get_ga_id;

end pc_general_agent;
/

