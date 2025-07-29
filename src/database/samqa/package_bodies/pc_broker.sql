create or replace package body samqa.pc_broker is

-- ????????? ???????? ????? ?????? ? ??????? (PERSON, BROKER)
    procedure cre_broker (
        first_name_in             in person.first_name%type,
        last_name_in              in person.last_name%type,
        address_mail_in1          in person.address%type                           --- Modified by rprabu on 07/02/2018
        ,
        address_mail_in2          in person.address%type                           --- Added by rprabu on 07/02/2018
        ,
        city_in                   in person.city%type,
        state_in                  in person.state%type,
        zip_in                    in person.zip%type,
        commissions_payable_to_in in broker.commissions_payable_to%type   --- Added by rprabu on 07/02/2018
        ,
        phy_address_flag_in       in person.phy_address_flag%type             --- Added by rprabu on 07/02/2018
        ,
        address_phy_in1           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        address_phy_in2           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        city_in1                  in person.city%type   			                         --- Added by rprabu on 07/02/2018
        ,
        state_in1                 in person.state%type                                    --- Added by rprabu on 07/02/2018
        ,
        zip_in1                   in person.zip%type                                        --- Added by rprabu on 07/02/2018
        ,
        phone_day_in              in person.phone_day%type,
        phone_evening_in          in person.phone_day%type                         --- Added by rprabu on 29/03/2018
        ,
        email_in                  in person.email%type,
        ssn_in                    in person.ssn%type,
        start_date_in             in broker.start_date%type,
        end_date_in               in broker.end_date%type,
        broker_lic_in             in broker.broker_lic%type,
        broker_rate_in            in broker.broker_rate%type,
        share_rate_in             in broker.share_rate%type,
        ga_rate_in                in broker.ga_rate%type,
        ga_id_in                  in broker.ga_id%type,
        note_in                   in broker.note%type,
        agency_name_in            in broker.agency_name%type,
        salesrep_id_in            in broker.salesrep_id%type,
        user_id_in                in number                                              --- Added by rprabu on  12/02/2018
        ,
        cheque_flag_in            in varchar2 default null                        --- Added by rprabu on  24/06/2019 for 7901
        ,
        reason_flag_in            in varchar2 default null                        --- Added by rprabu on  24/06/2019 for 7901
        ,
        p_am_id                   in number default null           --- Added by swamy on  01/07/2024 for 12247
        ,
        broker_id_out             out broker.broker_id%type
    ) is
        l_address_id person.pers_id%type;
        l_flag       varchar2(1) := null;
    begin

