create or replace package body samqa.pc_sam_gp_intgrtn as

    utlf         utl_file.file_type;
    no_records exception;
    l_file_id    number;
    dir          varchar2(100) := 'GP';
    l_message    varchar2(32000);
    l_line       varchar2(32000);
    cstmr_id_tbl varchar2_4000_tbl;
    cnt          number;

    function is_stacked_account (
        p_entrp_id in number
    ) return varchar2 is
        l_stacked_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup plans,
                enterprise                er,
                account                   acc
            where
                    er.entrp_id = p_entrp_id
                and plans.entrp_id = er.entrp_id
                and plans.entrp_id = acc.entrp_id
                and acc.account_type = 'FSA'
                and plans.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
        ) loop
            if x.cnt > 0 then
                l_stacked_flag := 'Y';
            end if;
        end loop;

        return l_stacked_flag;
    end is_stacked_account;

    procedure insert_customer_gt (
        p_customer_id   in varchar2,
        p_customer_name in varchar2,
        p_class_id      in varchar2,
        p_stacked       in varchar2,
        p_account_type  in varchar2,
        p_acc_id        in number,
        p_status        in varchar2,
        p_customer_type in varchar2,
        p_entrp_id      in number,
        p_pers_id       in number
    ) is
    begin
        insert into gp_customer_account_gt (
            customer_id,
            customer_name,
            class_id,
            stacked,
            account_type,
            acc_id,
            status,
            customer_type,
            pers_id,
            entrp_id
        ) values ( p_customer_id,
                   p_customer_name,
                   p_class_id,
                   p_stacked,
                   p_account_type,
                   p_acc_id,
                   p_status,
                   p_customer_type,
                   p_pers_id,
                   p_entrp_id );

    end insert_customer_gt;

    procedure insert_ap_ar_txn_outbnd (
        p_batch_id    in varchar2,
        p_entity_id   in varchar2,
        p_entity_type in varchar2,
        p_doc_date    in varchar2,
        p_amount      in number,
        p_file_name   in varchar2
    ) is
    begin
        insert into gp_ap_ar_txn_outbnd (
            txn_id,
            batch_id,
            entity_id,
            entity_type,
            document_date,
            amount,
            file_name,
            creation_date
        ) values ( gp_ap_ar_txn_outbnd_seq.nextval,
                   p_batch_id,
                   p_entity_id,
                   p_entity_type,
                   p_doc_date,
                   p_amount,
                   p_file_name,
                   sysdate );

    end insert_ap_ar_txn_outbnd;

    procedure insert_alert (
        p_subject in varchar2,
        p_message in varchar2
    ) is
        l_notification_id number;
    begin
        pc_notifications.insert_notifications('sam_gp@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com'
        , 'customer.service@sterlingadministration.com', p_subject, p_message,
                                              0, null, l_notification_id);

        update email_notifications
        set
            mail_status = 'READY'
        where
            notification_id = l_notification_id;

    end insert_alert;

    function insert_file_seq (
        p_action in varchar2
    ) return number is
        l_file_id number;
    begin
        insert into external_files (
            file_id,
            file_action,
            creation_date,
            last_update_date
        ) values ( file_seq.nextval,
                   p_action,
                   sysdate,
                   sysdate ) returning file_id into l_file_id;

        return l_file_id;
    end insert_file_seq;

    function get_checkbook_id (
        p_prod_type   in varchar2,
        p_reason_type in varchar2
    ) return varchar2 is
        l_checkbook_id varchar2(100);
    begin
        for x in (
            select
                account_type,
                reason_type,
                chk.checkbook_code
            from
                customer_class_gp cg,
                checkbook_gp      chk
            where
                cg.account_type is not null
                and cg.account_type = p_prod_type
                and cg.reason_type = p_reason_type
                and chk.checkbook_id = cg.checkbook_id
            union
            select
                account_type,
                reason_type,
                chk.checkbook_code
            from
                vendor_class_gp cg,
                checkbook_gp    chk
            where
                cg.account_type is not null
                and cg.account_type = p_prod_type
                and cg.reason_type = p_reason_type
                and chk.checkbook_id = cg.checkbook_id
        ) loop
            l_checkbook_id := x.checkbook_code;
        end loop;

        return l_checkbook_id;
    end get_checkbook_id;

    function get_class_id (
        p_prod_type   in varchar2,
        p_reason_type in varchar2
    ) return varchar2 is
        l_class_id varchar2(100);
    begin
        for x in (
            select
                cust_class_code
            from
                (
                    select
                        account_type,
                        reason_type,
                        cust_class_code
                    from
                        customer_class_gp
                    where
                        account_type is not null
                        and account_type = p_prod_type
                        and reason_type = nvl(p_reason_type, reason_type)
                    union
                    select
                        account_type,
                        reason_type,
                        vendor_class_code
                    from
                        vendor_class_gp
                    where
                        account_type is not null
                )
            where
                    account_type = p_prod_type
                and reason_type = nvl(p_reason_type, reason_type)
        ) loop
            l_class_id := x.cust_class_code;
        end loop;

        return l_class_id;
    end get_class_id;
