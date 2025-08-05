create or replace package body samqa.pc_sbs_migration is

    procedure migrate_sbs_employer as

        l_entrp_id            number;
        l_acc_num             varchar2(30);
        x_error_message       varchar2(255);
        x_return_status       varchar2(255);
        l_salesteam_member_id number;
        l_setup_fee           number := 0;
        l_employee_id         number;
    begin
	  -- Excluding the clients that is inactive and dont need to be imported into SAM
	 -- DDLS to be created for the migration
    --exec pc_lookups.insert_lookups('SBS','ACCOUNT_TYPE','Benefit Solutions')
--insert into plans VALUES
--(520,'Benefit Solutions','SHA',null,1551,'SBS','A','SBS','N','N','N');
/*
create or replace view sbs_client (clientid,clientname,ein,street1,street2,city,state,zip
                     , effectivedate,phone,contactemail,fax,contactfirstname
                     , contactlastname,EnrollmentFee,note,ModifiedBy,istestclient,dba_name,termination_date
                     , enrollment_date)
as
SELECT "ClientID","ClientName","EIN","Street1","Street2"
   ,   "City","State","Zip","EffectiveDate","Phone","ContactEmail"
   ,   "Fax","ContactFirstName","ContactLastName","EnrollmentFee","Note"
   ,   "ModifiedBy","IsTestClient","DBA","TerminationDate","EnrollmentDate"
FROM CLIENT@GREATPLAINSDB*/
        for x in (
            select
                clientname,
                ein,
                street1,
                street2,
                city,
                state,
                zip,
                to_char(effectivedate, 'MM/DD/YYYY') effectivedate,
                phone,
                contactemail,
                fax,
                contactfirstname,
                contactlastname,
                enrollmentfee,
                note,
                modifiedby,
                clientid,
                dba_name,
                termination_date,
                enrollment_date
            from
                sbs_client
            where
                istestclient <> 1
        ) loop
            l_entrp_id := get_entrp_id_for_vendor(x.clientid, 'SBS');
            if l_entrp_id is null then
                l_acc_num := null;
                x_return_status := 'S';
                x_error_message := null;
                pc_employer_enroll.create_employer(
                    p_name                   => x.clientname,
                    p_ein_number             => x.ein,
                    p_address                => x.street1
                                 || ' '
                                 || x.street2,
                    p_city                   => x.city,
                    p_state                  => x.state,
                    p_zip                    => x.zip,
                    p_account_type           => 'SBS',
                    p_start_date             => x.effectivedate,
                    p_phone                  => x.phone,
                    p_email                  => x.contactemail,
                    p_fax                    => x.fax,
                    p_contact_name           => x.contactfirstname
                                      || ' '
                                      || x.contactlastname,
                    p_contact_phone          => x.phone,
                    p_broker_id              => 0,
                    p_salesrep_id            => null,
                    p_ga_id                  => null,
                    p_plan_code              => 520,
                    p_card_allowed           => 1,
                    p_setup_fee              => x.enrollmentfee,
                    p_note                   => x.note,
                    p_pin_mailer             => 'N',
                    p_cust_svc_rep           => null,
                    p_allow_eob              => 'N',
                    p_teamster_group         => 'N',
                    p_user_id                => nvl(
                        get_user_id(x.modifiedby),
                        0
                    ),
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
                    null;
                end if;
                l_entrp_id := pc_entrp.get_entrp_id(l_acc_num);
                update enterprise
                set
                    dba_name = x.dba_name
                where
                    entrp_id = l_entrp_id;

            end if;

            update account
            set
                end_date = x.termination_date,
                reg_date = x.enrollment_date
            where
                entrp_id = l_entrp_id;

        end loop;
    end migrate_sbs_employer;

end;
/


-- sqlcl_snapshot {"hash":"3f92ccc746ae6c8aff32a4b336fde58d250f910e","type":"PACKAGE_BODY","name":"PC_SBS_MIGRATION","schemaName":"SAMQA","sxml":""}