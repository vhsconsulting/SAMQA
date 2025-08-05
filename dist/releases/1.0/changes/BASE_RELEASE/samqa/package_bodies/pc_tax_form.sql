-- liquibase formatted sql
-- changeset SAMQA:1754374091431 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_tax_form.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_tax_form.sql:null:b956b503e80c9d55333c3939041be0ae97d9efc6:create

create or replace package body samqa.pc_tax_form as

    procedure generate_5498 (
        p_tax_year         in varchar2,
        p_generation_month in varchar2,
        p_acc_num          in varchar2
    ) -- 2012
     is
        l_batch_number number;
        l_next_year    number;
    begin
        l_batch_number := batch_num_seq.nextval;
       /*  DELETE FROM TAX_FORMS WHERE ACC_NUM = P_ACC_NUM
        AND BEGIN_DATE = TO_DATE('01-JAN-'||P_TAX_YEAR,'DD-MON-YYYY');*/
        l_next_year := to_number ( p_tax_year ) + 1;
        insert into tax_forms (
            tax_form_id,
            batch_number,
            acc_id,
            pers_id,
            acc_num,
            start_date,
            begin_date,
            end_date,
            tax_doc_type,
            current_bal,
            creation_date
        )
            select
                tax_forms_seq.nextval,
                l_batch_number,
                l_acc.acc_id,
                l_acc.pers_id,
                l_acc.acc_num,
                l_acc.start_date,
                to_date('01-JAN-' || p_tax_year, 'DD-MON-YYYY'),
                to_date('31-DEC-' || p_tax_year, 'DD-MON-YYYY'),
                '5498',
                pc_account.current_balance(l_acc.acc_id, '01-JAN-2004', to_date('31-DEC-'
                                                                                || p_tax_year, 'DD-MON-YYYY')) + pc_account.outside_inv_balance
                                                                                (l_acc.acc_id, to_date('31-DEC-'
                                                                                                                                               || p_tax_year
                                                                                                                                               ,
                                                                                                                                               'DD-MON-YYYY'
                                                                                                                                               )
                                                                                                                                               )
                                                                                                                                               ,
                sysdate
            from
                account l_acc
            where
                    l_acc.account_type = 'HSA'
                and ( p_acc_num is null
                      or l_acc.acc_num = p_acc_num )
                and nvl(l_acc.blocked_flag, 'N') = 'N'
                and l_acc.pers_id is not null
                and l_acc.account_status <> 3
                and l_acc.start_date < to_date('31-DEC-' || p_tax_year, 'DD-MON-YYYY') + 1
                                                                                         and nvl(l_acc.end_date, sysdate) > to_date('01-JAN-' || p_tax_year
                                                                                         , 'DD-MON-YYYY');

        update tax_forms
        set
            start_fee_date = (
                select
                    min(fee_date)
                from
                    income
                where
                    income.acc_id = tax_forms.acc_id
            )
        where
                trunc(start_date) >= trunc(begin_date)
            and batch_number = l_batch_number
            and ( p_acc_num is null
                  or acc_num = p_acc_num );
         -- Current Year Deposit
        if to_char(sysdate, 'MON') = 'JAN' then
            update tax_forms
            set
                curr_yr_deposit = nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0)) amount
                    from
                        income
                    where
                            income.acc_id = tax_forms.acc_id
                        and fee_code in(0, 3, 4, 9, 6,
                                        7, 10, 110, 14, 15,
                                        16, 50)
                        and trunc(income.fee_date) >= least(begin_date,
                                                            nvl(start_fee_date, begin_date))
                        and trunc(income.fee_date) <= end_date
                ),
                                      0)
            where
                    batch_number = l_batch_number
                and ( p_acc_num is null
                      or acc_num = p_acc_num );

            update tax_forms
            set
                curr_yr_deposit = nvl(curr_yr_deposit, 0) + nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0)) amount
                    from
                        income
                    where
                            income.acc_id = tax_forms.acc_id
                        and fee_code = 130
                        and trunc(income.fee_date) >= to_date('01-JAN-' || l_next_year, 'DD-MON-YYYY')
                        and trunc(income.fee_date) <= to_date('31-DEC-' || l_next_year, 'DD-MON-YYYY')
                ),
                                                                0)
            where
                    batch_number = l_batch_number
                and ( p_acc_num is null
                      or acc_num = p_acc_num );

        else
            update tax_forms
            set
                curr_yr_deposit = nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                    from
                        income
                    where
                            income.acc_id = tax_forms.acc_id
                        and fee_code in(0, 3, 4, 6, 110,
                                        7, 10, 9, 14, 15,
                                        16, 50)
                        and trunc(income.fee_date) >= least(begin_date,
                                                            nvl(start_fee_date, begin_date))
                        and trunc(income.fee_date) <= end_date
                ),
                                      0)
            where
                    batch_number = l_batch_number
                and ( p_acc_num is null
                      or acc_num = p_acc_num );

            update tax_forms
            set
                curr_yr_deposit = nvl(curr_yr_deposit, 0) + nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0)) amount
                    from
                        income
                    where
                            income.acc_id = tax_forms.acc_id
                        and fee_code = 130
                        and trunc(income.fee_date) >= to_date('01-JAN-' || l_next_year, 'DD-MON-YYYY')
                        and trunc(income.fee_date) <= to_date('31-DEC-' || l_next_year, 'DD-MON-YYYY')
                ),
                                                                0)
            where
                    batch_number = l_batch_number
                and ( p_acc_num is null
                      or acc_num = p_acc_num );

        end if;
         -- Previous Year Deposit
        if to_char(sysdate, 'MON') = 'JAN' then
            update tax_forms
            set
                prev_yr_deposit = nvl(prev_yr_deposit, 0) + nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                    from
                        income
                    where
                            income.acc_id = tax_forms.acc_id
                        and fee_code in(7, 10)
                        and trunc(income.fee_date) >= to_date('01-JAN-' || l_next_year, 'DD-MON-YYYY')
                        and trunc(income.fee_date) <= to_date('31-DEC-' || l_next_year, 'DD-MON-YYYY')
                ),
                                                                0)
            where
                    batch_number = l_batch_number
                and ( p_acc_num is null
                      or acc_num = p_acc_num );

        else
            update tax_forms
            set
                prev_yr_deposit = nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                    from
                        income
                    where
                            income.acc_id = tax_forms.acc_id
                        and fee_code in(7, 10)
                        and trunc(income.fee_date) >= to_date('01-JAN-' || l_next_year, 'DD-MON-YYYY')
                        and trunc(income.fee_date) <= to_date('31-DEC-' || l_next_year, 'DD-MON-YYYY')
                ),
                                      0)
            where
                    batch_number = l_batch_number
                and ( p_acc_num is null
                      or acc_num = p_acc_num );

            update tax_forms
            set
                prev_yr_deposit = nvl(prev_yr_deposit, 0) - nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0)) amount
                    from
                        income
                    where
                            income.acc_id = tax_forms.acc_id
                        and fee_code = 130
                        and trunc(income.fee_date) >= least(begin_date,
                                                            nvl(start_fee_date, begin_date))
                        and trunc(income.fee_date) <= end_date
                ),
                                                                0)
            where
                    batch_number = l_batch_number
                and start_fee_date is not null
                and ( p_acc_num is null
                      or acc_num = p_acc_num );

             /*    UPDATE TAX_FORMS
                 SET    PREV_YR_DEPOSIT =PREV_YR_DEPOSIT-nvl((SELECT SUM(NVL(AMOUNT,0)+NVL(AMOUNT_ADD,0)) AMOUNT
                                          FROM INCOME
                                          WHERE INCOME.ACC_ID = TAX_FORMS.ACC_ID
                                          AND   FEE_CODE = 130
                                          AND   TRUNC(INCOME.FEE_DATE) >= TO_DATE('01-JAN-'||l_next_year,'DD-MON-YYYY')
                                          AND   TRUNC(INCOME.FEE_DATE) <= TO_DATE('31-DEC-'||l_next_year,'DD-MON-YYYY')),0)
                 WHERE  BATCH_NUMBER = L_BATCH_NUMBER
                 AND  (P_ACC_NUM IS NULL OR ACC_NUM = P_ACC_NUM);   */
        end if;
         -- Rollover
        update tax_forms
        set
            rollover = nvl((
                select
                    sum(nvl(amount, 0) + nvl(amount_add, 0))
                from
                    income
                where
                        income.acc_id = tax_forms.acc_id
                    and fee_code = 5
                    and trunc(income.fee_date) >= least(begin_date,
                                                        nvl(start_fee_date, begin_date))
                    and trunc(income.fee_date) <= end_date
            ),
                           0)
        where
                batch_number = l_batch_number
            and ( p_acc_num is null
                  or acc_num = p_acc_num );

        delete from tax_forms
        where
                nvl(prev_yr_deposit, 0) + nvl(curr_yr_deposit, 0) + nvl(rollover, 0) = 0
            and current_bal = 0
            and batch_number = l_batch_number
            and ( p_acc_num is null
                  or acc_num = p_acc_num );

		 -- Added by Vanitha for 7920. Insert Tax form generated Event.
        for x in (
            select
                tax_form_id,
                pers_id,
                acc_id
            from
                (
                    select
                        tax_form_id,
                        pers_id,
                        acc_id,
                        count(tax_form_id)
                        over(partition by acc_id) tax_form_count
                    from
                        tax_forms
                    where
                            begin_date = to_date('01-JAN-' || p_tax_year, 'DD-MON-YYYY')
                        and end_date = to_date('31-DEC-' || p_tax_year, 'DD-MON-YYYY')
                        and tax_doc_type = '5498'
                        and trunc(creation_date) = trunc(sysdate)
                        and ( p_acc_num is null
                              or acc_num = p_acc_num )
                )   -- replaced hard coded value with variable by swamy for ticket#7920
            where
                tax_form_count = 1
        ) loop
            pc_notification2.insert_events(
                p_acc_id      => x.acc_id,
                p_pers_id     => x.pers_id,
                p_event_name  => 'TAX_STATEMENT',
                p_entity_type => 'TAX_FORM',
                p_entity_id   => x.tax_form_id
            );
        end loop;
		-- code ends here: 7920. Insert Tax form generated Event.

    end generate_5498;

    procedure generate_1099 (
        p_tax_year in number,
        p_acc_num  in varchar2
    ) is
        l_batch_number number;
    begin
        l_batch_number := batch_num_seq.nextval;
        insert into tax_forms (
            tax_form_id,
            batch_number,
            acc_id,
            pers_id,
            acc_num,
            start_date,
            begin_date,
            end_date,
            tax_doc_type,
            gross_dist
        )
            select
                tax_forms_seq.nextval,
                l_batch_number,
                acc_id,
                pers_id,
                acc_num,
                start_date,
                begin_date,
                end_date,
                '1099',
                gross_dist
            from
                (
                    select
                        l_acc.acc_id,
                        l_acc.pers_id,
                        l_acc.acc_num,
                        l_acc.start_date,
                        to_date('01-JAN-' || p_tax_year, 'DD-MON-YYYY') begin_date,
                        to_date('31-DEC-' || p_tax_year, 'DD-MON-YYYY') end_date,
                        sum(pay.amount)                                 gross_dist
                    from
                        payment pay,
                        account l_acc
                    where
                        ( l_acc.acc_num = p_acc_num
                          or p_acc_num is null )
                        and pay.acc_id = l_acc.acc_id
                        and l_acc.account_type = 'HSA'
                        and pay.reason_code in ( 5, 6, 7, 8, 11,
                                                 12, 13, 19, 60, 27,
                                                 28, 29 )
                        and to_char(pay.pay_date, 'YYYY') = to_char(p_tax_year)
                    group by
                        l_acc.acc_id,
                        l_acc.pers_id,
                        l_acc.acc_num,
                        l_acc.start_date
                    having
                        sum(pay.amount) > 0
                );

     -- Added by Vanitha for 7920. Insert Tax form generated Event.
        for x in (
            select
                tax_form_id,
                pers_id,
                acc_id
            from
                tax_forms
            where
                    begin_date = to_date('01-JAN-' || p_tax_year, 'DD-MON-YYYY')
                and end_date = to_date('31-DEC-' || p_tax_year, 'DD-MON-YYYY')
                and tax_doc_type = '1099'
                and trunc(creation_date) = trunc(sysdate)
        ) loop
            pc_notification2.insert_events(
                p_acc_id      => x.acc_id,
                p_pers_id     => x.pers_id,
                p_event_name  => 'TAX_STATEMENT',
                p_entity_type => 'TAX_FORM',
                p_entity_id   => x.tax_form_id
            );
        end loop;
	 -- code ends here: 7920. Insert Tax form generated Event.

    end generate_1099;

    function get_tax_web (
        p_acc_id in number,
        p_year   in varchar2
    ) return tax_record_t
        pipelined
        deterministic
    is
        l_record_t tax_record_row_t;
        l_count    number := 0;
    begin
        if p_year = 'CURRENT' then
            for x in (
                select
                    pc_account_details.get_current_year_total(acc_id,
                                                              trunc(sysdate, 'YYYY'),
                                                              sysdate,
                                                              start_date) cy,
                    pc_account_details.get_prior_year_total(acc_id,
                                                            trunc(sysdate, 'YYYY'),
                                                            sysdate,
                                                            start_date) py,
                    pc_account_details.get_interest_total(acc_id,
                                                          trunc(sysdate, 'YYYY'),
                                                          sysdate)    interest,
                    pc_account_details.get_disbursement_total(acc_id,
                                                              trunc(sysdate, 'YYYY'),
                                                              sysdate)    disb
                from
                    account
                where
                    acc_id = p_acc_id
            ) loop
                l_record_t.current_year_deposit := nvl(x.cy, 0);
                l_record_t.previous_year_deposit := nvl(x.py, 0);
                l_record_t.interest := nvl(x.interest, 0);
                l_record_t.disbursement := nvl(x.disb, 0);
                l_record_t.tax_year := to_char(sysdate, 'YYYY');
                l_record_t.prev_tax_year := to_char(trunc(sysdate, 'YYYY') - 1,
                                                    'YYYY');

                pipe row ( l_record_t );
            end loop;
        end if;

        if p_year = 'PREVIOUS' then
            for x in (
                select
                    pc_account_details.get_current_year_total(acc_id, begin_date, end_date, start_date) cy,
                    pc_account_details.get_prior_year_total(acc_id, begin_date, end_date, start_date)   py,
                    pc_account_details.get_interest_total(acc_id, begin_date, end_date)                 interest,
                    pc_account_details.get_disbursement_total(acc_id, begin_date, end_date)             disb
                from
                    tax_forms c
                where
                        tax_doc_type = '5498'
                    and tax_form_id = (
                        select
                            max(tax_form_id)
                        from
                            tax_forms d
                        where
                                c.acc_id = d.acc_id
                            and d.tax_doc_type = c.tax_doc_type
                            and d.begin_date = c.begin_date
                            and d.end_date = c.end_date
                    )
                    and acc_id = p_acc_id
                    and begin_date = trunc(trunc(sysdate, 'YYYY') - 1,
                                           'YYYY')
                    and end_date = trunc(sysdate, 'YYYY') - 1
            ) loop
                l_record_t.current_year_deposit := nvl(x.cy, 0);
                l_record_t.previous_year_deposit := nvl(x.py, 0);
                l_record_t.interest := nvl(x.interest, 0);
                l_record_t.disbursement := nvl(x.disb, 0);
                l_record_t.tax_year := to_char(trunc(sysdate, 'YYYY') - 1,
                                               'YYYY');

                l_record_t.prev_tax_year := to_char(trunc(trunc(sysdate, 'YYYY') - 1,
                                                          'YYYY') - 1,
                                                    'YYYY');

                l_count := 1;
                pipe row ( l_record_t );
            end loop;

            if l_count = 0 then
                for x in (
                    select
                        pc_account_details.get_current_year_total(acc_id,
                                                                  trunc(trunc(sysdate, 'YYYY') - 1,
                                                                        'YYYY'),
                                                                  trunc(sysdate, 'YYYY') - 1,
                                                                  start_date)                 cy,
                        pc_account_details.get_prior_year_total(acc_id,
                                                                trunc(trunc(sysdate, 'YYYY') - 1,
                                                                      'YYYY'),
                                                                trunc(sysdate, 'YYYY') - 1,
                                                                start_date)                 py,
                        pc_account_details.get_interest_total(acc_id,
                                                              trunc(trunc(sysdate, 'YYYY') - 1,
                                                                    'YYYY'),
                                                              trunc(sysdate, 'YYYY') - 1) interest,
                        pc_account_details.get_disbursement_total(acc_id,
                                                                  trunc(trunc(sysdate, 'YYYY') - 1,
                                                                        'YYYY'),
                                                                  trunc(sysdate, 'YYYY') - 1) disb
                    from
                        account
                    where
                        acc_id = p_acc_id
                ) loop
                    l_record_t.current_year_deposit := nvl(x.cy, 0);
                    l_record_t.previous_year_deposit := nvl(x.py, 0);
                    l_record_t.interest := nvl(x.interest, 0);
                    l_record_t.disbursement := nvl(x.disb, 0);
                    l_record_t.tax_year := to_char(
                        trunc(trunc(sysdate, 'YYYY') - 1,
                              'YYYY'),
                        'YYYY'
                    );

                    l_record_t.prev_tax_year := to_char(trunc(sysdate, 'YYYY') - 1,
                                                        'YYYY');

                    l_count := 1;
                    pipe row ( l_record_t );
                end loop;

            end if;

        end if;

    end get_tax_web;

    function get_5498_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return tax_5498_t
        pipelined
        deterministic
    is
        l_record_t tax_5498_row_t;
        l_count    number := 0;
    begin
        for x in (
            select
                count(*) cnt
            from
                tax_forms a
            where
                    a.tax_doc_type = '5498'
                and a.acc_num = p_acc_num
                and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
                and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
                and a.batch_number in (
                    select
                        max(batch_number)
                    from
                        tax_forms
                    where
                            a.tax_doc_type = tax_forms.tax_doc_type
                        and a.acc_num = tax_forms.acc_num
                        and begin_date = a.begin_date
                        and end_date = a.end_date
                )
        ) loop
            l_count := x.cnt;
        end loop;
	     ---  strip_bad added each name Ticket #8719 rprabu 11/02/2020
        if l_count > 0 then
            for x in (
                select
                    acc_num,
                    nvl(
                        strip_bad(b.first_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.middle_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.last_name),
                        ''
                    )                      name,
                    b.address,
                    b.city,
                    b.state,
                    b.zip,
                    '***-**-'
                    || substr(b.ssn, 8, 4) ssn,
                    format_money(0)        box1,
                    format_money(nvl(
                        case
                            when a.curr_yr_deposit < 0 then
                                0
                            else a.curr_yr_deposit
                        end, 0))                  box2,
                    format_money(nvl(
                        case
                            when a.prev_yr_deposit < 0 then
                                0
                            else a.prev_yr_deposit
                        end, 0))                  box3,
                    format_money(nvl(
                        case
                            when a.rollover < 0 then
                                0
                            else a.rollover
                        end, 0))                  box4,
                    format_money(nvl(
                        case
                            when a.current_bal < 0 then
                                0
                            else a.current_bal
                        end, 0))                  box5,
                    a.corrected_flag
                from
                    tax_forms a,
                    person    b
                where
                        a.pers_id = b.pers_id
                    and a.tax_doc_type = '5498'
                    and a.acc_num = p_acc_num
                    and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
                    and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
                    and a.batch_number in (
                        select
                            max(batch_number)
                        from
                            tax_forms
                        where
                                a.tax_doc_type = tax_forms.tax_doc_type
                            and a.acc_num = tax_forms.acc_num
                            and begin_date = a.begin_date
                            and end_date = a.end_date
                    )
            ) loop
                l_record_t.acc_num := x.acc_num;
        ---  l_record_t.NAME       := strip_bad(x.NAME);
                l_record_t.name := x.name;   -- strip_bad removed Ticket #8719 rprabu 11/02/2020
                l_record_t.address := x.address;
                l_record_t.city := x.city;
                l_record_t.state := x.state;
                l_record_t.zip := x.zip;
                l_record_t.ssn := x.ssn;
                l_record_t.box1 := x.box1;
                l_record_t.box2 := x.box2;
                l_record_t.box3 := x.box3;
                l_record_t.box4 := x.box4;
                l_record_t.box5 := x.box5;
                l_record_t.corrected := x.corrected_flag;
                pipe row ( l_record_t );
            end loop;

        else
            for x in (
                select
                    a.acc_num,
                    nvl(
                        strip_bad(b.first_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.middle_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.last_name),
                        ''
                    )                      name,
                    b.address,
                    b.city,
                    b.state,
                    b.zip,
                    '***-**-'
                    || substr(b.ssn, 8, 4) ssn,
                    'N'                    corrected_flag
                from
                    account a,
                    person  b
                where
                        a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
            ) loop
                l_record_t.acc_num := x.acc_num;
     ---  l_record_t.NAME       := strip_bad(x.NAME);
                l_record_t.name := x.name;   -- strip_bad removed Ticket #8719 rprabu 11/02/2020
                l_record_t.address := x.address;
                l_record_t.city := x.city;
                l_record_t.state := x.state;
                l_record_t.zip := x.zip;
                l_record_t.ssn := x.ssn;
                l_record_t.box1 := '0.00';
                l_record_t.box2 := '0.00';
                l_record_t.box3 := '0.00';
                l_record_t.box4 := '0.00';
                l_record_t.box5 := '0.00';
                l_record_t.corrected := x.corrected_flag;
                pipe row ( l_record_t );
            end loop;
        end if;

    end get_5498_web;

    function get_1099_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return tax_1099_t
        pipelined
        deterministic
    is
        l_record_t tax_1099_row_t;
        l_count    number := 0;
    begin
        for x in (
            select
                count(*) cnt
            from
                tax_forms a
            where
                    a.tax_doc_type = '1099'
                and a.acc_num = p_acc_num
                and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
                and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
                and a.batch_number in (
                    select
                        max(batch_number)
                    from
                        tax_forms
                    where
                            a.tax_doc_type = tax_forms.tax_doc_type
                        and a.acc_num = tax_forms.acc_num
                        and begin_date = a.begin_date
                        and end_date = a.end_date
                )
        ) loop
            l_count := x.cnt;
        end loop;

        if l_count > 0 then
            for x in (
                select
                    acc_num,
                    nvl(
                        strip_bad(b.first_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.middle_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.last_name),
                        ''
                    )                          name,
                    b.address,
                    b.city,
                    b.state,
                    b.zip,
                    '***-**-'
                    || substr(b.ssn, 8, 4)     ssn,
                    format_money(a.gross_dist) gross_dist,
                    format_money(0.00)         earn_on_excess,
                    format_money(0.00)         fmv_on_dod,
                    a.corrected_flag
                from
                    tax_forms a,
                    person    b
                where
                        a.pers_id = b.pers_id
                    and a.tax_doc_type = '1099'
                    and a.acc_num = p_acc_num
                    and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
                    and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
                    and a.batch_number in (
                        select
                            max(batch_number)
                        from
                            tax_forms
                        where
                                a.tax_doc_type = tax_forms.tax_doc_type
                            and a.acc_num = tax_forms.acc_num
                            and begin_date = a.begin_date
                            and end_date = a.end_date
                    )
            ) loop
                l_record_t.acc_num := x.acc_num;
           ---  l_record_t.NAME       := strip_bad(x.NAME);
                l_record_t.name := x.name;   -- strip_bad removed Ticket #8719 rprabu 11/02/2020
                l_record_t.address := x.address;
                l_record_t.city := x.city;
                l_record_t.state := x.state;
                l_record_t.zip := x.zip;
                l_record_t.ssn := x.ssn;
                l_record_t.gross_dist := x.gross_dist;
                l_record_t.earn_on_excess := x.earn_on_excess;
                l_record_t.fmv_on_dod := x.fmv_on_dod;
                l_record_t.corrected := x.corrected_flag;
                pipe row ( l_record_t );
            end loop;

        else
            for x in (
                select
                    a.acc_num,
                    nvl(
                        strip_bad(b.first_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.middle_name),
                        ''
                    )
                    || ' '
                    || nvl(
                        strip_bad(b.last_name),
                        ''
                    )                      name,
                    b.address,
                    b.city,
                    b.state,
                    b.zip,
                    '***-**-'
                    || substr(b.ssn, 8, 4) ssn,
                    format_money(0.00)     gross_dist,
                    format_money(0.00)     earn_on_excess,
                    format_money(0.00)     fmv_on_dod,
                    'N'                    corrected_flag
                from
                    account a,
                    person  b
                where
                        a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.name := x.name;
                l_record_t.address := x.address;
                l_record_t.city := x.city;
                l_record_t.state := x.state;
                l_record_t.zip := x.zip;
                l_record_t.ssn := x.ssn;
                l_record_t.gross_dist := x.gross_dist;
                l_record_t.earn_on_excess := x.earn_on_excess;
                l_record_t.fmv_on_dod := x.fmv_on_dod;
                l_record_t.corrected := x.corrected_flag;
                pipe row ( l_record_t );
            end loop;
        end if;

    end get_1099_web;

    procedure regenerate_5498 as

        l_tax_year varchar2(10) := to_char(trunc(sysdate, 'YYYY') - 1,
                                           'YYYY');
    begin
 -- IF TRUNC(SYSDATE) <= GET_TAX_DAY THEN
        for x in (
            select
                b.acc_num
            from
                income  a,
                account b
            where
                    a.acc_id = b.acc_id
                and a.fee_code in ( 7, 10, 130 )
                and trunc(a.fee_date) between trunc(trunc(sysdate, 'YYYY') - 1,
                                                    'YYYY') and trunc(sysdate, 'YYYY') - 1
                and ( trunc(a.creation_date) >= trunc(sysdate) - 1
                      or trunc(a.last_updated_date) >= trunc(sysdate) - 1 )
            union
            select
                b.acc_num
            from
                income  a,
                account b
            where
                    a.acc_id = b.acc_id
                and a.fee_code in ( 7, 10, 130 )
                and trunc(a.fee_date) between trunc(sysdate, 'YYYY') and sysdate
                and ( trunc(a.creation_date) >= trunc(sysdate) - 1
                      or trunc(a.last_updated_date) >= trunc(sysdate) - 1 )
        ) loop
            pc_tax_form.generate_5498(l_tax_year,
                                      to_char(sysdate, 'MON'),
                                      x.acc_num); -- 2012
        end loop;

        pc_notifications.send_email_on_5498;
 --END IF;
    end;

    procedure insert_5500_report (
        p_entrp_id    in number,
        p_ben_plan_id in number,
        p_acc_id      in number,
        p_report_type in varchar2,
        p_user_id     in number
    ) is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            tax_forms
        where
                tax_doc_type = p_report_type
            and entrp_id = p_entrp_id
            and ben_plan_id = p_ben_plan_id
            and acc_id = p_acc_id;

        if l_count = 0 then
            insert into tax_forms (
                tax_form_id,
                entrp_id,
                acc_id,
                ben_plan_id,
                tax_doc_type,
                creation_date,
                last_update_date
            ) values ( tax_forms_seq.nextval,
                       p_entrp_id,
                       p_acc_id,
                       p_ben_plan_id,
                       p_report_type,
                       sysdate,
                       sysdate );

        end if;

    end insert_5500_report;

end pc_tax_form;
/