--23
    procedure gp_cstmr_adrs (
        x_file_name out varchar2
    ) is
    begin
        select distinct
            customer_id
        bulk collect
        into cstmr_id_tbl
        from
            gp_customer_account_gt
        order by
            1;

        if cstmr_id_tbl.count > 0 then
            l_file_id := insert_file_seq('GP_CSTMR_ADR');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_cstmr_adr.csv';
            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'customer_id,address_id,contact,address1,address2,address3,city,state,zip,country_code,'
                      || 'country,phone1,phone2,phone3,fax,tax_schedule,shipping_method,ups_zone,salesperson_id,'
                      || 'territory_id,user_defined1,user_defined2,site_id';--23

            utl_file.put_line(utlf, l_line);
            for i in 1..cstmr_id_tbl.last loop
                l_line := cstmr_id_tbl(i)
                          || ',PRIMARY'
                          || rpad(',', 21, ',');--23
                utl_file.put_line(utlf, l_line);
            end loop;

            utl_file.fclose(utlf);
        end if;

    exception
        when others then
            utl_file.fclose_all;
           --    pc_log.log_app_error('PC_SAM_GP_INTGRTN','gp_cstmr_adrs',DBMS_UTILITY.FORMAT_CALL_STACK
             --   , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

    end gp_cstmr_adrs;
--75 fd
    procedure gp_customer_account (
        x_file_name out varchar2
    ) is
        gp_cstm_acc ty_tb_gp_cstmr_acc;
    begin
        select
            *
        bulk collect
        into gp_cstm_acc
        from
            (
                select
                    acc_id,
                    account_type,
                    regexp_replace(acc_num, '[[:cntrl:]]'),
                    substr(
                        replace(
                            replace(first_name
                                    || ' '
                                    || middle_name
                                    || ' '
                                    || last_name, ','),
                            '  ',
                            ' '
                        ),
                        1,
                        64
                    )                                     name,
                    'PRIMARY',
                    'N',--stkd
                    pc_account.have_outside_investment(acc_id),
                    decode(b.account_status, 4, 'N', 'Y') status,
                    '',
                    a.pers_id,
                    null
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and account_type = 'HSA'
                    and trunc(b.creation_date) >= trunc(sysdate) - 30
                union
                select
                    acc_id,
                    account_type,
                    regexp_replace(acc_num, '[[:cntrl:]]'),
                    substr(
                        replace(name, ','),
                        1,
                        64
                    ),
                    'PRIMARY',
                    is_stacked_account(a.entrp_id),
                    'N',--invst,
                    decode(b.account_status, 4, 'N', 'Y') status,
                    'E',
                    null,
                    a.entrp_id
                from
                    enterprise a,
                    account    b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and trunc(b.creation_date) >= trunc(sysdate) - 30
            )
        order by
            2;

        if gp_cstm_acc.count > 0 then
            l_file_id := insert_file_seq('GP_CSTMR_ACNT');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_cstmr_acnt.csv';
            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w', 32767);
            l_line := 'Customer ID,Customer Name,Short Name,Statement Name,Active,Class ID,Primary Address ID,'
                      || 'Ship To Address ID,Bill To Address ID,Statement To Address ID,Salesperson ID,Territory ID,'
                      || 'User Defined 1,User Defined 2,Comment 1,Comment 2,Trade Discount,Payment Terms,'
                      || 'Discount Grace Period,Due Date Grace Period,Price Level,Note,Checkbook ID,Cash Account From,'
                      || 'Cash,Accounts Receivable,Sales,Cost of Sales,Inventory,Terms Discounts Taken,'
                      || 'Terms Discounts Available,Finance Charges,Write-offs,Overpayment Write-offs,'
                      || 'Sales Order Returns,E Mail,Home Page,FTP Site,Image,Login,Password,sam_account_no,'
                      || 'User Defined 2,Additional Information,Balance Type,Finance Charge Type,Finance Charge Percent,'
                      || 'Finance Charge Dollar,Minimum Payment Type,Minimum Payment Percent,Minimum Payment Dollar,'
                      || 'Credit Limit Type,Credit Limit Amount,Maximum Write-off Type,Maximum Write-off Amount,'
                      || 'Post Results To,Order Fulfillment Shortage Default,Credit Card ID,Credit Card Number,'
                      || 'Expiration Date,Bank Name,Bank Branch,Language,Tax Exempt 1,Tax Exempt 2,Tax Registration,'
                      || 'Currency ID,Rate Type ID,Statement Cycle,Maintain Calendar Year,Maintain Fiscal Year,'
                      || 'Maintain Transaction,Maintain Distribution,EMail To:,Email CC:,Email BCC:,Record_Number';--75

            utl_file.put_line(utlf, l_line);
            for i in 1..gp_cstm_acc.count loop
                if gp_cstm_acc(i).acnt_typ = 'HSA' then
                    if gp_cstm_acc(i).entity_typ is null then
                        l_line := gp_cstm_acc(i).cstvnd_id
                                  || ','
                                  || gp_cstm_acc(i).cstvnd_nm
                                  || ',,,'
                                  || gp_cstm_acc(i).status
                                  || ','
                                  || get_class_id(gp_cstm_acc(i).acnt_typ,
                                                  'CONT')
                                  || ','
                                  || gp_cstm_acc(i).address_id
                                  || rpad(',', 35, ',')
                                  || gp_cstm_acc(i).cstvnd_id
                                  || rpad(',', 34, ',')
                                  || ','
                                  || gp_cstm_acc(i).acc_id;

                        utl_file.put_line(utlf, l_line);
                        insert_customer_gt(gp_cstm_acc(i).cstvnd_id,
                                           gp_cstm_acc(i).cstvnd_nm,
                                           get_class_id(gp_cstm_acc(i).acnt_typ,
                                                        'CONT'),
                                           'N',
                                           gp_cstm_acc(i).acnt_typ,
                                           gp_cstm_acc(i).acc_id,
                                           gp_cstm_acc(i).status,
                                           'CONTRIBUTION',
                                           gp_cstm_acc(i).entrp_id,
                                           gp_cstm_acc(i).pers_id);

                        if gp_cstm_acc(i).outside_inv = 'Y' then
                            l_line := ltrim(gp_cstm_acc(i).cstvnd_id,
                                            '0')
                                      || '-OI'
                                      || ','
                                      || gp_cstm_acc(i).cstvnd_nm
                                      || ',,,'
                                      || gp_cstm_acc(i).status
                                      || ','
                                      || get_class_id(gp_cstm_acc(i).acnt_typ,
                                                      'OI')
                                      || ','
                                      || gp_cstm_acc(i).address_id
                                      || rpad(',', 35, ',')
                                      || gp_cstm_acc(i).cstvnd_id--||'-OI'
                                      || rpad(',', 34, ',')
                                      || ','
                                      || gp_cstm_acc(i).acc_id;

                            utl_file.put_line(utlf, l_line);
--following 4 changes made due to gtt table populating cstmr_id with suffix -OI -FSA -HRA -FEE and gtt tbl is blk clctd in gp_vndr_acnt which again appends same suffix and as a result there are two identical suffix appended and string exceeds 15 char
                            insert_customer_gt(ltrim(gp_cstm_acc(i).cstvnd_id,
                                                     '0')
                                               || '-OI',
                                               gp_cstm_acc(i).cstvnd_nm,
                                               get_class_id(gp_cstm_acc(i).acnt_typ,
                                                            'CONT'),
                                               'N',
                                               gp_cstm_acc(i).acnt_typ,
                                               gp_cstm_acc(i).acc_id,
                                               gp_cstm_acc(i).status,
                                               'OUTSIDE_INVESTMENT',
                                               gp_cstm_acc(i).entrp_id,
                                               gp_cstm_acc(i).pers_id);

                        end if;

                    else
                        l_line := gp_cstm_acc(i).cstvnd_id
                                  || ','
                                  || gp_cstm_acc(i).cstvnd_nm
                                  || ',,,'
                                  || gp_cstm_acc(i).status
                                  || ','
                                  || get_class_id(gp_cstm_acc(i).acnt_typ
                                                  || 'ER',
                                                  'CONT')
                                  || ','
                                  || gp_cstm_acc(i).address_id
                                  || rpad(',', 35, ',')
                                  || gp_cstm_acc(i).cstvnd_id
                                  || rpad(',', 34, ',')
                                  || ','
                                  || gp_cstm_acc(i).acc_id;

                        utl_file.put_line(utlf, l_line);
                        insert_customer_gt(gp_cstm_acc(i).cstvnd_id,
                                           gp_cstm_acc(i).cstvnd_nm,
                                           get_class_id(gp_cstm_acc(i).acnt_typ
                                                        || 'ER',
                                                        'CONT'),
                                           'N',
                                           gp_cstm_acc(i).acnt_typ,
                                           gp_cstm_acc(i).acc_id,
                                           gp_cstm_acc(i).status,
                                           'CONTRIBUTION',
                                           gp_cstm_acc(i).entrp_id,
                                           gp_cstm_acc(i).pers_id);

                    end if;
                end if;

                if gp_cstm_acc(i).acnt_typ in ( 'HRA', 'FSA' ) then
                    if gp_cstm_acc(i).stckd = 'Y' then
                        for c in (
                            select
                                cust_class_code class_id,
                                reason_type,
                                account_type
                            from
                                customer_class_gp
                            where
                                account_type in ( 'FSA', 'HRA' )
                        ) loop
                            if c.reason_type = 'FEE' then
                                if c.account_type = gp_cstm_acc(i).acnt_typ then
                                    l_line := gp_cstm_acc(i).cstvnd_id
                                              || '-'
                                              || c.reason_type
                                              || ','
                                              || gp_cstm_acc(i).cstvnd_nm
                                              || ',,,'
                                              || gp_cstm_acc(i).status
                                              || ','
                                              || c.class_id
                                              || ','
                                              || gp_cstm_acc(i).address_id
                                              || rpad(',', 35, ',')
                                              || gp_cstm_acc(i).cstvnd_id--||'-'||c.reason_type
                                              || rpad(',', 34, ',')
                                              || ','
                                              || gp_cstm_acc(i).acc_id;

                                    utl_file.put_line(utlf, l_line);
                                    insert_customer_gt(gp_cstm_acc(i).cstvnd_id
                                                       || '-'
                                                       || c.reason_type,
                                                       gp_cstm_acc(i).cstvnd_nm,
                                                       c.class_id,
                                                       'Y',
                                                       gp_cstm_acc(i).acnt_typ,
                                                       gp_cstm_acc(i).acc_id,
                                                       gp_cstm_acc(i).status,
                                                       'FEE',
                                                       gp_cstm_acc(i).entrp_id,
                                                       gp_cstm_acc(i).pers_id);

                                end if;

                            else
                                l_line := gp_cstm_acc(i).cstvnd_id
                                          || '-'
                                          || c.account_type
                                          || ','
                                          || gp_cstm_acc(i).cstvnd_nm
                                          || ',,,'
                                          || gp_cstm_acc(i).status
                                          || ','
                                          || c.class_id
                                          || ','
                                          || gp_cstm_acc(i).address_id
                                          || rpad(',', 35, ',')
                                          || gp_cstm_acc(i).cstvnd_id--||'-'||c.prod_type
                                          || rpad(',', 34, ',')
                                          || ','
                                          || gp_cstm_acc(i).acc_id;

                                utl_file.put_line(utlf, l_line);
                                insert_customer_gt(gp_cstm_acc(i).cstvnd_id
                                                   || '-'
                                                   || c.account_type,
                                                   gp_cstm_acc(i).cstvnd_nm,
                                                   c.class_id,
                                                   'Y',
                                                   c.account_type,
                                                   gp_cstm_acc(i).acc_id,
                                                   gp_cstm_acc(i).status,
                                                   'CONTRIBUTION',
                                                   gp_cstm_acc(i).entrp_id,
                                                   gp_cstm_acc(i).pers_id);

                            end if;
                              --utl_file.put_line(utlf,l_line);

                        end loop;

                    else
                        for c in (
                            select
                                cust_class_code class_id,
                                reason_type,
                                account_type
                            from
                                customer_class_gp
                            where
                                account_type = gp_cstm_acc(i).acnt_typ
                        ) loop
                            if c.reason_type = 'FEE' then
                                l_line := gp_cstm_acc(i).cstvnd_id
                                          || '-'
                                          || c.reason_type
                                          || ','
                                          || gp_cstm_acc(i).cstvnd_nm
                                          || ',,,'
                                          || gp_cstm_acc(i).status
                                          || ','
                                          || c.class_id
                                          || ','
                                          || gp_cstm_acc(i).address_id
                                          || rpad(',', 35, ',')
                                          || gp_cstm_acc(i).cstvnd_id--||'-'||c.reason_type
                                          || rpad(',', 34, ',')
                                          || ','
                                          || gp_cstm_acc(i).acc_id;

                                insert_customer_gt(gp_cstm_acc(i).cstvnd_id
                                                   || '-'
                                                   || c.reason_type,
                                                   gp_cstm_acc(i).cstvnd_nm,
                                                   c.class_id,
                                                   'N',
                                                   gp_cstm_acc(i).acnt_typ,
                                                   gp_cstm_acc(i).acc_id,
                                                   gp_cstm_acc(i).status,
                                                   'FEE',
                                                   gp_cstm_acc(i).entrp_id,
                                                   gp_cstm_acc(i).pers_id);

                            else
                                l_line := gp_cstm_acc(i).cstvnd_id
                                          || ','
                                          || gp_cstm_acc(i).cstvnd_nm
                                          || ',,,'
                                          || gp_cstm_acc(i).status
                                          || ','
                                          || c.class_id
                                          || ','
                                          || gp_cstm_acc(i).address_id
                                          || rpad(',', 35, ',')
                                          || gp_cstm_acc(i).cstvnd_id
                                          || rpad(',', 34, ',')
                                          || ','
                                          || gp_cstm_acc(i).acc_id;

                                insert_customer_gt(gp_cstm_acc(i).cstvnd_id,
                                                   gp_cstm_acc(i).cstvnd_nm,
                                                   c.class_id,
                                                   'N',
                                                   gp_cstm_acc(i).acnt_typ,
                                                   gp_cstm_acc(i).acc_id,
                                                   gp_cstm_acc(i).status,
                                                   'CONTRIBUTION',
                                                   gp_cstm_acc(i).entrp_id,
                                                   gp_cstm_acc(i).pers_id);

                            end if;

                            utl_file.put_line(utlf, l_line);
                        end loop;
                    end if;--gp_cstm_acc(i).stckd ='Y'
                end if;

                if gp_cstm_acc(i).acnt_typ in ( 'COBRA', 'CMP', 'POP', 'ERISA_WRAP', 'FORM_5500' ) then
                    l_line := gp_cstm_acc(i).cstvnd_id
                              || ','
                              || gp_cstm_acc(i).cstvnd_nm
                              || ',,,'
                              || gp_cstm_acc(i).status
                              || ','
                              || get_class_id(gp_cstm_acc(i).acnt_typ,
                                              'FEE')
                              || ','
                              || gp_cstm_acc(i).address_id
                              || rpad(',', 35, ',')
                              || gp_cstm_acc(i).cstvnd_id
                              || rpad(',', 34, ',')
                              || ','
                              || gp_cstm_acc(i).acc_id;

                    insert_customer_gt(gp_cstm_acc(i).cstvnd_id,
                                       gp_cstm_acc(i).cstvnd_nm,
                                       get_class_id(gp_cstm_acc(i).acnt_typ,
                                                    'FEE'),
                                       'N',
                                       gp_cstm_acc(i).acnt_typ,
                                       gp_cstm_acc(i).acc_id,
                                       gp_cstm_acc(i).status,
                                       'FEE',
                                       gp_cstm_acc(i).entrp_id,
                                       gp_cstm_acc(i).pers_id);

                    utl_file.put_line(utlf, l_line);
                end if;

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'Customers');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_customer_account;
--66 fd vn ac mn

   -- GP uses customer as vendor as well
   -- So the customer id of customer and vendor are the same
   -- so all the customers with customer type CONTRIBUTION will be sent to
   -- GP as vendors

    procedure gp_vendor_account (
        x_file_name out varchar2
    ) is
        gp_vndr_acc    ty_tb_gp_vndr_acc;
        outside_invest varchar2(1);
    begin
        select
            acc_id,
            account_type,
            customer_id,
            customer_name,
            'PRIMARY',
            stacked,
            '',
            status,
            '',
            pers_id,
            entrp_id
        bulk collect
        into gp_vndr_acc
        from
            (
                select distinct
                    acc_id,
                    account_type,
                    customer_id,
                    customer_name,
                    stacked,
                    status,
                    pers_id,
                    entrp_id
                from
                    gp_customer_account_gt
                where
                    customer_type in ( 'OUTSIDE_INVESTMENT', 'CONTRIBUTION' )
                    and ( pers_id is null
                          or entrp_id is null )
                    and account_type in ( 'HSA', 'HRA', 'FSA' )
                union
                select distinct
                    acc_id,
                    account_type,
                    customer_id,
                    customer_name,
                    stacked,
                    status,
                    pers_id,
                    entrp_id
                from
                    gp_customer_account_gt
                where
                        customer_type = 'FEE'
                    and ( pers_id is null
                          or entrp_id is null )
                    and account_type not in ( 'HSA', 'HRA', 'FSA' )
            )
        order by
            2,
            1;

        if gp_vndr_acc.count > 0 then
            l_file_id := insert_file_seq('GP_VNDR_ACNT');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_vndr_acnt.csv';
            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w', 32767);
            l_line := 'vendor_id,name,Active,class_id,primary_address_id,vendor_account,purchase_address_id,'
                      || 'remit_to_address_id,ship_from_address_id,comment_1,comment_2,note,vendor_id,'
                      || 'use_cash_account_from,cash,accounts_payable,terms_discounts_available,terms_discounts_taken,'
                      || 'finance_charges,purchases,trade_discount,miscellaneous,freight,tax,write_offs,accrued_purchases,'
                      || 'purchase_price_variance,address_id,e_mail,home_page,ftp_site,login,password,user_defined_1,'
                      || 'user_defined_2,additional_information,currency_id,rate_type_id,payment_terms,discount_grace_period,'
                      || 'due_date_grace_period,payment_priority,minimum_order,trade_discount,tax_id,tax_registration,'
                      || 'checkbook_id,sam_account_no,user_defined_1,user_defined_2,1099_type,fob,language,minimum_payment_type,'
                      || 'minimum_payment_percent,minimum_payment_dollar,maximum_invoice_amt_type,maximum_invoice_amt_dollar,'
                      || 'credit_limit_type,credit_limit_dollar,write_off_type,maximum_write_off_amount,revalue_vendor,'
                      || 'post_result_to,maintain_calendar_history,maintain_period_history,maintain_trx_history,maintain_gl_dist_history'
                      || ',Record_Number';--66
            utl_file.put_line(utlf, l_line);
            for i in 1..gp_vndr_acc.count loop
                if gp_vndr_acc(i).acnt_typ = 'HSA' then
                    if gp_vndr_acc(i).entrp_id is null then
                        l_line := gp_vndr_acc(i).cstvnd_id
                                  || ','
                                  || gp_vndr_acc(i).cstvnd_nm
                                  || ','
                                  || gp_vndr_acc(i).status
                                  || ','
                                  || get_class_id(gp_vndr_acc(i).acnt_typ,
                                                  'CLAIM')
                                  || ','
                                  || gp_vndr_acc(i).address_id
                                  || ',,,,,,,,'
                                  || gp_vndr_acc(i).cstvnd_id
                                  || rpad(',', 35, ',')
                                  || gp_vndr_acc(i).cstvnd_id
                                  || rpad(',', 20, ',')
                                  || ','
                                  || gp_vndr_acc(i).acc_id;

                        utl_file.put_line(utlf, l_line);
                    else
                        l_line := gp_vndr_acc(i).cstvnd_id
                                  || ','
                                  || gp_vndr_acc(i).cstvnd_nm
                                  || ','
                                  || gp_vndr_acc(i).status
                                  || ','
                                  || get_class_id(gp_vndr_acc(i).acnt_typ
                                                  || 'ER',
                                                  'CLAIM')
                                  || ','
                                  || gp_vndr_acc(i).address_id
                                  || ',,,,,,,,'
                                  || gp_vndr_acc(i).cstvnd_id
                                  || rpad(',', 35, ',')
                                  || gp_vndr_acc(i).cstvnd_id
                                  || rpad(',', 20, ',')
                                  || ','
                                  || gp_vndr_acc(i).acc_id;

                        utl_file.put_line(utlf, l_line);
               /*l_line := gp_vndr_acc(i).cstvnd_id||','||gp_vndr_acc(i).cstvnd_nm||','
                        ||gp_vndr_acc(i).status||','
                        ||get_class_id(gp_vndr_acc(i).acnt_typ||'ER','REFUND')||','
                        ||gp_vndr_acc(i).address_id||',,,,,,,,'
                        ||gp_vndr_acc(i).cstvnd_id||rpad(',',35,',')||gp_vndr_acc(i).cstvnd_id||rpad(',',20,',')
                        ||','||gp_vndr_acc(i).acc_id;
                utl_file.put_line(utlf,l_line);*/
                    end if;
                end if;

                if gp_vndr_acc(i).acnt_typ in ( 'HRA', 'FSA' ) then
                    if gp_vndr_acc(i).stckd = 'Y' then
                        for c in (
                            select
                                vendor_class_code class_id
                            from
                                vendor_class_gp
                            where
                                    account_type = gp_vndr_acc(i).acnt_typ--prod_type in('HRA','FSA')
                                and reason_type = 'CLAIM'
                        )--copied from customer account procedure above but needs confirmation from vanitha
                         loop
                            l_line := gp_vndr_acc(i).cstvnd_id
                                      || ','
                                      || gp_vndr_acc(i).cstvnd_nm
                                      || ','
                                      || gp_vndr_acc(i).status
                                      || ','
                                      || c.class_id
                                      || ','
                                      || gp_vndr_acc(i).address_id
                                      || ',,,,,,,,'
                                      || gp_vndr_acc(i).cstvnd_id
                                      || rpad(',', 35, ',')
                                      || regexp_replace(gp_vndr_acc(i).cstvnd_id,
                                                        '-.+')
                                      || rpad(',', 20, ',')
                                      || ','
                                      || gp_vndr_acc(i).acc_id;

                            utl_file.put_line(utlf, l_line);
                        end loop;
                   /*
                   FOR c IN(SELECT VENDOR_CLASS_CODE  class_id from vendor_class_gp
                            WHERE account_type=gp_vndr_acc(i).acnt_typ--prod_type in('HRA','FSA')
                            AND reason_type='REFUND')--copied from customer account procedure above but needs confirmation from vanitha
                   LOOP
                     l_line := gp_vndr_acc(i).cstvnd_id||','||gp_vndr_acc(i).cstvnd_nm
                                ||',' ||gp_vndr_acc(i).status||','||c.class_id||','||gp_vndr_acc(i).address_id||',,,,,,,,'
                                ||gp_vndr_acc(i).cstvnd_id||rpad(',',35,',')||regexp_replace(gp_vndr_acc(i).cstvnd_id,'-.+')
                                ||rpad(',',20,',')||','||gp_vndr_acc(i).acc_id;
                       utl_file.put_line(utlf,l_line);
                   END LOOP;
                   */
                    else
                        l_line := gp_vndr_acc(i).cstvnd_id
                                  || ','
                                  || gp_vndr_acc(i).cstvnd_nm
                                  || ','
                                  || gp_vndr_acc(i).status
                                  || ','
                                  || get_class_id(gp_vndr_acc(i).acnt_typ,
                                                  'CLAIM')
                                  || ','
                                  || gp_vndr_acc(i).address_id
                                  || ',,,,,,,,'
                                  || gp_vndr_acc(i).cstvnd_id
                                  || rpad(',', 35, ',')
                                  || gp_vndr_acc(i).cstvnd_id
                                  || rpad(',', 20, ',')
                                  || ','
                                  || gp_vndr_acc(i).acc_id;

                        utl_file.put_line(utlf, l_line);
                  /*l_line := gp_vndr_acc(i).cstvnd_id||','||gp_vndr_acc(i).cstvnd_nm||','||gp_vndr_acc(i).status||','
                           ||get_class_id(gp_vndr_acc(i).acnt_typ,'REFUND')||','||gp_vndr_acc(i).address_id
                           ||',,,,,,,,'||gp_vndr_acc(i).cstvnd_id||rpad(',',35,',')||gp_vndr_acc(i).cstvnd_id||rpad(',',20,',')
                           ||','||gp_vndr_acc(i).acc_id;
                   utl_file.put_line(utlf,l_line);*/
                    end if;

                end if;

                if gp_vndr_acc(i).acnt_typ not in ( 'HSA', 'HRA', 'FSA' ) then
                    l_line := gp_vndr_acc(i).cstvnd_id
                              || ','
                              || gp_vndr_acc(i).cstvnd_nm
                              || ','
                              || gp_vndr_acc(i).status
                              || ','
                              || get_class_id(gp_vndr_acc(i).acnt_typ,
                                              'REFUND')
                              || ','
                              || gp_vndr_acc(i).address_id
                              || ',,,,,,,,'
                              || gp_vndr_acc(i).cstvnd_id
                              || rpad(',', 35, ',')
                              || gp_vndr_acc(i).cstvnd_id
                              || rpad(',', 20, ',')
                              || ','
                              || gp_vndr_acc(i).acc_id;

                    utl_file.put_line(utlf, l_line);
                end if;

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'Vendors');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_vendor_account;

