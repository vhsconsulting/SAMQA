-- liquibase formatted sql
-- changeset SAMQA:1754373992385 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_data_scrub.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_data_scrub.sql:null:c9381ec1ff3e9a53a7209bb56ac359b9e63bcde4:create

create or replace package body samqa.pc_data_scrub as

    procedure process_enterprise is
    begin
        update enterprise
        set
            entrp_email = 'IT-team@sterlingadministration.com';

        update contact
        set
            email = 'IT-team@sterlingadministration.com';

        update online_users
        set
            email = 'IT-team@sterlingadministration.com',
            password = '228b13d0a559f06a100f1e49c'; -- encrypted password for ITTeam2005$$

        update user_security_info
        set
            pw_question1 = 1,
            pw_answer1 = 'fruit',
            pw_question2 = 6,
            pw_answer2 = 'book',
            pw_question3 = 11,
            pw_answer3 = 'place';

        update person
        set
            email = 'IT-team@sterlingadministration.com';

        update employer_online_enrollment
        set
            email = 'IT-team@sterlingadministration.com';

        update enrollment_edi_detail
        set
            email = 'IT-team@sterlingadministration.com';

        update online_enrollment
        set
            email = 'IT-team@sterlingadministration.com';

        update online_hfsa_enroll_stage
        set
            email_address = 'IT-team@sterlingadministration.com';

        update cobra_email_notifications
        set
            to_address = 'IT-team@sterlingadministration.com',
            cc_address = 'IT-team@sterlingadministration.com'; 

		-------added by rpu 16/05/2025 		
        update cobra_plans
        set
            carrier_contact_email = 'it-team@sterlingamdinistration.com',
            carrier_phone_no = '111-111-1111';

        update contact_import
        set
            tax_id = '99-999999';

        update cobra_plan_setup
        set
            carrier_contact_name = 'Carrier Contact Name',
            carrier_contact_email = 'it-team@sterlingamdinistration.com',
            carrier_phone_no = '111-111-1111';

        update contact_leads
        set
            email = 'it-team@sterlingamdinistration.com',
            phone_num = '111-111-1111',
            contact_fax = '111-111-1111';

    end process_enterprise;

    procedure process_ssn (
        p_entrp_id in varchar2
    ) as

        type l_varchar_tbl is
            table of varchar2(30) index by binary_integer;
        l_old_ssn_tbl l_varchar_tbl;
        l_new_ssn_tbl l_varchar_tbl;
        cursor person_cur is
        select
            ssn old_ssn,
            format_ssn(substr(
                abs(dbms_random.random),
                0,
                9
            ))  new_ssn
        from
            (
                select
                    ssn
                from
                    person
                where
                    ssn is not null
                    and entrp_id = p_entrp_id
                    and p_entrp_id is not null
                group by
                    ssn
                union
                select
                    ssn
                from
                    person
                where
                    ssn is not null
                    and entrp_id is not null
                    and p_entrp_id is null
                group by
                    ssn
                union
                select
                    ssn
                from
                    person
                where
                    ssn is not null
                    and entrp_id is null
                    and p_entrp_id is null
                group by
                    ssn
            );

        type person_row is
            table of person_cur%rowtype index by pls_integer;
        l_person_row  person_row;
    begin
        execute immediate 'truncate table DEPOSIT_REGISTER';
        execute immediate 'truncate table DEBIT_SETTLEMENT_ERROR';
        execute immediate 'truncate table DEBIT_DAILY_BALANCE';
        execute immediate 'truncate table DEBIT_CARD_UPDATES';
        execute immediate 'truncate table DEBIT_CARD_ADJUST';
        execute immediate 'truncate table FAUTH';
        execute immediate 'truncate table EB_SSN_UPDATES';
        update person
        set
            email = 'IT-team@sterlingadministration.com',
            address = '1000 broadway',
            city = 'Oakland',
            state = 'CA',
            zip = '94612';

        open person_cur;
        loop
            fetch person_cur
            bulk collect into l_person_row limit 500;
            forall i in 1..l_person_row.count
                update person
                set
                    ssn = l_person_row(i).new_ssn,
                    birth_date = '01-JAN-1980'
                where
                    ssn = l_person_row(i).old_ssn;

            forall i in 1..l_person_row.count
                update mass_enroll_dependant
                set
                    ssn = l_person_row(i).new_ssn
                where
                    ssn = l_person_row(i).old_ssn;

            forall i in 1..l_new_ssn_tbl.count
                update mass_enroll_dependant
                set
                    subscriber_ssn = l_person_row(i).new_ssn
                where
                    subscriber_ssn = l_person_row(i).old_ssn;

            forall i in 1..l_person_row.count
                update mass_enrollments
                set
                    ssn = l_person_row(i).new_ssn
                where
                    ssn = l_person_row(i).old_ssn;

            forall i in 1..l_person_row.count
                update termination_interface
                set
                    ssn = l_person_row(i).new_ssn
                where
                    ssn = l_person_row(i).old_ssn;

            forall i in 1..l_new_ssn_tbl.count
                update enrollment_edi_detail
                set
                    ssn = l_person_row(i).new_ssn
                where
                    ssn = l_person_row(i).old_ssn;

            forall i in 1..l_person_row.count
                update online_enrollment
                set
                    ssn = l_person_row(i).new_ssn
                where
                    ssn = l_person_row(i).old_ssn;

            forall i in 1..l_person_row.count
                update sales_commission_history
                set
                    ssn = l_person_row(i).new_ssn
                where
                    ssn = l_person_row(i).old_ssn;

            commit;
            exit when l_person_row.count = 0;
        end loop;

    end process_ssn;

    procedure process_bank_acct is
    begin
        for x in (
            select
                bank_acct_num old_bank_acct,
                substr(
                    abs(dbms_random.random),
                    0,
                    9
                )             new_bank_acct
            from
                user_bank_acct
        ) loop
            update user_bank_acct
            set
                bank_acct_num = x.new_bank_acct
            where
                bank_acct_num = x.old_bank_acct;

            update claim_interface
            set
                bank_acct_number = x.new_bank_acct
            where
                bank_acct_number = x.old_bank_acct;
            --update BANK_ACCT_EXT set BANK_ACCT_NUM = x.new_bank_acct  where BANK_ACCT_NUM = x.old_bank_acct;
            --update ACH_TRANSFER_EXTERNAL set BANK_ACCT_NUM = x.new_bank_acct  where BANK_ACCT_NUM = x.old_bank_acct;
            --update CLAIMS_EXTERNAL set BANK_ACCT_NUMBER = x.new_bank_acct  where BANK_ACCT_NUMBER = x.old_bank_acct;
            --update ENROLL_MAIN_EXTERNAL set BANK_ACCT_NUM = x.new_bank_acct  where BANK_ACCT_NUM = x.old_bank_acct;

        end loop;
    end process_bank_acct;

    procedure process_routing_num is
    begin
        for x in (
            select
                bank_routing_num old_routing_num,
                substr(
                    abs(dbms_random.random),
                    0,
                    9
                )                new_routing_num
            from
                user_bank_acct
        ) loop
            update user_bank_acct
            set
                bank_routing_num = x.new_routing_num
            where
                bank_routing_num = x.old_routing_num;

            update claim_interface
            set
                routing_number = x.new_routing_num
            where
                routing_number = x.old_routing_num;
            --update BANK_ACCT_EXT set BANK_ROUTING_NUM = x.new_routing_num  where BANK_ROUTING_NUM = x.old_routing_num;
            --update ACH_TRANSFER_EXTERNAL set BANK_ROUTING_NUM = x.new_routing_num  where BANK_ROUTING_NUM = x.old_routing_num;
            --update CLAIMS_EXTERNAL set ROUTING_NUMBER = x.new_routing_num  where ROUTING_NUMBER = x.old_routing_num;
            --update ONLINE_ENROLLMENT set ROUTING_NUMBER = x.new_routing_num  where ROUTING_NUMBER = x.old_routing_num;
            --update ENROLL_MAIN_EXTERNAL set BANK_ROUTING_NUM = x.new_routing_num  where BANK_ROUTING_NUM = x.old_routing_num;

        end loop;
    end process_routing_num;

    procedure run (
        p_entrp_id in varchar2
    ) is
    begin
        process_ssn(p_entrp_id);
        process_bank_acct;
        process_routing_num;
        process_enterprise;
    --    commit;
    exception
        when others then
            rollback;
            raise;
    end;

    procedure purge_tables is
    begin
   -- commiting, as this is not a transaction and not to extend rollback segment too much !!
        delete from website_logs wl
        where
            wl.creation_date < add_months(sysdate, -3);

        commit;
        delete from metavante_errors
        where
            last_update_date < add_months(sysdate, -3);

        commit;
        delete from email_notifications
        where
            last_update_date < add_months(sysdate, -3);

        commit;
        delete from user_login_history
        where
            creation_date < add_months(sysdate, -3);

        commit;
        delete from external_files
        where
            last_update_date < add_months(sysdate, -6);

        commit;
        delete from cobra_email_notifications
        where
            last_update_date < add_months(sysdate, -6);

        commit;
        delete npm_enrollments;

        commit;
    end;

end pc_data_scrub;
/

