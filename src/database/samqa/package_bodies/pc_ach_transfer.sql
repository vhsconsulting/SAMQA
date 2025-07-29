create or replace package body samqa.pc_ach_transfer is

    procedure ins_ach_transfer (
        p_acc_id           in number,
        p_bank_acct_id     in number,
        p_transaction_type in varchar2,
        p_amount           in number default 0,
        p_fee_amount       in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_status           in varchar2,
        p_user_id          in number,
        p_pay_code         in number default 5,
        x_transaction_id   out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        setup_error exception;
        l_claim_id     number;
        l_pay_code     number := 5;
        l_ach_source   varchar2(30) := 'ONLINE';
        l_account_type varchar2(50);
        l_pers_id      number;
    begin
        x_return_status := 'S';
        l_pay_code := p_pay_code;
        select
            decode(p_acc_id, null, 'Account number cannot be null', 'xx')
            || decode(p_bank_acct_id, null, 'Bank Information cannot be null', 'xx')
            || decode(p_transaction_type, null, 'Transaction Type cannot be null', 'xx')
            || decode(p_reason_code, null, 'Reason code cannot be null', 'xx')
        into x_error_message
        from
            dual;

        pc_log.log_error('INS_ACH_TRANSFER', 'p_acc_id' || p_acc_id);
        if
            x_error_message not like 'xx%'
            and x_error_message is not null
        then
            raise setup_error;
        end if;
        x_error_message := null;
        if p_transaction_date < trunc(sysdate) then
            x_error_message := 'Enter valid transaction date , Transaction date has to be greater than todays date';
            raise setup_error;
        end if;

        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for transaction amount';
            raise setup_error;
        end if;

        if is_number(p_fee_amount) = 'N' then
            x_error_message := 'Enter only numeric values for fee amount';
            raise setup_error;
        end if;

        pc_log.log_error('INS_ACH_TRANSFER', 'transaction type ' || p_transaction_type);
        pc_log.log_error('INS_ACH_TRANSFER', 'Transaction date ' || p_transaction_date);

     -- Added by Joshi for 12553.
        for x in (
            select
                account_type,
                pers_id
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_account_type := x.account_type;
            l_pers_id := x.pers_id;
        end loop;

     --IF p_transaction_type = 'C' AND p_reason_code <> 5 THEN -- Vanitha: added on 04/25
    -- commented above and added below by Joshi for 12553.
        if
            p_transaction_type = 'C'
            and p_reason_code <> 5
            and l_account_type = 'HSA'
            and l_pers_id is not null
        then -- Vanitha: added on 04/25

            if p_transaction_date > add_months(
                trunc(sysdate, 'YYYY'),
                12
            ) - 1 then
                for x in (
                    select
                        pc_fin.receipts(a.acc_id,
                                        decode(p_reason_code, 7, sysdate, p_transaction_date))                                      receipts
                                        ,
                        pc_fin.contribution_limit(a.pers_id,
                                                  decode(p_reason_code, 7, sysdate, p_transaction_date))                                      contribution_limit
                                                  ,
                        get_pending_balance(a.acc_id,
                                            last_day(add_months(
                            trunc(p_transaction_date, 'YYYY'),
                            11
                        )),
                                            p_reason_code)                                                                 pending_amount
                                            ,
                        pc_account.fee_bucket_balance(a.acc_id, to_date('01-jan-2004', 'dd-mon-yyyy'), p_transaction_date) fee_bucket  -- added by swamy for ticket#12369
                        ,
                        a.account_type  -- added by swamy for ticket#12369
                    from
                        account a,
                        person  b
                    where
                            a.pers_id = b.pers_id
                        and a.pers_id is not null
                        and a.account_type <> 'COBRA'
                        and a.acc_id = p_acc_id
                ) loop
                    if
                        x.contribution_limit is not null
                        and nvl(x.receipts, 0) + nvl(x.pending_amount, 0) + p_amount > nvl(x.contribution_limit, g_contribution_limit
                        )
                    then
                        x_error_message := 'Cannot contribute more than annual limit of '
                                           || x.contribution_limit
                                           || ' set by IRS ';
                        raise setup_error;
                    elsif nvl(x.receipts, 0) + nvl(x.pending_amount, 0) + p_amount > g_contribution_limit then
                        x_error_message := 'Cannot contribute more than the annual limit set by IRS for the year ' || to_char(p_transaction_date
                        , 'YYYY');
                        raise setup_error;
                /*elsif (x.account_type = 'HSA' AND (nvl(x.fee_bucket,0) + NVL(x.pending_amount,0)+p_amount > g_hsa_fee_bucket_limit)) THEN  -- added by swamy for ticket#12369
                    x_error_message := 'Cannot contribute more than the fee bucket balance of 120';
                   RAISE setup_error;*/

                    end if;
                end loop;

            else
                for x in (
                    select
                        pc_fin.receipts(a.acc_id,
                                        decode(p_reason_code,
                                               7,
                                               trunc(sysdate, 'YYYY') - 1,
                                               sysdate))                                                                            receipts
                                               ,
                        pc_fin.contribution_limit(a.pers_id,
                                                  decode(p_reason_code,
                                                         7,
                                                         trunc(sysdate, 'YYYY') - 1,
                                                         sysdate))                                                                            contribution_limit
                                                         ,
                        get_pending_balance(a.acc_id,
                                            last_day(add_months(
                            trunc(sysdate, 'YYYY'),
                            11
                        )),
                                            p_reason_code)                                                                 pending_amount
                                            ,
                        pc_account.fee_bucket_balance(a.acc_id, to_date('01-jan-2004', 'dd-mon-yyyy'), p_transaction_date) fee_bucket  -- added by swamy for ticket#12369
                        ,
                        a.account_type  -- added by swamy for ticket#12369
                    from
                        account a,
                        person  b
                    where
                            a.pers_id = b.pers_id
                        and a.pers_id is not null
                        and a.account_type <> 'COBRA'
                        and a.acc_id = p_acc_id
                ) loop
                    if nvl(x.receipts, 0) + nvl(x.pending_amount, 0) + p_amount > nvl(x.contribution_limit, g_contribution_limit) then
                        x_error_message := 'Cannot contribute more than annual limit of '
                                           || nvl(x.contribution_limit, g_contribution_limit)
                                           || ' set by IRS ';
                        raise setup_error;
            /*elsif (x.account_type = 'HSA' AND (nvl(x.fee_bucket,0) + NVL(x.pending_amount,0)+p_amount > g_hsa_fee_bucket_limit)) THEN  -- added by swamy for ticket#12369
                x_error_message := 'Cannot contribute more than the fee bucket balance of 120';
               RAISE setup_error;*/
                    end if;
                end loop;
            end if;
        end if;

        if p_transaction_type = 'D' then -- Vanitha: added on 04/25
            for x in (
                select
                    account_status
                from
                    account
                where
                    acc_id = p_acc_id
            ) loop
                if x.account_status = 3 then
                    x_error_message := 'Your account has not been activated yet, You cannot schedule Disbursement at this time';
                    raise setup_error;
                end if;
            end loop;
        end if;

        if p_pay_code = 10 then
            l_pay_code := 5;
            l_ach_source := 'MOBILE';
        end if;
        if p_user_id in ( - 99, - 98 ) then
            l_pay_code := 5;
            l_ach_source := 'PRIVATE_LABEL';
        end if;

        pc_log.log_error('INS_ACH_TRANSFER', 'Transaction date ' || p_transaction_date);
        insert into ach_transfer (
            transaction_id,
            acc_id,
            bank_acct_id,
            transaction_type,
            amount,
            fee_amount,
            total_amount,
            transaction_date,
            reason_code,
            status,
            pay_code,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date,
            ach_source
        ) values ( ach_transfer_seq.nextval,
                   p_acc_id,
                   p_bank_acct_id,
                   p_transaction_type,
                   p_amount,
                   p_fee_amount,
                   nvl(p_amount, 0) + nvl(p_fee_amount, 0),
                   p_transaction_date,
                   p_reason_code,
                   p_status,
                   nvl(l_pay_code, 5),
                   p_user_id,
                   p_user_id,
                   sysdate,
                   sysdate,
                   nvl(l_ach_source, 'ONLINE') ) returning transaction_id into x_transaction_id;

        pc_log.log_error('INS_ACH_TRANSFER', 'x_transaction_id'
                                             || x_transaction_id
                                             || 'status '
                                             || x_return_status);
        if
            p_user_id in ( - 99, - 98 )
            and p_transaction_type = 'D'
        then
            for x in (
                select
                    *
                from
                    ach_transfer_v
                where
                        transaction_id = x_transaction_id
                    and status = 2
            ) loop
                if x.claim_id is null then
           -- Commented out as part of the HSA claim redesign flow: HEX project
                    l_claim_id := doc_seq.nextval;
                    insert into payment_register (
                        payment_register_id,
                        batch_number,
                        acc_num,
                        acc_id,
                        pers_id,
                        provider_name,
                        claim_code,
                        claim_id,
                        trans_date,
                        gl_account,
                        cash_account,
                        claim_amount,
                        claim_type,
                        peachtree_interfaced,
                        check_number,
                        note
                    )
                        select
                            payment_register_seq.nextval,
                            batch_num_seq.nextval,
                            x.acc_num,
                            x.acc_id,
                            x.pers_id,
                            'eDisbursement',
                            upper(substr(b.last_name, 1, 4))
                            || to_char(sysdate, 'YYYYMMDDHHMISS')
                            || x.transaction_id,
                            l_claim_id,
                            sysdate,
                            (
                                select
                                    account_num
                                from
                                    payment_acc_info
                                where
                                        account_type = 'GL_ACCOUNT'
                                    and status = 'A'
                            ),
                            nvl((
                                select
                                    account_num
                                from
                                    payment_acc_info
                                where
                                    substr(account_type, 1, 3) like substr(x.acc_num, 1, 3)
                                                                    || '%'
                                    and status = 'A'
                            ),
                                (
                                select
                                    account_num
                                from
                                    payment_acc_info
                                where
                                        substr(account_type, 1, 3) = 'SHA'
                                    and status = 'A'
                            )),
                            x.total_amount,
                            'ONLINE',
                            'Y',
                            x_transaction_id,
                            'Online Disbursement'
                        from
                            person b
                        where
                                b.pers_id = x.pers_id
                            and not exists (
                                select
                                    *
                                from
                                    payment_register
                                where
                                    claim_code like upper(substr(b.last_name, 1, 4))
                                                    || '%'
                                                    || x.transaction_id
                            );

                    insert into claimn (
                        claim_id,
                        pers_id,
                        pers_patient,
                        claim_code,
                        prov_name,
                        claim_date_start,
                        claim_date_end,
                        service_status,
                        claim_amount,
                        claim_paid,
                        claim_pending,
                        note,
                        bank_acct_id,
                        vendor_id,
                        pay_reason
                    )
                        select
                            claim_id,
                            pers_id,
                            pers_id,
                            claim_code,
                            provider_name,
                            sysdate,
                            trans_date,
                            nvl(x.reason_code, 3),
                            claim_amount,
                            claim_amount,
                            0,
                            'Disbursement Created for ' || to_char(sysdate, 'YYYYMMDD'),
                            bank_acct_id,
                            vendor_id,
                            pay_reason
                        from
                            payment_register a
                        where
                                a.acc_id = x.acc_id
                            and a.claim_id = l_claim_id
                            and a.check_number = x_transaction_id
                            and not exists (
                                select
                                    *
                                from
                                    claimn
                                where
                                    claim_id = a.claim_id
                            );

                    update ach_transfer
                    set
                        claim_id = l_claim_id
                    where
                        transaction_id = x_transaction_id;

                end if;
            end loop;
        end if;

    exception
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('INS_ACH_TRANSFER', 'x_error_message ' || x_error_message);
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
            pc_log.log_error('INS_ACH_TRANSFER', 'sqlerrm ' || sqlerrm);
    end ins_ach_transfer;

    procedure upd_ach_transfer (
        p_transaction_id   in number,
        p_transaction_type in varchar2,
        p_amount           in number default 0,
        p_fee_amount       in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_user_id          in number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is
        setup_error exception;
        l_contribution_limit number;
        l_account_type       varchar2(50);
        l_pers_id            number;
    begin
        x_return_status := 'S';
        if p_transaction_id is null then
            x_error_message := 'Transaction ID cannot be null ';
        elsif p_transaction_type is null then
            x_error_message := 'Transaction type cannot be null ';
        elsif p_reason_code is null then
            x_error_message := 'Reason code cannot be null ';
        elsif p_transaction_date < trunc(sysdate) then
            x_error_message := 'Enter valid transaction date , Transaction date has to be greater than todays date';
        end if;

        if x_error_message is not null then
            raise setup_error;
        end if;
        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for transaction amount';
            raise setup_error;
        end if;

        if is_number(p_fee_amount) = 'N' then
            x_error_message := 'Enter only numeric values for fee amount';
            raise setup_error;
        end if;

  -- Added by Joshi for 12553.
        for x in (
            select
                acc.account_type,
                acc.pers_id
            from
                account      acc,
                ach_transfer ach
            where
                    acc.acc_id = ach.acc_id
                and ach.transaction_id = p_transaction_id
        ) loop
            l_account_type := x.account_type;
            l_pers_id := x.pers_id;
        end loop;

       --IF p_transaction_type = 'C' AND p_reason_code <> 5 THEN -- Vanitha: added on 04/25
        -- commented above and added below by Joshi for 12553.   
        if
            p_transaction_type = 'C'
            and p_reason_code <> 5
            and l_account_type = 'HSA'
            and l_pers_id is not null
        then
            if p_transaction_date < add_months(
                trunc(sysdate, 'YYYY'),
                12
            ) then
                for x in (
                    select
                        pc_fin.receipts(a.acc_id,
                                        decode(p_reason_code,
                                               7,
                                               trunc(sysdate, 'YYYY') - 1,
                                               sysdate))                             receipts,
                        pc_fin.contribution_limit(a.pers_id,
                                                  decode(p_reason_code,
                                                         7,
                                                         trunc(sysdate, 'YYYY') - 1,
                                                         sysdate))                             contribution_limit,
                        get_pending_balance(a.acc_id,
                                            last_day(add_months(
                            trunc(sysdate, 'YYYY'),
                            11
                        )),
                                            c.reason_code) - c.total_amount pending_amount
                    from
                        account      a,
                        person       b,
                        ach_transfer c
                    where
                            a.pers_id = b.pers_id
                        and a.pers_id is not null
                        and a.acc_id = c.acc_id
                        and c.transaction_id = p_transaction_id
                ) loop
                    if nvl(x.contribution_limit, 0) = 0 then
                        l_contribution_limit := g_contribution_limit;
                    end if;

                    if nvl(x.receipts, 0) + nvl(x.pending_amount, 0) + p_amount > nvl(l_contribution_limit, g_contribution_limit) then
                        x_error_message := 'You have exceeded your contribution limit of '
                                           || nvl(l_contribution_limit, g_contribution_limit)
                                           || ' set by the IRS ';
                        raise setup_error;
                    end if;

                end loop;

            else
                for x in (
                    select
                        pc_fin.receipts(a.acc_id,
                                        decode(p_reason_code, 7, sysdate, p_transaction_date)) receipts,
                        pc_fin.contribution_limit(a.pers_id,
                                                  decode(p_reason_code, 7, sysdate, p_transaction_date)) contribution_limit,
                        get_pending_balance(a.acc_id,
                                            last_day(add_months(
                            trunc(p_transaction_date, 'YYYY'),
                            11
                        )),
                                            c.reason_code) - c.total_amount           pending_amount
                    from
                        account      a,
                        person       b,
                        ach_transfer c
                    where
                            a.pers_id = b.pers_id
                        and a.pers_id is not null
                        and a.acc_id = c.acc_id
                        and c.transaction_id = p_transaction_id
                ) loop
                    if nvl(x.receipts, 0) + nvl(x.pending_amount, 0) + p_amount > nvl(l_contribution_limit, g_contribution_limit) then
                        x_error_message := 'Cannot contribute more than the annual limit set by IRS for the year ' || to_char(p_transaction_date
                        , 'YYYY');
                        raise setup_error;
                    end if;
                end loop;
            end if;
        end if;

        if p_transaction_type = 'D' then -- Vanitha: added on 04/25
            for x in (
                select
                    account_status
                from
                    account      a,
                    ach_transfer b
                where
                        a.acc_id = b.acc_id
                    and b.transaction_id = p_transaction_id
            ) loop
                if x.account_status = 3 then
                    x_error_message := 'Your account has not been activated yet, You cannot schedule Disbursement at this time';
                    raise setup_error;
                end if;
            end loop;
        end if;

        update ach_transfer
        set
            transaction_type = p_transaction_type,
            amount = nvl(p_amount, 0),
            fee_amount = nvl(p_fee_amount, 0),
            total_amount = nvl(p_amount, 0) + nvl(p_fee_amount, 0),
            transaction_date = p_transaction_date,
            reason_code = p_reason_code,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                transaction_id = p_transaction_id
            and status in ( 1, 2 );

        if sql%rowcount = 0 then
            x_error_message := 'Processed/Cancelled disbursements cannot be modified';
            raise setup_error;
        end if;
    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end upd_ach_transfer;

    procedure delete_ach_transfer (
        p_transaction_id in number,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
    begin
        x_return_status := 'S';
        delete from ach_transfer
        where
            transaction_id = p_transaction_id;

        delete from ach_transfer_details
        where
            transaction_id = p_transaction_id;

    exception
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end delete_ach_transfer;

    procedure cancel_ach_transfer (
        p_transaction_id in number,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
    begin
        x_return_status := 'S';
        update ach_transfer
        set
            status = 9,
            last_updated_by = p_user_id,
            last_update_date = sysdate,
            bankserv_status = 'USER_CANCELLED'
        where
                transaction_id = p_transaction_id
            and status in ( 1, 2, 9 );

    exception
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end cancel_ach_transfer;

    procedure void_invoice (
        p_invoice_id in number,
        p_user_id    in number
    ) is
    begin
        update ach_transfer
        set
            status = 9,
            last_updated_by = p_user_id,
            last_update_date = sysdate,
            bankserv_status = 'VOID'
        where
                invoice_id = p_invoice_id
            and status in ( 1, 2 );

    end void_invoice;

    function get_pending_balance (
        p_acc_id      in number,
        p_end_date    in date,
        p_reason_code in number
    ) return number is
        l_balance number;
    begin
        if p_reason_code = 7 then
            for x in (
                select
                    sum(nvl(amount, 0)) amount
                from
                    ach_transfer
                where
                        acc_id = p_acc_id
                    and transaction_date <= trunc(p_end_date)
                    and to_char(transaction_date, 'YYYY') = to_char(p_end_date, 'YYYY')
                    and status in ( 1, 2 )
                    and transaction_type = 'C'
                    and reason_code = p_reason_code
            ) loop
                l_balance := x.amount;
            end loop;
        else
            for x in (
                select
                    sum(nvl(amount, 0)) amount
                from
                    ach_transfer
                where
                        acc_id = p_acc_id
                    and transaction_date <= trunc(p_end_date)
                    and to_char(transaction_date, 'YYYY') = to_char(p_end_date, 'YYYY')
                    and status in ( 1, 2 )
                    and transaction_type = 'C'
                    and reason_code <> 7
            ) loop
                l_balance := x.amount;
            end loop;
        end if;

        return nvl(l_balance, 0);
    end get_pending_balance;

    procedure ins_ach_transfer_hrafsa (
        p_acc_id           in number,
        p_bank_acct_id     in number,
        p_transaction_type in varchar2,
        p_amount           in number default 0,
        p_fee_amount       in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_status           in varchar2,
        p_user_id          in number,
        p_claim_id         in number,
        p_plan_type        in varchar2,
        p_pay_code         in number default 5,
        x_transaction_id   out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is
        setup_error exception;
        l_claim_count number := 0;
    begin
        x_return_status := 'S';
        select
            decode(p_acc_id, null, 'Account number cannot be null', 'xx')
            || decode(p_bank_acct_id, null, 'Bank Information cannot be null', 'xx')
            || decode(p_transaction_type, null, 'Transaction Type cannot be null', 'xx')
            || decode(p_reason_code, null, 'Reason code cannot be null', 'xx')
        into x_error_message
        from
            dual;

        if
            x_error_message not like 'xx%'
            and x_error_message is not null
        then
            raise setup_error;
        end if;
        x_error_message := null;
        if p_transaction_date < trunc(sysdate) then
            x_error_message := 'Enter valid transaction date , Transaction date has to be greater than todays date';
            raise setup_error;
        end if;

        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for transaction amount';
            raise setup_error;
        end if;

        if is_number(p_fee_amount) = 'N' then
            x_error_message := 'Enter only numeric values for fee amount';
            raise setup_error;
        end if;

    /*  SELECT  COUNT(*)
      INTO    l_claim_count
      FROM    ACH_TRANSFER
      WHERE   total_amount >= NVL(p_amount,0)+NVL(p_fee_amount,0)
      AND     claim_id = p_claim_id;*/
        if l_claim_count = 0 then
            insert into ach_transfer (
                transaction_id,
                acc_id,
                bank_acct_id,
                transaction_type,
                amount,
                fee_amount,
                total_amount,
                transaction_date,
                reason_code,
                status,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                claim_id,
                plan_type,
                pay_code
            ) values ( ach_transfer_seq.nextval,
                       p_acc_id,
                       p_bank_acct_id,
                       p_transaction_type,
                       p_amount,
                       p_fee_amount,
                       nvl(p_amount, 0) + nvl(p_fee_amount, 0),
                       p_transaction_date,
                       p_reason_code,
                       p_status,
                       p_user_id,
                       p_user_id,
                       sysdate,
                       sysdate,
                       p_claim_id,
                       p_plan_type,
                       p_pay_code ) returning transaction_id into x_transaction_id;

        end if;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end ins_ach_transfer_hrafsa;

    function get_bank_acct_id (
        p_transaction_id in number
    ) return number is
        l_bank_acct_id number;
    begin
        for x in (
            select
                bank_acct_id
            from
                user_bank_acct
            where
                bank_acct_id = p_transaction_id
        ) loop
            l_bank_acct_id := x.bank_acct_id;
        end loop;

        return l_bank_acct_id;
    end get_bank_acct_id;

    function is_pending_txn (
        p_transaction_id in number,
        p_acc_id         in number
    ) return varchar2 is
    begin
        for x in (
            select
                count(*) cnt
            from
                income
            where
                    cc_number = 'CNB' || p_transaction_id  -- Replaced BankServ with CNB by Swamy for Ticket#7723(Nacha)
                and acc_id = p_acc_id
                and transaction_type = 'P'
        ) loop
            if x.cnt > 0 then
                return 'Y';
            end if;
        end loop;

        return 'N';
    end is_pending_txn;

    procedure reprocess_declines is
    begin
        for x in (
            select
                transaction_id
            from
                ach_transfer
            where
                transaction_id in ( 563832, 562847, 563966, 563852, 563834,
                                    563326, 563967, 561807, 563319, 563166,
                                    563167, 563810, 539496, 563728, 563410,
                                    560454, 561946, 563691, 563749, 564104,
                                    564066, 563226, 563686, 560449, 564030,
                                    561987, 558026, 560230, 564006, 559347,
                                    563692, 563333, 563250, 563787, 563851,
                                    557341, 536977, 563833, 560219, 563171,
                                    563318, 560228, 563426, 563367, 540886,
                                    563466, 518869, 563841, 559946, 563807,
                                    563768, 563811, 560508, 560231, 563827,
                                    563771, 563773, 559271, 562066, 564088,
                                    560306, 563789, 563814, 564049, 560458,
                                    560461, 559248, 564126, 563335, 539826,
                                    528728, 560460, 563069, 563828, 555066,
                                    536375, 563987, 563772, 540885, 529640,
                                    561388, 560450, 561066, 563767, 498311,
                                    563812, 563829, 549926, 556986, 560928,
                                    563210, 565417, 564787, 565240, 565236,
                                    564768, 564233, 565048, 565220, 563628,
                                    565257, 565166, 546607, 563369, 565069,
                                    565075, 565076, 564707, 565070, 565248,
                                    564706, 564886, 564891, 564634, 564636,
                                    564633, 564631, 565216, 565126, 565087,
                                    565106, 565009, 565146, 563747, 563748,
                                    564232, 565127, 565214, 542527 )
        ) loop
            update ach_transfer
            set
                status = '3',
                processed_date = sysdate,
                bankserv_status = 'APPROVED'
            where
                transaction_id = x.transaction_id;

            pc_auto_process.post_ach_deposits(x.transaction_id);
        end loop;
    end;

    function get_bankserv_pin (
        p_account_type in varchar2
    ) return varchar2 is
        l_bankserv_pin varchar2(2000);
    begin
        for x in (
            select
                bankserv_pin
            from
                bankserv_pins
            where
                    nvl(account_type, '-1') = nvl(p_account_type, '-1')
                and status = 'A'
                and transaction_type = 'BANKSERV'
        ) loop
            l_bankserv_pin := x.bankserv_pin;
        end loop;

        return l_bankserv_pin;
    end get_bankserv_pin;

    procedure update_ach_status (
        p_transaction_id   in number,
        p_ach_status       in varchar2,
        p_response_message in varchar2,
        x_error_message    out varchar2
    ) is
    begin
        x_error_message := '';
        if p_ach_status = 'A01' then
            update ach_transfer
            set
                status = '3',
                processed_date = sysdate,
                bankserv_status = 'APPROVED',
                error_message = p_response_message
            where
                transaction_id = p_transaction_id;

            pc_auto_process.post_ach_deposits(p_transaction_id);
        else
            update ach_transfer
            set
                status = '3',
                processed_date = sysdate,
                bankserv_status = 'DECLINED',
                error_message = p_response_message
            where
                transaction_id = p_transaction_id;

        end if;

    exception
        when others then
            x_error_message := 'Error in updating SAM' || sqlerrm;
    end update_ach_status;

end pc_ach_transfer;
/


-- sqlcl_snapshot {"hash":"d56af05766b977581d52f6d2005bc553c5d202b8","type":"PACKAGE_BODY","name":"PC_ACH_TRANSFER","schemaName":"SAMQA","sxml":""}