-- Assigning the value to address_Phy_in1.
        if address_phy_in1 is null then                          --- Added by rprabu on  12/02/2018
            l_flag := 'Y';
        else
            l_flag := 'N';
        end if;

   -- Insert person
   -- 6937 : Joshi commented commissions_payable_to_in field below.

        insert into person (
            pers_id,
            first_name,
            last_name,
            address,
            address2                                      --- Added by rprabu on 07/02/2018
            ,
            city,
            state,
            zip
  --,commissions_Payable_To                        --- Added by rprabu on 07/02/2018
            ,
            phy_address_flag  			                 --- Added by rprabu on 07/02/2018
            ,
            phone_day,
            phone_even                                    --- Added by rprabu on 29/03/2018
            ,
            email,
            ssn,
            person_type,
            created_by                      			     --- Added by rprabu on 12/02/2018
        ) values ( pers_seq.nextval,
                   first_name_in,
                   last_name_in
  --,address_mail_in1                    --- Modified by rprabu on 07/02/2018
  --,address_mail_in2                    --- Added by rprabu on 07/02/2018
  --,city_in
  --,state_in
  --,zip_in
                   ,
                   address_phy_in1   -- Start Added by Swamy for Ticket#12133 07052024
                   ,
                   address_phy_in2,
                   city_in1,
                   state_in1,
                   zip_in1,
                   phy_address_flag_in   -- End Added by Swamy for Ticket#12133 07052024
 -- ,commissions_payable_to_in          --- Added by rprabu on 07/02/2018
 -- ,replace(commissions_payable_to_in,'&#59;', '&')         --- Added by rprabu on 28/03/2018 told by Gopy
  --,l_flag                             --- Added by rprabu on 07/02/2018
                   ,
                   phone_day_in,
                   phone_evening_in                     --- Added by rprabu on 29/03/2018
                   ,
                   email_in,
                   ssn_in,
                   'BROKER',
                   user_id_in                            --- Added by rprabu on 12/02/2018
                    ) returning pers_id into broker_id_out;

   --- Insert into alternate address.added by RPRABU on 07/02/2018
   -- If l_flag ='N' Then   -- Commented by Swamy for Ticket#12133 07052024
        l_address_id := address_id_seq.nextval;
        insert into addresses (
            address_id,
            entity_type,
            entity_id,
            address1,
            address2,
            city,
            state,
            zip,
            creation_date,
            created_by
        ) values ( l_address_id,
                   'BROKER',
                   broker_id_out,
                   address_phy_in1,
                   address_phy_in2,
                   city_in1,
                   state_in1,
                   zip_in1,
                   sysdate,
                   user_id_in );
 --End if;

   -- Insert broker
        insert into broker (
            broker_id,
            start_date,
            end_date,
            broker_lic,
            broker_rate,
            share_rate,
            ga_rate,
            ga_id,
            note,
            agency_name,
            salesrep_id,
            created_by                            --------Added by RPRABU on 12/02/2018
            ,
            commissions_payable_to -- Added by Joshi for ticket 6937
            ,
            cheque_flag            ----Added by RPRABU on 24/06/2019
            ,
            reason_flag            ----Added by RPRABU on 24/06/2019
            ,
            am_id                  --- Added by swamy on  01/07/2024 for 12247

        ) values ( broker_id_out,
                   start_date_in,
                   end_date_in,
                   broker_lic_in,
                   broker_rate_in,
                   share_rate_in,
                   ga_rate_in,
                   ga_id_in,
                   note_in
  --,agency_name_in
                   ,
                   replace(agency_name_in, '&#59;', '&')   --- rprabu 28/03/2018 as told by Gopy
                   ,
                   salesrep_id_in,
                   user_id_in                               --------Added by RPRABU on 12/02/2018
                   ,
                   replace(commissions_payable_to_in, '&#59;', '&')         --- Added by rprabu on 28/03/2018 told by Gopy
                   ,
                   cheque_flag_in              ----Added by RPRABU on 24/06/2019
                   ,
                   reason_flag_in              ----Added by RPRABU on 24/06/2019
                   ,
                   p_am_id                     --- Added by swamy on  01/07/2024 for 12247
                    );

  -- Added by sam to include historic information of Salesrep... to include new broker/SalesrepID
        if salesrep_id_in is not null then
            insert into broker_salesrep_assignment (
                brk_salesrep_assign_id,
                broker_id,
                salesrep_id,
                effective_date,
                effective_end_date,
                status,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( broker_salesrep_assign_seq.nextval,
                       broker_id_out,
                       salesrep_id_in,
                       sysdate,
                       null,
                       'A',
                       sysdate,
                       user_id_in,
                       null,
                       null );

        end if;

    end cre_broker;
-- ????????? ?????????? ?????? ? ??????? (PERSON, BROKER)
    procedure upd_broker_online (
        broker_id_in    in broker.broker_id%type,
        first_name_in   in person.first_name%type,
        last_name_in    in person.last_name%type,
        address_in      in person.address%type,
        city_in         in person.city%type,
        state_in        in person.state%type,
        zip_in          in person.zip%type,
        phone_day_in    in person.phone_day%type,
        email_in        in person.email%type,
        broker_lic_in   in broker.broker_lic%type,
        agency_name_in  in broker.agency_name%type,
        user_name_in    in varchar2,
        p_user_id       in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        if pc_users.is_main_online_broker(p_user_id) = 'Y' then     --- Rupesh  issue 9132 02/06/2020

							-- UPDATE person
            update person
            set
                first_name = nvl(first_name_in, first_name),
                last_name = nvl(last_name_in, last_name),
                address = nvl(address_in, address),
                city = nvl(city_in, city),
                state = nvl(state_in, state),
                zip = nvl(zip_in, zip),
                phone_day = nvl(phone_day_in, phone_day),
                email = nvl(email_in, email)
							--  ,person_type  = 'BROKER'
                ,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                pers_id = broker_id_in;

                        	-- UPDATE broker
            update broker
            set
                broker_lic = nvl(broker_lic_in, broker_lic),
                note = note || 'Updated from online',
                agency_name = agency_name_in,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                broker_id = broker_id_in;

        else                                                                      --- Rupesh  issue 9132 02/06/2020

            update contact
            set
                phone = phone_day_in,
                email = email_in
            where
                user_id = p_user_id;

        end if;

        update online_users
        set
            find_key = nvl(broker_lic_in, find_key),
            email = nvl(email_in, email),
            tax_id = nvl(broker_lic_in, tax_id),
            last_update_date = sysdate
        where
            user_name = user_name_in;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end upd_broker_online;

    procedure upd_broker (
        broker_id_in              in broker.broker_id%type,
        first_name_in             in person.first_name%type,
        last_name_in              in person.last_name%type,
        address_mail_in1          in person.address%type                          --- Modified by rprabu on 07/02/2018
        ,
        address_mail_in2          in person.address%type                           --- Added by rprabu on 07/02/2018
        ,
        city_in                   in person.city%type,
        state_in                  in person.state%type,
        zip_in                    in person.zip%type,
        commissions_payable_to_in in broker.commissions_payable_to%type     --- Added by rprabu on 07/02/2018
        ,
        phy_address_flag_in       in person.phy_address_flag%type                  --- Added by rprabu on 07/02/2018
        ,
        address_phy_in1           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        address_phy_in2           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        city_in1                  in person.city%type   				                     --- Added by rprabu on 07/02/2018
        ,
        state_in1                 in person.state%type                                    --- Added by rprabu on 07/02/2018
        ,
        zip_in1                   in person.zip%type                                        --- Added by rprabu on 07/02/2018
        ,
        phone_day_in              in person.phone_day%type,
        email_in                  in person.email%type,
        ssn_in                    in person.ssn%type,
        start_date_in             in broker.start_date%type,
        end_date_in               in broker.end_date%type,
        broker_lic_in             in broker.broker_lic%type,
        broker_rate_in            in broker.broker_rate%type,
        share_rate_in             in broker.share_rate%type,
        ga_rate_in                in broker.ga_rate%type,
        ga_id_in                  in broker.ga_id%type,
        note_in                   in broker.note%type,
        agency_name_in            in broker.agency_name%type,
        salesrep_id_in            in broker.salesrep_id%type,
        verified_by_in            in broker.verified_by%type     				     --- Added by rprabu on  14/03/2018
        ,
        verified_date_in          in broker.verified_date%type   					 --- Added by rprabu on  14/03/2018
        ,
        user_id_in                in number                                            --- Added by rprabu on  12/02/2018
        ,
        cheque_flag_in            in varchar2 default null                        --- Added by rprabu on  24/06/2019 for 7901
        ,
        reason_flag_in            in varchar2 default null                        --- Added by rprabu on  24/06/2019 for 7901
        ,
        p_am_id                   in number default null           --- Added by swamy on  01/07/2024 for 12247
    ) is

        l_broker_lic    varchar2(255);
        l_address_id    number(9);                             			     --- Added by rprabu on  12/02/2018
        cursor c_address is
        select
            address_id
        from
            addresses  			 --- Added by rprabu on  12/02/2018
        where
            entity_id = broker_id_in;

    --- Added by rprabu on  14/03/2018   for ticket 5420
        l_verified_by   number;
        l_verified_date date;
        cursor c_verified is
        select
            verified_by,
            verified_date
        from
            broker
        where
            broker_id = broker_id_in;

    begin

  --   rprabu 07/02/2018
        l_address_id := null;
        open c_address;
        fetch c_address into l_address_id;
        close c_address;
        pc_log.log_error('broker_rate_in ', broker_rate_in);
        select
            broker_lic
        into l_broker_lic
        from
            broker
        where
            broker_id = broker_id_in;

        if phy_address_flag_in = 'N' then   	 --- Added by rprabu on  12/02/2018
   -- UPDATE person
   -- 6937 : Joshi commented commissions_payable_to_in field below.
            begin
                update person
                set
                    first_name = first_name_in,
                    last_name = last_name_in,
                    address = address_mail_in1         		 		       --- Modified  by rprabu on 07/02/2018
                    ,
                    address2 = address_mail_in2            					   --- Added by rprabu on 07/02/2018
                    ,
                    city = city_in,
                    state = state_in,
                    zip = zip_in
			 --, commissions_Payable_To     = commissions_payable_to_in       --- Added by rprabu on 07/02/2018
                    ,
                    phy_address_flag = 'N'                             --- Added by rprabu on 07/02/2018
                    ,
                    phone_day = phone_day_in,
                    email = email_in,
                    ssn = ssn_in
		   --  ,person_type  = 'BROKER'
                    ,
                    last_update_date = sysdate                       --- Added by rprabu on 12/02/2018
                    ,
                    last_updated_by = user_id_in                    --- Added by rprabu on 12/02/2018
                where
                    pers_id = broker_id_in;

            end;
			---- If physical address already not there then create the same.
            if l_address_id is null then ----l_address_id is  Null
                l_address_id := address_id_seq.nextval;
                insert into addresses (
                    address_id,
                    entity_type,
                    entity_id,
                    address1,
                    address2,
                    city,
                    state,
                    zip,
                    creation_date,
                    created_by
                ) values ( l_address_id,
                           'BROKER',
                           broker_id_in,
                           address_phy_in1,
                           address_phy_in2,
                           city_in1,
                           state_in1,
                           zip_in1,
                           sysdate,
                           user_id_in );

            else

				 -- If physical address already there then update
                update addresses
                set
                    address1 = address_phy_in1,
                    address2 = address_phy_in2,
                    city = city_in1,
                    state = state_in1,
                    zip = zip_in1,
                    last_updated_on = sysdate,
                    last_updated_by = user_id_in
                where
                    entity_id = broker_id_in;

            end if;  ----l_address_id is  Null
        elsif phy_address_flag_in = 'Y' then  --- Phy_address_flag_in = 'N' Then  	 --- Added by rprabu on  12/02/2018
            begin
                update person
                set
                    first_name = first_name_in,
                    last_name = last_name_in,
                    address = address_mail_in1,
                    address2 = address_mail_in2,
                    city = city_in,
                    state = state_in,
                    zip = zip_in
			 --, commissions_Payable_To     = commissions_payable_to_in
                    ,
                    phy_address_flag = 'Y',
                    phone_day = phone_day_in,
                    email = email_in,
                    ssn = ssn_in,
                    last_updated_by = user_id_in
                where
                    pers_id = broker_id_in;

            end;
        end if;

        open c_verified;  --- added by rprabu 14/03/2018 for ticket 5420
        fetch c_verified into
            l_verified_by,
            l_verified_date;
        close c_verified;
        if l_verified_by is null
           or l_verified_date is null then    --- added by rprabu 14/03/2018  for ticket 5420
            l_verified_by := verified_by_in;
            l_verified_date := verified_date_in;
        end if;    --- End by rprabu 14/03/2018 for ticket 5420

 -- end date salesrep update... to maintain salesrep  history.. SAM 

        for i in (
            select
                salesrep_id
            from
                broker
            where
                broker_id = broker_id_in
        ) loop
            if i.salesrep_id != salesrep_id_in then
                update broker_salesrep_assignment
                set
                    effective_end_date = sysdate - 1,
                    status = 'I',
                    last_updated_by = user_id_in,
                    last_update_date = sysdate
                where
                        broker_id = broker_id_in
                    and salesrep_id = i.salesrep_id;

         -- Added by sam to include historic information of Salesrep... include new broker/salerepID 
                insert into broker_salesrep_assignment (
                    brk_salesrep_assign_id,
                    broker_id,
                    salesrep_id,
                    effective_date,
                    effective_end_date,
                    status,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( broker_salesrep_assign_seq.nextval,
                           broker_id_in,
                           salesrep_id_in,
                           sysdate,
                           null,
                           'A',
                           sysdate,
                           user_id_in,
                           null,
                           null );

            end if;
        end loop;

        pc_log.log_error('upd_broker P_am_id ', p_am_id);

   -- Update broker
        update broker
        set
            start_date = start_date_in,
            end_date = end_date_in,
            broker_lic = broker_lic_in,
            broker_rate = broker_rate_in,
            share_rate = share_rate_in,
            ga_rate = ga_rate_in,
            ga_id = ga_id_in,
            note = note_in,
            agency_name = agency_name_in,
            salesrep_id = salesrep_id_in,
            verified_by = l_verified_by               --- Added by rprabu 14/03/2018  for ticket 5420
            ,
            verified_date = l_verified_date             --- Added by rprabu 14/03/2018  for ticket 5420
            ,
            last_updated_by = user_id_in  			     --- Added by rprabu on  12/02/2018
            ,
            commissions_payable_to = commissions_payable_to_in -- added by Joshi 6937 Commission payable field moved to BROKER
            ,
            cheque_flag = cheque_flag_in                --- Added by rprabu on  24/06/2019 for 7901
            ,
            reason_flag = reason_flag_in                --- Added by rprabu on  24/06/2019 for 7901
            ,
            am_id = p_am_id                       --- Added by swamy on  01/07/2024 for 12247
        where
            broker_id = broker_id_in;

        update online_users
        set
            find_key = nvl(broker_lic_in, find_key),
            tax_id = nvl(broker_lic_in, tax_id),
            last_update_date = sysdate,
            last_updated_by = user_id_in    --- Added by rprabu on  12/02/2018
        where
                tax_id = l_broker_lic
            and user_type = 'B';

    end upd_broker;

-- ????????? ???????? ?????? ? ??????? (PERSON, BROKER)
    procedure del_broker (
        broker_id_in in broker.broker_id%type
    ) is
    begin
        delete broker
        where
            broker_id = broker_id_in;

        delete person
        where
            pers_id = broker_id_in;

        delete addresses
        where
            entity_id = broker_id_in; -- Added by RPRABU 12/02/2018
    end del_broker;

    procedure validate_broker_assign (
        p_broker_assignment_id in number,
        p_broker_id            in number,
        p_entrp_id             in number,
        p_pers_id              in number,
        p_effective_date       in varchar2,
        p_effective_end_date   in varchar2,
        p_user_id              in number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
        l_count number;
        e_error exception;
    begin
        x_return_status := 'S';
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
 /*SELECT COUNT(*)--Commented on Duarte's Request
 INTO  l_count
 FROM  broker_assignments
 WHERE broker_id = 209084
 AND  entrp_id = p_entrp_id
 AND  pers_id IS NULL;

 IF l_count > 0 THEN
       x_return_status := 'E';
       x_error_message := 'Employer is assigned to in-house broker, Cannot change broker';
       RAISE e_error;

 END IF;*/

        if p_entrp_id is not null then
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    broker_id = p_broker_id
                and entrp_id = p_entrp_id
                and effective_date = to_date(p_effective_date, 'MM/DD/YYYY')
                and pers_id is null
                and effective_end_date is null
                and p_broker_assignment_id is null;

            if
                l_count > 0
                and p_broker_assignment_id is null
            then
                x_return_status := 'E';
                x_error_message := 'Employer has been assigned with this broker already';
                raise e_error;
            end if;

            l_count := 0;
            if p_broker_assignment_id is not null then
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

        else
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    broker_id = p_broker_id
                and pers_id = p_pers_id
                and effective_end_date is null
                and effective_date = to_date(p_effective_date, 'MM/DD/YYYY');

            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'Subscriber has been assigned with this broker already';
                raise e_error;
            end if;

            l_count := 0;
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    effective_date > to_date(p_effective_date, 'MM/DD/YYYY')
                and effective_end_date is null
                and pers_id = p_pers_id;

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
                and effective_end_date is null
                and entrp_id = p_pers_id
                and broker_id <> p_broker_id
                and broker_id <> 0;

            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'There is already a broker assigned with same effective date, Cannot assign this broker';
                raise e_error;
            end if;

            l_count := 0;
            if p_broker_assignment_id is not null then
                select
                    count(*)
                into l_count
                from
                    broker_assignments a,
                    account            b
                where
                        a.broker_id = p_broker_id
                    and a.pers_id = p_pers_id
                    and a.pers_id = b.pers_id
                    and effective_end_date is null
                    and a.broker_id = b.broker_id
                    and a.pers_id is not null;

                if
                    l_count = 1
                    and p_effective_end_date is not null
                then
                    x_return_status := 'E';
                    x_error_message := 'Cannot end date broker associated with account';
                    raise e_error;
                end if;

            end if;

        end if;

    exception
        when e_error then
            null;
    end validate_broker_assign;

    procedure insert_broker_assign (
        p_broker_assignment_id in number,
        p_broker_id            in number,
        p_entrp_id             in number,
        p_pers_id              in number,
        p_effective_date       in varchar2,
        p_salesrep_id          in varchar2,
        p_user_id              in number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
        l_count number;
        e_error exception;
    begin
        x_return_status := 'S';
        if p_entrp_id is not null then
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    broker_id = p_broker_id
                and entrp_id = p_entrp_id
                and effective_date = to_date(p_effective_date, 'MM/DD/YYYY')
                and pers_id is null;

            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'Employer has been assigned with this broker already';
                raise e_error;
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
                and pers_id is null;

            pc_log.log_error('PC_BROKER.INSERT_BROKER_ASSIGN', l_count);
            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'A Broker has been already assigned with future effective date, Update the effective date of the broker
                       with future effective date and then add this broker';
                raise e_error;
            end if;

            if x_return_status = 'S' then
                insert into broker_assignments (
                    broker_assignment_id,
                    broker_id,
                    pers_id,
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
                        pers_id,
                        entrp_id,
                        nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate),
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        'A'
                    from
                        (
                            select
                                pers_id,
                                entrp_id
                            from
                                person a
                            where
                                entrp_id = p_entrp_id
                            union
                            select
                                null,
                                p_entrp_id
                            from
                                dual
                        );

                update account
                set
                    broker_id = p_broker_id,
                    salesrep_id = nvl(p_salesrep_id, salesrep_id)
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            person
                        where
                            entrp_id = p_entrp_id
                    );

                update account
                set
                    broker_id = p_broker_id,
                    salesrep_id = nvl(p_salesrep_id, salesrep_id)
                where
                    entrp_id = p_entrp_id;

                if
                    p_broker_id <> 0
                    and p_entrp_id is not null
                then
                    pc_sales_team.assign_sales_team(
                        p_entrp_id    => p_entrp_id,
                        p_entity_type => 'BROKER',
                        p_entity_id   => p_broker_id,
                        p_eff_date    => to_date(p_effective_date, 'MM/DD/YYYY'),
                        p_user_id     => p_user_id
                    );
                end if;

                if
                    p_salesrep_id is not null
                    and p_entrp_id is not null
                then
                    pc_sales_team.assign_sales_team(
                        p_entrp_id    => p_entrp_id,
                        p_entity_type => 'SALES_REP',
                        p_entity_id   => p_salesrep_id,
                        p_eff_date    => to_date(p_effective_date, 'MM/DD/YYYY'),
                        p_user_id     => p_user_id
                    );
                end if;

                pc_log.log_error('PC_BROKER', 'Effective date'
                                              || p_effective_date
                                              || 'entrp id '
                                              || p_entrp_id
                                              || 'broker id '
                                              || p_broker_id);

                update broker_assignments
                set
                    effective_end_date = nvl(to_date(p_effective_date, 'MM/DD/YYYY') - 1, sysdate)
                where
                        trunc(effective_date) <= nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate)
                    and entrp_id = p_entrp_id
                    and broker_id <> p_broker_id
                    and effective_end_date is null;

            end if;

        else
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    broker_id = p_broker_id
                and pers_id = p_pers_id;

            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'Subscriber has been assigned with this broker already';
                raise e_error;
            end if;

            l_count := 0;
            select
                count(*)
            into l_count
            from
                broker_assignments
            where
                    effective_date > to_date(p_effective_date, 'MM/DD/YYYY')
                and pers_id = p_pers_id;

            if l_count > 0 then
                x_return_status := 'E';
                x_error_message := 'A Broker has been already assigned with future effective date, Update the effective date of the broker
                       with future effective date and then add this broker';
                raise e_error;
            end if;

            if x_return_status = 'S' then
                insert into broker_assignments (
                    broker_assignment_id,
                    broker_id,
                    pers_id,
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
                        p_pers_id,
                        entrp_id,
                        nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate),
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        'A'
                    from
                        person a
                    where
                        pers_id = p_pers_id;

                update account
                set
                    broker_id = p_broker_id,
                    salesrep_id = nvl(p_salesrep_id, salesrep_id)
                where
                    pers_id = p_pers_id;

                update broker_assignments
                set
                    effective_end_date = to_date(p_effective_date, 'MM/DD/YYYY') - 1
                where
                        trunc(effective_date) <= to_date(p_effective_date, 'MM/DD/YYYY')
                    and pers_id = p_pers_id
                    and broker_id <> p_broker_id
                    and effective_end_date is null;

            end if;

        end if;

    exception
        when e_error then
            null;
    end insert_broker_assign;

    procedure update_broker_assign (
        p_broker_assignment_id in number,
        p_broker_id            in number,
        p_entrp_id             in number,
        p_pers_id              in number,
        p_effective_date       in varchar2,
        p_effective_end_date   in varchar2,
        p_salesrep_id          in varchar2,
        p_user_id              in number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
    begin
        pc_log.log_error('UPDATE BROKER ASSIGNMENT', 'Broker Assignment ID '
                                                     || p_broker_assignment_id
                                                     || ' Effective End Date '
                                                     || p_effective_end_date);
        if p_effective_end_date is not null then
            if p_entrp_id is not null then
                update broker_assignments
                set
                    effective_end_date = to_date(p_effective_end_date, 'MM/DD/YYYY'),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        entrp_id = p_entrp_id
                    and broker_assignment_id = p_broker_assignment_id
                    and effective_end_date is null;

                update broker_assignments
                set
                    effective_end_date = to_date(p_effective_end_date, 'MM/DD/YYYY'),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            enterprise
                        where
                            entrp_id = p_entrp_id
                    )
                    and broker_id = p_broker_id
                    and entrp_id = p_entrp_id
                    and effective_end_date is null;

                update sales_team_member
                set
                    end_date = to_date(p_effective_end_date, 'MM/DD/YYYY'),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        emplr_id = p_entrp_id
                    and entity_id = p_broker_id
                    and entity_type = 'BROKER';

            else
                update broker_assignments
                set
                    effective_end_date = to_date(p_effective_end_date, 'MM/DD/YYYY'),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        pers_id = p_pers_id
                    and broker_assignment_id = p_broker_assignment_id
                    and effective_end_date is null;

            end if;

        else
            if p_entrp_id is not null then
                update broker_assignments
                set
                    effective_end_date = null,
                    effective_date = to_date(p_effective_date, 'MM/DD/YYYY'),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        entrp_id = p_entrp_id
                    and broker_assignment_id = p_broker_assignment_id;
           --  AND    effective_end_date IS NULL;

                update broker_assignments
                set
                    effective_end_date = null,
                    effective_date = to_date(p_effective_date, 'MM/DD/YYYY'),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            enterprise
                        where
                            entrp_id = p_entrp_id
                    )
                    and broker_id = p_broker_id
                    and entrp_id = p_entrp_id;
            -- AND    effective_end_date IS NULL;

                update account
                set
                    broker_id = p_broker_id,
                    salesrep_id = p_salesrep_id
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            person
                        where
                            entrp_id = p_entrp_id
                    );

                update account
                set
                    broker_id = p_broker_id,
                    salesrep_id = p_salesrep_id
                where
                    entrp_id = p_entrp_id;

                if
                    p_broker_id <> 0
                    and p_entrp_id is not null
                then
                    pc_sales_team.assign_sales_team(
                        p_entrp_id    => p_entrp_id,
                        p_entity_type => 'BROKER',
                        p_entity_id   => p_broker_id,
                        p_eff_date    => to_date(p_effective_date, 'MM/DD/YYYY'),
                        p_user_id     => p_user_id
                    );
                end if;

                if
                    p_salesrep_id is not null
                    and p_entrp_id is not null
                then
                    pc_sales_team.assign_sales_team(
                        p_entrp_id    => p_entrp_id,
                        p_entity_type => 'SALES_REP',
                        p_entity_id   => p_salesrep_id,
                        p_eff_date    => to_date(p_effective_date, 'MM/DD/YYYY'),
                        p_user_id     => p_user_id
                    );
                end if;

                update broker_assignments
                set
                    effective_end_date = to_date(p_effective_date, 'MM/DD/YYYY')
              -- ,   effective_date = TO_DATE(p_effective_date,'MM/DD/YYYY')-1
                    ,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        broker_id <> p_broker_id
                    and entrp_id = p_entrp_id
                    and ( effective_end_date is null
                          or effective_end_date > to_date(p_effective_date, 'MM/DD/YYYY') );

            else
                update broker_assignments
                set
                    effective_end_date = null,
                    effective_date = to_date(p_effective_date, 'MM/DD/YYYY'),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        pers_id = p_pers_id
                    and broker_assignment_id = p_broker_assignment_id;
             --AND    effective_end_date IS NULL;

                update broker_assignments
                set
                    effective_end_date = to_date(p_effective_date, 'MM/DD/YYYY')
             --  ,   effective_date = TO_DATE(p_effective_date,'MM/DD/YYYY')-1
                    ,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        broker_id <> p_broker_id
                    and pers_id = p_pers_id
                    and ( effective_end_date is null
                          or effective_end_date > to_date(p_effective_date, 'MM/DD/YYYY') );

                update account
                set
                    broker_id = p_broker_id,
                    salesrep_id = p_salesrep_id
                where
                    pers_id = p_pers_id;

            end if;
        end if;

    end update_broker_assign;

    function get_broker_name (
        p_broker_id in number
    ) return varchar2 is
        l_name varchar2(255);
    begin
        for x in (
            select
                b.first_name
                || ' '
                || b.last_name name
            from
                person b
            where
                pers_id = p_broker_id
        ) loop
            l_name := x.name;
        end loop;

        return trim(l_name);
    end get_broker_name;

    function get_broker_lic (
        p_broker_id in number
    ) return varchar2 is
        l_lic varchar2(255);
    begin
        for x in (
            select
                broker_lic
            from
                broker
            where
                broker_id = p_broker_id
        ) loop
            l_lic := x.broker_lic;
        end loop;

        return l_lic;
    end get_broker_lic;

    function get_salesrep_id (
        p_broker_id in number
    ) return number is
        l_salesrep_id number;
    begin
        for x in (
            select
                salesrep_id
            from
                broker
            where
                broker_id = p_broker_id
        ) loop
            l_salesrep_id := x.salesrep_id;
        end loop;

        return l_salesrep_id;
    end get_salesrep_id;

    function get_effective_date (
        p_pers_id   in number,
        p_broker_id in number
    ) return varchar2 is
        l_eff_date varchar2(30);
    begin
        for x in (
            select
                to_char(
                    max(effective_date),
                    'MM/DD/YYYY'
                ) eff_date
            from
                broker_assignments
            where
                    pers_id = p_pers_id
                and broker_id = p_broker_id
        ) loop
            l_eff_date := x.eff_date;
        end loop;

        return l_eff_date;
    end get_effective_date;

    function get_er_count (
        p_broker_id    in number,
        p_account_type in varchar2 default 'HSA'
    ) return number is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            account
        where
                account.broker_id = p_broker_id
            and account.entrp_id is not null
            and account_type = p_account_type
            and end_date is null;

        return l_count;
    end get_er_count;

    function get_pers_count (
        p_broker_id    in number,
        p_acc_status   in number,
        p_account_type in varchar2 default 'HSA'
    ) return number is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            account
        where
                account.broker_id = p_broker_id
            and account_type = p_account_type
            and account.account_status = nvl(p_acc_status, account.account_status);

        return l_count;
    end get_pers_count;

    function get_broker_info (
        p_broker_lic in varchar2
    ) return broker_t
        pipelined
        deterministic
    is
        l_record broker_row;
    begin
        for x in (
            select
                b.broker_id,
                nvl(b.broker_lic, 'SK' || b.broker_id) as broker_lic,
                b.start_date,
                b.end_date,
                p.first_name,
                p.last_name,
                p.address,
                p.address2,
                p.city,
                p.state,
                p.zip,
                b.broker_rate / 100                    as broker_rate,
                substr(phone_day, 1, 30)               phone_day,
                substr(email, 1, 50)                   email,
                ga_id,
                b.agency_name,
                b.flg_agree   -- Added by swamy for Ticket#7660
            from
                broker b,
                person p
            where
                    b.broker_id = p.pers_id
                and ( upper(b.broker_lic) = upper(p_broker_lic) --)
                      or to_char(b.broker_id) = p_broker_lic )
        ) -- Bracket Added by Swamy for Ticket#12309 -- changed by joshi for tikcet 5244
         loop
            l_record.broker_id := x.broker_id;
            l_record.broker_lic := x.broker_lic;
            l_record.start_date := to_char(x.start_date, 'MM/DD/YYYY');
            l_record.first_name := x.first_name;
            l_record.last_name := x.last_name;
            l_record.broker_name := x.first_name
                                    || ' '
                                    || x.last_name;
            l_record.address := x.address
                                || ','
                                || x.address2; --SK Added on 0510
            l_record.city := x.city;
            l_record.state := x.state;
            l_record.zip := x.zip;
            l_record.broker_rate := x.broker_rate;
            l_record.broker_comm := ( x.broker_rate * 100 )
                                    || '%';
            l_record.broker_phone := x.phone_day;
            l_record.broker_email := x.email;
            l_record.ga_id := x.ga_id;
            l_record.agency_name := x.agency_name;
            l_record.flg_agree := x.flg_agree;     -- Added by swamy for Ticket#7660
            pipe row ( l_record );
        end loop;
    end get_broker_info;

    function get_broker_info (
        p_broker_id in number
    ) return broker_t
        pipelined
        deterministic
    is
        l_record broker_row;
    begin
        for x in (
            select
                b.broker_id,
                nvl(b.broker_lic, 'SK' || b.broker_id) as broker_lic,
                b.start_date,
                b.end_date,
                p.first_name,
                p.last_name,
                p.address,
                p.address2,
                p.city,
                p.state,
                p.zip,
                b.broker_rate / 100                    as broker_rate,
                substr(phone_day, 1, 30)               phone_day,
                substr(email, 1, 50)                   email,
                ga_id,
                b.agency_name,
                b.flg_agree   -- Added by swamy for Ticket#7660
            from
                broker b,
                person p
            where
                    b.broker_id = p.pers_id
                and b.broker_id = p_broker_id
        ) loop
            l_record.broker_id := x.broker_id;
            l_record.broker_lic := x.broker_lic;
            l_record.start_date := to_char(x.start_date, 'MM/DD/YYYY');
            l_record.first_name := x.first_name;
            l_record.last_name := x.last_name;
            l_record.broker_name := x.first_name
                                    || ' '
                                    || x.last_name;
            l_record.address := x.address
                                || ','
                                || x.address2;--Added by Sk 05-10-2020
            l_record.city := x.city;
            l_record.state := x.state;
            l_record.zip := x.zip;
            l_record.broker_rate := x.broker_rate;
            l_record.broker_comm := ( x.broker_rate * 100 )
                                    || '%';
            l_record.broker_phone := x.phone_day;
            l_record.broker_email := x.email;
            l_record.ga_id := x.ga_id;
            l_record.agency_name := x.agency_name;
            l_record.flg_agree := x.flg_agree;     -- Added by swamy for Ticket#7660
            pipe row ( l_record );
        end loop;
    end get_broker_info;

    function get_broker_prod (
        p_broker_id in number
    ) return broker_prod_t
        pipelined
        deterministic
    is
        l_record broker_prod_row;
    begin
        for x in (
            select distinct
                account_type,
                pc_lookups.get_meaning(account_type, 'ACCOUNT_TYPE') meaning
            from
                account
            where
                broker_id = p_broker_id
        ) loop
            l_record.product_type := x.account_type;
            l_record.plan_type := x.account_type;
            l_record.account_meaning := x.meaning;
            pipe row ( l_record );
        end loop;
    end get_broker_prod;

    function get_broker_info_from_acc_id (
        p_acc_id number
    ) return broker_t
        pipelined
    is
        rec         broker_row;
        l_tbl       broker_t;
        l_broker_id number;
    begin
        select
            broker_id
        into l_broker_id
        from
            account
        where
            acc_id = p_acc_id;

        select
            *
        bulk collect
        into l_tbl
        from
            table ( pc_broker.get_broker_info(l_broker_id) );

        for i in 1..l_tbl.count loop
            pipe row ( l_tbl(i) );
        end loop;

    end get_broker_info_from_acc_id;

    function get_ga_info (
        p_entrp_id number
    ) return tbl_ga_lic
        pipelined
    is
        rec rec_ga_lic;
    begin
        for i in (
            select
                a.ga_id,
                agency_name,
                ga_lic,
                email
            from
                general_agent     a,
                sales_team_member b
            where
                    a.ga_id = b.entity_id
                and b.entity_type = 'GENERAL_AGENT'
                and b.end_date is null
                and b.status = 'A'
                and b.emplr_id = p_entrp_id
        ) loop
            rec.ga_id := i.ga_id;
            rec.agency_name := i.agency_name;
            rec.ga_lic := i.ga_lic;
            rec.email := i.email;
            pipe row ( rec );
        end loop;
    end get_ga_info;

    procedure insert_sales_team_leads (
        p_first_name      varchar2,
        p_last_name       varchar2,
        p_license         varchar2,
        p_agency_name     varchar2,
        p_tax_id          varchar2,
        p_gender          varchar2,
        p_address         varchar2,
        p_city            varchar2,
        p_state           varchar2,
        p_zip             varchar2,
        p_phone1          varchar2,
        p_phone2          varchar2,
        p_email           varchar2,
        p_entrp_id        number,
        p_ref_entity_id   number,
        p_ref_entity_type varchar2,
        p_lead_source     varchar2,
        p_entity_type     varchar2
    ) is
    begin
        pc_log.log_error('INSERT_SALES_TEAM_LEADS', 'P_EMAIL ' || p_email);
        insert into external_sales_team_leads (
            external_sales_team_id,
            first_name,
            last_name,
            license,
            agency_name,
            tax_id,
            gender,
            address,
            city,
            state,
            zip,
            phone1,
            phone2,
            email,
            creation_date,
            entrp_id,
            ref_entity_id,
            ref_entity_type,
            lead_source,
            entity_type
        ) values ( external_sales_team_lead_seq.nextval,
                   p_first_name,
                   p_last_name,
                   p_license,
                   p_agency_name,
                   p_tax_id,
                   p_gender,
                   p_address,
                   p_city,
                   p_state,
                   p_zip,
                   p_phone1,
                   p_phone2,
                   p_email,
                   sysdate,
                   p_entrp_id,
                   p_ref_entity_id,
                   p_ref_entity_type,
                   p_lead_source,
                   p_entity_type );

    end insert_sales_team_leads;