--26/18 vn ad
    procedure gp_vndr_adrs (
        x_file_name out varchar2
    ) is
    begin
        select
            customer_id
            || decode(account_type,
                      'HSA',
                      decode(
                               pc_account.have_outside_investment(acc_id),
                               'Y',
                               '-OI'
                           ))
        bulk collect
        into cstmr_id_tbl
        from
            gp_customer_account_gt
        where
            customer_type = 'CONTRIBUTION'
        order by
            1;

        if cstmr_id_tbl.count > 0 then
            l_file_id := insert_file_seq('GP_VNDR_ADR');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_vndr_adr.csv';
            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'vendor_id,address_id,contact,address1,address2,address3,city,state,zip,'
                      || 'country_code,country,phone1,phone2,phone3,fax,tax_schedule,shipping_method,'
                      || 'ups_zone,email,home_page,ftp_site,login,password,user_defined1,user_defined2,additional_information';--26

            utl_file.put_line(utlf, l_line);
            for i in 1..cstmr_id_tbl.last loop
                l_line := cstmr_id_tbl(i)
                          || ',PRIMARY'
                          || rpad(',', 24, ',');--26

                utl_file.put_line(utlf, l_line);
            end loop;

            utl_file.fclose(utlf);
        end if;

    exception
        when others then
            utl_file.fclose_all;
    end gp_vndr_adrs;

    procedure gp_check_payment (
        x_file_name out varchar2
    ) is
        ap_trnx ty_tb_payment;
    begin
        select
            *
        bulk collect
        into ap_trnx
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKPAY',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(check_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    0,                                        -- PAYMENT_METHOD
                    check_amount,                              -- AMOUNT
                    get_checkbook_id(account_type, 'CLAIM'),    -- CHECKBOOK_ID
                    check_number,                              -- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    checks     d,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and b.claim_id = d.entity_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and d.status = 'MAILED'
                    and d.check_amount = c.amount
                    and d.check_amount > 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = g_date
                    and c.reason_code not in ( 13, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKPAY',                                   -- BATCH ID
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(d.check_date, 'mm/dd/rrrr'),                                 -- DOCUMENT DATE
                    0,                                                                     -- PAYMENT_METHOD
                    check_amount,                                                           -- AMOUNT
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            pc_sam_gp_intgrtn.get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            pc_sam_gp_intgrtn.get_checkbook_id(a.account_type, 'CLAIM')
                    end,                    -- CHECKBOOK_ID
                    d.check_number,                                                         -- DOCUMENT NO
                    'N',                                                                    -- UNAPPLIED
                    'N',                                                                    -- REFUND
                    'PAYMENT',                                                    -- ENTITY TYPE
                    c.change_num                                                   -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    checks     d,
                    pay_reason f,
                    person     e
                where
                        a.entrp_id = e.entrp_id
                    and b.pers_id = e.pers_id
                    and b.claim_id = c.claimn_id
                    and b.claim_id = d.entity_id
                    and a.account_type in ( 'HRA', 'FSA' )
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and d.status = 'MAILED'
                    and d.check_amount = c.amount
                    and d.check_amount > 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = trunc(d.check_date)
                    and trunc(c.paid_date) = g_date
                    and c.reason_code not in ( 13, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
         /*  SELECT
                to_char(g_date,'mmddrr')||'-CHKPAY',                                   -- BATCH ID
                case when is_stacked_account(a.entrp_id) = 'Y' THEN
                     regexp_replace(a.acc_num,'[[:cntrl:]]')
                   ||'-'||PC_LOOKUPS.GET_meaning(b.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                ELSE  regexp_replace(a.acc_num,'[[:cntrl:]]') END,                      -- VENDOR ID
                to_char(transaction_date,'mm/dd/rrrr'),                                 -- DOCUMENT DATE
                0 ,                                                                     -- PAYMENT_METHOD
                check_amount,                                                           -- AMOUNT
                case when is_stacked_account(a.entrp_id) = 'Y' THEN
                     get_checkbook_id(PC_LOOKUPS.GET_meaning(b.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                     ,'CLAIM')
                ELSE  get_checkbook_id(A.ACCOUNT_TYPE ,'CLAIM') END,                    -- CHECKBOOK_ID
                to_char(b.employer_payment_id),                                         -- DOCUMENT NO
                'N',                                                                    -- UNAPPLIED
                'N',                                                                    -- REFUND
                'EMPLOYER_PAYMENTS',                                                    -- ENTITY TYPE
                b.employer_payment_id                                                   -- ENTITY ID
            FROM   account a,employer_payments c, pay_reason f
            WHERE   a.entrp_id      =c.entrp_id
              AND   account_type    !='HSA'
              AND   transaction_source='CLAIM_PAYMENT'
              AND   b.check_amount > 0
              AND   b.reason_code   = f.reason_code
              AND   f.reason_type   = 'DISBURSEMENT'
              AND   trunc(b.CHECK_DATE) =g_date
              AND   b.reason_code  NOT IN (13,19) -- exclude epayment , debit card
              AND   NOT EXISTS ( SELECT * FROM GP_AP_AR_TXN_OUTBND e
                                 WHERE e.ENTITY_ID = b.employer_payment_id
                                  AND  e.ENTITY_TYPE = 'EMPLOYER_PAYMENTS')*/
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKPAY',                                    -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(transaction_date, 'mm/dd/rrrr'),                                -- DOCUMENT DATE
                    0,                                                                     -- PAYMENT_METHOD
                    check_amount,                                                           -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'REFUND'
                            )
                        else
                            get_checkbook_id(a.account_type, 'REFUND')
                    end,                    -- CHECKBOOK_ID
                    nvl(b.check_number,
                        to_char(b.employer_payment_id)),                      -- DOCUMENT NO
                    'N',                                                                    -- UNAPPLIED
                    'Y',                                                                    -- REFUND
                    'EMPLOYER_PAYMENTS',                                                   -- ENTITY TYPE
                    b.employer_payment_id                                                   -- ENTITY ID
                from
                    account           a,
                    employer_payments b
                where
                        a.entrp_id = b.entrp_id
                    and account_type != 'HSA'
                    and b.check_amount > 0
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and trunc(b.check_date) = g_date
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )
                    and reason_code in ( 23, 25 ) -- Refund reason code
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKPAY',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    0,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),              -- check number
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and trunc(b.creation_date) = g_date
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code not in ( 8, 11, 12, 18, 17 )  -- Exclude Interest, Payroll Contribution
                                               --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKPAY',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    0,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code = 18
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and trunc(b.creation_date) = g_date
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKPAY',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    0,                                        -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CLAIM')
                    end,  -- CHECKBOOK_ID
                    substr(
                        replace(b.check_number, ','),
                        1,
                        20
                    ),           -- check number
                    null,                                        -- comments
                    to_char(b.invoice_id),                        -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    employer_deposit_id                          -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) < 0
                    and trunc(b.creation_date) = g_date
                    and b.reason_code not in ( 8, 11, 12, 40, 18,
                                               120, 17 )      --q
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
            )
        order by
            1;

        if ap_trnx.count > 0 then
            l_file_id := insert_file_seq('GP_AP_TRNSCTN');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_check_payment'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'Batch ID,Vendor ID,Document Date,Payment Method,Amount,Checkbook ID,Document No.,Comment,Record_Number';--||',Is this from Unapplied Cash?,Is this a Refund?';
            utl_file.put_line(utlf, l_line);
            for i in 1..ap_trnx.last loop
                l_line := ap_trnx(i).batch_id
                          || ','
                          || ap_trnx(i).cstvnd_id
                          || ','
                          || ap_trnx(i).docmnt_dt
                          || ','
                          || ap_trnx(i).pay_method
                          || ','
                          || ap_trnx(i).amnt
                          || ','
                          || ap_trnx(i).chkbk_id
                          || ','
                          || ap_trnx(i).invdoc_no
                          || ','
                          ||
                    case
                        when ap_trnx(i).entity_type = 'INCOME' then
                            'Individual Receipt Adjustment'
                        when ap_trnx(i).entity_type = 'EMPLOYER_DEPOSITS' then
                            'Employer Receipt Adjustment'
                    end
                          || ','
                          || ap_trnx(i).entity_type
                          || ':'
                          || ap_trnx(i).entity_id;--||','||ap_trnx(i).unapplied||','||ap_trnx(i).refund;
                utl_file.put_line(utlf, l_line);

                -- Capture in history table
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => ap_trnx(i).batch_id,
                    p_entity_id   => ap_trnx(i).entity_id,
                    p_entity_type => ap_trnx(i).entity_type,
                    p_doc_date    => ap_trnx(i).docmnt_dt,
                    p_amount      => ap_trnx(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'AP Manual Payments');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_check_payment;
 --14 pybl tnx
    procedure gp_ach_payment (
        x_file_name out varchar2
    ) is
        ap_trnx ty_tb_payment;
    begin
        select
            *
        bulk collect
        into ap_trnx
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    3,                                        -- PAYMENT_METHOD
                    c.amount,                                   -- AMOUNT
                    get_checkbook_id(account_type, 'CLAIM'),    -- CHECKBOOK_ID
                    to_char(d.transaction_id),                 -- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                  -- ENTITY TYPE
                    c.change_num                              -- ENTITY_ID
                from
                    account      a,
                    claimn       b,
                    payment      c,
                    ach_transfer d,
                    pay_reason   f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = c.claimn_id
                    and b.claim_id = d.claim_id
                    and account_type = 'HSA'
                    and d.transaction_type = 'D'
                    and d.status = 3
                    and c.amount > 0
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.reason_code = 19 --  epayment only
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = g_date
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',                                   -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                     -- VENDOR ID
                    to_char(d.transaction_date, 'mm/dd/rrrr'),                               -- DOCUMENT DATE
                    3,                                                                    -- PAYMENT_METHOD
                    c.amount,                                                          -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CLAIM')
                    end,                  -- CHECKBOOK_ID
                    to_char(d.transaction_id),                                       -- DOCUMENT NO
                    'N',                                                                  -- UNAPPLIED
                    'N',                                                                  -- REFUND
                    'PAYMENT',                                                  -- ENTITY TYPE
                    c.change_num                                                 -- ENTITY ID
                from
                    account      a,
                    person       e,
                    claimn       b,
                    payment      c,
                    ach_transfer d,
                    pay_reason   f
                where
                        a.entrp_id = e.entrp_id
                    and e.pers_id = b.pers_id
                    and b.claim_id = c.claimn_id
                    and b.claim_id = d.claim_id
                    and account_type in ( 'HRA', 'FSA' )
                    and d.transaction_type = 'D'
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and d.status = 3
                    and c.amount > 0
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.reason_code = 19 --  epayment only
                    and trunc(d.transaction_date) = g_date
                    and trunc(c.paid_date) = g_date
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
        /*    SELECT
                to_char(g_date,'mmddrr')||'-ACHPAY',                                   -- BATCH ID
                case when is_stacked_account(a.entrp_id) = 'Y' THEN
                     regexp_replace(a.acc_num,'[[:cntrl:]]')
                   ||'-'||PC_LOOKUPS.GET_meaning(b.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                ELSE  regexp_replace(a.acc_num,'[[:cntrl:]]') END,                     -- VENDOR ID
                to_char(transaction_date,'mm/dd/rrrr'),                               -- DOCUMENT DATE
                3 ,                                                                    -- PAYMENT_METHOD
                check_amount,                                                          -- AMOUNT
                case when is_stacked_account(a.entrp_id) = 'Y' THEN
                     get_checkbook_id(PC_LOOKUPS.GET_meaning(b.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                     ,'CLAIM')
                ELSE  get_checkbook_id(A.ACCOUNT_TYPE ,'CLAIM') END,                  -- CHECKBOOK_ID
                to_char(b.employer_payment_id),                                       -- DOCUMENT NO
                'N',                                                                  -- UNAPPLIED
                'N',                                                                  -- REFUND
                'EMPLOYER_PAYMENTS',                                                  -- ENTITY TYPE
                b.employer_payment_id                                                 -- ENTITY ID
            FROM   account a,employer_payments b,pay_reason f
            WHERE   a.entrp_id      =b.entrp_id
              AND   account_type    !='HSA'
              AND   transaction_source='CLAIM_PAYMENT'
              AND   check_amount > 0
              AND   b.reason_code   = f.reason_code
              AND   f.reason_type   = 'DISBURSEMENT'
              AND   b.reason_code  = 19 -- epayment only
              AND   TRUNC(b.CHECK_DATE) =g_date
              AND   NOT EXISTS ( SELECT * FROM GP_AP_AR_TXN_OUTBND e
                                 WHERE e.ENTITY_ID = b.employer_payment_id
                                  AND  e.ENTITY_TYPE = 'EMPLOYER_PAYMENTS')*/
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',                                   -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(transaction_date, 'mm/dd/rrrr'),                                -- DOCUMENT DATE
                    3,                                                                     -- PAYMENT_METHOD
                    check_amount,                                                           -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'REFUND'
                            )
                        else
                            get_checkbook_id(a.account_type, 'REFUND')
                    end,                   -- CHECKBOOK_ID
                    nvl(b.check_number,
                        to_char(b.employer_payment_id)),                    -- DOCUMENT NO
                    'N',                                                                   -- UNAPPLIED
                    'Y',                                                                   -- REFUND
                    'EMPLOYER_PAYMENTS',                                                   -- ENTITY TYPE
                    b.employer_payment_id                                                  -- ENTITY ID
                from
                    account           a,
                    employer_payments b
                where
                        a.entrp_id = b.entrp_id
                    and account_type != 'HSA'
                    and check_amount > 0
                    and trunc(b.check_date) = g_date
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )
                    and reason_code in ( 23, 25 ) -- Refund reason code
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and trunc(b.creation_date) = g_date
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code not in ( 8, 11, 12, 18, 17 )  -- Exclude Interest, Payroll Contribution
                                               --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code = 18
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and trunc(b.creation_date) = g_date
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                        -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CLAIM')
                    end,  -- CHECKBOOK_ID
                    substr(
                        nvl(
                            replace(b.check_number, ','),
                            employer_deposit_id
                        ),
                        1,
                        20
                    ),           -- check number
                    null,                                        -- comments
                    to_char(b.invoice_id),                        -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    employer_deposit_id                          -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) < 0
                    and trunc(b.creation_date) = g_date
                    and b.reason_code not in ( 8, 11, 12, 40, 17,
                                               18, 120 )      --q
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
            )
        order by
            1;

        if ap_trnx.count > 0 then
            l_file_id := insert_file_seq('GP_AP_TRNSCTN');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_ach_payment'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'Batch ID,Vendor ID,Document Date,Payment Method,Amount,Checkbook ID,Document No.,Comment,Record_Number';--||',Is this from Unapplied Cash?,Is this a Refund?';
            utl_file.put_line(utlf, l_line);
            for i in 1..ap_trnx.last loop
                l_line := ap_trnx(i).batch_id
                          || ','
                          || ap_trnx(i).cstvnd_id
                          || ','
                          || ap_trnx(i).docmnt_dt
                          || ','
                          || ap_trnx(i).pay_method
                          || ','
                          || ap_trnx(i).amnt
                          || ','
                          || ap_trnx(i).chkbk_id
                          || ','
                          || ap_trnx(i).invdoc_no
                          || ','
                          ||
                    case
                        when ap_trnx(i).entity_type = 'INCOME' then
                            'Individual Receipt Adjustment'
                        when ap_trnx(i).entity_type = 'EMPLOYER_DEPOSITS' then
                            'Employer Receipt Adjustment'
                    end
                          || ','
                          || ap_trnx(i).entity_type
                          || ':'
                          || ap_trnx(i).entity_id;--||','||ap_trnx(i).unapplied||','||ap_trnx(i).refund;
                utl_file.put_line(utlf, l_line);

                -- Capture in history table
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => ap_trnx(i).batch_id,
                    p_entity_id   => ap_trnx(i).entity_id,
                    p_entity_type => 'PAYMENT',
                    p_doc_date    => ap_trnx(i).docmnt_dt,
                    p_amount      => ap_trnx(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'AP Manual Payments');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_ach_payment;

    procedure gp_debit_card_payment (
        x_file_name out varchar2
    ) is
        ap_trnx ty_tb_payment;
    begin
        select
            *
        bulk collect
        into ap_trnx
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-DCPAY',       -- debit card payment BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    1,                                         -- dr card PAYMENT_METHOD
                    c.amount,                              -- AMOUNT
                    get_checkbook_id(account_type, 'CLAIM'),    -- CHECKBOOK_ID
                    substr(
                        nvl(
                            regexp_replace(
                                regexp_replace(c.pay_num, '[[:punct:]]', '|'),
                                '[[:cntrl:]]'
                            ),
                            c.change_num
                        ),
                        1,
                        20
                    ),-- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount > 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = trunc(g_date)
                    and c.reason_code = 13                                     -- debit card payment reason
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-DCPAY',       -- debit card payment BATCH ID
                    case
                        when is_stacked_account(acc.entrp_id) = 'Y' then
                            regexp_replace(acc.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(acc.acc_num, '[[:cntrl:]]')
                    end,                     -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    1,                                         -- dr card PAYMENT_METHOD
                    c.amount,                              -- AMOUNT
                    case
                        when is_stacked_account(acc.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(acc.account_type, 'CLAIM')
                    end,    -- CHECKBOOK_ID
                    substr(
                        nvl(
                            regexp_replace(
                                regexp_replace(c.pay_num, '[[:punct:]]', '|'),
                                '[[:cntrl:]]'
                            ),
                            c.change_num
                        ),
                        1,
                        20
                    ),-- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    ben_plan_enrollment_setup bp,
                    account                   acc,
                    claimn                    b,
                    payment                   c,
                    pay_reason                f,
                    person                    d
                where
                    acc.entrp_id is not null
                    and acc.entrp_id = d.entrp_id
                    and bp.acc_id = acc.acc_id
                    and b.pers_id = d.pers_id
                    and acc.account_type in ( 'HRA', 'FSA' )
                    and c.plan_type = bp.plan_type
                    and c.reason_code = 13
                    and bp.status in ( 'A', 'I' )
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and b.plan_start_date = bp.plan_start_date
                    and b.plan_end_date = bp.plan_end_date
                    and bp.claim_reimbursed_by = 'STERLING'
                    and b.claim_id = c.claimn_id
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.pay_date) = trunc(g_date)
                    and c.paid_date >= trunc(nvl(bp.reimburse_start_date, bp.plan_start_date))
                    and c.paid_date <= trunc(nvl(bp.reimburse_end_date, sysdate))
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )

        /*    SELECT
                to_char(g_date,'mmddrr')||'-DCPAY',                         -- debit card payment BATCH ID
                regexp_replace(a.acc_num,'[[:cntrl:]]')
                ||case when is_stacked_account(a.entrp_id)='Y'THEN
                '-'||PC_LOOKUPS.GET_meaning(C.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                ELSE''END,                                                   -- VENDOR ID
                to_char(transaction_date,'mm/dd/rrrr'),                      -- DOCUMENT DATE
                1,                                                           -- dr card PAYMENT_METHOD
                ABS(AMOUNT)   ,                                               -- AMOUNT
                case when is_stacked_account(a.entrp_id)='Y'THEN
                     get_checkbook_id(PC_LOOKUPS.GET_meaning(C.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                     ,'CLAIM')
                ELSE get_checkbook_id(A.ACCOUNT_TYPE,'CLAIM')END,            -- CHECKBOOK_ID
                to_char(C.employer_payment_id),                              -- DOCUMENT NO
                'N',                                                         -- UNAPPLIED
                'N',                                                         -- REFUND
                'EMPLOYER_PAYMENTS',                                         -- ENTITY TYPE
                C.employer_payment_id                                        -- ENTITY ID
            FROM   account a,HRAFSA_EMPLOYEE_PAYMENTS_V c
            WHERE   a.entrp_id     = C.entrp_id
            AND     AMOUNT < 0
            AND     TRUNC(C.TRANSACTION_DATE) =g_date
            AND   NOT EXISTS(SELECT * FROM GP_AP_AR_TXN_OUTBND e
                                 WHERE e.ENTITY_ID = C.employer_payment_id
                                  AND  e.ENTITY_TYPE = 'EMPLOYER_PAYMENTS')*/
            )
        order by
            1;

        if ap_trnx.count > 0 then
            l_file_id := insert_file_seq('GP_AP_TRNSCTN');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_dr_card_payment'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'Batch ID,Vendor ID,Document Date,Payment Method,Amount,Checkbook ID,Document No.,Comment,Record_Number';--'Comment,Is this from Unapplied Cash?,Is this a Refund?';
            utl_file.put_line(utlf, l_line);
            for i in 1..ap_trnx.last loop
                l_line := ap_trnx(i).batch_id
                          || ','
                          || ap_trnx(i).cstvnd_id
                          || ','
                          || ap_trnx(i).docmnt_dt
                          || ','
                          || ap_trnx(i).pay_method
                          || ','
                          || ap_trnx(i).amnt
                          || ','
                          || ap_trnx(i).chkbk_id
                          || ','
                          || ap_trnx(i).invdoc_no
                          || ','
                          ||
                    case
                        when ap_trnx(i).entity_type = 'INCOME' then
                            'Individual Receipt Adjustment'
                        when ap_trnx(i).entity_type = 'EMPLOYER_DEPOSITS' then
                            'Employer Receipt Adjustment'
                    end
                          || ','
                          || ap_trnx(i).entity_type
                          || ':'
                          || ap_trnx(i).entity_id;--||','||ap_trnx(i).unapplied||','||ap_trnx(i).refund;
                utl_file.put_line(utlf, l_line);

                -- Capture in history table
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => ap_trnx(i).batch_id,
                    p_entity_id   => ap_trnx(i).entity_id,
                    p_entity_type => ap_trnx(i).entity_type,
                    p_doc_date    => ap_trnx(i).docmnt_dt,
                    p_amount      => ap_trnx(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'AP Manual Payments');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end;

    procedure gp_check_receipt (
        x_file_name out varchar2
    ) is
        gp_cstmr_acn     ty_tb_gp_cstmr;
        gp_inv_acn       ty_tb_gp_cstmr;
        l_invoice_id     number;
        l_invoice_amount number := 0;
    begin
        select
            *
        bulk collect
        into gp_cstmr_acn
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),              -- check number
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and trunc(b.creation_date) = g_date
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) > 0
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code not in ( 8, 11, 12, 18 )  -- Exclude Interest, Payroll Contribution
                                               --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Outside Investment Transfer
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code = 18
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) > 0
                    and trunc(b.creation_date) = g_date
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(b.check_amount, 0),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,  -- CHECKBOOK_ID
                    substr(
                        nvl(
                            replace(b.check_number, ','),
                            employer_deposit_id
                        ),
                        1,
                        20
                    ),           -- check number
                    null,                                        -- comments
                    to_char(b.invoice_id),                        -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    employer_deposit_id                          -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) > 0
                    and trunc(b.creation_date) = g_date
                    and b.reason_code not in ( 8, 11, 12, 40, 18,
                                               17, 120 )      --q
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    '0',                                        -- PAYMENT_METHOD
                    abs(c.amount),                              -- AMOUNT
                    get_checkbook_id(account_type, 'CONT'),    -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),              -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = g_date
                    and c.reason_code <> 19 -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',                                   -- BATCH ID
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),                                 -- DOCUMENT DATE
                    '0',                                                                     -- PAYMENT_METHOD
                    abs(c.amount),                                                           -- AMOUNT
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            pc_sam_gp_intgrtn.get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            pc_sam_gp_intgrtn.get_checkbook_id(a.account_type, 'CONT')
                    end,                    -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),                                           -- DOCUMENT NO
                    'N',                                                                    -- UNAPPLIED
                    'N',                                                                    -- REFUND
                    'PAYMENT',                                                    -- ENTITY TYPE
                    c.change_num                                                   -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f,
                    person     e
                where
                        a.entrp_id = e.entrp_id
                    and b.pers_id = e.pers_id
                    and b.claim_id = c.claimn_id
                    and a.account_type in ( 'HRA', 'FSA' )
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = g_date
                    and c.reason_code not in ( 13, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
         /*   SELECT
                to_char(g_date,'mmddrr')||'-CHKREC',                                   -- BATCH ID
                case when is_stacked_account(a.entrp_id) = 'Y' THEN
                     regexp_replace(a.acc_num,'[[:cntrl:]]')
                   ||'-'||PC_LOOKUPS.GET_meaning(b.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                ELSE  regexp_replace(a.acc_num,'[[:cntrl:]]') END,                      -- VENDOR ID
                to_char(transaction_date,'mm/dd/rrrr'),                                 -- DOCUMENT DATE
                '0' ,                                        -- PAYMENT_METHOD
                ABS(check_amount),                                                           -- AMOUNT
                case when is_stacked_account(a.entrp_id) = 'Y' THEN
                     get_checkbook_id(PC_LOOKUPS.GET_meaning(b.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')
                     ,'CONT')
                ELSE  get_checkbook_id(A.ACCOUNT_TYPE ,'CONT') END,                    -- CHECKBOOK_ID
                to_char(b.employer_payment_id),                                         -- DOCUMENT NO
                null  comments,                              -- comments
                null  invoice_id ,                           -- invoice_id
                'EMPLOYER_PAYMENTS',                                                    -- ENTITY TYPE
                b.employer_payment_id                                                   -- ENTITY ID
            FROM   account a,employer_payments b,pay_reason f
            WHERE   a.entrp_id      =b.entrp_id
              AND   account_type    !='HSA'
              AND   transaction_source='CLAIM_PAYMENT'
              AND   b.check_amount < 0
              AND   b.reason_code   = f.reason_code
              AND   f.reason_type   = 'DISBURSEMENT'
              AND   trunc(b.CHECK_DATE) =g_date
              AND   b.reason_code  <> 19 -- exclude epayment , debit card
              AND   NOT EXISTS ( SELECT * FROM GP_AP_AR_TXN_OUTBND e
                                 WHERE e.ENTITY_ID = b.employer_payment_id
                                  AND  e.ENTITY_TYPE = 'EMPLOYER_PAYMENTS')*/
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',                                    -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(transaction_date, 'mm/dd/rrrr'),                                -- DOCUMENT DATE
                    '0',                                        -- PAYMENT_METHOD
                    abs(check_amount),                                                           -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,                    -- CHECKBOOK_ID
                    to_char(b.employer_payment_id),                                         -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'EMPLOYER_PAYMENTS',                                                   -- ENTITY TYPE
                    b.employer_payment_id                                                   -- ENTITY ID
                from
                    account           a,
                    employer_payments b
                where
                        a.entrp_id = b.entrp_id
                    and account_type != 'HSA'
                    and b.check_amount < 0
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and trunc(b.check_date) = g_date
                    and reason_code in ( 23, 25 ) -- Refund reason code
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
            )
        order by
            1;

        dbms_output.put_line('gp_cstmr_acn.count' || gp_cstmr_acn.count);
        if gp_cstmr_acn.count > 0 then
            l_file_id := insert_file_seq('GP_AR_TRNSCTN');
            dbms_output.put_line('l_file_id' || l_file_id);
            x_file_name := 'GP_'
                           || l_file_id
                           || '_check_receipt'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            dbms_output.put_line('x_file_name' || x_file_name);
            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'batch_id,customer_id,document_date,receipt_type,amount,checkbook_id,check_card_no,comments,invoice_id,Record_Number'
            ;
            utl_file.put_line(utlf, l_line);
            for i in 1..gp_cstmr_acn.last loop
                l_line := gp_cstmr_acn(i).batch_id
                          || ','
                          || gp_cstmr_acn(i).cstvnd_id
                          || ','
                          || gp_cstmr_acn(i).docmnt_dt
                          || ','
                          || gp_cstmr_acn(i).rcvpmt_typ
                          || ','
                          || gp_cstmr_acn(i).amnt
                          || ','
                          || gp_cstmr_acn(i).chckbk_id
                          || ','
                          || gp_cstmr_acn(i).docmnt_no
                          || ','
                          ||
                    case
                        when gp_cstmr_acn(i).entity_type = 'PAYMENT' then
                            'Individual Payment Adjustment'
                        when gp_cstmr_acn(i).entity_type = 'EMPLOYER_PAYMENTS' then
                            'Employer Payment Adjustment'
                    end
                          || ','
                          || gp_cstmr_acn(i).invoice_id
                          || ','
                          || gp_cstmr_acn(i).entity_type
                          || ':'
                          || gp_cstmr_acn(i).entity_id;

                utl_file.put_line(utlf, l_line);

                -- Capture in history table
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => gp_cstmr_acn(i).batch_id,
                    p_entity_id   => gp_cstmr_acn(i).entity_id,
                    p_entity_type => gp_cstmr_acn(i).entity_type,
                    p_doc_date    => gp_cstmr_acn(i).docmnt_dt,
                    p_amount      => gp_cstmr_acn(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        dbms_output.put_line('fee invoices collection ' || gp_cstmr_acn.count);

         -- Fees from invoices
        select
            *
        bulk collect
        into gp_inv_acn
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]')
                    ||
                    case
                        when a.account_type in ( 'HRA', 'FSA' ) then
                                '-FEE'
                        else
                            ''
                    end,                                  -- Customer ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(b.check_amount, 0),                      --  Amount
                    get_checkbook_id(a.account_type, 'FEE'),      -- Checkbook ID
                    substr(
                        replace(b.check_number, ','),
                        1,
                        20
                    ),    -- check number
                    null,                                       -- comments
                    b.invoice_id,                      -- invoice_id
                    'EMPLOYER_PAYMENTS',                        -- entity_type
                    b.employer_payment_id                        -- entity id
                from
                    account           a,
                    employer_payments b,
                    pay_reason        c
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and b.reason_code = c.reason_code
                    and b.reason_code != '120'
                    and c.reason_type = 'FEE'
                    and b.invoice_id is not null
                    and trunc(b.check_date) = g_date
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
            )
        order by
            invoice_id;

        if gp_inv_acn.count > 0 then
            if gp_cstmr_acn.count = 0 then
                l_file_id := insert_file_seq('GP_AR_TRNSCTN');
                x_file_name := 'GP_'
                               || l_file_id
                               || '_check_receipt'
                               || to_char(g_date, 'mmddrr')
                               || '.csv';

            end if;

            utlf := utl_file.fopen(dir, x_file_name, 'a');
            if gp_cstmr_acn.count = 0 then
                l_line := 'batch_id,customer_id,document_date,receipt_type,amount,checkbook_id,check_card_no,comments,invoice_id,Record_Number'
                ;
                utl_file.put_line(utlf, l_line);
            end if;

            for i in 1..gp_inv_acn.last loop
                if gp_inv_acn(i).invoice_id <> l_invoice_id then
                    l_line := gp_inv_acn(i).batch_id
                              || ','
                              || gp_inv_acn(i).cstvnd_id
                              || ','
                              || gp_inv_acn(i).docmnt_dt
                              || ','
                              || gp_inv_acn(i).rcvpmt_typ
                              || ','
                              || gp_inv_acn(i).amnt
                              || ','
                              || gp_inv_acn(i).chckbk_id
                              || ','
                              || gp_inv_acn(i).docmnt_no
                              || ','
                              ||
                        case
                            when gp_cstmr_acn(i).entity_type = 'PAYMENT' then
                                'Individual Payment Adjustment'
                            when gp_cstmr_acn(i).entity_type = 'EMPLOYER_PAYMENTS' then
                                'Employer Payment Adjustment'
                        end
                              || ','
                              || gp_inv_acn(i).invoice_id
                              || ','
                              || gp_cstmr_acn(i).entity_type
                              || ':'
                              || gp_cstmr_acn(i).entity_id;

                    utl_file.put_line(utlf, l_line);
                    l_invoice_amount := 0;
                end if;

                l_invoice_id := gp_inv_acn(i).invoice_id;
                l_invoice_amount := l_invoice_amount + gp_inv_acn(i).amnt;

                -- Capture in history table
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => gp_cstmr_acn(i).batch_id,
                    p_entity_id   => gp_cstmr_acn(i).entity_id,
                    p_entity_type => gp_cstmr_acn(i).entity_type,
                    p_doc_date    => gp_cstmr_acn(i).docmnt_dt,
                    p_amount      => gp_cstmr_acn(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'RM Cash Receipts');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_check_receipt;

    procedure gp_ach_receipt (
        x_file_name out varchar2
    ) is
        gp_cstmr_acn ty_tb_gp_cstmr;
    begin
        select
            *
        bulk collect
        into gp_cstmr_acn
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                          -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        replace(cc_number, ','),
                        1,
                        20
                    ),        -- check number
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and trunc(b.creation_date) = g_date
                    and nvl(amount, 0) + nvl(amount_add, 0) > 0
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code not in ( 8, 11, 12, 18, 17 )  -- Exclude Interest, Payroll Contribution
                                                   --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Outside Investment Transfer
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                          -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        replace(cc_number, ','),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and nvl(amount, 0) + nvl(amount_add, 0) > 0
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code = 18
                    and trunc(b.creation_date) = g_date
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                          -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,  -- CHECKBOOK_ID
                    substr(
                        replace(b.check_number, ','),
                        1,
                        20
                    ),         -- check number
                    null,                                        -- comments
                    b.invoice_id,                                -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    b.employer_deposit_id                        -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) > 0
                    and trunc(b.check_date) = g_date
                    and b.reason_code not in ( 8, 11, 12, 40, 18,
                                               17 )      --q
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
                union -- Fees from invoices
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]')
                    ||
                    case
                        when a.account_type in ( 'HRA', 'FSA' ) then
                                '-FEE'
                        else
                            ''
                    end,                                  -- Customer ID
                    to_char(b.check_date, 'mm/dd/rrrr'),           -- Document Date
                    3,                                           -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    get_checkbook_id(a.account_type, 'FEE'),      -- Checkbook ID
                    substr(
                        replace(b.employer_payment_id, ','),
                        1,
                        20
                    ),    -- check number
                    null,                                        -- comments
                    b.invoice_id,                                -- invoice_id
                    'EMPLOYER_PAYMENTS',                         -- entity_type
                    b.employer_payment_id                        -- entity id
                from
                    account           a,
                    employer_payments b,
                    pay_reason        c
                where
                        a.entrp_id = b.entrp_id
                    and trunc(b.check_date) = g_date
                    and nvl(b.check_amount, 0) > 0
                    and account_type <> 'HSA'
                    and b.reason_code = c.reason_code
                    and c.reason_type = 'FEE'
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    3,                                        -- PAYMENT_METHOD
                    abs(c.amount),                              -- AMOUNT
                    get_checkbook_id(account_type, 'CONT'),    -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),              -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = g_date
                    and c.reason_code in ( 29, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',                                   -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                     -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),                               -- DOCUMENT DATE
                    3,                                                                    -- PAYMENT_METHOD
                    abs(c.amount),                                                          -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,                  -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),                                       -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'PAYMENT',                                                  -- ENTITY TYPE
                    c.change_num                                                 -- ENTITY ID
                from
                    account    a,
                    person     e,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.entrp_id = e.entrp_id
                    and e.pers_id = b.pers_id
                    and b.claim_id = c.claimn_id
                    and account_type in ( 'HRA', 'FSA' )
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.reason_code in ( 29, 19 ) --  epayment only
                    and trunc(c.paid_date) = g_date
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
            )
        order by
            1;

        if gp_cstmr_acn.count > 0 then
            l_file_id := insert_file_seq('GP_AR_TRNSCTN');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_ach_receipt'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'batch_id,customer_id,document_date,receipt_type,amount,checkbook_id,check_card_no,comments,invoice_id,Record_Number'
            ;
            utl_file.put_line(utlf, l_line);
            for i in 1..gp_cstmr_acn.last loop
                l_line := gp_cstmr_acn(i).batch_id
                          || ','
                          || gp_cstmr_acn(i).cstvnd_id
                          || ','
                          || gp_cstmr_acn(i).docmnt_dt
                          || ','
                          || gp_cstmr_acn(i).rcvpmt_typ
                          || ','
                          || gp_cstmr_acn(i).amnt
                          || ','
                          || gp_cstmr_acn(i).chckbk_id
                          || ','
                          || gp_cstmr_acn(i).docmnt_no
                          || ','
                          ||
                    case
                        when gp_cstmr_acn(i).entity_type = 'PAYMENT' then
                            'Individual Payment Adjustment'
                        when gp_cstmr_acn(i).entity_type = 'EMPLOYER_PAYMENTS' then
                            'Employer Payment Adjustment'
                    end
                          || ','
                          || gp_cstmr_acn(i).invoice_id
                          || ','
                          || gp_cstmr_acn(i).entity_type
                          || ':'
                          || gp_cstmr_acn(i).entity_id;

                utl_file.put_line(utlf, l_line);

                -- Capture in history table
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => gp_cstmr_acn(i).batch_id,
                    p_entity_id   => gp_cstmr_acn(i).entity_id,
                    p_entity_type => gp_cstmr_acn(i).entity_type,
                    p_doc_date    => gp_cstmr_acn(i).docmnt_dt,
                    p_amount      => gp_cstmr_acn(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'RM Cash Receipts');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_ach_receipt;

    procedure gp_invoices (
        x_file_name out varchar2
    ) is
        l_invoice_tbl ty_tb_invoice;
    begin
        select
            *
        bulk collect
        into l_invoice_tbl
        from
            (
                select
                    a.invoice_id                                           -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY') invoice_date      -- invoice_date
                    ,
                    case
                        when b.account_type in ( 'HRA', 'FSA' ) then
                            b.acc_num || '-FEE'
                        else
                            b.acc_num
                    end                                 customer                           -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'   -- customer name
                    ,
                    nvl(c.gp_item_number,
                        decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                               b.account_type)
                        || '-'
                        || case
                        when instr(
                            substr(
                                replace(c.reason_name, b.account_type),
                                1,
                                1
                            ),
                            ' '
                        ) = 0 then
                            substr(
                                replace(c.reason_name, b.account_type),
                                1,
                                30
                            )
                        else substr(
                            replace(c.reason_name, b.account_type),
                            2,
                            30
                        )
                    end)-- item number
                    ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'FEE'
                    and trunc(a.approved_date) = trunc(g_date)
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num                                -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and is_stacked_account(b.entrp_id) = 'N'
                    and trunc(a.approved_date) = trunc(g_date)
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    case
                        when is_stacked_account(b.entrp_id) = 'N' then
                            b.acc_num
                        when is_stacked_account(b.entrp_id) = 'Y'
                             and c.reason_code in ( 180, 70 ) then
                            b.acc_num || '-FSA'
                        when is_stacked_account(b.entrp_id) = 'Y'
                             and c.reason_code in ( 49, 69 ) then
                            b.acc_num || '-HRA'
                        else
                            b.acc_num
                    end
                      -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    c.gp_item_number,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'FUNDING'
                    and trunc(a.approved_date) = trunc(g_date)
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num || '-FSA'                        -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount                     -- price
                    ,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and trunc(a.approved_date) = g_date
                    and is_stacked_account(b.entrp_id) = 'Y'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and trunc(a.approved_date) = trunc(g_date)
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and exists (
                        select
                            *
                        from
                            invoice_distribution_summary c
                        where
                                a.invoice_id = c.invoice_id
                            and c.account_type = 'FSA'
                    )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num || '-HRA'                        -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and trunc(a.approved_date) = g_date
                    and is_stacked_account(b.entrp_id) = 'Y'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and trunc(a.approved_date) = trunc(g_date)
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and exists (
                        select
                            *
                        from
                            invoice_distribution_summary c
                        where
                                a.invoice_id = c.invoice_id
                            and c.account_type = 'HRA'
                    )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
            );

        if l_invoice_tbl.count > 0 then
            l_file_id := insert_file_seq('GP_INV');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_inv'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'Type,Type ID,Doc Number,Date,Default Site,Batch ID,Cust ID,Cust Name,item_number,unit_of_measure'
                      || ',quantity,unit_price,item_description,marksdown_amount,extended_price,qty_to_invoice,qty_fulfilled'
                      || ',qty_cancelled,qty_to_back_order,qty_to_order,items_unit_cost,doc_number,Record_Number';
            utl_file.put_line(utlf, l_line);
            for i in 1..l_invoice_tbl.last loop
                l_line := '3'  -- Type
                          || ','
                          || 'STD'-- Type Id
                          || ','
                          || l_invoice_tbl(i).invoice_id
                          || ','
                          || l_invoice_tbl(i).invoice_date
                          || ','
                          || 'MAIN'
                          || ','
                          || to_char(sysdate, 'MMDDYY')
                          || '-INV'
                          || ','
                          || l_invoice_tbl(i).customer_id
                          || ','
                          || l_invoice_tbl(i).customer_name
                          || ','
                          ||
                    case
                        when l_invoice_tbl(i).item_number = 'HRA-FSA Setup Fee' then
                            'FSA-HRA Setup Fee'
                        when l_invoice_tbl(i).item_number = 'HRA-Set up fee' then
                            'HRA-Setup fee'
                        else l_invoice_tbl(i).item_number
                    end
                          || ',,1,'
                          || l_invoice_tbl(i).price
                          || rpad(',', 10, ',')
                          || l_invoice_tbl(i).invoice_id
                          || ','
                          || 'AR_INVOICE_LINES:'
                          || l_invoice_tbl(i).invoice_line_id;

                utl_file.put_line(utlf, l_line);
                dbms_output.put_line('line' || l_line);
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => to_char(sysdate, 'MMDDYY')
                                  || '-INV',
                    p_entity_id   => l_invoice_tbl(i).invoice_line_id,
                    p_entity_type => 'AR_INVOICE_LINES',
                    p_doc_date    => l_invoice_tbl(i).invoice_date,
                    p_amount      => l_invoice_tbl(i).price,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'SOP');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_invoices;

    procedure gp__manual_post_invoices is
        l_invoice_tbl ty_tb_invoice;
        x_file_name   varchar2(100);
    begin
        select
            *
        bulk collect
        into l_invoice_tbl
        from
            (
                select
                    a.invoice_id                                           -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY') invoice_date      -- invoice_date
                    ,
                    case
                        when b.account_type in ( 'HRA', 'FSA' ) then
                            b.acc_num || '-FEE'
                        else
                            b.acc_num
                    end                                 customer                           -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'   -- customer name
                    ,
                    nvl(c.gp_item_number,
                        decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                               b.account_type)
                        || '-'
                        || case
                        when instr(
                            substr(
                                replace(c.reason_name, b.account_type),
                                1,
                                1
                            ),
                            ' '
                        ) = 0 then
                            substr(
                                replace(c.reason_name, b.account_type),
                                1,
                                30
                            )
                        else substr(
                            replace(c.reason_name, b.account_type),
                            2,
                            30
                        )
                    end)-- item number
                    ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'FEE'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and a.invoice_date >= '01-JAN-2014'
                    and e.status <> 'VOID'
                    and a.invoice_id not in (
                        select
                            ar.invoice_id
                        from
                            ar_invoice         ar, ar_invoice_lines   arl, invoice_parameters a, pay_reason         pr
                        where
                                ar.invoice_id = arl.invoice_id
                            and a.entity_id = ar.entity_id
                            and a.invoice_type = ar.invoice_reason
                            and arl.rate_code = to_char(pr.reason_code)
                            and ar.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                            and ar.invoice_reason = a.invoice_type
                            and arl.status <> 'VOID'
                            and pr.reason_mapping in ( 67, 68, 2 )
                            and ar.invoice_date >= '01-JAN-2014'
                        group by
                            ar.invoice_id, ar.invoice_date, ar.entity_id, ar.entity_type, ar.billing_date,
                            a.min_inv_amount, a.min_inv_hra_amount, decode(pr.plan_type, 'HRA', 'HRA', 'FSA'), ar.rate_plan_id, ar.start_date
                            , ar.end_date, ar.status,
                            invoice_amount
                        having ( sum(arl.total_line_amount) < nvl(a.min_inv_amount, 0)
                                 and nvl(a.min_inv_amount, 0) > 0
                                 or sum(arl.total_line_amount) < nvl(a.min_inv_hra_amount, 0)
                                 and nvl(a.min_inv_hra_amount, 0) > 0 )
                               and sum(arl.total_line_amount) > 0
                    )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                                           -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY') invoice_date      -- invoice_date
                    ,
                    case
                        when b.account_type in ( 'HRA', 'FSA' ) then
                            b.acc_num || '-FEE'
                        else
                            b.acc_num
                    end                                 customer                           -- customer id
                    ,
                    '"'
                    || substr(
                        replace(x.billing_name, ','),
                        1,
                        28
                    )
                    || '"'                              customer_name,
                    reason_name,
                    x.invoice_amount,
                    null
                from
                    ar_invoice a,
                    account    b,
                    (
                        select
                            ar.invoice_id,
                            a.billing_name,
                            case
                                when sum(arl.total_line_amount) < nvl(a.min_inv_amount, 0)
                                     and nvl(a.min_inv_amount, 0) > 0 then
                                    nvl(a.min_inv_amount, 0) - sum(arl.total_line_amount)
                                when sum(arl.total_line_amount) < nvl(a.min_inv_hra_amount, 0)
                                     and nvl(a.min_inv_hra_amount, 0) > 0 then
                                    nvl(a.min_inv_hra_amount, 0) - sum(arl.total_line_amount)
                            end invoice_amount,
                            case
                                when sum(arl.total_line_amount) < nvl(a.min_inv_amount, 0)
                                     and nvl(a.min_inv_amount, 0) > 0 then
                                    'FSA-Maintenance Fee'
                                when sum(arl.total_line_amount) < nvl(a.min_inv_hra_amount, 0)
                                     and nvl(a.min_inv_hra_amount, 0) > 0 then
                                    'HRA-Maintenance Fee'
                            end reason_name
                        from
                            ar_invoice         ar,
                            ar_invoice_lines   arl,
                            invoice_parameters a,
                            pay_reason         pr
                        where
                                ar.invoice_id = arl.invoice_id
                            and a.entity_id = ar.entity_id
                            and a.invoice_type = ar.invoice_reason
                            and arl.rate_code = to_char(pr.reason_code)
                            and ar.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                            and ar.invoice_reason = a.invoice_type
                            and arl.status <> 'VOID'
                            and pr.reason_mapping in ( 67, 68, 2 )
                            and ar.invoice_date >= '01-JAN-2014'
                        group by
                            ar.invoice_id,
                            ar.invoice_date,
                            ar.entity_id,
                            ar.entity_type,
                            ar.billing_date,
                            a.min_inv_amount,
                            a.min_inv_hra_amount,
                            decode(pr.plan_type, 'HRA', 'HRA', 'FSA'),
                            ar.rate_plan_id,
                            ar.start_date,
                            ar.end_date,
                            ar.status,
                            invoice_amount,
                            a.billing_name
                        having ( sum(arl.total_line_amount) < nvl(a.min_inv_amount, 0)
                                 and nvl(a.min_inv_amount, 0) > 0
                                 or sum(arl.total_line_amount) < nvl(a.min_inv_hra_amount, 0)
                                 and nvl(a.min_inv_hra_amount, 0) > 0 )
                               and sum(arl.total_line_amount) > 0
                    )          x
                where
                    a.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'FEE'
                    and a.invoice_date >= '01-JAN-2014'
                    and a.invoice_id = x.invoice_id
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num                                -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and is_stacked_account(b.entrp_id) = 'N'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    case
                        when is_stacked_account(b.entrp_id) = 'N' then
                            b.acc_num
                        when is_stacked_account(b.entrp_id) = 'Y'
                             and c.reason_code in ( 180, 70 ) then
                            b.acc_num || '-FSA'
                        when is_stacked_account(b.entrp_id) = 'Y'
                             and c.reason_code in ( 49, 69 ) then
                            b.acc_num || '-HRA'
                        else
                            b.acc_num
                    end
                      -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    c.gp_item_number,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'FUNDING'
                    and trunc(a.approved_date) = trunc(g_date)
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num || '-FSA'                        -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount                     -- price
                    ,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and is_stacked_account(b.entrp_id) = 'Y'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and exists (
                        select
                            *
                        from
                            invoice_distribution_summary c
                        where
                                a.invoice_id = c.invoice_id
                            and c.account_type = 'FSA'
                    )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num || '-HRA'                        -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status in ( 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and is_stacked_account(b.entrp_id) = 'Y'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and exists (
                        select
                            *
                        from
                            invoice_distribution_summary c
                        where
                                a.invoice_id = c.invoice_id
                            and c.account_type = 'HRA'
                    )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
            );

        if l_invoice_tbl.count > 0 then
            l_file_id := insert_file_seq('GP_INV');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_inv'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'Type,Type ID,Doc Number,Date,Default Site,Batch ID,Cust ID,Cust Name,item_number,unit_of_measure'
                      || ',quantity,unit_price,item_description,marksdown_amount,extended_price,qty_to_invoice,qty_fulfilled'
                      || ',qty_cancelled,qty_to_back_order,qty_to_order,items_unit_cost,doc_number';
            utl_file.put_line(utlf, l_line);
            for i in 1..l_invoice_tbl.last loop
                l_line := '3'  -- Type
                          || ','
                          || 'STD'-- Type Id
                          || ','
                          || l_invoice_tbl(i).invoice_id
                          || ','
                          || l_invoice_tbl(i).invoice_date
                          || ','
                          || 'MAIN'
                          || ','
                          || to_char(sysdate, 'MMDDYY')
                          || '-INV'
                          || ','
                          || l_invoice_tbl(i).customer_id
                          || ','
                          || l_invoice_tbl(i).customer_name
                          || ','
                          || l_invoice_tbl(i).item_number
                          || ',,1,'
                          || l_invoice_tbl(i).price
                          || rpad(',', 10, ',')
                          || l_invoice_tbl(i).invoice_id;

                utl_file.put_line(utlf, l_line);
                if l_invoice_tbl(i).invoice_line_id is not null then
                    insert_ap_ar_txn_outbnd(
                        p_batch_id    => to_char(sysdate, 'MMDDYY')
                                      || '-INV',
                        p_entity_id   => l_invoice_tbl(i).invoice_line_id,
                        p_entity_type => 'AR_INVOICE_LINES',
                        p_doc_date    => l_invoice_tbl(i).invoice_date,
                        p_amount      => l_invoice_tbl(i).price,
                        p_file_name   => x_file_name
                    );
                end if;

            end loop;

            utl_file.fclose(utlf);
        end if;
         /*  IF x_file_name IS NOT NULL THEN
              ftp_gp_files(x_file_name,'SOP');
           END IF;
         */
    exception
        when others then
            utl_file.fclose_all;
    end gp__manual_post_invoices;

    procedure gp_items (
        x_file_name out varchar2
    ) is
        items ty_tb_items;
    begin
        select
            substr(decode(d.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                          d.account_type)
                   || '-'
                   || b.reason_name,
                   1,
                   30),
            e.total_line_amount,
            substr(c.invoice_id, 1, 17)
        bulk collect
        into items
        from
            gp_ap_ar_txn_outbnd a,
            pay_reason          b,
            ar_invoice          c,
            account             d,
            ar_invoice_lines    e
        where
                a.entity_id = c.invoice_id
            and c.invoice_id = e.invoice_id
            and c.acc_num = d.acc_num
            and e.rate_code = b.reason_code
            and a.entity_type = 'AR_INVOICE'--'AR_INVOICE'
            and trunc(a.creation_date) = g_date
            and e.status <> 'VOID';

        if items.count > 0 then
            l_file_id := insert_file_seq('GP_ITM');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_items'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'item_number,unit_of_measure,quantity,unit_price,item_description,marksdown_amount,extended_price,' || 'qty_to_invoice,qty_fulfilled,qty_cancelled,qty_to_back_order,qty_to_order,items_unit_cost,doc_number'
            ;
            utl_file.put_line(utlf, l_line);
            for i in 1..items.last loop
                l_line := items(i).acnt_typ   -- item_number
                          || ',each,1,'          -- unit of measure , quantity
                          || items(i).amnt       -- unit price
                          || ',,,,,,,,,,'
                          || items(i).invoice_id;-- doc no

                utl_file.put_line(utlf, l_line);
            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'SOP');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_items;

    procedure gp_item_inventory (
        x_file_name out varchar2
    ) is
        itm_invnt ty_tb_itm_invnt;
    begin
        select
            item_number,
            item_description
        bulk collect
        into itm_invnt
        from
            item_master
        order by
            item_number;

        if itm_invnt.count > 0 then
            l_file_id := insert_file_seq('GP_ITM_INVNT');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_itm_invnt'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w', 32767);
            l_line := 'item_number,item_description,item_short_name,item_generic_description,item_class_code,item_type,'
                      || 'valuation_method,item_shipping_weight,sales_tax_options,sales_tax_schedule_id,u_of_m_schedule,'
                      || 'purchase_tax_options,purchase_tax_schedule_id,standard_cost,current_cost,list_price,decimal_places_qtys,'
                      || 'decimal_places_currency,item_note,inventory_gl_account,inventory_offset_gl_account,cost_of_goods_sold_gl_account,'
                      || 'sales_gl_account,marksdown_gl_account,sales_return_gl_account,in_use_gl_account,in_service_gl_account,'
                      || 'damaged_gl_account,variance_gl_account,drop_ship_items_gl_acct,purchase_price_variance_gl_acct,'
                      || 'unrealized_purchase_price_gl_acct,inventory_return_gl_acct,assembly_variance_gl_acct';

            utl_file.put_line(utlf, l_line);
            for i in 1..itm_invnt.last loop
                l_line := itm_invnt(i).itm_nmbr -- item number
                          || ','
                          || itm_invnt(i).itm_dscr -- item description
                          || ',,,,,,,,,each'            -- unit of measure
                          || rpad(',', 23, ',');

                utl_file.put_line(utlf, l_line);
            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'SOP');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_item_inventory;

    procedure gp_hsa_fee (
        x_file_name out varchar2
    ) is
        rec ty_tb_hsa_fee;
    begin
        select
            acc.acc_num-- cust id
            ,
            p.change_num-- invoice no
            ,
            1           -- doc type
            ,
            to_char(p.pay_date, 'MM/DD/YYYY') pay_date-- doc dt
            ,
            to_char(p.pay_date, 'MM/DD/YYYY') due_date-- due dt
            ,
            substr(pr.reason_name, 1, 30) -- dscrptn
            ,
            p.amount                    -- amnt
            ,
            decode(pr.reason_code, 1, '10-100-3001', '10-100-3002')-- dist a/c
            ,
            'PURCH'                           dist_type
        bulk collect
        into rec
        from
            account    acc,
            payment    p,
            pay_reason pr
        where
                acc.acc_id = p.acc_id
            and p.reason_code = pr.reason_code
            and pr.reason_type = 'FEE'
            and acc.account_type = 'HSA'
            and trunc(p.pay_date) = g_date
            and not exists (
                select
                    *
                from
                    gp_ap_ar_txn_outbnd e
                where
                        e.entity_id = p.change_num
                    and e.entity_type = 'PAYMENT'
            );

        if rec.count > 0 then
            l_file_id := insert_file_seq('GP_HSA_FEE');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_hsa_fee'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'batch_id,Vendor id,Document Number,document_type,document_date,due_date,description,' ||--'customer_po,
             'amount,distribution_account,debit,credit,dist_type,currency_id,exch_rate,Record_Number';
            utl_file.put_line(utlf, l_line);
            for i in 1..rec.last loop
                l_line := to_char(g_date, 'mmddrr')
                          || '-HSA_FEE'
                          || ','
                          || rec(i).cstmr_id   -- customer id
                          || ','
                          || rec(i).invoice_id -- invoice id
                          || ','
                          || rec(i).doc_typ    -- document type
                          || ','
                          || rec(i).doc_date   -- document date
                          || ','
                          || rec(i).due_date   -- due date
                          || ','
                          || rec(i).dscrptn    -- dscrptn
                          || ','
                          || rec(i).amnt       -- amount
                          || ','
                          || rec(i).dist_acnt  -- dist a/c
                          || ','
                          || rec(i).amnt       -- debit
                          || ',,'
                          || rec(i).dist_type -- distribution type
                          || ',,,'
                          || 'PAYMENT:'
                          || rec(i).invoice_id;

                utl_file.put_line(utlf, l_line);
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => to_char(g_date, 'mmddrr')
                                  || '-HSA_FEE',
                    p_entity_id   => rec(i).invoice_id,
                    p_entity_type => 'PAYMENT',
                    p_doc_date    => rec(i).doc_date,
                    p_amount      => rec(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'AP Transactions');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_hsa_fee;

    procedure gp_hsa_interest (
        x_file_name out varchar2
    ) is
        rec ty_tb_hsa_fee;
    begin
        select
            acc.acc_num  -- CUSTOMER ID
            ,
            i.change_num -- INVOICE #
            ,
            7            -- DOCUMENT TYPE
            ,
            to_char(i.fee_date, 'MM/DD/YYYY') fee_date-- doc dt.
            ,
            to_char(i.fee_date, 'MM/DD/YYYY') due_date,
            'Interest'                        description,
            i.amount -- amount
            ,
            '10-100-3900' -- dist a/c
            ,
            'CRMEMO'                          dist_type
        bulk collect
        into rec
        from
            account acc,
            income  i
        where
                acc.acc_id = i.acc_id
            and i.fee_code = 8 -- intrst
            and acc.account_type = 'HSA'
            and trunc(i.fee_date) = g_date
            and not exists (
                select
                    *
                from
                    gp_ap_ar_txn_outbnd e
                where
                        e.entity_id = i.change_num
                    and e.entity_type = 'INCOME'
            );

        if rec.count > 0 then
            l_file_id := insert_file_seq('GP_HSA_INTEREST');
            x_file_name := 'GP_'
                           || l_file_id
                           || '_hsa_int'
                           || to_char(g_date, 'mmddrr')
                           || '.csv';

            update external_files
            set
                file_name = x_file_name
            where
                file_id = l_file_id;

            utlf := utl_file.fopen(dir, x_file_name, 'w');
            l_line := 'batch_id,customer_id,invoice_id,document_type,document_date,due_date,description,' || 'customer_po,amount,distribution_account,debit,credit,dist_type,currency_id,exch_rate,Record_Number'
            ;
            utl_file.put_line(utlf, l_line);
            for i in 1..rec.last loop
                l_line := to_char(g_date, 'mmddrr')
                          || '-HSA_INT'
                          || ','
                          || rec(i).cstmr_id   -- customer id
                          || ','
                          || rec(i).invoice_id -- invoice id
                          || ','
                          || rec(i).doc_typ    -- document type
                          || ','
                          || rec(i).doc_date   -- document date
                          || ','
                          || rec(i).due_date   -- due date
                          || ','
                          || rec(i).dscrptn    -- dscrptn
                          || ',,'
                          || rec(i).amnt      -- amount
                          || ','
                          || rec(i).dist_acnt  -- dist a/c
                          || ','
                          || rec(i).amnt       -- debit
                          || ',,'
                          || rec(i).dist_type -- distribution type
                          || ',,,'
                          || 'PAYMENT:'
                          || rec(i).invoice_id;

                utl_file.put_line(utlf, l_line);
                insert_ap_ar_txn_outbnd(
                    p_batch_id    => to_char(g_date, 'mmddrr')
                                  || '-HSA_INT',
                    p_entity_id   => rec(i).invoice_id,
                    p_entity_type => 'INCOME',
                    p_doc_date    => rec(i).doc_date,
                    p_amount      => rec(i).amnt,
                    p_file_name   => x_file_name
                );

            end loop;

            utl_file.fclose(utlf);
        end if;

        if x_file_name is not null then
            ftp_gp_files(x_file_name, 'RM Transactions');
        end if;
    exception
        when others then
            utl_file.fclose_all;
    end gp_hsa_interest;

    procedure ftp_gp_files (
        p_file_name in varchar2,
        p_file_dir  in varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_conn      utl_tcp.connection;
    begin
        l_conn := ftp.login('216.109.157.45', '22', 'SAMGP', 'Today@46');
        ftp.binary(p_conn => l_conn);
          /*  ftp.put (p_conn      => l_conn,
                     p_from_dir  => 'GP',
                     p_from_file => p_file_name,
                     p_to_file   => p_file_name);*/
        ftp.put(
            p_conn      => l_conn,
            p_from_dir  => 'GP',
            p_from_file => p_file_name,
            p_to_file   => '/'
                         || p_file_dir
                         || '/'
                         || p_file_name
        );

        ftp.logout(l_conn);
        update external_files
        set
            sent_flag = 'Y'
        where
            file_name = p_file_name;

    end ftp_gp_files;

    procedure ftp_get_gp_files (
        p_file_name in varchar2,
        p_file_dir  in varchar2,
        p_action    in varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_conn      utl_tcp.connection;
    begin
        dbms_output.put_line('p_file_name' || p_file_name);
        dbms_output.put_line('p_file_dir' || p_file_dir);
        l_conn := ftp.login('216.109.157.45', '22', 'SAMGP', 'Today@46');
        ftp.binary(p_conn => l_conn);
          /*  ftp.put (p_conn      => l_conn,
                     p_from_dir  => 'GP',
                     p_from_file => p_file_name,
                     p_to_file   => p_file_name);*/
        ftp.get(
            p_conn      => l_conn,
            p_from_file => '/'
                           || p_file_dir
                           ||
                           case
                               when p_action = 'SUCCESS' then
                                   '/Archive/'
                               when p_action = 'ERROR'   then
                                   '/Errors/'
                           end
                           || p_file_name,
            p_to_dir    => 'GP',
            p_to_file   => p_file_name
        );

        ftp.logout(l_conn);
    exception
        when others then
            null;
    end ftp_get_gp_files;

    procedure post_customer_files is
        l_file_name varchar2(3200);
    begin
        gp_customer_account(l_file_name);
        gp_cstmr_adrs(l_file_name);
        gp_vendor_account(l_file_name);
        gp_vndr_adrs(l_file_name);
    end post_customer_files;

    procedure post_invoice_files is
        l_file_name varchar2(3200);
    begin
        gp_invoices(l_file_name);
    end post_invoice_files;

    procedure post_transaction_files is
        l_file_name varchar2(3200);
    begin
        gp_check_payment(l_file_name);
        gp_ach_payment(l_file_name);
        gp_debit_card_payment(l_file_name);
        gp_check_receipt(l_file_name);
        gp_ach_receipt(l_file_name);
        gp_hsa_fee(l_file_name);
        gp_hsa_interest(l_file_name);
    end post_transaction_files;

    procedure process_error_files is

        l_sqlerrm    varchar2(2000);
        l_create_error exception;
        l_action     varchar2(100);
        l_table_name varchar2(100);
        l_file_name  varchar2(100);
        l_directory  varchar2(100);
        l_sql        varchar2(2000);
    begin
        for x in (
            select
                file_action,
                replace(file_name, '.csv', '_ERRORS.csv')  file_name,
                replace(file_name, '.csv', '_SUCCESS.csv') succ_file_name,
                file_name                                  actual_file_name
            from
                external_files
            where
                file_action like 'GP%'
                and trunc(creation_date) >= trunc(sysdate) - 1
                and file_action not in ( 'GP_CSTMR_ACNT', 'GP_VNDR_ACNT' )
                and result_flag is null
        ) loop
            if x.file_action = 'GP_AP_TRNSCTN' then
                l_table_name := 'GP_PAYMENT_RESULT_EXTERNAL';
                l_directory := 'AP Manual Payments';
            elsif x.file_action = 'GP_AR_TRNSCTN' then
                l_table_name := 'GP_RECEIPT_RESULT_EXTERNAL';
                l_directory := 'RM Cash Receipts';
            elsif x.file_action = 'GP_INV' then
                l_table_name := 'GP_INVOICE_RESULT_EXTERNAL';
                l_directory := 'SOP';
            elsif x.file_action = 'GP_HSA_INTEREST' then
                l_table_name := 'GP_INTEREST_RESULT_EXTERNAL';
                l_directory := 'RM Transactions';
            elsif x.file_action = 'GP_HSA_FEE' then
                l_table_name := 'GP_FEE_RESULT_EXTERNAL';
                l_directory := 'AP Transactions';
            end if;

            l_sql := null;
            dbms_output.put_line('error file name X.FILE_NAME' || x.file_name);
            dbms_output.put_line('success file name X.FILE_NAME' || x.succ_file_name);
            ftp_get_gp_files(x.file_name, l_directory, 'ERROR');
         --       ftp_get_gp_files(X.SUCC_FILE_NAME,l_directory,'SUCCESS');

         --       l_file_name := PC_FILE.remove_line_feed(X.FILE_NAME,'GP','050115');

            if file_exists(x.file_name, 'GP') = 'TRUE' then
                  /*  l_sql := ' ALTER TABLE '||l_table_name||'
                                location (GP:'''||X.FILE_NAME||''','''||X.SUCC_FILE_NAME
                                ||''' )';*/

                l_sql := ' ALTER TABLE '
                         || l_table_name
                         || '
                                location (GP:'''
                         || x.file_name
                         || ''')';


             /*   ELSIF FILE_EXISTS(X.FILE_NAME,'GP') = 'TRUE'
                AND  FILE_EXISTS(X.SUCC_FILE_NAME,'GP') = 'FALSE' THEN
                    l_sql := ' ALTER TABLE '||l_table_name||'
                                location (GP:'''||X.FILE_NAME||''')';

                ELSIF FILE_EXISTS(X.SUCC_FILE_NAME,'GP') = 'TRUE'
                AND  FILE_EXISTS(X.FILE_NAME,'GP') = 'FALSE' THEN
                    l_sql := ' ALTER TABLE '||l_table_name||'
                                location (GP:'''||X.SUCC_FILE_NAME||''')';*/
            end if;

            if l_sql is not null then
                dbms_output.put_line('corrected file l_sql ' || l_sql);
                begin
                    execute immediate l_sql;
                exception
                    when others then
                        l_sqlerrm := 'Error in changing GP error file ' || sqlerrm;
                        raise l_create_error;
                end;

            end if;

            update_success_and_error(l_table_name, x.file_action, x.actual_file_name);

                   --Update the POSTED flag in underlying tables
            update_posted_flag(x.actual_file_name);
            update external_files
            set
                result_flag = 'Y'
            where
                file_name = x.actual_file_name;

        end loop;
    end process_error_files;

    procedure update_success_and_error (
        p_table_name  in varchar2,
        p_file_action in varchar2,
        p_file_name   in varchar2
    ) is

        type rc is ref cursor;
        l_cursor            rc;
        type varchar2_tbl is
            table of varchar2(4000) index by binary_integer;
        l_message_tbl       varchar2_tbl;
        l_record_number_tbl varchar2_tbl;
        l_entity_tbl        varchar2_tbl;
        l_sql               varchar2(2000);
    begin
        l_sql := 'SELECT ERROR_MESSAGE,SUBSTR(RECORD_NUMBER,1,INSTR(RECORD_NUMBER,'':'')-1) ENTITY_TYPE '
                 || '    ,   SUBSTR(RECORD_NUMBER,INSTR(RECORD_NUMBER,'':'')+1) ENTITY_ID '
                 || 'FROM '
                 || p_table_name;
        begin
            open l_cursor for l_sql;

            loop
                fetch l_cursor
                bulk collect into
                    l_message_tbl,
                    l_entity_tbl,
                    l_record_number_tbl;
                exit when l_cursor%notfound;
            end loop;

            close l_cursor;
        exception
            when others then
                dbms_output.put_line('l_record_number_tbl.COUNT ' || l_record_number_tbl.count);
        end;

        if l_record_number_tbl.count > 0 then
            for i in 1..l_record_number_tbl.count loop
                dbms_output.put_line('l_record_number_tbl( '
                                     || i
                                     || ')'
                                     || l_record_number_tbl(i));
            end loop;

            forall i in 1..l_record_number_tbl.count
                update gp_ap_ar_txn_outbnd
                set
                    error_message = l_message_tbl(i),
                    error_flag = 'Y'
                where
                        entity_type = l_entity_tbl(i)
                    and entity_id = l_record_number_tbl(i)
                    and l_message_tbl(i) is not null;

            forall i in 1..l_record_number_tbl.count
                update gp_ap_ar_txn_outbnd
                set
                    error_message = l_message_tbl(i),
                    error_flag = 'Y'
                where
                        entity_type = 'AR_INVOICE_LINES'
                    and entity_id in (
                        select
                            a.invoice_line_id
                        from
                            ar_invoice_lines a, ar_invoice_lines c
                        where
                                a.invoice_id = c.invoice_id
                            and c.invoice_line_id = l_record_number_tbl(i)
                    )
                    and error_flag is null
                    and file_name = p_file_name
                    and l_message_tbl(i) is not null;

        end if;
            /* FORALL i IN 1 .. l_record_number_tbl.COUNT
               UPDATE GP_AP_AR_TXN_OUTBND
                  SET   ERROR_FLAG    = 'N'
                 WHERE   entity_type     = l_entity_tbl(i)
                  AND    entity_id       = l_record_number_tbl(i)
                  AND    l_message_tbl(i) IS  NULL;
                 */

    end update_success_and_error;

    function get_check_payment (
        p_date in date
    ) return ty_tb_payment
        pipelined
    is
        ap_trnx ty_tb_payment;
    begin
        select
            *
        bulk collect
        into ap_trnx
        from
            (
                select
                    to_char(p_date, 'mmddrr')
                    || '-CHKPAY',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(check_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    0,                                        -- PAYMENT_METHOD
                    check_amount,                              -- AMOUNT
                    get_checkbook_id(account_type, 'CLAIM'),    -- CHECKBOOK_ID
                    check_number,                              -- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    checks     d,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and b.claim_id = d.entity_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and d.status = 'MAILED'
                    and d.check_amount = c.amount
                    and d.check_amount > 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and c.reason_code not in ( 13, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(p_date, 'mmddrr')
                    || '-CHKPAY',                                   -- BATCH ID
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(d.check_date, 'mm/dd/rrrr'),                                 -- DOCUMENT DATE
                    0,                                                                     -- PAYMENT_METHOD
                    check_amount,                                                           -- AMOUNT
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            pc_sam_gp_intgrtn.get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            pc_sam_gp_intgrtn.get_checkbook_id(a.account_type, 'CLAIM')
                    end,                    -- CHECKBOOK_ID
                    d.check_number,                                                         -- DOCUMENT NO
                    'N',                                                                    -- UNAPPLIED
                    'N',                                                                    -- REFUND
                    'PAYMENT',                                                    -- ENTITY TYPE
                    c.change_num                                                   -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    checks     d,
                    pay_reason f,
                    person     e
                where
                        a.entrp_id = e.entrp_id
                    and b.pers_id = e.pers_id
                    and b.claim_id = c.claimn_id
                    and b.claim_id = d.entity_id
                    and a.account_type in ( 'HRA', 'FSA' )
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and d.status = 'MAILED'
                    and d.check_amount = c.amount
                    and d.check_amount > 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) = trunc(d.check_date)
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and c.reason_code not in ( 13, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(p_date, 'mmddrr')
                    || '-CHKPAY',                                    -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(transaction_date, 'mm/dd/rrrr'),                                -- DOCUMENT DATE
                    0,                                                                     -- PAYMENT_METHOD
                    check_amount,                                                           -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'REFUND'
                            )
                        else
                            get_checkbook_id(a.account_type, 'REFUND')
                    end,                    -- CHECKBOOK_ID
                    nvl(b.check_number,
                        to_char(b.employer_payment_id)),                      -- DOCUMENT NO
                    'N',                                                                    -- UNAPPLIED
                    'Y',                                                                    -- REFUND
                    'EMPLOYER_PAYMENTS',                                                   -- ENTITY TYPE
                    b.employer_payment_id                                                   -- ENTITY ID
                from
                    account           a,
                    employer_payments b
                where
                        a.entrp_id = b.entrp_id
                    and account_type != 'HSA'
                    and b.check_amount > 0
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and trunc(b.check_date) < p_date
                    and trunc(b.check_date) >= '01-JUL-2015'
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )
                    and reason_code in ( 23, 25 ) -- Refund reason code
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
                union
                select
                    to_char(p_date, 'mmddrr')
                    || '-CHKPAY',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    0,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),              -- check number
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code not in ( 8, 11, 12, 18, 17 )  -- Exclude Interest, Payroll Contribution
                                               --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union
                select
                    to_char(p_date, 'mmddrr')
                    || '-CHKPAY',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    0,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code = 18
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(p_date, 'mmddrr')
                    || '-CHKPAY',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    0,                                        -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CLAIM')
                    end,  -- CHECKBOOK_ID
                    substr(
                        replace(b.check_number, ','),
                        1,
                        20
                    ),           -- check number
                    null,                                        -- comments
                    to_char(b.invoice_id),                        -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    employer_deposit_id                          -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) < 0
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and trunc(b.creation_date) < p_date
                    and b.reason_code not in ( 8, 11, 12, 40, 18,
                                               120, 17 )      --q
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
            )
        order by
            1;

        if ap_trnx.count > 0 then
            for i in 1..ap_trnx.last loop
                pipe row ( ap_trnx(i) );
            end loop;

        end if;

    exception
        when others then
            null;
            pc_log.log_app_error('PC_SAM_GP_INTGRTN', 'get_check_payment', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace);

    end get_check_payment;

    function get_ach_payment (
        p_date in date
    ) return ty_tb_payment
        pipelined
    is
        ap_trnx ty_tb_payment;
    begin
        select
            *
        bulk collect
        into ap_trnx
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    3,                                        -- PAYMENT_METHOD
                    c.amount,                                   -- AMOUNT
                    get_checkbook_id(account_type, 'CLAIM'),    -- CHECKBOOK_ID
                    to_char(d.transaction_id),                 -- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                  -- ENTITY TYPE
                    c.change_num                              -- ENTITY_ID
                from
                    account      a,
                    claimn       b,
                    payment      c,
                    ach_transfer d,
                    pay_reason   f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = c.claimn_id
                    and b.claim_id = d.claim_id
                    and account_type = 'HSA'
                    and d.transaction_type = 'D'
                    and d.status = 3
                    and c.amount > 0
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.reason_code = 19 --  epayment only
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',                                   -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                     -- VENDOR ID
                    to_char(d.transaction_date, 'mm/dd/rrrr'),                               -- DOCUMENT DATE
                    3,                                                                    -- PAYMENT_METHOD
                    c.amount,                                                          -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CLAIM')
                    end,                  -- CHECKBOOK_ID
                    to_char(d.transaction_id),                                       -- DOCUMENT NO
                    'N',                                                                  -- UNAPPLIED
                    'N',                                                                  -- REFUND
                    'PAYMENT',                                                  -- ENTITY TYPE
                    c.change_num                                                 -- ENTITY ID
                from
                    account      a,
                    person       e,
                    claimn       b,
                    payment      c,
                    ach_transfer d,
                    pay_reason   f
                where
                        a.entrp_id = e.entrp_id
                    and e.pers_id = b.pers_id
                    and b.claim_id = c.claimn_id
                    and b.claim_id = d.claim_id
                    and account_type in ( 'HRA', 'FSA' )
                    and d.transaction_type = 'D'
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and d.status = 3
                    and c.amount > 0
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.reason_code = 19 --  epayment only
                    and trunc(d.transaction_date) < p_date
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',                                   -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(transaction_date, 'mm/dd/rrrr'),                                -- DOCUMENT DATE
                    3,                                                                     -- PAYMENT_METHOD
                    check_amount,                                                           -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'REFUND'
                            )
                        else
                            get_checkbook_id(a.account_type, 'REFUND')
                    end,                   -- CHECKBOOK_ID
                    nvl(b.check_number,
                        to_char(b.employer_payment_id)),                    -- DOCUMENT NO
                    'N',                                                                   -- UNAPPLIED
                    'Y',                                                                   -- REFUND
                    'EMPLOYER_PAYMENTS',                                                   -- ENTITY TYPE
                    b.employer_payment_id                                                  -- ENTITY ID
                from
                    account           a,
                    employer_payments b
                where
                        a.entrp_id = b.entrp_id
                    and account_type != 'HSA'
                    and check_amount > 0
                    and trunc(b.check_date) < p_date
                    and trunc(b.check_date) >= '01-JUL-2015'
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )
                    and reason_code in ( 23, 25 ) -- Refund reason code
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code not in ( 8, 11, 12, 18, 17 )  -- Exclude Interest, Payroll Contribution
                                               --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                        -- Receipt Type
                    abs(nvl(amount, 0) + nvl(amount_add, 0)),           --  Amount
                    get_checkbook_id(account_type, 'CLAIM'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code = 18
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) < 0
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACHPAY',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                        -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CLAIM')
                    end,  -- CHECKBOOK_ID
                    substr(
                        nvl(
                            replace(b.check_number, ','),
                            employer_deposit_id
                        ),
                        1,
                        20
                    ),           -- check number
                    null,                                        -- comments
                    to_char(b.invoice_id),                        -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    employer_deposit_id                          -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) < 0
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and b.reason_code not in ( 8, 11, 12, 40, 17,
                                               18, 120 )      --q
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
            )
        order by
            1;

        if ap_trnx.count > 0 then
            for i in 1..ap_trnx.last loop
                pipe row ( ap_trnx(i) );
            end loop;

        end if;

    exception
        when others then
            null;
            pc_log.log_app_error('PC_SAM_GP_INTGRTN', 'get_ach_payment', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace);

    end get_ach_payment;

    function get_ach_receipt (
        p_date in date
    ) return ty_tb_gp_cstmr
        pipelined
    is
        gp_cstmr_acn ty_tb_gp_cstmr;
    begin
        select
            *
        bulk collect
        into gp_cstmr_acn
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                          -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        replace(cc_number, ','),
                        1,
                        20
                    ),        -- check number
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and nvl(amount, 0) + nvl(amount_add, 0) > 0
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code not in ( 8, 11, 12, 18, 17 )  -- Exclude Interest, Payroll Contribution
                                                   --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Outside Investment Transfer
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                          -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        replace(cc_number, ','),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and nvl(amount, 0) + nvl(amount_add, 0) > 0
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and fee_code = 18
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    3,                                          -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,  -- CHECKBOOK_ID
                    substr(
                        replace(b.check_number, ','),
                        1,
                        20
                    ),         -- check number
                    null,                                        -- comments
                    b.invoice_id,                                -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    b.employer_deposit_id                        -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) > 0
                    and trunc(b.check_date) < p_date
                    and trunc(b.check_date) >= '01-JUL-2015'
                    and b.reason_code not in ( 8, 11, 12, 40, 18,
                                               17 )      --q
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
                union -- Fees from invoices
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]')
                    ||
                    case
                        when a.account_type in ( 'HRA', 'FSA' ) then
                                '-FEE'
                        else
                            ''
                    end,                                  -- Customer ID
                    to_char(b.check_date, 'mm/dd/rrrr'),           -- Document Date
                    3,                                           -- Receipt Type
                    abs(nvl(b.check_amount, 0)),                      --  Amount
                    get_checkbook_id(a.account_type, 'FEE'),      -- Checkbook ID
                    substr(
                        replace(b.employer_payment_id, ','),
                        1,
                        20
                    ),    -- check number
                    null,                                        -- comments
                    b.invoice_id,                                -- invoice_id
                    'EMPLOYER_PAYMENTS',                         -- entity_type
                    b.employer_payment_id                        -- entity id
                from
                    account           a,
                    employer_payments b,
                    pay_reason        c
                where
                        a.entrp_id = b.entrp_id
                    and trunc(b.check_date) < p_date
                    and trunc(b.check_date) >= '01-JUL-2015'
                    and nvl(b.check_amount, 0) > 0
                    and account_type <> 'HSA'
                    and b.reason_code = c.reason_code
                    and c.reason_type = 'FEE'
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and nvl(b.pay_code, 1) in ( 8, 3, 5 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    3,                                        -- PAYMENT_METHOD
                    abs(c.amount),                              -- AMOUNT
                    get_checkbook_id(account_type, 'CONT'),    -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),              -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and c.reason_code in ( 29, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-ACH',                                   -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                     -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),                               -- DOCUMENT DATE
                    3,                                                                    -- PAYMENT_METHOD
                    abs(c.amount),                                                          -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,                  -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),                                       -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'PAYMENT',                                                  -- ENTITY TYPE
                    c.change_num                                                 -- ENTITY ID
                from
                    account    a,
                    person     e,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.entrp_id = e.entrp_id
                    and e.pers_id = b.pers_id
                    and b.claim_id = c.claimn_id
                    and account_type in ( 'HRA', 'FSA' )
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.reason_code in ( 29, 19 ) --  epayment only
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
            )
        order by
            1;

        if gp_cstmr_acn.count > 0 then
            for i in 1..gp_cstmr_acn.last loop
                pipe row ( gp_cstmr_acn(i) );
            end loop;

        end if;

    end get_ach_receipt;

    function get_check_receipt (
        p_date in date
    ) return ty_tb_gp_cstmr
        pipelined
    is
        gp_cstmr_acn     ty_tb_gp_cstmr;
        gp_inv_acn       ty_tb_gp_cstmr;
        l_invoice_id     number;
        l_invoice_amount number := 0;
    begin
        select
            *
        bulk collect
        into gp_cstmr_acn
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]'),      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),              -- check number
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'INCOME',                                    -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) > 0
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code not in ( 8, 11, 12, 18 )  -- Exclude Interest, Payroll Contribution
                                               --, annaul election and Outside Investment
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Outside Investment Transfer
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    ltrim(
                        regexp_replace(acc_num, '[[:cntrl:]]'),
                        '0'
                    )
                    || '-OI',      -- Customer ID
                    to_char(fee_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(amount, 0) + nvl(amount_add, 0),           --  Amount
                    get_checkbook_id(account_type, 'CONT'),      -- Checkbook ID
                    substr(
                        nvl(
                            replace(cc_number, ','),
                            b.change_num
                        ),
                        1,
                        20
                    ),        -- check number
                    null,                                        -- comments
                    null,                                        -- invoice_id
                    'INCOME',                                     -- entity_type
                    b.change_num                                 -- entity_id
                from
                    account a,
                    income  b
                where
                        a.acc_id = b.acc_id
                    and account_type = 'HSA'
                    and fee_code not in ( 5, 17 )
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and fee_code = 18
                    and nvl(b.amount, 0) + nvl(b.amount_add, 0) > 0
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.change_num
                            and e.entity_type = 'INCOME'
                    )
                union -- Contributuons from Claim Invoice  Invoice
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,   -- VENDOR ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(b.check_amount, 0),                      --  Amount
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,  -- CHECKBOOK_ID
                    substr(
                        nvl(
                            replace(b.check_number, ','),
                            employer_deposit_id
                        ),
                        1,
                        20
                    ),           -- check number
                    null,                                        -- comments
                    to_char(b.invoice_id),                        -- invoice_id
                    'EMPLOYER_DEPOSITS',                         -- entity_type
                    employer_deposit_id                          -- entity id
                from
                    account           a,
                    employer_deposits b
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and nvl(b.check_amount, 0) > 0
                    and trunc(b.creation_date) < p_date
                    and trunc(b.creation_date) >= '01-JUL-2015'
                    and b.reason_code not in ( 8, 11, 12, 40, 18,
                                               17, 120 )      --q
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_deposit_id
                            and e.entity_type = 'EMPLOYER_DEPOSITS'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',      -- BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    '0',                                        -- PAYMENT_METHOD
                    abs(c.amount),                              -- AMOUNT
                    get_checkbook_id(account_type, 'CONT'),    -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),              -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and c.reason_code <> 19 -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',                                   -- BATCH ID
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),                                 -- DOCUMENT DATE
                    '0',                                                                     -- PAYMENT_METHOD
                    abs(c.amount),                                                           -- AMOUNT
                    case
                        when pc_sam_gp_intgrtn.is_stacked_account(a.entrp_id) = 'Y' then
                            pc_sam_gp_intgrtn.get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            pc_sam_gp_intgrtn.get_checkbook_id(a.account_type, 'CONT')
                    end,                    -- CHECKBOOK_ID
                    to_char(nvl(c.pay_num, c.change_num)),                                           -- DOCUMENT NO
                    'N',                                                                    -- UNAPPLIED
                    'N',                                                                    -- REFUND
                    'PAYMENT',                                                    -- ENTITY TYPE
                    c.change_num                                                   -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f,
                    person     e
                where
                        a.entrp_id = e.entrp_id
                    and b.pers_id = e.pers_id
                    and b.claim_id = c.claimn_id
                    and a.account_type in ( 'HRA', 'FSA' )
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount < 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and c.reason_code not in ( 13, 19 ) -- exclude epayment , debit card
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',                                    -- BATCH ID
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(a.acc_num, '[[:cntrl:]]')
                    end,                      -- VENDOR ID
                    to_char(transaction_date, 'mm/dd/rrrr'),                                -- DOCUMENT DATE
                    '0',                                        -- PAYMENT_METHOD
                    abs(check_amount),                                                           -- AMOUNT
                    case
                        when is_stacked_account(a.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CONT'
                            )
                        else
                            get_checkbook_id(a.account_type, 'CONT')
                    end,                    -- CHECKBOOK_ID
                    to_char(b.employer_payment_id),                                         -- DOCUMENT NO
                    null comments,                              -- comments
                    null invoice_id,                           -- invoice_id
                    'EMPLOYER_PAYMENTS',                                                   -- ENTITY TYPE
                    b.employer_payment_id                                                   -- ENTITY ID
                from
                    account           a,
                    employer_payments b
                where
                        a.entrp_id = b.entrp_id
                    and account_type != 'HSA'
                    and b.check_amount < 0
                    and nvl(b.transaction_source, '-1') <> 'GP'
                    and trunc(b.check_date) < p_date
                    and trunc(b.check_date) >= '01-JUL-2015'
                    and reason_code in ( 23, 25 ) -- Refund reason code
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
            )
        order by
            1;

        dbms_output.put_line('gp_cstmr_acn.count' || gp_cstmr_acn.count);
        if gp_cstmr_acn.count > 0 then
            for i in 1..gp_cstmr_acn.last loop
                pipe row ( gp_cstmr_acn(i) );
            end loop;
        end if;

        dbms_output.put_line('fee invoices collection ' || gp_cstmr_acn.count);

         -- Fees from invoices
        select
            *
        bulk collect
        into gp_inv_acn
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-CHKREC',       -- BATCH ID
                    regexp_replace(acc_num, '[[:cntrl:]]')
                    ||
                    case
                        when a.account_type in ( 'HRA', 'FSA' ) then
                                '-FEE'
                        else
                            ''
                    end,                                  -- Customer ID
                    to_char(b.check_date, 'mm/dd/rrrr'),             -- Document Date
                    '0',                                        -- Receipt Type
                    nvl(b.check_amount, 0),                      --  Amount
                    get_checkbook_id(a.account_type, 'FEE'),      -- Checkbook ID
                    substr(
                        replace(b.check_number, ','),
                        1,
                        20
                    ),    -- check number
                    null,                                       -- comments
                    b.invoice_id,                      -- invoice_id
                    'EMPLOYER_PAYMENTS',                        -- entity_type
                    b.employer_payment_id                        -- entity id
                from
                    account           a,
                    employer_payments b,
                    pay_reason        c
                where
                        a.entrp_id = b.entrp_id
                    and account_type <> 'HSA'
                    and b.reason_code = c.reason_code
                    and b.reason_code != '120'
                    and c.reason_type = 'FEE'
                    and b.invoice_id is not null
                    and trunc(b.check_date) < p_date
                    and trunc(b.check_date) >= '01-JUL-2015'
                    and nvl(b.pay_code, 1) in ( 1, 4, 9 )      --q
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = b.employer_payment_id
                            and e.entity_type = 'EMPLOYER_PAYMENTS'
                    )
            )
        order by
            invoice_id;

        if gp_inv_acn.count > 0 then
            for i in 1..gp_inv_acn.last loop
                pipe row ( gp_inv_acn(i) );
            end loop;
        end if;

    exception
        when others then
            pc_log.log_app_error('PC_SAM_GP_INTGRTN', 'get_check_receipt', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace);
    end get_check_receipt;

    function get_debit_card_payment (
        p_date in date
    ) return ty_tb_payment
        pipelined
    is
        ap_trnx ty_tb_payment;
    begin
        select
            *
        bulk collect
        into ap_trnx
        from
            (
                select
                    to_char(g_date, 'mmddrr')
                    || '-DCPAY',       -- debit card payment BATCH ID
                    regexp_replace(a.acc_num, '[[:cntrl:]]'),   -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    1,                                         -- dr card PAYMENT_METHOD
                    c.amount,                              -- AMOUNT
                    get_checkbook_id(account_type, 'CLAIM'),    -- CHECKBOOK_ID
                    substr(
                        nvl(
                            regexp_replace(
                                regexp_replace(c.pay_num, '[[:punct:]]', '|'),
                                '[[:cntrl:]]'
                            ),
                            c.change_num
                        ),
                        1,
                        20
                    ),-- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    account    a,
                    claimn     b,
                    payment    c,
                    pay_reason f
                where
                        a.pers_id = b.pers_id
                    and b.claim_id = claimn_id
                    and account_type = 'HSA'
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and c.amount > 0
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.paid_date) < p_date
                    and trunc(c.paid_date) >= '01-JUL-2015'
                    and c.reason_code = 13                                     -- debit card payment reason
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
                union
                select
                    to_char(g_date, 'mmddrr')
                    || '-DCPAY',       -- debit card payment BATCH ID
                    case
                        when is_stacked_account(acc.entrp_id) = 'Y' then
                            regexp_replace(acc.acc_num, '[[:cntrl:]]')
                            || '-'
                            || pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        else
                            regexp_replace(acc.acc_num, '[[:cntrl:]]')
                    end,                     -- VENDOR ID
                    to_char(c.paid_date, 'mm/dd/rrrr'),          -- DOCUMENT DATE
                    1,                                         -- dr card PAYMENT_METHOD
                    c.amount,                              -- AMOUNT
                    case
                        when is_stacked_account(acc.entrp_id) = 'Y' then
                            get_checkbook_id(
                                pc_lookups.get_meaning(c.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                                'CLAIM'
                            )
                        else
                            get_checkbook_id(acc.account_type, 'CLAIM')
                    end,    -- CHECKBOOK_ID
                    substr(
                        nvl(
                            regexp_replace(
                                regexp_replace(c.pay_num, '[[:punct:]]', '|'),
                                '[[:cntrl:]]'
                            ),
                            c.change_num
                        ),
                        1,
                        20
                    ),-- DOCUMENT NO
                    'N' unapplied,                             -- UNAPPLIED
                    'N' refund,                                -- REFUND
                    'PAYMENT',                                 -- ENTITY TYPE
                    c.change_num                               -- ENTITY ID
                from
                    ben_plan_enrollment_setup bp,
                    account                   acc,
                    claimn                    b,
                    payment                   c,
                    pay_reason                f,
                    person                    d
                where
                    acc.entrp_id is not null
                    and acc.entrp_id = d.entrp_id
                    and bp.acc_id = acc.acc_id
                    and b.pers_id = d.pers_id
                    and acc.account_type in ( 'HRA', 'FSA' )
                    and c.plan_type = bp.plan_type
                    and c.reason_code = 13
                    and bp.status in ( 'A', 'I' )
                    and c.reason_code = f.reason_code
                    and f.reason_type = 'DISBURSEMENT'
                    and b.plan_start_date = bp.plan_start_date
                    and b.plan_end_date = bp.plan_end_date
                    and bp.claim_reimbursed_by = 'STERLING'
                    and b.claim_id = c.claimn_id
                    and nvl(c.pay_source, '-1') <> 'GP'
                    and trunc(c.pay_date) < p_date
                    and trunc(c.pay_date) >= '01-JUL-2015'
                    and c.paid_date >= trunc(nvl(bp.reimburse_start_date, bp.plan_start_date))
                    and c.paid_date <= trunc(nvl(bp.reimburse_end_date, sysdate))
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = c.change_num
                            and e.entity_type = 'PAYMENT'
                    )
            )
        order by
            1;

        if ap_trnx.count > 0 then
            for i in 1..ap_trnx.last loop
                pipe row ( ap_trnx(i) );
            end loop;

        end if;

    exception
        when others then
            pc_log.log_app_error('PC_SAM_GP_INTGRTN', 'get_debit_card_payment', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace);
    end get_debit_card_payment;

    function get_hsa_fee (
        p_date in date
    ) return ty_tb_hsa_fee
        pipelined
    is
        rec ty_tb_hsa_fee;
    begin
        select
            acc.acc_num-- cust id
            ,
            p.change_num-- invoice no
            ,
            1           -- doc type
            ,
            to_char(p.pay_date, 'MM/DD/YYYY') pay_date-- doc dt
            ,
            to_char(p.pay_date, 'MM/DD/YYYY') due_date-- due dt
            ,
            substr(pr.reason_name, 1, 30) -- dscrptn
            ,
            p.amount                    -- amnt
            ,
            decode(pr.reason_code, 1, '10-100-3001', '10-100-3002')-- dist a/c
            ,
            'PURCH'                           dist_type
        bulk collect
        into rec
        from
            account    acc,
            payment    p,
            pay_reason pr
        where
                acc.acc_id = p.acc_id
            and p.reason_code = pr.reason_code
            and pr.reason_type = 'FEE'
            and acc.account_type = 'HSA'
            and trunc(p.pay_date) > '15-JUL-2015'
            and trunc(p.pay_date) < p_date
            and not exists (
                select
                    *
                from
                    gp_ap_ar_txn_outbnd e
                where
                        e.entity_id = p.change_num
                    and e.entity_type = 'PAYMENT'
            );

        if rec.count > 0 then
            for i in 1..rec.last loop
                pipe row ( rec(i) );
            end loop;

        end if;

    end get_hsa_fee;

    function get_hsa_interest (
        p_date in date
    ) return ty_tb_hsa_fee
        pipelined
    is
        rec ty_tb_hsa_fee;
    begin
        select
            acc.acc_num  -- CUSTOMER ID
            ,
            i.change_num -- INVOICE #
            ,
            7            -- DOCUMENT TYPE
            ,
            to_char(i.fee_date, 'MM/DD/YYYY') fee_date-- doc dt.
            ,
            to_char(i.fee_date, 'MM/DD/YYYY') due_date,
            'Interest'                        description,
            i.amount -- amount
            ,
            '10-100-3900' -- dist a/c
            ,
            'CRMEMO'                          dist_type
        bulk collect
        into rec
        from
            account acc,
            income  i
        where
                acc.acc_id = i.acc_id
            and i.fee_code = 8 -- intrst
            and acc.account_type = 'HSA'
            and trunc(i.fee_date) > '15-JUL-2015'
            and trunc(i.fee_date) < p_date
            and not exists (
                select
                    *
                from
                    gp_ap_ar_txn_outbnd e
                where
                        e.entity_id = i.change_num
                    and e.entity_type = 'INCOME'
            );

        if rec.count > 0 then
            for i in 1..rec.last loop
                pipe row ( rec(i) );
            end loop;

        end if;

    end get_hsa_interest;

    function get_invoices (
        p_date in date
    ) return ty_tb_invoice
        pipelined
    is
        l_invoice_tbl ty_tb_invoice;
    begin
        select
            *
        bulk collect
        into l_invoice_tbl
        from
            (
                select
                    a.invoice_id                                           -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY') invoice_date      -- invoice_date
                    ,
                    case
                        when b.account_type in ( 'HRA', 'FSA' ) then
                            b.acc_num || '-FEE'
                        else
                            b.acc_num
                    end                                 customer                           -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'   -- customer name
                    ,
                    nvl(c.gp_item_number,
                        decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                               b.account_type)
                        || '-'
                        || case
                        when instr(
                            substr(
                                replace(c.reason_name, b.account_type),
                                1,
                                1
                            ),
                            ' '
                        ) = 0 then
                            substr(
                                replace(c.reason_name, b.account_type),
                                1,
                                30
                            )
                        else substr(
                            replace(c.reason_name, b.account_type),
                            2,
                            30
                        )
                    end)-- item number
                    ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'FEE'
                    and trunc(a.approved_date) < trunc(p_date)
                    and trunc(a.approved_date) > '15-JUL-2015'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num                                -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and is_stacked_account(b.entrp_id) = 'N'
                    and trunc(a.approved_date) < trunc(p_date)
                    and trunc(a.approved_date) > '15-JUL-2015'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    case
                        when is_stacked_account(b.entrp_id) = 'N' then
                            b.acc_num
                        when is_stacked_account(b.entrp_id) = 'Y'
                             and c.reason_code in ( 180, 70 ) then
                            b.acc_num || '-FSA'
                        when is_stacked_account(b.entrp_id) = 'Y'
                             and c.reason_code in ( 49, 69 ) then
                            b.acc_num || '-HRA'
                        else
                            b.acc_num
                    end
                      -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    c.gp_item_number,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'FUNDING'
                    and trunc(a.approved_date) < trunc(p_date)
                    and trunc(a.approved_date) > '15-JUL-2015'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num || '-FSA'                        -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount                     -- price
                    ,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and trunc(a.approved_date) = g_date
                    and is_stacked_account(b.entrp_id) = 'Y'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and trunc(a.approved_date) < trunc(p_date)
                    and trunc(a.approved_date) > '15-JUL-2015'
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and exists (
                        select
                            *
                        from
                            invoice_distribution_summary c
                        where
                                a.invoice_id = c.invoice_id
                            and c.account_type = 'FSA'
                    )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
                union
                select
                    a.invoice_id                               -- invoice_id
                    ,
                    to_char(invoice_date, 'MM/DD/YYYY')       -- invoice_date
                    ,
                    b.acc_num || '-HRA'                        -- customer id
                    ,
                    '"'
                    || substr(
                        replace(a.billing_name, ','),
                        1,
                        28
                    )
                    || '"'-- customer name
                    ,
                    substr(decode(b.account_type, 'ERISA_WRAP', 'ERISA', 'FORM_5500', '5500',
                                  b.account_type)
                           || '-'
                           || c.reason_name,
                           1,
                           30)        -- item number
                           ,
                    e.total_line_amount,
                    e.invoice_line_id
                from
                    ar_invoice       a,
                    account          b,
                    ar_invoice_lines e,
                    pay_reason       c
                where
                    a.status not in ( 'DRAFT', 'VOID', 'GENERATED', 'CANCELLED' )
                    and a.acc_id = b.acc_id
                    and a.invoice_reason = 'CLAIM'
                    and trunc(a.approved_date) = g_date
                    and is_stacked_account(b.entrp_id) = 'Y'
                    and a.invoice_id = e.invoice_id
                    and e.rate_code = c.reason_code
                    and trunc(a.approved_date) < trunc(p_date)
                    and trunc(a.approved_date) > '15-JUL-2015'
                    and e.status <> 'VOID'
                    and b.account_type in ( 'HRA', 'FSA' )
                    and exists (
                        select
                            *
                        from
                            invoice_distribution_summary c
                        where
                                a.invoice_id = c.invoice_id
                            and c.account_type = 'HRA'
                    )
                    and not exists (
                        select
                            *
                        from
                            gp_ap_ar_txn_outbnd e
                        where
                                e.entity_id = e.invoice_line_id
                            and e.entity_type = 'AR_INVOICE_LINES'
                    )
            );

        if l_invoice_tbl.count > 0 then
            for i in 1..l_invoice_tbl.last loop
                pipe row ( l_invoice_tbl(i) );
            end loop;

        end if;

    exception
        when others then
            pc_log.log_app_error('PC_SAM_GP_INTGRTN', 'get_invoices', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace);
    end get_invoices;

    procedure update_posted_flag (
        p_file_name in varchar2
    ) is

        type rc is ref cursor;
        l_cursor            rc;
        type varchar2_tbl is
            table of varchar2(4000) index by binary_integer;
        l_message_tbl       varchar2_tbl;
        l_record_number_tbl varchar2_tbl;
        l_entity_tbl        varchar2_tbl;
        l_sql               varchar2(2000);
    begin
        pc_log.log_error('PC_SAM_GP_INTGRTN', 'Update Posted Flag');
               --     l_sql := 'SELECT ERROR_MESSAGE,SUBSTR(RECORD_NUMBER,1,INSTR(RECORD_NUMBER,'':'')-1) ENTITY_TYPE '||
                 --            '    ,   SUBSTR(RECORD_NUMBER,INSTR(RECORD_NUMBER,'':'')+1) ENTITY_ID '||
                   --          'FROM '||p_table_name;

               --     l_sql := 'SELECT a.ERROR_MESSAGE,SUBSTR(RECORD_NUMBER,1,INSTR(RECORD_NUMBER,'':'')-1) ENTITY_TYPE '||
      	         --                 '    ,   SUBSTR(RECORD_NUMBER,INSTR(RECORD_NUMBER,'':'')+1) ENTITY_ID '||
                   --          'FROM '||p_table_name ||' a'||','||'GP_AP_AR_TXN_OUTBND b'
                     --        || ' WHERE ERROR_FLAG IS NULL'
                       --      ||' AND ENTITY_ID = SUBSTR(RECORD_NUMBER,INSTR(RECORD_NUMBER,'':'')+1)';

                   --dbms_output.put_line (l_sql);

        for i in (
            select
                *
            from
                gp_ap_ar_txn_outbnd
            where
                error_flag is null
                and file_name = p_file_name
        ) loop
            if i.entity_type = 'PAYMENT' then
                update payment
                set
                    gp_posted = 'Y'
                where
                    change_num = i.entity_id;

            elsif i.entity_type = 'INCOME' then
                update income
                set
                    gp_posted = 'Y'
                where
                    change_num = i.entity_id;

            elsif i.entity_type = 'EMPLOYER_DEPOSITS' then
                update employer_deposits
                set
                    gp_posted = 'Y'
                where
                    employer_deposit_id = i.entity_id;

            elsif i.entity_type = 'EMPLOYER_PAYMENTS' then
                update employer_payments
                set
                    gp_posted = 'Y'
                where
                    employer_payment_id = i.entity_id;

            end if;
        end loop;

        pc_log.log_error('PC_SAM_GP_INTGRTN', 'Posted Flag Updated');
    end update_posted_flag;

end pc_sam_gp_intgrtn;
/


-- sqlcl_snapshot {"hash":"51acebadb5d7a3767a96e5183a1a58d7c036a764","type":"PACKAGE_BODY","name":"PC_SAM_GP_INTGRTN","schemaName":"SAMQA","sxml":""}