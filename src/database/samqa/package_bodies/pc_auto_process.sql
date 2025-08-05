create or replace package body samqa.pc_auto_process as

    procedure card_balance_reconcile (
        p_date in varchar2 default null
    ) as

        l_create_sql varchar2(32000);
        l_file_name  varchar2(300) := 'CardholderBalance'
                                     || nvl(p_date,
                                            to_char(sysdate, 'YYYY-MM-DD'))
                                     || '.csv';
        l_exception exception;
    begin
        null;
    exception
        when l_exception then
            null;
        when others then
            raise;
    end;

    procedure refresh_employer_balance_mv is
    begin
        begin
            execute immediate 'DROP TABLE EMPLOYER_BALANCE_MV';
        exception
            when others then
                null;
        end;
        begin
            execute immediate 'CREATE TABLE EMPLOYER_BALANCE_MV  AS
              SELECT * FROM TABLE(pc_employer_fin.get_funding_er_balance)';
        exception
            when others then
                null;
        end;
    end refresh_employer_balance_mv;

    procedure bank_serv_deposits (
        p_date in varchar2
    ) is

        l_table_sql     varchar2(32000);
        l_file          varchar2(100) := p_date || '-0600_oracle.csv';
        l_exception exception;
        l_error_message varchar2(32000);
    begin
        if file_exists(l_file, 'BANK_SERV_DIR') = 'TRUE' then
            l_table_sql := 'ALTER TABLE  BANK_SERV_EXTERNAL LOCATION (BANK_SERV_DIR:'''
                           || l_file
                           || ''')';
        end if;

        begin
            execute immediate l_table_sql;
        exception
            when others then
                l_error_message := sqlerrm;
                raise l_exception;
        end;

	  /*l_table_sql := 'CREATE TABLE BANK_SERV_EXTERNAL '||
			'(TxnID                 NUMBER '||
			',AccNum                VARCHAR2(30) '||
			',Name                  VARCHAR2(100) '||
			',TotalAmount           NUMBER '||
			',DepositType           NUMBER '||
			',DepositTypeTranslated VARCHAR2(30) '||
			',BankservStatus        VARCHAR2(255) '||
			',Date_YYYYMMDDHHMMSS   VARCHAR2(100) '||
			',EmployeeContrib       VARCHAR2(30)  '||
			',EmployerContrib       VARCHAR2(30) '||
			',EmployeeID            VARCHAR2(255) '||
			',EmployeeNamePerson    VARCHAR2(255) '||
			',EmployeeNameEnroll    VARCHAR2(255)) '||
			'  ORGANIZATION EXTERNAL '||
			'    ( TYPE ORACLE_LOADER  DEFAULT DIRECTORY bank_serv_dir '||
			'      ACCESS PARAMETERS '||
			'      ( records delimited by newline skip 1 fields terminated by '',''   '||
			'       optionally enclosed by ''"''   LRTRIM   MISSING FIELD VALUES ARE NULL) '||
			'      LOCATION ( '''|| l_file ||''' ))';

	 -- dbms_output.put_line('table sql '||l_table_sql);
	  BEGIN
	       EXECUTE IMMEDIATE 'DROP TABLE  BANK_SERV_EXTERNAL';
	  EXCEPTION
	       WHEN OTHERS THEN
		  NULL;
	  END;

	    EXECUTE IMMEDIATE l_table_sql;
      */

	  /** Posting Individual Contribution ***/
        begin
            insert into income (
                change_num,
                acc_id,
                fee_date,
                fee_code,
                amount,
                pay_code,
                cc_number,
                note,
                amount_add,
                transaction_type
            )
                select
                    change_seq.nextval,
                    b.acc_id,
                    to_date(p_date, 'YYYYMMDD'),
                    decode(deposittype, 1, 3, 2, 4,
                           3, 5, 4, 6, 5,
                           7),
                    0,
                    5
		     --  , 'BankServ'||TxnID
		     --  , 'Bankserv Deposit generate '||sysdate
                    ,
                    'CNB' || txnid                        -- Added by Swamy for Ticket#7723
                    ,
                    'CNB Deposit generate ' || sysdate   -- Added by Swamy for Ticket#7723
                    ,
                    totalamount,
                    'P'
                from
                    bank_serv_external a,
                    account            b
                where
                    employeeid is null
                    and bankservstatus = 'Approved'
                    and a.accnum = b.acc_num
                    and b.pers_id is not null
                    and not exists (
                        select
                            *
                        from
                            income
                        where
                                acc_id = b.acc_id
		                    -- AND CC_NUMBER = 'BankServ'||A.TxnID
                            and cc_number = 'CNB'
                            || a.txnid  -- Added by Swamy for Ticket#7723
                               and fee_date = to_date(p_date, 'YYYYMMDD')
                    );

        exception
            when others then
                raise;
        end;

 	  -- Posting Employer Contribution --
        begin
            insert into income (
                change_num,
                acc_id,
                fee_date,
                fee_code,
                amount,
                pay_code,
                cc_number,
                note,
                amount_add,
                contributor_amount,
                contributor,
                transaction_type
            )
                select
                    change_seq.nextval,
                    c.acc_id,
                    to_date(p_date, 'YYYYMMDD'),
                    decode(deposittype, 1, 3, 2, 4,
                           3, 5, 4, 6, 5,
                           7),
                    to_number(employeecontrib),
                    5
		      -- , 'BankServ'||TxnID
		      -- , 'Bankserv Deposit generate '||sysdate
                    ,
                    'CNB' || txnid                          -- Added by Swamy for Ticket#7723
                    ,
                    'CNB Deposit generate ' || sysdate      -- Added by Swamy for Ticket#7723
                    ,
                    to_number(date_yyyymmddhhmmss),
                    totalamount,
                    b.entrp_id,
                    'I'
                from
                    bank_serv_external a,
                    account            b,
                    account            c
                where
                        a.accnum = b.acc_num
                    and b.entrp_id is not null
                    and c.acc_num = a.employercontrib
                    and bankservstatus = 'Approved'
                    and not exists (
                        select
                            *
                        from
                            income
                        where
                                acc_id = c.acc_id
                            and contributor = b.entrp_id
				    -- AND CC_NUMBER = 'BankServ'||A.TxnID
                            and cc_number = 'CNB'
                            || a.txnid    -- Added by Swamy for Ticket#7723
                               and fee_date = to_date(p_date, 'YYYYMMDD')
                    );

        exception
            when others then
                raise;
        end;
         -- Posting to deposit register
        insert into deposit_register (
            deposit_register_id,
            first_name,
            acc_num,
            check_number,
            check_amount,
            trans_date,
            status,
            posted_flag,
            entrp_id,
            acc_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                deposit_register_seq.nextval,
                name,
                acc_num,
                check_number,
                check_amount,
                trans_date,
                'EXISTING',
                'Y',
                entrp_id,
                acc_id,
                sysdate,
                0,
                sysdate,
                0
            from
                (
                    select distinct
                        to_char(to_date(p_date, 'YYYYMMDD'), 'MM/DD/YYYY') trans_date,
                        c.name,
                        b.acc_num
		      -- , 'BankServ'||TxnID CHECK_NUMBER
                        ,
                        'CNB' || txnid                                     check_number   -- Added by Swamy for Ticket#7723
                        ,
                        totalamount                                        check_amount,
                        b.entrp_id,
                        b.acc_id
                    from
                        bank_serv_external a,
                        account            b,
                        enterprise         c
                    where
                        employeeid is not null
                        and a.accnum = b.acc_num
                        and b.entrp_id is not null
                        and c.entrp_id = b.entrp_id
                        and bankservstatus = 'Approved'
                );

        insert into deposit_register (
            deposit_register_id,
            first_name,
            acc_num,
            acc_id,
            check_number,
            check_amount,
            trans_date,
            status,
            posted_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                deposit_register_seq.nextval,
                a.name,
                a.accnum,
                b.acc_id
		      -- , 'BankServ'||TxnID check_number
                ,
                'CNB' || txnid                                     check_number   -- Added by Swamy for Ticket#7723
                ,
                totalamount,
                to_char(to_date(p_date, 'YYYYMMDD'), 'MM/DD/YYYY') trans_date,
                'EXISTING',
                'Y',
                sysdate,
                0,
                sysdate,
                0
            from
                bank_serv_external a,
                account            b
            where
                employeeid is null
                and bankservstatus = 'Approved'
                and a.accnum = b.acc_num
                and b.pers_id is not null;

        insert into deposit_register (
            deposit_register_id,
            first_name,
            acc_num,
            check_number,
            check_amount,
            trans_date,
            status,
            posted_flag,
            entrp_id,
            acc_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                deposit_register_seq.nextval,
                name,
                acc_num,
                check_number,
                check_amount,
                trans_date,
                'EXISTING',
                'Y',
                entrp_id,
                acc_id,
                sysdate,
                0,
                sysdate,
                0
            from
                (
                    select distinct
                        to_char(to_date(p_date, 'YYYYMMDD'), 'MM/DD/YYYY') trans_date,
                        null                                               name,
                        a.accnum                                           acc_num
		      -- , 'BankServ'||TxnID CHECK_NUMBER
                        ,
                        'CNB' || txnid                                     check_number    -- Added by Swamy for Ticket#7723
                        ,
                        totalamount                                        check_amount,
                        null                                               entrp_id,
                        null                                               acc_id
                    from
                        bank_serv_external a
                    where
                        employeeid is not null
                        and not exists (
                            select
                                *
                            from
                                account b
                            where
                                a.accnum = b.acc_num
                        )
                        and bankservstatus = 'Approved'
                );

        insert into deposit_register (
            deposit_register_id,
            first_name,
            acc_num,
            acc_id,
            check_number,
            check_amount,
            trans_date,
            status,
            posted_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                deposit_register_seq.nextval,
                a.name                                             first_name,
                a.accnum                                           acc_num,
                null                                               acc_id
		      -- , 'BankServ'||TxnID check_number
                ,
                'CNB' || txnid                                     check_number   -- Added by Swamy for Ticket#7723
                ,
                totalamount,
                to_char(to_date(p_date, 'YYYYMMDD'), 'MM/DD/YYYY') trans_date,
                'EXISTING',
                'Y',
                sysdate,
                0,
                sysdate,
                0
            from
                bank_serv_external a
            where
                employeeid is null
                and bankservstatus = 'Approved'
                and not exists (
                    select
                        *
                    from
                        account b
                    where
                        a.accnum = b.acc_num
                );

    exception
        when l_exception then
            raise_application_error('-20000', 'Error ' || l_error_message);
        when others then
            raise;
    end;

    procedure assign_broker_to_account is
        l_entrp_id       number;
        l_pers_id        number;
        l_effective_date date;
    begin
        pc_sales_team.assign_to_house_account;
        for x in (
            select
                a.pers_id,
                a.broker_id,
                c.acc_num,
                a.effective_date
            from
                broker_assignments a,
                account            c,
                (
                    select
                        pers_id
                    from
                        broker_assignments c
                    where
                            broker_id <> 0
                        and entrp_id is null
                    group by
                        pers_id,
                        effective_date
                    having
                        count(distinct broker_id) > 1
                )                  b
            where
                    a.pers_id = b.pers_id
                and a.pers_id = c.pers_id (+)
                and a.broker_id = c.broker_id (+)
            order by
                1
        ) loop
            if x.acc_num is null then
                delete from broker_assignments
                where
                        broker_id = x.broker_id
                    and pers_id = x.pers_id;

            end if;
        end loop;

     /** set broker **/
        update account c
        set
            broker_id = (
                select
                    broker_id
                from
                    account a,
                    person  b
                where
                        c.pers_id = b.pers_id
                    and a.entrp_id = b.entrp_id
            ),
            last_update_date = sysdate,
            last_updated_by = 0,
            note = '**Broker assignment '
        where
                0 <> (
                    select
                        broker_id
                    from
                        account a,
                        person  b
                    where
                            c.pers_id = b.pers_id
                        and a.entrp_id = b.entrp_id
                )
            and pers_id is not null
            and broker_id = 0;

  /** if employer changed then we have to update broker too for the employee
      from the employer ***/
        update account c
        set
            broker_id = (
                select
                    broker_id
                from
                    account a,
                    person  b
                where
                        c.pers_id = b.pers_id
                    and a.entrp_id = b.entrp_id
            ),
            last_update_date = sysdate,
            last_updated_by = 0,
            note = '**Broker assignment '
        where
                broker_id <> (
                    select
                        broker_id
                    from
                        account a,
                        person  b
                    where
                            c.pers_id = b.pers_id
                        and a.entrp_id = b.entrp_id
                )
            and pers_id is not null
            and broker_id <> 0;

 -- Employee detached from employer
        update broker_assignments a
        set
            entrp_id = null,
            last_update_date = sysdate,
            last_updated_by = 0
        where
            entrp_id is not null
            and exists (
                select
                    pers_id
                from
                    person
                where
                    entrp_id is null
                    and person.pers_id = a.pers_id
            );

 -- Employee attached to an employer

        for x in (
            select
                b.pers_id,
                b.entrp_id,
                c.broker_id,
                c.salesrep_id
            from
                broker_assignments a,
                person             b,
                account            c
            where
                a.entrp_id is null
                and b.entrp_id is not null
                and a.pers_id = b.pers_id
                and b.entrp_id = c.entrp_id
        ) loop
            update broker_assignments a
            set
                entrp_id = x.entrp_id,
                broker_id = x.broker_id,
                effective_end_date = sysdate - 1
     --  ,   salesrep_id = x.salesrep_id
            where
                entrp_id is null
                and pers_id = x.pers_id
                and broker_id <> x.broker_id;

        end loop;
          -- Assign salesrep that have the employer
      -- For all the salsresp that have not bee assigned, get the broker's salesrep and assign
   /*
   FOR X IN ( SELECT  ACC_ID, ENTRP_ID,
                         ( select salesrep_id from broker where broker_id = account.broker_id ) slrep_id
                   FROM   ACCOUNT
                  WHERE   SALESREP_ID IS NULL
                  AND     entrp_id is not null
                  AND     broker_id <> 0)
   LOOP
            update account
              set  salesrep_id  = X.slrep_id
                 , last_update_date = SYSDATE
                  , last_updated_by  = 0
                  , note  = '**Salesrep assignment '
            where  salesrep_id is null AND broker_id <> 0 and entrp_id is not null
            and    entrp_id = x.entrp_id;

            pc_sales_team.assign_sales_team (P_ENTRP_ID   =>X.ENTRP_ID
                                            , P_ENTITY_TYPE => 'SALES_REP'
			                                      , P_ENTITY_ID   => X.slrep_id
			                                      , P_EFF_DATE    => SYSDATE
			                                      , P_USER_ID     => 0);

             update account c
            	set    salesrep_id = X.slrep_id
                 , last_update_date = SYSDATE
                 , last_updated_by  = 0
                 , note  = '**Salesrep assignment '
             where  pers_id is not null
	           and   salesrep_id is null AND broker_id <> 0
             AND   pers_id in ( select pers_id from person where entrp_id= x.entrp_id);

        END LOOP;*/
          -- For all the employers salsresp that have not bee assigned, get the employer's salesrep and assign
        for x in (
            select
                ee.acc_id,
                p.entrp_id,
                er.salesrep_id,
                er.acc_num
            from
                account er,
                person  p,
                account ee
            where
                er.salesrep_id is not null
                and er.entrp_id = p.entrp_id
                and ee.pers_id = p.pers_id
                and ee.salesrep_id is null
                and er.entrp_id is not null
        )
               --   AND     EE.BROKER_ID <> 0
               --   AND     ER.BROKER_ID <> 0)
         loop
            update account
            set
                salesrep_id = x.salesrep_id,
                last_update_date = sysdate,
                last_updated_by = 0,
                note = substr(note || '**Salesrep assignment ', 1, 2000)
            where
                salesrep_id is null
                and acc_id = x.acc_id;

        end loop;
 /** cleanup duplicates being created because of some updates **/

        delete from broker_assignments a
        where
            rowid > (
                select
                    min(rowid)
                from
                    broker_assignments x
                where
                        x.entrp_id = a.entrp_id
                    and x.broker_id = a.broker_id
                    and x.pers_id = a.pers_id
            );

        delete from broker_assignments a
        where
                rowid > (
                    select
                        min(rowid)
                    from
                        broker_assignments x
                    where
                        x.entrp_id is null
                        and x.broker_id = a.broker_id
                        and x.pers_id = a.pers_id
                )
            and a.entrp_id is null;

        insert into broker_assignments
            select
                broker_assignment_seq.nextval,
                a.broker_id,
                null,
                a.entrp_id,
                a.start_date,
                sysdate,
                1,
                sysdate,
                1,
                'A',
                null
            from
                account a
            where
                a.pers_id is null
                and not exists (
                    select
                        *
                    from
                        broker_assignments e
                    where
                            e.broker_id = a.broker_id
                        and e.entrp_id = a.entrp_id
                        and e.pers_id is null
                        and e.entrp_id is not null
                );

        insert into broker_assignments
            select
                broker_assignment_seq.nextval,
                d.broker_id,
                c.pers_id,
                c.entrp_id,
                d.effective_date,
                sysdate,
                1,
                sysdate,
                1,
                'A',
                null
            from
                account            a,
                person             c,
                broker_assignments d
            where
                    a.pers_id = c.pers_id
                and d.entrp_id = c.entrp_id
                and c.entrp_id is not null
                and d.pers_id is null
                and not exists (
                    select
                        *
                    from
                        broker_assignments e
                    where
                            e.broker_id = a.broker_id
                        and e.pers_id = c.pers_id
                );

        l_effective_date := null;

    /** Delete the duplicate assignments **/
        delete from broker_assignments a
        where
                rowid > (
                    select
                        min(rowid)
                    from
                        broker_assignments b
                    where
                        b.entrp_id is null
                        and a.pers_id = b.pers_id
                        and a.broker_id = b.broker_id
                        and a.effective_date = b.effective_date
                )
            and a.entrp_id is null;

        delete from broker_assignments a
        where
                rowid > (
                    select
                        min(rowid)
                    from
                        broker_assignments b
                    where
                        b.pers_id is null
                        and a.pers_id = b.pers_id
                        and a.broker_id = b.broker_id
                        and a.effective_date = b.effective_date
                )
            and a.pers_id is null;

    /** End date the old brokers for employers **/
        for x in (
            select
                broker_id,
                entrp_id,
                effective_date,
                effective_end_date
            from
                broker_assignments
            where
                entrp_id in (
                    select
                        entrp_id
                    from
                        broker_assignments
                    where
                        pers_id is null
                        and effective_end_date is null
                        and broker_id <> 0
                    group by
                        entrp_id
                    having
                        count(broker_id) > 1
                )
                and pers_id is null
            order by
                entrp_id,
                effective_date desc
        ) loop
            if l_entrp_id = x.entrp_id then
                update broker_assignments
                set
                    effective_end_date = l_effective_date - 1
                where
                        broker_id = x.broker_id
                    and entrp_id = x.entrp_id;

            else
                l_effective_date := x.effective_date;
                l_entrp_id := x.entrp_id;
            end if;
        end loop;
    /** End date the old brokers for person **/

        for x in (
            select
                broker_id,
                pers_id,
                effective_date,
                effective_end_date
            from
                broker_assignments
            where
                pers_id in (
                    select
                        pers_id
                    from
                        broker_assignments
                    where
                        entrp_id is not null
                        and broker_id <> 0
                        and effective_end_date is null
                    group by
                        pers_id
                    having
                        count(broker_id) > 1
                )
                and entrp_id is not null
            order by
                pers_id,
                effective_date desc
        ) loop
            if l_pers_id = x.pers_id then
                update broker_assignments
                set
                    effective_end_date = l_effective_date - 1
                where
                        broker_id = x.broker_id
                    and pers_id = x.pers_id;

            else
                l_effective_date := x.effective_date;
                l_pers_id := x.pers_id;
            end if;
        end loop;

        delete from broker_assignments
        where
            broker_assignment_id in (
                select
                    broker_assignment_id
                from
                    broker_assignments
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            broker_assignments
                        where
                            pers_id is not null
                            and broker_id <> 0
                            and effective_end_date is null
                        group by
                            pers_id
                        having
                            count(broker_id) > 1
                    )
                    and pers_id is not null
                    and entrp_id is null
            );

    end assign_broker_to_account;

    procedure process_broker_commissions is
    begin
       /*** update broker commission register ***/

        insert into broker_commission_register (
            broker_id,
            broker_lic,
            broker_rate,
            entrp_id,
            pers_id,
            acc_id,
            pay_date,
            amount,
            reason_code,
            change_num,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            account_type
        )
            select distinct
                ab.broker_id,
                (
                    select
                        nvl(broker_lic, 'SK' || broker_id)
                    from
                        broker a
                    where
                        a.broker_id = ab.broker_id
                ),
                (
                    select
                        broker_rate
                    from
                        broker a
                    where
                        a.broker_id = ab.broker_id
                ),
                ab.entrp_id,
                ab.pers_id,
                b.acc_id,
                case
                    when sysdate - pay_date > 2 then
                        sysdate
                    else
                        pay_date
                end pay_date,
                amount,
                reason_code,
                c.change_num,
                sysdate,
                - 1,
                sysdate,
                - 1,
                'HSA'
            from
                broker_assignments ab,
                account            b,
                payment            c,
                account            acc --Ticket#4639
            where
                    ab.pers_id = b.pers_id
                and b.acc_id = c.acc_id
                and trunc(c.pay_date) >= trunc(sysdate, 'YYYY') - 1
                and c.reason_code in ( 1, 2 )
                and c.pay_date >= trunc(ab.effective_date)
                and c.pay_date <= trunc(nvl(ab.effective_end_date, sysdate))
                and ab.broker_id <> '0'
                and b.account_type = 'HSA'
      /* For ticket#2574.Stop saving the information if the HSA individual doesn't have any employer attached to it.*/
                and ab.entrp_id is not null
            /*Ticket#4639*/ --Closed accounts will not contribute to broker commision
                and ab.entrp_id = acc.entrp_id
                and acc.account_status = 1
                and months_between(c.pay_date, b.start_date) <= 12 -- Added condition to not pay any commission 12 months from Start Date 04_09_2019
                and not exists (
                    select
                        *
                    from
                        broker_commission_register d
                    where
                        c.change_num = d.change_num
                );

    end process_broker_commissions;

    procedure fix_plan_code is
    begin
        update account
        set
            plan_code = 401
        where
            acc_num like 'FRB%'
            and plan_code <> 401;

    end;

    procedure fix_date is
    begin
        update balance_register
        set
            fee_date = to_date(to_char(fee_date, 'mm')
                               || '/'
                               || to_char(fee_date, 'dd')
                               || '/'
                               || to_char(sysdate, 'YYYY'),
        'mm/dd/yyyy')
        where
            to_char(fee_date, 'yyyy') = '00' || to_char(sysdate, 'YY');

        update income
        set
            fee_date = to_date(to_char(fee_date, 'mm')
                               || '/'
                               || to_char(fee_date, 'dd')
                               || '/'
                               || to_char(sysdate, 'YYYY'),
        'mm/dd/yyyy')
        where
            to_char(fee_date, 'yyyy') = '00' || to_char(sysdate, 'YY');

        update payment
        set
            pay_date = to_date(to_char(pay_date, 'mm')
                               || '/'
                               || to_char(pay_date, 'dd')
                               || '/'
                               || to_char(sysdate, 'YYYY'),
        'mm/dd/yyyy')
        where
            to_char(pay_date, 'yyyy') = '00' || to_char(sysdate, 'YY');

    end fix_date;

    procedure upload_debit_card_error is
    begin
        null;
    end upload_debit_card_error;

    procedure update_card_status is
    begin
        null;
    end update_card_status;

    procedure process_pending_edeposit is
    begin
        for x in (
            select
                *
            from
                income
            where
                    transaction_type = 'P'
                and num_business_days(fee_date, sysdate) > 3
        ) loop
            if ( x.fee_code <> 3
            or (
                x.fee_code = 3
                and x.contributor is not null
            ) ) then
                update income
                set
                    transaction_type = 'A'
                where
                        acc_id = x.acc_id
                    and change_num = x.change_num;

		   -- Added by Vanitha for 7920. insert HSA contribution processed event.
                if x.contributor is null then
                    pc_notification2.insert_events(
                        p_acc_id      => x.acc_id,
                        p_pers_id     => null,
                        p_event_name  => 'PAYROLL_CONTRB',
                        p_entity_type => 'INCOME',
                        p_entity_id   => x.change_num
                    );

                end if;

            end if;
        end loop;

        -- As per duarte, for initial contributions we want to make money available only after
        -- 10 business days because of the time it takes to fraud checking
        -- Change effective 7/8/2015
        -- commented and added by joshi to 30 days as per shavee request on 04/21/2025.
        for x in (
            select
                *
            from
                income
            where
                    transaction_type = 'P'
                and contributor is null
                and fee_code = 3
	               --AND    num_business_days(FEE_DATE,SYSDATE) > 10 )
                and num_business_days(fee_date, sysdate) > 30
        ) loop
            update income
            set
                transaction_type = 'A'
            where
                    acc_id = x.acc_id
                and change_num = x.change_num;

		   -- Added by Vanitha for 7920. insert HSA contribution processed event.
            pc_notification2.insert_events(
                p_acc_id      => x.acc_id,
                p_pers_id     => null,
                p_event_name  => 'PAYROLL_CONTRB',
                p_entity_type => 'INCOME',
                p_entity_id   => x.change_num
            );

        end loop;

    end process_pending_edeposit;

    procedure post_ach_deposits (
        p_transaction_id in number
    ) is
        l_list_bill number;
        l_acct_type varchar2(10);
        l_flat_fee  varchar2(1) := 'N';
    begin
        pc_log.log_error('PC_AUTO_PROCESS', 'Posting Individual Contribution');
        for x in (
            select
                account_type
            from
                ach_transfer_v
            where
                transaction_id = p_transaction_id
        ) loop
            l_acct_type := x.account_type;
        end loop;

        if l_acct_type in ( 'HSA', 'LSA' ) then
          /** Posting Individual Contribution ***/
            begin
                insert into income (
                    change_num,
                    acc_id,
                    fee_date,
                    fee_code,
                    amount,
                    pay_code,
                    cc_number,
                    note,
                    amount_add,
                    ee_fee_amount,
                    transaction_type
                )
                    select
                        change_seq.nextval,
                        acc_id,
                        transaction_date,
                        reason_code,
                        0,
                        a.pay_code
                  -- , decode(a.pay_code,3,'ACH'||transaction_id,'BankServ'||transaction_id)
                  -- , 'Bankserv Deposit generate '||sysdate
                        ,
                        decode(a.pay_code, 3, 'ACH' || transaction_id, 'CNB' || transaction_id)   -- Added by Swamy for Ticket#7723
                        ,
                        'CNB Deposit generate ' || sysdate                                   -- Added by Swamy for Ticket#7723
                        ,
                        nvl(amount, 0),
                        nvl(fee_amount, 0),
                        'P'
                    from
                        ach_transfer_v a
                    where
                        entrp_id is null
                        and transaction_type = 'C'
                        and status = 3
                        and upper(bankserv_status) = 'APPROVED'
                        and trunc(transaction_date) <= trunc(sysdate)
                        and pers_id is not null
                        and transaction_id = p_transaction_id
                        and not exists (
                            select
                                *
                            from
                                income
                            where
                                    income.acc_id = a.acc_id
                                -- AND CC_NUMBER = 'BankServ'||A.transaction_id
                                and cc_number = 'CNB'
                                || a.transaction_id   -- Added by Swamy for Ticket#7723
                                   and fee_date = a.transaction_date
                        );

            exception
                when others then
                    raise;
            end;
        end if;

        pc_log.log_error('PC_AUTO_PROCESS', 'Posting Employer Contribution');
 	  -- Posting Employer Contribution --
        begin
		/*  INSERT INTO INCOME
		  (     CHANGE_NUM
		       ,ACC_ID
		       ,FEE_DATE
		       ,FEE_CODE
		       ,AMOUNT
		       ,PAY_CODE
		       ,CC_NUMBER
		       ,NOTE
		       ,AMOUNT_ADD
		       ,EE_FEE_AMOUNT
		       ,ER_FEE_AMOUNT
		       ,CONTRIBUTOR_AMOUNT
		       ,CONTRIBUTOR
                       ,TRANSACTION_TYPE
		  )
		  SELECT CHANGE_SEQ.NEXTVAL
		       ,  acc_id
		       , transaction_date
		       , reason_code
		       , employer_contrib
		       , 5
		       , 'BankServ'||transaction_id
		       , 'Bankserv Deposit generate '||sysdate
		       , employee_contrib
		       , ee_fee_amount
		       , er_fee_amount
		       , total_amount
		       , entrp_id
           , 'I'
		  FROM ach_emp_detail_v A
		  WHERE status  = 3
      AND   transaction_type = 'C'
		  AND   UPPER(bankserv_status) = 'APPROVED'
		  AND   TRUNC(transaction_date) <= TRUNC(SYSDATE)
                  AND   transaction_id = p_transaction_id
		  AND   NOT EXISTS ( SELECT * FROM INCOME
		                     WHERE INCOME.ACC_ID = A.ACC_ID
		                     AND  INCOME.CONTRIBUTOR = A.entrp_id
				     AND INCOME.CC_NUMBER = 'BankServ'||A.transaction_id
				     AND INCOME.FEE_DATE = A.TRANSACTION_DATE);*/

            begin
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting Employer Deposits');
                if l_acct_type in ( 'HSA', 'LSA' ) then     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                    select
                        employer_deposit_seq.nextval
                    into l_list_bill
                    from
                        dual;

                    insert into employer_deposits (
                        employer_deposit_id,
                        entrp_id,
                        list_bill,
                        check_number,
                        check_amount,
                        check_date,
                        posted_balance,
                        remaining_balance,
                        fee_bucket_balance,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        note,
                        pay_code,
                        reason_code,
                        plan_type,
                        invoice_id
                    )
                        select
                            l_list_bill,
                            entrp_id,
                            l_list_bill
           -- ,'BankServ'||transaction_id
                            ,
                            'CNB' || transaction_id   -- Added by Swamy for Ticket#7723
                            ,
                            total_amount,
                            transaction_date,
                            total_amount,
                            0,
                            fee_amount,
                            0,
                            sysdate,
                            0,
                            sysdate,
                            'Inserted from ACH Process',
                            pay_code,
                            reason_code,
                            plan_type,
                            invoice_id
                        from
                            ach_transfer_v x
                        where
                                transaction_id = p_transaction_id
                            and entrp_id is not null
       --and invoice_id IS NULL /*Ticket#7391 */
                            and transaction_type = 'C'
                            and not exists (
                                select
                                    *
                                from
                                    employer_deposits a
                                where
                                    a.invoice_id = x.invoice_id
                            );

                else
                    select
                        employer_deposit_seq.nextval
                    into l_list_bill
                    from
                        dual;

                    insert into employer_deposits (
                        employer_deposit_id,
                        entrp_id,
                        list_bill,
                        check_number,
                        check_amount,
                        check_date,
                        posted_balance,
                        remaining_balance,
                        fee_bucket_balance,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        note,
                        pay_code,
                        reason_code,
                        plan_type,
                        invoice_id
                    )
                        select
                            l_list_bill,
                            entrp_id,
                            l_list_bill
           -- ,'BankServ'||transaction_id
                            ,
                            'CNB' || transaction_id     -- Added by Swamy for Ticket#7723
                            ,
                            total_amount,
                            transaction_date,
                            total_amount,
                            0,
                            fee_amount,
                            0,
                            sysdate,
                            0,
                            sysdate,
                            'Inserted from ACH Process',
                            pay_code,
                            reason_code,
                            plan_type,
                            invoice_id
                        from
                            ach_transfer_v x
                        where
                                transaction_id = p_transaction_id
                            and entrp_id is not null
                            and invoice_id is null
                            and transaction_type = 'C'
                            and not exists (
                                select
                                    *
                                from
                                    employer_deposits a
                                where
                                    a.invoice_id = x.invoice_id
                            );

                end if;

                pc_log.log_error('PC_AUTO_PROCESS', 'Posting to Individuals');
                for x in (
                    select
                        transaction_id,
                        a.acc_id,
                        acct_id,
                        transaction_date,
                        reason_code,
                        employer_contrib,
                        a.pay_code
      -- , decode(a.pay_code,3,'ACH'||transaction_id,'BankServ'||transaction_id) cc_number
      -- , 'Bankserv Deposit generate '||sysdate
                        ,
                        decode(a.pay_code, 3, 'ACH' || transaction_id, 'CNB' || transaction_id) cc_number   -- Added by Swamy for Ticket#7723
                        ,
                        'CNB Deposit generate ' || sysdate                                             -- Added by Swamy for Ticket#7723
                        ,
                        employee_contrib,
                        ee_fee_amount,
                        er_fee_amount,
                        total_amount,
                        b.entrp_id,
                        'I'
                    from
                        ach_emp_detail_v a,
                        account          b
                    where
                            status = 3
                        and transaction_type = 'C'
                        and upper(bankserv_status) = 'APPROVED'
                        and trunc(transaction_date) <= trunc(sysdate)
                        and transaction_id = p_transaction_id
                        and a.group_acc_id = b.acc_id
                        and not exists (
                            select
                                *
                            from
                                income
                            where
                                    income.acc_id = a.acc_id
                                and income.contributor = b.entrp_id
		    -- AND INCOME.CC_NUMBER IN ('BankServ'||A.transaction_id,'ACH'||A.transaction_id)
                                and income.cc_number in ( 'CNB' || a.transaction_id, 'ACH' || a.transaction_id )           -- Added by Swamy for Ticket#7723
                                and income.fee_date = a.transaction_date
                        )
                ) loop
                    insert into income (
                        change_num,
                        acc_id,
                        fee_date,
                        fee_code,
                        amount,
                        pay_code,
                        cc_number,
                        note,
                        amount_add,
                        ee_fee_amount,
                        er_fee_amount,
                        contributor_amount,
                        contributor,
                        transaction_type,
                        list_bill
                    ) values ( change_seq.nextval,
                               x.acc_id,
                               x.transaction_date,
                               x.reason_code,
                               nvl(x.employer_contrib, 0),
                               x.pay_code,
                               x.cc_number
             --  , 'Bankserv Deposit generate '||sysdate
                               ,
                               'CNB Deposit generate ' || sysdate    -- Added by Swamy for Ticket#7723
                               ,
                               nvl(x.employee_contrib, 0),
                               nvl(x.ee_fee_amount, 0),
                               nvl(x.er_fee_amount, 0),
                               nvl(x.total_amount, 0),
                               x.entrp_id,
                               'I',
                               l_list_bill );

                end loop;

                pc_log.log_error('PC_AUTO_PROCESS', 'Posting to employer payment');
                insert into employer_payments (
                    employer_payment_id,
                    entrp_id,
                    check_amount,
                    creation_date
        --,CREATED_BY
                    ,
                    last_update_date
        --,LAST_UPDATED_BY
        --,NOTE
                    ,
                    check_date,
                    check_number,
                    bank_acct_id,
                    payment_register_id,
                    list_bill,
                    reason_code,
                    transaction_date,
                    plan_type,
                    pay_code,
                    invoice_id,
                    note
                )
                    select
                        employer_payments_seq.nextval,
                        x.entrp_id,
                        x.fee_amount,
                        sysdate
        --,p_user_id
                        ,
                        sysdate,
                        sysdate,
                        p_transaction_id
        --,p_user_id
        --,note
                        ,
                        x.bank_acct_id,
                        null,
                        null,
                        x.reason_code,
                        x.transaction_date,
                        x.plan_type,
                        x.pay_code,
                        nvl(x.invoice_id, p_transaction_id)
      --  ,b.note||': Payment through Bank Serv : Transaction_id '||p_transaction_id
                        ,
                        b.note
                        || ': Payment through CNB : Transaction_id '
                        || p_transaction_id       -- Added by Swamy for Ticket#7723
                    from
                        ach_transfer_v     x,
                        ach_upload_staging b
                    where
                            x.transaction_id = p_transaction_id
                        and x.transaction_id = b.transaction_id
                        and x.transaction_type = 'F'
                        and x.status = 3
                        and upper(x.bankserv_status) = 'APPROVED'
                        and trunc(x.transaction_date) <= trunc(sysdate + 1)
                        and not exists (
                            select
                                *
                            from
                                employer_payments a
                            where
                                a.invoice_id = x.invoice_id
                        );

                pc_log.log_error('PC_AUTO_PROCESS', 'Posting to invoice');

     /*Ticket#7391 */
                for x in (
                    select
                        plan_type,
                        invoice_id,
                        total_amount
                    from
                        ach_transfer
                    where
                        transaction_id = p_transaction_id
                ) loop
                    pc_log.log_error('PC_AUTO_PROCESS', 'Posting to invoice x.plan_type ' || x.plan_type);
                    if x.plan_type = 'HSA' then
                        update ar_invoice
                        set
                            status = 'POSTED',
                            paid_amount = x.total_amount,
                            pending_amount = 0
                        where
                            invoice_id = x.invoice_id;

                    elsif x.plan_type = 'LSA' then     -- LSA Added by Swamy for Ticket#9912
            -- Added by Swamy for Ticket#11047 on 09/05/2022
                        l_flat_fee := 'N';
                        for k in (
                            select
                                count(*) cnt
                            from
                                ar_invoice_lines arl,
                                pay_reason       pr
                            where
                                    arl.rate_code = pr.reason_code
                                and pr.reason_mapping = 1
                                and arl.invoice_id = x.invoice_id
                        ) loop
                            if nvl(k.cnt, 0) > 0 then
                                l_flat_fee := 'Y';
                            end if;
                        end loop;

                        pc_log.log_error('PC_AUTO_PROCESS', 'Posting to invoice l_flat_fee ' || l_flat_fee);
                        if l_flat_fee = 'N' then
                            update ar_invoice
                            set
                                status = 'POSTED',
                                paid_amount = x.total_amount,
                                pending_amount = 0
                            where
                                invoice_id = x.invoice_id;

                        else
                            pc_log.log_error('PC_AUTO_PROCESS', 'calling pc_invoice.post_invoice p_transaction_id ' || p_transaction_id
                            );
                            pc_invoice.post_invoice(p_transaction_id);
                        end if;
            -- End of addition for Ticket#11047 on 09/05/2022
                    else
                        pc_invoice.post_invoice(p_transaction_id);
                    end if;

                end loop;

            end;
        exception
            when others then
                raise;
        end;

        pc_log.log_error('PC_AUTO_PROCESS', 'Posting deposit register');
         -- Posting to deposit register

    exception
        when others then
            raise;
    end post_ach_deposits;

    procedure inactivate_scheduler_detail is
    begin
        update scheduler_details
        set
            status = 'I',
            last_updated_date = sysdate
        where
                status = 'A'
            and trunc(effective_end_date) = trunc(sysdate);

    end inactivate_scheduler_detail;

    procedure generate_ach_upload is

        g_destination      constant varchar2(30) := '121102036';
        g_origin           constant varchar2(30) := '121102036';
        g_bank_name        constant varchar2(30) := 'THE MECHANICS BANK';
        g_company_name     constant varchar2(30) := 'STERLING HEALTH';
        g_data             constant varchar2(30) := 'ONLINE PAY'
                                        || to_char(sysdate - 1, 'YYYY-MM-DD');
        g_taxid            constant varchar2(10) := '84-1637046';
        g_transaction_type constant varchar2(10) := 'ACC_CLAIMS';
        l_file_header      varchar2(94);
        l_batch_header     varchar2(94);
        l_line_count       number := 0;
        l_total_amount     number := 0;
        l_file_control     varchar2(94);
        l_batch_control    varchar2(94);
        l_file_end         varchar2(94);
    begin
        l_file_header := '101 '
                         || g_destination
                         || ' '
                         || g_origin
                         || to_char(sysdate, 'YYMMDD')
                         || to_char(sysdate, 'HHMI')
                         || 'A094101'
                         || lpad(g_bank_name, 23, ' ')
                         || lpad(g_bank_name, 23, ' ')
                         || lpad(' ', 8, ' ');

        l_batch_header := '5200'
                          || lpad(g_company_name, 16, ' ')
                          || lpad(g_data, 20, ' ')
                          || g_taxid
                          || 'PPD'
                          || g_transaction_type
                          || to_char(sysdate, 'YYMMDD')
                          || to_char(sysdate + 1, 'YYMMDD')
                          || lpad(' ', 3, ' ')
                          || '1'
                          || g_destination
                          || lpad(demo_users_seq.nextval, 6, '0');

        dbms_output.put_line(' file header '
                             || l_file_header
                             || length(l_file_header));
        dbms_output.put_line(' file header '
                             || l_batch_header
                             || length(l_batch_header));

 /*  FOR X IN ( SELECT  '822'||routing_number||RPAD(account_number,17,' ')||LPAD(REPLACE(AMOUNT,'.'),10,'0')||
                      RPAD(REPLACE(ACC_NUM,'.'),15,' ')||RPAD(SUBSTR(FIRST_NAME||' '||LAST_NAME,1,22),22,' ')
		      ||'  0'||SUBSTR(g_origin,1,8)||LPAD(ROWNUM,7,'0') LINE
                   , amount
               FROM   ONLINE_DISB_EXTERNAL WHERE routing_number IS NOT NULL AND ACCOUNT_NUMBER IS NOT NULL)
   LOOP
       dbms_output.put_line(' line '||x.line);
       l_line_count := l_line_count+1;
       l_total_amount := l_total_amount+x.amount;
   END LOOP;*/
        l_batch_control := '8200'
                           || lpad(l_line_count, 6, '0')
                           || '1520398730'
                           || lpad(
            replace(l_total_amount, '.'),
            12,
            '0'
        )
                           || lpad(
            replace(l_total_amount, '.'),
            12,
            '0'
        )
                           || g_taxid
                           || lpad(' ', 25, ' ')
                           || g_destination
                           || lpad(demo_users_seq.currval, 6, '0');

        dbms_output.put_line(' batch control '
                             || l_batch_control
                             || length(l_batch_control));
        l_file_control := '9'
                          || lpad(1, 6, '0')
                          || lpad(9, 6, '0')
                          || lpad(l_line_count, 8, '0')
                          || '1520398730'
                          || lpad(
            replace(l_total_amount, '.'),
            12,
            '0'
        )
                          || lpad(
            replace(l_total_amount, '.'),
            12,
            '0'
        )
                          || lpad(' ', 39, ' ');

        dbms_output.put_line(' file control '
                             || l_file_control
                             || length(l_file_control));
        l_file_end := '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999';
    end generate_ach_upload;

 -- Below Procedure is added by Swamy for Ticket#7723 (Nacha)
    procedure nacha_file as
        l_file_name varchar2(3200);
    begin
        for k in (
            select distinct
                ( decode(n.account_type, 'FEE_PAY', null, n.account_type) ) account_type
            from
                nacha_data n
        ) loop
            pc_log.log_error('Begining of PC_Auto_Process.NACHA_FILE', 'k.ACCOUNT_TYPE := ' || k.account_type);
	   -- PC_Auto_Process.Generate_Nacha_File(K.Account_Type,L_FILE_NAME);    -- Commented by Swamy for Ticket#11701
            pc_auto_process.generate_nacha_file_employee(k.account_type, l_file_name);  -- Added by Swamy for Ticket#11701
            pc_auto_process.generate_nacha_file_employer(k.account_type, l_file_name);  -- Added by Swamy for Ticket#11701
            pc_auto_process.generate_nacha_file_fee(k.account_type, l_file_name);  -- Added by Swamy for Ticket#11701
	   -- Added by Joshi for 12748- Sprint 59: ACH Pull for FSA/HRA Claims
            if k.account_type in ( 'FSA', 'HRA' ) then
                pc_auto_process.generate_nacha_file_for_employee_payment(k.account_type, l_file_name);
            end if;

        end loop;
    exception
        when others then
            pc_log.log_error('PC_Auto_Process.NACHA_FILE Error',
                             'Others :=' || sqlerrm(sqlcode));
    end nacha_file;

/*PROCEDURE GENERATE_NACHA_FILE(P_ACCOUNT_TYPE IN VARCHAR2 DEFAULT NULL)
AS
   G_DESTINATION       VARCHAR2(30);
   G_ORIGIN            VARCHAR2(30) ;
   G_DEST_BANK         VARCHAR2(30);
   G_COMPANY_NAME      VARCHAR2(30);
   G_DATA              VARCHAR2(30);
   G_DATA1             VARCHAR2(30);
   G_TAXID             VARCHAR2(30);
   G_TRANSACTION_TYPE  VARCHAR2(30);
   G_SERVICE_CLASS     VARCHAR2(30);
   G_STANDARD_ENTRY    VARCHAR2(30);
   L_BATCH_NUMBER      NUMBER;
   L_FILE_HEADER       VARCHAR2(94);
   L_BATCH_HEADER      VARCHAR2(150);
   L_CCD_RECORD        VARCHAR2(94);
   L_CCD_RECORD2       VARCHAR2(94);
   L_CRLF2             CONSTANT VARCHAR2(2) := CHR(13); -- Carriage Return

   L_LINE_COUNT       NUMBER := 0;
   L_FILE_CONTROL     VARCHAR2(94);
   L_BATCH_CONTROL    VARCHAR2(96);
   L_FILE_END         VARCHAR2(94);
   L_ENTRY_COUNT      NUMBER;
   L_DEBIT_AMOUNT     NUMBER := 0;
   L_CREDIT_AMOUNT    NUMBER := 0;
   L_ENTRY_HASH       NUMBER := 0;
   L_TOTAL_AMOUNT     NUMBER := 0;
   L_REC_COUNT        NUMBER := 0;
   V_COUNT            NUMBER := 0;
   L_Detail_Addenda_Count NUMBER := 0;
   L_Block_Count      NUMBER := 0;

   L_UTL_ID           UTL_FILE.FILE_TYPE;
   L_FILE_NAME        VARCHAR2(3200);

   TYPE CLAIM_TYP IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   CLAIM_TAB CLAIM_TYP;

BEGIN
 pc_log.log_error('Begining of PC_Auto_Process.GENERATE_NACHA_FILE','P_ACCOUNT_TYPE := '||P_ACCOUNT_TYPE);

 -- Assign proper values for NACHA variables.
 IF P_ACCOUNT_TYPE IS NOT NULL THEN  --When acct type is specified , we generate contributio/disbursements file ELSE we just create one file for Fee payments
    --create separate file for contributions and disbursements
    L_Block_Count := 0;
    -- Assign proper values for NACHA variables.
    FOR X IN (SELECT * FROM NACHA_DATA WHERE account_type = P_ACCOUNT_TYPE) LOOP
      G_DESTINATION    := X.DESTINATION;
      G_ORIGIN         := X.ORIGIN;
      G_DEST_BANK      := X.DEST_BANK;
      G_COMPANY_NAME   := X.COMPANY_NAME;
      G_DATA           := X.DATA;
      G_DATA1          := X.DATA1;
      G_TAXID          := X.TAXID ;
      G_TRANSACTION_TYPE:= X.TRANSACTION_TYPE;
      G_SERVICE_CLASS  := X.SERVICE_CLASS;
      G_STANDARD_ENTRY := X.STANDARD_ENTRY;
    END LOOP;

    SELECT COUNT(*)
      INTO V_COUNT
      FROM ACH_NACHA_V N
     WHERE N.STATUS in (1,2)
       AND N.AMOUNT > 0
       AND TRUNC(N.TRANSACTION_DATE) <= TRUNC(SYSDATE)
       AND N.ACCOUNT_TYPE = P_ACCOUNT_TYPE
       AND N.TRANSACTION_TYPE = 'C'
	   AND NOT EXISTS (SELECT 1 FROM Nacha_Process_Log P WHERE P.Transaction_Id = N.Transaction_Id);

      SELECT NACHA_SEQ.NEXTVAL
        INTO L_BATCH_NUMBER
        FROM DUAL;

    pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE',' L_BATCH_NUMBER := '||L_BATCH_NUMBER||' V_COUNT :='||V_COUNT);
    IF V_COUNT > 0 THEN
       --Generate Filenames
       L_FILE_NAME    := 'DAILY_'||P_account_type||'_ACH_'||'CONTRIB_'||L_BATCH_NUMBER||'_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.ach';

       UPDATE EXTERNAL_FILES
          SET FILE_NAME = L_FILE_NAME
        WHERE FILE_ID = L_BATCH_NUMBER;

       L_UTL_ID       := UTL_FILE.FOPEN( 'BANK_SERV_DIR', L_FILE_NAME, 'w' );

       L_FILE_HEADER := '101 '
                    ||RPAD(G_DESTINATION,9,' ')
                    ||LPAD(G_TAXID,10,'0')
                    ||TO_CHAR(SYSDATE,'YYMMDD')
                    ||TO_CHAR(SYSDATE,'HHMM')
                    ||'A'
                    ||'094'
                    ||'10'
                    ||'1'
                    ||RPAD(G_DEST_BANK,23,' ')
                    ||RPAD(G_COMPANY_NAME,23,' ')
                    ||'        ';

       L_Block_Count := L_Block_Count + 1;  -- Count of Header Record

       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                         , BUFFER => L_FILE_HEADER||L_CRLF2);

       L_BATCH_HEADER := '5'
                     ||G_SERVICE_CLASS
                     ||RPAD(G_COMPANY_NAME,16,' ')
                     ||RPAD(G_DATA,20,' ')  --Company discretionary data
                     ||G_DATA1    -- Company ID
                     ||'CCD'
                     ||RPAD(G_TRANSACTION_TYPE,10,' ')  --Company Entry desc
                     ||'      ' --Company desc date
                     ||TO_CHAR(SYSDATE,'YYMMDD')
                     ||RPAD(' ',3,' ')
                     ||'1'
                     ||SUBSTR(G_DESTINATION,1,8)
                     ||LPAD(L_BATCH_NUMBER,7,'0');

       L_Block_Count := L_Block_Count + 1;  -- Count of Batch Header Record

       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_BATCH_HEADER||L_CRLF2);

       L_ENTRY_COUNT   := 0;
       L_DEBIT_AMOUNT  := 0;
       L_CREDIT_AMOUNT := 0;
       L_Detail_Addenda_Count := 0;

       --Cash Concentration or Disbursement entry
       FOR X IN ( SELECT  SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),1,8) RECEIVING_DFI_NUM
                       ,  DECODE(SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),9,1),NULL,' ',SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),9,1)) CHECK_DIGIT
                       ,  SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),1,8) ROUTING_NUM
                       ,  RPAD(BANK_ACCT_NUM,17,' ')   ACCOUNT_NUMBER
                       ,  REPLACE(REPLACE(TO_CHAR(AMOUNT, '9999999.99'), '.', ''),' ','0') TOTAL_AMOUNT
                       ,  CASE WHEN TRANSACTION_TYPE = 'C' THEN
                                    DECODE(BANK_ACCT_TYPE,'C',27,37)
                               WHEN TRANSACTION_TYPE = 'D' THEN
                                    DECODE(BANK_ACCT_TYPE,'C',22,32)
                          END TRANSACTION_CODE
                       ,  AMOUNT
                       ,  TRANSACTION_TYPE
                       ,  SUBSTR(RPAD(PERSONFNAME||NVL(PERSONLNAME,''),22,' '),1,22) NAME
                       ,  RPAD(TRANSACTION_ID,15,' ') TRANSACTION_ID
                       ,  LPAD(ACC_NUM,15,' ') ACC_NUM
                       ,  CLAIM_ID
                       ,  PERSONFNAME
                       ,  PERSONLNAME
                       ,  PLAN_TYPE
                    FROM ACH_NACHA_V N
                   WHERE N.STATUS in (1,2)
                   AND TRUNC(N.TRANSACTION_DATE) <= TRUNC(SYSDATE)
                   AND N.ACCOUNT_TYPE = P_ACCOUNT_TYPE
                   AND N.TRANSACTION_TYPE = 'C'
                   AND N.AMOUNT > 0
				   AND NOT EXISTS (SELECT 1 FROM Nacha_Process_Log P WHERE P.Transaction_Id = N.Transaction_Id ))
      LOOP
         L_CCD_RECORD := '6';
         L_LINE_COUNT := NACHA_DETAIL_SEQ.NEXTVAL;
         L_Detail_Addenda_Count := L_Detail_Addenda_Count + 1;
         L_Block_Count := L_Block_Count + 1;  -- Count of Detail Record

         L_CCD_RECORD := L_CCD_RECORD||X.TRANSACTION_CODE||LPAD(X.RECEIVING_DFI_NUM,8,' ')
                         ||LPAD(X.CHECK_DIGIT,1,' ')||X.ACCOUNT_NUMBER||LPAD(REPLACE(X.TOTAL_AMOUNT,'.'),10,0)||X.TRANSACTION_ID
                         ||X.NAME||'  '||'0'||SUBSTR(G_DESTINATION,1,8)||L_LINE_COUNT;

         IF X.TRANSACTION_TYPE = 'C' THEN
            L_DEBIT_AMOUNT := L_DEBIT_AMOUNT+NVL(X.AMOUNT,0);
         END IF;

         L_ENTRY_COUNT   := L_ENTRY_COUNT+1;
         L_ENTRY_HASH    := L_ENTRY_HASH+X.RECEIVING_DFI_NUM;

         UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                          , BUFFER => L_CCD_RECORD||L_CRLF2);

          L_REC_COUNT := L_REC_COUNT + 1;

          CLAIM_TAB(L_REC_COUNT) := X.CLAIM_ID;

          INSERT INTO NACHA_PROCESS_LOG
		              (ACCOUNT_TYPE    ,
                       TRANSACTION_TYPE,
                       TRANSACTION_ID  ,
                       ACC_NUM         ,
                       AMOUNT          ,
                       TRACE_NUMBER    ,
                       PROCESSED_DATE  ,
                       BATCH_NUMBER    ,
                       FILE_NAME       ,
                       FLG_PROCESSED   ,
                       FIRST_NAME      ,
                       LAST_NAME       ,
                       PLAN_TYPE       ,
                       CLAIM_ID
                      )
               VALUES(P_ACCOUNT_TYPE   ,
                      X.TRANSACTION_TYPE,
                      X.TRANSACTION_ID,
                      X.ACC_NUM     ,
                      X.AMOUNT      ,
                      L_LINE_COUNT  ,
                      TRUNC(SYSDATE),
                      L_BATCH_NUMBER,
                      L_FILE_NAME  ,
                      'N'          ,
                      X.PERSONFNAME,
                      X.PERSONLNAME,
                      X.PLAN_TYPE  ,
                      X.CLAIM_ID
                     );

         -- Updating the Status to Processing
		 UPDATE Ach_Transfer
             SET Status = '4'
           WHERE Transaction_Id = X.Transaction_Id
             AND Status In ('1','2');
      END LOOP;

      dbms_output.put_line('Debit Amount '||L_DEBIT_AMOUNT||' Credit Amount '||L_Credit_AMOUNT);

      L_BATCH_CONTROL := '8'
                     ||G_SERVICE_CLASS
                     ||LPAD(L_ENTRY_COUNT,6,'0')
                     ||LPAD(L_ENTRY_HASH,10,'0')
                     ||LPAD(REPLACE(REPLACE(TO_CHAR(L_DEBIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                     ||LPAD(REPLACE(REPLACE(TO_CHAR(L_CREDIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                     ||G_DATA1    -- Company ID
                     ||LPAD(' ',25,' ')
                     ||SUBSTR(G_DESTINATION,1,8)
                     ||LPAD(L_BATCH_NUMBER,7,'0');

       L_Block_Count := L_Block_Count + 1;  -- Count of Batch Control Record

       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_BATCH_CONTROL||L_CRLF2);

       L_Block_Count := L_Block_Count + 1;  -- Count of File Control Record

       L_Block_Count := ceil(L_Block_Count/10);  -- Divide by 10 and Roundup to the nearest integer , If there are 11 records, then the Block count should be 2.

       L_FILE_CONTROL := '9'
                      ||LPAD(1,6,'0')
                      ||LPAD(L_Block_Count,6,'0')
                      ||LPAD(L_Detail_Addenda_Count,8,'0')
                      ||LPAD(L_ENTRY_HASH,10,'0')
                      ||LPAD(REPLACE(REPLACE(TO_CHAR(L_DEBIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                      ||LPAD(REPLACE(REPLACE(TO_CHAR(L_CREDIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                      ||LPAD(' ',39,' ');

       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_FILE_CONTROL||L_CRLF2);

       UTL_FILE.FCLOSE(FILE => L_UTL_ID);


        UPDATE EXTERNAL_FILES
           SET RESULT_FLAG = 'Y'
         WHERE FILE_NAME = L_FILE_NAME
           AND FILE_ACTION = 'ACH_FILE';

     -- Send the Nacha file details to Finance Department as an attachmet.
     Pc_Notifications.Notify_Nacha_Result(P_Account_Type);

     COMMIT;
   END IF;

   DBMS_OUTPUT.PUT_LINE(' Contribution File created successfully');
  /*
    --Create Disbursements file
    --create separate file for contributions and disbursements
     SELECT COUNT(*)
       INTO V_COUNT
       FROM ACH_NACHA_V N
      WHERE N.STATUS in (1,2)
        AND N.AMOUNT > 0
        AND TRUNC(N.TRANSACTION_DATE) <= TRUNC(SYSDATE)
        AND N.ACCOUNT_TYPE = P_ACCOUNT_TYPE
        AND N.TRANSACTION_TYPE = 'D'
		AND NOT EXISTS (SELECT 1 FROM Nacha_Process_Log P WHERE P.Transaction_Id = N.Transaction_Id);

      SELECT NACHA_SEQ.NEXTVAL
        INTO L_BATCH_NUMBER
        FROM DUAL;

   IF V_COUNT > 0 THEN

      L_Block_Count := 0;
      --Generate Filenames
      L_FILE_NAME    := 'DAILY_'||P_account_type||'_ACH_'||'DISB_'||L_BATCH_NUMBER||'_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.ach';

      UPDATE EXTERNAL_FILES
         SET FILE_NAME = L_FILE_NAME
       WHERE FILE_ID = L_BATCH_NUMBER;

      L_UTL_ID       := UTL_FILE.FOPEN( 'BANK_SERV_DIR', L_FILE_NAME, 'w' );

      L_FILE_HEADER := '101 '
                    ||RPAD(G_DESTINATION,9,' ')
                    ||LPAD(G_TAXID,10,'0')
                    ||TO_CHAR(SYSDATE,'YYMMDD')
                    ||TO_CHAR(SYSDATE,'HHMM')
                    ||'A'
                    ||'094'
                    ||'10'
                    ||'1'
                    ||RPAD(G_DEST_BANK,23,' ')
                    ||RPAD(G_COMPANY_NAME,23,' ')
                    ||'        ';

      L_Block_Count := L_Block_Count + 1;  -- Count of Header Record

      UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                       , BUFFER => L_FILE_HEADER||L_CRLF2);

       L_BATCH_HEADER := '5'
                     ||G_SERVICE_CLASS
                     ||RPAD(G_COMPANY_NAME,16,' ')
                     ||RPAD(G_DATA,20,' ')  --Company discretionary data
                     ||G_DATA1    -- Company ID
                     ||'CCD'
                     ||RPAD(G_TRANSACTION_TYPE,10,' ')  --Company Entry desc
                     ||'      ' --Company desc date
                     ||TO_CHAR(SYSDATE,'YYMMDD')
                     ||RPAD(' ',3,' ')
                     ||'1'
                     ||SUBSTR(G_DESTINATION,1,8)
                     ||LPAD(L_BATCH_NUMBER,7,'0');

       L_Block_Count := L_Block_Count + 1;  -- Count of Batch Header Record

       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_BATCH_HEADER||L_CRLF2);

       L_ENTRY_COUNT   := 0;
       L_DEBIT_AMOUNT  := 0;
       L_CREDIT_AMOUNT := 0;
       L_LINE_COUNT    := 0;  -- added by swamy
       L_ENTRY_HASH    := 0;  -- added by swamy
       L_Detail_Addenda_Count := 0;

       --Cash Concentration or Disbursement entry
       FOR X IN ( SELECT  SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),1,8) RECEIVING_DFI_NUM
                       ,  DECODE(SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),9,1),NULL,' ',SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),9,1)) CHECK_DIGIT
                       ,  SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),1,8) ROUTING_NUM
                       ,  RPAD(BANK_ACCT_NUM,17,' ')   ACCOUNT_NUMBER
                       ,  REPLACE(REPLACE(TO_CHAR(AMOUNT, '9999999.99'), '.', ''),' ','0') TOTAL_AMOUNT
                       ,  CASE WHEN TRANSACTION_TYPE = 'C' THEN
                                    DECODE(BANK_ACCT_TYPE,'C',27,37)
                               WHEN TRANSACTION_TYPE = 'D' THEN
                                    DECODE(BANK_ACCT_TYPE,'C',22,32)
                          END TRANSACTION_CODE
                       ,  AMOUNT
                       ,  TRANSACTION_TYPE
                       ,  SUBSTR(RPAD(PERSONFNAME||NVL(PERSONLNAME,''),22,' '),1,22) NAME
                       ,  RPAD(TRANSACTION_ID,15,' ') TRANSACTION_ID
                       ,  LPAD(ACC_NUM,15,' ') ACC_NUM
                       ,  CLAIM_ID
                    FROM ACH_NACHA_V N
                   WHERE N.STATUS in (1,2)
                   AND TRUNC(N.TRANSACTION_DATE) <= TRUNC(SYSDATE)
                    AND N.ACCOUNT_TYPE = P_ACCOUNT_TYPE
                    AND N.TRANSACTION_TYPE = 'D'
                    AND N.AMOUNT > 0
					AND NOT EXISTS (SELECT 1 FROM Nacha_Process_Log P WHERE P.Transaction_Id = N.Transaction_Id))
      LOOP
         L_CCD_RECORD := '6';
         L_LINE_COUNT := NACHA_DETAIL_SEQ.NEXTVAL;
         L_Detail_Addenda_Count := L_Detail_Addenda_Count + 1;
         L_Block_Count := L_Block_Count + 1;  -- Count of Detail Record

         L_CCD_RECORD := L_CCD_RECORD||X.TRANSACTION_CODE||LPAD(X.RECEIVING_DFI_NUM,8,' ')
                         ||LPAD(X.CHECK_DIGIT,1,' ')||X.ACCOUNT_NUMBER||LPAD(REPLACE(X.TOTAL_AMOUNT,'.'),10,0)||X.TRANSACTION_ID
                         ||X.NAME||'  '||'0'||SUBSTR(G_DESTINATION,1,8)||L_LINE_COUNT;-- LPAD(L_LINE_COUNT,7,'0');

        IF X.TRANSACTION_TYPE = 'D' THEN
           L_CREDIT_AMOUNT  := L_CREDIT_AMOUNT+NVL(X.AMOUNT,0);
        END IF;

         L_ENTRY_COUNT   := L_ENTRY_COUNT+1;
         L_ENTRY_HASH    := L_ENTRY_HASH+X.RECEIVING_DFI_NUM;

         UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                          , BUFFER => L_CCD_RECORD||L_CRLF2);

          L_REC_COUNT := L_REC_COUNT + 1;

          CLAIM_TAB(L_REC_COUNT) := X.CLAIM_ID;

          INSERT INTO NACHA_PROCESS_LOG
		             (ACCOUNT_TYPE,
                      TRANSACTION_TYPE,
                      TRANSACTION_ID ,
                      ACC_NUM    ,
                      AMOUNT,
                      TRACE_NUMBER,
                      PROCESSED_DATE ,
                      BATCH_NUMBER  ,
                      FILE_NAME ,
                      FLG_PROCESSED
                      )
               VALUES(P_ACCOUNT_TYPE,
                      X.TRANSACTION_TYPE,
                      X.TRANSACTION_ID,
                      X.ACC_NUM,
                      X.AMOUNT,
                      L_LINE_COUNT,
                      TRUNC(SYSDATE),
                      L_BATCH_NUMBER,
                      L_FILE_NAME,
                      'N'
                      );
          -- Updating the Status to Processing
		  UPDATE Ach_Transfer
             SET Status = '4'
           WHERE Transaction_Id = X.Transaction_Id
             AND Status In ('1','2');
      END LOOP;
      --For all the subscriber debits,we need to create a sterling credit and vice versa
      --Chek for transaction code ????
       dbms_output.put_line('Debit Amount '||L_DEBIT_AMOUNT);
       --Credit Entry
            L_BATCH_CONTROL := '8'
                     ||G_SERVICE_CLASS
                     ||LPAD(L_ENTRY_COUNT,6,'0')
                     ||LPAD(L_ENTRY_HASH,10,'0')
                     ||LPAD(REPLACE(REPLACE(TO_CHAR(L_DEBIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                     ||LPAD(REPLACE(REPLACE(TO_CHAR(L_CREDIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                     ||G_DATA1    -- Company ID
                     ||LPAD(' ',25,' ')
                     ||SUBSTR(G_DESTINATION,1,8)
                     ||LPAD(L_BATCH_NUMBER,7,'0');

            L_Block_Count := L_Block_Count + 1;  -- Count of Batch Control Record


            UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                             , BUFFER => L_BATCH_CONTROL||L_CRLF2);

            L_Block_Count := L_Block_Count + 1;  -- Count of File Control Record
            L_Block_Count := ceil(L_Block_Count/10);  -- Divide by 10 and Roundup to the nearest integer , If there are 11 records, then the Block count should be 2.

            L_FILE_CONTROL := '9'
                             ||LPAD(1,6,'0')
                             ||LPAD(L_Block_Count,6,'0')
                             ||LPAD(L_Detail_Addenda_Count,8,'0')
                             ||LPAD(L_ENTRY_HASH,10,'0')
                             ||LPAD(REPLACE(REPLACE(TO_CHAR(L_DEBIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                             ||LPAD(REPLACE(REPLACE(TO_CHAR(L_CREDIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                             ||LPAD(' ',39,' ');

            UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                             , BUFFER => L_FILE_CONTROL||L_CRLF2);

            UTL_FILE.FCLOSE(FILE => L_UTL_ID);


        UPDATE EXTERNAL_FILES
           SET RESULT_FLAG = 'Y'
         WHERE FILE_NAME = L_FILE_NAME
           AND FILE_ACTION = 'ACH_FILE';

      COMMIT;
   END IF;
  */
/* pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE calling pc_notifications.Notify_nacha_result ','L_BATCH_NUMBER := '||L_BATCH_NUMBER);

   DBMS_OUTPUT.PUT_LINE(' Disbursements File created successfully');
ELSE --Fee Payments File
    -- Assign proper values for NACHA variables.
    FOR X IN (SELECT * FROM NACHA_DATA WHERE ACCOUNT_TYPE = 'FEE_PAY')
    LOOP
      G_DESTINATION    := X.DESTINATION;
      G_ORIGIN         := X.ORIGIN;
      G_DEST_BANK      := X.DEST_BANK;
      G_COMPANY_NAME   := X.COMPANY_NAME;
      G_DATA           := X.DATA;
      G_DATA1          := X.DATA1;
      G_TAXID          := X.TAXID ;
      G_TRANSACTION_TYPE:= X.TRANSACTION_TYPE;
      G_SERVICE_CLASS  := X.SERVICE_CLASS;
      G_STANDARD_ENTRY := X.STANDARD_ENTRY;
    END LOOP;

     SELECT COUNT(*)
       INTO V_COUNT
       FROM ACH_NACHA_V N
      WHERE N.STATUS in (1,2)
        AND N.AMOUNT > 0
        AND TRUNC(N.TRANSACTION_DATE) <= TRUNC(SYSDATE)
        AND N.TRANSACTION_TYPE = 'F'
		AND NOT EXISTS (SELECT 1 FROM Nacha_Process_Log P WHERE P.Transaction_Id = N.Transaction_Id);

      SELECT NACHA_SEQ.NEXTVAL
        INTO L_BATCH_NUMBER
        FROM DUAL;

    pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE Fee Transactions ','L_BATCH_NUMBER := '||L_BATCH_NUMBER);

   IF V_COUNT > 0 THEN

       L_Block_Count := 0;  -- Initialization
       --Generate Filenames
       L_FILE_NAME    := 'DAILY_'||P_account_type||'ACH_'||'FEE_'||L_BATCH_NUMBER||'_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.ach';

      UPDATE EXTERNAL_FILES
         SET FILE_NAME = L_FILE_NAME
       WHERE FILE_ID = L_BATCH_NUMBER;

      L_UTL_ID       := UTL_FILE.FOPEN( 'BANK_SERV_DIR', L_FILE_NAME, 'w' );

      L_FILE_HEADER := '101 '
                    ||RPAD(G_DESTINATION,9,' ')
                    ||LPAD(G_TAXID,10,'0')
                    ||TO_CHAR(SYSDATE,'YYMMDD')
                    ||TO_CHAR(SYSDATE,'HHMM')
                    ||'A'
                    ||'094'
                    ||'10'
                    ||'1'
                    ||RPAD(G_DEST_BANK,23,' ')
                    ||RPAD(G_COMPANY_NAME,23,' ')
                    ||'        ';

       L_Block_Count := L_Block_Count + 1;  -- Count of Header Record
       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_FILE_HEADER||L_CRLF2);

       L_BATCH_HEADER := '5'
                     ||G_SERVICE_CLASS
                     ||RPAD(G_COMPANY_NAME,16,' ')
                     ||RPAD(G_DATA,20,' ')  --Company discretionary data
                     ||G_DATA1    -- Company ID
                     ||'CCD'
                     ||RPAD(G_TRANSACTION_TYPE,10,' ')  --Company Entry desc
                     ||'      ' --Company desc date
                     ||TO_CHAR(SYSDATE,'YYMMDD')
                     ||RPAD(' ',3,' ')
                     ||'1'
                     ||SUBSTR(G_DESTINATION,1,8)
                     ||LPAD(L_BATCH_NUMBER,7,'0');

       L_Block_Count := L_Block_Count + 1;  -- Count of Batch Header Record

       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_BATCH_HEADER||L_CRLF2);

       L_ENTRY_COUNT   := 0;
       L_DEBIT_AMOUNT  := 0;
       L_CREDIT_AMOUNT := 0;
       L_Detail_Addenda_Count := 0;

       --Cash Concentration or Disbursement entry
       FOR X IN ( SELECT  SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),1,8) RECEIVING_DFI_NUM
                       ,  DECODE(SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),9,1),NULL,' ',SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),9,1)) CHECK_DIGIT
                       ,  SUBSTR(RTRIM(LTRIM(TO_CHAR(BANK_ROUTING_NUM,'099999999'))),1,8) ROUTING_NUM
                       ,  RPAD(BANK_ACCT_NUM,17,' ')   ACCOUNT_NUMBER
                       ,  REPLACE(REPLACE(TO_CHAR(AMOUNT, '9999999.99'), '.', ''),' ','0') TOTAL_AMOUNT
                       ,  CASE WHEN TRANSACTION_TYPE = 'F' THEN
                                    DECODE(BANK_ACCT_TYPE,'C',27,37)
                          END TRANSACTION_CODE
                       ,  AMOUNT
                       ,  TRANSACTION_TYPE
                       ,  SUBSTR(RPAD(PERSONFNAME||NVL(PERSONLNAME,''),22,' '),1,22) NAME
                       ,  RPAD(TRANSACTION_ID,15,' ') TRANSACTION_ID
                       ,  LPAD(ACC_NUM,15,' ') ACC_NUM
                       ,  CLAIM_ID
                       ,  PERSONFNAME   -- 1707
                       ,  PERSONLNAME
                       ,  PLAN_TYPE
                       ,  ACCOUNT_TYPE
                    FROM ACH_NACHA_V N
                   WHERE N.STATUS in (1,2)
                     AND TRUNC(N.TRANSACTION_DATE) <= TRUNC(SYSDATE)
                     AND N.TRANSACTION_TYPE = 'F'
                     AND N.AMOUNT > 0
					 AND NOT EXISTS (SELECT 1 FROM Nacha_Process_Log P WHERE P.Transaction_Id = N.Transaction_Id))
      LOOP
         L_CCD_RECORD := '6';
         L_LINE_COUNT := NACHA_DETAIL_SEQ.NEXTVAL;
         L_Detail_Addenda_Count := L_Detail_Addenda_Count + 1;
         L_Block_Count := L_Block_Count + 1;  -- Count of Detail Record
         --L_LINE_COUNT := L_LINE_COUNT+1;

         L_CCD_RECORD := L_CCD_RECORD||X.TRANSACTION_CODE||LPAD(X.RECEIVING_DFI_NUM,8,' ')
                         ||LPAD(X.CHECK_DIGIT,1,' ')||X.ACCOUNT_NUMBER||LPAD(REPLACE(X.TOTAL_AMOUNT,'.'),10,0)||X.TRANSACTION_ID
                         ||X.NAME||'  '||'0'||SUBSTR(G_DESTINATION,1,8)||L_LINE_COUNT; --LPAD(L_LINE_COUNT,7,'0');

       -- IF X.TRANSACTION_TYPE = 'D' THEN
         --  L_CREDIT_AMOUNT  := L_CREDIT_AMOUNT+NVL(X.AMOUNT,0);
       -- END IF;

         L_DEBIT_AMOUNT := L_DEBIT_AMOUNT+NVL(X.AMOUNT,0);   -- Added by Swamy
         L_ENTRY_COUNT  := L_ENTRY_COUNT+1;
         L_ENTRY_HASH   := L_ENTRY_HASH+X.RECEIVING_DFI_NUM;

         UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                          , BUFFER => L_CCD_RECORD||L_CRLF2);

          L_REC_COUNT := L_REC_COUNT + 1;

          CLAIM_TAB(L_REC_COUNT) := X.CLAIM_ID;

          INSERT INTO NACHA_PROCESS_LOG
		             (ACCOUNT_TYPE  ,
                      TRANSACTION_TYPE,
                      TRANSACTION_ID ,
                      ACC_NUM        ,
                      AMOUNT         ,
                      TRACE_NUMBER   ,
                      PROCESSED_DATE ,
                      BATCH_NUMBER   ,
                      FILE_NAME      ,
                      FLG_PROCESSED  ,
                      FIRST_NAME     ,
                      LAST_NAME      ,
                      PLAN_TYPE      ,
                      CLAIM_ID
                      )
               VALUES(X.ACCOUNT_TYPE,
                      X.TRANSACTION_TYPE,
                      X.TRANSACTION_ID,
                      X.ACC_NUM     ,
                      X.AMOUNT      ,
                      L_LINE_COUNT  ,
                      TRUNC(SYSDATE),
                      L_BATCH_NUMBER,
                      L_FILE_NAME   ,
                      'N'           ,
                      X.PERSONFNAME ,
                      X.PERSONLNAME ,
                      X.PLAN_TYPE   ,
                      X.CLAIM_ID
                      );

          -- Updating the Status to Processing
		  UPDATE Ach_Transfer
             SET Status = '4'
           WHERE Transaction_Id = X.Transaction_Id
             AND Status In ('1','2');
      END LOOP;
      --For all the subscriber debits,we need to create a sterling credit and vice versa
      --Chek for transaction code ????
      dbms_output.put_line('Debit Amount '||L_DEBIT_AMOUNT);
      --Credit Entry
            L_BATCH_CONTROL := '8'
                     ||G_SERVICE_CLASS
                     ||LPAD(L_ENTRY_COUNT,6,'0')
                     ||LPAD(L_ENTRY_HASH,10,'0')
                     ||LPAD(REPLACE(REPLACE(TO_CHAR(L_DEBIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                     ||LPAD(REPLACE(REPLACE(TO_CHAR(L_CREDIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                     ||G_DATA1    -- Company ID
                     ||LPAD(' ',25,' ')
                     ||SUBSTR(G_DESTINATION,1,8)
                     ||LPAD(L_BATCH_NUMBER,7,'0');

       L_Block_Count := L_Block_Count + 1;  -- Count of Batch Control Record

       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_BATCH_CONTROL||L_CRLF2);

       L_Block_Count := L_Block_Count + 1;  -- Count of File Control Record
       L_Block_Count := CEIL(L_Block_Count/10);  -- Divide by 10 and Roundup to the nearest integer , If there are 11 records, then the Block count should be 2.

       L_FILE_CONTROL := '9'
                      ||LPAD(1,6,'0')
                      ||LPAD(L_Block_Count,6,'0')
                      ||LPAD(L_Detail_Addenda_Count,8,'0')
                      ||LPAD(L_ENTRY_HASH,10,'0')
                      ||LPAD(REPLACE(REPLACE(TO_CHAR(L_DEBIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                      ||LPAD(REPLACE(REPLACE(TO_CHAR(L_CREDIT_AMOUNT,'9999999.99'),'.'),' '),12,'0')
                      ||LPAD(' ',39,' ');


       UTL_FILE.PUT_LINE( FILE   => L_UTL_ID
                        , BUFFER => L_FILE_CONTROL||L_CRLF2);

       UTL_FILE.FCLOSE(FILE => L_UTL_ID);


        UPDATE EXTERNAL_FILES
           SET RESULT_FLAG = 'Y'
         WHERE FILE_NAME = L_FILE_NAME
           AND FILE_ACTION = 'ACH_FILE';

      -- Send the Nacha file details to Finance Department as an attachmet.
      Pc_Notifications.Notify_Nacha_Result(P_Account_Type);   -- 1707

      COMMIT;
   END IF;

  pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE END ','');

   DBMS_OUTPUT.PUT_LINE(' Fee Payments File created successfully');
  -- Generate Fee payment File
END IF; -- Acount type loop

 pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE calling Pc_Notifications.Notify_Nacha_Result ','');

EXCEPTION
WHEN OTHERS THEN
  pc_log.log_error('PC_Auto_Process.GENERATE_NACHA_FILE Error in Others ','L_BATCH_NUMBER := '||L_BATCH_NUMBER||' Error'||SQLERRM(SQLCODE));
END GENERATE_NACHA_FILE;
*/

    procedure generate_nacha_file_employee (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    )   -- For Server Migration by Swamy 06/10/2023)
     as

        g_destination          varchar2(30);
        g_origin               varchar2(30);
        g_dest_bank            varchar2(30);
        g_company_name         varchar2(30);
        g_data                 varchar2(30);
        g_data1                varchar2(30);
        g_taxid                varchar2(30);
        g_transaction_type     varchar2(30);
        g_service_class        varchar2(30);
        g_standard_entry       varchar2(30);
        l_batch_number         number;
        l_file_header          varchar2(94);
        l_batch_header         varchar2(150);
        l_ccd_record           varchar2(94);
        l_ccd_record2          varchar2(94);
        l_crlf2                constant varchar2(2) := chr(13); -- Carriage Return

        l_line_count           number := 0;
        l_file_control         varchar2(94);
        l_batch_control        varchar2(96);
        l_file_end             varchar2(94);
        l_entry_count          number;
        l_debit_amount         number := 0;
        l_credit_amount        number := 0;
        l_entry_hash           number := 0;
        l_total_amount         number := 0;
        l_rec_count            number := 0;
        v_count                number := 0;
        l_detail_addenda_count number := 0;
        l_block_count          number := 0;
        l_utl_id               utl_file.file_type;
        l_file_name            varchar2(3200);
        type claim_typ is
            table of number index by binary_integer;
        claim_tab              claim_typ;
    begin
        pc_log.log_error('Begining of PC_Auto_Process.GENERATE_NACHA_FILE', 'P_ACCOUNT_TYPE := ' || p_account_type);

 -- Assign proper values for NACHA variables.
        if p_account_type is not null then  --When acct type is specified , we generate contributio/disbursements file ELSE we just create one file for Fee payments
    --create separate file for contributions and disbursements */
            l_block_count := 0;
    -- Assign proper values for NACHA variables.
            for x in (
                select
                    *
                from
                    nacha_data
                where
                    account_type = p_account_type
            ) loop
                g_destination := x.destination;
                g_origin := x.origin;
                g_dest_bank := x.dest_bank;
                g_company_name := x.company_name;
                g_data := x.data;
                g_data1 := x.data1;
                g_taxid := x.taxid;
                g_transaction_type := x.transaction_type;
                g_service_class := x.service_class;
                g_standard_entry := x.standard_entry;
            end loop;

            select
                count(*)
            into v_count
            from
                ach_nacha_v n
            where
                n.status in ( 1, 2 )
                and n.amount > 0
                and trunc(n.transaction_date) <= trunc(sysdate)
                and n.account_type = p_account_type
                and n.transaction_type = 'C'
                and n.std_entry_class_code = 'PPD'   -- Added by Swamy for Ticket#11701
                and not exists (
                    select
                        1
                    from
                        nacha_process_log p
                    where
                        p.transaction_id = n.transaction_id
                );

            select
                nacha_seq.nextval
            into l_batch_number
            from
                dual;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE', ' L_BATCH_NUMBER := '
                                                                     || l_batch_number
                                                                     || ' V_COUNT :='
                                                                     || v_count);
            if v_count > 0 then
       --Generate Filenames
                l_file_name := 'DAILY_'
                               || p_account_type
                               || '_ACH_'
                               || 'CONTRIB_CSU_'
                               || l_batch_number
                               || '_'
                               || to_char(sysdate, 'MMDDYYYY')
                               || '.ach';  -- Added by Swamy for Ticket#11701
       --L_FILE_NAME    := 'DAILY_'||P_account_type||'_ACH_'||'CONTRIB_'||L_BATCH_NUMBER||'_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.ach';

                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_batch_number;

                l_utl_id := utl_file.fopen('BANK_SERV_DIR', l_file_name, 'w');
                l_file_header := '101 '
                                 || rpad(g_destination, 9, ' ')
                                 || lpad(g_taxid, 10, '0')
                                 || to_char(sysdate, 'YYMMDD')
                                 || to_char(sysdate, 'HHMM')
                                 || 'A'
                                 || '094'
                                 || '10'
                                 || '1'
                                 || rpad(g_dest_bank, 23, ' ')
                                 || rpad(g_company_name, 23, ' ')
                                 || '        ';

                l_block_count := l_block_count + 1;  -- Count of Header Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_header || l_crlf2
                );
                l_batch_header := '5'
                                  || g_service_class
                                  || rpad(g_company_name, 16, ' ')
                                  || rpad(g_data, 20, ' ')  --Company discretionary data
                                  || g_data1    -- Company ID
                                  || 'PPD'
                                  || rpad(g_transaction_type, 10, ' ')  --Company Entry desc
                                  || '      ' --Company desc date
                                  || to_char(sysdate, 'YYMMDD')
                                  || rpad(' ', 3, ' ')
                                  || '1'
                                  || substr(g_destination, 1, 8)
                                  || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Header Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_header || l_crlf2
                );
                l_entry_count := 0;
                l_debit_amount := 0;
                l_credit_amount := 0;
                l_detail_addenda_count := 0;

       --Cash Concentration or Disbursement entry
                for x in (
                    select
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             receiving_dfi_num,
                        decode(
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            ),
                            null,
                            ' ',
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            )
                        )                             check_digit,
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             routing_num,
                        rpad(bank_acct_num, 17, ' ')  account_number,
                        replace(
                            replace(
                                to_char(amount, '9999999.99'),
                                '.',
                                ''
                            ),
                            ' ',
                            '0'
                        )                             total_amount,
                        case
                            when transaction_type = 'C' then
                                decode(bank_acct_type, 'C', 27, 37)
                            when transaction_type = 'D' then
                                decode(bank_acct_type, 'C', 22, 32)
                        end                           transaction_code,
                        amount,
                        transaction_type,
                        substr(
                            rpad(personfname || nvl(personlname, ''),
                                 22,
                                 ' '),
                            1,
                            22
                        )                             name,
                        rpad(transaction_id, 15, ' ') transaction_id,
                        lpad(acc_num, 15, ' ')        acc_num,
                        claim_id,
                        personfname,
                        personlname,
                        plan_type
                    from
                        ach_nacha_v n
                    where
                        n.status in ( 1, 2 )
                        and trunc(n.transaction_date) <= trunc(sysdate)
                        and n.account_type = p_account_type
                        and n.transaction_type = 'C'
                        and n.amount > 0
                        and n.std_entry_class_code = 'PPD'    -- Added by Swamy for Ticket#11701
                        and not exists (
                            select
                                1
                            from
                                nacha_process_log p
                            where
                                p.transaction_id = n.transaction_id
                        )
                ) loop
                    l_ccd_record := '6';
                    l_line_count := nacha_detail_seq.nextval;
                    l_detail_addenda_count := l_detail_addenda_count + 1;
                    l_block_count := l_block_count + 1;  -- Count of Detail Record

                    l_ccd_record := l_ccd_record
                                    || x.transaction_code
                                    || lpad(x.receiving_dfi_num, 8, ' ')
                                    || lpad(x.check_digit, 1, ' ')
                                    || x.account_number
                                    || lpad(
                        replace(x.total_amount, '.'),
                        10,
                        0
                    )
                                    || x.transaction_id
                                    || x.name
                                    || '  '
                                    || '0'
                                    || substr(g_destination, 1, 8)
                                    || l_line_count;

                    if x.transaction_type = 'C' then
                        l_debit_amount := l_debit_amount + nvl(x.amount, 0);
                    end if;

                    l_entry_count := l_entry_count + 1;
                    l_entry_hash := l_entry_hash + x.receiving_dfi_num;
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_ccd_record || l_crlf2
                    );
                    l_rec_count := l_rec_count + 1;
                    claim_tab(l_rec_count) := x.claim_id;
                    insert into nacha_process_log (
                        account_type,
                        transaction_type,
                        transaction_id,
                        acc_num,
                        amount,
                        trace_number,
                        processed_date,
                        batch_number,
                        file_name,
                        flg_processed,
                        first_name,
                        last_name,
                        plan_type,
                        claim_id
                    ) values ( p_account_type,
                               x.transaction_type,
                               x.transaction_id,
                               x.acc_num,
                               x.amount,
                               l_line_count,
                               trunc(sysdate),
                               l_batch_number,
                               l_file_name,
                               'N',
                               x.personfname,
                               x.personlname,
                               x.plan_type,
                               x.claim_id );

         -- Updating the Status to Processing
                    update ach_transfer
                    set
                        status = '4'
                    where
                            transaction_id = x.transaction_id
                        and status in ( '1', '2' );

                end loop;

                dbms_output.put_line('Debit Amount '
                                     || l_debit_amount
                                     || ' Credit Amount '
                                     || l_credit_amount);
                l_batch_control := '8'
                                   || g_service_class
                                   || lpad(l_entry_count, 6, '0')
                                   || lpad(l_entry_hash, 10, '0')
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || g_data1    -- Company ID
                                   || lpad(' ', 25, ' ')
                                   || substr(g_destination, 1, 8)
                                   || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Control Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_control || l_crlf2
                );
                l_block_count := l_block_count + 1;  -- Count of File Control Record

                l_block_count := ceil(l_block_count / 10);  -- Divide by 10 and Roundup to the nearest integer , If there are 11 records, then the Block count should be 2.

                l_file_control := '9'
                                  || lpad(1, 6, '0')
                                  || lpad(l_block_count, 6, '0')
                                  || lpad(l_detail_addenda_count, 8, '0')
                                  || lpad(l_entry_hash, 10, '0')
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(' ', 39, ' ');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_control || l_crlf2
                );
                utl_file.fclose(file => l_utl_id);
                update external_files
                set
                    result_flag = 'Y'
                where
                        file_name = l_file_name
                    and file_action = 'ACH_FILE';

     -- Send the Nacha file details to Finance Department as an attachmet.
                pc_notifications.notify_nacha_result(p_account_type, l_file_name);
                commit;
            end if;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE calling pc_notifications.Notify_nacha_result ', 'L_BATCH_NUMBER := ' || l_batch_number
            );
        end if; -- Acount type loop

        p_file_name := l_file_name;   -- For Server Migration by Swamy 06/10/2023
        pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE calling Pc_Notifications.Notify_Nacha_Result ', '');
    exception
        when others then
            pc_log.log_error('PC_Auto_Process.GENERATE_NACHA_FILE Error in Others ',
                             'L_BATCH_NUMBER := '
                             || l_batch_number
                             || ' Error'
                             || sqlerrm(sqlcode));
    end generate_nacha_file_employee;

    procedure generate_nacha_file_employer (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    )   -- For Server Migration by Swamy 06/10/2023
     as

        g_destination          varchar2(30);
        g_origin               varchar2(30);
        g_dest_bank            varchar2(30);
        g_company_name         varchar2(30);
        g_data                 varchar2(30);
        g_data1                varchar2(30);
        g_taxid                varchar2(30);
        g_transaction_type     varchar2(30);
        g_service_class        varchar2(30);
        g_standard_entry       varchar2(30);
        l_batch_number         number;
        l_file_header          varchar2(94);
        l_batch_header         varchar2(150);
        l_ccd_record           varchar2(94);
        l_ccd_record2          varchar2(94);
        l_crlf2                constant varchar2(2) := chr(13); -- Carriage Return

        l_line_count           number := 0;
        l_file_control         varchar2(94);
        l_batch_control        varchar2(96);
        l_file_end             varchar2(94);
        l_entry_count          number;
        l_debit_amount         number := 0;
        l_credit_amount        number := 0;
        l_entry_hash           number := 0;
        l_total_amount         number := 0;
        l_rec_count            number := 0;
        v_count                number := 0;
        l_detail_addenda_count number := 0;
        l_block_count          number := 0;
        l_utl_id               utl_file.file_type;
        l_file_name            varchar2(3200);
        type claim_typ is
            table of number index by binary_integer;
        claim_tab              claim_typ;
    begin
        pc_log.log_error('Begining of PC_Auto_Process.GENERATE_NACHA_FILE', 'P_ACCOUNT_TYPE := ' || p_account_type);

 -- Assign proper values for NACHA variables.
        if p_account_type is not null then  --When acct type is specified , we generate contributio/disbursements file ELSE we just create one file for Fee payments
    --create separate file for contributions and disbursements */
            l_block_count := 0;
    -- Assign proper values for NACHA variables.
            for x in (
                select
                    *
                from
                    nacha_data
                where
                    account_type = p_account_type
            ) loop
                g_destination := x.destination;
                g_origin := x.origin;
                g_dest_bank := x.dest_bank;
                g_company_name := x.company_name;
                g_data := x.data;
                g_data1 := x.data1;
                g_taxid := x.taxid;
                g_transaction_type := x.transaction_type;
                g_service_class := x.service_class;
                g_standard_entry := x.standard_entry;
            end loop;

            select
                count(*)
            into v_count
            from
                ach_nacha_v n
            where
                n.status in ( 1, 2 )
                and n.amount > 0
                and trunc(n.transaction_date) <= trunc(sysdate)
                and n.account_type = p_account_type
                and n.transaction_type = 'C'
                and n.std_entry_class_code = 'CCD'  -- Added by Swamy for Ticket#11701
                and not exists (
                    select
                        1
                    from
                        nacha_process_log p
                    where
                        p.transaction_id = n.transaction_id
                );

            select
                nacha_seq.nextval
            into l_batch_number
            from
                dual;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE', ' L_BATCH_NUMBER := '
                                                                     || l_batch_number
                                                                     || ' V_COUNT :='
                                                                     || v_count);
            if v_count > 0 then
       --Generate Filenames
                l_file_name := 'DAILY_'
                               || p_account_type
                               || '_ACH_'
                               || 'CONTRIB_BUS_'
                               || l_batch_number
                               || '_'
                               || to_char(sysdate, 'MMDDYYYY')
                               || '.ach';  -- Added by Swamy for Ticket#11701
       --L_FILE_NAME    := 'DAILY_'||P_account_type||'_ACH_'||'CONTRIB_'||L_BATCH_NUMBER||'_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.ach';

                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_batch_number;

                l_utl_id := utl_file.fopen('BANK_SERV_DIR', l_file_name, 'w');
                l_file_header := '101 '
                                 || rpad(g_destination, 9, ' ')
                                 || lpad(g_taxid, 10, '0')
                                 || to_char(sysdate, 'YYMMDD')
                                 || to_char(sysdate, 'HHMM')
                                 || 'A'
                                 || '094'
                                 || '10'
                                 || '1'
                                 || rpad(g_dest_bank, 23, ' ')
                                 || rpad(g_company_name, 23, ' ')
                                 || '        ';

                l_block_count := l_block_count + 1;  -- Count of Header Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_header || l_crlf2
                );
                l_batch_header := '5'
                                  || g_service_class
                                  || rpad(g_company_name, 16, ' ')
                                  || rpad(g_data, 20, ' ')  --Company discretionary data
                                  || g_data1    -- Company ID
                                  || 'CCD'
                                  || rpad(g_transaction_type, 10, ' ')  --Company Entry desc
                                  || '      ' --Company desc date
                                  || to_char(sysdate, 'YYMMDD')
                                  || rpad(' ', 3, ' ')
                                  || '1'
                                  || substr(g_destination, 1, 8)
                                  || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Header Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_header || l_crlf2
                );
                l_entry_count := 0;
                l_debit_amount := 0;
                l_credit_amount := 0;
                l_detail_addenda_count := 0;

       --Cash Concentration or Disbursement entry
                for x in (
                    select
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             receiving_dfi_num,
                        decode(
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            ),
                            null,
                            ' ',
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            )
                        )                             check_digit,
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             routing_num,
                        rpad(bank_acct_num, 17, ' ')  account_number,
                        replace(
                            replace(
                                to_char(amount, '9999999.99'),
                                '.',
                                ''
                            ),
                            ' ',
                            '0'
                        )                             total_amount,
                        case
                            when transaction_type = 'C' then
                                decode(bank_acct_type, 'C', 27, 37)
                            when transaction_type = 'D' then
                                decode(bank_acct_type, 'C', 22, 32)
                        end                           transaction_code,
                        amount,
                        transaction_type,
                        substr(
                            rpad(personfname || nvl(personlname, ''),
                                 22,
                                 ' '),
                            1,
                            22
                        )                             name,
                        rpad(transaction_id, 15, ' ') transaction_id,
                        lpad(acc_num, 15, ' ')        acc_num,
                        claim_id,
                        personfname,
                        personlname,
                        plan_type
                    from
                        ach_nacha_v n
                    where
                        n.status in ( 1, 2 )
                        and trunc(n.transaction_date) <= trunc(sysdate)
                        and n.account_type = p_account_type
                        and n.transaction_type = 'C'
                        and n.amount > 0
                        and n.std_entry_class_code = 'CCD'  -- Added by Swamy for Ticket#11701
                        and not exists (
                            select
                                1
                            from
                                nacha_process_log p
                            where
                                p.transaction_id = n.transaction_id
                        )
                ) loop
                    l_ccd_record := '6';
                    l_line_count := nacha_detail_seq.nextval;
                    l_detail_addenda_count := l_detail_addenda_count + 1;
                    l_block_count := l_block_count + 1;  -- Count of Detail Record

                    l_ccd_record := l_ccd_record
                                    || x.transaction_code
                                    || lpad(x.receiving_dfi_num, 8, ' ')
                                    || lpad(x.check_digit, 1, ' ')
                                    || x.account_number
                                    || lpad(
                        replace(x.total_amount, '.'),
                        10,
                        0
                    )
                                    || x.transaction_id
                                    || x.name
                                    || '  '
                                    || '0'
                                    || substr(g_destination, 1, 8)
                                    || l_line_count;

                    if x.transaction_type = 'C' then
                        l_debit_amount := l_debit_amount + nvl(x.amount, 0);
                    end if;

                    l_entry_count := l_entry_count + 1;
                    l_entry_hash := l_entry_hash + x.receiving_dfi_num;
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_ccd_record || l_crlf2
                    );
                    l_rec_count := l_rec_count + 1;
                    claim_tab(l_rec_count) := x.claim_id;
                    insert into nacha_process_log (
                        account_type,
                        transaction_type,
                        transaction_id,
                        acc_num,
                        amount,
                        trace_number,
                        processed_date,
                        batch_number,
                        file_name,
                        flg_processed,
                        first_name,
                        last_name,
                        plan_type,
                        claim_id
                    ) values ( p_account_type,
                               x.transaction_type,
                               x.transaction_id,
                               x.acc_num,
                               x.amount,
                               l_line_count,
                               trunc(sysdate),
                               l_batch_number,
                               l_file_name,
                               'N',
                               x.personfname,
                               x.personlname,
                               x.plan_type,
                               x.claim_id );

         -- Updating the Status to Processing
                    update ach_transfer
                    set
                        status = '4'
                    where
                            transaction_id = x.transaction_id
                        and status in ( '1', '2' );

                end loop;

                dbms_output.put_line('Debit Amount '
                                     || l_debit_amount
                                     || ' Credit Amount '
                                     || l_credit_amount);
                l_batch_control := '8'
                                   || g_service_class
                                   || lpad(l_entry_count, 6, '0')
                                   || lpad(l_entry_hash, 10, '0')
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || g_data1    -- Company ID
                                   || lpad(' ', 25, ' ')
                                   || substr(g_destination, 1, 8)
                                   || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Control Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_control || l_crlf2
                );
                l_block_count := l_block_count + 1;  -- Count of File Control Record

                l_block_count := ceil(l_block_count / 10);  -- Divide by 10 and Roundup to the nearest integer , If there are 11 records, then the Block count should be 2.

                l_file_control := '9'
                                  || lpad(1, 6, '0')
                                  || lpad(l_block_count, 6, '0')
                                  || lpad(l_detail_addenda_count, 8, '0')
                                  || lpad(l_entry_hash, 10, '0')
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(' ', 39, ' ');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_control || l_crlf2
                );
                utl_file.fclose(file => l_utl_id);
                update external_files
                set
                    result_flag = 'Y'
                where
                        file_name = l_file_name
                    and file_action = 'ACH_FILE';

     -- Send the Nacha file details to Finance Department as an attachmet.
                pc_notifications.notify_nacha_result(p_account_type, l_file_name);
                commit;
            end if;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE calling pc_notifications.Notify_nacha_result ', 'L_BATCH_NUMBER := ' || l_batch_number
            );
        end if; -- Acount type loop
        p_file_name := l_file_name;   -- For Server Migration by Swamy 06/10/2023
        pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE calling Pc_Notifications.Notify_Nacha_Result ', '');
    exception
        when others then
            pc_log.log_error('PC_Auto_Process.GENERATE_NACHA_FILE Error in Others ',
                             'L_BATCH_NUMBER := '
                             || l_batch_number
                             || ' Error'
                             || sqlerrm(sqlcode));
    end generate_nacha_file_employer;

    procedure generate_nacha_file_fee (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    )   -- For Server Migration by Swamy 06/10/2023
     as

        g_destination          varchar2(30);
        g_origin               varchar2(30);
        g_dest_bank            varchar2(30);
        g_company_name         varchar2(30);
        g_data                 varchar2(30);
        g_data1                varchar2(30);
        g_taxid                varchar2(30);
        g_transaction_type     varchar2(30);
        g_service_class        varchar2(30);
        g_standard_entry       varchar2(30);
        l_batch_number         number;
        l_file_header          varchar2(94);
        l_batch_header         varchar2(150);
        l_ccd_record           varchar2(94);
        l_ccd_record2          varchar2(94);
        l_crlf2                constant varchar2(2) := chr(13); -- Carriage Return

        l_line_count           number := 0;
        l_file_control         varchar2(94);
        l_batch_control        varchar2(96);
        l_file_end             varchar2(94);
        l_entry_count          number;
        l_debit_amount         number := 0;
        l_credit_amount        number := 0;
        l_entry_hash           number := 0;
        l_total_amount         number := 0;
        l_rec_count            number := 0;
        v_count                number := 0;
        l_detail_addenda_count number := 0;
        l_block_count          number := 0;
        l_utl_id               utl_file.file_type;
        l_file_name            varchar2(3200);
        type claim_typ is
            table of number index by binary_integer;
        claim_tab              claim_typ;
    begin
        pc_log.log_error('Begining of PC_Auto_Process.GENERATE_NACHA_FILE', 'P_ACCOUNT_TYPE := ' || p_account_type);

 -- Assign proper values for NACHA variables.
        if p_account_type is null then  --When acct type is specified , we generate contributio/disbursements file ELSE we just create one file for Fee payments
   -- Fee Payments File
    -- Assign proper values for NACHA variables.
            for x in (
                select
                    *
                from
                    nacha_data
                where
                    account_type = 'FEE_PAY'
            ) loop
                g_destination := x.destination;
                g_origin := x.origin;
                g_dest_bank := x.dest_bank;
                g_company_name := x.company_name;
                g_data := x.data;
                g_data1 := x.data1;
                g_taxid := x.taxid;
                g_transaction_type := x.transaction_type;
                g_service_class := x.service_class;
                g_standard_entry := x.standard_entry;
            end loop;

            select
                count(*)
            into v_count
            from
                ach_nacha_v n
            where
                n.status in ( 1, 2 )
                and n.amount > 0
                and trunc(n.transaction_date) <= trunc(sysdate)
                and n.transaction_type = 'F'
                and not exists (
                    select
                        1
                    from
                        nacha_process_log p
                    where
                        p.transaction_id = n.transaction_id
                );

            select
                nacha_seq.nextval
            into l_batch_number
            from
                dual;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE Fee Transactions ', 'L_BATCH_NUMBER := ' || l_batch_number);
            if v_count > 0 then
                l_block_count := 0;  -- Initialization
       --Generate Filenames
                l_file_name := 'DAILY_'
                               || p_account_type
                               || 'ACH_'
                               || 'FEE_BUS_'
                               || l_batch_number
                               || '_'
                               || to_char(sysdate, 'MMDDYYYY')
                               || '.ach';  -- Added by Swamy for Ticket#11701
       --L_FILE_NAME    := 'DAILY_'||P_account_type||'ACH_'||'FEE_'||L_BATCH_NUMBER||'_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.ach';

                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_batch_number;

                l_utl_id := utl_file.fopen('BANK_SERV_DIR', l_file_name, 'w');
                l_file_header := '101 '
                                 || rpad(g_destination, 9, ' ')
                                 || lpad(g_taxid, 10, '0')
                                 || to_char(sysdate, 'YYMMDD')
                                 || to_char(sysdate, 'HHMM')
                                 || 'A'
                                 || '094'
                                 || '10'
                                 || '1'
                                 || rpad(g_dest_bank, 23, ' ')
                                 || rpad(g_company_name, 23, ' ')
                                 || '        ';

                l_block_count := l_block_count + 1;  -- Count of Header Record
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_header || l_crlf2
                );
                l_batch_header := '5'
                                  || g_service_class
                                  || rpad(g_company_name, 16, ' ')
                                  || rpad(g_data, 20, ' ')  --Company discretionary data
                                  || g_data1    -- Company ID
                                  || 'CCD'
                                  || rpad(g_transaction_type, 10, ' ')  --Company Entry desc
                                  || '      ' --Company desc date
                                  || to_char(sysdate, 'YYMMDD')
                                  || rpad(' ', 3, ' ')
                                  || '1'
                                  || substr(g_destination, 1, 8)
                                  || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Header Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_header || l_crlf2
                );
                l_entry_count := 0;
                l_debit_amount := 0;
                l_credit_amount := 0;
                l_detail_addenda_count := 0;

       --Cash Concentration or Disbursement entry
                for x in (
                    select
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             receiving_dfi_num,
                        decode(
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            ),
                            null,
                            ' ',
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            )
                        )                             check_digit,
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             routing_num,
                        rpad(bank_acct_num, 17, ' ')  account_number,
                        replace(
                            replace(
                                to_char(amount, '9999999.99'),
                                '.',
                                ''
                            ),
                            ' ',
                            '0'
                        )                             total_amount,
                        case
                            when transaction_type = 'F' then
                                decode(bank_acct_type, 'C', 27, 37)
                        end                           transaction_code,
                        amount,
                        transaction_type,
                        substr(
                            rpad(personfname || nvl(personlname, ''),
                                 22,
                                 ' '),
                            1,
                            22
                        )                             name,
                        rpad(transaction_id, 15, ' ') transaction_id,
                        lpad(acc_num, 15, ' ')        acc_num,
                        claim_id,
                        personfname   -- 1707
                        ,
                        personlname,
                        plan_type,
                        account_type
                    from
                        ach_nacha_v n
                    where
                        n.status in ( 1, 2 )
                        and trunc(n.transaction_date) <= trunc(sysdate)
                        and n.transaction_type = 'F'
                        and n.amount > 0
                        and not exists (
                            select
                                1
                            from
                                nacha_process_log p
                            where
                                p.transaction_id = n.transaction_id
                        )
                ) loop
                    l_ccd_record := '6';
                    l_line_count := nacha_detail_seq.nextval;
                    l_detail_addenda_count := l_detail_addenda_count + 1;
                    l_block_count := l_block_count + 1;  -- Count of Detail Record
         --L_LINE_COUNT := L_LINE_COUNT+1;

                    l_ccd_record := l_ccd_record
                                    || x.transaction_code
                                    || lpad(x.receiving_dfi_num, 8, ' ')
                                    || lpad(x.check_digit, 1, ' ')
                                    || x.account_number
                                    || lpad(
                        replace(x.total_amount, '.'),
                        10,
                        0
                    )
                                    || x.transaction_id
                                    || x.name
                                    || '  '
                                    || '0'
                                    || substr(g_destination, 1, 8)
                                    || l_line_count; --LPAD(L_LINE_COUNT,7,'0');

       /* IF X.TRANSACTION_TYPE = 'D' THEN
           L_CREDIT_AMOUNT  := L_CREDIT_AMOUNT+NVL(X.AMOUNT,0);
        END IF;
       */
                    l_debit_amount := l_debit_amount + nvl(x.amount, 0);   -- Added by Swamy
                    l_entry_count := l_entry_count + 1;
                    l_entry_hash := l_entry_hash + x.receiving_dfi_num;
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_ccd_record || l_crlf2
                    );
                    l_rec_count := l_rec_count + 1;
                    claim_tab(l_rec_count) := x.claim_id;
                    insert into nacha_process_log (
                        account_type,
                        transaction_type,
                        transaction_id,
                        acc_num,
                        amount,
                        trace_number,
                        processed_date,
                        batch_number,
                        file_name,
                        flg_processed,
                        first_name,
                        last_name,
                        plan_type,
                        claim_id
                    ) values ( x.account_type,
                               x.transaction_type,
                               x.transaction_id,
                               x.acc_num,
                               x.amount,
                               l_line_count,
                               trunc(sysdate),
                               l_batch_number,
                               l_file_name,
                               'N',
                               x.personfname,
                               x.personlname,
                               x.plan_type,
                               x.claim_id );

          -- Updating the Status to Processing
                    update ach_transfer
                    set
                        status = '4'
                    where
                            transaction_id = x.transaction_id
                        and status in ( '1', '2' );

                end loop;
      --For all the subscriber debits,we need to create a sterling credit and vice versa
      --Chek for transaction code ????
                dbms_output.put_line('Debit Amount ' || l_debit_amount);
      --Credit Entry
                l_batch_control := '8'
                                   || g_service_class
                                   || lpad(l_entry_count, 6, '0')
                                   || lpad(l_entry_hash, 10, '0')
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || g_data1    -- Company ID
                                   || lpad(' ', 25, ' ')
                                   || substr(g_destination, 1, 8)
                                   || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Control Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_control || l_crlf2
                );
                l_block_count := l_block_count + 1;  -- Count of File Control Record
                l_block_count := ceil(l_block_count / 10);  -- Divide by 10 and Roundup to the nearest integer , If there are 11 records, then the Block count should be 2.

                l_file_control := '9'
                                  || lpad(1, 6, '0')
                                  || lpad(l_block_count, 6, '0')
                                  || lpad(l_detail_addenda_count, 8, '0')
                                  || lpad(l_entry_hash, 10, '0')
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(' ', 39, ' ');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_control || l_crlf2
                );
                utl_file.fclose(file => l_utl_id);
                update external_files
                set
                    result_flag = 'Y'
                where
                        file_name = l_file_name
                    and file_action = 'ACH_FILE';

      -- Send the Nacha file details to Finance Department as an attachmet.
                pc_notifications.notify_nacha_result(p_account_type, l_file_name);   -- 1707

                commit;
            end if;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE END ', '');
            dbms_output.put_line(' Fee Payments File created successfully');
   -- Generate Fee payment File
        end if; -- Acount type loop

        p_file_name := l_file_name;   -- For Server Migration by Swamy 06/10/2023
        pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE calling Pc_Notifications.Notify_Nacha_Result ', '');
    exception
        when others then
            pc_log.log_error('PC_Auto_Process.GENERATE_NACHA_FILE Error in Others ',
                             'L_BATCH_NUMBER := '
                             || l_batch_number
                             || ' Error'
                             || sqlerrm(sqlcode));
    end generate_nacha_file_fee;

    procedure process_nacha_file is
    begin

    -- 'P' Added below by Joshi for 12748.
        for k in (
            select
                transaction_id,
                transaction_type
            from
                nacha_process_log
            where
                    nvl(flg_processed, 'N') = 'N'
                and transaction_type in ( 'C', 'F', 'P' )
        ) loop
            update ach_transfer
            set
                status = '3',
                processed_date = sysdate,
                bankserv_status = 'APPROVED'
            where
                transaction_id = k.transaction_id;

            pc_log.log_error('Process_Nacha_File', 'K.Transaction_ID := ' || k.transaction_id);
            if k.transaction_type <> 'P' then  -- Added below by Joshi for 12748
                pc_auto_process.post_ach_deposits(k.transaction_id);
            else
			-- Added by Joshi for ticket 12851. claim pending needs to be updated
                for x in (
                    select
                        transaction_id,
                        claim_id
                    from
                        ach_transfer_v
                    where
                        transaction_id = k.transaction_id
                ) loop
                    for c in (
                        select
                            sum(amount) amount
                        from
                            payment    a,
                            pay_reason b
                        where
                                claimn_id = x.claim_id
                            and a.reason_code = b.reason_code
                            and b.reason_type = 'DISBURSEMENT'
                    ) loop
                        pc_log.log_error('Process_Nacha_File', 'claim_id for transaction type P :' || x.claim_id);
                        update claimn
                        set
                            claim_paid = c.amount,
                            claim_pending = approved_amount - ( nvl(denied_amount, 0) + c.amount )
                        where
                            claim_id = x.claim_id;

                        update payment_register
                        set
                            insufficient_fund_flag = 'N'
                        where
                                claim_id = x.claim_id
                            and claim_amount = c.amount;

                    end loop;
                end loop;
            end if;

            pc_log.log_error('Contribution File created successfully for ', 'Transaction_ID := ' || k.transaction_id);
            update nacha_process_log
            set
                flg_processed = 'Y'
            where
                transaction_id = k.transaction_id;

     -- Swamy  for Cobrapoint
     -- Only when the refund amount is got back from the employer, the refund for the QB should be initiated.
            pc_auto_process.confirm_employer_refund(p_transaction_id => k.transaction_id);
        end loop;

    --Pc_Notifications.Notify_Nacha_Result;

  /* UPDATE Nacha_Process_Log
       SET Flg_Processed = 'Y'
     WHERE Transaction_id IN (SELECT Transaction_id
	                           FROM NACHA_PROCESS_LOG
							  WHERE NVL(FLG_PROCESSED,'N') = 'N'
							    AND Transaction_type in ('C','F'));
 */

    exception
        when others then
            pc_log.log_error('Process_Nacha_File Others ',
                             'Error Message := ' || sqlerrm(sqlcode));
    end process_nacha_file;

-- Swamy for Cobrapoint 30/11/2022
    procedure confirm_employer_refund (
        p_transaction_id in number
    ) is
        l_reason_code number := 132;
    begin
        for n in (
            select
                b.cobra_refund_claim_id,
                d.invoice_id,
                a.bankserv_status,
                b.acc_id,
                b.main_invoice_id,
                start_date,
                entity_id
            from
                ach_transfer_v    a,
                employer_deposits d,
                ar_invoice        b
            where
                    a.transaction_id = p_transaction_id
                and a.invoice_id = d.invoice_id
                and upper(a.bankserv_status) = 'APPROVED'
                and a.status = '3'
                and d.invoice_id = b.invoice_id
                and b.cobra_refund_claim_id is not null
        ) loop
            update ach_transfer
            set
                status = '4'
            where
                    claim_id = n.cobra_refund_claim_id
                and transaction_type = 'D'
                and reason_code = 132
                and status = '5';

            insert into income (
                change_num,
                acc_id,
                fee_date,
                fee_code,
                amount,
                pay_code,
                cc_number,
                note,
                amount_add,
                ee_fee_amount,
                list_bill,
                transaction_type,
                due_date,
                postmark_date
            )
                select
                    change_seq.nextval,
                    i.acc_id,
                    sysdate,
                    l_reason_code,
                    0,
                    i.pay_code,
                    'Returned ' || n.main_invoice_id,
                    'Premium returned on '
                    || sysdate
                    || 'for premium invoice '
                    || n.main_invoice_id
                    || 'for due date'
                    || i.due_date,
                    - i.amount_add   -- commented and added by Swamy for Cobrapoint bug fixing -nvl(p_check_amount,0)
                    ,
                    case
                        when l_reason_code in ( 9, 19, 20 ) then
                            - nvl(i.ee_fee_amount, 0)
                        else
                            0
                    end,
                    n.main_invoice_id,
                    'I',
                    n.start_date,
                    sysdate
                from
                    income  i,
                    account a
                where
                        i.list_bill = n.main_invoice_id
                    and i.acc_id = a.acc_id
                    and a.pers_id = n.entity_id
                    and a.account_type = 'COBRA'
                    and i.fee_code <> 19;

        end loop;
    exception
        when others then
            pc_log.log_error('confirm_employer_refund Others ',
                             'Error Message := ' || sqlerrm(sqlcode));
    end confirm_employer_refund;

    procedure generate_nacha_file_for_employee_payment (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    )   -- For Server Migration by Swamy 06/10/2023)
     as

        g_destination          varchar2(30);
        g_origin               varchar2(30);
        g_dest_bank            varchar2(30);
        g_company_name         varchar2(30);
        g_data                 varchar2(30);
        g_data1                varchar2(30);
        g_taxid                varchar2(30);
        g_transaction_type     varchar2(30);
        g_service_class        varchar2(30);
        g_standard_entry       varchar2(30);
        l_batch_number         number;
        l_file_header          varchar2(94);
        l_batch_header         varchar2(150);
        l_ccd_record           varchar2(94);
        l_ccd_record2          varchar2(94);
        l_crlf2                constant varchar2(2) := chr(13); -- Carriage Return

        l_line_count           number := 0;
        l_file_control         varchar2(94);
        l_batch_control        varchar2(96);
        l_file_end             varchar2(94);
        l_entry_count          number;
        l_debit_amount         number := 0;
        l_credit_amount        number := 0;
        l_entry_hash           number := 0;
        l_total_amount         number := 0;
        l_rec_count            number := 0;
        v_count                number := 0;
        l_detail_addenda_count number := 0;
        l_block_count          number := 0;
        l_utl_id               utl_file.file_type;
        l_file_name            varchar2(3200);
        type claim_typ is
            table of number index by binary_integer;
        claim_tab              claim_typ;
    begin
        pc_log.log_error('Begining of PC_Auto_Process.GENERATE_NACHA_FILE', 'P_ACCOUNT_TYPE := ' || p_account_type);

 -- Assign proper values for NACHA variables.
        if p_account_type is not null then  --When acct type is specified , we generate contributio/disbursements file ELSE we just create one file for Fee payments
    --create separate file for contributions and disbursements */
            l_block_count := 0;
    -- Assign proper values for NACHA variables.
            for x in (
                select
                    *
                from
                    nacha_data
                where
                    account_type = p_account_type
            ) loop
                g_destination := x.destination;
                g_origin := x.origin;
                g_dest_bank := x.dest_bank;
                g_company_name := x.company_name;
                g_data := x.data;
                g_data1 := x.data1;
                g_taxid := x.taxid;
                g_transaction_type := x.transaction_type;
                g_service_class := x.service_class;
                g_standard_entry := x.standard_entry;
            end loop;

            select
                count(*)
            into v_count
            from
                ach_nacha_v n
            where
                n.status in ( 1, 2 )
                and n.amount > 0
                and trunc(n.transaction_date) <= trunc(sysdate)
                and n.account_type = p_account_type
                and n.transaction_type = 'P'
                and n.std_entry_class_code = 'PPD'
                and not exists (
                    select
                        1
                    from
                        nacha_process_log p
                    where
                        p.transaction_id = n.transaction_id
                );

            select
                nacha_seq.nextval
            into l_batch_number
            from
                dual;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE', ' L_BATCH_NUMBER := '
                                                                     || l_batch_number
                                                                     || ' V_COUNT :='
                                                                     || v_count);
            if v_count > 0 then
       --Generate Filenames
                l_file_name := 'DAILY_'
                               || p_account_type
                               || '_ACH_'
                               || 'PAYMENT_CSU_'
                               || l_batch_number
                               || '_'
                               || to_char(sysdate, 'MMDDYYYY')
                               || '.ach';  -- Added by Swamy for Ticket#11701
       --L_FILE_NAME    := 'DAILY_'||P_account_type||'_ACH_'||'CONTRIB_'||L_BATCH_NUMBER||'_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.ach';

                update external_files
                set
                    file_name = l_file_name
                where
                    file_id = l_batch_number;

                l_utl_id := utl_file.fopen('BANK_SERV_DIR', l_file_name, 'w');
                l_file_header := '101 '
                                 || rpad(g_destination, 9, ' ')
                                 || lpad(g_taxid, 10, '0')
                                 || to_char(sysdate, 'YYMMDD')
                                 || to_char(sysdate, 'HHMM')
                                 || 'A'
                                 || '094'
                                 || '10'
                                 || '1'
                                 || rpad(g_dest_bank, 23, ' ')
                                 || rpad(g_company_name, 23, ' ')
                                 || '        ';

                l_block_count := l_block_count + 1;  -- Count of Header Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_header || l_crlf2
                );
                l_batch_header := '5'
                                  || g_service_class
                                  || rpad(g_company_name, 16, ' ')
                                  || rpad(g_data, 20, ' ')  --Company discretionary data
                                  || g_data1    -- Company ID
                                  || 'PPD'
                                  || rpad(g_transaction_type, 10, ' ')  --Company Entry desc
                                  || '      ' --Company desc date
                                  || to_char(sysdate, 'YYMMDD')
                                  || rpad(' ', 3, ' ')
                                  || '1'
                                  || substr(g_destination, 1, 8)
                                  || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Header Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_header || l_crlf2
                );
                l_entry_count := 0;
                l_debit_amount := 0;
                l_credit_amount := 0;
                l_detail_addenda_count := 0;

       --Cash Concentration or Disbursement entry
                for x in (
                    select
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             receiving_dfi_num,
                        decode(
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            ),
                            null,
                            ' ',
                            substr(
                                rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                                9,
                                1
                            )
                        )                             check_digit,
                        substr(
                            rtrim(ltrim(to_char(bank_routing_num, '099999999'))),
                            1,
                            8
                        )                             routing_num,
                        rpad(bank_acct_num, 17, ' ')  account_number,
                        replace(
                            replace(
                                to_char(amount, '9999999.99'),
                                '.',
                                ''
                            ),
                            ' ',
                            '0'
                        )                             total_amount,
                        case
                            when transaction_type = 'C' then
                                decode(bank_acct_type, 'C', 27, 37)
                            when transaction_type = 'D' then
                                decode(bank_acct_type, 'C', 22, 32)
                        end                           transaction_code,
                        amount,
                        transaction_type,
                        substr(
                            rpad(personfname || nvl(personlname, ''),
                                 22,
                                 ' '),
                            1,
                            22
                        )                             name,
                        rpad(transaction_id, 15, ' ') transaction_id,
                        lpad(acc_num, 15, ' ')        acc_num,
                        claim_id,
                        personfname,
                        personlname,
                        plan_type
                    from
                        ach_nacha_v n
                    where
                        n.status in ( 1, 2 )
                        and trunc(n.transaction_date) <= trunc(sysdate)
                        and n.account_type = p_account_type
                        and n.transaction_type = 'P'
                        and n.amount > 0
                        and n.std_entry_class_code = 'PPD'    -- Added by Swamy for Ticket#11701 
                        and not exists (
                            select
                                1
                            from
                                nacha_process_log p
                            where
                                p.transaction_id = n.transaction_id
                        )
                ) loop
                    l_ccd_record := '6';
                    l_line_count := nacha_detail_seq.nextval;
                    l_detail_addenda_count := l_detail_addenda_count + 1;
                    l_block_count := l_block_count + 1;  -- Count of Detail Record

                    l_ccd_record := l_ccd_record
                                    || x.transaction_code
                                    || lpad(x.receiving_dfi_num, 8, ' ')
                                    || lpad(x.check_digit, 1, ' ')
                                    || x.account_number
                                    || lpad(
                        replace(x.total_amount, '.'),
                        10,
                        0
                    )
                                    || x.transaction_id
                                    || x.name
                                    || '  '
                                    || '0'
                                    || substr(g_destination, 1, 8)
                                    || l_line_count;

         -- commented and added below by Joshi for 12748
                    if x.transaction_type = 'P' then
                        l_debit_amount := l_debit_amount + nvl(x.amount, 0);
                    end if;

                    l_entry_count := l_entry_count + 1;
                    l_entry_hash := l_entry_hash + x.receiving_dfi_num;
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_ccd_record || l_crlf2
                    );
                    l_rec_count := l_rec_count + 1;
                    claim_tab(l_rec_count) := x.claim_id;
                    insert into nacha_process_log (
                        account_type,
                        transaction_type,
                        transaction_id,
                        acc_num,
                        amount,
                        trace_number,
                        processed_date,
                        batch_number,
                        file_name,
                        flg_processed,
                        first_name,
                        last_name,
                        plan_type,
                        claim_id
                    ) values ( p_account_type,
                               x.transaction_type,
                               x.transaction_id,
                               x.acc_num,
                               x.amount,
                               l_line_count,
                               trunc(sysdate),
                               l_batch_number,
                               l_file_name,
                               'N',
                               x.personfname,
                               x.personlname,
                               x.plan_type,
                               x.claim_id );

         -- Updating the Status to Processing
                    update ach_transfer
                    set
                        status = '4'
                    where
                            transaction_id = x.transaction_id
                        and status in ( '1', '2' );

                end loop;

                dbms_output.put_line('Debit Amount '
                                     || l_debit_amount
                                     || ' Credit Amount '
                                     || l_credit_amount);
                l_batch_control := '8'
                                   || g_service_class
                                   || lpad(l_entry_count, 6, '0')
                                   || lpad(l_entry_hash, 10, '0')
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                   || g_data1    -- Company ID
                                   || lpad(' ', 25, ' ')
                                   || substr(g_destination, 1, 8)
                                   || lpad(l_batch_number, 7, '0');

                l_block_count := l_block_count + 1;  -- Count of Batch Control Record

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_batch_control || l_crlf2
                );
                l_block_count := l_block_count + 1;  -- Count of File Control Record

                l_block_count := ceil(l_block_count / 10);  -- Divide by 10 and Roundup to the nearest integer , If there are 11 records, then the Block count should be 2.

                l_file_control := '9'
                                  || lpad(1, 6, '0')
                                  || lpad(l_block_count, 6, '0')
                                  || lpad(l_detail_addenda_count, 8, '0')
                                  || lpad(l_entry_hash, 10, '0')
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_debit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(
                    replace(
                        replace(
                            to_char(l_credit_amount, '9999999.99'),
                            '.'
                        ),
                        ' '
                    ),
                    12,
                    '0'
                )
                                  || lpad(' ', 39, ' ');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_file_control || l_crlf2
                );
                utl_file.fclose(file => l_utl_id);
                update external_files
                set
                    result_flag = 'Y'
                where
                        file_name = l_file_name
                    and file_action = 'ACH_FILE';

     -- Send the Nacha file details to Finance Department as an attachmet.
                pc_notifications.notify_nacha_result(p_account_type, l_file_name);
                commit;
            end if;

            pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE_FOR_EMPLOYEE_PAYMENT calling pc_notifications.Notify_nacha_result '
            , 'L_BATCH_NUMBER := ' || l_batch_number);
        end if; -- Acount type loop 

        p_file_name := l_file_name;   -- For Server Migration by Swamy 06/10/2023
        pc_log.log_error(' PC_Auto_Process.GENERATE_NACHA_FILE_FOR_EMPLOYEE_PAYMENT calling Pc_Notifications.Notify_Nacha_Result ', ''
        );
    exception
        when others then
            pc_log.log_error('PC_Auto_Process.GENERATE_NACHA_FILE_FOR_EMPLOYEE_PAYMENT Error in Others ',
                             'L_BATCH_NUMBER := '
                             || l_batch_number
                             || ' Error'
                             || sqlerrm(sqlcode));
    end generate_nacha_file_for_employee_payment;

end;
/


-- sqlcl_snapshot {"hash":"564d1027260cdb740803fa02306184a2adb41a4c","type":"PACKAGE_BODY","name":"PC_AUTO_PROCESS","schemaName":"SAMQA","sxml":""}