-- Added by swamy for Ticket#7660
-- Procedure to update the flg_agree column of the broker.
-- After broker creation, for the first time broker login, user will be prompted with a message to agree/Disagree
-- an agreement in electronic format. This update is done in the below procedure. This message will appear only for the first time Broker Login.
    procedure upd_broker_flg_agree (
        p_broker_id in number,
        p_flg_agree in varchar2
    ) is
    begin
--pc_log.log_error('Upd_Broker_Flg_Agree','P_Broker_Id '||P_Broker_Id||' P_Flg_Agree := '||P_Flg_Agree);
        update broker
        set
            flg_agree = p_flg_agree
        where
            broker_id = p_broker_id;

    end upd_broker_flg_agree;

-- For SQL Injection Start added by Swamy
    function getemployeeinfo (
        p_entrp_id    in number,
        p_plan_type   in varchar2,
        p_first_name  in varchar2,
        p_last_name   in varchar2,
        p_acc_num     in varchar2,
        p_start_date  in varchar2,
        p_end_date    in varchar2,
        p_sort_column in varchar2,
        p_sort_order  in varchar2,
        p_start_row   in varchar2,     -- Swamy #12013 12022024
        p_end_row     in varchar2      -- Swamy #12013 12022024
    ) return emp_info_t
        pipelined
        deterministic
    is

        l_record_t    emp_info_row_t;
        v_order       varchar2(1000);
        v_sql         varchar2(4000);
        v_sql_cur     l_cursor;
        v_start_date  date;
        v_end_date    date;
        v_sort_column varchar2(250);
        v_sort_order  varchar2(10);
    begin
