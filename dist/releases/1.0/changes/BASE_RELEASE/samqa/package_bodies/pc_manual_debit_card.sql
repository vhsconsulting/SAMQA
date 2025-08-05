-- liquibase formatted sql
-- changeset SAMQA:1754374052550 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_manual_debit_card.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_manual_debit_card.sql:null:e12ffd2f3eeaf41d4c8139ab50c3524ce42356aa:create

create or replace package body samqa.pc_manual_debit_card is

    procedure migrate_cards is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl card_creation_tab;
        l_sqlerrm         varchar2(32000);
    begin
        l_file_name := 'MB2_'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '_create.mbi';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            acc_num    employee_id,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            '20090812' start_date,
            null       start_time,
            null       email
        bulk collect
        into l_card_create_tbl
        from
            account    a,
            card_debit c
        where
            c.card_number is not null
            and a.pers_id = c.card_id;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count > 0 then
            l_line := 'IA'
                      || ','
                      || to_char((l_card_create_tbl.count) + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Card_Creation'
                      || ','
                      || 'STL_Result_Card_Creation'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        l_line := null;

     /*  FOR i IN 1 .. l_card_create_tbl.COUNT
       LOOP
           l_line := 'IB'                    -- Record ID
                ||','||G_TPA_ID                             -- TPA ID
            ||','||G_EMPLOYER_ID                        -- Employer ID
            ||','||l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
            ||','||l_card_create_tbl(i).last_name       -- Last Name
            ||','||l_card_create_tbl(i).first_name      -- First Name
            ||','||l_card_create_tbl(i).middle_name     -- Middle Name
            ||','||l_card_create_tbl(i).address         -- Address
            ||','||l_card_create_tbl(i).city            -- City
            ||','||l_card_create_tbl(i).state           -- State
            ||','||l_card_create_tbl(i).zip             -- Zip
                    ||','||'US'                                 -- Country
            ||','||'2'                                  -- Employee Status, 2 - Active
            ||','||l_card_create_tbl(i).gender          -- Gender
            ||','||l_card_create_tbl(i).birth_date      -- Birth Date
            ||','||'1'                                  -- HDHP eligible , 1 - Yes
            ||','||l_card_create_tbl(i).drivlic         -- Employee Driver License
            ||',CNEW_'||l_card_create_tbl(i).employee_id    -- Record Tracking Number
        ||','||l_card_create_tbl(i).email;            -- Email Address

           UTL_FILE.PUT_LINE( file   => l_utl_id
                            , buffer => l_line );

       END LOOP;*/

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IC'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || g_plan_id                        -- Plan ID
                      || ','
                      || l_card_create_tbl(i).employee_id        -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || g_plan_start_date                -- Plan Start Date
                      || ','
                      || g_plan_end_date                -- Plan End Date
                      || ','
                      || '2'                        -- Account Status , 2 - Active
                      || ','
                      || '0'                        -- Employee Pay Period Election
                      || ','
                      || '0'                        -- Employer Pay Period Election
                      || ','
                      || l_card_create_tbl(i).start_date           -- Effective Date
                      || ','
                      || '1'                        -- E-Signature Flag , 1 - Yes
                      || ','
                      || l_card_create_tbl(i).start_date        -- E-Signature Date
                      || ','
                      || l_card_create_tbl(i).start_time              -- E-Signature Time
                      || ',CNEW_'
                      || l_card_create_tbl(i).employee_id;            -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
   /*    FOR i IN 1 .. l_card_create_tbl.COUNT
       LOOP
           l_line := 'IF'                                           -- Record ID
                ||','||G_TPA_ID                    -- TPA ID
            ||','||G_EMPLOYER_ID                -- Employer ID
                ||','||l_card_create_tbl(i).employee_id        -- Employee ID
            ||','||TO_CHAR(SYSDATE,'YYYYMMDD')              -- Issue Date
                    ||','||TO_CHAR(SYSDATE,'YYYYMMDD')              -- Card Effective Date
                    ||','||'1'                                      -- Shipping Address Code, 1 - Cardholder Address
                ||','||'2'                        -- Issue Card
            ||','||'1'                                      -- Shipping Method Code, 1 - US Mail
            ||',CNEW_'||l_card_create_tbl(i).employee_id;        -- Record Tracking Number

           UTL_FILE.PUT_LINE( file   => l_utl_id
                            , buffer => l_line );

       END LOOP;*/

        utl_file.fclose(file => l_utl_id);
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('metavante@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating Card Creation File'
            , l_sqlerrm);
    end migrate_cards;

    procedure migrate_deposits is

        l_utl_id           utl_file.file_type;
        l_file_name        varchar2(3200);
        l_line             varchar2(32000);
        l_card_deposit_tbl amount_tab;
        l_sqlerrm          varchar2(32000);
    begin
        l_file_name := 'MB_'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '_payment6_IH.mbi';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');

      /** Posting the deposits ***/
      /** IH record is for all deposits **/

        select
            *
        bulk collect
        into l_card_deposit_tbl
        from
            (
                select
                    acc_num,
                    difference,
                    'Debit  Contribution',
                    to_char(sysdate, 'YYYYMMDD') fee_date,
                    to_char(sysdate, 'YYYYMMDD')
                    || rownum
                from
                    (
                        select
                            b.acc_num,
                            b.acc_id,
                            pc_account.acc_balance(b.acc_id)                         sam_balance,
                            a.disbursable_balance                                    metavante_balance,
                            pc_account.acc_balance(b.acc_id) - a.disbursable_balance difference
                        from
                            card_balance_external a,
                            account               b,
                            card_debit            c
                        where
                                employee_id = b.acc_num
                            and a.disbursable_balance < pc_account.acc_balance(b.acc_id)
                            and b.pers_id = c.card_id
                            and pc_account.acc_balance(b.acc_id) - a.disbursable_balance < 10
                    )
            );

        dbms_output.put_line('l_card_deposit_tbl.COUNT ' || l_card_deposit_tbl.count);
        if l_card_deposit_tbl.count > 0 then
            l_line := 'IA'
                      || ','
                      || to_char(l_card_deposit_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Deposit'
                      || ','
                      || 'STL_Result_Deposit'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_deposit_tbl.count loop
            l_line := 'IH'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_deposit_tbl(i).employee_id          -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || g_plan_start_date                -- Plan Start Date
                      || ','
                      || g_plan_end_date                             -- Plan End Date
                      || ','
                      || '1'                                         -- Deposit Type, 1 - Other
                      || ','
                      || l_card_deposit_tbl(i).amount               -- Employee Deposit Amount
                      || ','
                      || '0'                                         -- Employer Deposit Amount
--             ||','||G_PLAN_ID                                   -- Plan ID
                      || ','
                      || l_card_deposit_tbl(i).change_num          -- Record Tracking Number
                      || ','
                      || l_card_deposit_tbl(i).transaction_date    -- Display Date
                      || ','
                      || l_card_deposit_tbl(i).merchant_name;      -- Note

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
        l_line := null;
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('metavante@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating Deposit/Payment file'
            , l_sqlerrm);
    end migrate_deposits;

    function insert_file_seq (
        p_action in varchar2
    ) return number is
        l_file_id number;
    begin
        insert into metavante_files (
            file_id,
            file_action,
            creation_date,
            last_update_date
        ) values ( file_seq.nextval,
                   p_action,
                   sysdate,
                   sysdate ) returning file_id into l_file_id;

        return l_file_id;
    end;

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2 is
        x_file_name varchar2(320);
    begin
        select
            decode(p_result,
                   'RESULT',
                   replace(file_name, '.mbi', '.res'),
                   'EXPORT',
                   replace(file_name, '.mbi', '.exp'))
        into x_file_name
        from
            metavante_files
        where
                file_id = (
                    select
                        max(file_id)
                    from
                        metavante_files
                    where
                        file_action = p_action
                )
            and result_flag = 'N';

        return x_file_name;
    exception
        when others then
            return null;
    end;

    procedure import_req_export (
        p_record_type      in varchar2,
        p_transaction_type in varchar2,
        p_file_name        in out varchar2
    ) is

        l_utl_id     utl_file.file_type;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_reopen_tbl varchar2_tab;
        l_sqlerrm    varchar2(32000);
        l_file_id    number;
    begin
          /** will check with metavante if IL record is needed for this **/
        if p_record_type is not null then
            if p_file_name is null then
                l_file_id := insert_file_seq(p_record_type);
                l_file_name := 'MB_'
                               || l_file_id
                               || '_'
                               || p_record_type
                               || '.mbi';
                dbms_output.put_line('file id ' || l_file_id);
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || 2
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_'
                      || p_record_type
                      || '_Import'
                      || ','
                      || 'STL_Export_Result'
                      || ','
                      || 'STL_'
                      || p_record_type
                      || '_Export';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            if p_record_type <> 'EN' then
                l_line := 'IL'            -- Record ID
                          || ','
                          || g_tpa_id             -- TPA ID
                          || ','
                          || p_record_type        -- Export Record Type
                          || ','
                          || '1'                  -- Transaction TYpe, 1- All
                          || ','
                          || ''                   -- -- Export Date from
                          || ','
                          || ''                   -- Export Date to
                          || ','
                          || '2';                 -- Output format

            else
                l_line := 'IL'                            -- Record ID
                          || ','
                          || g_tpa_id                             -- TPA ID
                          || ','
                          || p_record_type                        -- Export Record Type
                          || ','
                          || '7'                                  -- Transaction Origination, 'POS'
                          || ','
                          || '21'                                  -- Transaction TYpe, includes Pre-Auth, Force-Post, Refund
                          || ','
                          || '1'                                 -- Transaction Status
                          || ','
                          || '1';                                  -- Transaction Date Type, 1 -- Settlement Date
                l_line := l_line
                          || ','
                          || '20100301'; -- Export Date from

                l_line := l_line
                          || ','
                          || '20100310'   -- Export Date to
                          || ','
                          || '2'                                 -- Output format
                          || ','
                          || '4';                                  -- Transaction Filter

            end if;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            mail_utility.send_email('metavante@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Generating Export Request for ' || p_record_type
            , l_sqlerrm);
    end;

    procedure request_transaction_export (
        p_file_name in out varchar2
    ) is
    begin
        -- 'EC' is to get the available balance in the card
        import_req_export('EN', 'SETTLEMENT', p_file_name);
    end;

    procedure onetime_terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_payment_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_deposit_tbl  amount_tab;
        l_card_payment_tbl  amount_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
    begin
        l_line := null;
        l_file_id := null;

       /*** Posting disbursements ***/
       /** II is for all disbursements, pre auth and debit card purchases are excluded **/
        if p_acc_num_list is null then
            select
                b.acc_num,
                current_card_value amount,
                'Termination Debit',
                to_char(sysdate, 'YYYYMMDD'),
                b.acc_id
            bulk collect
            into l_card_payment_tbl
            from
                account    b,
                card_debit c
            where
                    b.account_status = 4
                and b.pers_id = c.card_id
                and c.card_number is not null
                and current_card_value > 0
                and exists (
                    select
                        *
                    from
                        card_debit
                    where
                            card_id = b.pers_id
                        and card_number is not null
                );

        end if;

        if l_card_payment_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('PAYMENT');
                l_payment_file_name := 'MB_'
                                       || l_file_id
                                       || '_payment.mbi';
            else
                l_payment_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_payment_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_payment_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_payment_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Payment'
                      || ','
                      || 'STL_Result_Payment'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_payment_tbl.count loop
            l_line := 'II'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_payment_tbl(i).employee_id        -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || l_card_payment_tbl(i).merchant_name        -- Merchant Name
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service from
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service to
                      || ','
                      || l_card_payment_tbl(i).amount                -- Approved Claim Amount
        --     ||','||G_PLAN_START_DATE                           -- Plan Start Date
        --     ||','||G_PLAN_END_DATE                             -- Plan End Date
    --                 ||','||G_PLAN_ID                                   -- Plan ID
                      || ','
                      || l_card_payment_tbl(i).change_num;      -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_payment_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_file_name := l_payment_file_name;
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('metavante@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating Deposit/Payment file'
            , l_sqlerrm);
    end onetime_terminate;

end pc_manual_debit_card;
/