--db_tool('getemployeeinfo begin p_entrp_id :='||p_entrp_id);
        if is_date(p_start_date, 'DD-MON-YYYY') = 'Y' then         -- Date format changed by Jagadeesh ##9420
            v_start_date := to_date ( p_start_date, 'DD-MON-YYYY' );
        else
            v_start_date := null;
        end if;
--db_tool('1');
        if
            v_start_date is not null
            and is_date(p_end_date, 'DD-MON-YYYY') = 'Y'
        then
            v_end_date := to_date ( p_end_date, 'DD-MON-YYYY' );
        else
            v_end_date := null;
            v_start_date := null;
        end if;

--- start_Date added by rprabu 21-06-2019 TO_DATE(P_Start_Date,'MM/DD/YYYY')
        v_sql := 'SELECT  RN_1,NAME, ACC_NUM, TO_CHAR(START_DATE,''MM/DD/YYYY'') START_DATE , TO_CHAR(END_DATE,''MM/DD/YYYY'') END_DATE, ANNUAL_ELECTION, ACC_BALANCE , BENEFIT_YEAR,plan_type_meaning,first_name,last_name,MOD(ROWNUM,2) RN
               FROM (select ROWNUM RN_1,NAME, ACC_NUM, START_DATE, END_DATE, ANNUAL_ELECTION, ACC_BALANCE,BENEFIT_YEAR ,plan_type_meaning,first_name,last_name
                       from FSA_HRA_EMPLOYEES_V  where ENTRP_ID= '
                 || p_entrp_id
                 || ' AND    ACCOUNT_TYPE IN ( ''FSA'' , ''HRA'')  
                        AND plan_type <> ''NDT''
                       AND STATUS NOT IN (''P'',''R'')';
   --db_tool('p_sort_column :='||p_sort_column||' p_sort_order :='||p_sort_order);
        if nvl(p_plan_type, '*') in ( 'DCA', 'FSA', 'HRA', 'LPF', 'PKG',
                                      'TRN' ) then
            v_sql := v_sql
                     || ' AND   PLAN_TYPE = '''
                     || p_plan_type
                     || '''';
        end if;
   -- From online screen, only P_First_Name or P_Last_Name or P_Acc_Num any one parameter will have value, there is no case where
   -- all the parameter will have value.
        if
            nvl(p_first_name, '*') <> '*'
            and nvl(p_last_name, '*') = '*'
            and nvl(p_acc_num, '*') = '*'
        then
            v_sql := v_sql
                     || ' AND UPPER(FIRST_NAME) = UPPER('''
                     || p_first_name
                     || ''')';
        end if;

        if
            nvl(p_last_name, '*') <> '*'
            and nvl(p_first_name, '*') = '*'
            and nvl(p_acc_num, '*') = '*'
        then
            v_sql := v_sql
                     || ' AND UPPER(LAST_NAME) = UPPER('''
                     || p_last_name
                     || ''')';
        end if;

        if
            nvl(p_acc_num, '*') <> '*'
            and nvl(p_first_name, '*') = '*'
            and nvl(p_last_name, '*') = '*'
        then -- added by Jaggi #9061
            v_sql := v_sql
                     || ' AND UPPER(ACC_NUM) = UPPER('''
                     || p_acc_num
                     || ''')';
        end if;

        if
            v_start_date is not null
            and v_end_date is not null
        then
            v_sql := v_sql
                     || ' AND START_DATE >= '''
                     || v_start_date
                     || ''' AND START_DATE<= '''
                     || v_end_date
                     || '''';
        end if;

   --V_Sql := V_Sql||')';    -- commented Swamy #12013 12022024
        if
            nvl(p_start_row, '*') <> '*'
            and nvl(p_end_row, '*') <> '*'
        then
            v_sql := v_sql
                     || ' ) WHERE RN_1 >= '
                     || p_start_row
                     || ' AND RN_1 <= '
                     || p_end_row;    -- Swamy #12013 12022024
        else
            v_sql := v_sql || ')';
        end if;

        if nvl(p_sort_column, '*') in ( 'ACC_NUM', 'FIRST_NAME', 'LAST_NAME' ) then
            v_sort_column := p_sort_column;
        end if;

        if nvl(p_sort_order, '*') in ( 'ASC', 'DESC' ) then
            v_sort_order := p_sort_order;
        else
            v_sort_order := 'ASC';
        end if;

        if nvl(v_sort_column, '*') <> '*' then
            if v_sort_column = 'START_DATE' then
                v_order := ' order by '
                           || v_sort_column
                           || ' '
                           || v_sort_order;
            else
                v_order := ' order by '
                           || v_sort_column
                           || ' '
                           || v_sort_order
                           || ',START_DATE DESC';
            end if;
        end if;

        v_sql := v_sql || v_order;
        pc_log.log_error('Getemployeeinfo', 'V_Sql : ' || v_sql);

--   db_tool('v_sql :='||v_sql);
--   db_tool('V_Start_Date : '||V_Start_Date||'V_Start_Date : '||V_End_Date);
   --open V_SQL_CUR for v_sql using p_entrp_id,p_plan_type,p_first_name,p_last_name,p_acc_num,p_start_date,p_end_date;
        open v_sql_cur for v_sql;

        loop
            fetch v_sql_cur into
                l_record_t.row_num,
                l_record_t.name,
                l_record_t.acc_num,
                l_record_t.start_date,
                l_record_t.end_date,
                l_record_t.annual_election,
                l_record_t.acc_balance,
                l_record_t.benefit_year,
                l_record_t.plan_type_meaning,
                l_record_t.first_name,
                l_record_t.last_name,
                l_record_t.rn;

            exit when v_sql_cur%notfound;
            pipe row ( l_record_t );
        end loop;

        close v_sql_cur;
    exception
        when others then
            null;
    end getemployeeinfo;

  -- Added by rprabu 21/06/2019 for ticket#7901
    function check_broker_doc (
        p_broker_id number,
        p_doc_type  varchar2
    ) return varchar2 is
        l_doc_verified varchar2(50);
    begin
        l_doc_verified := null;
        for i in (
            select
                decode(verified_flag, 'Y', 'Verified', 'N', 'Not Verified') doc_verified
            from
                file_attachments
            where
                    entity_id = p_broker_id
                and document_purpose = p_doc_type
        ) loop
            l_doc_verified := i.doc_verified;
        end loop;

        return nvl(l_doc_verified, ' ');
    end check_broker_doc;

    -- Broker_Pedning CLient Info ##9617 added by Jaggi 13/01/2021

    function get_broker_pending_info (
        p_broker_id   in number,
        p_client_name varchar2,
        p_acct_type   varchar2,
        p_acct_status varchar2
    ) return get_broker_pending_info_t
        pipelined
        deterministic
    is
        l_pending_client_info get_broker_pending_info_row_t;
        l_acct_status         varchar2(100);
    begin
        if p_acct_status = 'A' then
            l_acct_status := '1';
        elsif p_acct_status = 'P' then
            l_acct_status := '3,6,8,10,11';  -- 11 Added by Swamy for Ticket#12534(12629)
        end if;

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
                pc_broker.get_broker_name(b.broker_id)                   broker_name           -- Added by Jaggi ##9603
                ,
                resubmit_flag                                                    -- added by jaggi #10431
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = b.entrp_id
                and account_type = nvl(p_acct_type, account_type)
                and upper(name) like upper('%'
                                           || p_client_name
                                           || '%')
                and p_broker_id = decode(p_acct_status, 'A', broker_id, 'P', enrolled_by)         -- 9141 dhanya discussion if ER linked another GA , it should displayed to Ga2 Like Broker ticket.
                and decline_date is null                                                             -- Added by Jaggi #9893
                and b.account_status in ( 3, 6, 8, 10, 11 )
        )   -- 11 Added by Swamy for Ticket#12534(12629)
                --AND INSTR( NVL(l_acct_status,Account_Status)  , Account_Status  )  > 0)
         loop
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
            l_pending_client_info.phone_number := x.entrp_phones;
            l_pending_client_info.complete_flag := x.complete_flag;
            l_pending_client_info.industry_type := x.industry_type;
            l_pending_client_info.resubmit_flag := x.resubmit_flag;
            pipe row ( l_pending_client_info );
        end loop;

    exception
        when others then
            pc_log.log_error('PC_Broker.Get_Broker_Pending_Info', sqlerrm);
    end get_broker_pending_info;
-- Added by Jaggi
    procedure insert_broker_auth_req (
        p_broker_id        in number,
        p_acc_id           in number,
        p_broker_user_id   in number,
        p_user_id          in number,
        x_authorize_req_id out number,
        x_error_status     out varchar2,
        x_error_message    out varchar
    ) is

        l_broker_name     varchar(300);
        l_broker_auth_seq number := null;
        l_find_key        varchar2(20);
        l_user_id         number;
        l_user_find_key   varchar2(1) default 'N';
        l_return_status   varchar2(1);
        l_error_message   varchar2(32000);
        l_duplicate_request exception;
        ll_request_count  integer;
        l_status          varchar2(50);
    begin
        x_error_status := 'S';
        l_broker_name := pc_broker.get_broker_name(p_broker_id);
        l_find_key := upper(pc_broker.get_broker_lic(p_broker_id));
        begin
            select distinct
                authorize_req_id
            into l_broker_auth_seq
            from
                er_portal_authorizations
            where
                    broker_id = p_broker_id
                and acc_id = p_acc_id;

        exception
            when no_data_found then
                l_broker_auth_seq := null;
        end;

  --IF ll_request_count > 0 THEN
  --   RAISE l_duplicate_request ;
 -- END IF;

   -- Generate broker_autorization seq
        if l_broker_auth_seq is null then
            l_broker_auth_seq := broker_authorize_req_seq.nextval;
        end if;
        if p_broker_user_id is not null then
            l_status := 'APPROVED';
        else
            l_status := 'PENDING_FOR_APPROVAL';
        end if;
  -- get the all online users associated to Broker.
        for x in (
            select
                user_id
            from
                online_users
            where
                    user_type = 'B'
                and user_status = 'A'
                and user_id = nvl(p_broker_user_id, user_id)
                and upper(find_key) = l_find_key
        ) loop
            pc_log.log_error('pc_broker.insert_broker_auth_req: USER_ID: ', x.user_id);
            pc_log.log_error('pc_broker.insert_broker_auth_req: P_BROKER_ID: ', p_broker_id);
            pc_log.log_error('pc_broker.insert_broker_auth_req: P_ACC_ID: ', p_acc_id);
            pc_log.log_error('pc_broker.insert_broker_auth_req: l_broker_auth_seq: ', l_broker_auth_seq);
            insert into er_portal_authorizations (
                authorize_req_id,
                broker_id,
                acc_id,
                user_id,
                request_status,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( l_broker_auth_seq,
                       p_broker_id,
                       p_acc_id,
                       x.user_id,
                       l_status,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id ) returning authorize_req_id into x_authorize_req_id;

            pc_log.log_error('pc_broker.insert_broker_auth_req: X_AUTHORIZE_REQ_ID: ', x_authorize_req_id);
            pc_log.log_error('pc_broker.insert_broker_auth_req: SQL%ROWCOUNT: ', sql%rowcount);
        end loop;

    exception
        when l_duplicate_request then
  -- pc_log.log_error('pc_broker.pc_broker','error in l_setup_error '||x_error_message);
            x_error_status := 'E';
            x_error_message := 'The broker has already requsted for authorization';
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('pc_broker.pc_broker',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end insert_broker_auth_req;

    function get_broker_authorise_info (
        p_tax_id in varchar2
    ) return broker_authorize_info_t
        pipelined
        deterministic
    is

        l_record          broker_authorize_info_row;
        l_sql             varchar2(4000);
        l_column_list     varchar2(4000);
        l_sql_cur         l_cursor;
        l_comp_plan_exits varchar2(1) default 'N';
    begin
        for x in (
            select distinct
                a.acc_id,
                a.account_type,
                a.entrp_id
            from
                account                  a,
                er_portal_authorizations b,
                enterprise               e
            where
                    a.acc_id = b.acc_id
                and a.entrp_id = e.entrp_id
                and replace(e.entrp_code, '-') = replace(p_tax_id, '-')
                and a.account_type in (
                    select distinct
                        product_type
                    from
                        broker_authorize_product_map
                )
        )
                -- Added above product_type clause for 10694 .
         loop
            pc_log.log_error('get_broker_authorise_info', 'x.acc_id: '
                                                          || x.acc_id
                                                          || 'x.account_type: '
                                                          || x.account_type);

 -- added by Jaggi #11086
            if x.account_type = 'POP' then
                for j in (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            entrp_id = x.entrp_id
                        and status = 'A'
                        and plan_end_date > sysdate
                        and plan_type like '%COMP%'
                ) loop
                    l_comp_plan_exits := 'Y';
                end loop;

            end if;

    -- get the column list
            if
                x.account_type = 'POP'
                and l_comp_plan_exits = 'N'
            then
                select
                    listagg(permission_type, ', ') within group(
                    order by
                        product_type
                    ) permission_list
                into l_column_list
                from
                    broker_authorize_product_map
                where
                        product_type = x.account_type
                    and permission_type not in ( 'ALLOW_BROKER_PLAN_AMEND' );

            else
                select
                    listagg(permission_type, ', ') within group(
                    order by
                        product_type
                    ) permission_list
                into l_column_list
                from
                    broker_authorize_product_map
                where
                    product_type = x.account_type;

            end if;

            pc_log.log_error('get_broker_authorise_info', 'l_column_list: ' || l_column_list);
            l_sql := 'select Distinct a.acc_id,c.account_type ,c.acc_num,e.name, a.authorize_options, bp.description,  a.is_authorized , bp.nav_code ,
                   c.broker_id, pc_broker.get_broker_name(c.broker_id) broker_name, authorize_req_id,REQUEST_STATUS
            from ( select acc_id, authorize_options, is_authorized from account_preference
                   unpivot INCLUDE  NULLS (is_authorized FOR authorize_options IN ( '
                     || l_column_list
                     || ' )))  a ,broker_authorize_product_map bp , account c,enterprise e,ER_PORTAL_AUTHORIZATIONS er
            where a.acc_id = c.acc_id and er.acc_id = c.acc_id and er.broker_id = c.broker_id and c.entrp_id = e.entrp_id and a.acc_id = '
                     || x.acc_id
                     || ' and a.authorize_options = bp.permission_type
               and bp.product_type = '''
                     || x.account_type
                     || '''';

            pc_log.log_error('get_broker_authorise_info', 'l_sql : ' || l_sql);
            open l_sql_cur for l_sql;

            loop
                fetch l_sql_cur into l_record;
                exit when l_sql_cur%notfound;
                pipe row ( l_record );
            end loop;

            close l_sql_cur;
        end loop;
    end get_broker_authorise_info;

    function get_broker_authorize_req_info (
        p_broker_id in number,
        p_acc_id    in number
    ) return varchar2 is
        l_request_access varchar2(50) := 'N';
    begin
        for x in (
            select distinct
                request_status
            from
                er_portal_authorizations
            where
                    broker_id = p_broker_id
                and acc_id = p_acc_id
        ) loop
            l_request_access := x.request_status;
        end loop;

        return l_request_access;
    end get_broker_authorize_req_info;

-- Added by Jaggi for #9902
    function show_broker_authorize_notify (
        p_ein varchar2
    ) return varchar2 is
        l_broker_authorize_notify varchar2(50) := 'N';
    begin
        for x in (
            select
                count(*) broker_count
            from
                account                  a,
                er_portal_authorizations b,
                enterprise               e
            where
                    a.acc_id = b.acc_id
                and a.entrp_id = e.entrp_id
                and b.request_status = 'PENDING_FOR_APPROVAL'
                and replace(e.entrp_code, '-') = replace(p_ein, '-')
                and a.account_type in (
                    select distinct
                        product_type
                    from
                        broker_authorize_product_map
                )
        )
                    -- Added above product_type clause for 10694 .
         loop
            if x.broker_count > 0 then
                l_broker_authorize_notify := 'Y';
            end if;
        end loop;

        return l_broker_authorize_notify;
    end show_broker_authorize_notify;

-- Added by Jaggi for 9902
    procedure update_broker_auth (
        p_acc_id           number,
        p_broker_id        number,
        p_authorize_req_id number,
        p_authorize_option pc_online_enrollment.varchar2_tbl,
        p_is_authorized    pc_online_enrollment.varchar2_tbl,
        p_nav_code         pc_online_enrollment.varchar2_tbl,
        p_user_id          in number,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    ) is

        l_account_type   varchar2(20);
        l_sql            varchar2(100);
        l_where          varchar2(50);
        l_update_sql     varchar2(1000);
        l_update_by_sql  varchar2(1000);
        l_sql_set_column varchar2(1000);
        l_site_nav_id    number;
        l_return_status  varchar2(1);
        l_error_message  varchar2(32000);
        l_role_entries   pc_online_enrollment.varchar2_tbl;
        i                integer := 1;
        l_option_select  varchar2(1);
    begin
        x_error_status := 'S';
        l_option_select := 'N';
        for z in (
            select
                account_type
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_account_type := z.account_type;
        end loop;

        l_sql := 'update account_preference set last_update_date = sysdate, last_updated_by = '
                 || p_user_id
                 || ',';
        pc_log.log_error('UPDATE_BROKER_AUTH', 'P_AUTHORISE_OPTION: count  : ' || p_authorize_option.count);
        for i in 1..p_authorize_option.count loop
            pc_log.log_error('UPDATE_BROKER_AUTH',
                             'p_authorize_option(i):'
                             || p_authorize_option(i)
                             || 'p_is_authorized(i):'
                             || p_is_authorized(i));

            if i = 1 then
                l_sql_set_column := p_authorize_option(i)
                                    || '='
                                    || ''''
                                    || p_is_authorized(i)
                                    || '''';

            else
                l_sql_set_column := l_sql_set_column
                                    || ','
                                    || p_authorize_option(i)
                                    || '='
                                    || ''''
                                    || p_is_authorized(i)
                                    || '''';
            end if;

            l_where := ' where acc_id = ' || p_acc_id;
            l_update_sql := l_sql
                            || l_sql_set_column
                            || l_where;
        end loop;

        pc_log.log_error('UPDATE_BROKER_AUTH', 'l_update_sql : ' || l_update_sql);
        if l_update_sql is not null then
            execute immediate l_update_sql;
        end if;
        if p_authorize_option.count > 0 then
            for j in 1..p_authorize_option.count loop
                if p_is_authorized(j) = 'Y' then
                    l_option_select := 'Y';
                    pc_log.log_error('UPDATE_BROKER_AUTH',
                                     'P_IS_AUTHORIZED(j) : '
                                     || p_is_authorized(j)
                                     || 'P_AUTHORIZE_OPTION(j) : '
                                     || p_authorize_option(j)
                                     || 'p_nav_code(j) : '
                                     || p_nav_code(j));

                    begin
                        select
                            site_nav_id
                        into l_site_nav_id
                        from
                            site_navigation s
                        where
                                s.nav_code = p_nav_code(j)
                            and s.account_type = l_account_type
                            and s.portal_type = 'BROKER_EMPLOYER';

                    exception
                        when no_data_found then
                            l_site_nav_id := null;
                    end;

                    if l_site_nav_id is not null then
                        l_role_entries(i) := l_site_nav_id;
                        i := i + 1;
                    end if;

                end if;
            end loop;
        end if;

        if l_role_entries.count() > 0 then
            for x in (
                select distinct
                    o.user_id,
                    emp_reg_type
                from
                    er_portal_authorizations b,
                    online_users             o
                where
                        broker_id = p_broker_id
                    and b.user_id = o.user_id
                    and b.acc_id = p_acc_id
                    and authorize_req_id = p_authorize_req_id
            ) loop
                pc_users.create_role_entries(x.user_id, l_role_entries, p_user_id, x.emp_reg_type, p_authorize_req_id,
                                             l_return_status, l_error_message);
            end loop;
        end if;

  -- check if all option is deselected then roles should be deleted.
        if
            l_role_entries.count() = 0
            and p_authorize_option.count > 0
            and p_authorize_req_id is not null
        then
            delete from user_role_entries
            where
                authorize_req_id = p_authorize_req_id;

        end if;

        if l_option_select = 'Y' then
            update er_portal_authorizations
            set
                request_status = 'APPROVED',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    broker_id = p_broker_id
                and authorize_req_id = p_authorize_req_id
                and acc_id = p_acc_id;

        else
            pc_broker.remove_broker_authorize(p_broker_id, p_acc_id);
        end if;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('pc_broker.UPDATE_BROKER_AUTH',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end update_broker_auth;

-- Added by Joshi for #9902
    function get_broker_authorize_req_id (
        p_broker_id in number,
        p_acc_id    in number
    ) return number is
        l_authorize_id number;
    begin
        for x in (
            select distinct
                authorize_req_id
            from
                er_portal_authorizations
            where
                    broker_id = p_broker_id
                and acc_id = p_acc_id
        ) loop
            l_authorize_id := x.authorize_req_id;
        end loop;

        return l_authorize_id;
    end get_broker_authorize_req_id;

-- Added by Jaggi for 9902
    procedure create_broker_authorize (
        p_broker_id        number,
        p_acc_id           number,
        p_broker_user_id   number,
        p_authorize_req_id number,
        p_user_id          in number,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    ) is

        type broker_permission_row_t is
            table of broker_permission_row index by binary_integer;
        l_record            broker_permission_row_t;
        i                   integer := 1;
        l_account_type      varchar2(30);
        l_sql               varchar2(4000);
        l_sql_cur           l_cursor;
        l_column_list       varchar2(4000);
        l_role_entries      pc_online_enrollment.varchar2_tbl;
        l_site_nav_id       number;
        l_return_status     varchar2(1);
        l_error_message     varchar2(4000);
        l_authorize_req_id  number;
        l_find_key          varchar2(50);
        l_all_flags_removed varchar2(1) := 'N';
    begin
        x_error_status := 'S';
        for x in (
            select
                account_type
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_account_type := x.account_type;
        end loop;

        if p_authorize_req_id is not null then
            l_authorize_req_id := p_authorize_req_id;
        end if;

  -- check record and if not insert one.
 --    IF p_authorize_req_id is NULL THEN
        for x in (
            select
                *
            from
                account_preference
            where
                acc_id = p_acc_id
        ) loop
            if
                nvl(x.allow_broker_ee, 'N') = 'N'
                and nvl(x.allow_broker_enroll, 'N') = 'N'
                and nvl(x.allow_broker_invoice, 'N') = 'N'
                and nvl(x.allow_bro_upd_pln_doc, 'N') = 'N'
                and nvl(x.allow_broker_renewal, 'N') = 'N'
                and nvl(x.allow_broker_enroll_rpts, 'N') = 'N'
                and nvl(x.allow_broker_enroll_ee, 'N') = 'N'
                and nvl(x.allow_broker_plan_amend, 'N') = 'N'
            then -- Added By Joshi 11081

                if p_authorize_req_id is not null then
                    pc_broker.remove_broker_authorize(p_broker_id, p_acc_id);
                    l_all_flags_removed := 'Y';
                end if;
            end if;

            if
                ( x.allow_broker_ee = 'Y'
                or x.allow_broker_enroll = 'Y'
                or x.allow_broker_invoice = 'Y'
                or x.allow_bro_upd_pln_doc = 'Y'
                or x.allow_broker_renewal = 'Y'
                or x.allow_broker_enroll_rpts = 'Y'
                or x.allow_broker_enroll_ee = 'Y'
                or nvl(x.allow_broker_plan_amend, 'N') = 'Y' )   -- Added By Joshi 11081
                and p_authorize_req_id is null
            then
                pc_broker.insert_broker_auth_req(
                    p_broker_id        => p_broker_id,
                    p_acc_id           => p_acc_id,
                    p_broker_user_id   => null,
                    p_user_id          => p_user_id,
                    x_authorize_req_id => l_authorize_req_id,
                    x_error_status     => l_return_status,
                    x_error_message    => l_error_message
                );

                if l_authorize_req_id is not null then
                    update er_portal_authorizations
                    set
                        request_status = 'APPROVED',
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            broker_id = p_broker_id
                        and authorize_req_id = l_authorize_req_id
                        and acc_id = p_acc_id;

                end if;

            end if;

        end loop;

        if l_all_flags_removed = 'N' then
            select
                listagg(permission_type, ', ') within group(
                order by
                    product_type
                ) permission_list
            into l_column_list
            from
                broker_authorize_product_map
            where
                product_type = l_account_type;

            l_sql := 'select distinct a.authorize_option, a.is_authorized , bp.nav_code ,
                      er.authorize_req_id
                from ( select acc_id, authorize_option, is_authorized from account_preference
                       unpivot INCLUDE  NULLS (is_authorized FOR authorize_option IN ( '
                     || l_column_list
                     || ' )))  a ,broker_authorize_product_map bp , ER_PORTAL_AUTHORIZATIONS er
                where a.acc_id = '
                     || p_acc_id
                     || ' and a.acc_id = er.acc_id and a.authorize_option = bp.permission_type
                   and bp.product_type = '''
                     || l_account_type
                     || '''';

            pc_log.log_error('pc_broker.create_broker_authorize', 'l_sql : ' || l_sql);
            open l_sql_cur for l_sql;

            loop
                fetch l_sql_cur into
                    l_record
                (i);
                exit when l_sql_cur%notfound;
                i := i + 1;
            end loop;

            close l_sql_cur;
            i := 1;
            for j in 1..l_record.count loop
                if l_record(j).is_authorized = 'Y' then
                    pc_log.log_error('pc_broker.create_broker_authorize',
                                     'l_record(j).is_authorized : ' || l_record(j).is_authorized);
                    pc_log.log_error('pc_broker.create_broker_authorize',
                                     'l_record(j).authorise_option : ' || l_record(j).authorize_option);
                    pc_log.log_error('pc_broker.create_broker_authorize',
                                     'l_record(j).nav_code : ' || l_record(j).nav_code);
                    begin
                        select
                            site_nav_id
                        into l_site_nav_id
                        from
                            site_navigation s
                        where
                                s.nav_code = l_record(j).nav_code
                            and s.account_type = l_account_type
                            and s.portal_type = 'BROKER_EMPLOYER';

                    exception
                        when no_data_found then
                            l_site_nav_id := null;
                    end;

                    if l_site_nav_id is not null then
                        l_role_entries(i) := l_site_nav_id;
                        i := i + 1;
                    end if;

                end if;
            end loop;

            if l_role_entries.count() > 0 then
                for x in (
                    select distinct
                        o.user_id,
                        emp_reg_type
                    from
                        er_portal_authorizations b,
                        online_users             o
                    where
                            broker_id = p_broker_id
                        and b.user_id = o.user_id
                        and b.user_id = nvl(p_broker_user_id, b.user_id)
                        and b.acc_id = p_acc_id
                        and authorize_req_id = l_authorize_req_id
                ) loop
                    pc_log.log_error('pc_broker.create_broker_authorize:x.user_id', x.user_id);
                    pc_log.log_error('pc_broker.create_broker_authorize:p_broker_user_id', p_broker_user_id);
                    pc_users.create_role_entries(x.user_id, l_role_entries, p_user_id, x.emp_reg_type, l_authorize_req_id,
                                                 l_return_status, l_error_message);

                end loop;

                if l_authorize_req_id is not null then
                    update er_portal_authorizations
                    set
                        request_status = 'APPROVED',
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            broker_id = p_broker_id
                        and authorize_req_id = l_authorize_req_id
                        and acc_id = p_acc_id;

                end if;

            end if;

        end if;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('pc_broker.create_broker_authorize',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end create_broker_authorize;

 -- Added by Jaggi for 9902
    procedure remove_broker_authorize (
        p_broker_id in number,
        p_acc_id    in number
    ) is
    begin
        for x in (
            select distinct
                authorize_req_id
            from
                er_portal_authorizations
            where
                    broker_id = p_broker_id
                and acc_id = p_acc_id
        ) loop
            if x.authorize_req_id is not null then
                delete from user_role_entries
                where
                    authorize_req_id = x.authorize_req_id;

                delete from er_portal_authorizations
                where
                        authorize_req_id = x.authorize_req_id
                    and broker_id = p_broker_id
                    and acc_id = p_acc_id;

                update account_preference
                set
                    allow_bro_upd_pln_doc = 'N',
                    allow_broker_renewal = 'N',
                    allow_broker_enroll_rpts = 'N',
                    allow_broker_enroll = 'N',
                    allow_broker_invoice = 'N',
                    allow_broker_enroll_ee = 'N',
                    allow_broker_ee = 'N',
                    allow_broker_plan_amend = 'N'
                where
                    acc_id = p_acc_id;

            end if;
        end loop;
    end remove_broker_authorize;

-- Added by Swamy for Ticket#10747
    procedure get_broker_id (
        p_user_id     in number,
        p_entity_type out varchar2,
        p_broker_id   out number
    ) is
    begin
        for k in (
            select
                a.user_type,
                b.broker_id
            from
                online_users a,
                broker       b
            where
                    a.user_id = p_user_id
                and upper(a.find_key) = upper(b.broker_lic)
        ) loop
            if nvl(k.user_type, '*') = 'B' then
                p_entity_type := 'BROKER';
                p_broker_id := k.broker_id;
            end if;
        end loop;
    end get_broker_id;

 -- Added by Swamy for Ticket#11087
    function get_broker_service_documents (
        p_broker_id in number
    ) return broker_serv_doc_t
        pipelined
        deterministic
    is
        l_broker_serv_doc broker_serv_doc_row;
        l_entrp_id        number;
    begin
        for j in (
            select
                fa.attachment_id attachment_id,
                null             entrp_id,
                fa.document_name,
                lp.description,
                fa.creation_date,
                fa.document_purpose
            from
                file_attachments fa,
                lookups          lp
            where
                    fa.entity_id = p_broker_id
                and fa.entity_name = 'BROKER'
                and fa.show_online = 'Y'
                and fa.document_purpose = lp.lookup_code
                and lp.lookup_name = 'DOCUMENT_PURPOSE'
            union
            select
                fa.attachment_id,
                a.entrp_id,
                fa.document_name,
                'Plan documents' description,
                fa.creation_date,
                fa.document_purpose
            from
                file_attachments fa,
                account          a
            where
                    fa.entity_id = a.acc_id
                and a.broker_id = p_broker_id
                and fa.entity_name = 'ACCOUNT'
                and fa.show_online_broker = 'Y'
                and fa.document_purpose = 'PLAN_DOC'
        ) loop
            l_broker_serv_doc.employer_name := null;
            if j.entrp_id is not null then
                for m in (
                    select
                        pc_entrp.get_entrp_name(j.entrp_id) l_employer_desc
                    from
                        dual
                ) loop
                    l_broker_serv_doc.employer_name := m.l_employer_desc;
                end loop;

            end if;

            l_broker_serv_doc.attachment_id := j.attachment_id;
            l_broker_serv_doc.document_name := j.document_name;
            l_broker_serv_doc.description := j.description;
            l_broker_serv_doc.creation_date := j.creation_date;
            l_broker_serv_doc.document_purpose := j.document_purpose;
            pipe row ( l_broker_serv_doc );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_Broker.get_broker_service_documents', sqlerrm);
    end get_broker_service_documents;

 -- Added by Jaggi
    function get_broker_salesrep (
        p_broker_id in number
    ) return broker_salesrep_details_t
        pipelined
        deterministic
    is
        l_broker_salesrep_details broker_salesrep_details_row;
        l_count                   varchar2(3) := 'No';
    begin
        for j in (
            select
                trim(e.first_name
                     || ' '
                     || e.last_name) as salesrep_name,
                e.email         as salesrep_email,
                e.day_phone     as salesrep_phone_num,
                e.team_url      as salesrep_team_url
            from
                broker   b,
                employee e,
                salesrep s
            where
                    b.salesrep_id = s.salesrep_id
                and s.emp_id = e.emp_id
                and b.broker_id = p_broker_id
        ) loop
            l_broker_salesrep_details.salesrep_name := j.salesrep_name;
            l_broker_salesrep_details.salesrep_email := j.salesrep_email;
            l_broker_salesrep_details.salesrep_phone_num := j.salesrep_phone_num;
            l_broker_salesrep_details.salesrep_team_url := j.salesrep_team_url;
            l_count := 'Yes';
            pipe row ( l_broker_salesrep_details );
        end loop;

        if l_count = 'No' then
            for k in (
                select
                    e.first_name
                    || ' '
                    || e.last_name as salesrep_name,
                    e.email        as salesrep_email,
                    e.day_phone    as salesrep_phone_num,
                    e.team_url     as salesrep_team_url
                from
                    employee e
                where
                    emp_id = 3971
            )
					--from employee E where emp_id = 7373)  --this is for prod
             loop
                l_broker_salesrep_details.salesrep_name := k.salesrep_name;
                l_broker_salesrep_details.salesrep_email := k.salesrep_email;
                l_broker_salesrep_details.salesrep_phone_num := k.salesrep_phone_num;
                l_broker_salesrep_details.salesrep_team_url := k.salesrep_team_url;
                pipe row ( l_broker_salesrep_details );
            end loop;

        end if;

    exception
        when others then
            pc_log.log_error('PC_Broker.get_broker_Salesrep', sqlerrm);
    end get_broker_salesrep;

  -- Added by Jaggi
    function get_broker_account_manager (
        p_broker_id in number
    ) return broker_account_manager_details_t
        pipelined
        deterministic
    is
        l_broker_account_manager broker_account_manager_row;
        l_count                  varchar2(3) := 'No';
    begin
        for j in (
            select
                e.first_name
                || ' '
                || e.last_name as account_manager_name,
                e.email        as account_manager_email,
                e.day_phone    as account_manager_phone,
                e.team_url     as account_manager_url
            from
                broker   b,
                salesrep s,
                employee e
            where
                    broker_id = p_broker_id
                and b.am_id = s.salesrep_id
                and s.emp_id = e.emp_id
        ) loop
            l_broker_account_manager.account_manager_name := j.account_manager_name;
            l_broker_account_manager.account_manager_email := j.account_manager_email;
            l_broker_account_manager.account_manager_phone := j.account_manager_phone;
            l_broker_account_manager.account_manager_url := j.account_manager_url;
            l_count := 'Yes';
            pipe row ( l_broker_account_manager );
        end loop;

        if l_count = 'No' then
            for k in (
                select
                    e.first_name
                    || ' '
                    || e.last_name as account_manager_name,
                    e.email        as account_manager_email,
                    e.day_phone    as account_manager_phone,
                    e.team_url     as account_manager_url
                from
                    employee e
                where
                    emp_id = 6131
            ) 
					--from employee E where emp_id = 6131)  This is for prod
             loop
                l_broker_account_manager.account_manager_name := k.account_manager_name;
                l_broker_account_manager.account_manager_email := k.account_manager_email;
                l_broker_account_manager.account_manager_phone := k.account_manager_phone;
                l_broker_account_manager.account_manager_url := k.account_manager_url;
                pipe row ( l_broker_account_manager );
            end loop;

        end if;

    exception
        when others then
            pc_log.log_error('PC_Broker.get_broker_account_manager', sqlerrm);
    end get_broker_account_manager;

end pc_broker;
/


-- sqlcl_snapshot {"hash":"7ed0ec7a08409f6a88c60d07c14ce2260cf51d6c","type":"PACKAGE_BODY","name":"PC_BROKER","schemaName":"SAMQA","sxml":""}