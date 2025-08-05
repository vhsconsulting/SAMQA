-- liquibase formatted sql
-- changeset SAMQA:1754373979656 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_claim.sql:null:19ccb6c07d4fd8108c203a434a7deaabde88526b:create

create or replace package body samqa.pc_claim is

    procedure cancel_ach_eclaim (
        p_transaction_id in number,
        p_note           in varchar2,
        p_user_id        in number
    ) is
        l_claim_id     number;
        l_acc_id       account.acc_id%type;  -- Added by swamy for Ticket#9912 on 10/08/2021
        l_account_type varchar2(10);   -- Added by swamy for Ticket#9912 on 10/08/2021
    begin
        update ach_transfer
        set
            status = 9,
            bankserv_status = 'DECLINED',
            error_message = p_note,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            transaction_id = p_transaction_id
        returning claim_id,
                  acc_id into l_claim_id, l_acc_id;

   -- Start Added by swamy for Ticket#9912
        l_account_type := pc_account.get_account_type(l_acc_id);
        if l_account_type = 'LSA' then
            delete from payment b
            where
                claimn_id = l_claim_id;

            update payment_register
            set
                cancelled_flag = 'Y',
                claim_error_flag = 'Y',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = l_claim_id;

            update claimn
            set
                claim_status = 'DECLINED',
                denied_amount = claim_paid         -- For Ticket# 10429
                ,
                claim_pending = approved_amount    -- For Ticket# 10429
                ,
                claim_paid = 0                  -- For Ticket# 10429
                ,
                reviewed_date = sysdate,
                reviewed_by = p_user_id
            where
                claim_id = l_claim_id;

     -- End of addition by swamy for Ticket#9912
        else
            update claimn
            set
                claim_status = 'DECLINED',
                reviewed_date = sysdate,
                reviewed_by = p_user_id
            where
                claim_id = l_claim_id;

        end if;
  /* -- Start Added by swamy for Ticket#9912
   l_account_type := pc_account.get_account_type(l_acc_id);
   IF l_account_type = 'LSA' then
           DELETE FROM PAYMENT b
           WHERE  claimn_id = l_claim_id;

           UPDATE payment_register
             SET  cancelled_flag = 'Y'
               ,  claim_error_flag = 'Y'
               ,  last_update_date = SYSDATE
               ,  last_updated_by = p_user_id
           WHERE claim_id =  l_claim_id;
   END IF;
   -- End of addition by swamy for Ticket#9912
*/
    exception
        when others then
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/
            raise;
    end cancel_ach_eclaim;

    procedure cancel_invalid_bank_txns (
        p_bank_acct_id in number,
        p_note         in varchar2,
        p_user_id      in number
    ) is
        l_invoice_id number;
    begin
        for x in (
            select
                a.claim_id,
                a.service_type,
                a.claim_status
            from
                claimn           a,
                payment_register b
            where
                    a.claim_id = b.claim_id
                and b.bank_acct_id = p_bank_acct_id
                and a.claim_status not in ( 'PAID', 'DENIED', 'ERROR', 'CANCELLED' )
        ) loop
            if x.claim_status = 'PARTIALLY_PAID' then
                update claimn
                set
                    denied_amount = claim_pending,
                    denied_reason = 'INACTIVE_BANK_ACCOUNT',
                    reviewed_date = sysdate,
                    reviewed_by = p_user_id,
                    claim_pending = 0,
                    approved_amount = claim_paid
                where
                        claim_id = x.claim_id
                    and service_type <> 'HSA';

            else
                update claimn
                set
                    claim_status = 'DENIED',
                    denied_amount = claim_amount,
                    denied_reason = 'INACTIVE_BANK_ACCOUNT',
                    reviewed_date = sysdate,
                    reviewed_by = p_user_id
                where
                        claim_id = x.claim_id
                    and service_type <> 'HSA'
                    and claim_status not in ( 'DENIED', 'ERROR', 'CANCELLED', 'PROCESSED' );

            end if;
        end loop;

        update ach_transfer
        set
            status = 9,
            bankserv_status = 'DECLINED',
            error_message = 'Declined because of invalid bank account',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                bank_acct_id = p_bank_acct_id
            and status in ( 1, 2, 6 );    -- 6 Added by Swamy for Ticket#12309

 -- Added code by Joshi for #11276. update the invoice setting ACH_PUSH whererever bank account used.
        update invoice_parameters
        set
            payment_method = 'ACH_PUSH',
            payment_term = 'NET15', -- added by Jaggi #11437
            autopay = 'N',
            bank_acct_id = null,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                bank_acct_id = p_bank_acct_id
            and status = 'A';

   -- Added by Swamy #12309 
        for j in (
            select
                invoice_id
            from
                ar_invoice
            where
                    bank_acct_id = p_bank_acct_id
                and status = 'IN_PROCESS'
        ) loop
            update ar_invoice_lines
            set
                status = 'PROCESSED'
            where
                    invoice_id = j.invoice_id
                and status = 'IN_PROCESS';

        end loop;

-- added by Jaggi #11276 and #11281
        update ar_invoice
        set
            payment_method = 'ACH_PUSH',
            invoice_term = 'NET15', -- added by Jaggi #11437
            status = decode(status, 'IN_PROCESS', 'PROCESSED', status),
            auto_pay = 'N',
            bank_acct_id = null,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                bank_acct_id = p_bank_acct_id
            and status in ( 'GENERATED', 'PROCESSED', 'IN_PROCESS' );

        pc_log.log_error('PC_CLAIM.cancel_invalid_bank_txns ', ' l_invoice_id '
                                                               || l_invoice_id
                                                               || ' p_bank_acct_id :='
                                                               || p_bank_acct_id);

    -- Added by Joshi for 11709
        update monthly_invoice_payment_detail
        set
            status = 'I'
        where
            bank_acct_id = p_bank_acct_id;
  -- code ends here  Joshi for 11709

    exception
        when others then
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/
            raise;
    end cancel_invalid_bank_txns;

    procedure process_hrafsa_ach_eclaim (
        p_transaction_id in number,
        p_user_id        in number
    ) is
        l_return_status varchar2(3200);
        l_error_message varchar2(3200);
        l_payment_date  date;
    begin
        for x in (
            select
                b.total_amount,
                a.acc_id,
                b.transaction_id,
                c.claim_id,
                a.pay_reason,
                c.service_type,
                case
                    when e.plan_end_date < sysdate then
                        e.plan_end_date /** uncomment when jeanette comes back **/
                    else
                        b.transaction_date
                end                                                                                                  transaction_date
                ,
                pc_account.acc_balance(a.acc_id, e.plan_start_date, e.plan_end_date, d.account_type, c.service_type) acc_balance
            from
                payment_register          a,
                ach_transfer              b,
                claimn                    c,
                account                   d,
                ben_plan_enrollment_setup e
            where
                b.status in ( 1, 2 )
                and e.status in ( 'A', 'I' )
                and b.claim_id = a.claim_id
                and a.acc_id = b.acc_id
                and c.claim_id = a.claim_id
                and d.acc_id = a.acc_id
                and e.acc_id = a.acc_id
                and c.service_type = e.plan_type
                and e.plan_start_date < e.plan_end_date
                and e.plan_start_date = c.plan_start_date
                and e.plan_end_date = c.plan_end_date
                and b.transaction_id = p_transaction_id
        ) loop
            if x.acc_balance >= 0 then
                delete from balance_register
                where
                    change_id = x.acc_id || x.transaction_id;

                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    claimn_id,
                    pay_num,
                    note,
                    plan_type,
                    paid_date,
                    created_by      -- Added by Swamy for Ticket#11556
                    ,
                    creation_date   -- Added by Swamy for Ticket#11556
                ) values ( change_seq.nextval,
                           x.acc_id,
                           x.transaction_date,
                           x.total_amount,
                           19,
                           x.claim_id,
                           x.transaction_id,
                           'Disbursement (Claim ID:'
                           || x.claim_id
                           || ') created on '
                           || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                           x.service_type,
                           sysdate,
                           p_user_id    -- Added by Swamy for Ticket#11556
                           ,
                           sysdate      -- Added by Swamy for Ticket#11556
                            );

                update ach_transfer
                set
                    status = 3,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                    transaction_id = p_transaction_id;

                update_claim_totals(x.claim_id);
                update_claim_status(x.claim_id);
            end if;
        end loop;
    exception
        when others then
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

            raise;
    end process_hrafsa_ach_eclaim;

    procedure process_ach_claim (
        p_transaction_id in number,
        p_user_id        in number
    )  -- Added by Swamy for Ticket#11556)
     is
        l_batch_number varchar2(30);
        l_claim_id     number;
    begin
        pc_log.log_error('PC_CLAIM', 'p_transaction_id ' || p_transaction_id);
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
        for x in (
            select
                *
            from
                ach_transfer_v
            where
                    transaction_id = p_transaction_id
                and status = 2
        ) loop
            pc_log.log_error('PC_CLAIM', ' x.ACCOUNT_TYPE ' || x.account_type);
            if
                pc_account.acc_balance(x.acc_id) >= -10
                and x.account_type in ( 'HSA', 'LSA' )     -- LSA added by Swamy for Ticket#9912 on 10/08/2021
            then
                delete from balance_register
                where
                    change_id = x.acc_id || x.transaction_id;
      /*  IF X.CLAIM_ID IS NULL THEN
           -- Commented out as part of the HSA claim redesign flow: HEX project
        l_claim_id := DOC_SEQ.NEXTVAL;
        INSERT INTO PAYMENT_REGISTER
        (PAYMENT_REGISTER_ID
        ,BATCH_NUMBER
        ,ACC_NUM
        ,ACC_ID
        ,PERS_ID
        ,PROVIDER_NAME
        ,CLAIM_CODE
        ,CLAIM_ID
        ,TRANS_DATE
        ,GL_ACCOUNT
        ,CASH_ACCOUNT
        ,CLAIM_AMOUNT
        ,CLAIM_TYPE
        ,PEACHTREE_INTERFACED
        ,CHECK_NUMBER
        ,NOTE)
           SELECT PAYMENT_REGISTER_SEQ.NEXTVAL
            , l_batch_number
            , X.ACC_NUM
            , X.ACC_ID
            , X.PERS_ID
            , 'eDisbursement'
            , UPPER(SUBSTR(B.LAST_NAME,1,4))||TO_CHAR(SYSDATE,'YYYYMMDDHHMISS')||x.transaction_id
            , l_claim_id
            , SYSDATE
            , (SELECT ACCOUNT_NUM FROM PAYMENT_ACC_INFO WHERE ACCOUNT_TYPE = 'GL_ACCOUNT' AND STATUS = 'A')
            ,  NVL((SELECT ACCOUNT_NUM FROM PAYMENT_ACC_INFO WHERE SUBSTR(ACCOUNT_TYPE,1,3) LIKE SUBSTR(X.ACC_NUM,1,3)||'%' AND STATUS = 'A'),
              (SELECT ACCOUNT_NUM FROM PAYMENT_ACC_INFO WHERE SUBSTR(ACCOUNT_TYPE,1,3) = 'SHA' AND STATUS = 'A'))
            , X.TOTAL_AMOUNT
            , 'ONLINE'
            , 'Y'
            , p_transaction_id
            , 'Online Disbursement'
           FROM  PERSON B
           WHERE B.PERS_ID = X.PERS_ID
           AND   NOT EXISTS ( SELECT * FROM PAYMENT_REGISTER
                            WHERE CLAIM_CODE LIKE UPPER(SUBSTR(B.LAST_NAME,1,4))||'%'||x.transaction_id);

        INSERT INTO CLAIMN
        (  CLAIM_ID
          ,PERS_ID
          ,PERS_PATIENT
          ,CLAIM_CODE
          ,PROV_NAME
          ,CLAIM_DATE_START
          ,CLAIM_DATE_END
          ,SERVICE_STATUS
          ,CLAIM_AMOUNT
          ,CLAIM_PAID
          ,CLAIM_PENDING
          ,NOTE
        )
           SELECT claim_id
          ,PERS_ID
          ,PERS_ID
          ,CLAIM_CODE
          ,PROVIDER_NAME
          ,SYSDATE
          ,TRANS_DATE
          ,NVL(x.reason_code,3)
          ,CLAIM_AMOUNT
          ,CLAIM_AMOUNT
          ,0
          ,'Disbursement Created for '||TO_CHAR(SYSDATE,'YYYYMMDD')
        FROM PAYMENT_REGISTER A
        WHERE A.BATCH_NUMBER = l_batch_number
          AND   A.ACC_ID = X.ACC_ID
        AND   A.CLAIM_ID = l_claim_id
          AND   A.CHECK_NUMBER =  p_transaction_id
        AND   NOT EXISTS ( SELECT * FROM CLAIMN WHERE CLAIM_ID = A.CLAIM_ID);*/
        --  Added as part of the HSA claim redesign flow: HEX project
                update claimn
                set
                    claim_paid = x.total_amount,
                    claim_status = 'PAID',
                    claim_pending = claim_amount - x.total_amount,
                    last_updated_by = p_user_id   -- Added by Swamy for Ticket#11556
                    ,
                    last_update_date = sysdate    -- Added by Swamy for Ticket#11556
                where
                    claim_id = x.claim_id;
        --
                insert into payment (
                    change_num,
                    claimn_id,
                    pay_date,
                    amount,
                    reason_code,
                    pay_num,
                    note,
                    acc_id,
                    paid_date,
                    created_by        -- Added by Swamy for Ticket#11556
                    ,
                    creation_date     -- Added by Swamy for Ticket#11556
                )
                    select
                        change_seq.nextval,
                        claim_id,
                        trans_date,
                        claim_amount,
                        19,
                        p_transaction_id,
                        'Generate Disbursement ' || to_char(sysdate, 'YYYYMMDD'),
                        acc_id,
                        sysdate,
                        p_user_id        -- Added by Swamy for Ticket#11556
                        ,
                        sysdate          -- Added by Swamy for Ticket#11556
                    from
                        payment_register a
                    where
                            a.acc_id = x.acc_id
                        and a.claim_id = x.claim_id
       --   AND   A.CHECK_NUMBER =  p_transaction_id
                        and not exists (
                            select
                                *
                            from
                                payment
                            where
                                claimn_id = a.claim_id
                        );

                update ach_transfer
                set
                    status = 3,
                    claim_id = x.claim_id,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id    -- Added by Swamy for Ticket#11556
                where
                    transaction_id = p_transaction_id;

            elsif x.account_type = 'COBRA' then
                pc_log.log_error('PC_CLAIM', ' p_transaction_id ' || p_transaction_id);
/* commented by jaggi prod move feb 4
              DELETE FROM balance_register WHERE change_id = x.acc_id||x.transaction_id;
*/
                if x.entrp_id is not null then
                    update ach_transfer
                    set
                        status = 3,
                        claim_id = (
                            select
                                employer_payment_id
                            from
                                employer_payments
                            where
                                    check_number = to_char(p_transaction_id)
                                and entrp_id = x.entrp_id
                        ),
                        last_update_date = sysdate,
                        last_updated_by = p_user_id        -- Added by Swamy for Ticket#11556
                    where
                        transaction_id = p_transaction_id;

                else
                    update claimn
                    set
                        claim_paid = x.total_amount,
                        claim_status = 'PAID',
                        claim_pending = claim_amount - x.total_amount,
                        last_updated_by = p_user_id      -- Added by Swamy for Ticket#11556
                        ,
                        last_update_date = sysdate        -- Added by Swamy for Ticket#11556
                    where
                        claim_id = x.claim_id;
            --
                    insert into payment (
                        change_num,
                        claimn_id,
                        pay_date,
                        amount,
                        reason_code,
                        pay_num,
                        note,
                        acc_id,
                        paid_date,
                        created_by                 -- Added by Swamy for Ticket#11556
                        ,
                        creation_date              -- Added by Swamy for Ticket#11556
                    )
                        select
                            change_seq.nextval,
                            claim_id,
                            claim_date_start,
                            claim_amount,
                            pay_reason,
                            p_transaction_id,
                            'Generate Disbursement ' || to_char(sysdate, 'YYYYMMDD'),
                            x.acc_id,
                            sysdate,
                            p_user_id            -- Added by Swamy for Ticket#11556
                            ,
                            sysdate              -- Added by Swamy for Ticket#11556
                        from
                            claimn a
                        where
                                a.pers_id = x.pers_id
                            and a.claim_id = x.claim_id
           --   AND   A.CHECK_NUMBER =  p_transaction_id
                            and not exists (
                                select
                                    *
                                from
                                    payment
                                where
                                    claimn_id = a.claim_id
                            );

                    update ach_transfer
                    set
                        status = 3,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id   -- Added by Swamy for Ticket#11556
                    where
                        transaction_id = p_transaction_id;

                end if;

            end if;

        end loop;

  -- Added by Swamy for Cobrapoint 02/11/2022
        pc_cobra_disbursement.post_premium_invoice(
            p_transaction_id => p_transaction_id,
            p_user_id        => p_user_id
        );
    exception
        when others then
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/
            raise;
    end process_ach_claim;

    function claim_type (
        claim_id_in in varchar2
    ) return varchar2 is
        l_claim_type varchar2(30);
    begin
        for x in (
            select
                claim_type
            from
                payment_register
            where
                claim_id = claim_id_in
            union
            select
                'ONLINE'
            from
                payment
            where
                    reason_code = 13
                and claimn_id = claim_id_in
        ) loop
            l_claim_type := x.claim_type;
        end loop;

        return l_claim_type;
    end claim_type;

    function claim_code (
        claim_id_in in claim.claim_id%type
    ) return claim.claim_code%type is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            claim_code
        from
            claim
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.claim_code;
        else
            return null;
        end if;
    end claim_code;

-- ??? ??.claim ?????????? CLAIM_CODE
    function claimn_code (
        claim_id_in in claimn.claim_id%type
    ) return claimn.claim_code%type is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            claim_code
        from
            claimn
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.claim_code;
        else
            return null;
        end if;
    end claimn_code;
/*
PROCEDURE get_deductible(p_acc_id        IN NUMBER
                    , p_plan_start_date IN DATE
                    , p_plan_end_date   IN DATE
                    , p_plan_type       IN VARCHAR2
                    , p_pers_id         IN NUMBER
                    , p_pers_patient    IN NUMBER
                    , p_rule_id         IN NUMBER
                    , p_annual_election IN NUMBER
                    , p_claim_amount    IN NUMBER
                    , x_deductible      OUT NUMBER
                    , x_payout_amount   OUT NUMBER)
IS
  l_deductible NUMBER;
  l_deductible_flag VARCHAR2(1) := 'Y';
  l_disb_ytd        NUMBER := 0;
  l_rule_id         NUMBER;
BEGIN

  l_disb_ytd := NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0);
    dbms_output.put_line('l_disb_ytd '|| l_disb_ytd);

  FOR X IN (SELECT  Rank
                   ,Entity
                   ,Type_of_Deductible
                   ,min_deductible
                   ,max_deductible
                   ,maximum_cap
             FROM   deductible_rule_detail
             WHERE  rule_id = p_rule_id
             ORDER  BY rank)
  LOOP
     -- Employee Pays First rule
        IF  x.entity = 'EMPLOYEE' AND    p_pers_id = p_pers_patient THEN
            dbms_output.put_line('l_disb_ytd '|| X.max_deductible);

           IF NVL(l_disb_ytd,0) <= NVL(x.maximum_cap,X.max_deductible) THEN
               IF   x.Type_of_Deductible = 'AMOUNT' THEN
                    dbms_output.put_line('l_disb_ytd '|| NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0));

                   IF  NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0)
                   BETWEEN x.min_deductible AND x.max_deductible THEN
                      x_deductible := LEAST(x.max_deductible- NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date),0),p_claim_amount);
                      x_payout_amount := p_claim_amount-NVL(x_deductible,0);
                      l_deductible_flag := 'Y';
                   END IF;
               ELSIF x.Type_of_Deductible = 'PERCENTAGE' THEN
                 IF  NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0)
                 BETWEEN x.min_deductible AND x.max_deductible THEN
                   X_deductible := LEAST((p_annual_election*(x.max_deductible/100)
                                      - NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0)),p_claim_amount);
                   x_payout_amount := p_claim_amount-NVL(x_deductible,0);
                   l_deductible_flag := 'Y';

                 END IF;
              END IF;
           ELSE
             X_deductible := 0;
             x_payout_amount := 0;
           END IF;
           EXIT;
        END IF;
        IF x.entity = 'EMPLOYER'  AND l_deductible_flag = 'N' THEN
          IF NVL(l_disb_ytd,0) <= NVL(x.maximum_cap,x.max_deductible) THEN
             x_deductible := 0;
             x_payout_amount := p_claim_amount;
          ELSE
             x_deductible := 0;
             x_payout_amount := 0;
          END IF;
        END IF;
        IF  x.entity = 'DEPENDANT'
        AND p_pers_id <> p_pers_patient
        AND l_deductible_flag = 'N' THEN
           IF NVL(l_disb_ytd,0) <= x.maximum_cap THEN
               IF   x.Type_of_Deductible = 'AMOUNT' THEN
                   IF  NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0)
                   BETWEEN x.min_deductible AND x.max_deductible THEN
                      x_deductible := LEAST(x.max_deductible- NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0),p_claim_amount);
                      x_payout_amount := p_claim_amount-NVL(x_deductible,0);
                      l_deductible_flag := 'Y';

                   END IF;
               ELSIF x.Type_of_Deductible = 'PERCENTAGE' THEN
                 IF  NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0)
                 BETWEEN x.min_deductible AND x.max_deductible THEN
                   X_deductible := LEAST(p_annual_election*(x.max_deductible/100)
                                      - NVL(pc_fin.deductible_YTD(p_acc_id,p_plan_start_date,p_plan_end_date,p_pers_patient),0),p_claim_amount);
                   x_payout_amount := p_claim_amount-NVL(x_deductible,0);
                   l_deductible_flag := 'Y';

                 END IF;-- Type_of_Deductible = 'PERCENTAGE'
              END IF;   --     x.entity = 'DEPENDANT'
         END IF;
        EXIT;
      END IF;

  END LOOP;
END get_deductible;
*/
    procedure get_deductible (
        p_acc_id          in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_pers_id         in number,
        p_pers_patient    in number,
        p_rule_id         in number,
        p_annual_election in number,
        p_claim_amount    in number,
        x_deductible      out number,
        x_payout_amount   out number
    ) is

        l_deductible      number;
        l_deductible_flag varchar2(1) := 'N';
        l_disb_ytd        number := 0;
        l_ded_ytd         number := 0;
        l_rule_id         number;
    begin
        l_ded_ytd := nvl(
            pc_fin.deductible_ytd(p_acc_id, p_plan_start_date, p_plan_end_date, p_pers_patient),
            0
        );

        l_disb_ytd := nvl(
            pc_fin.disbursement_ytd(p_acc_id, 'HRA', p_plan_type, null, p_plan_start_date,
                                    p_plan_end_date),
            0
        );

        for x in (
            select
                rank,
                entity,
                type_of_deductible,
                min_deductible,
                max_deductible,
                maximum_cap,
                rule_type
            from
                deductible_rule_detail a,
                deductible_rule        b
            where
                    a.rule_id = b.rule_id
                and a.rule_id = p_rule_id
            order by
                rank
        ) loop
            pc_log.log_error('PC_CLAIM.p_acc_id', p_acc_id);
            pc_log.log_error('PC_CLAIM.Type_of_Deductible', x.type_of_deductible);
            pc_log.log_error('PC_CLAIM.Entity', x.entity);
            pc_log.log_error('PC_CLAIM.min_deductible', x.min_deductible);
            pc_log.log_error('PC_CLAIM.rule_type', x.rule_type);

     -- Employee Pays First rule
            if
                x.entity = 'EMPLOYEE'
                and p_pers_id = p_pers_patient
                and x.rule_type = 'EE_PAYS_FIRST'
            then
                if nvl(l_ded_ytd, 0) <= x.max_deductible then
                    if x.type_of_deductible = 'AMOUNT' then
                        if nvl(
                            pc_fin.deductible_ytd(p_acc_id, p_plan_start_date, p_plan_end_date, p_pers_patient),
                            0
                        ) between nvl(x.min_deductible, 0) and x.max_deductible then
                            x_deductible := round(
                                least(x.max_deductible - nvl(
                                    pc_fin.deductible_ytd(p_acc_id, p_plan_start_date, p_plan_end_date),
                                    0
                                ),
                                      p_claim_amount),
                                2
                            );

                            x_payout_amount := round(p_claim_amount - nvl(x_deductible, 0),
                                                     2);
                            l_deductible_flag := 'Y';
                        end if;

                    end if;

                else
                    x_deductible := 0;
                    x_payout_amount := round(p_claim_amount, 2);
                end if;
            end if;

            if
                x.entity = 'EMPLOYEE'
                and x.rule_type = 'SPLIT'
            then
                if x.type_of_deductible = 'PERCENTAGE' then
                    x_deductible := p_claim_amount * ( nvl(x.max_deductible, 0) / 100 );
                    x_payout_amount := p_claim_amount - x_deductible;
                end if;
            end if;

            if
                x.entity = 'EMPLOYER'
                and x.rule_type = 'ER_PAYS_FIRST'
            then
                if nvl(l_disb_ytd, 0) between nvl(x.min_deductible, 0) and x.max_deductible then
                    x_deductible := 0;
                    x_payout_amount := round(
                        least(x.max_deductible - nvl(l_disb_ytd, 0),
                              p_claim_amount),
                        2
                    );

                else
                    x_deductible := 0;
                    x_payout_amount := 0;
                end if;
            end if;

            if
                x.entity = 'DEPENDANT'
                and p_pers_id <> p_pers_patient
                and l_deductible_flag = 'N'
            then
                if nvl(l_disb_ytd, 0) <= x.maximum_cap then
                    if x.type_of_deductible = 'AMOUNT' then
                        if nvl(
                            pc_fin.deductible_ytd(p_acc_id, p_plan_start_date, p_plan_end_date, p_pers_patient),
                            0
                        ) between x.min_deductible and x.max_deductible then
                            x_deductible := round(
                                least(x.max_deductible - nvl(
                                    pc_fin.deductible_ytd(p_acc_id, p_plan_start_date, p_plan_end_date, p_pers_patient),
                                    0
                                ),
                                      p_claim_amount),
                                2
                            );

                            x_payout_amount := round(p_claim_amount - nvl(x_deductible, 0),
                                                     2);
                            l_deductible_flag := 'Y';
                        end if;

                    elsif x.type_of_deductible = 'PERCENTAGE' then
                        if nvl(
                            pc_fin.deductible_ytd(p_acc_id, p_plan_start_date, p_plan_end_date, p_pers_patient),
                            0
                        ) between x.min_deductible and x.max_deductible then
                            x_deductible := round(
                                least(p_annual_election *(x.max_deductible / 100) - nvl(
                                    pc_fin.deductible_ytd(p_acc_id, p_plan_start_date, p_plan_end_date, p_pers_patient),
                                    0
                                ),
                                      p_claim_amount),
                                2
                            );

                            x_payout_amount := round(p_claim_amount - nvl(x_deductible, 0),
                                                     2);
                            l_deductible_flag := 'Y';
                        end if;-- Type_of_Deductible = 'PERCENTAGE'
                    end if;   --     x.entity = 'DEPENDANT'
                end if;
            end if;

            x_deductible := round(x_deductible, 2);
            x_payout_amount := round(x_payout_amount, 2);
        end loop;

    end get_deductible;
-- ??? ??.claim ?????????? ???-?? ????????? ?????
    function count_claim_detail (
        claim_id_in in claim.claim_id%type
    ) return number is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            count(1) count_r
        from
            claimn
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return nvl(r1.count_r, 0);
        else
            return 0;
        end if;

    end count_claim_detail;

-- ??? ??.claim ?????????? ????? ????????? ?????
    function sum_claim_detail (
        claim_id_in in claim.claim_id%type
    ) return claim_detail.sure_amount%type is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            sum(sure_amount) summ_r
        from
            claim_detail
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return nvl(r1.summ_r, 0);
        else
            return 0;
        end if;

    end sum_claim_detail;

-- ??? ??.claim ?????????? ????? CLAIM-? (new)
    function sum_claimn_detail (
        claim_id_in in claimn.claim_id%type
    ) return number is

        cursor c1 (
            p_claim_id claimn.claim_id%type
        ) is
        select
            claim_amount
        from
            claimn
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.claim_amount;
        else
            return null;
        end if;
    end sum_claimn_detail;

-- ??? ??.claim ?????????? ???-?? ????? ??? ????
    function count_claim_payment (
        claim_id_in in claim.claim_id%type
    ) return number is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            count(1) count_r
        from
            payment
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return nvl(r1.count_r, 0);
        else
            return 0;
        end if;

    end count_claim_payment;

-- ??? ??.claim ?????????? ????? ????? ??? ????
    function sum_claim_payment (
        claim_id_in in claim.claim_id%type
    ) return number is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            sum(amount) summ_r
        from
            payment
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return nvl(r1.summ_r, 0);
        else
            return 0;
        end if;

    end sum_claim_payment;


-- ??? ??.claim ?????????? ???-?? ????? ??? ???? (new)
    function count_claimn_payment (
        claim_id_in in claimn.claim_id%type
    ) return number is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            count(1) count_r
        from
            payment
        where
            claimn_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return nvl(r1.count_r, 0);
        else
            return 0;
        end if;

    end count_claimn_payment;

-- ??? ??.claim ?????????? ????? ????? ??? ???? (new)
    function sum_claimn_payment (
        claim_id_in in claimn.claim_id%type
    ) return number is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            sum(amount) summ_r
        from
            payment
        where
                claimn_id = p_claim_id
            and reason_code <> 14;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return nvl(r1.summ_r, 0);
        else
            return 0;
        end if;

    end sum_claimn_payment;

    function get_paid_date (
        claim_id_in in claimn.claim_id%type
    ) return date is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            max(paid_date) summ_r
        from
            payment
        where
            claimn_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.summ_r;
        else
            return null;
        end if;
    end get_paid_date;
-- ??? ??.claim ?????????? ???????????? ??????? ??? ????
    function rest_claim (
        claim_id_in in claim.claim_id%type
    ) return number is
    begin
        return pc_claim.sum_claim_detail(claim_id_in) - pc_claim.sum_claim_payment(claim_id_in);
    end rest_claim;

-- ??? ??.claim ?????????? ???????????? ??????? ??? ???? (new)
    function rest_claimn (
        claim_id_in in claimn.claim_id%type
    ) return number is
    begin
        return pc_claim.sum_claimn_detail(claim_id_in) - pc_claim.sum_claimn_payment(claim_id_in);
    end rest_claimn;

    function has_document (
        claim_id_in in number
    ) return varchar2 is
        l_doc_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                count(1) cnt
            from
                file_attachments
            where
                    entity_name = 'CLAIMN'
                and entity_id = to_char(claim_id_in)
        ) loop
            if x.cnt > 0 then
                l_doc_flag := 'Y';
            end if;
        end loop;

        return l_doc_flag;
    end has_document;

    procedure process_emp_claim (
        p_entrp_id       in number,
        p_list_bill      in number,
        p_refund_amount  in number,
        p_emp_deposit_id in number,
        p_check_number   in varchar2,
        x_batch_number   out varchar2,
        x_error_message  out varchar2
    ) is

        l_batch_number   varchar2(30);
        l_error_message  varchar2(32000);
        l_vendor_id      number;
        l_name           varchar2(32000);
        l_address        varchar2(32000);
        l_city           varchar2(32000);
        l_state          varchar2(32000);
        l_zip            varchar2(32000);
        l_acc_num        varchar2(30);
        l_payment_reg_id number;
        l_check_number   number;
    begin
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
        if p_entrp_id is not null then
            select
                name,
                address,
                city,
                state,
                zip,
                acc_num
            into
                l_name,
                l_address,
                l_city,
                l_state,
                l_zip,
                l_acc_num
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id;

        end if;

        for x in (
            select
                vendor_id
            from
                vendors
            where
                orig_sys_vendor_ref = l_acc_num
        ) loop
            l_vendor_id := x.vendor_id;
        end loop;

        if l_vendor_id is null then
            if
                l_name is not null
                and l_city is not null
                and l_state is not null
            then
                insert into vendors (
                    vendor_id,
                    orig_sys_vendor_ref,
                    vendor_name,
                    address1,
                    address2,
                    city,
                    state,
                    zip,
                    expense_account,
                    acc_num,
                    vendor_in_peachtree,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( vendor_seq.nextval,
                           l_acc_num,
                           l_name,
                           l_address,
                           null,
                           l_city,
                           l_state,
                           l_zip,
                           2400,
                           null,
                           'N',
                           sysdate,
                           0,
                           sysdate,
                           0 ) returning vendor_id into l_vendor_id;

            else
                x_error_message := 'Employer /Address information is incomplete, cannot create refund';
            end if;
        end if;

        if l_vendor_id is not null then
            insert into payment_register (
                payment_register_id,
                batch_number,
                entrp_id,
                acc_num,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                memo,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( payment_register_seq.nextval,
                       l_batch_number,
                       p_entrp_id,
                       l_acc_num,
                       l_name,
                       l_vendor_id,
                       l_acc_num,
                       substr(l_name, 1, 4)
                       || p_list_bill,
                       null,
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
                       (
                           select
                               account_num
                           from
                               payment_acc_info
                           where
                                   substr(account_type, 1, 3) = 'SHA'
                               and status = 'A'
                       ),
                       p_refund_amount,
                       'Refund on check number '
                       || p_check_number
                       || ' created on '
                       || to_char(sysdate, 'MM/DD/RRRR'),
                       'EMPLOYER',
                       'N',
                       'N',
                       'N',
                       l_name,
                       sysdate,
                       get_user_id(v('APP_USER')),
                       sysdate,
                       get_user_id(v('APP_USER')) ) returning payment_register_id into l_payment_reg_id;

        end if;

        update employer_deposits
        set
            refund_amount = nvl(refund_amount, 0) + p_refund_amount,
            remaining_balance = check_amount - ( nvl(posted_balance, 0) + nvl(refund_amount, 0) + p_refund_amount )
        where
            employer_deposit_id = p_emp_deposit_id;

        insert into employer_payments (
            employer_payment_id,
            entrp_id,
            check_amount,
            check_date,
            list_bill,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            payment_register_id
        ) values ( employer_payments_seq.nextval,
                   p_entrp_id,
                   p_refund_amount,
                   sysdate,
                   p_list_bill,
                   sysdate,
                   get_user_id(v('APP_USER')),
                   sysdate,
                   get_user_id(v('APP_USER')),
                   'Refund processed by ' || v('APP_USER'),
                   l_payment_reg_id );

        for x in (
            select
                a.payment_register_id,
                c.check_amount,
                d.acc_id
            from
                payment_register  a,
                employer_payments c,
                account           d
            where
                    a.batch_number = l_batch_number
                and nvl(a.cancelled_flag, 'N') = 'N'
                and nvl(a.claim_error_flag, 'N') = 'N'
                and nvl(a.insufficient_fund_flag, 'N') = 'N'
                and nvl(a.peachtree_interfaced, 'N') = 'N'
                and a.payment_register_id = c.payment_register_id
                and a.acc_num = d.acc_num
                and a.claim_type = 'EMPLOYER'
        ) loop
            pc_check_process.insert_check(
                p_claim_id     => x.payment_register_id,
                p_check_amount => x.check_amount,
                p_acc_id       => x.acc_id,
                p_user_id      => get_user_id(v('APP_USER')),
                p_status       => 'OPEN',
                p_source       => 'EMPLOYER_PAYMENTS',
                x_check_number => l_check_number
            );
        end loop;

        x_batch_number := l_batch_number;
    exception
        when others then
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/
            x_error_message := sqlerrm;
    end process_emp_claim;

    procedure create_disbursement (
        p_vendor_id     in number,
        p_provider_name in varchar2,
        p_address1      in varchar2,
        p_address2      in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zipcode       in varchar2,
        p_claim_date    in varchar2,
        p_claim_amount  in number,
        p_claim_type    in varchar2,
        p_acc_num       in varchar2,
        p_note          in varchar2,
        p_dos           in varchar2,
        p_acct_num      in varchar2,
        p_patient_name  in varchar2,
        p_date_received in varchar2,
        p_payment_mode  in varchar2 default 'P'  --P : Payment, FP : Fee Bucket Refund
        ,
        p_user_id       in number,
        p_batch_number  in varchar2
    ) is

        l_error_message  varchar2(32000);
        l_plan_code      number;
        l_acc_id         number;
        l_vendor_id      number;
        l_pers_id        number;
        l_grp_acc        varchar2(30);
        l_fee_setup      number;
        l_count          number;
        l_claim_insert   varchar2(1) := 'N';
        l_claim_amount   number;
        j                number;
        l_status         varchar2(30) := 'SUCCESS';
        l_setup_error exception;
        l_return_status  varchar2(30) := 'S';
        l_provider_name  varchar2(3200);
        l_last_name      varchar2(3200);
        l_nsf_flag       varchar2(1) := 'N';
        l_note           varchar2(32000);
        l_payment_reg_id number;
        l_check_number   number;
        l_claim_paid     number := 0;
    begin
   --x_batch_number :=  TO_CHAR(SYSDATE,'YYYYMMDDHHMISS');
        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Batch Number' || p_batch_number);
        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'acc_num' || p_acc_num);
        l_acc_id := null;
        l_claim_amount := p_claim_amount;
        if p_acc_num is not null then
            for x in (
                select
                    acc_id,
                    a.pers_id,
                    b.last_name,
                    a.account_status
                from
                    account a,
                    person  b
                where
                        acc_num = upper(p_acc_num)
                    and a.pers_id = b.pers_id
                    and a.account_type = 'HSA'
            ) loop
                l_acc_id := x.acc_id;
                l_pers_id := x.pers_id;
                l_last_name := x.last_name;
                if x.account_status = 4 then
                    l_error_message := 'Cannot create claim for this account , account is closed';
                    raise l_setup_error;
                end if;
            end loop;

            if l_acc_id is null then
                l_error_message := 'Cannot Find Account , Verify Account Number';
                raise l_setup_error;
            end if;
        end if;

        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Deriving acc_id' || l_acc_id);
        begin
            if p_acc_num is null then
                l_error_message := 'Enter valid value for Account Number';
                raise l_setup_error;
            end if;
            if p_claim_date is null then
                l_error_message := 'Enter valid value for Fee Date';
                raise l_setup_error;
            end if;
            if nvl(p_claim_amount, 0) = 0 then
                l_error_message := 'Enter valid value for Claim Amount';
                raise l_setup_error;
            end if;

            if
                p_claim_type = 'PROVIDER'
                and p_provider_name is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for Provider Name';
                raise l_setup_error;
            end if;

            if
                p_claim_type = 'PROVIDER'
                and p_address1 is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for Address 1';
                raise l_setup_error;
            end if;

            if
                p_claim_type = 'PROVIDER'
                and p_city is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for City';
                l_status := 'ERROR';
            end if;

            if
                p_claim_type = 'PROVIDER'
                and p_state is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for State';
                raise l_setup_error;
            end if;

            if
                p_claim_type = 'PROVIDER'
                and p_zipcode is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for State';
                raise l_setup_error;
            end if;

            pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Validations Passed');
            if
                p_claim_amount <= pc_account.acc_balance(l_acc_id) - nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                )
                and pc_account.acc_balance(l_acc_id) - ( p_claim_amount + nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                ) ) >= 0
            then
                l_nsf_flag := 'N';
            elsif
                p_claim_amount > ( pc_account.acc_balance(l_acc_id) - nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                ) )
                and ( p_claim_amount + nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                ) ) - pc_account.acc_balance(l_acc_id) >= 0
            then
                l_nsf_flag := 'Y';
            else
                l_nsf_flag := 'Y';
            end if;

            pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Checked for NSF' || l_nsf_flag);
            pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Checked for claim amount' || p_claim_amount);
            if pc_account.acc_balance(l_acc_id) - ( nvl(p_claim_amount, 0) + nvl(
                pc_fin.get_bill_pay_fee(l_acc_id),
                0
            ) ) < 0 then
                l_note := p_note
                          || 'Disbursement requested for '
                          || nvl(p_claim_amount, 0)
                          || ' ,but the available balance is '
                          || to_char(pc_account.acc_balance(l_acc_id) - nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                ));

                pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Note' || l_note);
                l_claim_amount := pc_account.acc_balance(l_acc_id) - nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                );

            else
                if p_claim_type = 'PROVIDER' then
                    l_note := l_note
                              || '('
                              || ( p_acc_num )
                              || ') '
                              ||
                        case
                            when p_dos is null then
                                ''
                            else ' DOS:' || p_dos
                        end
                              ||
                        case
                            when p_acct_num is null then
                                ''
                            else ' Acct# ' || p_acct_num
                        end
                              || p_note;

                elsif
                    p_claim_type = 'SUBSCRIBER'
                    and p_note is null
                then
                    l_note := 'Disbursement Created on ' || p_claim_date;
                end if;
            end if;
       --END IF;
            pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Note' || l_note);
            l_vendor_id := null;
            pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT',
                             'Claim Type '
                             || p_claim_type
                             || ' Vendor id : '
                             || nvl(p_vendor_id, l_vendor_id)
                             || ' ACC NUM '
                             || p_acc_num);

        exception
            when l_setup_error then
                null;
        end;

        if p_vendor_id is null then
            if p_claim_type = 'SUBSCRIBER' then
                for x in (
                    select
                        x.acc_num,
                        x.acc_id,
                        x.vendor_id,
                        c.first_name
                        || ' '
                        || c.middle_name
                        || ' '
                        || c.last_name name,
                        c.address,
                        c.city,
                        c.state,
                        c.zip
                    from
                        (
                            select
                                a.vendor_id,
                                b.acc_id,
                                b.pers_id,
                                b.acc_num,
                                a.address1,
                                a.city,
                                a.state,
                                a.zip
                            from
                                vendors a,
                                account b
                            where
                                    a.orig_sys_vendor_ref (+) = p_acc_num
                                and b.acc_num = p_acc_num
                                and a.orig_sys_vendor_ref (+) = b.acc_num
                        )      x,
                        person c
                    where
                            x.pers_id = c.pers_id
                        and ( x.address1 is null
                              or x.address1 = c.address )
                        and ( x.city is null
                              or x.city = c.city )
                        and ( x.state is null
                              or x.state = c.state )
                        and ( x.zip is null
                              or x.zip = c.zip )
                ) loop
                    pc_log.log_error('CREATE_DISBURSEMENT', 'x.VENDOR ID '
                                                            || x.vendor_id
                                                            || ' , P_ACC_NUM '
                                                            || p_acc_num);

                    l_vendor_id := x.vendor_id;
                    pc_log.log_error('CREATE_DISBURSEMENT', 'l_VENDOR ID '
                                                            || l_vendor_id
                                                            || ' , P_ACC_NUM '
                                                            || p_acc_num);
                end loop;

                pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'subscriber:Vendor id ' || l_vendor_id);

  /*   ELSIF  p_claim_type = 'PROVIDER' THEN

        FOR X IN ( SELECT * FROM VENDORS
                   WHERE ORIG_SYS_VENDOR_REF = P_PROVIDER_NAME
                    AND  (ADDRESS1 IS NOT NULL
                         AND ADDRESS1
                          OR ADDRESS2 IS NOT NULL)
                    AND  CITY IS NOT NULL AND STATE IS NOT NULL
                    AND  ZIP IS NOT NULL)
        LOOP
          L_VENDOR_ID := X.VENDOR_ID;
        END LOOP;
        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT','PROVIDER:Vendor id '||L_VENDOR_ID);
        */
            end if;
        else
            l_vendor_id := p_vendor_id;
        end if;

        update vendors
        set
            orig_sys_vendor_ref = p_acc_num
        where
            vendor_id = nvl(p_vendor_id, l_vendor_id);

        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Vendor id ' || l_vendor_id);
        if nvl(p_vendor_id, l_vendor_id) is null then
            if p_claim_type = 'SUBSCRIBER' then
                for x in (
                    select
                        *
                    from
                        person
                    where
                        pers_id = l_pers_id
                ) loop
                    pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Creating Vendor for person ' || l_pers_id);
                    l_provider_name := nvl(p_patient_name, x.first_name
                                                           || ' '
                                                           || x.last_name);

                    pc_online.create_vendor(
                        p_vendor_name         => nvl(p_patient_name, x.first_name
                                                             || ' '
                                                             || x.last_name),
                        p_vendor_acc_num      => p_acc_num,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zipcode             => x.zip,
                        p_acc_num             => p_acc_num,
                        p_user_id             => p_user_id,
                        p_orig_sys_vendor_ref => p_acc_num,
                        x_vendor_id           => l_vendor_id,
                        x_return_status       => l_return_status,
                        x_error_message       => l_error_message
                    );

                    pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'after PC_ONLINE.CREATE_VENDOR '
                                                                     || l_return_status
                                                                     || ', vendor_id '
                                                                     || l_vendor_id);
                end loop;

            elsif p_claim_type = 'PROVIDER' then
                l_provider_name := p_provider_name;
                pc_online.create_vendor(
                    p_vendor_name    => p_provider_name,
                    p_vendor_acc_num => p_acct_num,
                    p_address        => p_address1
                                 || ' '
                                 || p_address2,
                    p_city           => p_city,
                    p_state          => p_state,
                    p_zipcode        => p_zipcode,
                    p_acc_num        => p_acc_num,
                    p_user_id        => p_user_id,
                    x_vendor_id      => l_vendor_id,
                    x_return_status  => l_return_status,
                    x_error_message  => l_error_message
                );

                pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'after PC_ONLINE.CREATE_VENDOR '
                                                                 || l_return_status
                                                                 || ', vendor_id '
                                                                 || l_vendor_id);
            end if;
        else
            for x in (
                select
                    *
                from
                    vendors
                where
                        vendor_id = nvl(p_vendor_id, l_vendor_id)
                    and address1 <> p_address1
                    and city <> p_city
                    and state <> p_state
                    and zip <> p_zipcode
            ) loop
                update vendors
                set
                    vendor_name = p_provider_name,
                    orig_sys_vendor_ref = p_acct_num,
                    address1 = p_address1,
                    address2 = p_address2,
                    city = p_city,
                    state = p_state,
                    zip = p_zipcode,
                    vendor_in_peachtree = 'N',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    vendor_id = nvl(p_vendor_id, l_vendor_id);

            end loop;
        end if;

        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'INSERTING TO PAYMENT_REGISTER ,ACC_ID ' || l_acc_id);
        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'INSERTING TO PAYMENT_REGISTER ,p_PROVIDER_NAME ' || p_provider_name);
        if p_provider_name is null then
            for x in (
                select
                    *
                from
                    vendors
                where
                    vendor_id = p_vendor_id
            ) loop
                l_provider_name := x.vendor_name;
            end loop;
        end if;

        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'INSERTING TO PAYMENT_REGISTER ,L_PROVIDER_NAME ' || l_provider_name);
        if l_acc_id is not null then
            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                patient_name,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag
            ) values ( payment_register_seq.nextval,
                       p_batch_number,
                       p_acc_num,
                       l_acc_id,
                       l_pers_id,
                       nvl(p_provider_name, l_provider_name),
                       l_vendor_id,
                       case
                           when p_claim_type = 'SUBSCRIBER' then
                               p_acc_num
                           else
                               nvl(p_provider_name, l_provider_name)
                       end,
                       upper(substr(l_last_name, 1, 4))
                       || to_char(sysdate, 'YYYYMMDDHHMISS'),
                       doc_seq.nextval,
                       to_date(p_claim_date, 'MM/DD/RRRR'),
                       pc_param.get_gl_account,
                       pc_param.get_cash_account(p_acc_num),
                       p_claim_amount,
                       l_error_message
                       || '  '
                       || l_note,
                       p_claim_type,
                       p_patient_name,
                       'N',
                       decode(l_error_message, null, 'N', 'Y'),
                       l_nsf_flag ) returning payment_register_id into l_payment_reg_id;

            if
                l_payment_reg_id is not null
                and p_batch_number is not null
            then
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
                    pay_reason,
                    vendor_id,
                    bank_acct_id
                )
                    select
                        claim_id,
                        pers_id,
                        pers_id,
                        claim_code,
                        provider_name,
                        trans_date,
                        to_date(p_date_received, 'MM/DD/RRRR'),
                        2,
                        claim_amount,
                        get_claim_paid(acc_id, a.claim_type, a.claim_amount),
                        claim_amount - get_claim_paid(acc_id, a.claim_type, a.claim_amount) claim_pending,
                        case
                            when a.claim_amount = get_claim_paid(acc_id, a.claim_type, a.claim_amount) then
                                'Disbursement Created on ' || to_char(trans_date, 'RRRRMMDD')
                            when a.claim_amount > get_claim_paid(acc_id, a.claim_type, a.claim_amount) then
                                'Disbursement requested for '
                                || claim_amount
                                || ', Available balance is '
                                || pc_account.acc_balance(acc_id)
                            else
                                'Insufficient Balance'
                        end                                                                 note,
                        pay_reason,
                        vendor_id,
                        bank_acct_id
                    from
                        payment_register a
                    where
                            a.batch_number = p_batch_number
                        and a.vendor_id = nvl(p_vendor_id, l_vendor_id)
                        and payment_register_id = l_payment_reg_id
                        and claim_error_flag = 'N';

                pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'INSERTING TO CLAIMN ' || sql%rowcount);
                insert into payment (
                    change_num,
                    claimn_id,
                    pay_date,
                    amount,
                    reason_code,
                    pay_num,
                    note,
                    reason_mode,
                    acc_id
                )
                    select
                        change_seq.nextval,
                        a.claim_id,
                        trans_date,
                        b.claim_paid,
                        decode(a.claim_type, 'SUBSCRIBER', 12, 'PROVIDER', 11),
                        null,
                        'Generate Disbursement ' || to_char(trans_date, 'RRRRMMDD'),
                        p_payment_mode,
                        acc_id
                    from
                        payment_register a,
                        claimn           b
                    where
                            a.batch_number = p_batch_number
                        and a.vendor_id = nvl(p_vendor_id, l_vendor_id)
                        and payment_register_id = l_payment_reg_id
                        and a.claim_id = b.claim_id
                        and b.claim_paid > 0
                        and a.claim_error_flag = 'N'
                        and pc_account.acc_balance(acc_id) - nvl(
                            pc_fin.get_bill_pay_fee(acc_id),
                            0
                        ) >= b.claim_paid;

  -- INSERT INTO CHECKS TABLE HERE
                for x in (
                    select
                        a.claim_id,
                        c.amount,
                        c.acc_id,
                        b.claim_amount
                    from
                        payment_register a,
                        claimn           b,
                        payment          c
                    where
                            a.batch_number = p_batch_number
                        and payment_register_id = l_payment_reg_id
                        and nvl(a.cancelled_flag, 'N') = 'N'
                        and nvl(a.claim_error_flag, 'N') = 'N'
       -- AND   NVL(A.INSUFFICIENT_FUND_FLAG,'N') = 'N'
                        and nvl(a.peachtree_interfaced, 'N') = 'N'
                        and nvl(c.claim_posted, 'N') = 'N'
                        and b.claim_amount - nvl(
                            pc_claim.f_claim_paid(a.claim_id),
                            0
                        ) >= 0
                        and a.claim_id = b.claim_id
                        and b.claim_id = c.claimn_id
                        and c.acc_id = a.acc_id
                        and c.reason_code in ( 11, 12 )
                ) loop
                    l_claim_paid := 0;
                    l_claim_paid := nvl(
                        pc_claim.f_claim_paid(x.claim_id),
                        0
                    );
                    if x.claim_amount - l_claim_paid >= 0 then
                        pc_check_process.insert_check(
                            p_claim_id     => x.claim_id,
                            p_check_amount => x.amount,
                            p_acc_id       => x.acc_id,
                            p_user_id      => p_user_id,
                            p_status       => 'OPEN',
                            p_source       => 'HSA_CLAIM',
                            x_check_number => l_check_number
                        );
                    end if;

                end loop;

                pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'INSERTING TO PAYMENT ' || sql%rowcount);
            end if;

        end if;

        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'Call audit review notification');
        for x in (
            select
                case
                    when get_claim_3000_per_week(l_acc_id) > 0
                         and get_claim_8000_per_month(l_acc_id) = 0 then
                        'CLAIM_OVER_3000'
                end template_name
            from
                dual
            union
            select
                case
                    when get_claim_8000_per_month(l_acc_id) > 0 then
                        'CLAIM_OVER_8000'
                end
            from
                dual
            union
            select
                case
                    when get_denied_bank_draft(l_acc_id) > 0 then
                        'DENIED_BANK_DRAFT'
                end
            from
                dual
        ) loop
            if x.template_name is not null then
                pc_notifications.audit_review_notification(l_payment_reg_id, x.template_name, p_user_id);
            end if;
        end loop;

        pc_notifications.claim_notification(l_payment_reg_id, p_user_id);
        pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT:CREATE_CHECK', 'creating check ' || l_payment_reg_id);
    exception
        when others then
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

            raise;
    end create_disbursement;

    function get_claim_3000_per_week (
        p_acc_id in number
    ) return number is
        l_cnt number := 0;
    begin
        for x in (
            select
                count(*) cnt
            from
                payment a,
                claimn  b,
                account c
            where
                reason_code in ( 11, 12, 19 )
                and a.claimn_id = b.claim_id
                and c.acc_id = p_acc_id
                and a.acc_id = c.acc_id
                and trunc(a.pay_date) between ( sysdate - 7 ) and sysdate
            having
                sum(a.amount) > 3000
            order by
                1
        ) loop
            l_cnt := x.cnt;
        end loop;

        return l_cnt;
    end get_claim_3000_per_week;

    function get_claim_8000_per_month (
        p_acc_id in number
    ) return number is
        l_cnt number := 0;
    begin
        for x in (
            select
                count(*) cnt
            from
                payment a,
                claimn  b,
                account c
            where
                reason_code in ( 11, 12, 19 )
                and a.claimn_id = b.claim_id
                and c.acc_id = p_acc_id
                and a.acc_id = c.acc_id
                and trunc(a.pay_date) between ( sysdate - 30 ) and sysdate
            having
                sum(a.amount) > 8000
            order by
                1
        ) loop
            l_cnt := x.cnt;
        end loop;

        return l_cnt;
    end get_claim_8000_per_month;

    function get_denied_bank_draft (
        p_acc_id in number
    ) return number is
        l_cnt number := 0;
    begin
        for x in (
            select
                count(*) cnt
            from
                (
                    select
                        1
                    from
                        income a
                    where
                        lower(a.note) like '%%sufficient%'
                        and a.acc_id = p_acc_id
                        and trunc(fee_date) between trunc(sysdate, 'YYYY') and sysdate
                    union
                    select
                        1
                    from
                        income a
                    where
                        lower(a.note) like '%%returned%'
                        and a.acc_id = p_acc_id
                        and trunc(fee_date) between trunc(sysdate, 'YYYY') and sysdate
                    union
                    select
                        1
                    from
                        payment a
                    where
                            a.acc_id = p_acc_id
                        and reason_code = 6
                )
        ) loop
            l_cnt := x.cnt;
        end loop;

        return l_cnt;
    end get_denied_bank_draft;

    function claim_paid (
        claim_id_in in varchar2
    ) return number is
        l_claim_paid number;
    begin
        for x in (
            select
                sum(amount) amount
            from
                payment    a,
                pay_reason b
            where
                    claimn_id = claim_id_in
                and a.reason_code = b.reason_code
                and a.reason_code <> 24 -- Exclude deductible
                and b.reason_type = 'DISBURSEMENT'
        ) loop
            l_claim_paid := x.amount;
        end loop;

        return l_claim_paid;
    end;

    function f_claim_paid (
        claim_id_in in varchar2
    ) return number is
        l_claim_paid number;
    begin
        for x in (
            select
                sum(amount) amount
            from
                payment    a,
                pay_reason b
            where
                    claimn_id = claim_id_in
                and a.reason_code = b.reason_code
                and a.reason_code <> 24 -- Exclude deductible
                and b.reason_type = 'DISBURSEMENT'
        ) loop
            l_claim_paid := x.amount;
        end loop;

        return l_claim_paid;
    end f_claim_paid;

-- Fee Bucket Refund for Closed Accounts
    procedure process_feebucket_refund (
        p_provider_name in varchar2,
        p_claim_date    in varchar2,
        p_claim_amount  in number,
        p_claim_type    in varchar2,
        p_acc_num       in varchar2,
        p_note          in varchar2,
        p_user_id       in number,
        p_batch_number  in varchar2
    ) is

        l_error_message  varchar2(32000);
        l_plan_code      number;
        l_acc_id         number;
        l_vendor_id      number;
        l_pers_id        number;
        l_grp_acc        varchar2(30);
        l_fee_setup      number;
        l_count          number;
        l_claim_insert   varchar2(1) := 'N';
        j                number;
        l_status         varchar2(30) := 'SUCCESS';
        l_setup_error exception;
        l_return_status  varchar2(30) := 'S';
        l_provider_name  varchar2(3200);
        l_last_name      varchar2(3200);
        l_nsf_flag       varchar2(1) := 'N';
        l_note           varchar2(32000);
        l_payment_reg_id number;
        l_check_number   number;
    begin
   --x_batch_number :=  TO_CHAR(SYSDATE,'YYYYMMDDHHMISS');
        pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'Batch Number' || p_batch_number);
        pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'acc_num' || p_acc_num);
        l_acc_id := null;
        begin
            if p_acc_num is not null then
                for x in (
                    select
                        acc_id,
                        a.pers_id,
                        b.last_name,
                        a.account_status
                    from
                        account a,
                        person  b
                    where
                            acc_num = upper(p_acc_num)
                        and a.pers_id = b.pers_id
                        and a.account_type = 'HSA'
                ) loop
                    l_acc_id := x.acc_id;
                    l_pers_id := x.pers_id;
                    l_last_name := x.last_name;
                end loop;

                if l_acc_id is null then
                    l_error_message := 'Cannot Find Account , Verify Account Number';
                    raise l_setup_error;
                end if;
            end if;

            pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'Deriving acc_id' || l_acc_id);
            l_vendor_id := null;
        exception
            when l_setup_error then
                null;
        end;

        for x in (
            select
                x.acc_num,
                x.acc_id,
                x.vendor_id,
                c.first_name
                || ' '
                || c.middle_name
                || ' '
                || c.last_name name,
                c.address,
                c.city,
                c.state,
                c.zip
            from
                (
                    select
                        a.vendor_id,
                        b.acc_id,
                        b.pers_id,
                        b.acc_num,
                        a.address1,
                        a.city,
                        a.state,
                        a.zip
                    from
                        vendors a,
                        account b
                    where
                            a.orig_sys_vendor_ref (+) = p_acc_num
                        and b.acc_num = p_acc_num
                        and a.orig_sys_vendor_ref (+) = b.acc_num
                )      x,
                person c
            where
                    x.pers_id = c.pers_id
                and ( x.address1 is null
                      or x.address1 = c.address )
                and ( x.city is null
                      or x.city = c.city )
                and ( x.state is null
                      or x.state = c.state )
                and ( x.zip is null
                      or x.zip = c.zip )
        ) loop
            pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'x.VENDOR ID '
                                                        || x.vendor_id
                                                        || ' , P_ACC_NUM '
                                                        || p_acc_num);

            l_vendor_id := x.vendor_id;
            pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'l_VENDOR ID '
                                                        || l_vendor_id
                                                        || ' , P_ACC_NUM '
                                                        || p_acc_num);
        end loop;

        pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'subscriber:Vendor id ' || l_vendor_id);
        pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'Vendor id ' || l_vendor_id);
        if l_vendor_id is null then
            for x in (
                select
                    *
                from
                    person
                where
                    pers_id = l_pers_id
            ) loop
                pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'Creating Vendor for person ' || l_pers_id);
                pc_online.create_vendor(
                    p_vendor_name         => x.first_name
                                     || ' '
                                     || x.last_name,
                    p_orig_sys_vendor_ref => p_acc_num,
                    p_vendor_acc_num      => p_acc_num,
                    p_address             => x.address,
                    p_city                => x.city,
                    p_state               => x.state,
                    p_zipcode             => x.zip,
                    p_acc_num             => p_acc_num,
                    p_user_id             => p_user_id,
                    x_vendor_id           => l_vendor_id,
                    x_return_status       => l_return_status,
                    x_error_message       => l_error_message
                );

                pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'after PC_ONLINE.CREATE_VENDOR '
                                                                      || l_return_status
                                                                      || ', vendor_id '
                                                                      || l_vendor_id);
            end loop;
        end if;

        if l_vendor_id is not null then
            if p_claim_type not in ( 'SUBSCRIBER_EDI', 'SUBSCRIBER', 'SUBSCRIBER_ONLINE' ) then
                update vendors
                set
                    orig_sys_vendor_ref = null
                where
                    vendor_id = l_vendor_id;

            else
                update vendors
                set
                    orig_sys_vendor_ref = p_acc_num
                where
                    vendor_id = l_vendor_id;

            end if;
        end if;

        pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'INSERTING TO PAYMENT_REGISTER ,ACC_ID ' || l_acc_id);
        if l_acc_id is not null then
            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                patient_name,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag
            ) values ( payment_register_seq.nextval,
                       p_batch_number,
                       p_acc_num,
                       l_acc_id,
                       l_pers_id,
                       p_provider_name,
                       l_vendor_id,
                       p_acc_num,
                       upper(substr(l_last_name, 1, 4))
                       || to_char(sysdate, 'YYYYMMDDHHMISS'),
                       doc_seq.nextval,
                       to_date(p_claim_date, 'MM/DD/RRRR'),
                       pc_param.get_gl_account,
                       pc_param.get_cash_account(p_acc_num),
                       p_claim_amount,
                       'Fee Deposit Refund Created on ' || to_char(sysdate, 'RRRRMMDD'),
                       p_claim_type,
                       p_provider_name,
                       'N',
                       decode(l_error_message, null, 'N', 'Y'),
                       l_nsf_flag ) returning payment_register_id into l_payment_reg_id;

            pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'INSERTING TO PAYMENT_REGISTER ' || l_payment_reg_id);
            pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'PERS_ID ' || l_pers_id);
        end if;

    exception
        when others then
            null;
    end process_feebucket_refund;

    procedure create_feebucket_check (
        p_batch_number in number,
        p_user_id      in number
    ) is
        l_check_number number;
    begin
        if p_batch_number is not null then
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
                claim_status,
                approved_amount,
                note,
                pay_reason,
                vendor_id,
                bank_acct_id
            )
                select
                    claim_id,
                    pers_id,
                    pers_id,
                    claim_code,
                    provider_name,
                    trans_date,
                    sysdate,
                    3,
                    claim_amount,
                    a.claim_amount,
                    0,
                    'PAID',
                    claim_amount,
                    'Fee Deposit Refund Created on ' || to_char(trans_date, 'RRRRMMDD') note,
                    pay_reason,
                    vendor_id,
                    bank_acct_id
                from
                    payment_register a
                where
                        a.batch_number = p_batch_number
                    and claim_error_flag = 'N';

            pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'INSERTING TO CLAIMN ' || sql%rowcount);
            insert into payment (
                change_num,
                claimn_id,
                pay_date,
                amount,
                reason_code,
                pay_num,
                note,
                reason_mode,
                acc_id
            )
                select
                    change_seq.nextval,
                    a.claim_id,
                    trans_date,
                    b.claim_paid,
                    23 -- Fee bucket refund amount
                    ,
                    null,
                    'Generate Disbursement ' || to_char(trans_date, 'RRRRMMDD'),
                    'FP',
                    acc_id
                from
                    payment_register a,
                    claimn           b
                where
                        a.batch_number = p_batch_number
                    and a.claim_id = b.claim_id
                    and a.claim_error_flag = 'N';

            pc_log.log_error('PC_CLAIM.process_feebucket_refund', 'INSERTING TO PAYMENT ' || sql%rowcount);
            for x in (
                select
                    a.claim_id,
                    c.amount,
                    c.acc_id
                from
                    payment_register a,
                    claimn           b,
                    payment          c
                where
                        a.batch_number = p_batch_number
                    and a.claim_id = b.claim_id
                    and b.claim_id = c.claimn_id
                    and c.acc_id = a.acc_id
                    and b.claim_amount - nvl(
                        pc_claim.f_claim_paid(a.claim_id),
                        0
                    ) >= 0
                    and nvl(a.cancelled_flag, 'N') = 'N'
                    and nvl(a.claim_error_flag, 'N') = 'N'
                    and nvl(a.insufficient_fund_flag, 'N') = 'N'
                    and nvl(a.peachtree_interfaced, 'N') = 'N'
                    and c.reason_code = 23
            ) loop
                pc_check_process.insert_check(
                    p_claim_id     => x.claim_id,
                    p_check_amount => x.amount,
                    p_acc_id       => x.acc_id,
                    p_user_id      => p_user_id,
                    p_status       => 'OPEN',
                    p_source       => 'HSA_CLAIM',
                    x_check_number => l_check_number
                );
            end loop;

        end if;
    exception
        when others then
            null;
    end create_feebucket_check;

    function get_claim_paid (
        p_acc_id       in number,
        p_claim_type   in varchar2,
        p_claim_amount in number
    ) return number is
        l_claim_amount number;
        l_balance      number;
        l_bill_pay_fee number := 0;
        l_mtly_fee     number := 0;
    begin
        l_balance := pc_account.acc_balance(p_acc_id);
        l_bill_pay_fee := nvl(
            pc_fin.get_bill_pay_fee(p_acc_id),
            0
        );
        if to_char(sysdate + 1, 'DD') = '01' then
            select
                nvl(
                    pc_plan.fmonth_er(b.entrp_id),
                    nvl(
                        pc_plan.fmonth(a.plan_code),
                        0
                    )
                )
            into l_mtly_fee
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and a.acc_id = p_acc_id;

        else
            l_mtly_fee := 0;
        end if;

        if p_claim_type = 'SUBSCRIBER' then
            if
                p_claim_amount + l_bill_pay_fee + l_mtly_fee <= l_balance -- if claim amount is less than balance
                and l_balance - ( p_claim_amount + l_bill_pay_fee + l_mtly_fee ) >= 0
            then
                l_claim_amount := p_claim_amount;
            elsif
                p_claim_amount + l_bill_pay_fee + l_mtly_fee > l_balance  -- if claim amount is more than balance
                and ( p_claim_amount + l_bill_pay_fee + l_mtly_fee ) - l_balance >= 0
            then -- and balance > 0 then pay the balance
                l_claim_amount := l_balance - ( l_bill_pay_fee + l_mtly_fee );
            else
                l_claim_amount := 0;
            end if;
        elsif p_claim_type in ( 'HSA_TRANSFER', 'PROVIDER', 'OUTSIDE_INVESTMENT_TRANSFER' ) then
            if
                p_claim_amount + l_bill_pay_fee + l_mtly_fee <= l_balance
                and l_balance - ( p_claim_amount + l_bill_pay_fee + l_mtly_fee ) >= 0
            then
                l_claim_amount := p_claim_amount;
            elsif
                p_claim_amount > l_balance  -- if claim amount is more than balance
                and p_claim_amount - l_balance >= 0
            then -- and balance > 0 then dont pay
                l_claim_amount := 0;
            else
                l_claim_amount := 0;
            end if;
        end if;

        pc_log.log_error('pc_claim', 'get_claim_paid:P_CLAIM_TYPE '
                                     || p_claim_type
                                     || ' P_CLAIM_AMOUNT :='
                                     || p_claim_amount
                                     || 'L_BILL_PAY_FEE :='
                                     || l_bill_pay_fee
                                     || 'L_MTLY_FEE :='
                                     || l_mtly_fee
                                     || ' L_BALANCE :='
                                     || l_balance
                                     || ' L_CLAIM_AMOUNT :='
                                     || l_claim_amount);

        return l_claim_amount;
    end get_claim_paid;

    procedure validate_hra_fsa_disbursement (
        p_acc_id             in number,
        p_amount             in number,
        p_service_start_date in date,
        p_service_end_date   in date,
        p_service_type       in varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        l_validate_error exception;
        l_plan_exists  varchar2(1) := 'N';
        l_plan_expired varchar2(1) := 'N';
        l_plan_termed  varchar2(1) := 'N';
    begin
        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:P_ACC_ID ' || p_acc_id);
        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:P_SERVICE_START_DATE ' || p_service_start_date);
        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:P_SERVICE_END_DATE ' || p_service_end_date);
        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:P_SERVICE_TYPE ' || p_service_type);
        x_return_status := 'S';
        for x in (
            select
                b.account_status,
                c.plan_start_date,
                c.plan_end_date,
                nvl(c.grace_period, 0)       grace_period,
                nvl(c.runout_period_days, 0) runout_period_days,
                lead(c.plan_end_date + nvl(c.grace_period, 0),
                     1)
                over(
                    order by
                        c.plan_end_date + nvl(c.grace_period, 0)
                )                            as plan_next,
                c.effective_end_date         termination_date,
                c.status,
                b.account_type,
                c.runout_period_term
            from
                account                   b,
                ben_plan_enrollment_setup c
            where
                    b.acc_id = p_acc_id
                and b.account_type in ( 'HRA', 'FSA' )
                and c.acc_id = b.acc_id
                and c.plan_type = p_service_type
                and nvl(c.sf_ordinance_flag, 'N') = 'N'
                and c.status in ( 'A', 'I' )
                and trunc(c.plan_start_date) <= p_service_start_date
                and trunc(c.plan_end_date) + nvl(c.grace_period, 0) >= p_service_end_date
        )
             --Claims should be validated even if they are of future date
             --AND   TRUNC(c.plan_end_date)+NVL(c.grace_period,0) > SYSDATE )
         loop
  /*    IF x.account_status <> 1 THEN
         X_ERROR_MESSAGE := 'Cannot Reimburse at this time, Account is not Active';
         RAISE l_validate_error;
      END IF;
      IF x.status <> 'A' THEN
         X_ERROR_MESSAGE := 'Cannot Reimburse at this time, ' ||p_service_type ||' plan is not Active';
         RAISE l_validate_error;
      END IF;*/
            pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:x.TERMINATION_DATE ' || x.termination_date);
            l_plan_exists := 'Y';
            if x.termination_date is not null then
        --If termination date is after plan end date ,calculation should always include plan end date
                if
                    case
                        when x.runout_period_term = 'CPE'
                             and x.termination_date <= x.plan_end_date then
                            x.termination_date
                        else
                            x.plan_end_date
                    end
                    + nvl(x.runout_period_days, 0) < trunc(sysdate) then
                    x_error_message := 'Cannot Reimburse at this time,'
                                       || p_service_type
                                       || ' plan has expired';
                    raise l_validate_error;
                elsif
                        x.termination_date + nvl(x.runout_period_days, 0) > trunc(sysdate)
                    and p_service_start_date > x.termination_date
                then
                    x_error_message := 'Cannot Reimburse at this time, Service Date '
                                       || to_char(p_service_start_date, 'MM/DD/YYYY')
                                       || ' cannot be  after the termination date '
                                       || to_char(x.termination_date, 'MM/DD/YYYY');

                    raise l_validate_error;
                end if;

                pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:TERMINATION_DATE ' || x.termination_date);
            else
                if x.account_type in ( 'HRA', 'FSA', 'LPF' ) then
            -- Grace period is valid only for healthcare FSA
                    pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:TERMINATION_DATE ' || x.termination_date
                    );
                    if
                            x.plan_end_date + nvl(x.grace_period, 0) + nvl(x.runout_period_days, 0) < trunc(sysdate)
                        and ( x.plan_next is null
                              or x.plan_next < sysdate )
                    then
                        x_error_message := 'Cannot Reimburse at this time,'
                                           || p_service_type
                                           || ' plan has expired';
                        raise l_validate_error;
                    elsif
                            x.plan_end_date + nvl(x.grace_period, 0) + nvl(x.runout_period_days, 0) > trunc(sysdate)
                        and p_service_start_date > x.plan_end_date + nvl(x.grace_period, 0)
                    then
                        x_error_message := 'Cannot Reimburse at this time, Service Date '
                                           || to_char(p_service_start_date, 'MM/DD/YYYY')
                                           || ' cannot be  after the Plan Expiry date and Grace Period '
                                           || to_char(x.plan_end_date + nvl(x.grace_period, 0),
                                                      'MM/DD/YYYY');

                        raise l_validate_error;
                    end if;

                else
                    if x.plan_end_date + nvl(x.runout_period_days, 0) < trunc(sysdate) then
                        x_error_message := 'Cannot Reimburse at this time,'
                                           || p_service_type
                                           || ' plan has expired';
                        raise l_validate_error;
                    elsif
                            x.plan_end_date + nvl(x.runout_period_days, 0) > trunc(sysdate)
                        and p_service_start_date > x.plan_end_date
                    then
                        x_error_message := 'Cannot Reimburse at this time, Service Date '
                                           || to_char(p_service_start_date, 'MM/DD/YYYY')
                                           || ' cannot be  after the Plan Expiry date and Grace Period '
                                           || to_char(x.plan_end_date + nvl(x.grace_period, 0),
                                                      'MM/DD/YYYY');

                        raise l_validate_error;
                    end if;
                end if;
      /*  IF P_AMOUNT > PC_ACCOUNT.ACC_BALANCE(p_acc_id, x.plan_start_date,x.plan_end_date, X.ACCOUNT_TYPE,P_SERVICE_TYPE) THEN
                 X_ERROR_MESSAGE := 'Cannot Reimburse at this time,You do not have enough balance available ' ;
                 RAISE l_validate_error;
        END IF;*/

            end if;

        end loop;

        for x in (
            select
                b.account_status,
                b.account_type,
                b.acc_id
            from
                account b
            where
                    b.acc_id = p_acc_id
                and b.account_type in ( 'HRA', 'FSA' )
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            c.acc_id = b.acc_id
                        and c.plan_type = p_service_type
                        and c.status in ( 'A', 'I' )
                        and nvl(c.sf_ordinance_flag, 'N') = 'Y'
                        and c.plan_start_date <= p_service_start_date
                )
        ) loop
            for xx in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup c
                where
                        c.plan_type = p_service_type
                    and c.status in ( 'A', 'I' )
                    and nvl(c.sf_ordinance_flag, 'N') = 'Y'
                    and c.acc_id = x.acc_id
                    and c.plan_start_date <= p_service_start_date
            ) loop
                if xx.cnt = 0 then
                    x_error_message := 'Cannot Reimburse at this time,'
                                       || p_service_type
                                       || ' has no plans for the service period ';
                    raise l_validate_error;
                end if;
            end loop;

            for xx in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup c
                where
                        c.plan_type = p_service_type
                    and c.status in ( 'A', 'I' )
                    and nvl(c.sf_ordinance_flag, 'N') = 'Y'
                    and c.acc_id = x.acc_id
                    and c.plan_start_date <= p_service_start_date
            ) loop
                if xx.cnt = 0 then
                    x_error_message := 'Cannot Reimburse at this time,'
                                       || p_service_type
                                       || ' has no plans defined for the service period ';
                    raise l_validate_error;
                end if;
            end loop;

            for xx in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup c
                where
                        c.plan_type = p_service_type
                    and c.status in ( 'A', 'I' )
                    and nvl(c.sf_ordinance_flag, 'N') = 'Y'
                    and c.acc_id = x.acc_id
                    and trunc(c.plan_end_date) +
                        case
                            when effective_end_date is not null then
                                90
                            else
                                nvl(c.grace_period, 0)
                        end
                    >= p_service_end_date
            ) loop
                if xx.cnt = 0 then
                    x_error_message := 'Cannot Reimburse at this time,'
                                       || p_service_type
                                       || ' has no plans defined for the service period ';
                    raise l_validate_error;
                end if;
            end loop;

            for xx in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup c
                where
                        c.plan_type = p_service_type
                    and c.status in ( 'A', 'I' )
                    and nvl(c.sf_ordinance_flag, 'N') = 'Y'
                    and c.acc_id = x.acc_id
                    and trunc(c.plan_end_date) +
                        case
                            when effective_end_date is not null then
                                90
                            else
                                nvl(c.grace_period, 0)
                        end
                    >= p_service_end_date
                    and trunc(c.plan_end_date) +
                        case
                            when effective_end_date is not null then
                                90
                            else
                                nvl(c.grace_period, 0)
                        end
                    > trunc(sysdate)
            ) loop
                if xx.cnt = 0 then
                    x_error_message := 'Cannot Reimburse at this time,'
                                       || p_service_type
                                       || ' has no plans defined for the service period or the plan has expired';
                    raise l_validate_error;
                end if;
            end loop;

            for xx in (
                select
                    c.plan_start_date,
                    c.plan_end_date,
                    nvl(c.grace_period, 0)       grace_period,
                    nvl(c.runout_period_days, 0) runout_period_days,
                    c.effective_end_date + 90    termination_date -- 90 days is defined based on the ordinance
                    ,
                    c.status
                from
                    ben_plan_enrollment_setup c
                where
                        c.plan_type = p_service_type
                    and c.status in ( 'A', 'I' )
                    and nvl(c.sf_ordinance_flag, 'N') = 'Y'
                    and c.acc_id = x.acc_id
                    and ( c.effective_end_date is null
                          or c.effective_end_date + 90 > sysdate )
                    and c.plan_start_date <= p_service_start_date
                    and trunc(c.plan_end_date) +
                        case
                            when effective_end_date is not null then
                                90
                            else
                                nvl(c.grace_period, 0)
                        end
                    >= p_service_end_date
            ) loop
                if xx.termination_date is not null then
                    if xx.termination_date < trunc(sysdate) then
                        x_error_message := 'Cannot Reimburse at this time,'
                                           || p_service_type
                                           || ' plan has expired';
                        raise l_validate_error;
                    elsif
                        xx.termination_date > sysdate
                        and p_service_start_date > xx.termination_date
                    then
                        x_error_message := 'Cannot Reimburse at this time, Service Date '
                                           || to_char(p_service_start_date, 'MM/DD/YYYY')
                                           || ' cannot be  after the termination date '
                                           || to_char(xx.termination_date, 'MM/DD/YYYY');

                        raise l_validate_error;
                    end if;

                end if;
            end loop;

   /*   FOR XX IN (
           SELECT c.plan_start_date
                , c.plan_end_date
                , NVL(c.grace_period,0) grace_period
                , NVL(c.runout_period_days,0) runout_period_days
                , C.EFFECTIVE_END_DATE+90 TERMINATION_DATE -- 90 days is defined based on the ordinance
                , c.status
           FROM   BEN_PLAN_ENROLLMENT_SETUP C
           WHERE  c.plan_type = P_SERVICE_TYPE
             AND  C.STATUS IN ('A','I')
             AND  NVL(C.SF_ORDINANCE_FLAG,'N') = 'Y'
             AND  (C.EFFECTIVE_END_DATE IS NULL OR C.EFFECTIVE_END_DATE+90 > SYSDATE)
             AND  C.ACC_ID = X.ACC_ID
               AND  c.plan_start_date <= P_SERVICE_start_DATE
             AND  TRUNC(c.plan_end_date)
                 + case when effective_end_date is not null then 90
                      else NVL(c.grace_period,0) end >= P_SERVICE_end_DATE
          )
       LOOP
            IF xx.TERMINATION_DATE IS NOT NULL
              THEN
                IF   xx.TERMINATION_DATE < SYSDATE THEN
                 X_ERROR_MESSAGE := 'Cannot Reimburse at this time,' ||p_service_type ||' plan has expired' ;
                 RAISE l_validate_error;
                ELSIF  xx.TERMINATION_DATE > SYSDATE
                 AND   P_SERVICE_START_DATE > xx.TERMINATION_DATE THEN
                 X_ERROR_MESSAGE := 'Cannot Reimburse at this time, Service Date '
                          ||TO_CHAR(P_SERVICE_START_DATE,'MM/DD/YYYY')||' cannot be  after the termination date '
                          ||TO_CHAR(xx.TERMINATION_DATE,'MM/DD/YYYY') ;
                 RAISE l_validate_error;
                end if;
            END IF;

       END LOOP;
       */

            for xx in (
                select
                    max(plan_end_date)                          plan_end_date,
                    max(nvl(effective_end_date, plan_end_date)) effective_end_date,
                    sum(
                        case
                            when effective_end_date is not null
                                 and plan_end_date > sysdate then
                                1
                            when effective_end_date is not null
                                 and plan_end_date < sysdate
                                 and effective_end_date + 90 > sysdate then
                                1
                            else
                                0
                        end
                    )                                           term
                from
                    ben_plan_enrollment_setup c
                where
                        c.plan_type = p_service_type
                    and c.status in ( 'A', 'I' )
                    and nvl(c.sf_ordinance_flag, 'N') = 'Y'
                    and c.acc_id = x.acc_id
                    and c.plan_start_date >= p_service_start_date
            ) loop
                if
                    xx.plan_end_date < trunc(sysdate)
                    and xx.term = 0
                then
                    x_error_message := 'Cannot Reimburse at this time,'
                                       || p_service_type
                                       || ' plan has expired , out of the runout period';
                    raise l_validate_error;
                end if;

                if
                    xx.plan_end_date < trunc(sysdate)
                    and xx.effective_end_date + 90 <= trunc(sysdate)
                    and xx.term = 1
                then
                    x_error_message := 'Cannot Reimburse at this time,'
                                       || p_service_type
                                       || ' plan has termed , out of the runout period';
                    raise l_validate_error;
                end if;

            end loop;

        end loop;
  /* IF l_plan_exists = 'N' THEN
      X_ERROR_MESSAGE := 'Cannot Reimburse at this time, as there is no valid plan year for this service type ';
      RAISE l_validate_error;
   END IF;*/
        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:X_RETURN_STATUS ' || x_return_status);
    exception
        when l_validate_error then
            x_return_status := 'E';
            pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:X_ERROR_MESSAGE ' || x_error_message);
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:X_ERROR_MESSAGE ' || x_error_message);
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end validate_hra_fsa_disbursement;

    procedure create_fsa_disbursement (
        p_acc_num            in varchar2,
        p_acc_id             in number,
        p_vendor_id          in number,
        p_vendor_acc_num     in varchar2,
        p_amount             in number,
        p_patient_name       in varchar2,
        p_note               in varchar2,
        p_user_id            in number,
        p_service_start_date in varchar2,
        p_service_end_date   in varchar2,
        p_date_received      in varchar2,
        p_service_type       in varchar2,
        p_claim_source       in varchar2,
        p_claim_method       in varchar2,
        p_bank_acct_id       in number,
        p_pay_reason         in number,
        p_doc_flag           in varchar2,
        p_insurance_category in varchar2,
        p_claim_category     in varchar2,
        p_memo               in varchar2,
        x_claim_id           out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        l_batch_number       varchar2(30);
        setup_error exception;
        l_claim_error_flag   varchar2(30);
        l_doc_flag           varchar2(30);
        l_insurance_category varchar2(30);
        l_claim_category     varchar2(30);
        l_pay_reason         number;
        l_claim_id           number;
        l_claim_type         varchar2(30);
        l_vendor_id          number;
    begin
        x_return_status := 'S';
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
        pc_log.log_error('create_fsa_disbursement,L_BATCH_NUMBER', l_batch_number);
        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for amount';
            raise setup_error;
        end if;

        if
            p_doc_flag is null
            and p_service_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
        then
            l_doc_flag := 'N';
        else
            l_doc_flag := 'Y';
        end if;

        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'P_CLAIM_SOURCE '
                                                    || p_claim_source
                                                    || ' , P_CLAIM_METHOD '
                                                    || p_claim_method
                                                    || ' P_PAY_REASON '
                                                    || p_pay_reason);

        if p_service_type <> 'FSA' then
            l_insurance_category := null;
            l_claim_category := null;
        end if;

        if p_claim_source in ( 'FILE UPLOAD', 'MOBILE', 'TAKEOVER' ) then
            l_claim_type := p_claim_method;
        else
            if nvl(p_bank_acct_id, -1) <> -1 then
                if p_claim_source = 'INTERNAL' then
                    l_claim_type := 'SUBSCRIBER_ACH';
                elsif p_claim_source = 'FILE UPLOAD' then
                    l_claim_type := 'SUBSCRIBER_ACH_EDI';
                else
                    l_claim_type := 'SUBSCRIBER_ONLINE_ACH';
                end if;

                l_pay_reason := 19;
            else
                if p_claim_method = 'CHEQUE' then
                    if p_pay_reason = 12 then
                        l_claim_type := 'SUBSCRIBER';
                    else
                        l_claim_type := 'PROVIDER';
                    end if;

                else
                    l_claim_type := p_claim_method;
                end if;
            end if;
        end if;

  -- Applicable only for SAM submitted claims

        if l_claim_type is null then
            l_claim_type := nvl(p_claim_method, 'SUBSCRIBER');
        end if;
        if l_claim_type in ( 'SUBSCRIBER_ONLINE_ACH', 'SUBSCRIBER_ACH', 'ACH', 'SUBCRIBER_ACH_EDI' ) then
            l_pay_reason := 19;
        end if;

        if l_claim_type in ( 'PROVIDER_ONLINE', 'PROVIDER', 'PROVIDER_EDI' ) then
            l_pay_reason := 11;
        end if;

        if l_claim_type in ( 'SUBSCRIBER_ONLINE', 'SUBSCRIBER', 'SUBSCRIBER_EDI', 'SUBSCRIBER_TAKEOVER' ) then
            l_pay_reason := 12;
        end if;

        if l_claim_type in ( 'DEBIT_CARD_OFFSET' ) then
            l_pay_reason := p_pay_reason;
        end if;
        if
            l_claim_type in ( 'SUBSCRIBER_EDI', 'SUBSCRIBER_ONLINE', 'DEBIT_CARD_OFFSET' )
            and nvl(p_vendor_id, -1) = -1
        then
            for x in (
                select
                    x.acc_num,
                    x.acc_id,
                    x.vendor_id,
                    c.first_name
                    || ' '
                    || c.middle_name
                    || ' '
                    || c.last_name name,
                    c.address,
                    c.city,
                    c.state,
                    c.zip
                from
                    (
                        select
                            a.vendor_id,
                            b.acc_id,
                            b.pers_id,
                            b.acc_num,
                            a.address1,
                            a.city,
                            a.state,
                            a.zip
                        from
                            vendors a,
                            account b
                        where
                                a.orig_sys_vendor_ref (+) = p_acc_num
                            and b.acc_num = p_acc_num
                            and a.orig_sys_vendor_ref (+) = b.acc_num
                    )      x,
                    person c
                where
                        x.pers_id = c.pers_id
                    and ( x.address1 is null
                          or upper(x.address1) = upper(c.address) )
                    and ( x.city is null
                          or upper(x.city) = upper(c.city) )
                    and ( x.state is null
                          or upper(x.state) = upper(c.state) )
                    and ( x.zip is null
                          or upper(x.zip) = upper(c.zip) )
            ) loop
                pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'x.VENDOR ID '
                                                            || x.vendor_id
                                                            || ' , P_ACC_NUM '
                                                            || p_acc_num);

                l_vendor_id := x.vendor_id;
                pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'l_VENDOR ID '
                                                            || l_vendor_id
                                                            || ' , P_ACC_NUM '
                                                            || p_acc_num);
            end loop;
        else
            l_vendor_id := p_vendor_id;
        end if;

        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'after validate_hra_fsa_disbursement:L_vendor_id ' || l_vendor_id);
        if
            l_vendor_id is null
            and l_claim_type in ( 'SUBSCRIBER_EDI', 'SUBSCRIBER_ONLINE', 'SUBSCRIBER_TAKEOVER', 'DEBIT_CARD_OFFSET' )
        then
            for x in (
                select
                    first_name
                    || ' '
                    || last_name name,
                    address,
                    city,
                    state,
                    zip,
                    b.acc_id
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and b.acc_num = p_acc_num
            ) loop
                pc_payee.add_payee(
                    p_payee_name          => x.name,
                    p_payee_acc_num       => p_acc_num,
                    p_address             => x.address,
                    p_city                => x.city,
                    p_state               => x.state,
                    p_zipcode             => x.zip,
                    p_acc_num             => p_acc_num,
                    p_user_id             => p_user_id,
                    p_orig_sys_vendor_ref => p_acc_num,
                    p_acc_id              => x.acc_id,
                    p_payee_type          => p_service_type,
                    p_payee_tax_id        => null,
                    x_vendor_id           => l_vendor_id,
                    x_return_status       => x_return_status,
                    x_error_message       => x_error_message
                );

                pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'l_VENDOR ID '
                                                            || l_vendor_id
                                                            || ' , CLAIM_TYPE '
                                                            || l_claim_type);
                if x_return_status = 'E' then
                    pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'X_ERROR_MESSAGE ID ' || x_error_message);
                    raise setup_error;
                end if;

            end loop;
        end if;

        if l_vendor_id is not null then
            if l_claim_type not in ( 'SUBSCRIBER_EDI', 'SUBSCRIBER', 'SUBSCRIBER_ONLINE', 'SUBSCRIBER_TAKEOVER', 'DEBIT_CARD_OFFSET' )
            then
                update vendors
                set
                    orig_sys_vendor_ref = null
                where
                    vendor_id = p_vendor_id;

            else
                update vendors
                set
                    orig_sys_vendor_ref = p_acc_num
                where
                    vendor_id = nvl(p_vendor_id, l_vendor_id);

            end if;
        end if;

        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'VENDOR ID '
                                                    || l_vendor_id
                                                    || ' , CLAIM_TYPE '
                                                    || l_claim_type);
        validate_hra_fsa_disbursement(
            p_acc_id             => p_acc_id,
            p_amount             => p_amount,
            p_service_start_date => p_service_start_date,
            p_service_end_date   => p_service_end_date,
            p_service_type       => p_service_type,
            x_return_status      => x_return_status,
            x_error_message      => x_error_message
        );

        if x_return_status = 'E' then
            pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'validate_hra_fsa_disbursement:X_ERROR_MESSAGE ' || x_error_message);
            raise setup_error;
            x_return_status := 'S';
            l_claim_error_flag := 'Y';
        end if;

        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'after validate_hra_fsa_disbursement:L_vendor_id ' || l_vendor_id);
        if nvl(p_bank_acct_id, -1) <> -1 then
            select
                doc_seq.nextval
            into l_claim_id
            from
                dual;

        elsif l_vendor_id is not null then
            select
                doc_seq.nextval
            into l_claim_id
            from
                dual;

        end if;

        pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'after validate_hra_fsa_disbursement:l_claim_id ' || l_claim_id);

   -- Check Disbursement
        if l_vendor_id is not null then
            for x in (
                select
                    count(*) cnt
                from
                    account a,
                    person  b,
                    vendors c
                where
                        a.acc_id = c.acc_id
                    and a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
                    and a.acc_id = p_acc_id
                    and c.vendor_id = l_vendor_id
            ) loop
                if x.cnt = 0 then
                    pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'Vendor id is not created or associated to this account for vendor id ' || l_vendor_id
                    );
                    x_error_message := 'There has been error processing your claim , Please Contact Customer Service at 800-617-4729 or email customer.service@sterlingadministration.com. '
                    ;
                    raise setup_error;
                end if;
            end loop;

            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                service_start_date,
                service_end_date,
                service_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                date_of_service,
                patient_name,
                pay_reason,
                bank_acct_id,
                memo
           --   ,DOC_FLAG
                ,
                insurance_category,
                expense_category,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entrp_id
            )
                select
                    payment_register_seq.nextval,
                    l_batch_number,
                    p_acc_num,
                    a.acc_id,
                    b.pers_id,
                    vendor_name,
                    vendor_id,
                    p_vendor_acc_num,
                    upper(substr(last_name, 1, 4))
                    || to_char(sysdate, 'YYYYMMDDHHMISS'),
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
                            substr(account_type, 1, 3) like substr(a.acc_num, 1, 3)
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
                    p_amount,
                    p_note
                    || nvl2(x_error_message, ',ERROR: ' || x_error_message, ''),
                    l_claim_type,
                    p_service_start_date,
                    p_service_end_date,
                    p_service_type,
                    'N',
                    l_claim_error_flag,
                    'N',
                    p_service_start_date,
                    p_patient_name,
                    l_pay_reason,
                    decode(p_bank_acct_id, -1, null, p_bank_acct_id),
                    p_memo
                --   , P_DOC_FLAG
                    ,
                    nvl(p_insurance_category, l_insurance_category),
                    nvl(p_claim_category, l_claim_category),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    b.entrp_id
                from
                    account a,
                    person  b,
                    vendors c
                where
                        a.acc_id = c.acc_id
                    and a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
                    and a.acc_id = p_acc_id
                    and c.vendor_id = l_vendor_id;

            if sql%rowcount > 0 then
                x_claim_id := l_claim_id;
                pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'after validate_hra_fsa_disbursement:X_CLAIM_ID ' || x_claim_id);
            end if;

        end if;
       -- Subscriber ACH
        if nvl(p_bank_acct_id, -1) <> -1 then
            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                service_start_date,
                service_end_date,
                service_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                date_of_service,
                patient_name,
                pay_reason,
                bank_acct_id,
                memo
           --   ,DOC_FLAG
                ,
                insurance_category,
                expense_category,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entrp_id
            )
                select
                    payment_register_seq.nextval,
                    l_batch_number,
                    p_acc_num,
                    a.acc_id,
                    b.pers_id,
                    'Paid by Subscriber',
                    null,
                    null,
                    upper(substr(last_name, 1, 4))
                    || to_char(sysdate, 'YYYYMMDDHHMISS'),
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
                            substr(account_type, 1, 3) like substr(a.acc_num, 1, 3)
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
                    p_amount,
                    p_note,
                    l_claim_type,
                    p_service_start_date,
                    p_service_end_date,
                    p_service_type,
                    'N',
                    l_claim_error_flag,
                    'N',
                    p_service_start_date,
                    p_patient_name,
                    l_pay_reason,
                    decode(p_bank_acct_id, -1, null, p_bank_acct_id),
                    p_memo
                --   , P_DOC_FLAG
                    ,
                    nvl(p_insurance_category, l_insurance_category),
                    nvl(p_claim_category, l_claim_category),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    b.entrp_id
                from
                    account a,
                    person  b
                where
                        a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
                    and a.acc_id = p_acc_id;

            if sql%rowcount > 0 then
                x_claim_id := l_claim_id;
            end if;
        end if;
     --  COMMIT;
        if x_claim_id is not null then
            insert into claimn (
                claim_id,
                pers_id,
                pers_patient,
                claim_code,
                prov_name,
                claim_date_start,
                claim_date_end,
                service_status,
                service_start_date,
                service_end_date,
                service_type,
                claim_amount,
                claim_paid,
                claim_pending
 --   ,DENIED_AMOUNT
 --   ,DENIED_REASON
                ,
                claim_status,
                doc_flag,
                insurance_category,
                expense_category,
                note,
                entrp_id,
                claim_source,
                pay_reason,
                vendor_id,
                bank_acct_id,
                takeover
         -- ,TRANS_FRAUD_FLAG
            )
                select
                    claim_id,
                    pers_id,
                    pers_id,
                    claim_code,
                    provider_name,
                    p_date_received,
                    trans_date,
                    2,
                    service_start_date,
                    service_end_date,
                    service_type,
                    claim_amount,
                    0,
                    claim_amount
    --,DECODE(L_CLAIM_ERROR_FLAG,'Y',CLAIM_AMOUNT,0)
  --  ,DECODE(L_CLAIM_ERROR_FLAG,'Y',X_ERROR_MESSAGE,null)
                    ,
                    case
                        when l_claim_error_flag = 'Y' then
                            'ERROR'
                        else
                            case
                                when p_service_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'HRA',
                                                         'HRP', 'HR5', 'HR4', 'ACO' ) then
                                        decode(p_doc_flag, 'Y', 'PENDING_DOC', 'PENDING_REVIEW')
                                else
                                    'PENDING_REVIEW'
                            end
                    end,
                    nvl(p_doc_flag, l_doc_flag),
                    nvl(p_insurance_category, l_insurance_category),
                    nvl(p_claim_category, l_claim_category),
                    'Disbursement Created on ' || to_char(trans_date, 'RRRRMMDD'),
                    a.entrp_id,
                    decode(p_claim_source, 'FILE UPLOAD', 'EDI', p_claim_source),
                    a.pay_reason,
                    vendor_id,
                    bank_acct_id,
                    decode(p_claim_source, 'TAKEOVER', 'Y', 'N')
        --  ,PC_CLAIM.GET_TRANS_FRAUD_FLAG(P_ACC_ID)  -- Added By Jaggi #9775
                from
                    payment_register a
                where
                        a.batch_number = l_batch_number
                    and a.acc_num = p_acc_num
                    and a.claim_id = l_claim_id;

        end if;
    /*
        INSERT INTO PAYMENT
        (CHANGE_NUM
        ,CLAIMN_ID
        ,PAY_DATE
        ,AMOUNT
        ,REASON_CODE
        ,PAY_NUM
        ,NOTE
        ,ACC_ID)
        SELECT CHANGE_SEQ.NEXTVAL
                ,A.CLAIM_ID
                ,TRANS_DATE
                ,B.CLAIM_PAID
                ,A.PAY_REASON
                ,NULL
                ,'Generate Disbursement '||TO_CHAR(TRANS_DATE,'RRRRMMDD')
                ,ACC_ID
  FROM PAYMENT_REGISTER A,CLAIMN B
  WHERE A.BATCH_NUMBER = l_batch_number
        AND   A.CLAIM_ID = B.CLAIM_ID
  AND   A.ACC_NUM = P_ACC_NUM
        AND   B.CLAIM_PAID > 0
        AND CLAIM_ERROR_FLAG = 'N'
        AND INSUFFICIENT_FUND_FLAG = 'N'
        AND  B.CLAIM_STATUS = 'PENDING'
  AND  A.CLAIM_ID = l_claim_id;*/


    exception
        when setup_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end create_fsa_disbursement;

    procedure update_hra_fsa_disbursement (
        p_acc_id             in number,
        p_claim_amount       in number,
        p_service_start_date in date,
        p_service_end_date   in date,
        p_service_type       in varchar2,
        p_patient_name       in varchar2,
        p_note               in varchar2,
        p_pay_reason         in varchar2,
        p_memo               in varchar2,
        p_insurance_caterogy in varchar2,
        p_expense_category   in varchar2,
        p_user_id            in number,
        p_doc_flag           in varchar2,
        p_claim_id           in number,
        p_claim_status       in varchar2,
        p_plan_start_date    in date,
        p_plan_end_date      in date,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        setup_error exception;
        l_claim_error_flag   varchar2(30);
        l_doc_flag           varchar2(30);
        l_insurance_category varchar2(30);
        l_claim_category     varchar2(30);
    begin
        x_return_status := 'S';
        if is_number(p_claim_amount) = 'N' then
            x_error_message := 'Enter only numeric values for amount';
            raise setup_error;
        end if;

        if p_claim_status not in ( 'PENDING_OTHER_INSURANCE', 'PENDING_DOC', 'PENDING', 'PENDING_REVIEW' ) then
            x_error_message := 'Cannot update claim that is not in pending status';
            raise setup_error;
        else
            validate_hra_fsa_disbursement(
                p_acc_id             => p_acc_id,
                p_amount             => p_claim_amount,
                p_service_start_date => p_service_start_date,
                p_service_end_date   => p_service_end_date,
                p_service_type       => p_service_type,
                x_return_status      => x_return_status,
                x_error_message      => x_error_message
            );

            if x_return_status = 'E' then
                x_return_status := 'S';
                l_claim_error_flag := 'Y';
            end if;
            update payment_register
            set
                claim_amount = p_claim_amount,
                note = p_note,
                service_start_date = p_service_start_date,
                service_end_date = p_service_end_date,
                claim_error_flag = l_claim_error_flag
                  --    ,INSUFFICIENT_FUND_FLAG= L_INSUFFICIENT_FUND_FLAG
                ,
                date_of_service = p_service_start_date,
                patient_name = p_patient_name
                  --    ,PAY_REASON            = NVL(P_PAY_REASON,PAY_REASON)
                ,
                memo = p_memo,
                insurance_category = p_insurance_caterogy,
                expense_category = p_expense_category,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = p_claim_id;

            update claimn
            set
                service_start_date = p_service_start_date,
                service_end_date = p_service_end_date,
                denied_amount = decode(l_claim_error_flag, 'Y', claim_amount, 0),
                insurance_category = nvl(p_insurance_caterogy, l_insurance_category),
                expense_category = nvl(p_expense_category, l_claim_category),
                note = p_note,
                claim_amount = p_claim_amount,
                claim_paid = pc_claim.f_claim_paid(claim_id),
                claim_pending = p_claim_amount - nvl(
                    pc_claim.f_claim_paid(claim_id),
                    0
                ),
                doc_flag = p_doc_flag,
                plan_start_date = p_plan_start_date,
                plan_end_date = p_plan_end_date
            where
                claim_id = p_claim_id;

            update claimn
            set
                claim_status = p_claim_status
            where
                claim_status in ( 'PENDING_OTHER_INSURANCE', 'PENDING_DOC', 'PENDING', 'PENDING_REVIEW' )
                and claim_id = p_claim_id;

        end if;

    exception
        when setup_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_error_message := sqlerrm;
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end update_hra_fsa_disbursement;

    procedure cancel_hra_fsa_disbursement (
        p_claim_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        create_error exception;
    begin
        x_return_status := 'S';
        pc_log.log_error('P_CLAIM_ID ', p_claim_id);
        for x in (
            select
                claim_amount,
                claim_status,
                claim_pending,
                claim_paid
            from
                claimn
            where
                claim_id = p_claim_id
        ) loop
            if x.claim_status = 'PAID' then
                x_error_message := 'Cannot Cancel Paid Claim';
                raise create_error;
            else
         /* DELETE FROM PAYMENT b
          WHERE  claimn_id = p_claim_id;*/

          /* making the account negative in payment so that if we want to revert we can */
                update balance_register
                set
                    acc_id = - acc_id
                where
                    change_id in (
                        select
                            change_num
                        from
                            payment
                        where
                            claimn_id = p_claim_id
                    );

                update payment
                set
                    claimn_id = - claimn_id
                where
                    claimn_id = p_claim_id;

                update claimn
                set
                    claim_status = 'CANCELLED'
                where
                    claim_id = p_claim_id;

                update claimn
                set
                    claim_status = 'CANCELLED'
                where
                    claim_id = p_claim_id;

                update deductible_balance
                set
                    status = 'CANCELLED',
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                    claim_id = p_claim_id;

                update payment_register
                set
                    cancelled_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    claim_id = p_claim_id;

                update checks
                set
                    status = 'PURGED'
                where
                        entity_type = 'CLAIMN'
                    and entity_id = p_claim_id;

                update ach_transfer
                set
                    status = 9
                where
                    claim_id = p_claim_id;

            end if;
        end loop;

    exception
        when create_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end cancel_hra_fsa_disbursement;

    procedure deny_hra_fsa_disbursement (
        p_claim_id      in number,
        p_claim_status  in varchar2,
        p_denied_reason in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        create_error exception;
        l_claim_status varchar2(30);
    begin
        x_return_status := 'S';
        if nvl(p_denied_reason, '-1') = '-1' then
            x_error_message := 'Denied Reason must be specified ';
            raise create_error;
        end if;

        for x in (
            select
                claim_amount,
                claim_status,
                claim_pending,
                claim_paid
            from
                claimn
            where
                claim_id = p_claim_id
        ) loop
            if
                x.claim_amount <> x.claim_pending
                and x.claim_paid > 0
                and x.claim_status = 'PAID'
            then
                x_error_message := 'Claim is not fully adjusted down to zero, So Adjustment must be done on this claim before attempting to deny it'
                ;
                raise create_error;
            else
                update claimn
                set
                    claim_status =
                        case
                            when claim_paid > 0 then
                                'PAID'
                            else
                                'DENIED'
                        end,
                    denied_amount = claim_amount - claim_paid,
                    claim_pending = 0 --Added to update the pending amt in case of manual adjustment
                    ,
                    denied_reason = decode(p_denied_reason, '-1', null, p_denied_reason),
                    reviewed_date = sysdate,
                    reviewed_by = p_user_id
                where
                    claim_id = p_claim_id
                returning claim_status into l_claim_status;

        /*  IF l_claim_status = 'DENIED' THEN
             UPDATE CHECKS SET STATUS = 'PURGED'
             WHERE ENTITY_TYPE = 'CLAIMN' AND ENTITY_ID = P_CLAIM_ID;
             UPDATE ACH_TRANSFER SET STATUS = 9
             WHERE CLAIM_ID = P_CLAIM_ID;

          END IF;
          */
                if
                    p_claim_status = 'DENIED'
                    and p_denied_reason <> 'DUPLICATE_NL'
                then
                    pc_notifications.insert_deny_claim_events(p_claim_id, p_user_id);
                end if;

            end if;
        end loop;

    exception
        when create_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end deny_hra_fsa_disbursement;

    procedure process_hra_fsa_disbursement (
        p_claim_id          in number,
        p_claim_status      in varchar2,
        p_approved_amount   in number,
        p_denied_amount     in number,
        p_deductible_amount in number,
        p_denied_reason     in varchar2,
        p_note              in varchar2,
        p_user_id           in number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is
        create_error exception;
        l_claim_status      varchar2(30);
        l_sf_ordinance_flag varchar2(1) := 'N';
    begin
        x_return_status := 'S';
        l_claim_status := p_claim_status;
        if
            p_claim_status = 'APPROVED_FOR_CHEQUE'
            and nvl(p_approved_amount, 0) = 0
        then
            x_error_message := 'Approved amount cannot be zero for an approved claim';
            raise create_error;
        end if;

        for x in (
            select
                claim_amount,
                claim_status,
                service_start_date,
                plan_start_date,
                plan_end_date,
                service_type
            from
                claimn
            where
                claim_id = p_claim_id
        ) loop
            if
                p_claim_status in ( 'DENIED', 'ERROR' )
                and x.claim_status not in ( 'AWAITING_APPROVAL', 'PENDING_DOC', 'PENDING_REVIEW', 'PENDING_OTHER_INSURANCE', 'PENDING'
                )
            then
                x_error_message := 'Cannot deny a claim that has been already processed';
                raise create_error;
            end if;

            if nvl(p_approved_amount, 0) + nvl(p_denied_amount, 0) + nvl(p_deductible_amount, 0) <> x.claim_amount then
                x_error_message := 'Total of Approved, Denied and Deductible Amount '
                                   || to_char(nvl(p_approved_amount, 0) + nvl(p_denied_amount, 0) + nvl(p_deductible_amount, 0))
                                   || ' must equal claim amount '
                                   || x.claim_amount;

                raise create_error;
            end if;

            for xx in (
                select
                    nvl(sf_ordinance_flag, 'N') sf_ordinance_flag
                from
                    ben_plan_enrollment_setup
                where
                        plan_start_date = x.plan_start_date
                    and plan_end_date = x.plan_end_date
                    and plan_type = x.service_type
            ) loop
                l_sf_ordinance_flag := xx.sf_ordinance_flag;
            end loop;

            if
                x.service_start_date > sysdate
                and l_sf_ordinance_flag = 'N'
            then
                l_claim_status := 'APPROVED_FUTURE_SRV_DATE';
                pc_notifications.hrafsa_future_claim_notify(p_claim_id);
            end if;

        end loop;

        if
            p_denied_amount > 0
            and nvl(p_denied_reason, '-1') = '-1'
        then
            x_error_message := 'Denied Reason must be specified when denied amount is more than zero';
            raise create_error;
        end if;

        update claimn
        set
            claim_status = l_claim_status,
            approved_amount = p_approved_amount,
            denied_amount = p_denied_amount,
            denied_reason = decode(p_denied_reason, '-1', null, p_denied_reason),
            reviewed_date = sysdate,
            approved_date = decode(p_claim_status, 'APPROVED', sysdate, null),
            deductible_amount = nvl(p_deductible_amount, 0),
            claim_pending = claim_amount - ( nvl(p_approved_amount, 0) + nvl(p_deductible_amount, 0) + nvl(p_denied_amount, 0) ),
            reviewed_by = p_user_id,
            note = substr(p_note
                          || ' Reviewed by '
                          || get_user_name(p_user_id),
                          1,
                          4000)
        where
            claim_id = p_claim_id;

   --For partially denied claim, we need to sed notifications
        if
            p_claim_status = 'DENIED'
            and p_denied_reason <> 'DUPLICATE_NL'
        then
            pc_notifications.insert_deny_claim_events(p_claim_id, p_user_id);
        elsif
            p_claim_status <> 'DENIED'
            and p_denied_amount > 0
        then
            pc_log.log_error('Before call to notification', p_claim_id);
            pc_notifications.insert_deny_claim_events(p_claim_id, p_user_id);
        elsif p_claim_status = 'APPROVED' then  /* added for Ticket 4286 */
            pc_notifications.insert_approved_claim_events(p_claim_id, p_user_id);
        end if;

        if nvl(p_deductible_amount, 0) > 0 then
            for x in (
                select
                    deductible_amount,
                    approved_amount,
                    pers_id,
                    claim_status,
                    pc_person.acc_id(pers_id) acc_id,
                    approved_date,
                    note,
                    pers_patient
                from
                    claimn
                where
                        claim_id = p_claim_id
                    and service_type in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
                    and nvl(deductible_amount, 0) > 0
            ) loop
                pc_claim.ins_deductible_balance(
                    p_acc_id            => x.acc_id,
                    p_pers_id           => x.pers_id,
                    p_pers_patient      => x.pers_patient,
                    p_claim_id          => p_claim_id,
                    p_deductible_amount => x.deductible_amount,
                    p_pay_date          => x.approved_date,
                    p_status            => x.claim_status,
                    p_note              => 'Approved on '
                              || to_char(x.approved_date, 'MM/DD/YYYY'),
                    p_user_id           => p_user_id
                );
            end loop;
        end if;

    exception
        when create_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/
    end process_hra_fsa_disbursement;

    procedure create_hra_disbursement (
        p_acc_num            in varchar2,
        p_acc_id             in number,
        p_vendor_id          in number,
        p_vendor_acc_num     in varchar2,
        p_amount             in number,
        p_patient_name       in varchar2,
        p_note               in varchar2,
        p_user_id            in number,
        p_service_start_date in varchar2,
        p_service_end_date   in varchar2,
        p_date_received      in varchar2,
        p_service_type       in varchar2,
        p_claim_source       in varchar2,
        p_claim_method       in varchar2,
        p_bank_acct_id       in number,
        p_pay_reason         in number,
        p_doc_flag           in varchar2,
        p_insurance_category in varchar2,
        p_claim_category     in varchar2,
        p_memo               in varchar2,
        x_claim_id           out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        l_batch_number       varchar2(30);
        setup_error exception;
        l_claim_error_flag   varchar2(30);
        l_doc_flag           varchar2(30);
        l_insurance_category varchar2(30);
        l_claim_category     varchar2(30);
        l_service_type       varchar2(30);
        l_pay_reason         number;
        l_claim_id           number;
        l_claim_type         varchar2(30);
        l_vendor_id          number;
    begin
        x_return_status := 'S';
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
        pc_log.log_error('create_fsa_disbursement,L_BATCH_NUMBER', l_batch_number);
        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for amount';
            raise setup_error;
        end if;

        pc_log.log_error('CREATE_HRA_DISBURSEMENT', 'DOC FLAG '
                                                    || p_doc_flag
                                                    || ', SERVICE TYPE '
                                                    || p_service_type);
        pc_log.log_error('CREATE_HRA_DISBURSEMENT', 'CLAIM METHOD '
                                                    || p_claim_method
                                                    || ', P_PAY_REASON '
                                                    || p_pay_reason
                                                    || ' P_VENDOR_ID '
                                                    || p_vendor_id
                                                    || ' bank accct id '
                                                    || p_bank_acct_id);

        if p_service_type is null then
            l_service_type := pc_benefit_plans.get_hra_ben_plan_type(p_acc_id, 'HRA');
        else
            l_service_type := p_service_type;
        end if;

        l_doc_flag := 'Y';
        l_pay_reason := p_pay_reason;
        if p_claim_source in ( 'FILE UPLOAD', 'MOBILE' ) then
            l_claim_type := p_claim_method;
        else
            if nvl(p_bank_acct_id, -1) <> -1 then
                if p_claim_source = 'INTERNAL' then
                    l_claim_type := 'SUBSCRIBER_ACH';
                elsif p_claim_source = 'FILE UPLOAD' then
                    l_claim_type := 'SUBSCRIBER_ACH_EDI';
                else
                    l_claim_type := 'SUBSCRIBER_ONLINE_ACH';
                end if;

                l_pay_reason := 19;
            else
                if p_claim_method = 'CHEQUE' then
                    if p_pay_reason = 12 then
                        l_claim_type := 'SUBSCRIBER';
                    else
                        l_claim_type := 'PROVIDER';
                    end if;

                else
                    l_claim_type := p_claim_method;
                end if;
            end if;
        end if;
  -- Applicable only for SAM submitted claims

        if l_claim_type is null then
            l_claim_type := nvl(p_claim_method, 'SUBSCRIBER');
        end if;
        if l_claim_type in ( 'SUBSCRIBER_ONLINE_ACH', 'SUBSCRIBER_ACH', 'ACH', 'SUBCRIBER_ACH_EDI' ) then
            l_pay_reason := 19;
        end if;

        if l_claim_type in ( 'PROVIDER_ONLINE', 'PROVIDER', 'PROVIDER_EDI' ) then
            l_pay_reason := 11;
        end if;

        if l_claim_type in ( 'SUBSCRIBER_ONLINE', 'SUBSCRIBER', 'SUBSCRIBER_EDI' ) then
            l_pay_reason := 12;
        end if;

        if
            l_claim_type in ( 'SUBSCRIBER_EDI', 'SUBSCRIBER_ONLINE' )
            and nvl(p_vendor_id, -1) = -1
        then
            for x in (
                select
                    x.acc_num,
                    x.acc_id,
                    x.vendor_id,
                    c.first_name
                    || ' '
                    || c.middle_name
                    || ' '
                    || c.last_name name,
                    c.address,
                    c.city,
                    c.state,
                    c.zip
                from
                    (
                        select
                            a.vendor_id,
                            b.acc_id,
                            b.pers_id,
                            b.acc_num,
                            a.address1,
                            a.city,
                            a.state,
                            a.zip
                        from
                            vendors a,
                            account b
                        where
                                a.orig_sys_vendor_ref (+) = p_acc_num
                            and b.acc_num = p_acc_num
                            and a.orig_sys_vendor_ref (+) = b.acc_num
                    )      x,
                    person c
                where
                        x.pers_id = c.pers_id
                    and ( x.address1 is null
                          or upper(x.address1) = upper(c.address) )
                    and ( x.city is null
                          or upper(x.city) = upper(c.city) )
                    and ( x.state is null
                          or upper(x.state) = upper(c.state) )
                    and ( x.zip is null
                          or upper(x.zip) = upper(c.zip) )
            ) loop
                l_vendor_id := x.vendor_id;
            end loop;
        else
            l_vendor_id := p_vendor_id;
        end if;

        if
            l_vendor_id is null
            and l_claim_type in ( 'SUBSCRIBER_EDI', 'SUBSCRIBER_ONLINE' )
        then
            for x in (
                select
                    first_name
                    || ' '
                    || last_name name,
                    address,
                    city,
                    state,
                    zip,
                    b.acc_id
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and b.acc_num = p_acc_num
            ) loop
                pc_payee.add_payee(
                    p_payee_name          => x.name,
                    p_payee_acc_num       => p_acc_num,
                    p_address             => x.address,
                    p_city                => x.city,
                    p_state               => x.state,
                    p_zipcode             => x.zip,
                    p_acc_num             => p_acc_num,
                    p_user_id             => p_user_id,
                    p_orig_sys_vendor_ref => p_acc_num,
                    p_acc_id              => x.acc_id,
                    p_payee_type          => l_service_type,
                    p_payee_tax_id        => null,
                    x_vendor_id           => l_vendor_id,
                    x_return_status       => x_return_status,
                    x_error_message       => x_error_message
                );

                if x_return_status = 'E' then
                    raise setup_error;
                end if;
            end loop;
        end if;

        if l_vendor_id is not null then
            if l_claim_type not in ( 'SUBSCRIBER_EDI', 'SUBSCRIBER', 'SUBSCRIBER_ONLINE' ) then
                update vendors
                set
                    orig_sys_vendor_ref = null
                where
                    vendor_id = p_vendor_id;

            else
                update vendors
                set
                    orig_sys_vendor_ref = p_acc_num
                where
                    vendor_id = nvl(p_vendor_id, l_vendor_id);

            end if;
        end if;

        validate_hra_fsa_disbursement(
            p_acc_id             => p_acc_id,
            p_amount             => p_amount,
            p_service_start_date => p_service_start_date,
            p_service_end_date   => p_service_end_date,
            p_service_type       => l_service_type,
            x_return_status      => x_return_status,
            x_error_message      => x_error_message
        );

        if x_return_status = 'E' then
            raise setup_error;
            x_return_status := 'S';
            l_claim_error_flag := 'Y';
        end if;

        select
            doc_seq.nextval
        into l_claim_id
        from
            dual;

   -- Check Disbursement
        if l_vendor_id is not null then
            for x in (
                select
                    count(*) cnt
                from
                    account a,
                    person  b,
                    vendors c
                where
                        a.acc_id = c.acc_id
                    and a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
                    and a.acc_id = p_acc_id
                    and c.vendor_id = l_vendor_id
            ) loop
                if x.cnt = 0 then
                    pc_log.log_error('CREATE_FSA_DISBURSEMENT', 'Vendor id is not created or associated to this account for vendor id ' || l_vendor_id
                    );
                    x_error_message := 'There has been error processing your claim , Please Contact Customer Service at 800-617-4729 or email customer.service@sterlingadministration.com. '
                    ;
                    raise setup_error;
                end if;
            end loop;

            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                service_start_date,
                service_end_date,
                service_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                date_of_service,
                patient_name,
                pay_reason,
                bank_acct_id,
                memo
           --   ,DOC_FLAG
                ,
                insurance_category,
                expense_category,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entrp_id
            )
                select
                    payment_register_seq.nextval,
                    l_batch_number,
                    p_acc_num,
                    a.acc_id,
                    b.pers_id,
                    vendor_name,
                    vendor_id,
                    p_vendor_acc_num,
                    upper(substr(last_name, 1, 4))
                    || to_char(sysdate, 'YYYYMMDDHHMISS'),
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
                            substr(account_type, 1, 3) like substr(a.acc_num, 1, 3)
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
                    p_amount,
                    p_note,
                    l_claim_type,
                    p_service_start_date,
                    p_service_end_date,
                    l_service_type,
                    'N',
                    l_claim_error_flag,
                    'N',
                    p_service_start_date,
                    p_patient_name,
                    l_pay_reason,
                    decode(p_bank_acct_id, -1, null, p_bank_acct_id),
                    p_memo
                --   , P_DOC_FLAG
                    ,
                    nvl(p_insurance_category, l_insurance_category),
                    nvl(p_claim_category, l_claim_category),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    b.entrp_id
                from
                    account a,
                    person  b,
                    vendors c
                where
                        a.acc_id = c.acc_id
                    and a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
                    and a.acc_id = p_acc_id
                    and c.vendor_id = l_vendor_id;

            if sql%rowcount > 0 then
                x_claim_id := l_claim_id;
            end if;
        end if;
       -- Subscriber ACH
        if nvl(p_bank_acct_id, -1) <> -1 then
            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                service_start_date,
                service_end_date,
                service_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                date_of_service,
                patient_name,
                pay_reason,
                bank_acct_id,
                memo
           --   ,DOC_FLAG
                ,
                insurance_category,
                expense_category,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entrp_id
            )
                select
                    payment_register_seq.nextval,
                    l_batch_number,
                    p_acc_num,
                    a.acc_id,
                    b.pers_id,
                    'Paid to Subscriber',
                    null,
                    null,
                    upper(substr(last_name, 1, 4))
                    || to_char(sysdate, 'YYYYMMDDHHMISS'),
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
                            substr(account_type, 1, 3) like substr(a.acc_num, 1, 3)
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
                    p_amount,
                    p_note,
                    l_claim_type,
                    p_service_start_date,
                    p_service_end_date,
                    l_service_type,
                    'N',
                    l_claim_error_flag,
                    'N',
                    p_service_start_date,
                    p_patient_name,
                    l_pay_reason,
                    decode(p_bank_acct_id, -1, null, p_bank_acct_id),
                    p_memo
                --   , P_DOC_FLAG
                    ,
                    nvl(p_insurance_category, l_insurance_category),
                    nvl(p_claim_category, l_claim_category),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    b.entrp_id
                from
                    account a,
                    person  b
                where
                        a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
                    and a.acc_id = p_acc_id;

            if sql%rowcount > 0 then
                x_claim_id := l_claim_id;
            end if;
        end if;

        if x_claim_id is not null then
            insert into claimn (
                claim_id,
                pers_id,
                pers_patient,
                claim_code,
                prov_name,
                claim_date_start,
                claim_date_end,
                benefits_received_date,
                service_status,
                service_start_date,
                service_end_date,
                service_type,
                claim_amount,
                claim_paid,
                claim_pending
 --   ,DENIED_AMOUNT
 --   ,DENIED_REASON
                ,
                claim_status,
                doc_flag,
                insurance_category,
                expense_category,
                note,
                entrp_id,
                claim_source,
                pay_reason,
                vendor_id,
                bank_acct_id
        --  ,TRANS_FRAUD_FLAG
            )
                select
                    claim_id,
                    pers_id,
                    pers_id,
                    claim_code,
                    provider_name,
                    p_date_received,
                    trans_date,
                    decode(p_claim_source, 'INTERNAL', null, sysdate),
                    2,
                    service_start_date,
                    service_end_date,
                    service_type,
                    claim_amount,
                    0,
                    claim_amount
    --,DECODE(L_CLAIM_ERROR_FLAG,'Y',CLAIM_AMOUNT,0)
  --  ,DECODE(L_CLAIM_ERROR_FLAG,'Y',X_ERROR_MESSAGE,null)
                    ,
                    case
                        when l_claim_error_flag = 'Y' then
                            'ERROR'
                        else
                            case
                                when l_service_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'HRA',
                                                         'HRP', 'HR5', 'HR4', 'ACO' ) then
                                        decode(p_doc_flag, 'Y', 'PENDING_DOC', 'PENDING_REVIEW')
                                else
                                    'PENDING_REVIEW'
                            end
                    end,
                    nvl(p_doc_flag, l_doc_flag),
                    nvl(p_insurance_category, l_insurance_category),
                    nvl(p_claim_category, l_claim_category),
                    'Disbursement Created on ' || to_char(trans_date, 'RRRRMMDD'),
                    a.entrp_id,
                    decode(p_claim_source, 'FILE UPLOAD', 'EDI', p_claim_source),
                    a.pay_reason,
                    vendor_id,
                    bank_acct_id
         -- ,PC_CLAIM.GET_TRANS_FRAUD_FLAG(P_ACC_ID)  -- Added By Jaggi #9775
                from
                    payment_register a
                where
                        a.batch_number = l_batch_number
                    and a.acc_num = p_acc_num
                    and a.claim_id = l_claim_id;

        end if;
    /*
        INSERT INTO PAYMENT
        (CHANGE_NUM
        ,CLAIMN_ID
        ,PAY_DATE
        ,AMOUNT
        ,REASON_CODE
        ,PAY_NUM
        ,NOTE
        ,ACC_ID)
        SELECT CHANGE_SEQ.NEXTVAL
                ,A.CLAIM_ID
                ,TRANS_DATE
                ,B.CLAIM_PAID
                ,A.PAY_REASON
                ,NULL
                ,'Generate Disbursement '||TO_CHAR(TRANS_DATE,'RRRRMMDD')
                ,ACC_ID
  FROM PAYMENT_REGISTER A,CLAIMN B
  WHERE A.BATCH_NUMBER = l_batch_number
        AND   A.CLAIM_ID = B.CLAIM_ID
  AND   A.ACC_NUM = P_ACC_NUM
        AND   B.CLAIM_PAID > 0
        AND CLAIM_ERROR_FLAG = 'N'
        AND INSUFFICIENT_FUND_FLAG = 'N'
        AND  B.CLAIM_STATUS = 'PENDING'
  AND  A.CLAIM_ID = l_claim_id;*/


    exception
        when setup_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end create_hra_disbursement;

    procedure process_finance_claim (
        p_claim_id      in number,
        p_claim_status  in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_transaction_id   number;
        l_check_number     varchar2(255);
        process_exception exception;
        l_amount           number;
        l_payment_amount   number;
        l_payment_date     date;
        l_change_num       number;
        l_note             varchar2(255);
        l_acc_balance      number := 0;
        l_claim_paid       number := 0;
        l_transaction_date date := sysdate;
    begin
        x_return_status := 'S';
        if p_claim_status = 'APPROVED_FOR_CHEQUE' then
            for x in (
                select
                    b.acc_num,
                    b.acc_id,
                    a.claim_id,
                    c.annual_election,
                    a.service_type,
                    b.pay_reason,
                    b.bank_acct_id,
                    nvl(a.approved_amount, 0)                    approved_amount,
                    nvl(
                        pc_claim.f_claim_paid(a.claim_id),
                        0
                    )                                            claim_paid,
                    nvl(a.approved_amount - nvl(
                        pc_claim.f_claim_paid(a.claim_id),
                        0
                    ),
                        0)                                       claim_pending,
                    c.plan_end_date,
                    a.claim_amount,
                    nvl(a.deductible_amount, 0)                  deductible_amount,
                    a.service_end_date,
                    pc_entrp.get_payroll_integration(a.entrp_id) payroll_flag
                --   , NVL(D.PAYROLL_INTEGRATION,'N') PAYROLL_FLAG
                    ,
                    nvl(a.takeover, 'N')                         takeover,
                    nvl(c.grace_period, 0)                       grace_period,
                    c.plan_start_date,
                    d.account_type,
                    c.plan_type,
                    nvl(c.sf_ordinance_flag, 'N')                sf_ordinance_flag,
                    c.effective_end_date
                from
                    claimn                    a,
                    account                   d,
                    payment_register          b,
                    ben_plan_enrollment_setup c
                where
                        a.claim_id = p_claim_id
                    and a.claim_status = 'APPROVED'
                    and a.pers_id = d.pers_id
                    and c.status in ( 'A', 'I' )
                    and d.account_type in ( 'HRA', 'FSA' )
                    and a.claim_id = b.claim_id
                    and c.acc_id = b.acc_id
                    and ( a.approved_amount > 0
                          or a.deductible_amount > 0 )
                    and a.service_type = c.plan_type
                    and trunc(c.plan_start_date) = trunc(a.plan_start_date)
                    and trunc(c.plan_end_date) = trunc(a.plan_end_date)
                order by
                    claim_id asc,
                    acc_num
            ) loop
     -- We have to check if the reimbursement exceeded annual election
     -- for healthcare FSA
     -- Have to do couple of checks here
     -- Check if contribution YTD = annual election , if it is then
     -- we will not get any more funds, so just deny the claim
     -- if it is less then APPROVE WITH NO FUNDS so we can pay later

     -- if claim amount = deductible amount that means
     -- nothing getting paid out
                l_acc_balance := pc_account.acc_balance(x.acc_id, x.plan_start_date, x.plan_end_date, x.account_type, x.plan_type);

                if l_acc_balance > 0 then
                    l_payment_amount := least(x.claim_pending, l_acc_balance);
                else
                    l_payment_amount := 0;  --used to check if pay out needed
                end if;

                pc_log.log_error('create_fsa_disbursement,process_finance_claim: AUTHORIZE ', l_payment_amount);

             -- This is to handle run out period claims
                if trunc(x.plan_end_date) <= trunc(sysdate) then
                    for xx in (
                        select
                            max(service_date) service_date
                        from
                            claim_detail
                        where
                            claim_id = x.claim_id
                    ) loop
                        if xx.service_date > x.plan_end_date then
                            l_payment_date := x.plan_end_date;
                        else
                            l_payment_date := xx.service_date;
                        end if;
                    end loop;

                    if l_payment_date is null then
                        l_payment_date := x.service_end_date;
                    end if;
                    if
                        x.grace_period > 0
                        and x.service_end_date <= trunc(x.plan_end_date) + x.grace_period
                    then
                        l_payment_date := x.plan_end_date;
                    end if;

                    if
                        x.sf_ordinance_flag = 'Y'
                        and x.service_end_date <= trunc(x.effective_end_date) + 90
                    then
                        l_payment_date := x.plan_end_date;
                    end if;

                end if;
           -- For payroll integration we create payment but dont by check or ACH

                if ( x.payroll_flag = 'Y'
                or x.takeover = 'Y' ) then
                    if l_payment_amount > 0 then
                        insert into payment (
                            change_num,
                            acc_id,
                            pay_date,
                            amount,
                            reason_code,
                            claimn_id,
                            pay_num,
                            note,
                            plan_type,
                            paid_date
                        ) values ( change_seq.nextval,
                                   x.acc_id,
                                   nvl(l_payment_date, sysdate),
                                   l_payment_amount,
                                   x.pay_reason,
                                   x.claim_id,
                                   change_seq.currval,
                                   'Disbursement (Claim ID:'
                                   || x.claim_id
                                   || ') created on '
                                   || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                                   x.service_type,
                                   sysdate ) return change_num into l_change_num;
                   -- Just for records that we took and mailed to employer
                        if x.payroll_flag = 'Y' then
                            pc_check_process.insert_pay_receipt(
                                p_pay_id       => l_change_num,
                                p_check_amount => l_payment_amount,
                                p_acc_id       => x.acc_id,
                                p_user_id      => p_user_id,
                                x_check_number => l_check_number
                            );

                            l_note := 'No checks/ACH issued, Paid by Payroll Integration ***';
                        else
                            l_note := 'No checks/ACH issued, Takeover claim ***';
                        end if;

                        update_claim_totals(x.claim_id);
                        update claimn
                        set
                            claim_status =
                                case
                                    when approved_amount = claim_paid then
                                        'PAID'
                                    else
                                        'PARTIALLY_PAID'
                                end,
                            payment_released_by = p_user_id,
                            payment_release_date = sysdate,
                            note = note
                                   || l_note
                                   || ' payment released by '
                                   || get_user_name(p_user_id)
                                   || ' '
                                   || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
                                   || '***'
                        where
                            claim_id = x.claim_id;

                        null;
                    else
                        if
                            l_payment_amount = 0
                            and x.payroll_flag = 'Y'
                        then
                            if x.claim_paid > 0 then
                                update claimn
                                set
                                    claim_status = 'PARTIALLY_PAID',
                                    note = note
                                           || l_note
                                           || ' payment released by '
                                           || get_user_name(p_user_id)
                                           || ' '
                                           || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
                                           || '***'
                                where
                                    claim_id = x.claim_id;

                            end if;

                            if x.claim_paid = 0 then
                                if x.deductible_amount = 0 then
                                    update claimn
                                    set
                                        claim_status = 'APPROVED_NO_FUNDS'
                                    where
                                        claim_id = x.claim_id;

                                elsif x.deductible_amount > 0 then
                                    update claimn
                                    set
                                        claim_status = 'PAID',
                                        note = note
                                               || l_note
                                               || '  released by '
                                               || get_user_name(p_user_id)
                                               || ' '
                                               || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
                                               || '***'
                                    where
                                        claim_id = x.claim_id;

                                end if;

                            end if;

                        end if; -- l_payment_amount = 0 AND X.PAYROLL_FLAG = 'Y'
                    end if;
                else
                    if l_payment_amount > 0 then
                        update claimn
                        set
                            claim_status = 'APPROVED_FOR_CHEQUE',
                            released_date = sysdate,
                            released_by = p_user_id,
                            note = substr(note
                                          || ' Released by '
                                          || get_user_name(p_user_id),
                                          1,
                                          4000)
                        where
                            claim_id = x.claim_id;

                    elsif l_payment_amount = 0 then
                        if x.deductible_amount = 0 then
                            update claimn
                            set
                                claim_status = 'APPROVED_NO_FUNDS'
                            where
                                claim_id = x.claim_id;

                        elsif x.deductible_amount > 0 then
                            update claimn
                            set
                                claim_status = 'PAID',
                                note = substr(note
                                              || ' Released by '
                                              || get_user_name(p_user_id),
                                              1,
                                              4000)
                            where
                                claim_id = x.claim_id;

                        end if;
                    end if;
                end if;

            end loop;

        else
       -- Called from submit for finance approval
            for x in (
                select
                    b.acc_num,
                    b.acc_id,
                    a.claim_id,
                    c.annual_election,
                    a.service_type,
                    b.pay_reason,
                    b.bank_acct_id,
                    nvl(a.approved_amount, 0)                    approved_amount,
                    d.account_type,
                    nvl(
                        pc_claim.f_claim_paid(a.claim_id),
                        0
                    )                                            claim_paid,
                    nvl(a.approved_amount, 0) - nvl(
                        pc_claim.f_claim_paid(a.claim_id),
                        0
                    )                                            claim_pending,
                    c.plan_end_date,
                    c.plan_start_date,
                    c.plan_type,
                    a.claim_amount,
                    nvl(a.deductible_amount, 0)                  deductible_amount,
                    a.service_end_date,
                    pc_entrp.get_payroll_integration(a.entrp_id) payroll_flag
                   --, NVL(D.PAYROLL_INTEGRATION,'N') PAYROLL_FLAG
                    ,
                    a.denied_amount,
                    nvl(c.grace_period, 0)                       grace_period,
                    nvl(a.takeover, 'N')                         takeover
                from
                    claimn                    a,
                    account                   d,
                    payment_register          b,
                    ben_plan_enrollment_setup c
                where
                        a.claim_id = p_claim_id
                    and a.claim_status = 'APPROVED_FOR_CHEQUE'
                    and a.pers_id = d.pers_id
                    and c.status in ( 'A', 'I' )
                    and a.claim_id = b.claim_id
                    and d.account_type in ( 'HRA', 'FSA' )
                    and c.acc_id = b.acc_id
                    and ( nvl(a.approved_amount, 0) > 0
                          or nvl(a.deductible_amount, 0) > 0 )
                    and a.service_type = c.plan_type
                    and trunc(c.plan_start_date) = trunc(a.plan_start_date)
                    and trunc(c.plan_end_date) = trunc(a.plan_end_date)
                order by
                    claim_id asc,
                    acc_num
            ) loop
     -- We have to check if the reimbursement exceeded annual election
     -- for healthcare FSA
     -- Have to do couple of checks here
     -- Check if contribution YTD = annual election , if it is then
     -- we will not get any more funds, so just deny the claim
     -- if it is less then APPROVE WITH NO FUNDS so we can pay later

     -- if claim amount = deductible amount that means
     -- nothing getting paid out
                pc_log.log_error('create_fsa_disbursement,process_finance_claim: GRACE_PERIOD ', x.grace_period);
                l_acc_balance := nvl(
                    pc_account.acc_balance(x.acc_id, x.plan_start_date, x.plan_end_date, x.account_type, x.plan_type),
                    0
                );

                l_payment_amount := 0;
                if
                    x.claim_amount = x.deductible_amount + nvl(x.denied_amount, 0)
                    and x.approved_amount = 0
                then
                    update claimn
                    set
                        claim_status = 'PAID',
                        claim_paid = 0,
                        payment_released_by = p_user_id,
                        payment_release_date = sysdate
                    where
                        claim_id = x.claim_id;

         /** Fully going towards deductible ***/
                    if x.pay_reason = 11 then
                        pc_notifications.insert_deny_claim_events(x.claim_id, p_user_id);
                    end if;

                else
                    pc_log.log_error('create_fsa_disbursement,process_finance_claim:  x.acc_balance ', l_acc_balance);
                    l_transaction_date := null;
                    if l_acc_balance > 0 then
                        for xx in (
                            select
                                invoice_id,
                                payment_amount
                            from
                                claim_invoice_posting
                            where
                                    claim_id = x.claim_id
                                and posting_status = 'NOT_POSTED'
                                and payment_status is null
                        ) loop
                            l_payment_amount := least(xx.payment_amount, l_acc_balance);
                            l_transaction_date := sysdate + 1;
                            pc_log.log_error('PROCESS_FINANCE_CLAIM: PAYMENT_AMOUNT', xx.payment_amount);
                        end loop;

                        pc_log.log_error('PROCESS_FINANCE_CLAIM: l_acc_balance', l_acc_balance);
                        if nvl(l_payment_amount, 0) = 0 then
                            l_payment_amount := least(x.claim_pending, l_acc_balance);
                        end if;

                        pc_log.log_error('PROCESS_FINANCE_CLAIM: x.claim_pending', x.claim_pending);
                    else
                        l_payment_amount := 0;  --used to check if pay out needed
                    end if;

                    pc_log.log_error('create_fsa_disbursement,process_finance_claim: l_payment_amount ', l_payment_amount);
       -- This is to handle run out period claims
                    if trunc(x.plan_end_date) <= trunc(sysdate) then
                        for xx in (
                            select
                                max(service_date) service_date
                            from
                                claim_detail
                            where
                                claim_id = x.claim_id
                        ) loop
                            if xx.service_date >= trunc(sysdate, 'YYYY') then
                                l_payment_date := x.plan_end_date;
                            else
                                l_payment_date := xx.service_date;
                            end if;
                        end loop;

                        if l_payment_date is null then
                            l_payment_date := x.service_end_date;
                        end if;
                        if
                            x.grace_period > 0
                            and x.service_end_date <= trunc(x.plan_end_date) + x.grace_period
                        then
                            l_payment_date := x.plan_end_date;
                        end if;

                    end if;
     -- For payroll integration we create payment but dont by check or ACH
                    pc_log.log_error('create_fsa_disbursement,process_finance_claim: l_payment_date ', l_payment_date);
                    if ( x.payroll_flag = 'Y'
                    or x.takeover = 'Y' ) then
                        if l_payment_amount > 0 then
                            insert into payment (
                                change_num,
                                acc_id,
                                pay_date,
                                amount,
                                reason_code,
                                claimn_id,
                                pay_num,
                                note,
                                plan_type,
                                paid_date
                            ) values ( change_seq.nextval,
                                       x.acc_id,
                                       nvl(l_payment_date, sysdate),
                                       l_payment_amount,
                                       x.pay_reason,
                                       x.claim_id,
                                       change_seq.currval,
                                       'Disbursement (Claim ID:'
                                       || x.claim_id
                                       || ') created on '
                                       || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                                       x.service_type,
                                       sysdate ) return change_num into l_change_num;
                   -- Just for records that we took and mailed to employer
                            if x.payroll_flag = 'Y' then
                                pc_check_process.insert_pay_receipt(
                                    p_pay_id       => l_change_num,
                                    p_check_amount => l_payment_amount,
                                    p_acc_id       => x.acc_id,
                                    p_user_id      => p_user_id,
                                    x_check_number => l_check_number
                                );

                                l_note := 'No checks/ACH issued, Paid by Payroll Integration ***';
                            else
                                l_note := 'No checks/ACH issued, Takeover claim ***';
                            end if;

                            update_claim_totals(x.claim_id);
                            update claimn
                            set
                                claim_status =
                                    case
                                        when approved_amount = claim_paid then
                                            'PAID'
                                        else
                                            'PARTIALLY_PAID'
                                    end,
                                payment_released_by = p_user_id,
                                payment_release_date = sysdate,
                                note = note
                                       || l_note
                                       || ' payment released by '
                                       || get_user_name(p_user_id)
                                       || ' '
                                       || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
                                       || '***'
                            where
                                claim_id = x.claim_id;

                        end if;
                    else
          /*  IF   x.annual_election <= NVL(pc_fin.contribution_YTD(x.acc_id,x.account_type,x.service_type),0)
            AND  x.service_type IN ('FSA','LPF')
            THEN
               UPDATE CLAIMN
               SET    CLAIM_STATUS = 'DENIED'
                  ,   DENIED_REASON = 'INELIGIBLE_EXP'
                  ,   DENIED_AMOUNT = CLAIM_AMOUNT
               WHERE  CLAIM_ID = X.CLAIM_ID;
            ELS*/
                        if l_acc_balance <= 0 then
                            update claimn
                            set
                                claim_status = 'APPROVED_NO_FUNDS',
                                payment_released_by = p_user_id,
                                payment_release_date = sysdate
                            where
                                claim_id = x.claim_id;

                /** No Funds, have to check if this is going to be paid out ***/
                            if
                                x.service_type in ( 'HRA', 'FSA', 'HR5', 'HRP', 'HR4' )
                                and x.pay_reason = 11
                            then
                                pc_notifications.insert_deny_claim_events(x.claim_id, p_user_id);
                            end if;

                        else
                            l_amount := 0;
                     --  l_amount := LEAST(x.approved_amount,NVL(X.ACC_BALANCE,0));
                            pc_log.log_error('create_fsa_disbursement,process_finance_claim:  X.PAY_REASON ', x.pay_reason);
                            if
                                x.pay_reason = 19
                                and l_payment_amount > 0
                            then
                          -- Schedule ACH to pay out
                          -- Finance have to go in and pay out and it will create payment
                                pc_ach_transfer.ins_ach_transfer_hrafsa(
                                    p_acc_id           => x.acc_id,
                                    p_bank_acct_id     => x.bank_acct_id,
                                    p_transaction_type => 'D',
                                    p_amount           => l_payment_amount,
                                    p_fee_amount       => 0,
                                    p_transaction_date => nvl(l_transaction_date, sysdate),
                                    p_reason_code      => 1,
                                    p_status           => 2,
                                    p_user_id          => p_user_id,
                                    p_claim_id         => p_claim_id,
                                    p_plan_type        => x.service_type,
                                    x_transaction_id   => l_transaction_id,
                                    x_return_status    => x_return_status,
                                    x_error_message    => x_error_message
                                );

                                pc_log.log_error('create_fsa_disbursement,process_finance_claim:UPDATING STATUS   ', x_return_status
                                                                                                                     || ' '
                                                                                                                     || x_error_message
                                                                                                                     );
                                if x_return_status = 'S' then
                                 -- if the claim is RUN OUT claim, update the fee date in balance register to the plan end date
                                    if x.plan_end_date < sysdate then
                                        update balance_register
                                        set
                                            fee_date = x.plan_end_date
                                        where
                                            change_id = x.acc_id || l_transaction_id;

                                    end if;

                                    update claimn
                                    set
                                        payment_released_by = p_user_id,
                                        payment_release_date = sysdate,
                                        note = note
                                               || '  payment released by '
                                               || get_user_name(p_user_id)
                                               || ' '
                                               || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
                                               || '***'
                                    where
                                        claim_id = x.claim_id;

                                    update_claim_totals(x.claim_id);
                                    pc_log.log_error('create_fsa_disbursement,process_finance_claim:UPDATING STATUS   ', x_return_status
                                    );
                                end if;

                            else
                          -- insert to checks table to send to adminisource
                                pc_log.log_error('create_fsa_disbursement,process_finance_claim:  X.PAY_REASON ', x.pay_reason);
                                begin
                                    if l_payment_amount > 0 then
                                        pc_check_process.insert_check(
                                            p_claim_id     => x.claim_id,
                                            p_check_amount => l_payment_amount,
                                            p_acc_id       => x.acc_id,
                                            p_user_id      => p_user_id,
                                            p_status       => 'READY',
                                            p_source       => 'CLAIMN',
                                            x_check_number => l_check_number
                                        );

                                    end if;

                                exception
                                    when others then
                                        x_return_status := 'E';
                                        x_error_message := sqlerrm;
                                end;

                                pc_log.log_error('create_fsa_disbursement,process_finance_claim:  x_return_status ', x_return_status)
                                ;
                                pc_log.log_error('create_fsa_disbursement,process_finance_claim:  l_check_number ', l_check_number);

                           -- We are going to pay out now
                           -- We will create the payment record now
                                if
                                    x_return_status = 'S'
                                    and l_payment_amount > 0
                                then
                                    insert_payment(
                                        p_acc_id        => x.acc_id,
                                        p_claim_id      => x.claim_id,
                                        p_reason_code   => x.pay_reason,
                                        p_amount        => l_payment_amount,
                                        p_plan_type     => x.service_type,
                                        p_payment_date  => nvl(l_payment_date, sysdate),
                                        x_return_status => x_return_status,
                                        x_error_message => x_error_message
                                    );

                                    pc_log.log_error('create_fsa_disbursement,process_finance_claim:AFTER CREATING PAYMENT  x_return_status '
                                    , x_return_status);
                                    l_claim_paid := 0;
                                    if x_return_status = 'S' then
                                        l_claim_paid := pc_claim.f_claim_paid(p_claim_id);
                                        update claimn
                                        set
                                            claim_status =
                                                case
                                                    when nvl(l_claim_paid, 0) = approved_amount then
                                                        'READY_TO_PAY'
                                                    when nvl(l_claim_paid, 0) < approved_amount then
                                                        'PARTIALLY_PAID'
                                                end,
                                            claim_paid = nvl(l_claim_paid, 0),
                                            claim_pending = nvl(approved_amount, claim_amount) - ( nvl(l_claim_paid, 0) ),
                                            payment_released_by = p_user_id,
                                            payment_release_date = sysdate,
                                            note = note
                                                   || '  payment released by '
                                                   || get_user_name(p_user_id)
                                                   || ' '
                                                   || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
                                                   || '***'
                                        where
                                            claim_id = p_claim_id;

                                        pc_log.log_error('create_fsa_disbursement,process_finance_claim:AFTER CREATING PAYMENT  updating claimn '
                                        , x_return_status);

                                 /** Partially paid, but we will no longer get contributions**/
                                        if
                                            x.service_type in ( 'HRA', 'FSA', 'HR5', 'HRP', 'HR4' )
                                            and x.pay_reason = 11
                                        then
                                            pc_log.log_error('create_fsa_disbursement,process_finance_claim:AFTER CREATING PAYMENT insert_deny_claim_events,x.service_type '
                                            , x.service_type);
                                            pc_notifications.insert_deny_claim_events(x.claim_id, p_user_id);
                                        end if;
                        --    END IF;

                                    end if;

                                end if;--x_return_status = 'S'
                            end if; -- B.PAY_REASON = 19
                        end if;   --'APPROVED_TO_DEDUCITBLE'
                   /* UPDATE claimn
                    SET claim_paid =  pc_claim.F_CLAIM_PAID(X.CLAIM_ID)
                      , claim_pending = NVL(APPROVED_AMOUNT,CLAIM_AMOUNT)-(NVL(DENIED_AMOUNT,0)+NVL( pc_claim.F_CLAIM_PAID(X.CLAIM_ID),0))
                    where claim_id = x.claim_id;*/

          --   END IF;
                    end if;

                end if;

            end loop;
        end if;

    exception
        when process_exception then
            x_return_status := 'E';
            pc_log.log_error('create_fsa_disbursement,process_finance_claim:AFTER process_exception  sqlerrm ', sqlerrm);
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            pc_log.log_error('create_fsa_disbursement,process_finance_claim:AFTER when others  sqlerrm ', sqlerrm);
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

            raise;
    end process_finance_claim;

    procedure insert_payment (
        p_acc_id        in number,
        p_claim_id      in number,
        p_reason_code   in number,
        p_amount        in number,
        p_plan_type     in varchar2 default null,
        p_payment_date  in date default sysdate,
        p_pay_num       in varchar2 default null,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('create_fsa_disbursement,process_finance_claim:AFTER CREATE PAYMENT  x_return_status ', x_return_status);
        insert into payment (
            change_num,
            acc_id,
            pay_date,
            amount,
            reason_code,
            claimn_id,
            pay_num,
            note,
            plan_type
        ) values ( change_seq.nextval,
                   p_acc_id,
                   p_payment_date,
                   p_amount,
                   p_reason_code,
                   p_claim_id,
                   p_pay_num,
                   'Disbursement (Claim ID:'
                   || p_claim_id
                   || ') created on '
                   || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                   p_plan_type );

    end insert_payment;

    procedure import_uploaded_claims (
        p_user_id      number,
        p_batch_number in varchar2
    ) as

        app_exception exception;
        l_error_msg        varchar2(150);
        l_first_detail_row boolean;
        l_acc_id           number;
        l_acc_num          varchar2(20);
        l_claim_id         number;
        l_return_status    varchar2(1);
        l_error_message    varchar2(150);
        l_idx              number;
        l_claim_method     varchar2(5);
        l_pay_reason       varchar2(3);
        l_bank_acct_id     number;
        l_service_start_dt date;
        l_service_end_dt   date;
        l_vendor_id        number;
        l_claim_amount     number;
        l_claim_type       varchar2(30);
        l_serice_provider  pc_online_enrollment.varchar2_tbl;
        l_service_date     pc_online_enrollment.varchar2_tbl;
        l_service_end_date pc_online_enrollment.varchar2_tbl;
        l_service_name     pc_online_enrollment.varchar2_tbl;
        l_service_price    pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name pc_online_enrollment.varchar2_tbl;
        l_note             pc_online_enrollment.varchar2_tbl;
        l_tax_code         pc_online_enrollment.varchar2_tbl;
        l_provider_tax_id  pc_online_enrollment.varchar2_tbl;
        l_eob_detail_id    pc_online_enrollment.varchar2_tbl;
        l_eob_linked       pc_online_enrollment.varchar2_tbl;
        l_service_type     varchar2(30);
    begin


  -- for cheyenne, one check per member and provider combination. for others one check per one claim number
  -- so outer loop will not include claim number for chyenne but will for others
  -- and, inner loop where condition will not be restricted by claim number for cheyenne, but will be for others
  -- amt calculation will not include claim_number in where clause but will for others

  -- I am thinking that in order to process claim effectively will combine similar provider
  -- and payout , if some one complains then will decide

        for x in (
            select
                a.acc_id,
                pers_id,
                provider_name,
                state,
                city,
                address,
                zip,
                service_plan_type,
                bank_name,
                bank_acct_number,
                routing_number,
                provider_acct_number,
                acc_num,
                bp.plan_start_date,
                bp.plan_end_date,
                min(format_to_date(service_start_dt)) service_start_dt,
                max(format_to_date(service_end_dt))   service_end_dt,
                sum(claim_amount)                     claim_amount
            from
                claim_interface           a,
                ben_plan_enrollment_setup bp
            where
                    a.interface_status = 'NOT_INTERFACED'
                and a.batch_number = p_batch_number
                and bp.status in ( 'A', 'I' )
                and a.acc_id = bp.acc_id
                and ( ( a.service_plan_type in ( 'HRA', 'HRP', 'ACO', 'HR5', 'HR4' )
                        and bp.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR5', 'HR4' ) )
                      or a.service_plan_type = bp.plan_type )
                and format_to_date(service_start_dt) >= bp.plan_start_date
                and format_to_date(service_end_dt) <= bp.plan_end_date
            group by
                a.acc_id,
                pers_id,
                provider_name,
                state,
                city,
                address,
                zip,
                service_plan_type,
                bank_name,
                bank_acct_number,
                routing_number,
                provider_acct_number,
                acc_num,
                bp.plan_start_date,
                bp.plan_end_date
            having min(format_to_date(service_start_dt)) >= bp.plan_start_date
                   and max(format_to_date(service_end_dt)) <= bp.plan_end_date
        ) loop
            begin
                l_claim_id := null;
                pc_log.log_error('IMPORT_UPLOADED_CLAIMS', x.acc_id);
                if x.claim_amount = 0 then
           /*UPDATE claim_interface
              SET    interface_status ='PROCESSED'
                  ,  error_message = 'Claim Amount is Zero, nothing to pay out'
            WHERE  acc_id = x.acc_id
              AND  provider_name  = x.provider_name
              AND  interface_status = 'NOT_INTERFACED';*/
                    null;
                else
                    l_service_type := x.service_plan_type;
                    if x.service_plan_type = 'HRA' then
                        for xx in (
                            select
                                plan_type
                            from
                                ben_plan_enrollment_setup
                            where
                                    acc_id = x.acc_id
                                and status in ( 'A', 'I' )
                                and plan_type in ( 'HRA', 'HR5', 'HRP', 'HR4', 'ACO' )
                                and trunc(plan_start_date) <= trunc(x.service_start_dt)
                                and trunc(plan_end_date) >= trunc(x.service_end_dt)
                        ) loop
                            l_service_type := xx.plan_type;
                        end loop;

                    end if;

                    l_return_status := 'S';
             -- Check if account holder has bank account, if they do have it then pay them with direct deposit
                    if
                        x.bank_name is null
                        and x.bank_acct_number is null
                        and x.routing_number is null
                    then
                        l_bank_acct_id := pc_user_bank_acct.get_active_bank_acct(x.acc_id, x.bank_acct_number, x.routing_number, x.bank_name
                        );
                    else
                        l_bank_acct_id := pc_user_bank_acct.get_active_bank_acct(x.acc_id, x.bank_acct_number, x.routing_number, x.bank_name
                        );

                  -- No bank account found, then create one
                        if l_bank_acct_id is null then
                            pc_user_bank_acct.insert_user_bank_acct(
                                p_acc_num          => x.acc_num,
                                p_display_name     => x.bank_name,
                                p_bank_acct_type   => 'C',
                                p_bank_routing_num => x.routing_number,
                                p_bank_acct_num    => x.bank_acct_number,
                                p_bank_name        => x.bank_name,
                                p_user_id          => p_user_id,
                                x_bank_acct_id     => l_bank_acct_id,
                                x_return_status    => l_return_status,
                                x_error_message    => l_error_message
                            );

                            if l_return_status <> 'S' then
                                update claim_interface
                                set
                                    interface_status = 'ERROR',
                                    error_message = 'Error in creating bank account ' || l_error_message,
                                    error_code = 'BANK_ACCOUNT_CREATE_ERROR'
                                where
                                        acc_id = x.acc_id
                                    and bank_name = x.bank_name
                                    and routing_number = x.routing_number
                                    and bank_acct_number = x.bank_acct_number
                                    and interface_status = 'NOT_INTERFACED';

                                raise app_exception;
                            end if;

                        end if;

                    end if;

                    l_return_status := 'S';
                    if l_bank_acct_id is not null then
                        l_claim_type := 'SUBSCRIBER_ACH_EDI';
                        l_pay_reason := 19;
                    else
                        l_pay_reason := 12;
                        l_claim_type := 'SUBSCRIBER_EDI';
                    end if;
          --  END IF;
          /*  IF l_bank_acct_id IS NULL AND l_vendor_id IS NOT NULL THEN
               l_claim_type := 'PROVIDER_EDI';
               l_pay_reason := 11;
            END IF;*/

             -- if we didnt find bank account id and vendor id then we will just pay the account holder
             -- by check
                    l_return_status := 'S';
                    pc_log.log_error('IMPORT CLAIMS, claim amount', x.claim_amount);
                    if x.service_plan_type in ( 'HRA', 'HR5', 'HRP', 'HR4' ) then
                        pc_claim.create_hra_disbursement(
                            p_acc_num            => x.acc_num,
                            p_acc_id             => x.acc_id,
                            p_vendor_id          => l_vendor_id,
                            p_vendor_acc_num     => x.provider_acct_number,
                            p_amount             => x.claim_amount,
                            p_patient_name       => null,
                            p_note               => 'Claim from File Upload',
                            p_user_id            => p_user_id,
                            p_service_start_date => x.service_start_dt,
                            p_service_end_date   => x.service_end_dt,
                            p_date_received      => sysdate,
                            p_service_type       => l_service_type,
                            p_claim_source       => 'FILE UPLOAD',
                            p_claim_method       => l_claim_type,
                            p_bank_acct_id       => l_bank_acct_id,
                            p_pay_reason         => l_pay_reason,
                            p_doc_flag           => 'N',
                            p_insurance_category => null,
                            p_claim_category     => null,
                            p_memo               => null,
                            x_claim_id           => l_claim_id,
                            x_return_status      => l_return_status,
                            x_error_message      => l_error_message
                        );

                        update payment_register
                        set
                            batch_number = p_batch_number
                        where
                            claim_id = l_claim_id;

                        pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'claim id from hra disbursement '
                                                                   || l_claim_id
                                                                   || ' return status '
                                                                   || l_return_status
                                                                   || ' error message '
                                                                   || l_error_message);
           --      pc_log.log_error('claim id from FSA disbursement '||l_CLAIM_ID);
           --      pc_log.log_error('claim id from FSA disbursement '||l_CLAIM_ID);
                        if l_return_status <> 'S' then
                            update claim_interface
                            set
                                interface_status = 'ERROR',
                                error_message = 'Error in creating claim ' || l_error_message,
                                error_code = 'CLAIM_CREATION_ERROR'
                            where
                                    acc_id = x.acc_id
                                and provider_name = x.provider_name
                                and interface_status = 'NOT_INTERFACED'
                                and batch_number = p_batch_number;

                            raise app_exception;
                        end if;

                    else
                        l_return_status := 'S';
                        pc_claim.create_fsa_disbursement(
                            p_acc_num            => x.acc_num,
                            p_acc_id             => x.acc_id,
                            p_vendor_id          => l_vendor_id,
                            p_vendor_acc_num     => x.provider_acct_number,
                            p_amount             => x.claim_amount,
                            p_patient_name       => null,
                            p_note               => 'Claim from File Upload',
                            p_user_id            => p_user_id,
                            p_service_start_date => x.service_start_dt,
                            p_service_end_date   => x.service_end_dt,
                            p_date_received      => sysdate,
                            p_service_type       => l_service_type,
                            p_claim_source       => 'FILE UPLOAD',
                            p_claim_method       => l_claim_method,
                            p_bank_acct_id       => l_bank_acct_id,
                            p_pay_reason         => l_pay_reason,
                            p_doc_flag           => 'N',
                            p_insurance_category => null,
                            p_claim_category     => null,
                            p_memo               => null,
                            x_claim_id           => l_claim_id,
                            x_return_status      => l_return_status,
                            x_error_message      => l_error_message
                        );

                        update payment_register
                        set
                            batch_number = p_batch_number
                        where
                            claim_id = l_claim_id;

                        pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'claim id from fsa disbursement '
                                                                   || l_claim_id
                                                                   || ' return status '
                                                                   || l_return_status
                                                                   || ' error message '
                                                                   || l_error_message);

                        if l_return_status <> 'S' then
                            update claim_interface
                            set
                                interface_status = 'ERROR',
                                error_message = 'Error in creating claim ' || l_error_message,
                                error_code = 'CLAIM_CREATION_ERROR'
                            where
                                    acc_id = x.acc_id
                                and provider_name = x.provider_name
                                and interface_status = 'NOT_INTERFACED'
                                and batch_number = p_batch_number;

                            raise app_exception;
                        end if;

                    end if;

                    pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'claim id before inserting to detail ' || l_claim_id);
                    if l_claim_id is not null then
                        for xx in (
                            select distinct
                                *
                            from
                                claim_interface
                            where
                                    acc_id = x.acc_id
                                and provider_name = x.provider_name
                                and interface_status = 'NOT_INTERFACED'
                                and format_to_date(service_start_dt) >= format_to_date(x.service_start_dt)
                                and format_to_date(service_end_dt) <= format_to_date(x.service_end_dt)
                                and batch_number = p_batch_number
                        ) loop
                            pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'provider_name ' || xx.provider_name);
                            pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'service_start_dt ' || xx.service_start_dt);
                            pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'service_end_dt ' || xx.service_end_dt);
                            pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'claim_amount ' || xx.claim_amount);
                            pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'patient_name ' || xx.patient_name);
                            pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'service code ' || xx.claim_number);
                            l_serice_provider(1) := xx.provider_name;
                            l_service_date(1) := to_char(
                                format_to_date(xx.service_start_dt),
                                'MM/DD/YYYY'
                            );
                            l_service_end_date(1) := to_char(
                                format_to_date(xx.service_end_dt),
                                'MM/DD/YYYY'
                            );
                            l_service_name(1) := xx.provider_name;
                            l_service_price(1) := xx.claim_amount;
                            l_patient_dep_name(1) := xx.patient_name;
                            l_note(1) := xx.note;
                            l_provider_tax_id(1) := null;
                            l_eob_detail_id(1) := null;
                            l_eob_linked(1) := null;
                            l_return_status := 'S';
                            pc_claim_detail.insert_claim_detail(
                                p_claim_id         => l_claim_id,
                                p_serice_provider  => l_serice_provider,
                                p_service_date     => l_service_date,
                                p_service_end_date => l_service_end_date,
                                p_service_name     => l_service_name,
                                p_service_price    => l_service_price,
                                p_patient_dep_name => l_patient_dep_name,
                                p_medical_code     => l_tax_code,
                                p_service_code     => xx.claim_number,
                                p_provider_tax_id  => l_provider_tax_id,
                                p_eob_detail_id    => l_eob_detail_id,
                                p_note             => l_note,
                                p_created_by       => p_user_id,
                                p_creation_date    => sysdate,
                                p_last_updated_by  => p_user_id,
                                p_last_update_date => sysdate,
                                p_eob_linked       => l_eob_linked, --Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag
                                x_return_status    => l_return_status,
                                x_error_message    => l_error_message
                            );

                            if l_return_status <> 'S' then
                                update claim_interface
                                set
                                    interface_status = 'ERROR',
                                    error_message = 'Error in creating claim detail ' || l_error_message,
                                    error_code = 'CLAIM_CREATION_ERROR'
                                where
                                        batch_number = p_batch_number
                                    and acc_id = x.acc_id
                                    and provider_name = x.provider_name
                                    and interface_status = 'NOT_INTERFACED';

                                raise app_exception;
                            else
                                update claim_interface
                                set
                                    interface_status = 'INTERFACED',
                                    claim_id = l_claim_id
                                where
                                        batch_number = p_batch_number
                                    and acc_id = x.acc_id
                                    and provider_name = x.provider_name
                                    and interface_status = 'NOT_INTERFACED'
                                    and format_to_date(service_start_dt) >= format_to_date(x.service_start_dt)
                                    and format_to_date(service_end_dt) <= format_to_date(x.service_end_dt);

                            end if;

                        end loop;

                        update claimn
                        set
                            prov_name = x.provider_name,
                            claim_amount = x.claim_amount
                        where
                            claim_id = l_claim_id;

                    end if;--l_CLAIM_ID
                end if;

            exception
                when app_exception then
                    pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'Error Message ' || l_error_message);
                    null;
                when others then
                    l_error_message := sqlerrm;
                    update claim_interface
                    set
                        interface_status = 'ERROR',
                        error_message = 'Error in creating claim ' || l_error_message,
                        error_code = 'CLAIM_CREATION_ERROR'
                    where
                            acc_id = x.acc_id
                        and provider_name = x.provider_name
                        and interface_status = 'NOT_INTERFACED';

            end;
        end loop;
    end import_uploaded_claims;

    procedure process_uploaded_claims (
        p_batch_number in varchar2,
        p_user_id      in number
    ) is
        l_plan_count    number;
        l_return_status varchar2(3200);
        l_error_message varchar2(3200);
    begin
        l_return_status := 'S';
        for x in (
            select
                b.service_type,
                a.acc_id,
                a.claim_id,
                b.claim_amount,
                a.other_insurance,
                b.plan_start_date,
                b.plan_end_date,
                b.service_start_date
            from
                claim_interface a,
                claimn          b
            where
                    batch_number = p_batch_number
                and a.claim_id = b.claim_id
                and interface_status = 'INTERFACED'
                and b.claim_status = 'PENDING_REVIEW'
            group by
                b.service_type,
                a.acc_id,
                a.claim_id,
                b.claim_amount,
                a.other_insurance,
                b.plan_start_date,
                b.plan_end_date,
                b.service_start_date
        ) loop
            select
                count(*)
            into l_plan_count
            from
                ben_plan_enrollment_setup
            where
                    plan_type <> x.service_type
                and acc_id = x.acc_id
                and status in ( 'A', 'I' )
                and trunc(plan_end_date) >= trunc(sysdate);

            if x.other_insurance = 'Y' then
                update claimn
                set
                    claim_status = 'PENDING_OTHER_INSURANCE'
                where
                    claim_id = x.claim_id;

            elsif ( l_plan_count > 0
            or x.claim_amount < 0 ) then
                update claimn
                set
                    claim_status = 'AWAITING_APPROVAL'
                where
                    claim_id = x.claim_id;

            elsif ( x.service_type is null
                    or x.plan_start_date is null
            or x.plan_end_date is null ) then
                update claimn
                set
                    claim_status = 'PENDING_REVIEW',
                    note = note || ' Unable to determine service type or plan year '
                where
                    claim_id = x.claim_id;

            elsif x.service_start_date > sysdate then
                update claimn
                set
                    claim_status = 'APPROVED_FUTURE_SRV_DATE'
                where
                    claim_id = x.claim_id;

                pc_notifications.hrafsa_future_claim_notify(x.claim_id);
            else
                update claimn
                set
                    claim_status = 'APPROVED_FOR_CHEQUE',
                    released_by = 0,
                    reviewed_by = 0,
                    approved_amount = x.claim_amount,
                    approved_date = sysdate,
                    reviewed_date = sysdate,
                    released_date = sysdate
                where
                    claim_id = x.claim_id;

        /*  pc_claim.process_finance_claim
          (
             P_CLAIM_ID        => x.claim_id
            ,P_CLAIM_STATUS    => 'READY_TO_PAY'
            ,P_USER_ID         => p_user_id
            ,X_RETURN_STATUS   => l_return_status
            ,X_ERROR_MESSAGE   => l_error_message
          );*/
                update claim_interface
                set
                    interface_status = 'PROCESSED'
                where
                        claim_id = x.claim_id
                    and interface_status = 'INTERFACED';

            end if;

        end loop;

        process_non_dc_hra_fsa_claims;
        process_mdup_dc_hra_fsa_claims;
    end process_uploaded_claims;

    procedure reprocess_approved_claims (
        p_user_id number
    ) is

        l_transaction_id number;
        x_return_status  varchar2(1);
        x_error_message  varchar2(150);
        l_pay_out_amt    number := 0;
        l_check_number   number;
        l_claim_pending  number := 0;
        l_claim_paid     number := 0;
        l_claim_amount   number := 0;
        l_acc_id         number;
        l_acc_balance    number := 0;
    begin
        update_claim_status(null);
        for x in (
            select
                a.claim_id,
                a.service_start_date,
                a.claim_status,
                a.claim_amount
            from
                claimn                    a,
                account                   d,
                payment_register          b,
                ben_plan_enrollment_setup c
            where
                    c.plan_end_date + nvl(c.runout_period_days, 0) + nvl(grace_period, 0) > sysdate
                and a.claim_status = 'APPROVED_FUTURE_SRV_DATE'
                and a.pers_id = d.pers_id
                and c.status in ( 'A', 'I' )
                and a.claim_id = b.claim_id
                and c.acc_id = b.acc_id
                and a.service_type = c.plan_type
                and trunc(a.service_start_date) = trunc(sysdate)
                and trunc(c.plan_start_date) <= trunc(a.plan_start_date)
                and trunc(c.plan_end_date) >= trunc(a.plan_end_date)
            order by
                claim_id asc
        ) loop
            update claimn
            set
                claim_status = 'APPROVED_FOR_CHEQUE',
                note = substr(note || ' Released from pending future service date to finance queue', 1, 4000)
           -- ,  APPROVED_AMOUNT = X.CLAIM_AMOUNT   -- Commented by swamy Ticket#7633
                ,
                reviewed_date = sysdate,
                approved_date = sysdate,
                deductible_amount = 0,
                claim_pending = 0,
                reviewed_by = 0
            where
                claim_id = x.claim_id;

        end loop;

        for x in (
            select
                pc_account.acc_balance(b.acc_id, c.plan_start_date, c.plan_end_date, d.account_type, c.plan_type) acc_balance,
                b.acc_num,
                b.acc_id,
                a.claim_id,
                c.annual_election,
                a.service_type,
                b.pay_reason,
                b.bank_acct_id,
                a.approved_amount,
                d.account_type,
                a.denied_reason,
                a.claim_pending,
                a.claim_status,
                a.claim_paid,
                a.claim_amount,
                pc_entrp.get_payroll_integration(a.entrp_id)                                                      payroll_flag
            from
                claimn                    a,
                account                   d,
                payment_register          b,
                ben_plan_enrollment_setup c
            where
                a.claim_status in ( 'PARTIALLY_PAID', 'APPROVED_NO_FUNDS' )
                and c.plan_start_date <= a.plan_start_date
                and c.plan_end_date >= a.plan_end_date
                and c.status in ( 'A', 'I' )
                and c.acc_id = b.acc_id
                and a.service_type = c.plan_type
                and a.pers_id = d.pers_id
                and a.claim_id = b.claim_id
                and a.claim_date_start < c.plan_end_date + nvl(c.runout_period_days, 0) + nvl(grace_period, 0) + 180
                and c.plan_end_date + nvl(c.runout_period_days, 0) + nvl(grace_period, 0) + 180 > sysdate
                and not exists (
                    select
                        *
                    from
                        ach_transfer
                    where
                            acc_id = d.acc_id
                        and claim_id = a.claim_id
                        and status in ( 1, 2 )
                )
                and pc_account.new_acc_balance(b.acc_id, c.plan_start_date, c.plan_end_date, d.account_type, c.plan_type) > 0
            order by
                claim_id asc,
                acc_num
        ) loop
            pc_log.log_error('REPROCESS_APPROVED_CLAIMS,CLAIM_ID ', x.claim_id);
      /** Oldest claims are ordered first to make sure we pay the oldest claims first
       here is sample case
       balance     400
       claim #1    200
       claim #2 50
         claim #3 100
         claim #4 100

       For claim#1
         Total claim amount    200
         pay out amount    200
         balance    200
       Claim #2
         Total claim amount    250
         pay out amount    50
         balance    150
       Claim #3
         Total claim amount    350
         payout    100
         balance    50
       Claim #4
        Total claim amount    450
        payout    amount 50
        balance -50

  */
            if ( l_acc_id is null
                 or l_acc_id <> x.acc_id ) then
                l_claim_amount := 0;
                l_acc_balance := x.acc_balance;
            end if;

            l_claim_amount := l_claim_amount + x.claim_pending;
            if l_acc_balance > 0 then
                l_pay_out_amt := least(l_acc_balance, x.claim_pending);
            else
                l_pay_out_amt := 0;
            end if;

            l_acc_balance := x.acc_balance - l_claim_amount;
            l_acc_id := x.acc_id;

/*   if x.claim_pending <= x.acc_balance then
        l_pay_out_amt   :=   x.claim_pending;
        l_claim_pending :=   0;
        l_claim_paid    :=   x.claim_amount;
    elsif x.acc_balance > 0  and  x.acc_balance <  x.claim_pending then
        l_pay_out_amt   :=   x.acc_balance ;
        l_claim_paid    :=   x.claim_paid    + l_pay_out_amt;
        l_claim_pending :=   x.claim_amount  - l_claim_paid;
    else
        l_pay_out_amt   := 0;  --used to check if pay out needed
    end if;
  */
    /*
     l_pay_out_amt  := case   when x.claim_status = 'PARTIALLY_PAID' then x.claim_pending
                                when x.claim_status  = 'APPROVED_NO_FUNDS' then x.approved_amount
                                end;
    */
            if l_pay_out_amt > 0 then
                if nvl(x.payroll_flag, 'N') = 'N' then
                    x_return_status := 'S';
                    update claimn
                    set
                        claim_status = 'APPROVED_FOR_CHEQUE',
                        funds_availability_date = sysdate
                    where
                        claim_id = x.claim_id;

                elsif nvl(x.payroll_flag, 'N') = 'Y' then
                    x_return_status := 'S';
                    update claimn
                    set
                        claim_status = 'APPROVED',
                        funds_availability_date = sysdate
                    where
                        claim_id = x.claim_id;

                end if;
            end if; --l_pay_out_amt > 0

        end loop;
  --commit;
        for x in (
            select
                b.deductible_amount,
                a.claim_id,
                b.pers_id,
                b.claim_status,
                a.acc_id,
                b.pers_patient,
                nvl(b.payment_release_date,
                    (
                    select
                        max(pay_date)
                    from
                        payment
                    where
                        claimn_id = b.claim_id
                )) paid_date
            from
                deductible_balance a,
                claimn             b
            where
                    a.claim_id = b.claim_id
                and a.status <> b.claim_status
                and service_type in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
                and nvl(b.deductible_amount, 0) > 0
        ) loop
            pc_claim.ins_deductible_balance(
                p_acc_id            => x.acc_id,
                p_pers_id           => x.pers_id,
                p_pers_patient      => x.pers_patient,
                p_claim_id          => x.claim_id,
                p_deductible_amount => x.deductible_amount,
                p_pay_date          => x.paid_date,
                p_status            => x.claim_status,
                p_note              => 'Updated with paid date and status '
                          || to_char(x.paid_date, 'MM/DD/YYYY'),
                p_user_id           => 0
            );
        end loop;

    end reprocess_approved_claims;

    procedure update_claim_totals (
        p_claim_id in number
    ) is
        l_claim_paid number;
    begin
        l_claim_paid := pc_claim.f_claim_paid(p_claim_id);
        update claimn
        set
            claim_status = decode(claim_status, 'PARTIALLY_PAID', 'PARTIALLY_PAID', 'READY_TO_PAY'),
            claim_paid = nvl(l_claim_paid, 0),
            claim_pending = nvl(approved_amount, claim_amount) - ( nvl(l_claim_paid, 0) )
        where
            claim_id = p_claim_id;

    end update_claim_totals;

    procedure process_claim_status (
        p_claim_id in number
    ) is
        l_claim_paid number;
        l_balance    number := 0;
    begin
        l_claim_paid := pc_claim.f_claim_paid(p_claim_id);
        l_balance := 0;
        for x in (
            select
                a.claim_amount,
                a.claim_pending,
                b.pers_id,
                b.acc_id,
                a.plan_start_date,
                a.plan_end_date,
                b.account_type,
                a.service_type,
                b.acc_num
            from
                claimn  a,
                account b
            where
                a.claim_status in ( 'APPROVED', 'APPROVED_FOR_CHEQUE' )
                and a.pers_id = b.pers_id
                and b.account_type in ( 'HRA', 'FSA' )
                and a.claim_amount > 0
                and a.claim_id = p_claim_id
                and a.plan_start_date is not null
                and a.plan_end_date is not null
        ) loop
            l_balance := nvl(
                pc_account.acc_balance(x.acc_id, x.plan_start_date, x.plan_end_date, x.account_type, x.service_type),
                0
            );

            if l_balance <= 0 then
                update claimn
                set
                    claim_status = 'APPROVED_NO_FUNDS'
                where
                        pers_id = x.pers_id
                    and claim_status in ( 'APPROVED', 'APPROVED_FOR_CHEQUE' );

            elsif l_balance < x.claim_pending then
                update claimn
                set
                    claim_status = 'APPROVED_NO_FUNDS'
                where
                        claim_id = p_claim_id
                    and claim_status in ( 'APPROVED', 'APPROVED_FOR_CHEQUE' );

            elsif
                l_balance > 0
                and l_balance > x.claim_pending
            then
                for xx in (
                    select
                        running_total,
                        service_type,
                        claim_id
                    from
                        (
                            select
                                sum(claim_pending)
                                over(partition by a.service_type, a.pers_id
                                     order by
                                         a.claim_id
                                    range between unbounded preceding and current row
                                ) as running_total,
                                a.service_type,
                                a.claim_id
                            from
                                claimn  a,
                                account b
                            where
                                a.claim_status in ( 'APPROVED', 'APPROVED_FOR_CHEQUE' )
                                and a.pers_id = b.pers_id
                                and b.account_type in ( 'HRA', 'FSA' )
                                and a.claim_amount > 0
                                and a.service_type = x.service_type
                                and a.pers_id = x.pers_id
                                and a.plan_start_date is not null
                                and a.plan_end_date is not null
                        )
                    where
                        running_total >= l_balance
                ) loop
                    update claimn
                    set
                        claim_status = 'APPROVED_NO_FUNDS'
                    where
                            claim_id = xx.claim_id
                        and claim_status in ( 'APPROVED', 'APPROVED_FOR_CHEQUE' );

                end loop;
            end if;

        end loop;

        update claimn
        set
            claim_paid = l_claim_paid,
            claim_pending = nvl(approved_amount, claim_amount) - ( nvl(l_claim_paid, 0) )
        where
                claim_id = p_claim_id
            and claim_status in ( 'READY_TO_PAY', 'PARTIALLY_PAID', 'APPROVED_NO_FUNDS', 'APPROVED_FOR_CHEQUE' )
            and exists (
                select
                    *
                from
                    account
                where
                        account.pers_id = claimn.pers_id
                    and account_type in ( 'HRA', 'FSA' )
            );

        update claimn
        set
            claim_pending = nvl(approved_amount, claim_amount) - ( nvl(claim_paid, 0) )
        where
                claim_id = p_claim_id
            and claim_status in ( 'READY_TO_PAY', 'PARTIALLY_PAID', 'APPROVED_NO_FUNDS', 'APPROVED_FOR_CHEQUE' )
            and exists (
                select
                    *
                from
                    account
                where
                        account.pers_id = claimn.pers_id
                    and account_type in ( 'HRA', 'FSA' )
            );

        l_claim_paid := 0;
       -- Update PAID status for ACH claims
        update claimn
        set
            claim_status = 'PAID'
        where
                claim_paid = approved_amount
            and service_type is not null
            and claim_status <> 'PAID'
            and claim_id = p_claim_id
            and exists (
                select
                    *
                from
                    payment
                where
                        payment.claimn_id = claimn.claim_id
                    and reason_code = 19
            )
            and exists (
                select
                    *
                from
                    account
                where
                        pers_id = claimn.pers_id
                    and account_type in ( 'HRA', 'FSA' )
            );

        update claimn
        set
            claim_status = 'PARTIALLY_PAID'
        where
                claim_paid < approved_amount
            and service_type is not null
            and claim_paid > 0
            and claim_id = p_claim_id
            and claim_status not in ( 'PARTIALLY_PAID', 'APPROVED_FOR_CHEQUE' )
            and exists (
                select
                    *
                from
                    payment
                where
                        payment.claimn_id = claimn.claim_id
                    and reason_code = 19
            )
            and exists (
                select
                    *
                from
                    account
                where
                        pers_id = claimn.pers_id
                    and account_type in ( 'HRA', 'FSA' )
            );

    end process_claim_status;

    procedure update_claim_status (
        p_claim_id in number
    ) is
        l_claim_paid number;
    begin
        if p_claim_id is not null then
            process_claim_status(p_claim_id);
        else
            for x in (
                select
                    claim_id
                from
                    claimn  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and b.account_type in ( 'HRA', 'FSA' )
                    and claim_status in ( 'APPROVED', 'READY_TO_PAY', 'PARTIALLY_PAID', 'APPROVED_NO_FUNDS', 'APPROVED_FOR_CHEQUE' )
                    and plan_end_date >= add_months(plan_end_date, -24)
            ) loop
                process_claim_status(x.claim_id);
            end loop;

            for x in (
                select
                    claim_id
                from
                    claimn  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and b.account_type = 'HSA'
                    and claim_status in ( 'APPROVED', 'READY_TO_PAY', 'PARTIALLY_PAID', 'APPROVED_NO_FUNDS', 'APPROVED_FOR_CHEQUE' )
            ) loop
                process_claim_status(x.claim_id);
            end loop;

        end if;

        for x in (
            select
                b.claim_id,
                a.eob_status_code,
                b.claim_status
            from
                eob_header a,
                claimn     b
            where
                    a.claim_id = b.claim_id
                and a.eob_status_code <> b.claim_status
                and b.claim_id = nvl(p_claim_id, b.claim_id)
        ) loop
            pc_eob.update_claim_with_eob(null, x.claim_id, 0);
        end loop;

    end update_claim_status;

/** Processing cheyenne claims for participants that have both
HRA/FSA claims but never used their debit card **/
    procedure process_non_dc_hra_fsa_claims as
    begin
        for x in (
            select distinct
                d.claim_amount,
                a.acc_num,
                d.service_start_date,
                a.claim_id
            from
                claim_interface a,
                claimn          d
            where
                    a.pers_id = d.pers_id
                and a.claim_id = d.claim_id
                and d.claim_status = 'AWAITING_APPROVAL'
                and a.interface_status = 'INTERFACED'
                and d.claim_amount > 0
                and not exists (
                    select
                        *
                    from
                        payment
                    where
                            payment.acc_id = a.acc_id
                        and payment.pay_date >= d.service_start_date
                        and payment.reason_code = 13
                )
            order by
                a.acc_num
        ) loop
            update claimn
            set
                claim_status = 'APPROVED_FOR_CHEQUE',
                approved_amount = x.claim_amount,
                reviewed_date = sysdate,
                approved_date = sysdate,
                reviewed_by = 0,
                released_date = sysdate,
                released_by = 0,
                note = note
                       || ' Auto released on '
                       || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
            where
                claim_id = x.claim_id;

        end loop;
    end process_non_dc_hra_fsa_claims;
/** Processing cheyenne claims for participants that have both
HRA/FSA claims but  used their debit card and found duplicates
across multiple debit card transactions so marking them as pending forever**/
    procedure process_mdup_dc_hra_fsa_claims as
    begin
        for x in (
            select distinct
                d.claim_amount,
                a.acc_num,
                d.service_start_date,
                a.claim_id
            from
                claim_interface a,
                claimn          d
            where
                    a.pers_id = d.pers_id
                and a.claim_id = d.claim_id
                and d.claim_status = 'AWAITING_APPROVAL'
                and a.interface_status = 'INTERFACED'
                and exists (
                    select
                        acc_id
                    from
                        payment
                    where
                            payment.acc_id = a.acc_id
                        and payment.pay_date >= d.service_start_date
                        and payment.reason_code = 13
                    group by
                        acc_id
                    having
                        sum(amount) = d.claim_amount
                )
            order by
                a.acc_num
        ) loop
            update claimn
            set
                claim_status = 'PENDING_REVIEW',
                note = note || 'Found Duplicate debit card swipe under HRA/FSA plan '
            where
                claim_id = x.claim_id;

        end loop;
    end process_mdup_dc_hra_fsa_claims;

    function get_claim_paid_ytd (
        p_acc_id number
    ) return number is
        l_claim_paid number;
    begin
        select
            nvl(
                sum(p.amount),
                0
            )
        into l_claim_paid
        from
            payment p
        where
            claimn_id in (
                select
                    claim_id
                from
                    (
                        select
                            claim_id
                        from
                            claimn c
                        where
                            pers_id in (
                                select
                                    p.pers_id
                                from
                                    person  p, account a
                                where
                                        p.pers_id = a.pers_id
                                    and a.acc_id = p_acc_id
                            )
                        union all
                        select
                            claim_id
                        from
                            claimn c
                        where
                            pers_patient in (
                                select
                                    p.pers_id
                                from
                                    person  p, account a
                                where
                                        p.pers_main = a.pers_id
                                    and a.acc_id = p_acc_id
                            )
                    )
            );

        return l_claim_paid;
    end get_claim_paid_ytd;

    procedure ins_deductible_balance (
        p_acc_id            in number,
        p_pers_id           in number,
        p_pers_patient      in number,
        p_claim_id          in number,
        p_deductible_amount in number,
        p_pay_date          in date,
        p_status            in varchar2,
        p_note              in varchar2,
        p_user_id           in number
    ) is
    begin
        update deductible_balance
        set
            deductible_amount = p_deductible_amount,
            pay_date = sysdate,
            last_updated_by = p_user_id,
            last_updated_date = sysdate,
            status = p_status,
            pers_patient = p_pers_patient
        where
                acc_id = p_acc_id
            and pers_id = p_pers_id
            and claim_id = p_claim_id;
           -- this is needed as deductible is calculated from review screen and there's a possibility of
           -- saving the screen more than once and inserting duplicate rows here.
        if sql%rowcount = 0 then
            if p_deductible_amount > 0 then
                insert into deductible_balance (
                    balance_id,
                    acc_id,
                    pers_id,
                    pers_patient,
                    claim_id,
                    deductible_amount,
                    pay_date,
                    status,
                    note,
                    last_updated_by,
                    last_updated_date,
                    created_by,
                    creation_date
                ) values ( ded_balance_seq.nextval,
                           p_acc_id,
                           p_pers_id,
                           p_pers_patient,
                           p_claim_id,
                           p_deductible_amount,
                           p_pay_date,
                           p_status,
                           p_note,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           sysdate );

            end if;

        end if;

    end ins_deductible_balance;

/** Process NSF disbursement for HSA ***/
    procedure process_nsf_hsa_claim (
        p_claim_id in number,
        p_user_id  in number
    ) is
        l_check_number number;
        l_amount       number; -- Added variable for calculations
    begin
        for x in (
            select
                a.claim_id,
                b.claim_amount - nvl(
                    pc_claim.f_claim_paid(a.claim_id),
                    0
                )                               claim_pending,
                a.acc_id,
                nvl(a.pay_reason, b.pay_reason) reason_code,
                a.trans_date
          --      ,A.CLAIM_AMOUNT
         -- Added for Subscriber Insufficient Partial Payment
                ,
                a.claim_type,
                decode(a.claim_type,
                       'SUBSCRIBER',
                       least((b.claim_amount - nvl(
                    pc_claim.f_claim_paid(a.claim_id),
                    0
                )),
                             (pc_account.acc_balance(acc_id) - nvl(
                    pc_fin.get_bill_pay_fee(acc_id),
                    0
                ))),
                       b.claim_amount)          claim_amount
            from
                payment_register a,
                claimn           b
            where
                    a.claim_id = p_claim_id
                and a.claim_id = b.claim_id
                and b.claim_status not in ( 'CANCELLED', 'ERROR', 'DENIED' )
                and ( ( pc_account.acc_balance(acc_id) - nvl(
                        pc_fin.get_bill_pay_fee(acc_id),
                        0
                    ) >= b.claim_pending
                 --Below Condition Added for the HSA Subscriber Insufficient Fund Screen, To allow for subscriber alone the
                              --claimed amount, even it is lesser than the Pending amount
                        and a.claim_type <> 'SUBSCRIBER' )
                      or ( pc_account.acc_balance(acc_id) - nvl(
                        pc_fin.get_bill_pay_fee(acc_id),
                        0
                    ) > 0
                           and a.claim_type = 'SUBSCRIBER' ) )
                and nvl(a.insufficient_fund_flag, 'N') = 'Y'
        ) loop
            --Added for the Subscriber Insufficient page
            l_amount := 0;
            if ( x.claim_pending > 0
            or x.claim_amount > 0 ) then
                if x.claim_type = 'SUBSCRIBER' then
                    l_amount := x.claim_amount;
                else
                    l_amount := x.claim_pending;
                end if;
            --End

                insert into payment (
                    change_num,
                    claimn_id,
                    pay_date,
                    amount,
                    reason_code,
                    pay_num,
                    note,
                    reason_mode,
                    acc_id,
                    last_updated_by,
                    created_by
                ) values ( change_seq.nextval,
                           x.claim_id,
                           sysdate
                    --,X.CLAIM_PENDING  -- Commented Old Value
                           ,
                           l_amount --Added the new value
                           ,
                           x.reason_code,
                           null,
                           'Generate Disbursement '
                           || to_char(x.trans_date, 'RRRRMMDD'),
                           'P',
                           x.acc_id,
                           p_user_id,
                           p_user_id );

                if l_amount > 0 then
                    pc_check_process.insert_check(
                        p_claim_id     => x.claim_id,
                --P_CHECK_AMOUNT => x.CLAIM_PENDING , -- Commented old value
                        p_check_amount => l_amount, --Added the new variable
                        p_acc_id       => x.acc_id,
                        p_user_id      => p_user_id,
                        p_status       => 'OPEN',
                        p_source       => 'HSA_CLAIM',
                        x_check_number => l_check_number
                    );
                end if;

                if x.claim_type = 'SUBSCRIBER' then --Added for the Subscriber insufficient funds
             --Added the update statement to the claim and Payment Register table based
                      --on the current partial amount dispense.
                    update claimn
                    set
                        claim_pending = x.claim_pending - x.claim_amount,
                        claim_paid = claim_paid + x.claim_amount,
                        claim_status =
                            case
                                when x.claim_amount - x.claim_pending = 0 then
                                    'PAID'
                                when nvl(
                                    pc_claim.f_claim_paid(x.claim_id),
                                    0
                                ) = 0                                then
                                    'APPROVED_NO_FUNDS'
                                else
                                    'PARTIALLY_PAID'
                            end
                    where
                        claim_id = x.claim_id;

                    update payment_register
                    set
                        insufficient_fund_flag = decode(x.claim_amount - x.claim_pending, 0, 'N', 'Y'),
                        peachtree_interfaced = 'N',
                        check_number = l_check_number
                    where
                        claim_id = x.claim_id;

                else --Added for the If condition

                    update claimn
                    set
                        claim_pending = x.claim_amount - nvl(
                            pc_claim.f_claim_paid(x.claim_id),
                            0
                        ),
                        claim_paid = nvl(
                            pc_claim.f_claim_paid(x.claim_id),
                            0
                        ),
                        claim_status =
                            case
                                when x.claim_amount - nvl(
                                    pc_claim.f_claim_paid(x.claim_id),
                                    0
                                ) = 0 then
                                    'PAID'
                                when nvl(
                                    pc_claim.f_claim_paid(x.claim_id),
                                    0
                                ) = 0 then
                                    'APPROVED_NO_FUNDS'
                                else
                                    'PARTIALLY_PAID'
                            end
                    where
                        claim_id = x.claim_id;

                    update payment_register
                    set
                        insufficient_fund_flag = decode(x.claim_amount - nvl(
                            pc_claim.f_claim_paid(x.claim_id),
                            0
                        ),
                                                        0,
                                                        'N',
                                                        'Y'),
                        peachtree_interfaced = 'N',
                        check_number = l_check_number
                    where
                        claim_id = x.claim_id;

                end if; --Added for the If condition
            end if;

        end loop;
    end process_nsf_hsa_claim;

    procedure process_broker_claim (
        p_broker_id         in number,
        p_broker_lic        in varchar2,
        p_vendor_id         in number,
        p_bank_acct_id      in number,
        p_commission        in number,
        p_reimburse_method  in varchar2,
        p_period_start_date in date,
        p_period_end_date   in date,
        p_note              in varchar2,
        p_account_type      in varchar2,
        x_transaction_id    out number,
        x_error_message     out varchar2
    ) is

        l_batch_number   varchar2(30);
        l_error_message  varchar2(32000);
        l_vendor_id      number;
        l_broker_pay_id  number;
        l_name           varchar2(32000);
        l_address        varchar2(32000);
        l_city           varchar2(32000);
        l_state          varchar2(32000);
        l_zip            varchar2(32000);
        l_acc_num        varchar2(30);
        l_payment_reg_id number;
        l_check_number   number;
        l_return_status  varchar2(30);
    begin
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
        l_return_status := 'S';
        for x in (
            select
                b.check_number
            from
                broker_payments a,
                checks          b
            where
                    transaction_amount = p_commission
                and a.transaction_number = b.check_number
                and b.status <> 'PURGED'
                and a.account_type = p_account_type
                and a.broker_id = p_broker_id
                and a.period_start_date >= p_period_start_date
                and a.period_end_date <= p_period_end_date
        ) loop
            l_return_status := 'E';
            x_error_message := 'Commission has been already created for '
                               || p_broker_lic
                               || ' for this period '
                               || ' with check number '
                               || x.check_number
                               || ' for the period '
                               || to_char(p_period_start_date, 'MM/DD/YYYY')
                               || '-'
                               || to_char(p_period_end_date, 'MM/DD/YYYY');

        end loop;

        if l_return_status = 'S' then
            select
                broker_payments_seq.nextval
            into l_broker_pay_id
            from
                dual;

            insert into broker_payments (
                broker_payment_id,
                broker_id,
                transaction_amount,
                transaction_date,
                note,
                period_start_date,
                period_end_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                account_type,
                reason_code       -- Added by swamy 10/07/2018 for Ticket#6072(Broker Payments)
                ,
                pay_code
            )         -- Added by swamy 10/07/2018 for Ticket#6072(Broker Payments)
             values ( l_broker_pay_id,
                       p_broker_id,
                       p_commission,
                       sysdate,
                       p_note,
                       p_period_start_date,
                       p_period_end_date,
                       sysdate,
                       get_user_id(v('APP_USER')),
                       sysdate,
                       get_user_id(v('APP_USER')),
                       p_account_type,
                       6               -- (6==> Returened Cheque) Added by swamy 10/07/2018 for Ticket#6072(Broker Payments)
                       ,
                       1 );             -- (1==> check) Added by swamy 10/07/2018 for Ticket#6072(Broker Payments)

           /*** Initially we start off with check ***/

            if
                p_reimburse_method = 'CHECK'
                and p_commission > 0
            then
                pc_check_process.insert_check(
                    p_claim_id     => l_broker_pay_id,
                    p_check_amount => p_commission,
                    p_acc_id       => null,
                    p_user_id      => get_user_id(v('APP_USER')),
                    p_status       => 'OPEN',
                    p_source       => 'BROKER_PAYMENTS',
                    x_check_number => x_transaction_id
                );

                update broker_payments
                set
                    transaction_number = x_transaction_id
                where
                    broker_payment_id = l_broker_pay_id;

            end if;

        end if;

    exception
        when others then
            x_error_message := sqlerrm;
    end process_broker_claim;

    function get_monthly_claim_amount (
        p_claim_id         in number,
        p_pers_id          in number,
        p_service_type     in varchar2,
        p_service_date     in date,
        p_service_end_date in date
    ) return number is
        l_claim_amount number;
    begin
        for x in (
            select
                sum(nvl(a.approved_amount,
                        (a.claim_amount -(nvl(a.denied_amount, 0) + nvl(a.deductible_amount, 0))))) approved_amount
            from
                claimn a
            where
                    a.pers_id = p_pers_id
                and a.service_type = p_service_type
                -- AND   c.claim_id = a.claim_id
                and a.claim_status not in ( 'DENIED', 'CANCELED', 'CANCELLED' )
                and a.claim_id <> p_claim_id
                and a.claim_id in (
                    select
                        claim_id
                    from
                        claim_detail c
                    where
                            c.claim_id <> p_claim_id
                        and ( trunc(c.service_date, 'MM') = trunc(p_service_date, 'MM')
                              or trunc(c.service_end_date, 'MM') = trunc(p_service_date, 'MM')
                              or trunc(c.service_date, 'MM') = trunc(p_service_end_date, 'MM')
                              or trunc(c.service_end_date, 'MM') = trunc(p_service_end_date, 'MM') )
                )
        ) loop
            l_claim_amount := x.approved_amount;
        end loop;

        return nvl(l_claim_amount, 0);
    end get_monthly_claim_amount;

    function get_monthly_claim_paid (
        p_claim_id         in number,
        p_pers_id          in number,
        p_service_type     in varchar2,
        p_service_date     in date,
        p_service_end_date in date
    ) return number is
        l_claim_amount number;
    begin
        for x in (
            select
                sum(nvl(a.approved_amount,
                        (a.claim_amount -(nvl(a.denied_amount, 0) + nvl(a.deductible_amount, 0))))) approved_amount
            from
                claimn       a,
                claim_detail c
            where
                    a.pers_id = p_pers_id
                and a.service_type = p_service_type
                and c.claim_id = a.claim_id
                and a.claim_status not in ( 'DENIED', 'CANCELED', 'CANCELLED' )
                and a.claim_id <> p_claim_id
                and ( trunc(c.service_date, 'MM') = trunc(p_service_end_date, 'MM')
                      or trunc(c.service_end_date, 'MM') = trunc(p_service_end_date, 'MM')
                      or trunc(c.service_date, 'MM') = trunc(p_service_date, 'MM')
                      or trunc(c.service_end_date, 'MM') = trunc(p_service_date, 'MM') )
        ) loop
            l_claim_amount := x.approved_amount;
        end loop;

        return nvl(l_claim_amount, 0);
    end get_monthly_claim_paid;

    procedure validate_claim_detail (
        p_claim_id      in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_setup_error exception;
        l_claim_status  varchar2(3200);
        l_denied_amount number := 0;
    begin
    /**IRS Guideline:
      Before the start of the Section 132 plan year,
      individual employees elected to set aside a certain amount of pre-tax salary to cover qualified
      costs incurred in commuting to work. The employee will designate an amount (up to $230.00 per month)
      for mass transit expenses and a separate amount (up to $230.00 per month) for parking expenses --
      separate reimbursement accounts are maintained for each category, and funds cannot be commingled
      or transferred between accounts (for example, amounts cannot be transferred from the mass transit to the parking account).
      As the employee incurs Section 132 expenses during the year, a request form may be submitted
      to the employer for reimbursement. If the employee does not use the full amount before the end of the program year,
      the left over amount is carried forward to the next year.Dollar Limitations
      The maximum nontaxable benefit in 2011 is $230 per month. The maximum applies separately to each month.
      PL 111-312; IRC ?132(f); Rev. Proc. 2011-12
    **/
        x_return_status := 'S';
        for x in (
            select
                b.account_status,
                c.plan_start_date,
                c.plan_end_date,
                nvl(c.grace_period, 0)                                                                   grace_period,
                nvl(c.runout_period_days, 0)                                                             runout_period_days,
                c.effective_end_date                                                                     termination_date,
                c.status,
                b.account_type,
                b.pers_id,
                nvl(c.transaction_period,
                    nvl(
                    pc_param.get_fsa_irs_limit('TRANSACTION_FREQ', d.service_type, d.service_end_date),
                    4
                ))                                                                                       transaction_period -- 4 represents Monthly
                ,
                nvl(c.transaction_limit,
                    pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', d.service_type, d.service_end_date)) transaction_amount -- 230 represents monthly txn maximum as per IRS guidelines
                    ,
                c.transaction_limit                                                                      plan_trans_limit,
                d.service_type,
                d.claim_id,
                d.service_start_date,
                d.service_end_date
               -- , pc_claim.get_monthly_claim_paid(d.claim_id, d.pers_id, d.service_type, d.service_start_date
              --     , d.service_end_date) previous_paid
            from
                account                   b,
                ben_plan_enrollment_setup c,
                claimn                    d
            where
                    d.claim_id = p_claim_id
                and b.account_type in ( 'HRA', 'FSA' )
                and c.acc_id = b.acc_id
                and c.status in ( 'A', 'I' )
                and b.pers_id = d.pers_id
                and d.service_type = c.plan_type
                and c.plan_type in ( 'TRN', 'PKG', 'UA1' )
                and ( c.effective_end_date is null
                      or c.effective_end_date > sysdate )
                and trunc(c.plan_start_date) = trunc(d.plan_start_date)
                and trunc(c.plan_end_date) = trunc(d.plan_end_date)
        ) loop
            if to_char(x.service_start_date, 'YYYY') <> to_char(x.service_end_date, 'YYYY') then
                null;
            elsif x.transaction_period = 4 then
                for xx in (
                    select
                        claim_id,
                        sum(no_of_lines)                         no_of_lines,
                        sum(service_price)                       service_price,
                        sum(months_exceeded)                     months_exceeded,
                        sum(no_of_months) * x.transaction_amount transaction_limit,
                        sum(rejected_amount)                     rejected_amount
                    from
                        (
                            select
                                claim_id,
                                count(*)                    no_of_lines,
                                sum(service_price)          service_price,
                                sum(
                                    case
                                        when to_char(service_date, 'MM') <> to_char(service_end_date, 'MM') then
                                            1
                                        else
                                            0
                                    end
                                )                           months_exceeded,
                                0                           no_of_months,
                                sum(service_price)          rejected_amount,
                                to_char(service_date, 'MM') service_month
                            from
                                claim_detail
                            where
                                    claim_id = x.claim_id
                                and to_char(service_date, 'MM') <> to_char(service_end_date, 'MM')
                            group by
                                claim_id,
                                to_char(service_date, 'MM')
                            union
                            select
                                a.claim_id,
                                count(*)                                      no_of_lines,
                                sum(a.service_price),
                                0,
                                count(distinct to_char(a.service_date, 'MM')) no_of_months,
                                case
                                    when sum(pc_claim.get_monthly_claim_amount(a.claim_id, b.pers_id, b.service_type, a.service_date,
                                    a.service_end_date)) > count(distinct to_char(a.service_date, 'MM')) * nvl(x.plan_trans_limit,
                                                                                                                                    pc_param.get_fsa_irs_limit
                                                                                                                                    (
                                                                                                                                    'TRANSACTION_LIMIT'
                                                                                                                                    ,
                                                                                                                                    b.service_type
                                                                                                                                    ,
                                                                                                                                    b.service_end_date
                                                                                                                                    )
                                                                                                                                    )
                                                                                                                                    then
                                        sum(a.service_price)
                                    else
                                        case
                                            when sum(pc_claim.get_monthly_claim_amount(a.claim_id, b.pers_id, b.service_type, a.service_date
                                            , a.service_end_date)) + sum(a.service_price) > count(distinct to_char(a.service_date, 'MM'
                                            )) * nvl(x.plan_trans_limit,
            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', b.service_type, b.service_end_date)) then
                                                    ( sum(pc_claim.get_monthly_claim_amount(a.claim_id, b.pers_id, b.service_type, a.service_date
                                                    , a.service_end_date)) + sum(a.service_price) ) - count(distinct to_char(a.service_date
                                                    , 'MM')) * nvl(x.plan_trans_limit,
                pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', b.service_type, b.service_end_date))
                                            else
                                                0
                                        end
                                end,
                                to_char(a.service_date, 'MM')                 service_month
                            from
                                claim_detail a,
                                claimn       b
                            where
                                    a.claim_id = x.claim_id
                                and a.claim_id = b.claim_id
                                and to_char(a.service_date, 'MM') = to_char(a.service_end_date, 'MM')
                            group by
                                a.claim_id,
                                to_char(a.service_date, 'MM'),
                                b.service_end_date,
                                b.service_type,
                                b.pers_id
                        )
                    group by
                        claim_id
                ) loop
                    if ( xx.rejected_amount >= 0
                    or xx.months_exceeded >= 0 ) then
                        update claimn
                        set
                            note = note
                                   || ' ** transaction_limit '
                                   || xx.transaction_limit
                                   || ' ** System calculated rejected amount '
                                   || xx.rejected_amount
                        where
                            claim_id = p_claim_id;
                 /*CLAIM_STATUS    = CASE WHEN xx.rejected_amount >= 0 THEN
                                            DECODE(claim_amount,xx.rejected_amount ,'DENIED','APPROVED')
                                         ELSE 'APPROVED' END
                     ,  CLAIM_PENDING   = CLAIM_AMOUNT -(NVL(APPROVED_AMOUNT,0)+NVL(DEDUCTIBLE_AMOUNT,0)
                                                       +NVL(xx.rejected_amount,0) )
                    ,  APPROVED_AMOUNT = CLAIM_AMOUNT -(NVL(APPROVED_AMOUNT,0)+NVL(DEDUCTIBLE_AMOUNT,0)
                                                       +NVL(xx.rejected_amount,0) )
                    ,  APPROVED_DATE   = SYSDATE
                    ,  DENIED_AMOUNT   = xx.rejected_amount
                    ,  DENIED_REASON   = CASE WHEN xx.months_exceeded > 0 THEN 'DATE_NOT_IN_RANGE'
                                              WHEN xx.rejected_amount > 0 THEN 'ABOVE_MONTHLY_MAX' END
                    ,  REVIEWED_DATE   = SYSDATE
                    ,  REVIEWED_BY = 0*/
                   /*
                  RETURNING DENIED_AMOUNT INTO l_denied_amount;
                  IF l_denied_amount > 0 THEN
                     PC_NOTIFICATIONS.insert_deny_claim_events(P_CLAIM_ID,0);
                  END IF;*/
                    end if;

                    if (
                        xx.rejected_amount = 0
                        and xx.months_exceeded = 0
                    ) then
                        update claimn
                        set
                            claim_status = 'APPROVED',
                            claim_pending = claim_amount - ( nvl(approved_amount, 0) + nvl(deductible_amount, 0) + nvl(xx.rejected_amount
                            , 0) ),
                            approved_amount =
                                case
                                    when nvl(approved_amount, 0) = 0 then
                                        claim_amount - ( nvl(approved_amount, 0) + nvl(deductible_amount, 0) + xx.rejected_amount )
                                    else
                                        approved_amount
                                end,
                            approved_date = sysdate,
                            reviewed_date = sysdate,
                            reviewed_by = 0
                        where
                            claim_id = p_claim_id;

                    end if;

                end loop;
            end if;
        end loop;

    exception
        when l_setup_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end validate_claim_detail;

    procedure validate_transaction_limits (
        p_claim_id in number
    ) is
        x_return_status varchar2(1) := 'S';
        x_error_message varchar2(3200);
        l_setup_error exception;
    begin
        pc_claim.validate_claim_detail(
            p_claim_id      => p_claim_id,
            x_return_status => x_return_status,
            x_error_message => x_error_message
        );
    end validate_transaction_limits;

    procedure process_emp_refund (
        p_entrp_id            in number,
        p_pay_code            in number,
        p_refund_amount       in number,
        p_emp_payment_id      in number,
        p_substantiate_reason in varchar2 default null  -- Added by Swamy for Ticket#5692
        ,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is

        l_batch_number   varchar2(30);
        l_error_message  varchar2(32000);
        l_vendor_id      number;
        l_name           varchar2(32000);
        l_address        varchar2(32000);
        l_city           varchar2(32000);
        l_state          varchar2(32000);
        l_zip            varchar2(32000);
        l_acc_num        varchar2(30);
        l_payment_reg_id number;
        l_acc_id         number;
        l_check_number   number;
    begin
        x_return_status := 'S';
        l_batch_number := batch_num_seq.nextval;
        pc_log.log_error('PC_CLAIM.PROCESS_EMP_REFUND', 'p_emp_payment_id ' || p_emp_payment_id);
        if p_entrp_id is not null then
            select
                name,
                address,
                city,
                state,
                zip,
                acc_num,
                acc_id
            into
                l_name,
                l_address,
                l_city,
                l_state,
                l_zip,
                l_acc_num,
                l_acc_id
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id;

        end if;

        for x in (
            select
                vendor_id
            from
                vendors
            where
                acc_num = l_acc_num
        ) loop
            l_vendor_id := x.vendor_id;
        end loop;

        if l_vendor_id is null then
            if
                l_name is not null
                and l_city is not null
                and l_state is not null
            then
                insert into vendors (
                    vendor_id,
                    orig_sys_vendor_ref,
                    vendor_name,
                    address1,
                    address2,
                    city,
                    state,
                    zip,
                    expense_account,
                    acc_num,
                    acc_id,
                    vendor_in_peachtree,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( vendor_seq.nextval,
                           l_acc_num,
                           l_name,
                           l_address,
                           null,
                           l_city,
                           l_state,
                           l_zip,
                           2400,
                           l_acc_num,
                           l_acc_id,
                           'N',
                           sysdate,
                           0,
                           sysdate,
                           0 ) returning vendor_id into l_vendor_id;

            else
                x_error_message := 'Employer /Address information is incomplete, cannot create refund';
            end if;
        end if;

        if l_vendor_id is not null then
            insert into payment_register (
                payment_register_id,
                batch_number,
                entrp_id,
                acc_num,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                memo,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( payment_register_seq.nextval,
                       l_batch_number,
                       p_entrp_id,
                       l_acc_num,
                       l_name,
                       l_vendor_id,
                       l_acc_num,
                       substr(l_name, 1, 4)
                       || p_emp_payment_id,
                       null,
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
                       (
                           select
                               account_num
                           from
                               payment_acc_info
                           where
                                   substr(account_type, 1, 3) = 'SHA'
                               and status = 'A'
                       ),
                       p_refund_amount,
                       'Refund created on ' || to_char(sysdate, 'MM/DD/RRRR'),
                       'EMPLOYER',
                       'N',
                       'N',
                       'N',
                       l_name,
                       sysdate,
                       get_user_id(v('APP_USER')),
                       sysdate,
                       get_user_id(v('APP_USER')) ) returning payment_register_id into l_payment_reg_id;

        end if;

        update employer_payments
        set
            payment_register_id = l_payment_reg_id
        where
            employer_payment_id = p_emp_payment_id;

        pc_log.log_error('PC_CLAIM.PROCESS_EMP_REFUND', 'L_PAYMENT_REG_ID ' || l_payment_reg_id);
        pc_log.log_error('PC_CLAIM.PROCESS_EMP_REFUND', 'p_emp_payment_id ' || p_emp_payment_id);
        for x in (
            select
                a.payment_register_id,
                c.check_amount,
                d.acc_id
            from
                payment_register  a,
                employer_payments c,
                account           d
            where
                    c.employer_payment_id = p_emp_payment_id
                and nvl(a.cancelled_flag, 'N') = 'N'
                and nvl(a.claim_error_flag, 'N') = 'N'
                and nvl(a.insufficient_fund_flag, 'N') = 'N'
                and nvl(a.peachtree_interfaced, 'N') = 'N'
                and a.payment_register_id = c.payment_register_id
                and a.acc_num = d.acc_num
                and a.claim_type = 'EMPLOYER'
        ) loop

    -- And Cond. added by Swamy for Ticket#5692
	-- When User substantiates, there would be a automatic creation of refund, but for Substantiation reason as PAYROLL,
    -- Check should not be generated. Added condition " and nvl(p_Substantiate_reason,'*') = 'PAYROLL'  "
            if
                x.check_amount > 0
                and nvl(p_substantiate_reason, '*') <> 'PAYROLL'
            then
                pc_check_process.insert_check(
                    p_claim_id     => x.payment_register_id,
                    p_check_amount => x.check_amount,
                    p_acc_id       => x.acc_id,
                    p_user_id      => get_user_id(v('APP_USER')),
                    p_status       => 'OPEN',
                    p_source       => 'EMPLOYER_PAYMENTS',
                    x_check_number => l_check_number
                );

            end if;
        end loop;

        update employer_payments
        set
            check_number = l_check_number
        where
            employer_payment_id = p_emp_payment_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_CLAIM.PROCESS_EMP_REFUND', 'SQLERRM ' || sqlerrm);
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end process_emp_refund;

    function get_deductible_report return claim_deductible_t
        pipelined
        deterministic
    is
        l_record            claim_deductible_row_t;
        l_deductible_amount number;
        l_approved_amount   number;
    begin
        for x in (
            select
                claim_id,
                a.pers_id,
                b.acc_id,
                b.acc_num,
                a.plan_start_date,
                a.plan_end_date,
                a.service_type,
                bpc.deductible_rule_id,
                bp.annual_election,
                a.claim_amount
            from
                claimn                    a,
                account                   b,
                ben_plan_enrollment_setup bp,
                ben_plan_coverages        bpc
            where
                    a.claim_status = 'PENDING_REVIEW'
                and a.pers_id = b.pers_id
                and bp.status in ( 'A', 'I' )
                and b.acc_id = bp.acc_id
                and a.service_type = bp.plan_type
                and a.plan_start_date = bp.plan_start_date
                and a.plan_end_date = bp.plan_end_date
                and bp.ben_plan_id = bpc.ben_plan_id
        ) loop
            l_deductible_amount := 0;
            l_approved_amount := 0;
            pc_log.log_error('PC_CLAIM.get_deductible_report', x.deductible_rule_id);
            pc_log.log_error('PC_CLAIM.get_deductible_report:acc_num', x.acc_num);
            pc_claim.get_deductible(
                p_acc_id          => x.acc_id,
                p_plan_start_date => x.plan_start_date,
                p_plan_end_date   => x.plan_end_date,
                p_plan_type       => x.service_type,
                p_pers_id         => x.pers_id,
                p_pers_patient    => x.pers_id,
                p_rule_id         => x.deductible_rule_id,
                p_annual_election => x.annual_election,
                p_claim_amount    => x.claim_amount,
                x_deductible      => l_deductible_amount,
                x_payout_amount   => l_approved_amount
            );

            if l_deductible_amount > 0 then
                l_record.claim_id := x.claim_id;
                l_record.acc_num := x.acc_num;
                l_record.plan_type := x.service_type;
                l_record.annual_election := x.annual_election;
                l_record.plan_start_date := x.plan_start_date;
                l_record.plan_end_date := x.plan_end_date;
                l_record.claim_amount := x.claim_amount;
                l_record.deductible_amount := l_deductible_amount;
                l_record.approved_amount := l_approved_amount;
                pipe row ( l_record );
            end if;

        end loop;
    end get_deductible_report;

    function is_duplicate_claim (
        p_claim_id in number
    ) return varchar2 is
        l_message varchar2(1200);
    begin
        for x in (
            select
                c.acc_num,
                a.service_name,
                count(distinct a.claim_id),
                a.service_price,
                a.service_date,
                a.service_end_date, -- wm_concat( a.claim_id) claim_numbers  -- Commented by RPRABU 0n 17/10/2017
                listagg(a.claim_id, ',') within group(
                order by
                    a.claim_id
                ) claim_numbers  -- Added by RPRABU 0n 17/10/2017
            from
                claim_detail a,
                claimn       b,
                account      c,
                claimn       d,
                claim_detail e
            where
                    a.claim_id = b.claim_id
                and b.plan_end_date > sysdate
                and c.pers_id = b.pers_id
                and b.claim_status not in ( 'CANCELLED', 'DENIED' )
                and d.claim_id = p_claim_id
                and d.claim_id = e.claim_id
                and d.pers_id = b.pers_id
                and e.service_price = a.service_price
                and e.service_date = a.service_date
                and e.service_end_date = a.service_end_date
                and e.service_name = a.service_name
            group by
                c.acc_num,
                a.service_name,
                a.service_price,
                a.service_date,
                a.service_end_date
            having
                count(distinct a.claim_id) > 1
            order by
                c.acc_num,
                a.service_date,
                a.service_end_date
        ) loop
            l_message := 'Possible duplicate found for the service details '
                         || x.service_name
                         || ' service price '
                         || format_money(x.service_price)
                         || ' and service date ranging from '
                         || to_char(x.service_date, 'MM/DD/YYYY')
                         || ' to '
                         || to_char(x.service_end_date, 'MM/DD/YYYY')
                         || ' in claim numbers '
                         || x.claim_numbers;
        end loop;

        return l_message;
    end is_duplicate_claim;

    function get_claim_payment_method (
        p_entrp_id in number
    ) return varchar2 is
        l_claim_payment_method varchar2(30);
        l_sql                  varchar2(3200);
        l_account_type         varchar2(20);
    begin
        for x in (
            select
                claim_payment_method
            from
                account_preference
            where
                entrp_id = p_entrp_id
        ) loop
            l_claim_payment_method := x.claim_payment_method;
        end loop;

        l_sql := 'SELECT lookup_code,
              meaning
        FROM lookups a
        WHERE lookup_name = ''WEB_REIMBURSEMENT_MODE''
        AND  LOOKUP_CODE IN (  ''SUBSCRIBER_ONLINE_ACH'' ,   ''SUBSCRIBER_ONLINE'')  ';

        /* commneted by joshi for 12085- To hide 'Pay me By Check' on website.    
      IF l_claim_payment_method = 'PAYROLL_INTEGRATION' THEN
         l_sql := l_sql ||' AND lookup_code = ''SUBSCRIBER_ONLINE'' ';

      END IF;
      IF l_claim_payment_method = 'PROVIDER_ONLINE' THEN
         l_sql := l_sql ||' AND lookup_code = ''PROVIDER_ONLINE'' ';
      END IF;
      IF l_claim_payment_method = 'CHECK' THEN
         l_sql := l_sql ||' AND lookup_code IN (''SUBSCRIBER_ONLINE'') ';
      END IF;
      IF l_claim_payment_method = 'DIRECT_DEPOSIT' THEN
         l_sql := l_sql ||' AND lookup_code = ''SUBSCRIBER_ONLINE_ACH'' ';
      END IF;

      -- Added by Joshi for 10320 (09/09/2021).
      l_Account_type := pc_account.get_account_type_from_entrp_id(P_ENTRP_ID);
      IF l_Account_type = 'LSA' THEN
        l_sql := l_sql ||' AND lookup_code = ''SUBSCRIBER_ONLINE_ACH'' ';
      END IF;
       */

        return l_sql;
    end get_claim_payment_method;

    procedure create_online_hsa_disbursement (
        p_acc_num          in varchar2,
        p_acc_id           in number,
        p_vendor_id        in number,
        p_bank_acct_id     in number,
        p_amount           in number,
        p_claim_date       in varchar2,
        p_note             in varchar2,
        p_memo             in varchar2,
        p_user_id          in number,
        p_claim_type       in varchar2,
        p_service_date     in pc_online_enrollment.varchar2_tbl,
        p_service_end_date in pc_online_enrollment.varchar2_tbl,
        p_service_price    in pc_online_enrollment.varchar2_tbl,
        p_patient_dep_name in pc_online_enrollment.varchar2_tbl,
        p_medical_code     in pc_online_enrollment.varchar2_tbl,
        p_detail_note      in pc_online_enrollment.varchar2_tbl,
        p_eob_detail_id    in pc_online_enrollment.varchar2_tbl,
        p_eob_id           in varchar2,
        x_claim_id         out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        l_batch_number       varchar2(30);
        setup_error exception;
        l_claim_error_flag   varchar2(30);
        l_doc_flag           varchar2(30);
        l_insurance_category varchar2(30);
        l_claim_category     varchar2(30);
        l_service_type       varchar2(30);
        l_pay_reason         number;
        l_claim_id           number;
        l_payment_reg_id     number;
        l_claim_type         varchar2(30);
        l_vendor_id          number;
        l_check_number       number;
        l_service_date       pc_online_enrollment.varchar2_tbl;
        l_service_end_date   pc_online_enrollment.varchar2_tbl;
        l_service_price      pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name   pc_online_enrollment.varchar2_tbl;
        l_medical_code       pc_online_enrollment.varchar2_tbl;
        l_note               pc_online_enrollment.varchar2_tbl;
        l_filler             pc_online_enrollment.varchar2_tbl;
        l_service_name       pc_online_enrollment.varchar2_tbl;
        l_eob_detail_id      pc_online_enrollment.varchar2_tbl;
        l_eob_linked         pc_online_enrollment.varchar2_tbl;
        l_account_type       varchar2(10);   -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin
        x_return_status := 'S';
        l_batch_number := batch_num_seq.nextval;
        pc_log.log_error('create_online_hsa_disbursement,L_BATCH_NUMBER', l_batch_number);
        pc_log.log_error('create_online_hsa_disbursement,acc_id', p_acc_id);
        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for amount';
            raise setup_error;
        end if;

        l_account_type := pc_account.get_account_type(p_acc_id);   -- Added by Swamy for Ticket#9912 on 10/08/2021

        if
            pc_fin.get_bill_pay_fee(p_acc_id) > 0
            and pc_account.acc_balance(p_acc_id) - p_amount > 0
            and pc_account.acc_balance(p_acc_id) - ( p_amount + nvl(
                pc_fin.get_bill_pay_fee(p_acc_id),
                0
            ) ) < 0
            and p_claim_type in ( 'PROVIDER_ONLINE', 'SUBSCRIBER_ONLINE' )
        then
            x_error_message := 'A '
                               || format_money(pc_fin.get_bill_pay_fee(p_acc_id))
                               || ' charge is applied for checks requested
                         from  your plan and you do not have sufficient funds to cover the disbursement and the charge. '
                               || 'Please reduce your claim by at least '
                               || format_money(pc_fin.get_bill_pay_fee(p_acc_id))
                               || ' and resubmit.';

            raise setup_error;
        end if;

        if
            p_claim_type = 'SUBSCRIBER_ONLINE_ACH'
            and pc_account.acc_balance(p_acc_id) - p_amount < 0
        then
            x_error_message := 'You do not have sufficient balance to schedule this disbursement';
            raise setup_error;
        end if;

        if pc_account.get_account_status(p_acc_id) = 3 then
            x_error_message := 'Your account has not been activated yet, You cannot schedule Disbursement at this time';
            raise setup_error;
        end if;

        if
            pc_account.acc_balance(p_acc_id) - ( p_amount + nvl(
                pc_fin.get_bill_pay_fee(p_acc_id),
                0
            ) ) < 0
            and p_claim_type in ( 'PROVIDER_ONLINE', 'SUBSCRIBER_ONLINE' )
        then
            x_error_message := 'You do not have sufficient balance to schedule this disbursement';
            raise setup_error;
        end if;

        pc_log.log_error('create_online_hsa_disbursement', 'P_ACC_NUM '
                                                           || p_acc_num
                                                           || ' P_CLAIM_TYPE '
                                                           || p_claim_type
                                                           || ' P_VENDOR_ID '
                                                           || p_vendor_id
                                                           || ' bank accct id '
                                                           || p_bank_acct_id);

        if p_claim_type = 'SUBSCRIBER_ONLINE_ACH' then
            l_pay_reason := 19;
        end if;
        if p_claim_type = 'PROVIDER_ONLINE' then
            l_pay_reason := 11;
        end if;
        if p_claim_type = 'SUBSCRIBER_ONLINE' then
            l_pay_reason := 12;
        end if;
        l_vendor_id := p_vendor_id;
        if l_vendor_id = -1 then
            l_vendor_id := null;
        end if;
        if l_pay_reason is null
           or p_claim_type not in ( 'SUBSCRIBER_ONLINE_ACH', 'PROVIDER_ONLINE', 'SUBSCRIBER_ONLINE' ) then
            x_error_message := 'Not a valid payment perference, please choose valid payment preference';
            raise setup_error;
        end if;

        if p_claim_type = 'SUBSCRIBER_ONLINE' then
            for x in (
                select
                    a.vendor_id
                from
                    vendors a,
                    account b,
                    person  c
                where
                        a.orig_sys_vendor_ref = p_acc_num
                    and a.orig_sys_vendor_ref = b.acc_num
                    and c.pers_id = b.pers_id
                    and a.address1 = c.address
                    and a.city = c.city
                    and a.state = c.state
                    and a.zip = c.zip
                    and rownum = 1
            ) loop
                pc_log.log_error('create_online_hsa_disbursement', 'x.VENDOR ID '
                                                                   || x.vendor_id
                                                                   || ' , P_ACC_NUM '
                                                                   || p_acc_num);

                l_vendor_id := x.vendor_id;
                pc_log.log_error('create_online_hsa_disbursement', 'l_VENDOR ID '
                                                                   || l_vendor_id
                                                                   || ' , P_ACC_NUM '
                                                                   || p_acc_num);
            end loop;

            pc_log.log_error('create_online_hsa_disbursement',
                             'l_VENDOR ID ' || nvl(l_vendor_id, -1));
            if ( l_vendor_id = -1
            or l_vendor_id is null ) then
                pc_log.log_error('create_online_hsa_disbursement', 'calling add payee');
                for x in (
                    select
                        first_name
                        || ' '
                        || last_name name,
                        address,
                        city,
                        state,
                        zip,
                        b.acc_id
                    from
                        person  a,
                        account b
                    where
                            a.pers_id = b.pers_id
                        and b.acc_num = p_acc_num
                ) loop
                    pc_payee.add_payee(
                        p_payee_name          => x.name,
                        p_payee_acc_num       => p_acc_num,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zipcode             => x.zip,
                        p_acc_num             => p_acc_num,
                        p_user_id             => p_user_id,
                        p_orig_sys_vendor_ref => p_acc_num,
                        p_acc_id              => x.acc_id,
                        p_payee_type          => l_account_type    -- 'HSA' replaced by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                        ,
                        p_payee_tax_id        => null,
                        x_vendor_id           => l_vendor_id,
                        x_return_status       => x_return_status,
                        x_error_message       => x_error_message
                    );

                    pc_log.log_error('create_online_hsa_disbursement', 'after add payee, X_RETURN_STATUS' || x_return_status);
                    pc_log.log_error('create_online_hsa_disbursement', 'after add payee, X_ERROR_MESSAGE' || x_error_message);
                    if x_return_status <> 'S' then
                        pc_log.log_error('create_online_hsa_disbursement', 'error in vendor creation ' || x_error_message);
                        raise setup_error;
                    end if;

                    pc_log.log_error('create_online_hsa_disbursement', 'L_VENDOR_ID ' || l_vendor_id);
                end loop;

            end if;

        end if;

        pc_log.log_error('create_online_hsa_disbursement',
                         'Have enough balance , '
                         || to_char(pc_account.acc_balance(p_acc_id) -(p_amount + nvl(
                      pc_fin.get_bill_pay_fee(p_acc_id),
                      0
                  ))));

        if ( (
            pc_account.acc_balance(p_acc_id) - ( p_amount + nvl(
                pc_fin.get_bill_pay_fee(p_acc_id),
                0
            ) ) >= 0
            and p_claim_type in ( 'PROVIDER_ONLINE', 'SUBSCRIBER_ONLINE' )
        )
        or (
            pc_account.acc_balance(p_acc_id) - ( p_amount ) >= 0
            and p_claim_type = 'SUBSCRIBER_ONLINE_ACH'
        ) ) then
            pc_log.log_error('create_online_hsa_disbursement', 'Checking values,
               vendor_id '
                                                               || l_vendor_id
                                                               || '  P_BANK_ACCT_ID id '
                                                               || p_bank_acct_id);
            if nvl(l_vendor_id, -1) <> -1 then
                select
                    doc_seq.nextval
                into l_claim_id
                from
                    dual;

                select
                    payment_register_seq.nextval
                into l_payment_reg_id
                from
                    dual;

                pc_log.log_error('create_online_hsa_disbursement', 'Have enough balance , creating claim '
                                                                   || l_claim_id
                                                                   || ' for vendor id '
                                                                   || l_vendor_id);
                insert into payment_register (
                    payment_register_id,
                    batch_number,
                    acc_num,
                    acc_id,
                    pers_id,
                    provider_name,
                    vendor_id,
                    vendor_orig_sys,
                    claim_code,
                    claim_id,
                    trans_date,
                    claim_amount,
                    claim_type,
                    peachtree_interfaced,
                    claim_error_flag,
                    insufficient_fund_flag,
                    pay_reason,
                    memo,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    entrp_id
                )
                    select
                        l_payment_reg_id,
                        l_batch_number,
                        p_acc_num,
                        a.acc_id,
                        b.pers_id,
                        vendor_name,
                        vendor_id,
                        vendor_acc_num,
                        upper(substr(last_name, 1, 4))
                        || to_char(sysdate, 'YYYYMMDDHHMISS'),
                        l_claim_id,
                        nvl(to_date(p_claim_date, 'MM/DD/YYYY'), sysdate),
                        p_amount,
                        p_claim_type,
                        'N',
                        'N',
                        'N',
                        l_pay_reason,
                        p_memo,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        b.entrp_id
                    from
                        account a,
                        person  b,
                        vendors c
                    where
                            a.acc_id = c.acc_id
                        and a.pers_id = b.pers_id
                        and a.acc_num = p_acc_num
                        and a.acc_id = p_acc_id
                        and c.vendor_id = l_vendor_id;

                pc_log.log_error('create_online_hsa_disbursement', 'Have enough balance , created claim '
                                                                   || l_claim_id
                                                                   || ' for vendor id '
                                                                   || l_vendor_id);
            end if;

            pc_log.log_error('create_online_hsa_disbursement', 'checking for P_BANK_ACCT_ID id ' || p_bank_acct_id);
            if ( nvl(p_bank_acct_id, -1) <> -1 ) then
                select
                    payment_register_seq.nextval
                into l_payment_reg_id
                from
                    dual;

                select
                    doc_seq.nextval
                into l_claim_id
                from
                    dual;

                pc_log.log_error('create_online_hsa_disbursement', 'Have enough balance ,
               creating claim '
                                                                   || l_claim_id
                                                                   || ' for P_BANK_ACCT_ID id '
                                                                   || p_bank_acct_id);
                insert into payment_register (
                    payment_register_id,
                    batch_number,
                    acc_num,
                    acc_id,
                    pers_id,
                    provider_name,
                    claim_code,
                    claim_id,
                    bank_acct_id,
                    trans_date,
                    claim_amount,
                    claim_type,
                    peachtree_interfaced,
                    claim_error_flag,
                    insufficient_fund_flag,
                    pay_reason,
                    memo,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    entrp_id
                )
                    select
                        l_payment_reg_id,
                        l_batch_number,
                        p_acc_num,
                        a.acc_id,
                        b.pers_id,
                        'Paid to Subscriber',
                        upper(substr(last_name, 1, 4))
                        || to_char(sysdate, 'YYYYMMDDHHMISS'),
                        l_claim_id,
                        p_bank_acct_id,
                        nvl(to_date(p_claim_date, 'MM/DD/YYYY'), sysdate),
                        p_amount,
                        p_claim_type,
                        'N',
                        'N',
                        'N',
                        l_pay_reason,
                        p_memo,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        b.entrp_id
                    from
                        account a,
                        person  b
                    where
                            a.pers_id = b.pers_id
                        and a.acc_num = p_acc_num;
              --   AND A.ACC_ID  = P_ACC_ID ;
                if sql%rowcount > 0 then
                    pc_log.log_error('create_online_hsa_disbursement', 'inserted into payment register with bank SQL%ROWCOUNT' || l_payment_reg_id
                    );
                end if;

            end if;

            pc_log.log_error('create_online_hsa_disbursement', 'l_payment_reg_id ' || l_payment_reg_id);
            for x in (
                select
                    claim_id
                from
                    payment_register
                where
                    payment_register_id = l_payment_reg_id
            ) loop
                x_claim_id := x.claim_id;
            end loop;

            pc_log.log_error('create_online_hsa_disbursement', 'x_claim_id ' || x_claim_id);
            if x_claim_id is not null then
                insert into claimn (
                    claim_id,
                    pers_id,
                    pers_patient,
                    claim_code,
                    prov_name,
                    claim_date_start,
                    claim_date_end,
                    service_status,
                    claim_status,
                    claim_amount,
                    claim_paid,
                    claim_pending,
                    note,
                    bank_acct_id,
                    vendor_id,
                    pay_reason,
                    claim_date,
                    created_by,
                    last_updated_by,
                    claim_source,
                    trans_fraud_flag,
                    entrp_id
                )
                    select
                        claim_id,
                        pers_id,
                        pers_id,
                        claim_code,
                        provider_name,
                        sysdate,
                        sysdate,
                        2,
                        'PENDING_APPROVAL',
                        claim_amount,
                        0,
                        claim_amount,
                        nvl(p_note,
                            'Disbursement Created on '
                            || to_char(trans_date, 'RRRRMMDD')
                            || ' from Online'),
                        bank_acct_id,
                        vendor_id,
                        pay_reason,
                        trans_date,
                        p_user_id,
                        p_user_id,
                        'ONLINE' -- ##9301 Added By Jagadeesh
                        ,
                        pc_claim.get_trans_fraud_flag(p_acc_id)  -- Added By Jaggi #9775
                        ,
                        entrp_id  -- Added by jaggi #10108
                    from
                        payment_register a
                    where
                            a.claim_id = x_claim_id
                        and a.acc_num = p_acc_num;

                l_service_date := pc_online_enrollment.array_fill(p_service_date, p_service_price.count);
                l_service_end_date := pc_online_enrollment.array_fill(p_service_end_date, p_service_price.count);
                l_service_price := pc_online_enrollment.array_fill(p_service_price, p_service_price.count);
                l_patient_dep_name := pc_online_enrollment.array_fill(p_patient_dep_name, p_service_price.count);
                l_note := pc_online_enrollment.array_fill(p_detail_note, p_service_price.count);
                l_medical_code := pc_online_enrollment.array_fill(p_medical_code, p_service_price.count);
                l_filler := pc_online_enrollment.array_fill(l_filler, p_service_price.count);
                l_service_name := pc_online_enrollment.array_fill(p_detail_note, p_service_price.count);
                l_eob_detail_id := pc_online_enrollment.array_fill(p_eob_detail_id, p_service_price.count);
                l_eob_linked := pc_online_enrollment.array_fill(l_eob_linked, p_service_price.count);
                pc_claim_detail.insert_claim_detail(
                    p_claim_id         => x_claim_id,
                    p_serice_provider  => l_filler,
                    p_service_date     => l_service_date,
                    p_service_end_date => l_service_end_date,
                    p_service_name     => l_service_name,
                    p_service_price    => l_service_price,
                    p_patient_dep_name => l_patient_dep_name,
                    p_medical_code     => l_medical_code,
                    p_service_code     => null,
                    p_note             => l_note,
                    p_provider_tax_id  => l_filler,
                    p_eob_detail_id    => l_eob_detail_id,
                    p_created_by       => p_user_id,
                    p_creation_date    => sysdate,
                    p_last_updated_by  => p_user_id,
                    p_last_update_date => sysdate,
                    p_eob_linked       => l_eob_linked --Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag
                    ,
                    x_return_status    => x_return_status,
                    x_error_message    => x_error_message
                );

                if x_return_status <> 'S' then
                    raise setup_error;
                end if;
            end if;

        end if;

        if x_claim_id is not null then
            if p_eob_id is not null then
                pc_eob.update_claim_with_eob(p_eob_id, x_claim_id, p_user_id);
            end if;

            process_hsa_claim(x_claim_id, p_user_id);
        else
            x_return_status := 'E';
            x_error_message := 'There is a problem processing your request, please contact customer service ';
        end if;

        if x_return_status <> 'S' then
            raise setup_error;
        end if;
        pc_log.log_error('create_online_hsa_disbursement', 'claim id '
                                                           || x_claim_id
                                                           || ' x_return_status '
                                                           || x_return_status);
    exception
        when setup_error then
            x_return_status := 'E';
   --     pc_log.log_app_error('PC_CLAIM','create_online_hsa_disbursement',null,null,null);
            --     ,DBMS_UTILITY.FORMAT_CALL_STACK
             --   , DBMS_UTILITY.FORMAT_ERROR_STACK
             --   , DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('create_online_hsa_disbursement', 'When Others Error ' || x_error_message);
   --     pc_log.log_app_error('PC_CLAIM','create_online_hsa_disbursement',null,null,null);

    end create_online_hsa_disbursement;

    procedure process_online_hsa_claim (
        p_claim_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_check_number   number;
        l_transaction_id number;
        setup_error exception;
        l_paid_flag      varchar2(1) := 'N';
        l_paid_amount    number := 0;
        l_payment_exists varchar2(1) := 'N';
        l_change_num     number;
        l_pay_code       number;
        l_payment_amount number := 0;
        l_account_type   varchar2(10);  -- Added by Swamy for Ticket#9912 on 10/08/2021
        l_entity_type    varchar2(20);  -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin
    -- Create Payment right away if it is check payment
    -- I will have to think of if it is future processing date
    -- then we have to create another nightly process
    -- that will create payments
    -- let me think about it
        x_return_status := 'S';
        for x in (
            select
                b.claim_id,
                b.claim_date,
                b.claim_amount,
                b.claim_pending,
                b.pay_reason,
                a.trans_date,
                a.acc_id,
                b.bank_acct_id,
                a.payment_register_id,
                b.note,
                decode(b.pay_reason, 12, 'SUBSCRIBER', 11, 'PROVIDER',
                       80, 'HSA_TRANSFER', 18, 'OUTSIDE_INVESTMENT_TRANSFER') claim_type
            from
                claimn           b,
                payment_register a
            where
                    b.claim_id = p_claim_id
                and b.claim_id = a.claim_id
                and b.service_type is null
                and b.claim_status = 'PENDING_APPROVAL'
          --    AND    B.CLAIM_PENDING > 0
                and nvl(a.cancelled_flag, 'N') = 'N'
                and nvl(a.claim_error_flag, 'N') = 'N'
                and nvl(a.insufficient_fund_flag, 'N') = 'N'
                and nvl(a.peachtree_interfaced, 'N') = 'N'
        ) loop
            pc_log.log_error('process_online_hsa_claim', 'p_claim_id '
                                                         || p_claim_id
                                                         || ' X.PAY_REASON  '
                                                         || x.pay_reason);
            -- Added by Swamy for Ticket#9912 on 10/08/2021
            l_account_type := null;
            l_entity_type := 'HSA_CLAIM';
            l_account_type := pc_account.get_account_type(x.acc_id);
            if l_account_type = 'LSA' then
                l_entity_type := 'LSA_CLAIM';
            end if;
            if x.pay_reason <> 19 then
                pc_log.log_error('process_online_hsa_claim',
                                 'P_claim_id '
                                 || p_claim_id
                                 || 'balance '
                                 || to_char(pc_account.acc_balance(x.acc_id) -(nvl(x.claim_pending, 0) + nvl(
                              pc_fin.get_bill_pay_fee(x.acc_id),
                              0
                          ))));

                if trunc(x.claim_date) <= trunc(sysdate) then -- I have to rewvaluate this condition based on when we will process
                    if
                        pc_account.acc_balance(x.acc_id) - ( nvl(x.claim_pending, 0) + nvl(
                            pc_fin.get_bill_pay_fee(x.acc_id),
                            0
                        ) ) < 0
                        and x.claim_type = 'PROVIDER'
                    then
                        update payment_register
                        set
                            insufficient_fund_flag = 'Y',
                            last_update_date = sysdate,
                            last_updated_by = p_user_id,
                            note = note
                                   || 'Disbursement requested for '
                                   || claim_amount
                                   || ', Available balance is '
                                   || pc_account.acc_balance(x.acc_id)
                        where
                            claim_id = x.claim_id;

                        update claimn
                        set
                            claim_status = 'APPROVED_NO_FUNDS',
                            note = 'Disbursement requested for '
                                   || claim_amount
                                   || ', Available balance is '
                                   || pc_account.acc_balance(x.acc_id)
                        where
                            claim_id = x.claim_id;

                        pc_notifications.hsa_nsf_letter_notification(x.claim_id, x.claim_type, p_user_id);
                    else
                        l_paid_flag := 'N';
                        l_paid_amount := 0;
                      -- if we didnt enter any check number
                      -- then we never paid out. it will never happen but
                      -- still doing defensive coding
                      -- if we did pay out then I dont want to process further

                        for x in (
                            select
                                sum(nvl(amount, 0)) paid_amount,
                                sum(
                                    case
                                        when pay_num is null then
                                            0
                                        else
                                            1
                                    end
                                )                   paid_count
                            from
                                payment
                            where
                                    claimn_id = p_claim_id
                                and reason_code in ( 11, 12, 13, 80, 18,
                                                     19 )
                        ) loop
                            if x.paid_count > 0 then
                                l_paid_flag := 'Y';
                            end if;
                            if x.paid_amount is not null then
                                l_payment_exists := 'Y';
                                l_paid_amount := x.paid_amount;
                            end if;

                        end loop;

                        pc_log.log_error('process_online_hsa_claim', 'after checking payment stuff,l_payment_exists' || l_payment_exists
                        );
                        pc_log.log_error('process_online_hsa_claim', 'after checking payment stuff,l_paid_flag ' || l_paid_flag);
                        l_change_num := null;
                      -- if we did pay out then do not proceed further
                        if
                            l_paid_flag = 'Y'
                            and x.claim_amount < nvl(l_paid_amount, 0) + nvl(x.claim_pending, 0)
                        then
                            x_return_status := 'E';
                            x_error_message := 'Cannot make payment anymore as the claim amount exceeds paid amount ';
                        end if;

                        pc_log.log_error('process_online_hsa_claim', 'after checking payment stuff,x.CLAIM_AMOUNT ' || x.claim_amount
                        );
                        pc_log.log_error('process_online_hsa_claim',
                                         'nvl(l_paid_amount,0)+NVL(X.CLAIM_PENDING,0)'
                                         || to_char(nvl(l_paid_amount, 0) + nvl(x.claim_pending, 0)));
                      -- Update payment if we didnt create the payment record

                        if x.claim_amount >= nvl(l_paid_amount, 0) + nvl(x.claim_pending, 0) then
                            if
                                nvl(l_paid_flag, 'N') = 'N'
                                and nvl(l_payment_exists, 'N') = 'N'
                            then
                        /*  UPDATE PAYMENT
                          SET    AMOUNT = LEAST(x.CLAIM_PENDING,PC_ACCOUNT.ACC_BALANCE(X.ACC_ID))
                             ,   PAID_DATE = SYSDATE
                          WHERE  CLAIMN_ID = P_CLAIM_ID
                          AND    REASON_CODE IN (11,12,13,19)
                          RETURNING CHANGE_NUM INTO l_change_num;
                           pc_log.log_error('create_online_hsa_disbursement','process_online_hsa_claim '||
                          'l_change_num '||l_change_num);
                       ELSE*/
                                pc_log.log_error('process_hsa_claim', 'inserting to payment ');
                                if
                                    x.claim_pending > 0
                                    and pc_claim.get_claim_paid(x.acc_id, x.claim_type, x.claim_amount) > 0
                                then
                                    l_payment_amount := pc_claim.get_claim_paid(x.acc_id, x.claim_type, x.claim_amount);

                                    insert into payment (
                                        change_num,
                                        claimn_id,
                                        pay_date,
                                        amount,
                                        reason_code,
                                        note,
                                        acc_id,
                                        paid_date
                                    ) values ( change_seq.nextval,
                                               p_claim_id,
                                               x.trans_date,
                                               l_payment_amount,
                                               x.pay_reason,
                                               'Generate Disbursement '
                                               || to_char(x.trans_date, 'RRRRMMDD'),
                                               x.acc_id,
                                               sysdate ) returning change_num into l_change_num;

                                    pc_log.log_error('create_online_hsa_disbursement', 'process_online_hsa_claim '
                                                                                       || 'l_change_num '
                                                                                       || l_change_num);
                                end if;

                            end if;
                        end if;

                        l_check_number := null;
                        if l_change_num is not null then
                            select
                                sum(amount)
                            into l_payment_amount
                            from
                                payment
                            where
                                    change_num = l_change_num
                                and claimn_id = x.claim_id;

                            for xx in (
                                select
                                    check_number
                                from
                                    checks
                                where
                                        entity_type = decode(l_account_type, 'LSA', 'LSA_Claim', 'HSA_CLAIM')   -- Replaced 'HSA_CLAIM' with decode by Swamy for Ticket#9912 on 10/08/2021
                                    and entity_id = x.claim_id
                                    and status = 'OPEN'
                                    and rownum = 1
                            ) loop
                                if nvl(l_payment_amount, 0) > 0 then
                                    update checks
                                    set
                                        check_amount = nvl(l_payment_amount, 0)
                                    where
                                        check_number = xx.check_number;

                                    l_check_number := xx.check_number;
                                end if;
                            end loop;

                        end if;

                        if
                            l_check_number is null
                            and nvl(l_payment_amount, 0) > 0
                        then
                            pc_check_process.insert_check(
                                p_claim_id     => x.claim_id,
                                p_check_amount => nvl(l_payment_amount, 0),
                                p_acc_id       => x.acc_id,
                                p_user_id      => p_user_id,
                                p_status       => 'OPEN',
                                p_source       => l_entity_type,   -- Replaced 'HSA_CLAIM' with l_ENTITY_TYPE by Swamy for Ticket#9912 on 10/08/2021
                                x_check_number => l_check_number
                            );
                        end if;

                        pc_log.log_error('create_online_hsa_disbursement', 'process_online_hsa_claim '
                                                                           || 'l_check_number '
                                                                           || l_check_number);
                        update claimn
                        set
                            claim_pending = x.claim_amount - nvl(
                                pc_claim.f_claim_paid(x.claim_id),
                                0
                            ),
                            claim_paid = nvl(
                                pc_claim.f_claim_paid(x.claim_id),
                                0
                            ),
                            note = 'Disbursement Created on ' || to_char(claim_date_start, 'RRRRMMDD')
                   --     , claim_status  = 'APPROVED_FOR_CHEQUE'
                        where
                            claim_id = x.claim_id;

                   /*
                 update payment_register
                   set    INSUFFICIENT_FUND_FLAG = DECODE( x.CLAIM_AMOUNT-NVL(PC_CLAIM.F_CLAIM_PAID(x.CLAIM_ID),0),0,'N','Y')
                     ,   PEACHTREE_INTERFACED = 'N'
                 where  claim_id = x.claim_id;*/

                        pc_fin.bill_pay_fee(x.acc_id);
                    end if;

                end if;

            else
                l_transaction_id := null;
                for xx in (
                    select
                        transaction_id,
                        status,
                        last_updated_by,
                        total_amount,
                        transaction_date
                    from
                        ach_transfer
                    where
                        claim_id = x.claim_id
                ) loop
                    l_transaction_id := xx.transaction_id;
                    if xx.status = 3 then
                        update claimn
                        set
                            claim_pending = x.claim_amount - nvl(
                                pc_claim.f_claim_paid(x.claim_id),
                                0
                            ),
                            claim_paid = nvl(
                                pc_claim.f_claim_paid(x.claim_id),
                                0
                            ),
                            claim_status = 'PAID'
                        where
                            claim_id = x.claim_id;

                        update payment_register
                        set
                            check_number = l_transaction_id
                        where
                            claim_id = x.claim_id;

                    elsif xx.status = 9 then
                        update payment_register
                        set
                            cancelled_flag = 'Y',
                            last_update_date = sysdate,
                            last_updated_by = last_updated_by
                        where
                            claim_id = x.claim_id;

                        update claimn
                        set
                            claim_status = 'CANCELLED',
                            claim_pending = 0,
                            claim_paid = 0
                        where
                            claim_id = x.claim_id;

                    else
                        if ( x.claim_pending <> xx.total_amount
                        or x.claim_date <> xx.transaction_date ) then
                            pc_ach_transfer.upd_ach_transfer(
                                p_transaction_id   => xx.transaction_id,
                                p_transaction_type => 'D',
                                p_amount           => x.claim_pending,
                                p_fee_amount       => 0,
                                p_transaction_date => x.claim_date,
                                p_reason_code      => 1,
                                p_user_id          => p_user_id,
                                x_return_status    => x_return_status,
                                x_error_message    => x_error_message
                            );

                            if x_return_status <> 'S' then
                                raise setup_error;
                            end if;
                        end if;
                    end if;

                end loop;

                if x.note = 'Claim from Mobile Website' then
                    l_pay_code := 10;
                end if;
                if l_transaction_id is null  --AND X.CLAIM_DATE > SYSDATE
                 then
                    pc_ach_transfer.ins_ach_transfer(
                        p_acc_id           => x.acc_id,
                        p_bank_acct_id     => x.bank_acct_id,
                        p_transaction_type => 'D',
                        p_amount           => x.claim_amount,
                        p_fee_amount       => 0,
                        p_transaction_date => greatest(x.claim_date, sysdate),
                        p_reason_code      => 1,
                        p_status           => 2,
                        p_user_id          => p_user_id,
                        p_pay_code         => nvl(l_pay_code, 5),
                        x_transaction_id   => l_transaction_id,
                        x_return_status    => x_return_status,
                        x_error_message    => x_error_message
                    );

                    if x_return_status <> 'S' then
                        raise setup_error;
                    end if;
                    update ach_transfer
                    set
                        claim_id = x.claim_id
                    where
                        transaction_id = l_transaction_id;

                    update payment_register
                    set
                        check_number = l_transaction_id
                    where
                        claim_id = x.claim_id;

                end if;

            end if;

            for xx in (
                select
                    case
                        when pc_claim.get_claim_3000_per_week(x.acc_id) > 0
                             and pc_claim.get_claim_8000_per_month(x.acc_id) = 0 then
                            'CLAIM_OVER_3000'
                    end template_name
                from
                    dual
                union
                select
                    case
                        when pc_claim.get_claim_8000_per_month(x.acc_id) > 0 then
                            'CLAIM_OVER_8000'
                    end
                from
                    dual
                union
                select
                    case
                        when pc_claim.get_denied_bank_draft(x.acc_id) > 0 then
                            'DENIED_BANK_DRAFT'
                    end
                from
                    dual
            ) loop
                pc_notifications.audit_review_notification(x.payment_register_id, xx.template_name, p_user_id);
            end loop;

        end loop;

    exception
        when setup_error then
            x_return_status := 'E';
      /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('process_online_hsa_claim', 'process_online_hsa_claim '
                                                         || 'SQLERRM '
                                                         || sqlerrm);
      /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end process_online_hsa_claim;

    procedure process_hsa_claim (
        p_claim_id in number default null,
        p_user_id  in number
    ) is
        l_return_status varchar2(1);
        l_error_message varchar2(3200);
    begin
        l_return_status := 'S';
        pc_log.log_error('process_hsa_claim', 'process_hsa_claim '
                                              || 'p_claim_id '
                                              || p_claim_id);
        for x in (
            select
                b.claim_id,
                b.claim_date_end,
                b.claim_amount,
                b.pay_reason,
                a.trans_date,
                a.acc_id,
                b.bank_acct_id,
                a.payment_register_id,
                pc_claim.f_claim_paid(b.claim_id) claim_paid
            from
                claimn           b,
                payment_register a
            where
                    b.claim_id = nvl(p_claim_id, b.claim_id)
                and b.claim_id = a.claim_id
                and b.service_type is null
          --     AND    B.CLAIM_PENDING > 0
                and b.claim_status = 'PENDING_APPROVAL'
                and nvl(a.cancelled_flag, 'N') = 'N'
                and nvl(a.claim_error_flag, 'N') = 'N'
                and nvl(a.insufficient_fund_flag, 'N') = 'N'
                and nvl(a.peachtree_interfaced, 'N') = 'N'
        ) loop
            l_return_status := 'S';
   --       pc_log.log_error('process_hsa_claim','calling process online hsa claim ');
            if x.claim_amount - nvl(x.claim_paid, 0) > 0 then
                process_online_hsa_claim(x.claim_id, p_user_id, l_return_status, l_error_message);
                if l_return_status <> 'S' then
                    pc_debit_card.insert_alert('Error in Processing claim for claim id ' || x.claim_id, l_error_message);
                end if;

            end if;

        end loop;

    exception
        when others then
            pc_log.log_error('process_hsa_claim', 'ERROR ' || sqlerrm);
      /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end process_hsa_claim;

    procedure update_hsa_disbursement (
        p_claim_id         in varchar2,
        p_acc_id           in number,
        p_amount           in number,
        p_note             in varchar2,
        p_memo             in varchar2,
        p_user_id          in number,
        p_service_date     in pc_online_enrollment.varchar2_tbl,
        p_service_end_date in pc_online_enrollment.varchar2_tbl,
        p_service_price    in pc_online_enrollment.varchar2_tbl,
        p_patient_dep_name in pc_online_enrollment.varchar2_tbl,
        p_medical_code     in pc_online_enrollment.varchar2_tbl,
        p_detail_note      in pc_online_enrollment.varchar2_tbl,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        l_batch_number       varchar2(30);
        setup_error exception;
        l_claim_error_flag   varchar2(30);
        l_doc_flag           varchar2(30);
        l_insurance_category varchar2(30);
        l_claim_category     varchar2(30);
        l_service_type       varchar2(30);
        l_claim_amount       number := 0;
        l_claim_date         date;
        l_pay_reason         number;
        l_claim_id           number;
        l_claim_type         varchar2(30);
        l_vendor_id          number;
        l_check_number       number;
        l_service_date       pc_online_enrollment.varchar2_tbl;
        l_service_end_date   pc_online_enrollment.varchar2_tbl;
        l_service_price      pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name   pc_online_enrollment.varchar2_tbl;
        l_medical_code       pc_online_enrollment.varchar2_tbl;
        l_note               pc_online_enrollment.varchar2_tbl;
        l_filler             pc_online_enrollment.varchar2_tbl;
    begin
        x_return_status := 'S';
        l_batch_number := batch_num_seq.nextval;
        pc_log.log_error('update_hsa_disbursement,L_BATCH_NUMBER', l_batch_number);
        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for amount';
            raise setup_error;
        end if;

        for x in (
            select
                a.pay_reason,
                a.claim_status
            from
                claimn a
            where
                a.claim_id = p_claim_id
        ) loop
            l_pay_reason := x.pay_reason;
            if x.claim_status in ( 'PAID', 'DENIED', 'CANCELLED', 'READY_TO_PAY', 'APPROVED_PENDING_REIMBURSEMENT' ) then
                x_error_message := 'Cannot make changes to the processed claim';
                raise setup_error;
            end if;

        end loop;

        if
            pc_fin.get_bill_pay_fee(p_acc_id) > 0
            and ( pc_account.acc_balance(p_acc_id) - l_claim_amount ) + p_amount > 0
            and ( pc_account.acc_balance(p_acc_id) + l_claim_amount ) - ( p_amount + nvl(
                pc_fin.get_bill_pay_fee(p_acc_id),
                0
            ) ) < 0
            and trunc(l_claim_date) <= sysdate + 4
        then
            x_error_message := 'A '
                               || format_money(pc_fin.get_bill_pay_fee(p_acc_id))
                               || ' charge is applied for checks requested
                         from  your plan and you do not have sufficient funds to cover the disbursement and the charge. '
                               || 'Please reduce your claim by at least '
                               || format_money(pc_fin.get_bill_pay_fee(p_acc_id))
                               || ' and resubmit.';

            raise setup_error;
        end if;

        if
            ( pc_account.acc_balance(p_acc_id) + l_claim_amount ) - ( p_amount + nvl(
                pc_fin.get_bill_pay_fee(p_acc_id),
                0
            ) ) < 0
            and trunc(l_claim_date) <= sysdate + 4
        then
            x_error_message := 'You do not have sufficient balance to schedule this disbursement';
            raise setup_error;
        end if;

        pc_log.log_error('update_hsa_disbursement', 'P_CLAIM_ID '
                                                    || p_claim_id
                                                    || ' l_pay_reason '
                                                    || l_pay_reason);
        if pc_account.acc_balance(p_acc_id) - ( p_amount + nvl(
            pc_fin.get_bill_pay_fee(p_acc_id),
            0
        ) ) >= 0 then
            update payment_register
            set
                claim_amount = nvl(p_amount, claim_amount),
                note = nvl(p_note, note),
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                memo = nvl(p_memo, memo)
            where
                claim_id = p_claim_id;

            l_service_date := pc_online_enrollment.array_fill(p_service_date, p_service_date.count);
            l_service_end_date := pc_online_enrollment.array_fill(p_service_end_date, p_service_date.count);
            l_service_price := pc_online_enrollment.array_fill(p_service_price, p_service_date.count);
            l_patient_dep_name := pc_online_enrollment.array_fill(p_patient_dep_name, p_service_date.count);
            l_note := pc_online_enrollment.array_fill(p_detail_note, p_service_date.count);
            l_medical_code := pc_online_enrollment.array_fill(p_medical_code, p_service_date.count);
            l_filler := pc_online_enrollment.array_fill(l_filler, p_service_date.count);
            pc_claim_detail.insert_claim_detail(
                p_claim_id         => p_claim_id,
                p_serice_provider  => l_filler,
                p_service_date     => l_service_date,
                p_service_end_date => l_service_end_date,
                p_service_name     => l_filler,
                p_service_price    => l_service_price,
                p_patient_dep_name => l_patient_dep_name,
                p_medical_code     => l_medical_code,
                p_service_code     => null,
                p_note             => l_note,
                p_provider_tax_id  => l_filler,
                p_eob_detail_id    => l_filler,
                p_created_by       => p_user_id,
                p_creation_date    => sysdate,
                p_last_updated_by  => p_user_id,
                p_last_update_date => sysdate,
                p_eob_linked       => l_filler,
                x_return_status    => x_return_status,
                x_error_message    => x_error_message
            );

            if x_return_status <> 'S' then
                raise setup_error;
            end if;
        end if;

        process_hsa_claim(p_claim_id, p_user_id);
        if x_return_status <> 'S' then
            raise setup_error;
        end if;
    exception
        when setup_error then
            x_return_status := 'E';
      /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
      /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end update_hsa_disbursement;

    procedure cancel_hsa_disbursement (
        p_claim_id      in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_batch_number       varchar2(30);
        setup_error exception;
        l_claim_error_flag   varchar2(30);
        l_doc_flag           varchar2(30);
        l_insurance_category varchar2(30);
        l_claim_category     varchar2(30);
        l_service_type       varchar2(30);
        l_claim_amount       number := 0;
        l_pay_reason         number;
        l_claim_id           number;
        l_claim_type         varchar2(30);
        l_vendor_id          number;
        l_check_number       number;
    begin
        x_return_status := 'S';
        l_batch_number := batch_num_seq.nextval;
        pc_log.log_error('cancel_hsa_disbursement,L_BATCH_NUMBER', l_batch_number);
        for x in (
            select
                claim_status,
                pay_reason
            from
                claimn
            where
                claim_id = p_claim_id
        ) loop
            if x.claim_status in ( 'PAID', 'DENIED', 'CANCELLED', 'READY_TO_PAY' ) then
                x_error_message := 'Cannot make changes to the processed claim';
                raise setup_error;
            end if;

            update payment_register
            set
                cancelled_flag = 'Y',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = p_claim_id;

            update claimn
            set
                claim_status = 'CANCELLED',
                claim_pending = 0,
                claim_paid = 0
            where
                claim_id = p_claim_id;

            if x.pay_reason = 19 then
                update ach_transfer
                set
                    status = 9,
                    bankserv_status = 'USER_CANCELLED',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    claim_id = p_claim_id;

            end if;

            if x.pay_reason in ( 11, 12 ) then
                delete from payment
                where
                    claimn_id = p_claim_id;

                update checks
                set
                    status = 'CANCELLED'
                where
                        entity_id = p_claim_id
                    and entity_type in ( 'HSA_CLAIM', 'LSA_CLAIM' );    -- LSA_CLAIM added by Swamy for Ticket#9912 on 10/08/2021
            end if;

        end loop;

    exception
        when setup_error then
            x_return_status := 'E';
      /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
      /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end cancel_hsa_disbursement;

/* Commented by Swamy for SQL Injection (White hat www Vid: 48289429)
 FUNCTION get_web_claim_detail(p_acc_id             IN NUMBER
                               ,p_reason_code        IN VARCHAR2
                   ,p_status             IN VARCHAR2
                   ,p_claim_date_from    IN VARCHAR2
                   ,p_claim_date_to      IN VARCHAR2
                   ,p_pay_date_from      IN VARCHAR2
                   ,p_pay_date_to        IN VARCHAR2
                   ,p_request_date_from  IN VARCHAR2
                   ,p_request_date_to  IN VARCHAR2 )
  RETURN claim_detail_t PIPELINED DETERMINISTIC
  IS

    l_record                  claim_detail_row_t;
    l_select                  VARCHAR2(3200);
    l_ref_cursor              sys_refcursor;
    l_search                  VARCHAR2(1) := 'N';
  BEGIN
     pc_log.log_error('get_web_claim_detail','p_acc_id '||p_acc_id);
       pc_log.log_error('get_web_claim_detail','p_status '||p_status);
      pc_log.log_error('get_web_claim_detail','p_reason_code '||p_reason_code);
      pc_log.log_error('get_web_claim_detail','p_claim_date_from '||p_claim_date_from);
      pc_log.log_error('get_web_claim_detail','p_claim_date_to '||p_claim_date_to);

      pc_log.log_error('get_web_claim_detail','p_pay_date_from '||p_pay_date_from);
      pc_log.log_error('get_web_claim_detail','p_pay_date_to '||p_pay_date_to);

      pc_log.log_error('get_web_claim_detail','p_request_date_from '||p_request_date_from);
      pc_log.log_error('get_web_claim_detail','p_request_date_to '||p_request_date_to);
      IF p_acc_id IS NULL THEN
      PIPE ROW(l_record);

      ELSE

            l_select := 'SELECT  TRANSACTION_NUMBER
                            , REIMBURSEMENT_METHOD
                      , CHECK_AMOUNT
                      , VENDOR_NAME
                      , BANK_NAME
                      , CLAIM_PENDING
                      , CLAIM_AMOUNT
                      , REASON_CODE
                      , PAY_DATE
                      , PROV_NAME
                    , CLAIM_STAT_MEANING
                    , CLAIM_STATUS
                    , CLAIM_DATE
                    , CASE WHEN LTRIM(RTRIM(PC_CLAIM.CLAIM_TYPE(TRANSACTION_NUMBER)))
                       LIKE (''%ONLINE%'') THEN ''ONLINE'' ELSE ''IN_OFFICE'' END
                       CLAIM_TYPE
                    FROM   HSA_CLAIM_REPORT_ONLINE_V ';

        IF (p_acc_id IS NOT NULL) THEN
                  -- Append a clause to the query and set the parameter value

              l_select := l_select ||
                     '  WHERE 1=1 AND  acc_id = :p_acc_id
                         AND  (reason_code is null or reason_code not in (14,17)) ' ;

        END IF;

               --  pc_log.log_error('get_web_claim_detail: p_reason_code',p_reason_code);

         IF (p_reason_code IS NOT NULL ) THEN
                  -- Append a clause to the query and set the parameter value
                IF p_reason_code = 'CHECK' THEN
                   l_select := l_select ||
                     '  AND :p_reason_code IS NOT NULL AND REASON_CODE IN (11,12)  ' ;
                END IF;
                IF p_reason_code = 'DIRECT_DEPOSIT' THEN
                   l_select := l_select ||
                     '  AND :p_reason_code IS NOT NULL AND REASON_CODE = 19  ' ;
                END IF;
                IF p_reason_code LIKE '%DEBIT_CARD_PURCHASE%' THEN
                   l_select := l_select ||
                     '  AND :p_reason_code IS NOT NULL AND REASON_CODE = 13  ' ;
                END IF;

                l_search := 'Y';
          ELSE
                   l_select := l_select ||
                     '  AND :p_reason_code IS NULL AND REASON_CODE IN (11,12,13,19)  ' ;

                   l_search := 'Y';
         END IF;

            IF (p_claim_date_from IS NOT NULL
            AND p_claim_date_TO IS NOT NULL ) THEN
                  l_select := l_select ||
                     '  AND CLAIM_DATE >= TO_DATE(:p_claim_date_from,''MM/DD/YYYY'')
                            AND CLAIM_DATE <=  TO_DATE(:p_claim_date_TO,''MM/DD/YYYY'') ' ;
              l_search := 'Y';
            ELSE
                  l_select := l_select || ' AND :p_claim_date_from IS NULL AND :p_claim_date_TO IS NULL ';
                   l_search := 'Y';

            END IF;

            IF (p_pay_date_from IS NOT NULL
             AND p_pay_date_to IS NOT NULL ) THEN
                  -- Append a clause to the query and set the parameter value

                l_select := l_select ||
                     '  AND PAY_DATE >= TO_DATE(:p_pay_date_from,''MM/DD/YYYY'')
                        AND PAY_DATE <=  TO_DATE(:p_pay_date_to,''MM/DD/YYYY'') ' ;
                l_search := 'Y';
           ELSE
                 l_select := l_select || ' AND :p_pay_date_from IS NULL AND :p_pay_date_to IS NULL ';
                   l_search := 'Y';

           END IF;

            IF (p_request_date_from IS NOT NULL
             AND p_request_date_to IS NOT NULL ) THEN
              l_select := l_select ||
                     '  AND DATE_RECEIVED >= TO_DATE(:p_request_date_from,''MM/DD/YYYY'')
                        AND DATE_RECEIVED <=  TO_DATE(:p_request_date_to,''MM/DD/YYYY'') ' ;
                l_search := 'Y';
           ELSE
                 l_select := l_select || ' AND :p_request_date_from IS NULL AND :p_request_date_to IS NULL ';
                 l_search := 'Y';
           END IF;
           IF (p_status IS NOT NULL OR p_status <> '') THEN
                  -- Append a clause to the query and set the parameter value
                 l_select := l_select ||
                     '  AND CLAIM_STATUS = :p_status ' ;
                l_search := 'Y';
           ELSE
                 l_select := l_select || ' AND :p_status IS NULL ';
                 l_search := 'Y';

           END IF;
             IF l_search = 'N' THEN
                 l_select := l_select ||
                     '  AND CLAIM_DATE > trunc(sysdate,''YYYY'') ' ;
             END IF;

        --  l_select := l_select || ' ORDER BY CLAIM_DATE DESC ';

          pc_log.log_error('get_web_claim_detail',l_select);
                -- Execute the SQL statement to fill the cursor
               OPEN l_ref_cursor FOR l_select
               USING p_acc_id,p_reason_code,p_claim_date_from,p_claim_date_to
                   , p_pay_date_from,p_pay_date_to,p_request_date_from,p_request_date_to
                   , p_status;

                -- Traverse the cursor and process each row
               LOOP
                FETCH l_ref_cursor INTO
                  l_record.claim_id
               ,  l_record.reimbursement_method
               ,  l_record.check_amount
               ,  l_record.vendor_name
               ,  l_record.bank_name
               ,  l_record.claim_pending
               ,  l_record.claim_amount
               ,  l_record.reason_code
               ,  l_record.pay_date
               ,  l_record.prov_name
               ,  l_record.claim_stat_meaning
               ,  l_record.claim_status
               ,  l_record.claim_date
               ,  l_record.claim_type;
                EXIT WHEN l_ref_cursor%NOTFOUND;
                 -- Pipe the row to the caller
                 PIPE ROW(l_record);

           END LOOP;

    END IF;
  END get_web_claim_detail;
*/
 -- Added by Swamy for SQL Injection (White hat www Vid: 48289429)
    function get_web_claim_detail (
        p_acc_id            in number,
        p_reason_code       in varchar2,
        p_status            in varchar2,
        p_claim_date_from   in varchar2,
        p_claim_date_to     in varchar2,
        p_pay_date_from     in varchar2,
        p_pay_date_to       in varchar2,
        p_request_date_from in varchar2,
        p_request_date_to   in varchar2
    ) return claim_detail_t
        pipelined
        deterministic
    is

        l_record            claim_detail_row_t;
        l_select            varchar2(3200);
        l_ref_cursor        sys_refcursor;
        l_search            varchar2(1) := 'N';
    --start swamy
        v_claim_date_from   date;
        v_claim_date_to     date;
        v_pay_date_from     date;
        v_pay_date_to       date;
        v_request_date_from date;
        v_request_date_to   date;
    ---end swamy
    begin

  /**************************************************************************************************************************************************
  The parameters p_claim_date_from,p_claim_date_to,p_pay_date_from,p_pay_date_to,p_request_date_from,p_request_date_to
  is hidden in the online web page. Hence these parameteres will always come as null. Suppose if the is any sql injection,
  with correct date values, then the query will filter as per the sql injection date. As these fields are hidden from screen,
  the query should not filter based on the date range. Hence all the date fields are passed as null.
  If in future, these fields are unhidden then uncomment the below code. The below code is written for future use, hence commented now.
  ***********************************************************************************************************************************/

  /*
   IF Is_Date(p_claim_date_from,'MM/DD/YYYY') = 'Y' THEN
      v_claim_date_from := TO_DATE(p_claim_date_from,'MM/DD/YYYY');
   ELSE
      v_claim_date_from := Null;
      v_claim_date_TO := Null;
   END IF;

   IF v_claim_date_from IS NOT NULL THEN
	 IF Is_Date(p_claim_date_TO,'MM/DD/YYYY') = 'Y' THEN
	   v_claim_date_TO   := TO_DATE(p_claim_date_TO,'MM/DD/YYYY');
	 ELSE
	  v_claim_date_TO := Null;
	 END IF;
   END IF;

   IF Is_Date(p_pay_date_from,'MM/DD/YYYY') = 'Y' THEN
      v_pay_date_from   :=  TO_DATE(p_pay_date_from,'MM/DD/YYYY');
   ELSE
      v_pay_date_from := Null;
   END IF;

   IF v_pay_date_from IS NOT NULL THEN
     IF Is_Date(p_pay_date_to,'MM/DD/YYYY') = 'Y' THEN
        v_pay_date_to     :=  TO_DATE(p_pay_date_to,'MM/DD/YYYY');
     ELSE
        v_pay_date_to := Null;
     End IF;
   END IF;

   IF Is_Date(p_request_date_from,'MM/DD/YYYY') = 'Y' THEN
      v_request_date_from := TO_DATE(p_request_date_from,'MM/DD/YYYY');
   ELSE
      v_request_date_from := Null;
   END IF;

   IF v_request_date_from IS NOT NULL THEN
     IF Is_Date(p_request_date_to,'MM/DD/YYYY') = 'Y' THEN
        v_request_date_to   := TO_DATE(p_request_date_to,'MM/DD/YYYY') ;
     ELSE
        v_request_date_to := Null;
     END IF;
   END IF;
   */

        pc_log.log_error('get_web_claim_detail', 'p_acc_id ' || p_acc_id);
        pc_log.log_error('get_web_claim_detail', 'p_status ' || p_status);
        pc_log.log_error('get_web_claim_detail', 'p_reason_code ' || p_reason_code);
        pc_log.log_error('get_web_claim_detail', 'p_claim_date_from ' || p_claim_date_from);
        pc_log.log_error('get_web_claim_detail', 'p_claim_date_to ' || p_claim_date_to);
        pc_log.log_error('get_web_claim_detail', 'p_pay_date_from ' || p_pay_date_from);
        pc_log.log_error('get_web_claim_detail', 'p_pay_date_to ' || p_pay_date_to);
        pc_log.log_error('get_web_claim_detail', 'p_request_date_from ' || p_request_date_from);
        pc_log.log_error('get_web_claim_detail', 'p_request_date_to ' || p_request_date_to);
        if p_acc_id is not null then
            l_select := 'SELECT  TRANSACTION_NUMBER
                      , REIMBURSEMENT_METHOD
                      , CHECK_AMOUNT
                      , VENDOR_NAME
                      , BANK_NAME
                      , CLAIM_PENDING
                      , CLAIM_AMOUNT
                      , REASON_CODE
                      , PAY_DATE
                      , PROV_NAME
                      , CLAIM_STAT_MEANING
                      , CLAIM_STATUS
                      , CLAIM_DATE
                      , CASE WHEN LTRIM(RTRIM(PC_CLAIM.CLAIM_TYPE(TRANSACTION_NUMBER)))
                       LIKE (''%ONLINE%'') THEN ''ONLINE'' ELSE ''IN_OFFICE'' END
                       CLAIM_TYPE
                     FROM HSA_CLAIM_REPORT_ONLINE_V
                    WHERE acc_id = :p_acc_id
                      AND NVL(reason_code,0) in (11,12,13,19) ';

         --  pc_log.log_error('get_web_claim_detail: p_reason_code',p_reason_code);
            if nvl(p_reason_code, '*') in ( 'CHECK', 'DIRECT_DEPOSIT', 'DEBIT_CARD_PURCHASE' ) then  -- Added by swamy
                  -- Append a clause to the query and set the parameter value
                if p_reason_code = 'CHECK' then
                    l_select := l_select || '  AND REASON_CODE IN (11,12)  ';
                end if;
                if p_reason_code = 'DIRECT_DEPOSIT' then
                    l_select := l_select || '  AND REASON_CODE = 19  ';
                end if;
                if p_reason_code like '%DEBIT_CARD_PURCHASE%' then
                    l_select := l_select || '  AND REASON_CODE = 13  ';
                end if;
                l_search := 'Y';
            end if;

            if (
                v_claim_date_from is not null
                and v_claim_date_to is not null
            ) then
                l_select := l_select || '  AND CLAIM_DATE >= TO_DATE(:p_claim_date_from,''MM/DD/YYYY'')
                            AND CLAIM_DATE <=  TO_DATE(:p_claim_date_TO,''MM/DD/YYYY'') ';
                l_search := 'Y';
            else
                l_select := l_select || ' AND :p_claim_date_from IS NULL AND :p_claim_date_TO IS NULL ';
                l_search := 'Y';
            end if;

            if (
                v_pay_date_from is not null
                and v_pay_date_to is not null
            ) then
                  -- Append a clause to the query and set the parameter value
                l_select := l_select || '  AND PAY_DATE >= TO_DATE(:p_pay_date_from,''MM/DD/YYYY'')
                        AND PAY_DATE <=  TO_DATE(:p_pay_date_to,''MM/DD/YYYY'') ';
                l_search := 'Y';
            else
                l_select := l_select || ' AND :p_pay_date_from IS NULL AND :p_pay_date_to IS NULL ';
                l_search := 'Y';
            end if;

            if (
                v_request_date_from is not null
                and v_request_date_to is not null
            ) then
                l_select := l_select || '  AND DATE_RECEIVED >= TO_DATE(:p_request_date_from,''MM/DD/YYYY'')
                        AND DATE_RECEIVED <=  TO_DATE(:p_request_date_to,''MM/DD/YYYY'') ';
                l_search := 'Y';
            else
                l_select := l_select || ' AND :p_request_date_from IS NULL AND :p_request_date_to IS NULL ';
                l_search := 'Y';
            end if;

            if ( p_status is not null
                 or p_status <> '' ) then
                  -- Append a clause to the query and set the parameter value
                l_select := l_select || '  AND CLAIM_STATUS = :p_status ';
                l_search := 'Y';
            else
                l_select := l_select || ' AND :p_status IS NULL ';
                l_search := 'Y';
            end if;

            if l_search = 'N' then
                l_select := l_select || '  AND CLAIM_DATE > trunc(sysdate,''YYYY'') ';
            end if;

                -- Execute the SQL statement to fill the cursor
            open l_ref_cursor for l_select
                using p_acc_id, v_claim_date_from, v_claim_date_to, v_pay_date_from, v_pay_date_to, v_request_date_from, v_request_date_to
                , p_status;

                -- Traverse the cursor and process each row
            loop
                fetch l_ref_cursor into
                    l_record.claim_id,
                    l_record.reimbursement_method,
                    l_record.check_amount,
                    l_record.vendor_name,
                    l_record.bank_name,
                    l_record.claim_pending,
                    l_record.claim_amount,
                    l_record.reason_code,
                    l_record.pay_date,
                    l_record.prov_name,
                    l_record.claim_stat_meaning,
                    l_record.claim_status,
                    l_record.claim_date,
                    l_record.claim_type;

                exit when l_ref_cursor%notfound;
                -- Pipe the row to the caller
                pipe row ( l_record );
            end loop;

        end if;

    end get_web_claim_detail;

    procedure create_new_disbursement (
        p_vendor_id      in number,
        p_provider_name  in varchar2,
        p_address1       in varchar2,
        p_address2       in varchar2,
        p_city           in varchar2,
        p_state          in varchar2,
        p_zipcode        in varchar2,
        p_claim_date     in varchar2,
        p_claim_amount   in number,
        p_claim_type     in varchar2,
        p_acc_num        in varchar2,
        p_note           in varchar2,
        p_dos            in varchar2,
        p_acct_num       in varchar2,
        p_patient_name   in varchar2,
        p_date_received  in varchar2,
        p_payment_mode   in varchar2 default 'P'  --P : Payment, FP : Fee Bucket Refund
        ,
        p_user_id        in number,
        p_batch_number   in varchar2,
        p_termination    in varchar2 default 'N',
        p_reason_code    in number,
        p_service_status in number default 2,
        p_claim_source   in varchar2 default 'INTERNAL' -- added by Joshi for 6792
    ) is

        l_error_message   varchar2(32000);
        l_plan_code       number;
        l_acc_id          number;
        l_vendor_id       number;
        l_pers_id         number;
        l_grp_acc         varchar2(30);
        l_fee_setup       number;
        l_count           number;
        l_claim_insert    varchar2(1) := 'N';
        l_claim_amount    number;
        j                 number;
        l_status          varchar2(30) := 'SUCCESS';
        l_setup_error exception;
        l_close_error exception;
        l_return_status   varchar2(30) := 'S';
        l_provider_name   varchar2(3200);
        l_last_name       varchar2(3200);
        l_nsf_flag        varchar2(1) := 'N';
        l_note            varchar2(32000);
        l_payment_reg_id  number;
        l_check_number    number;
        l_claim_id        number;
       --Added for the new HSA Subscriber/Provider screen
        l_mth_srt_day     varchar2(4) := null;
        l_entrp_id        number;
        l_mtly_fee        number := 0;
        l_current_balance number := 0;
        l_account_type    account.account_type%type;   -- Added by Swamy for Ticket#9912 on 10/08/2021
        l_source          varchar2(10);                -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin
   --x_batch_number :=  TO_CHAR(SYSDATE,'YYYYMMDDHHMISS');

        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Batch Number' || p_batch_number);
        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'acc_num' || p_acc_num);
        l_acc_id := null;
        l_claim_amount := p_claim_amount;
        if p_acc_num is not null then
            for x in (
                select
                    acc_id,
                    a.pers_id,
                    b.last_name,
                    a.account_status,
                    a.entrp_id,
                    a.plan_code,  --Added to get the Enterprise and Plan code
                    a.account_type,     -- LSA added by Swamy for Ticket#9912 on 10/08/2021
                    decode(a.account_type, 'HSA', 'HSA_CLAIM', 'LSA', 'LSA_CLAIM') claim_source   -- Added by Swamy for Ticket#9912 on 10/08/2021
                from
                    account a,
                    person  b
                where
                        acc_num = upper(p_acc_num)
                    and a.pers_id = b.pers_id
                    and a.account_type in ( 'HSA', 'LSA' )
            )    -- LSA added by Swamy for Ticket#9912 on 10/08/2021
             loop
                l_acc_id := x.acc_id;
                l_pers_id := x.pers_id;
                l_last_name := x.last_name;
                l_entrp_id := x.entrp_id;
                l_plan_code := x.plan_code;
                l_account_type := x.account_type;      -- LSA added by Swamy for Ticket#9912 on 10/08/2021
                l_source := x.claim_source;          -- Added by Swamy for Ticket#9912 on 10/08/2021
                if x.account_status = 4 then
                    l_error_message := 'Cannot create claim for this account , account is closed';
                    raise l_setup_error;
                end if;
            end loop;

            if l_acc_id is null then
                l_error_message := 'Cannot Find Account , Verify Account Number';
                raise l_setup_error;
            end if;
        end if;

        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Deriving acc_id' || l_acc_id);
        begin
            if p_acc_num is null then
                l_error_message := 'Enter valid value for Account Number';
                raise l_setup_error;
            end if;
            if p_claim_date is null then
                l_error_message := 'Enter valid value for Fee Date';
                raise l_setup_error;
            end if;
            if nvl(p_termination, 'N') = 'Y' then
                l_current_balance := pc_account.current_balance(l_acc_id);
                if l_current_balance < 0 then
                    insert into payment (
                        change_num,
                        acc_id,
                        pay_date,
                        amount,
                        reason_code,
                        note,
                        paid_date
                    ) values ( change_seq.nextval,
                               l_acc_id,
                               sysdate,
                               l_current_balance,
                               20,
                               'Courtesy Credit before closing account ',
                               sysdate );

                    raise l_close_error;
                end if;

            end if;

            if
                nvl(p_claim_amount, 0) = 0
                and nvl(p_termination, 'N') = 'N'
            then
                l_error_message := 'Enter valid value for Claim Amount';
                raise l_setup_error;
            end if;

            if
                p_claim_type in ( 'PROVIDER', 'HSA_TRANSFER', 'LSA_TRANSFER' )    -- LSA_TRANSFER added by Swamy for Ticket#9912 on 10/08/2021
                and p_provider_name is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for Provider Name';
                raise l_setup_error;
            end if;

            if
                p_claim_type in ( 'PROVIDER', 'HSA_TRANSFER', 'LSA_TRANSFER' )    -- LSA_TRANSFER added by Swamy for Ticket#9912 on 10/08/2021
                and p_address1 is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for Address 1';
                raise l_setup_error;
            end if;

            if
                p_claim_type in ( 'PROVIDER', 'HSA_TRANSFER', 'LSA_TRANSFER' )    -- LSA_TRANSFER added by Swamy for Ticket#9912 on 10/08/2021
                and p_city is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for City';
                l_status := 'ERROR';
            end if;

            if
                p_claim_type in ( 'PROVIDER', 'HSA_TRANSFER', 'LSA_TRANSFER' )    -- LSA_TRANSFER added by Swamy for Ticket#9912 on 10/08/2021
                and p_state is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for State';
                raise l_setup_error;
            end if;

            if
                p_claim_type in ( 'PROVIDER', 'HSA_TRANSFER', 'LSA_TRANSFER' )    -- LSA_TRANSFER added by Swamy for Ticket#9912 on 10/08/2021
                and p_zipcode is null
                and p_vendor_id is null
            then
                l_error_message := 'Enter valid value for State';
                raise l_setup_error;
            end if;

            pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Validations Passed');
            if nvl(p_termination, 'N') = 'N' then
               --Code Added for the claims on the last day of the month, Monthly fee charge also added
                  --to the claims during calculating account balance.
                select
                    to_char(sysdate + 1, 'DD')
                into l_mth_srt_day
                from
                    dual;

                if l_mth_srt_day = '01' then
                    select
                        nvl(
                            pc_plan.fmonth_er(l_entrp_id),
                            nvl(
                                pc_plan.fmonth(l_plan_code),
                                0
                            )
                        )
                    into l_mtly_fee
                    from
                        dual;

                else
                    l_mtly_fee := 0;
                end if;
           --End
            else
                l_claim_amount := pc_account.acc_balance(l_acc_id) - nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                ) - nvl(l_mtly_fee, 0);
            end if;

            if p_reason_code not in ( 27, 28, 29 ) then
                if
                    l_claim_amount <= pc_account.acc_balance(l_acc_id) - nvl(
                        pc_fin.get_bill_pay_fee(l_acc_id),
                        0
                    ) - nvl(l_mtly_fee, 0)
                    and pc_account.acc_balance(l_acc_id) - ( l_claim_amount + nvl(
                        pc_fin.get_bill_pay_fee(l_acc_id),
                        0
                    ) + nvl(l_mtly_fee, 0) ) >= 0
                then
                    l_nsf_flag := 'N';
                elsif
                    l_claim_amount > ( pc_account.acc_balance(l_acc_id) - nvl(
                        pc_fin.get_bill_pay_fee(l_acc_id),
                        0
                    ) - nvl(l_mtly_fee, 0) )
                    and ( l_claim_amount + nvl(
                        pc_fin.get_bill_pay_fee(l_acc_id),
                        0
                    ) + nvl(l_mtly_fee, 0) ) - pc_account.acc_balance(l_acc_id) >= 0
                then
                    l_nsf_flag := 'Y';
    /*   ELSIF
          pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT','Checking for NSF in else block , Claim Amount '
          ||P_CLAIM_AMOUNT||' balance '||PC_ACCOUNT.ACC_BALANCE(L_ACC_ID)||' bill pay fee '||nvl(PC_FIN.GET_BILL_PAY_FEE(L_ACC_ID),0)
          ||' monthly fee '||L_MTLY_FEE    );

           L_NSF_FLAG := 'Y' ;*/

                end if;

                pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Checked for NSF' || l_nsf_flag);
                pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Checked for claim amount' || l_claim_amount);
                if pc_account.acc_balance(l_acc_id) - ( nvl(l_claim_amount, 0) + nvl(
                    pc_fin.get_bill_pay_fee(l_acc_id),
                    0
                ) + nvl(l_mtly_fee, 0) ) < 0 then
                    l_note := p_note
                              || 'Disbursement requested for '
                              || nvl(l_claim_amount, 0)
                              || ' ,but the available balance is '
                              || to_char(pc_account.acc_balance(l_acc_id) - nvl(
                        pc_fin.get_bill_pay_fee(l_acc_id),
                        0
                    ) - nvl(l_mtly_fee, 0));

                    pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Note' || l_note);
                    l_claim_amount := pc_account.acc_balance(l_acc_id) - nvl(
                        pc_fin.get_bill_pay_fee(l_acc_id),
                        0
                    ) - nvl(l_mtly_fee, 0);

                    if
                        l_claim_amount > 0
                        and p_claim_type = 'SUBSCRIBER'
                    then
                        l_nsf_flag := 'N';
                    end if;
                else
                    if p_claim_type = 'PROVIDER' then
                        l_note := l_note
                                  || '('
                                  || ( p_acc_num )
                                  || ') '
                                  ||
                            case
                                when p_dos is null then
                                    ''
                                else ' DOS:' || p_dos
                            end
                                  ||
                            case
                                when p_acct_num is null then
                                    ''
                                else ' Acct# ' || p_acct_num
                            end
                                  || p_note;

                    elsif
                        p_claim_type = 'SUBSCRIBER'
                        and p_note is null
                    then
                        l_note := 'Disbursement Created on ' || p_claim_date;
                    else
                        l_note := p_note;
                    end if;
                end if;

            end if;

            pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Note' || l_note);
            l_vendor_id := null;
            pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT',
                             'Claim Type '
                             || p_claim_type
                             || ' Vendor id : '
                             || nvl(p_vendor_id, l_vendor_id)
                             || ' ACC NUM '
                             || p_acc_num);

        exception
            when l_setup_error then
                null;
        end;

        l_vendor_id := p_vendor_id;

/*   IF p_vendor_id IS NULL   THEN
      IF  p_claim_type = 'SUBSCRIBER' THEN
        FOR X IN  (SELECT  A.VENDOR_ID
                FROM   VENDORS A
                     , ACCOUNT B
                     , PERSON C
                WHERE  A.ORIG_SYS_VENDOR_REF  = P_ACC_NUM
                AND    A.ORIG_SYS_VENDOR_REF = B.ACC_NUM
                AND    C.PERS_ID = B.PERS_ID
                AND    A.ADDRESS1 = C.ADDRESS
                AND    A.CITY    = C.CITY
                AND    A.STATE   = C.STATE
                AND    A.ZIP    = C.ZIP
                AND    ROWNUM = 1)
       LOOP
          pc_log.log_error('create_online_hsa_disbursement','x.VENDOR ID '||X.VENDOR_ID ||' , P_ACC_NUM '||P_ACC_NUM);
          L_VENDOR_ID := X.VENDOR_ID;
          pc_log.log_error('create_online_hsa_disbursement','l_VENDOR ID '||l_VENDOR_ID ||' , P_ACC_NUM '||P_ACC_NUM);

        END LOOP;
        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT','subscriber:Vendor id '||L_VENDOR_ID);

     END IF;
   ELSE

        L_VENDOR_ID := P_VENDOR_ID;

   END IF;
   IF  p_claim_type = 'SUBSCRIBER' THEN
       UPDATE vendors
      SET   ORIG_SYS_VENDOR_REF = P_ACC_NUM
    WHERE   vendor_id = NVL(p_vendor_id,l_vendor_id);
   END IF;
      */

        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'Vendor id ' || l_vendor_id);
  /*
  IF NVL(p_vendor_id,l_vendor_id) IS NULL THEN

     IF  p_claim_type = 'SUBSCRIBER' THEN
        FOR X IN (SELECT FIRST_NAME||' '||LAST_NAME NAME, ADDRESS,CITY,STATE,ZIP, B.ACC_ID
                FROM PERSON A, ACCOUNT B
              WHERE  A.PERS_ID = B.PERS_ID
              AND    B.ACC_NUM = P_ACC_NUM)
       LOOP
             pc_payee.add_payee
                ( P_PAYEE_NAME         => X.NAME
                , P_PAYEE_ACC_NUM      => P_ACC_NUM
                , P_ADDRESS            => X.ADDRESS
                , P_CITY               => X.CITY
                , P_STATE              => X.STATE
                , P_ZIPCODE            => X.ZIP
                , P_ACC_NUM            => P_ACC_NUM
                , P_USER_ID            => P_USER_ID
                , P_ORIG_SYS_VENDOR_REF => P_ACC_NUM
                , P_ACC_ID             => X.ACC_ID
                , P_PAYEE_TYPE         => 'HSA'
                , P_PAYEE_TAX_ID       => NULL
                , X_VENDOR_ID         => L_VENDOR_ID
                , X_RETURN_STATUS      => L_RETURN_STATUS
                , X_ERROR_MESSAGE      => L_ERROR_MESSAGE
                );
               pc_log.log_error('create_disbursement','after add payee, L_RETURN_STATUS'||L_RETURN_STATUS);
               pc_log.log_error('create_disbursement','after add payee, L_ERROR_MESSAGE'||L_ERROR_MESSAGE);

              IF L_RETURN_STATUS <> 'S' THEN
                    pc_log.log_error('create_disbursement','error in vendor creation '||L_ERROR_MESSAGE);

                 RAISE l_setup_error;
              END IF;
             pc_log.log_error('create_disbursement','L_VENDOR_ID '||L_VENDOR_ID);

        END LOOP;
    ELSIF  p_claim_type IN ('HSA_TRANSFER','PROVIDER') THEN
              L_PROVIDER_NAME := P_PROVIDER_NAME;
              pc_payee.add_payee
                ( P_PAYEE_NAME         => P_PROVIDER_NAME
                , P_PAYEE_ACC_NUM      => P_ACCT_NUM
                , P_ADDRESS            => P_ADDRESS1||' '||P_ADDRESS2
                , P_CITY               => P_CITY
                , P_STATE              => P_STATE
                , P_ZIPCODE            => P_ZIPCODE
                , P_ACC_NUM            => P_ACC_NUM
                , P_USER_ID            => P_USER_ID
                , P_ORIG_SYS_VENDOR_REF => P_ACCT_NUM
                , P_ACC_ID             => l_ACC_ID
                , P_PAYEE_TYPE         => 'HSA'
                , P_PAYEE_TAX_ID       => NULL
                , X_VENDOR_ID         => L_VENDOR_ID
                , X_RETURN_STATUS      => L_RETURN_STATUS
                , X_ERROR_MESSAGE      => L_ERROR_MESSAGE
                );
               IF L_RETURN_STATUS <> 'S' THEN
                    pc_log.log_error('create_disbursement','error in vendor creation '||L_ERROR_MESSAGE);

                 RAISE l_setup_error;
              END IF;

              pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT','after PC_ONLINE.CREATE_VENDOR '||L_RETURN_STATUS||', vendor_id '||l_vendor_id);

    END IF;

  END IF;
  */
        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'INSERTING TO PAYMENT_REGISTER ,ACC_ID ' || l_acc_id);
        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'INSERTING TO PAYMENT_REGISTER ,p_PROVIDER_NAME ' || p_provider_name);
        if p_provider_name is null then
            for x in (
                select
                    *
                from
                    vendors
                where
                    vendor_id = p_vendor_id
            ) loop
                l_provider_name := x.vendor_name;
            end loop;
        end if;

        update vendors
        set
            acc_id = l_acc_id
        where
                vendor_id = nvl(p_vendor_id, l_vendor_id)
            and acc_id is null;

        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'INSERTING TO PAYMENT_REGISTER ,L_PROVIDER_NAME ' || l_provider_name);
        if
            l_acc_id is not null
            and l_vendor_id is not null
        then
            select
                doc_seq.nextval
            into l_claim_id
            from
                dual;

            select
                payment_register_seq.nextval
            into l_payment_reg_id
            from
                dual;

            pc_log.log_error('create_online_hsa_disbursement', 'Have enough balance , creating claim '
                                                               || l_claim_id
                                                               || ' for vendor id '
                                                               || l_vendor_id);
            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                claim_amount,
                claim_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                pay_reason,
                memo,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entrp_id,
                note,
                patient_name,
                service_type       -- Added by Swamy for Ticket#9912 on 10/08/2021
            )
                select
                    l_payment_reg_id,
                    p_batch_number,
                    p_acc_num,
                    l_acc_id,
                    l_pers_id,
                    nvl(p_provider_name, l_provider_name),
                    l_vendor_id,
                    case
                        when p_claim_type = 'SUBSCRIBER' then
                            p_acc_num
                        else
                            nvl(
                                nvl(p_acct_num, p_provider_name),
                                l_provider_name
                            )
                    end,
                    upper(substr(b.last_name, 1, 4))
                    || to_char(sysdate, 'YYYYMMDDHHMISS'),
                    l_claim_id,
                    nvl(to_date(p_claim_date, 'MM/DD/RRRR'), sysdate),
                    p_claim_amount,
                    p_claim_type,
                    'N',
                    decode(l_error_message, null, 'N', 'Y'),
                    l_nsf_flag,
                    p_reason_code,
                    nvl(l_error_message, '')
                    || '  '
                    || l_note,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    b.entrp_id,
                    nvl(l_error_message, '')
                    || '  '
                    || l_note,
                    p_patient_name,
                    l_account_type       -- Added by Swamy for Ticket#9912 on 10/08/2021
                from
                    person b
                where
                    b.pers_id = l_pers_id;

            pc_log.log_error('create_online_hsa_disbursement', 'Have enough balance , creating claim L_PAYMENT_REG_ID '
                                                               || l_payment_reg_id
                                                               || ' L_MTLY_FEE '
                                                               || l_mtly_fee);
            if
                l_payment_reg_id is not null
                and p_batch_number is not null
            then
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
                    claim_status,
                    claim_date,
                    vendor_id,
                    bank_acct_id,
                    pay_reason,
                    claim_source -- Added bu Joshi for 6796
                    ,
                    created_by               -- Added by Jaggi for 9883
                    ,
                    last_updated_by
                )
                    select
                        claim_id,
                        pers_id,
                        pers_id,
                        claim_code,
                        provider_name,
                        sysdate,
                        to_date(p_date_received, 'MM/DD/RRRR'),
                        nvl(p_service_status, 2),
                        claim_amount,
                        case
                            when p_reason_code in ( 27, 28, 29, 18 ) then
                                claim_amount
                            when p_termination = 'Y'  then
                                claim_amount
                            when trans_date > sysdate then
                                0
                            else
                                get_claim_paid(acc_id, a.claim_type, a.claim_amount)
                        end claim_amount,
                        case
                            when p_reason_code in ( 27, 28, 29, 18 ) then
                                0
                            when p_termination = 'Y'  then
                                0
                            when trans_date > sysdate then
                                claim_amount
                            else
                                claim_amount - get_claim_paid(acc_id, a.claim_type, a.claim_amount)
                        end claim_pending,
                        case
                            when a.claim_amount = get_claim_paid(acc_id, a.claim_type, a.claim_amount) then
                                'Disbursement Created on ' || to_char(trans_date, 'RRRRMMDD')
                            when a.claim_amount > get_claim_paid(acc_id, a.claim_type, a.claim_amount) then
                                'Disbursement requested for '
                                || claim_amount
                                || ', Available balance is '
                                || pc_account.acc_balance(acc_id)
                            when p_reason_code in ( 27, 28, 29 ) then
                                'Adjustment Created on ' || to_char(trans_date, 'RRRRMMDD')
                            when trans_date > sysdate                                                  then
                                'Disbursement Created on ' || to_char(trans_date, 'RRRRMMDD')
                            else
                                'Insufficient Balance'
                        end note,
                        case
                            when get_claim_paid(acc_id, a.claim_type, a.claim_amount) > 0 then
                                'PENDING_APPROVAL'
                            when p_reason_code in ( 27, 28, 29, 18, 80,
                                                    280 ) then     -- 280 Added by Swamy for Ticket#9912 on 10/08/2021
                                'PENDING_APPROVAL'
                            when trans_date > sysdate                                     then
                                'PENDING_APPROVAL'
                            else
                                'APPROVED_NO_FUNDS'
                        end,
                        trans_date,
                        vendor_id,
                        bank_acct_id,
                        pay_reason,
                        p_claim_source,
                        p_user_id             -- Added By Jaggi for 9883
                        ,
                        p_user_id
                    from
                        payment_register a
                    where
                            a.batch_number = p_batch_number
                        and a.vendor_id = nvl(p_vendor_id, l_vendor_id)
                        and payment_register_id = l_payment_reg_id
                        and claim_error_flag = 'N';

                if
                    nvl(to_date(p_claim_date, 'MM/DD/RRRR'), sysdate) > trunc(sysdate)
                    and nvl(p_termination, 'N') = 'N'
                then
                    pc_notifications.claim_notification(l_payment_reg_id, p_user_id);
                end if;

                pc_log.log_error('create_online_hsa_disbursement', 'P_CLAIM_DATE '
                                                                   || p_claim_date
                                                                   || ' P_TERMINATION '
                                                                   || p_termination
                                                                   || ' P_CLAIM_AMOUNT :='
                                                                   || p_claim_amount
                                                                   || ' P_batch_number :='
                                                                   || p_batch_number
                                                                   || ' L_PAYMENT_REG_ID :='
                                                                   || l_payment_reg_id
                                                                   || ' p_vendor_id :='
                                                                   || p_vendor_id);

                if nvl(to_date(p_claim_date, 'MM/DD/RRRR'), sysdate) <= trunc(sysdate) then
                    if
                        l_nsf_flag = 'Y'
                        and p_claim_type in ( 'SUBSCRIBER', 'PROVIDER' )
                    then
                        pc_notifications.hsa_nsf_letter_notification(l_claim_id, p_claim_type, p_user_id);
                    end if;

                    if
                        nvl(p_termination, 'N') = 'N'
                        and p_claim_amount > 0
                    then
                        insert into payment (
                            change_num,
                            claimn_id,
                            pay_date,
                            amount,
                            reason_code,
                            pay_num,
                            note,
                            reason_mode,
                            acc_id,
                            paid_date
                        )
                            select
                                change_seq.nextval,
                                a.claim_id,
                                trans_date,
                                b.claim_paid,
                                p_reason_code,
                                null,
                                'Generate Disbursement ' || to_char(trans_date, 'RRRRMMDD'),
                                p_payment_mode,
                                acc_id,
                                trans_date
                            from
                                payment_register a,
                                claimn           b
                            where
                                    a.batch_number = p_batch_number
                                and a.vendor_id = nvl(p_vendor_id, l_vendor_id)
                                and payment_register_id = l_payment_reg_id
                                and a.claim_id = b.claim_id
                                and b.claim_paid > 0
                                and a.claim_error_flag = 'N'
                                and pc_account.acc_balance(acc_id) - nvl(
                                    pc_fin.get_bill_pay_fee(acc_id),
                                    0
                                ) - l_mtly_fee >= b.claim_paid;

                        pc_notifications.claim_notification(l_payment_reg_id, p_user_id);
                        pc_log.log_error('PC_CLAIM.CREATE_NEW_DISBURSEMENT', 'INSERTING TO CLAIMN ' || sql%rowcount);
                    elsif ( nvl(p_termination, 'N') = 'Y'
                    or p_claim_amount < 0 ) then
                        insert into payment (
                            change_num,
                            claimn_id,
                            pay_date,
                            amount,
                            reason_code,
                            pay_num,
                            note,
                            reason_mode,
                            acc_id,
                            paid_date
                        )
                            select
                                change_seq.nextval,
                                a.claim_id,
                                trans_date,
                                b.claim_paid,
                                p_reason_code,
                                null,
                                'Generate Disbursement ' || to_char(trans_date, 'RRRRMMDD'),
                                p_payment_mode,
                                acc_id,
                                trans_date
                            from
                                payment_register a,
                                claimn           b
                            where
                                    a.batch_number = p_batch_number
                                and a.vendor_id = nvl(p_vendor_id, l_vendor_id)
                                and payment_register_id = l_payment_reg_id
                                and a.claim_id = b.claim_id
                                and b.claim_paid <> 0
                                and a.claim_error_flag = 'N';

                        if
                            p_claim_amount > 0
                            and trunc(to_date(p_claim_date, 'mm/dd/yyyy')) <= trunc(sysdate)
                            and p_reason_code in ( 11, 12 )
                        then
                            pc_fin.bill_pay_fee(l_acc_id);
                        end if;

                    end if;

                    for x in (
                        select
                            a.claim_id,
                            c.amount,
                            c.acc_id,
                            a.service_type     -- Added by Swamy for Ticket#9912 on 10/08/2021
                        from
                            payment_register a,
                            claimn           b,
                            payment          c
                        where
                                a.batch_number = p_batch_number
                            and payment_register_id = l_payment_reg_id
                            and b.claim_status = 'PENDING_APPROVAL'
                            and nvl(a.cancelled_flag, 'N') = 'N'
                            and nvl(a.claim_error_flag, 'N') = 'N'
                            and nvl(a.peachtree_interfaced, 'N') = 'N'
                            and nvl(c.claim_posted, 'N') = 'N'
                            and b.claim_amount - nvl(
                                pc_claim.f_claim_paid(a.claim_id),
                                0
                            ) >= 0
                            and a.claim_id = b.claim_id
                            and b.claim_id = c.claimn_id
                            and c.acc_id = a.acc_id
                            and c.amount > 0
                            and c.reason_code in ( 11, 12, 80, 18, 120 )
                    ) loop
				-- Added by Joshi for 6796. For outside investment, Check need not be created if made online
                        if ( p_reason_code <> 18
                        or (
                            nvl(p_claim_source, 'INTERNAL') <> 'ONLINE'
                            and p_reason_code = 18
                        ) ) then
                            pc_check_process.insert_check(
                                p_claim_id     => x.claim_id,
                                p_check_amount => x.amount,
                                p_acc_id       => x.acc_id,
                                p_user_id      => p_user_id,
                                p_status       => 'OPEN',
                                p_source       => l_source,      -- Replace 'HSA_CLAIM' with l_source by Swamy for Ticket#9912 on 10/08/2021
                                x_check_number => l_check_number
                            );

                        end if;
                    end loop;

                end if;

            end if;

        end if;

    exception
        when l_close_error then
     --  x_return_status := 'E';
            null;
        when l_setup_error then
            null;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end create_new_disbursement;

    procedure schedule_mobile_ach (
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

        l_acc_num          varchar2(30);
        l_claim_id         number;
        l_serice_provider  pc_online_enrollment.varchar2_tbl;
        l_service_date     pc_online_enrollment.varchar2_tbl;
        l_service_end_date pc_online_enrollment.varchar2_tbl;
        l_medical_code     pc_online_enrollment.varchar2_tbl;
        l_service_price    pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name pc_online_enrollment.varchar2_tbl;
        l_note             pc_online_enrollment.varchar2_tbl;
        l_eob_detail_id    pc_online_enrollment.varchar2_tbl;
    begin
        l_acc_num := pc_account.get_acc_num_from_acc_id(p_acc_id);
        l_serice_provider(1) := null;
        l_service_date(1) := null;
        l_service_end_date(1) := null;
        l_medical_code(1) := null;
        l_service_price(1) := null;
        l_patient_dep_name(1) := null;
        l_note(1) := null;
        l_eob_detail_id(1) := null;
        create_online_hsa_disbursement(
            p_acc_num          => l_acc_num,
            p_acc_id           => p_acc_id,
            p_vendor_id        => null,
            p_bank_acct_id     => p_bank_acct_id,
            p_amount           => p_amount,
            p_claim_date       => to_char(p_transaction_date, 'MM/DD/YYYY'),
            p_note             => 'Claim from Mobile Website',
            p_memo             => null,
            p_user_id          => p_user_id,
            p_claim_type       => 'SUBSCRIBER_ONLINE_ACH',
            p_service_date     => l_service_date,
            p_service_end_date => l_service_end_date,
            p_service_price    => l_service_price,
            p_patient_dep_name => l_patient_dep_name,
            p_medical_code     => l_medical_code,
            p_detail_note      => l_note,
            p_eob_detail_id    => l_eob_detail_id,
            p_eob_id           => null,
            x_claim_id         => l_claim_id,
            x_return_status    => x_return_status,
            x_error_message    => x_error_message
        );

        if x_return_status = 'S' then
            x_transaction_id := l_claim_id;
        end if;
        if l_claim_id is not null then
            update claimn
            set
                claim_source = 'MOBILE'
            where
                claim_id = l_claim_id;

        end if;

    end schedule_mobile_ach;

    procedure process_takeover_claim (
        p_batch_number in varchar2,
        p_user_id      in number
    ) is
        l_claim_id      number;
        l_return_status varchar2(3200);
        l_error_message varchar2(3200);
    begin
        for x in (
            select
                acc.acc_num,
                acc.acc_id,
                ext.claim_amount,
                per.first_name
                || decode(per.middle_name, null, '', ' ' || per.middle_name)
                || ' '
                || per.last_name                   patient_name,
                ext.note,
                ext.service_start_dt,
                ext.service_end_dt,
                ext.service_plan_type,
                pc_entrp.get_acc_num(per.entrp_id) er_acc_num,
                per.entrp_id,
                per.pers_id,
                case
                    when upper(ext.takeover_flag) in ( 'Y', 'YES' ) then
                        'Y'
                    else
                        'N'
                end                                takeover
            from
                claims_takeover_external ext,
                account                  acc,
                person                   per
            where
                    ext.acc_num = acc.acc_num
                and acc.pers_id = per.pers_id
                and upper(ext.takeover_flag) in ( 'Y', 'YES' )
        ) loop
            insert into claim_interface (
                claim_interface_id,
                er_acc_num,
                member_id,
                service_plan_type,
                claim_amount,
                patient_name,
                service_start_dt,
                service_end_dt,
                note,
                acc_id,
                pers_id,
                entrp_id,
                acc_num,
                interface_status,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                batch_number,
                takeover
            ) values ( claim_interface_seq.nextval,
                       x.er_acc_num,
                       x.acc_num,
                       x.service_plan_type,
                       x.claim_amount,
                       x.patient_name,
                       x.service_start_dt,
                       x.service_end_dt,
                       'Takeover Claim ',
                       x.acc_id,
                       x.pers_id,
                       x.entrp_id,
                       x.acc_num,
                       'NOT_INTERFACED',
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_batch_number,
                       x.takeover );

        end loop;

        for x in (
            select
                *
            from
                claim_interface
            where
                    batch_number = p_batch_number
                and interface_status = 'NOT_INTERFACED'
        ) loop
            pc_claim.create_fsa_disbursement(
                p_acc_num            => x.acc_num,
                p_acc_id             => x.acc_id,
                p_vendor_id          => null,
                p_vendor_acc_num     => null,
                p_amount             => x.claim_amount,
                p_patient_name       => x.patient_name,
                p_note               => x.note,
                p_user_id            => p_user_id,
                p_service_start_date => to_date(x.service_start_dt, 'MM/DD/YYYY'),
                p_service_end_date   => to_date(x.service_end_dt, 'MM/DD/YYYY'),
                p_date_received      => sysdate,
                p_service_type       => x.service_plan_type,
                p_claim_source       => 'TAKEOVER',
                p_claim_method       => 'SUBSCRIBER_TAKEOVER',
                p_bank_acct_id       => null,
                p_pay_reason         => 12,
                p_doc_flag           => 'N',
                p_insurance_category => null,
                p_claim_category     => null,
                p_memo               => null,
                x_claim_id           => l_claim_id,
                x_return_status      => l_return_status,
                x_error_message      => l_error_message
            );

            if l_return_status <> 'S' then
                update claim_interface
                set
                    error_message = l_error_message,
                    interface_status = 'ERROR'
                where
                    claim_interface_id = x.claim_interface_id;

            else
                update claim_interface
                set
                    claim_id = l_claim_id,
                    interface_status = 'INTERFACED'
                where
                    claim_interface_id = x.claim_interface_id;

                if x.takeover = 'Y' then
                    for xx in (
                        select
                            b.plan_start_date,
                            b.plan_end_date
                        from
                            claimn                    a,
                            account                   c,
                            ben_plan_enrollment_setup b
                        where
                                a.claim_id = l_claim_id
                            and a.pers_id = c.pers_id
                            and c.acc_id = b.acc_id
                            and b.status in ( 'A', 'I' )
                            and a.service_type = b.plan_type
                            and a.service_start_date between b.plan_start_date and b.plan_end_date
                            and a.service_end_date between b.plan_start_date and b.plan_end_date
                    ) loop
                        update claimn
                        set
                            claim_status = 'APPROVED',
                            reviewed_date = sysdate,
                            reviewed_by = p_user_id,
                            takeover = 'Y',
                            plan_start_date = xx.plan_start_date,
                            plan_end_date = xx.plan_end_date,
                            approved_amount = x.claim_amount
                        where
                            claim_id = l_claim_id;

                    end loop;

                end if;

            end if;

        end loop;

    end process_takeover_claim;

    function get_pending_claim_amount (
        p_claim_id         in number,
        p_pers_id          in number,
        p_service_type     in varchar2,
        p_service_date     in date,
        p_service_end_date in date
    ) return number is
        l_claim_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(approved_amount, 0)) claim_amount
            from
                claimn e
            where
                    e.pers_id = p_pers_id
                and e.claim_id <> p_claim_id
                and not exists (
                    select
                        *
                    from
                        payment
                    where
                        claimn_id = e.claim_id
                )
                and claim_status not in ( 'PENDING_DOC', 'DENIED', 'CANCELLED' )
                and e.service_type = p_service_type
                and e.plan_start_date = p_service_date
                and e.plan_end_date = p_service_end_date
        ) loop
            l_claim_amount := x.claim_amount;
        end loop;

        return nvl(l_claim_amount, 0);
    end get_pending_claim_amount;

    procedure create_split_claim (
        p_claim_id         in number,
        p_claim_amount     in number,
        p_plan_start_date  in date,
        p_plan_end_date    in date,
        p_service_date     in date,
        p_service_end_date in date,
        p_user_id          in number,
        x_claim_id         out number
    ) is
    begin
        select
            doc_seq.nextval
        into x_claim_id
        from
            dual;

        insert into payment_register (
            payment_register_id,
            batch_number,
            acc_num,
            acc_id,
            pers_id,
            provider_name,
            vendor_id,
            vendor_orig_sys,
            claim_code,
            claim_id,
            trans_date,
            gl_account,
            cash_account,
            claim_amount,
            note,
            claim_type,
            service_start_date,
            service_end_date,
            service_type,
            pay_reason,
            bank_acct_id,
            memo,
            insurance_category,
            expense_category,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id
        )
            select
                payment_register_seq.nextval,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                upper(substr(claim_code, 1, 4))
                || to_char(sysdate, 'YYYYMMDDHHMISS'),
                x_claim_id,
                sysdate,
                gl_account,
                cash_account,
                p_claim_amount,
                'Split Claim from Claim # ' || p_claim_id,
                claim_type,
                p_service_date,
                p_service_end_date,
                service_type,
                pay_reason,
                bank_acct_id,
                memo,
                insurance_category,
                expense_category,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                entrp_id
            from
                payment_register
            where
                claim_id = p_claim_id;

        insert into claimn (
            claim_id,
            pers_id,
            pers_patient,
            claim_code,
            prov_name,
            claim_date_start,
            claim_date_end,
            service_status,
            service_start_date,
            service_end_date,
            service_type,
            claim_amount,
            claim_paid,
            claim_pending,
            denied_amount,
            claim_status,
            doc_flag,
            insurance_category,
            expense_category,
            note,
            entrp_id,
            plan_start_date,
            plan_end_date,
            source_claim_id,
            pay_reason,
            vendor_id,
            bank_acct_id
        )
            select
                claim_id,
                pers_id,
                pers_id,
                claim_code,
                provider_name,
                trans_date,
                sysdate,
                2,
                service_start_date,
                service_end_date,
                service_type,
                claim_amount,
                0,
                claim_amount,
                0,
                (
                    select
                        claim_status
                    from
                        claimn
                    where
                        claim_id = p_claim_id
                ),
                (
                    select
                        doc_flag
                    from
                        claimn
                    where
                        claim_id = p_claim_id
                ),
                insurance_category,
                expense_category,
                note,
                entrp_id,
                p_plan_start_date,
                p_plan_end_date,
                p_claim_id,
                pay_reason,
                vendor_id,
                bank_acct_id
            from
                payment_register a
            where
                a.claim_id = x_claim_id;

        insert into claim_detail (
            claim_detail_id,
            claim_id,
            service_date,
            service_end_date,
            service_name,
            service_price,
            service_code,
            patient_dep_name,
            note,
            tax_code,
            provider_tax_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            line_status
        )
            select
                claim_detail_seq.nextval,
                x_claim_id,
                service_date,
                service_end_date,
                service_name,
                service_price,
                service_code,
                patient_dep_name,
                note,
                tax_code,
                provider_tax_id,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                'CURRENT_YEAR'
            from
                claim_detail
            where
                    claim_id = p_claim_id
                and service_date >= p_service_date
                and service_end_date <= p_service_end_date;

    end create_split_claim;

    function get_ach_claim_detail (
        p_trans_from_date in date,
        p_trans_to_date   in date
    ) return ach_claim_t
        pipelined
        deterministic
    is
        l_record ach_claim_row_t;
    begin
        for x in (
            select
                transaction_id,
                a.acc_num,
                b.first_name
                || ' '
                || b.middle_name
                || ' '
                || b.last_name name,
                transaction_date,
                a.total_amount,
                a.acc_id,
                b.pers_id,
                a.error_message,
                c.account_status
                  --, PC_ACCOUNT.ACC_BALANCE(c.ACC_ID) balance
                ,
                a.claim_id,
                a.account_type     -- Added by Swamy for Ticket#9912 on 10/08/2021
                ,
                'PPD'          standard_entry_class_code        -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023  for employee it is PPD
            from
                ach_transfer_v a,
                person         b,
                account        c
            where
                    transaction_type = 'D'
                and a.pers_id = b.pers_id
                and a.status in ( 1, 2 )
                and a.acc_id = c.acc_id
                and c.account_type in ( 'HSA', 'LSA' )   -- LSA Added by Swamy for Ticket#10418
                and trunc(transaction_date) >= nvl(p_trans_from_date,
                                                   trunc(sysdate))
                and trunc(transaction_date) <= nvl(p_trans_to_date,
                                                   trunc(sysdate))
        ) loop
            l_record.transaction_id := x.transaction_id;
            l_record.acc_num := x.acc_num;
            l_record.name := x.name;
            l_record.transaction_date := x.transaction_date;
            l_record.total_amount := x.total_amount;
            l_record.balance := pc_account.new_acc_balance(x.acc_id);
            l_record.acc_id := x.acc_id;
            l_record.pers_id := x.pers_id;
            l_record.note := x.error_message;
            l_record.account_status := x.account_status;
            l_record.claim_id := x.claim_id;             -- Added By Jaggi #9775
            l_record.account_type := x.account_type;      -- Added by Swamy for Ticket#9912 on 10/08/2021
            l_record.standard_entry_class_code := x.standard_entry_class_code;   -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023

            pipe row ( l_record );
        end loop;
    end get_ach_claim_detail;

    procedure check_doc_for_debit_card_txn (
        p_claim_id in number default null
    ) is
        l_no_of_docs number := 0;
        l_no_of_days number := 0;
    begin
        for x in (
            select
                a.claim_id,
                a.claim_date,
                a.creation_date,
                a.reviewed_date,
                b.acc_id,
                a.pers_id
            from
                claimn  a,
                account b
            where
                    pay_reason = 13
                and a.pers_id = b.pers_id
                and a.claim_status = 'PENDING_DOC'
                and b.account_type in ( 'HRA', 'FSA' )
                and ( p_claim_id is null
                      or claim_id = p_claim_id )
        ) loop

    -- Claim is in pending documentation status for the past 30 days
    -- it has not been reviewed as well

            select
                count(*)
            into l_no_of_docs
            from
                file_attachments
            where
                entity_id = to_char(x.claim_id);

            if l_no_of_docs = 0 then
                if trunc(sysdate - x.creation_date) = 31 then
                    pc_notifications.debit_letter_notification(x.pers_id, x.acc_id, 'SECOND_LETTER', 0      --System User ID
                    , x.claim_id);
                end if;

                if ( trunc(sysdate - x.creation_date) = 46 ) then
                    pc_notifications.debit_letter_notification(x.pers_id, x.acc_id, 'LAST_LETTER', 0      --System User ID
                    , x.claim_id);

                end if;

            else
                if
                    x.reviewed_date is not null
                    and trunc(x.reviewed_date - sysdate) = 16
                then
                    for xx in (
                        select
                            count(*) cnt
                        from
                            file_attachments
                        where
                                entity_id = to_char(x.claim_id)
                            and creation_date > x.reviewed_date
                    ) loop
                        if xx.cnt = 0 then
                            pc_notifications.debit_letter_notification(x.pers_id, x.acc_id, 'LAST_LETTER', 0      --System User ID
                            , x.claim_id);

                        end if;
                    end loop;

                end if;
            end if;

        end loop;
    end check_doc_for_debit_card_txn;

    procedure update_claim_to_review (
        p_claim_id in number,
        p_user_id  in number
    ) is
        l_claim_id   number;
        l_file_count number := 0;
    begin
        pc_log.log_error('update_claim_to_review', 'p_claim_id ' || p_claim_id);
        select
            count(*)
        into l_file_count
        from
            file_attachments
        where
                entity_name = 'CLAIMN'
            and entity_id = p_claim_id
            and creation_date > sysdate - 1;

        if l_file_count > 0 then
            update claimn
            set
                claim_status = 'PENDING_REVIEW',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    claim_id = p_claim_id
                and claim_status = 'PENDING_DOC'
                and ( pay_reason is null
                      or pay_reason <> 13 )
            returning claim_id into l_claim_id;

            if l_claim_id is not null then
                check_grace_period_claim(p_claim_id);
            else
                update claimn
                set
                    substantiation_reason = 'SUPPORT_DOC_RECV',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                        claim_id = p_claim_id
                    and claim_status = 'PAID'
                    and pay_reason = 13
                return claim_id into l_claim_id;

            end if;

        end if;

    end update_claim_to_review;

    procedure update_hsa_claim_amount (
        p_claim_id      in number,
        p_claim_amount  in number,
        p_memo          in varchar2,
        p_note          in varchar2,
        p_user_id       in number,
        x_error_message out varchar2
    ) is
        error_exception exception;
        l_change_payment varchar2(1) := 'Y';
    begin
        if p_memo is not null then
            update payment_register
            set
                memo = p_memo,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = p_claim_id;

        end if;

        for x in (
            select
                a.claim_id,
                a.claim_amount,
                a.claim_status,
                b.debit_card_posted,
                b.amount
            from
                claimn  a,
                payment b
            where
                    a.claim_id = p_claim_id
                and a.claim_id = b.claimn_id (+)
        ) loop
            if x.claim_status <> 'PENDING_APPROVAL' then
                x_error_message := 'Cannot modify the claim amount, contact administrators for corrective action on this claim';
                raise error_exception;
            end if;

            if x.debit_card_posted = 'Y' then
                x_error_message := 'Cannot modify the claim amount, contact administrators for corrective action on this claim as the payment
                            is posted to debit card already';
                raise error_exception;
            end if;
            if
                x.amount is not null
                and x.amount <> x.claim_amount
                and x.amount < p_claim_amount
            then
                l_change_payment := 'N';
            end if;

            update claimn
            set
                claim_amount = p_claim_amount,
                note = p_note,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = x.claim_id;

            if l_change_payment = 'Y' then
                update payment
                set
                    amount = p_claim_amount,
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                    claimn_id = x.claim_id;

                update checks
                set
                    check_amount = p_claim_amount,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                        entity_id = x.claim_id
                    and entity_type = 'HSA_CLAIM';

            end if;

        end loop;

    exception
        when error_exception then
            null;
    end update_hsa_claim_amount;

    procedure check_grace_period_claim (
        p_claim_id in number
    ) is

        l_claim_det             claim_det_tbl;
        a_claim_det             claim_det_tbl;
        l_past_year_amount      number := 0;
        l_current_year_amount   number := 0;
        l_grace_period_amount   number := 0;
        l_split_amount          number := 0;
        l_claim_amount          number := 0;
        l_acc_id                number;
        l_pers_id               number;
        l_account_type          varchar2(30);
        l_plan_type             varchar2(30);
        l_claim_id              number;
        l_split_claim_count     number := 0;
        l_rule_id               number;
        l_deductible_amount     number;
        l_approved_amount       number := 0;
        l_previous_year_balance number := 0;
    begin
        select
            a.claim_detail_id,
            a.service_date,
            nvl(a.service_end_date, a.service_date) service_end_date,
            a.service_price,
            b.service_type,
            b.pers_id,
            b.pers_patient,
            nvl(a.line_status, 'PENDING'),
            0,
            b.claim_amount
        bulk collect
        into l_claim_det
        from
            claim_detail a,
            claimn       b
        where
                a.claim_id = p_claim_id
            and a.claim_id = b.claim_id
        order by
            a.service_date asc;

        a_claim_det := l_claim_det;
        if l_claim_det.count > 0 then
            for i in 1..l_claim_det.count loop
                for x in (
                    select
                        pc_account.acc_balance(c.acc_id,
                                               d.plan_start_date,
                                               d.plan_end_date,
                                               c.account_type,
                                               l_claim_det(i).plan_type) - nvl(
                            pc_claim.get_pending_claim_amount(p_claim_id, c.pers_id, d.plan_type, d.plan_start_date, d.plan_end_date)
                            ,
                            0
                        )                    acc_bal,
                        plan_start_date,
                        plan_end_date,
                        nvl(grace_period, 0) grace_period,
                        d.plan_type,
                        c.account_type,
                        c.acc_id,
                        c.pers_id,
                        d.annual_election,
                        d.ben_plan_id,
                        d.runout_period_days
                    from
                        ben_plan_enrollment_setup d,
                        account                   c
                    where
                            d.acc_id = c.acc_id
                        and c.pers_id = l_claim_det(i).pers_id
                        and d.plan_type = l_claim_det(i).plan_type
                        and l_claim_det(i).service_date >= trunc(d.plan_start_date)
                        and plan_end_date < sysdate
                    order by
                        d.plan_start_date asc
                ) loop
                    l_acc_id := x.acc_id;
                    l_pers_id := x.pers_id;
                    l_account_type := x.account_type;
                    l_plan_type := x.plan_type;
                    l_previous_year_balance := x.acc_bal;
                    l_claim_amount := a_claim_det(i).claim_amount;
                    if
                        l_claim_det(i).service_date >= x.plan_start_date
                        and l_claim_det(i).service_end_date <= x.plan_end_date
                        and x.plan_end_date < trunc(sysdate)
                    then
       --     l_past_year_amount := LEAST(l_past_year_amount+ l_claim_det(i).service_price,x.acc_bal);
                        l_past_year_amount := l_past_year_amount + l_claim_det(i).service_price;
                        a_claim_det(i).line_status := 'PREVIOUS_YEAR';
                    end if;

                    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM',
                                     'l_claim_det(i).service_date  ' || l_claim_det(i).service_date);
                    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM',
                                     'l_claim_det(i).service_end_date ' || l_claim_det(i).service_end_date);
                    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'x.plan_start_date ' || x.plan_start_date);
                    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'x.plan_end_date ' || x.plan_end_date);
                    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM',
                                     'x.plan_end_date+ x.grace_period  '
                                     || to_char(x.plan_end_date + x.grace_period));

                    if
                                l_claim_det(i).service_date >= x.plan_start_date
                            and l_claim_det(i).service_end_date > x.plan_end_date
                            and l_claim_det(i).service_end_date <= x.plan_end_date + x.grace_period
                                                                                     and x.plan_end_date < trunc(sysdate)
                        and x.plan_end_date + x.grace_period + nvl(x.runout_period_days, 0) >= trunc(sysdate)
                        and x.acc_bal > 0
                    then
         --   l_grace_period_amount := LEAST(l_grace_period_amount + l_claim_det(i).service_price,x.acc_bal);
                        l_grace_period_amount := l_grace_period_amount + l_claim_det(i).service_price;
                        a_claim_det(i).line_status := 'GRACE_PERIOD';
                    end if;

                    for xx in (
                        select
                            deductible_rule_id
                        from
                            ben_plan_coverages a
                        where
                            a.ben_plan_id = x.ben_plan_id
                    ) loop
                        l_rule_id := xx.deductible_rule_id;
                    end loop;

                    if l_rule_id is not null then
                        pc_claim.get_deductible(
                            p_acc_id          => x.acc_id,
                            p_plan_start_date => x.plan_start_date,
                            p_plan_end_date   => x.plan_end_date,
                            p_plan_type       => x.plan_type,
                            p_pers_id         => x.pers_id,
                            p_pers_patient    => x.pers_id,
                            p_rule_id         => l_rule_id,
                            p_annual_election => x.annual_election,
                            p_claim_amount    => l_claim_amount,
                            x_deductible      => l_deductible_amount,
                            x_payout_amount   => l_approved_amount
                        );
                    end if;

                end loop;
            end loop;

            for i in 1..l_claim_det.count loop
                for x in (
                    select
                        plan_start_date,
                        plan_end_date,
                        nvl(grace_period, 0) grace_period,
                        d.plan_type,
                        c.account_type,
                        c.acc_id,
                        c.pers_id
                    from
                        ben_plan_enrollment_setup d,
                        account                   c
                    where
                            d.acc_id = c.acc_id
                        and d.status in ( 'A', 'I' )
                        and c.pers_id = l_claim_det(i).pers_id
                        and d.plan_type = l_claim_det(i).plan_type
                        and l_claim_det(i).service_date >= trunc(d.plan_start_date)
                        and plan_end_date >= trunc(sysdate)
                    order by
                        d.plan_start_date asc
                ) loop
                    if
                        l_claim_det(i).service_date >= x.plan_start_date
                        and l_claim_det(i).service_end_date <= x.plan_end_date
                        and x.plan_end_date >= trunc(sysdate)
                    then
                        if l_past_year_amount + l_grace_period_amount = 0 then
                            l_current_year_amount := l_current_year_amount + l_claim_det(i).service_price;
                            a_claim_det(i).line_status := 'CURRENT_YEAR';
                        else
                            l_split_amount := l_claim_amount;
            -- Deduct any past year balance
                            l_split_amount := l_split_amount - ( l_past_year_amount - nvl(l_deductible_amount, 0) );

            -- if the grace period amount and past year amount
            -- is greater than available balance then just deduct grace period amount
                            if l_past_year_amount + l_grace_period_amount < l_previous_year_balance then
                                l_split_amount := l_split_amount - l_grace_period_amount;
                            end if;
            -- if the past year amount is less than available balance
            -- but grace and past year is greater than previous year available balance
            -- then deduct that amount
                            if
                                l_past_year_amount < l_previous_year_balance
                                and l_past_year_amount + l_grace_period_amount > l_previous_year_balance
                            then
                                l_split_amount := l_split_amount - least(l_grace_period_amount,(l_previous_year_balance - l_past_year_amount
                                ));
                            end if;

                            if l_split_amount > 0 then
                                a_claim_det(i).line_status := 'SPLIT';
                            end if;
                        end if;

                    end if;
                end loop;
            end loop;

        end if;

        pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'l_grace_period_amount ' || l_grace_period_amount);
        pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'l_past_year_amount ' || l_past_year_amount);
        pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'split amount ' || l_split_amount);
        for i in 1..a_claim_det.count loop
            update claim_detail
            set
                line_status = a_claim_det(i).line_status
            where
                    claim_detail_id = a_claim_det(i).detail_id
                and claim_id = p_claim_id;

        end loop;

        if l_grace_period_amount + l_past_year_amount > 0 then
            for x in (
                select
                    ben_plan_id,
                    annual_election,
                    plan_start_date,
                    plan_end_date,
                    pc_account.acc_balance(acc_id, plan_start_date, plan_end_date, l_account_type, l_plan_type) - nvl(
                        pc_claim.get_pending_claim_amount(p_claim_id, l_pers_id, l_plan_type, plan_start_date, plan_end_date),
                        0
                    ) acc_bal
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = l_acc_id
                    and plan_type = l_plan_type
                    and status in ( 'A', 'I' )
                    and plan_end_date = (
                        select
                            max(plan_end_date)
                        from
                            ben_plan_enrollment_setup
                        where
                                acc_id = l_acc_id
                            and plan_type = l_plan_type
                            and status in ( 'A', 'I' )
                            and plan_end_date < trunc(sysdate)
                    )
            ) loop
                update claimn
                set
                    plan_start_date =
                        case
                            when x.acc_bal > 0 then
                                x.plan_start_date
                            else
                                plan_start_date
                        end,
                    plan_end_date =
                        case
                            when x.acc_bal > 0 then
                                x.plan_end_date
                            else
                                plan_end_date
                        end,
                    claim_pending = least(x.acc_bal, l_grace_period_amount + l_past_year_amount),
                    denied_amount = claim_amount - ( nvl(l_deductible_amount, 0) + least(x.acc_bal, l_grace_period_amount + l_past_year_amount
                    ) ),
                    deductible_amount = nvl(l_deductible_amount, 0),
                    approved_amount = least(x.acc_bal, l_grace_period_amount + l_past_year_amount),
                    note = note
                           || ':'
                           ||
                           case
                               when nvl(l_grace_period_amount, 0) > 0
                                    and nvl(l_past_year_amount, 0) = 0
                                    and nvl(l_split_amount, 0) = 0 then
                                   ' Grace Period Claim for previous plan year ,grace period amount: ' || nvl(l_grace_period_amount, 0
                                   )
                               when nvl(l_grace_period_amount, 0) > 0
                                    and l_past_year_amount = 0
                                    and nvl(l_split_amount, 0) = 0 then
                                   'Claim has service dates in grace period,past year amount:  ' || l_past_year_amount
                               when nvl(l_grace_period_amount, 0) > 0
                                    and l_past_year_amount > 0
                                    and nvl(l_split_amount, 0) = 0 then
                                   'Claim has service dates in grace period and previous plan year,previous year service amount '
                                   || l_past_year_amount
                                   || ': grace period service amount '
                                   || nvl(l_grace_period_amount, 0)
                               when nvl(l_grace_period_amount, 0) > 0
                                    and nvl(l_split_amount, 0) > 0 then
                                   'Claim has service dates in grace period and current plan year,previous year service amount '
                                   || l_past_year_amount
                                   || ': grace period service amount '
                                   || nvl(l_grace_period_amount, 0)
                                   || ' :split amount '
                                   || l_split_amount
                               else
                                   'CALCUALTED amounts ,previous year service amount '
                                   || l_past_year_amount
                                   || ': grace period service amount '
                                   || nvl(l_grace_period_amount, 0)
                                   || ' :split amount '
                                   || l_split_amount
                           end
                where
                    claim_id = p_claim_id;

            end loop;

            if l_split_amount - nvl(l_deductible_amount, 0) > 0 then
                select
                    count(*)
                into l_split_claim_count
                from
                    claimn
                where
                    source_claim_id = p_claim_id;

                for x in (
                    select
                        plan_start_date plan_start_date,
                        plan_end_date   plan_end_date,
                        ben_plan_id,
                        annual_election
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = l_acc_id
                        and status in ( 'A', 'I' )
                        and plan_type = l_plan_type
                        and plan_end_date > trunc(sysdate)
                ) loop
                    for xx in (
                        select
                            min(service_date)     service_date,
                            max(service_end_date) service_end_date
                        from
                            claim_detail
                        where
                            line_status not in ( 'GRACE_PERIOD', 'PREVIOUS_YEAR' )
                            and claim_id = p_claim_id
                    ) loop
                        if l_split_claim_count = 0 then
                            pc_claim.create_split_claim(p_claim_id, l_split_amount, x.plan_start_date, x.plan_end_date, xx.service_date
                            ,
                                                        xx.service_end_date, 0, l_claim_id);

                            update claimn
                            set
                                note = note
                                       || ':'
                                       || ' Claim has been split into '
                                       || l_claim_id
                            where
                                claim_id = p_claim_id;

                        else
                            update claimn
                            set
                                plan_start_date = x.plan_start_date,
                                plan_end_date = x.plan_end_date,
                                claim_pending = l_split_amount,
                                claim_amount = l_split_amount
                            where
                                source_claim_id = p_claim_id;

                        end if;
                    end loop;
                end loop;

            end if;

        end if;

        for x in (
            select
                sum(
                    case
                        when line_status = 'CURRENT_YEAR' then
                            1
                        else
                            0
                    end
                ) current_yr_count,
                sum(
                    case
                        when line_status <> 'CURRENT_YEAR' then
                            1
                        else
                            0
                    end
                ) prev_yr_count
            from
                claim_detail
            where
                claim_id = p_claim_id
        ) loop
            if x.prev_yr_count = 0 then
                for xx in (
                    select
                        plan_start_date plan_start_date,
                        plan_end_date   plan_end_date,
                        ben_plan_id,
                        annual_election
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = l_acc_id
                        and status in ( 'A', 'I' )
                        and plan_type = l_plan_type
                     -- AND  plan_end_date > trunc(SYSDATE) )
                        and trunc(plan_start_date) <= trunc(sysdate)
                        and trunc(plan_end_date) + nvl(grace_period, 0) >= trunc(sysdate)
                ) -- commented above and added by Joshi to fix the issue(#11143).
                 loop
                    update claimn
                    set
                        plan_start_date = xx.plan_start_date,
                        plan_end_date = xx.plan_end_date
                    where
                        claim_id = p_claim_id;

                end loop;

            end if;
        end loop;

        for x in (
            select
                count(*) cnt
            from
                claim_detail
            where
                    line_status = 'PENDING'
                and claim_id = p_claim_id
        ) loop
            if x.cnt > 0 then
                update claimn
                set
                    note = note
                           || ':'
                           || ' Unable to determine plan years correctly based on service date range given'
                where
                    claim_id = p_claim_id;

            end if;
        end loop;

    end check_grace_period_claim;

    procedure error_hsa_disbursement (
        p_claim_id      in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_batch_number       varchar2(30);
        setup_error exception;
        l_claim_error_flag   varchar2(30);
        l_doc_flag           varchar2(30);
        l_insurance_category varchar2(30);
        l_claim_category     varchar2(30);
        l_service_type       varchar2(30);
        l_claim_amount       number := 0;
        l_pay_reason         number;
        l_claim_id           number;
        l_claim_type         varchar2(30);
        l_vendor_id          number;
        l_check_number       number;
    begin
        x_return_status := 'S';
        for x in (
            select
                claim_status,
                pay_reason
            from
                claimn
            where
                claim_id = p_claim_id
        ) loop
            if x.claim_status in ( 'PAID', 'DENIED', 'CANCELLED', 'READY_TO_PAY', 'PARTIALLY_PAID' ) then
                x_error_message := 'Cannot make changes to the processed claim';
                raise setup_error;
            end if;

            if x.pay_reason = 19 then
                x_error_message := 'Cannot make changes to the ACH claim';
                raise setup_error;
            end if;
            update payment_register
            set
                cancelled_flag = 'Y',
                claim_error_flag = 'Y',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = p_claim_id;

            update claimn
            set
                claim_status = 'ERROR',
                claim_pending = 0,
                claim_paid = 0,
                note = '***Claim is marked as error by '
                       || get_user_name(p_user_id)
                       || ' on '
                       || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
            where
                claim_id = p_claim_id;

            if x.pay_reason in ( 11, 12, 80 ) then
                for xx in (
                    select
                        *
                    from
                        payment
                    where
                        claimn_id = p_claim_id
                ) loop
                    if xx.debit_card_posted = 'Y' then
                        pc_claim.insert_payment(
                            p_acc_id        => xx.acc_id,
                            p_claim_id      => p_claim_id,
                            p_reason_code   => xx.reason_code,
                            p_amount        => - xx.amount,
                            p_plan_type     => null,
                            p_payment_date  => sysdate,
                            p_pay_num       => null,
                            x_return_status => x_return_status,
                            x_error_message => x_error_message
                        );

                    else
                        delete from payment
                        where
                            claimn_id = p_claim_id;

                    end if;
                end loop;

                update checks
                set
                    status = 'CANCELLED'
                where
                        entity_id = p_claim_id
                    and entity_type in ( 'HSA_CLAIM', 'LSA_CLAIM' );    -- Added by Swamy for Ticket#10104 on 21/09/2021

            end if;

        end loop;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end error_hsa_disbursement;

    function get_claim_offset_number (
        p_claim_id      in number,
        p_offset_reason in varchar2
    ) return number is
        v_doc_amt    number;
        v_cnt        number;
        v_future_amt number;
    begin
        begin
            select
                nvl(doc_offset_amt, 0),
                nvl(future_claim_offset, 0)
            into
                v_doc_amt,
                v_future_amt
            from
                claimn
            where
                claim_id = p_claim_id;

        exception
            when others then
                v_doc_amt := 0;
                v_future_amt := 0;
        end;

        if
            p_offset_reason in ( 'PAYMENT', 'PAYROLL' )
            and v_doc_amt = 0
            and v_future_amt = 0
        then  --Payment/payroll together--Added by Puja
            select
                count(1)
            into v_cnt
            from
                payment a
            where
                    a.claimn_id = p_claim_id
                and reason_code in ( 73, 121 );

        elsif
            p_offset_reason in ( 'PAYMENT', 'PAYROLL', 'SUPPORT_DOC_RECV' )
            and ( v_future_amt <> 0
            or v_doc_amt <> 0 )
        then  --Added by Puja --Future Claim and payment/payroll txns together
            select
                sum(cnt)
            into v_cnt
            from
                (
                    select
                        count(1) cnt
                    from
                        payment a
                    where
                            a.claimn_id = p_claim_id
                        and reason_code in ( 73, 121 )
                    union all
                    select
                        count(1) cnt
                    from
                        claimn x
                    where
                            x.claim_id = p_claim_id
                        and x.unsubstantiated_flag = 'Y'
                        and x.claim_status = 'PAID'
                        and x.future_claim_offset is not null
                    union all
                    select
                        count(1) cnt
                    from
                        claimn x
                    where
                            x.claim_id = p_claim_id
                        and x.unsubstantiated_flag = 'Y'
                        and x.claim_status = 'PAID'
                        and x.doc_offset_amt is not null
                );

        else  --Future Claim txns
            select
                count(1)
            into v_cnt
            from
                claimn x
            where
                x.source_claim_id = p_claim_id;

        end if;

        return v_cnt;
    exception
        when others then
            v_cnt := 0;
            return v_cnt;
    end get_claim_offset_number;

    function get_remaining_offset (
        p_claim_id in number
    ) return number is
        l_offset number := 0;
    begin
        for x in (
            select
                nvl(a.amount, 0) - nvl(b.offset_amount, 0) amount
            from
                payment a,
                claimn  b
            where
                    a.claimn_id = b.claim_id
                and b.claim_id = p_claim_id
                and a.reason_code = 13
        ) loop
            l_offset := x.amount;
        end loop;

        return nvl(l_offset, 0);
    end get_remaining_offset;

    procedure update_source_claim (
        p_claim_amt       in number,
        p_rem_amt         in number,
        p_claim_id        in number,
        p_offset_amt      in number,
        p_unsub_claim_amt in number,
        p_unsub_claim_id  in number,
        x_error_status    out varchar2,
        x_error_message   out varchar2
    ) is

        v_org_amt           number := 0;
        v_rem_amount        number := 0;
        v_pers_id           number;
        v_card_status       number;
        v_future_offset_amt number;
  --x_error_status VARCHAr2(1000);
  --x_error_message VARCHAR2(1000);

        l_user_id           number := get_user_id(v('APP_USER'));
    begin
        pc_log.log_error('In Update_Source_claim', p_claim_id);
           --This is in case of more than 1 claim being used to settle the amount
        begin
            select
                nvl(offset_amount, 0),
                nvl(future_claim_offset, 0),
                pers_id
            into
                v_org_amt,
                v_future_offset_amt,
                v_pers_id   ----Added by Puja for future claim settlement
            from
                claimn
            where
                claim_id = p_unsub_claim_id;

        exception
            when others then
                v_org_amt := 0;
                v_pers_id := 0;
        end;

        if ( p_unsub_claim_amt - p_offset_amt - v_org_amt ) = 0 then --Claim settled
            update claimn
            set
                unsubstantiated_flag = 'N',
                substantiation_reason = 'FUTURE_CLAIM',
                offset_amount = p_offset_amt + v_org_amt,
                future_claim_offset = v_future_offset_amt + p_offset_amt, --Added for future claim settlement
                last_update_date = sysdate,
                last_updated_by = l_user_id
            where
                claim_id = p_unsub_claim_id;

             --When Claim gets Substantiated then un-suspend the suspended card
            begin
                select
                    status
                into v_card_status
                from
                    card_debit
                where
                    card_id = v_pers_id;

            exception
                when others then
                    v_card_status := 0;
            end;

         --Debit card staus will be set to Un-suspend pending i.e activate the card back if card was earlier suspended
            if v_card_status = 4 then
                update card_debit
                set
                    status = 7 --Un-Suspend
                where
                    card_id = v_pers_id;

            end if;

             --DENY the New CLAIM
            if p_claim_amt = p_offset_amt then
                update claimn
                set
                    source_claim_id = p_unsub_claim_id,
                    denied_reason = 'OFFSET_REASON',
                    claim_status = 'DENIED',
                    claim_pending = p_claim_amt - p_offset_amt,
                    denied_amount = p_offset_amt,
                    note = 'Claim offset for claim number # ' || p_unsub_claim_id,
                    last_update_date = sysdate,
                    last_updated_by = l_user_id
                where
                    claim_id = p_claim_id;

            else
                update claimn
                set
                    source_claim_id = p_unsub_claim_id,
                    denied_amount = p_offset_amt,
                    denied_reason = 'OFFSET_REASON',
                    claim_pending = p_claim_amt - p_offset_amt,
                    note = 'Claim offset for claim number # ' || p_unsub_claim_id,
                    last_update_date = sysdate,
                    last_updated_by = get_user_id(v('APP_USER'))
                where
                    claim_id = p_claim_id;

            end if;
             --p_rem_amt := 0; --Amt remaining
        else --Claim not settled
            update claimn
            set
                substantiation_reason = 'FUTURE_CLAIM',
                offset_amount = p_offset_amt + v_org_amt,
                future_claim_offset = v_future_offset_amt + p_offset_amt, ----Added by Puja for future claim settlement
                last_update_date = sysdate,
                last_updated_by = l_user_id
            where
                claim_id = p_unsub_claim_id;

            if p_claim_amt = p_offset_amt then
                update claimn
                set
                    source_claim_id = p_unsub_claim_id,
                    denied_reason = 'OFFSET_REASON',
                    claim_status = 'DENIED',
                    claim_pending = p_claim_amt - p_offset_amt,
                    denied_amount = p_offset_amt,
                    note = 'Claim offset for claim number # ' || p_unsub_claim_id,
                    last_update_date = sysdate,
                    last_updated_by = get_user_id(v('APP_USER'))
                where
                    claim_id = p_claim_id;

            else
                update claimn
                set
                    source_claim_id = p_unsub_claim_id,
                    denied_amount = p_offset_amt,
                    denied_reason = 'OFFSET_REASON',
                    claim_pending = p_claim_amt - p_offset_amt,
                    note = 'Claim offset for claim number # ' || p_unsub_claim_id,
                    last_update_date = sysdate,
                    last_updated_by = l_user_id
                where
                    claim_id = p_claim_id;

            end if;

        end if; --Claim settled/unsettled
        pc_notifications.insert_deny_debit_claim_event(p_claim_id,
                                                       'DEBIT_CARD_ADJ_FUTURE_CLAIM_OFFSET',
                                                       get_user_id(v('APP_USER')));
        x_error_status := 'S';
        x_error_message := 'Success';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := 'Error in Update Source Claim :' || sqlerrm;
            pc_log.log_error('In Update_Source_claim', sqlerrm);
    end update_source_claim;

    procedure mobile_hrafsa_disbursement (
        p_acc_num            in varchar2,
        p_acc_id             in number,
        p_amount             in number,
        p_patient_name       in varchar2,
        p_service_start_date in varchar2,
        p_service_end_date   in varchar2,
        p_service_type       in varchar2,
        p_claim_method       in varchar2,
        p_bank_acct_id       in number,
        p_vendor_id          in number,
        p_vendor_acc_num     in varchar2,
        p_insurance_category in varchar2,
        p_description        in varchar2,
        p_note               in varchar2,
        p_memo               in varchar2,
        p_user_id            in number,
        x_claim_id           out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        claim_creation_error exception;
        l_error_msg        varchar2(150);
        l_first_detail_row boolean;
        l_acc_id           number;
        l_acc_num          varchar2(20);
        l_claim_id         number;
        l_return_status    varchar2(1);
        l_error_message    varchar2(150);
        l_idx              number;
        l_claim_method     varchar2(5);
        l_pay_reason       varchar2(3);
        l_bank_acct_id     number;
        l_service_start_dt date;
        l_service_end_dt   date;
        l_vendor_id        number;
        l_claim_amount     number;
        l_claim_type       varchar2(30);
        l_serice_provider  pc_online_enrollment.varchar2_tbl;
        l_service_date     pc_online_enrollment.varchar2_tbl;
        l_service_end_date pc_online_enrollment.varchar2_tbl;
        l_service_name     pc_online_enrollment.varchar2_tbl;
        l_service_price    pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name pc_online_enrollment.varchar2_tbl;
        l_note             pc_online_enrollment.varchar2_tbl;
        l_tax_code         pc_online_enrollment.varchar2_tbl;
        l_provider_tax_id  pc_online_enrollment.varchar2_tbl;
        l_eob_detail_id    pc_online_enrollment.varchar2_tbl;
        l_eob_linked       pc_online_enrollment.varchar2_tbl;
        l_doc_flag         varchar2(1) := 'N';
        l_service_type     varchar2(30);
    begin
        x_return_status := 'S';
        pc_log.log_error('MOBILE_HRAFSA_DISBURSEMENT:P_ACC_NUM ', p_acc_num);
        pc_log.log_error('MOBILE_HRAFSA_DISBURSEMENT:P_ACC_ID ', p_acc_id);
        pc_log.log_error('MOBILE_HRAFSA_DISBURSEMENT:P_CLAIM_METHOD ', p_claim_method);
        pc_log.log_error('MOBILE_HRAFSA_DISBURSEMENT:P_BANK_ACCT_ID ', p_bank_acct_id);
        pc_log.log_error('MOBILE_HRAFSA_DISBURSEMENT:p_vendor_id ', p_vendor_id);
        l_service_type := p_service_type;
        if p_service_type = 'HRA' then
            for xx in (
                select
                    plan_type
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and plan_type in ( 'HRA', 'HR5', 'HRP', 'HR4', 'ACO' )
                    and status in ( 'A', 'I' )
                    and trunc(plan_start_date) <= trunc(to_date(p_service_start_date, 'MM/DD/YYYY'))
                    and trunc(plan_end_date) >= trunc(to_date(p_service_end_date, 'MM/DD/YYYY'))
            ) loop
                l_service_type := xx.plan_type;
            end loop;
        end if;

        if p_bank_acct_id is not null then
            l_claim_type := 'SUBSCRIBER_ONLINE_ACH';
            l_pay_reason := 19;
        end if;

        if p_vendor_id is not null then
            l_claim_type := 'PROVIDER_ONLINE';
            l_pay_reason := 11;
        end if;

        if l_service_type not in ( 'TRN', 'PKG' ) then
            l_doc_flag := 'Y';
        end if;
        if l_service_type in ( 'HRA', 'HR5', 'HRP', 'ACO', 'HR4' ) then
            pc_claim.create_hra_disbursement(
                p_acc_num            => p_acc_num,
                p_acc_id             => p_acc_id,
                p_vendor_id          => p_vendor_id,
                p_vendor_acc_num     => p_vendor_acc_num,
                p_amount             => p_amount,
                p_patient_name       => p_patient_name,
                p_note               => 'Claim from Mobile Website',
                p_user_id            => p_user_id,
                p_service_start_date => to_date(p_service_start_date, 'MM/DD/YYYY'),
                p_service_end_date   => to_date(p_service_end_date, 'MM/DD/YYYY'),
                p_date_received      => sysdate,
                p_service_type       => l_service_type,
                p_claim_source       => 'MOBILE',
                p_claim_method       => l_claim_type,
                p_bank_acct_id       => p_bank_acct_id,
                p_pay_reason         => l_pay_reason,
                p_doc_flag           => l_doc_flag,
                p_insurance_category => p_insurance_category,
                p_claim_category     => null,
                p_memo               => null,
                x_claim_id           => l_claim_id,
                x_return_status      => x_return_status,
                x_error_message      => x_error_message
            );
        else
            pc_claim.create_fsa_disbursement(
                p_acc_num            => p_acc_num,
                p_acc_id             => p_acc_id,
                p_vendor_id          => p_vendor_id,
                p_vendor_acc_num     => p_vendor_acc_num,
                p_amount             => p_amount,
                p_patient_name       => p_patient_name,
                p_note               => 'Claim from Mobile Website',
                p_user_id            => p_user_id,
                p_service_start_date => to_date(p_service_start_date, 'MM/DD/YYYY'),
                p_service_end_date   => to_date(p_service_end_date, 'MM/DD/YYYY'),
                p_date_received      => sysdate,
                p_service_type       => l_service_type,
                p_claim_source       => 'MOBILE',
                p_claim_method       => l_claim_type,
                p_bank_acct_id       => p_bank_acct_id,
                p_pay_reason         => l_pay_reason,
                p_doc_flag           => l_doc_flag,
                p_insurance_category => p_insurance_category,
                p_claim_category     => null,
                p_memo               => null,
                x_claim_id           => l_claim_id,
                x_return_status      => x_return_status,
                x_error_message      => x_error_message
            );
        end if;

        if x_return_status <> 'S' then
            raise claim_creation_error;
        end if;
        if l_claim_id is not null then
            l_serice_provider(1) := p_description;
            l_service_date(1) := p_service_start_date;
            l_service_end_date(1) := p_service_end_date;
            l_service_name(1) := p_description;
            l_service_price(1) := p_amount;
            l_patient_dep_name(1) := p_patient_name;
            l_note(1) := p_note;
            l_provider_tax_id(1) := null;
            l_eob_detail_id(1) := null;
            l_eob_linked(1) := null;
            pc_claim_detail.insert_claim_detail(
                p_claim_id         => l_claim_id,
                p_serice_provider  => l_serice_provider,
                p_service_date     => l_service_date,
                p_service_end_date => l_service_end_date,
                p_service_name     => l_service_name,
                p_service_price    => l_service_price,
                p_patient_dep_name => l_patient_dep_name,
                p_medical_code     => l_tax_code,
                p_service_code     => null,
                p_provider_tax_id  => l_provider_tax_id,
                p_eob_detail_id    => l_eob_detail_id,
                p_note             => l_note,
                p_created_by       => p_user_id,
                p_creation_date    => sysdate,
                p_last_updated_by  => p_user_id,
                p_last_update_date => sysdate,
                p_eob_linked       => l_eob_linked,
                x_return_status    => x_return_status,
                x_error_message    => x_error_message
            );

            if x_return_status <> 'S' then
                raise claim_creation_error;
            end if;
        end if;

        x_claim_id := l_claim_id;
        if l_claim_id is not null then
            update claimn
            set
                claim_source = 'MOBILE'
            where
                claim_id = l_claim_id;

        end if;

    exception
        when claim_creation_error then
            pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'Error Message ' || x_error_message);
            null;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

        when others then
            x_error_message := sqlerrm;
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end mobile_hrafsa_disbursement;

    procedure schedule_mobile_check (
        p_acc_id           in number,
        p_vendor_id        in number,
        p_amount           in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_user_id          in number,
        p_pay_code         in number default 5,
        p_memo             in varchar2,
        x_claim_id         out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        l_acc_num          varchar2(30);
        l_claim_id         number;
        l_serice_provider  pc_online_enrollment.varchar2_tbl;
        l_service_date     pc_online_enrollment.varchar2_tbl;
        l_service_end_date pc_online_enrollment.varchar2_tbl;
        l_medical_code     pc_online_enrollment.varchar2_tbl;
        l_service_price    pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name pc_online_enrollment.varchar2_tbl;
        l_note             pc_online_enrollment.varchar2_tbl;
        l_eob_detail_id    pc_online_enrollment.varchar2_tbl;
    begin
        l_acc_num := pc_account.get_acc_num_from_acc_id(p_acc_id);
        l_serice_provider(1) := null;
        l_service_date(1) := null;
        l_service_end_date(1) := null;
        l_medical_code(1) := null;
        l_service_price(1) := null;
        l_patient_dep_name(1) := null;
        l_note(1) := null;
        l_eob_detail_id(1) := null;
        create_online_hsa_disbursement(
            p_acc_num          => l_acc_num,
            p_acc_id           => p_acc_id,
            p_vendor_id        => p_vendor_id,
            p_bank_acct_id     => null,
            p_amount           => p_amount,
            p_claim_date       => to_char(p_transaction_date, 'MM/DD/YYYY'),
            p_note             => 'Claim from Mobile Website',
            p_memo             => p_memo,
            p_user_id          => p_user_id,
            p_claim_type       => 'PROVIDER_ONLINE',
            p_service_date     => l_service_date,
            p_service_end_date => l_service_end_date,
            p_service_price    => l_service_price,
            p_patient_dep_name => l_patient_dep_name,
            p_medical_code     => l_medical_code,
            p_detail_note      => l_note,
            p_eob_detail_id    => l_eob_detail_id,
            p_eob_id           => null,
            x_claim_id         => l_claim_id,
            x_return_status    => x_return_status,
            x_error_message    => x_error_message
        );

        if x_return_status = 'S' then
            x_claim_id := l_claim_id;
        end if;
        if l_claim_id is not null then
            update claimn
            set
                claim_source = 'MOBILE'
            where
                claim_id = l_claim_id;

        end if;

    end schedule_mobile_check;

    procedure deny_claims_end_grace_runout is
    begin
        for x in (
            select
                a.acc_num,
                c.claim_id,
                c.claim_status,
                bp.plan_start_date,
                bp.plan_end_date,
                bp.plan_end_date + nvl(bp.grace_period, 0) + nvl(bp.runout_period_days, 0) grace_runout_end,
                pc_entrp.get_entrp_name(c.entrp_id)                                        employer_name
            from
                ben_plan_enrollment_setup bp,
                claimn                    c,
                account                   a
            where
                c.claim_status not in ( 'PAID', 'CANCELLED', 'DENIED', 'ERROR' )
                and bp.plan_end_date + nvl(bp.grace_period, 0) + nvl(bp.runout_period_days, 0) < sysdate
                and c.claim_date < add_months(sysdate, -24)
                and bp.plan_start_date = c.plan_start_date
                and bp.plan_end_date = c.plan_end_date
                and bp.plan_type = c.service_type
                and bp.acc_id = a.acc_id
                and c.pers_id = a.pers_id
                and bp.status in ( 'A', 'I' )
                and a.account_type in ( 'HRA', 'FSA' )
                and not exists (
                    select
                        *
                    from
                        payment p
                    where
                        p.claimn_id = c.claim_id
                )
        ) loop
            update claimn
            set
                claim_status = 'DENIED',
                denied_reason =
                    case
                        when claim_status = 'APPROVED_NO_FUNDS' then
                            'INSUFFICIENT_FUND'
                        when claim_status = 'APPROVED'          then
                            'INSUFFICIENT_FUND'
                        else
                            'OHTER'
                    end
            where
                claim_id = x.claim_id;

        end loop;
    end deny_claims_end_grace_runout;

    procedure update_claim_payments (
        p_ben_plan_id   in number,
        p_entrp_id      in number,
        p_start_date    in varchar2,
        p_end_date      in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_error_status := 'S';
        pc_log.log_error('PC_benefit_Plans', 'Update_Claim_payments');
        for x in (
            select
                a.claim_id id
            from
                claimn                    a,
                ben_plan_enrollment_setup b
            where
                    a.entrp_id = b.entrp_id
                and ben_plan_id = p_ben_plan_id
                and b.status in ( 'A', 'I' )
                and b.ben_plan_id_main is null
             /* Modified for ticket#2734 */
                and a.service_type = b.plan_type
                and trunc(a.plan_start_date) = trunc(b.plan_start_date)
                and trunc(a.plan_end_date) = trunc(b.plan_end_date)
        ) loop
   --pc_log.log_error('In Update Loop1',X.ID);
            update claimn
            set
                plan_start_date = to_date(p_start_date, 'MM/DD/RRRR'),
                plan_end_date = to_date(p_end_date, 'MM/DD/RRRR'),
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = x.id;

        end loop;
 --Update Employer Payments also
        for x in (
            select
                employer_payment_id er_id
            from
                employer_payments         a,
                ben_plan_enrollment_setup b
            where
                    b.ben_plan_id = p_ben_plan_id
                and a.entrp_id = b.entrp_id
                and b.status in ( 'A', 'I' )
                and b.ben_plan_id_main is null
                and trunc(a.plan_start_date) = trunc(b.plan_start_date)
                and trunc(a.plan_end_date) = trunc(b.plan_end_date)
        ) loop
            update employer_payments
            set
                plan_start_date = to_date(p_start_date, 'MM/DD/RRRR'),
                plan_end_date = to_date(p_end_date, 'MM/DD/RRRR'),
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                employer_payment_id = x.er_id;

        end loop;

    exception
        when others then
            pc_log.log_error('Pc_Benefit_plans.Update_claims', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end update_claim_payments;

    procedure substantiate_previous_year (
        p_claim_id              in number,
        p_substantiation_reason in varchar2,
        p_user_id               in number,
        p_offset_amount         in number,
        p_service_type          in varchar2
    ) is

        l_claim_id        number;
        l_error_message   varchar2(3200);
        l_return_status   varchar2(255);
        l_plan_start_date date;
        l_plan_end_date   date;
        l_acc_balance     number := 0;
    begin
        for x in (
            select
                a.claim_id,
                b.acc_num,
                b.pers_id,
                service_start_date,
                service_end_date,
                a.vendor_id,
                a.service_type,
                b.acc_id,
                b.account_type
            from
                claimn  a,
                account b
            where
                    a.pers_id = b.pers_id
                and a.claim_id = p_claim_id
        ) loop
            if p_substantiation_reason = 'OFFSET_PREVIOUS_YEAR' then
                for xx in (
                    select
                        max(plan_start_date)           plan_start_date,
                        max(plan_end_date)             plan_end_date,
                        pc_account.acc_balance(acc_id,
                                               max(plan_start_date),
                                               max(plan_end_date),
                                               x.account_type,
                                               plan_type,
                                               max(plan_start_date),
                                               max(plan_end_date)) acc_balance
                    from
                        ben_plan_enrollment_setup
                    where
                            plan_end_date < sysdate
                        and acc_id = x.acc_id
                        and status in ( 'A', 'I' )
                        and plan_type = x.service_type
                    group by
                        acc_id,
                        x.account_type,
                        plan_type
                ) loop
                    if xx.acc_balance <= 0 then
                        raise_application_error('-20001', 'Account does not have enough balance to offset for previous year ');
                    else
                        l_plan_start_date := xx.plan_start_date;
                        l_plan_end_date := xx.plan_end_date;
                        l_acc_balance := xx.acc_balance;
                    end if;
                end loop;

                if
                    l_plan_start_date is not null
                    and l_plan_end_date is not null
                    and least(p_offset_amount, l_acc_balance) > 0
                then
                    pc_claim.create_fsa_disbursement(
                        p_acc_num            => x.acc_num,
                        p_acc_id             => x.acc_id,
                        p_vendor_id          => null,
                        p_vendor_acc_num     => null,
                        p_amount             => least(p_offset_amount, l_acc_balance),
                        p_patient_name       => null,
                        p_note               => 'Offset for Debit Card Purchase Claim #' || p_claim_id,
                        p_user_id            => p_user_id,
                        p_service_start_date => l_plan_start_date,
                        p_service_end_date   => l_plan_end_date,
                        p_date_received      => sysdate,
                        p_service_type       => nvl(p_service_type, x.service_type),
                        p_claim_source       => 'DEBIT_CARD_OFFSET',
                        p_claim_method       => 'DEBIT_CARD_OFFSET',
                        p_bank_acct_id       => null,
                        p_pay_reason         => 73,
                        p_doc_flag           => 'N',
                        p_insurance_category => null,
                        p_claim_category     => null,
                        p_memo               => null,
                        x_claim_id           => l_claim_id,
                        x_return_status      => l_return_status,
                        x_error_message      => l_error_message
                    );

                    dbms_output.put_line('l_error_message ' || l_error_message);
                    dbms_output.put_line('l_return_status ' || l_return_status);
                    dbms_output.put_line('l_claim_id ' || l_claim_id);
                    if l_return_status <> 'S' then
                        raise_application_error('-20001', l_error_message);
                    else
                        if l_claim_id is not null then
                            insert into payment (
                                change_num,
                                acc_id,
                                pay_date,
                                amount,
                                reason_code,
                                claimn_id,
                                pay_num,
                                note,
                                plan_type,
                                paid_date
                            ) values ( change_seq.nextval,
                                       x.acc_id,
                                       l_plan_end_date,
                                       least(p_offset_amount, l_acc_balance),
                                       73,
                                       l_claim_id,
                                       change_seq.currval,
                                       'Disbursement (Claim ID:'
                                       || l_claim_id
                                       || ') created on '
                                       || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                                       nvl(p_service_type, x.service_type),
                                       sysdate );

                            update claimn
                            set
                                substantiation_reason = 'OFFSET_PREVIOUS_YEAR',
                                source_claim_id = p_claim_id,
                                unsubstantiated_flag = 'N',
                                plan_start_date = l_plan_start_date,
                                plan_end_date = l_plan_end_date,
                                reviewed_date = sysdate,
                                approved_date = sysdate,
                                released_date = sysdate,
                                released_by = p_user_id,
                                payment_release_date = sysdate,
                                payment_released_by = p_user_id,
                                claim_status = 'PAID',
                                last_update_date = sysdate,
                                last_updated_by = p_user_id,
                                claim_paid = least(p_offset_amount, l_acc_balance),
                                approved_amount = least(p_offset_amount, l_acc_balance),
                                claim_pending = 0
                            where
                                claim_id = l_claim_id;

                        end if;
                    end if;

                else
                    raise_application_error('-20001', 'Cannot determine plan year for this plan, Cannot create  ');
                end if;

            end if;

            pc_debit_card.debit_card_offset(
                p_claim_id      => p_claim_id,
                p_amount        => least(p_offset_amount, l_acc_balance),
                p_reason        => 'OFFSET_PREVIOUS_YEAR',
                p_user_id       => p_user_id,
                x_error_message => l_error_message,
                x_return_status => l_return_status
            );

            dbms_output.put_line('l_error_message ' || l_error_message);
            dbms_output.put_line('l_return_status ' || l_return_status);
            if l_return_status <> 'S' then
                raise_application_error('-20001', l_error_message);
            end if;
            update claimn
            set
                note = note
                       || ' *** Offset with manual claim '
                       || l_claim_id
                       || ' on '
                       || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss'),
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = p_claim_id;

        end loop;
    end substantiate_previous_year;

 -- Procedure created by swamy on 10/05/2018 wrt Ticket#5692
-- This entire code is copied from apex screen :204:192, Tab "Recent employer payments" in  button "create payment"
-- The purpose of this procedure is to create a automatic Refund when "Substanciate" button is clicked under path
-- claims=>HRA/FSA claims =>Unsubstantiate Debit claims
    procedure auto_employer_payment (
        p_claim_id            in number,
        p_substantiate_reason in varchar2,
        p_check_amount        in number,
        p_list_bill           in varchar2,
        p_app_user            in number,
        p_acc_num             in varchar2,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is

        cursor cur_get_details is
        select
            c.entrp_id,
            c.service_type,
            a.acc_id,
            p.first_name,
            p.middle_name,
            p.last_name,
            c.claim_date_start,
            c.claim_date_end
        from
            claimn  c,
            account a,
            person  p
        where
                a.pers_id = c.pers_id
            and p.pers_id = c.pers_id
            and a.pers_id = p.pers_id
            and c.claim_id = p_claim_id;

        cursor cur_get_claim (
            vc_acc_id     in account.acc_id%type,
            vc_plan_type  in claimn.service_type%type,
            vc_date_start in date,
            vc_date_end   in date
        ) is
        select
            claim_reimbursed_by
        from
            ben_plan_enrollment_setup
        where
                acc_id = vc_acc_id -- 120376
            and plan_type = vc_plan_type --'fsa'
            and status <> 'R'
            and trunc(plan_start_date) <= trunc(vc_date_start)
            and trunc(plan_end_date) >= trunc(vc_date_end);

        l_return_status  varchar2(1) := 'S';
        l_error_message  varchar2(3200);
        v_acc_id         account.acc_id%type;
        v_claim          ben_plan_enrollment_setup.claim_reimbursed_by%type;
        erreur exception;
        v_er_payment_id  number;
        v_details        cur_get_details%rowtype;
        v_employee_name  varchar2(100);
        l_bank_acct_id   number;
        l_payment_reg_id number;
        l_acc_id         number;
        l_transaction_id number;
        l_bank_account_not_exist exception;
    begin
        pc_log.log_error('pc_claim.auto_employer_payment', null);
        pc_log.log_error('p_claim_id :=', p_claim_id);
        pc_log.log_error('p_Substantiate_reason :=', p_substantiate_reason);
        pc_log.log_error('p_check_amount :=', p_check_amount);
        if
            p_substantiate_reason in ( 'PAYMENT', 'PAYROLL' )
            and p_check_amount > 0
        then
            open cur_get_details;
            fetch cur_get_details into v_details;
            close cur_get_details;
            pc_log.log_error('pc_claim.auto_employer_payment v_details.acc_id :=', v_details.acc_id);
            pc_log.log_error(' v_details.service_type :=', v_details.service_type);
            open cur_get_claim(v_details.acc_id, v_details.service_type, v_details.claim_date_start, v_details.claim_date_end);

            fetch cur_get_claim into v_claim;
            close cur_get_claim;
            pc_log.log_error('pc_claim.auto_employer_payment v_claim :=', v_claim);
            if upper(nvl(v_claim, '*')) = 'EMPLOYER' then
                v_employee_name := v_details.first_name;
                if v_details.middle_name is not null then
                    v_employee_name := v_employee_name
                                       || ' '
                                       || v_details.middle_name;
                end if;

                if v_details.last_name is not null then
                    v_employee_name := v_employee_name
                                       || ' '
                                       || v_details.last_name;
                end if;

                l_bank_acct_id := null;
                l_acc_id := null;
                for x in (
                    select
                        ip.bank_acct_id,
                        a.acc_id
                    from
                        invoice_parameters ip,
                        account            a
                    where
                            entity_type = 'EMPLOYER'
                        and entity_id = v_details.entrp_id
                        and ip.entity_id = a.entrp_id
                        and payment_method = 'DIRECT_DEPOSIT'
                        and autopay = 'Y'
                        and ip.status = 'A'
                        and bank_acct_id is not null
                        and invoice_type = 'CLAIM'
                ) loop
                    l_bank_acct_id := x.bank_acct_id;
                    l_acc_id := x.acc_id;
                end loop;

                pc_log.log_error('pc_claim.auto_employer_payment l_bank_acct_id :=', l_bank_acct_id);
                pc_log.log_error('pc_claim.auto_employer_payment l_acc_id :=', l_acc_id);
                if l_bank_acct_id is not null then
                    insert into employer_payments (
                        employer_payment_id,
                        entrp_id,
                        check_amount,
                        check_number,
                        check_date,
                        creation_date,
                        created_by,
                        note,
                        payment_register_id,
                        reason_code,
                        transaction_date,
                        plan_type,
                        pay_code,
                        memo
                    ) values ( employer_payments_seq.nextval,
                               v_details.entrp_id,
                               p_check_amount,
                               null,
                               sysdate,
                               sysdate,
                               p_app_user,
                               'Refund ACH',
                               null,
                               25,
                               sysdate,
                               v_details.service_type,
                               5,
                               'Refund for  # '
                               || v_employee_name
                               || ' Claim Number # '
                               || p_claim_id ) returning employer_payment_id into v_er_payment_id;

                    pc_log.log_error('	pc_claim.auto_employer_payment calling pc_claim.process_emp_refund', null);

        /* commented by Joshi as the refund to be made by ACH #11698
 		pc_claim.process_emp_refund(  p_entrp_id            => v_details.entrp_id
									, p_pay_code            => 1
									, p_refund_amount       => p_check_amount
									, p_emp_payment_id      => v_er_payment_id
									, p_Substantiate_reason => p_Substantiate_reason
									, x_return_status       => l_return_status
									, x_error_message       => l_error_message);
		if l_return_status <> 'S' then
           pc_log.log_error('	pc_claim.auto_employer_payment error ',l_error_message);
		   raise erreur;
		end if;
        */

                    insert into payment_register (
                        payment_register_id,
                        batch_number,
                        entrp_id,
                        acc_num,
                        provider_name,
                        vendor_id,
                        bank_acct_id,
                        vendor_orig_sys,
                        claim_code,
                        claim_id,
                        trans_date,
                        gl_account,
                        cash_account,
                        claim_amount,
                        note,
                        claim_type,
                        peachtree_interfaced,
                        claim_error_flag,
                        insufficient_fund_flag,
                        memo,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by
                    ) values ( payment_register_seq.nextval,
                               batch_num_seq.nextval,
                               v_details.entrp_id,
                               pc_entrp.get_acc_num(v_details.entrp_id),
                               pc_entrp.get_entrp_name(v_details.entrp_id),
                               null,
                               l_bank_acct_id,
                               pc_entrp.get_acc_num(v_details.entrp_id),
                               substr(
                                   pc_entrp.get_entrp_name(v_details.entrp_id),
                                   1,
                                   4
                               )
                               || v_er_payment_id,
                               null,
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
                               (
                                   select
                                       account_num
                                   from
                                       payment_acc_info
                                   where
                                           substr(account_type, 1, 3) = 'SHA'
                                       and status = 'A'
                               ),
                               p_check_amount,
                               'Refund created on ' || to_char(sysdate, 'MM/DD/RRRR'),
                               'EMPLOYER',
                               'N',
                               'N',
                               'N',
                               pc_entrp.get_entrp_name(v_details.entrp_id),
                               sysdate,
                               p_app_user,
                               sysdate,
                               p_app_user ) returning payment_register_id into l_payment_reg_id;

            -- Insert into ACH_TRANSFER Table.
                    if
                        p_check_amount > 0
                        and nvl(p_substantiate_reason, '*') <> 'PAYROLL'
                    then  
                -- Insert into ACH_TRANSFER Table.
                        pc_ach_transfer.ins_ach_transfer(
                            p_acc_id           => l_acc_id,
                            p_bank_acct_id     => l_bank_acct_id,
                            p_transaction_type => 'D',
                            p_amount           => p_check_amount,
                            p_fee_amount       => 0,
                            p_transaction_date => sysdate,
                            p_reason_code      => 25,
                            p_status           => 2,
                            p_user_id          => p_app_user,
                            p_pay_code         => 5,
                            x_transaction_id   => l_transaction_id,
                            x_return_status    => x_return_status,
                            x_error_message    => x_error_message
                        );

                        update employer_payments
                        set
                            check_number = l_transaction_id,
                            payment_register_id = l_payment_reg_id,
                            bank_acct_id = l_bank_acct_id
                        where
                            employer_payment_id = v_er_payment_id;

                        update ach_transfer
                        set
                            claim_id = l_payment_reg_id,
                            ach_source = 'IN_OFFICE'
                        where
                            transaction_id = l_transaction_id;

                    end if;

                else
                    raise l_bank_account_not_exist;
                end if;

            end if;

        end if;

        x_return_status := l_return_status;
        x_error_message := l_error_message;
    exception
        when l_bank_account_not_exist then
            x_return_status := 'E';
            x_error_message := 'Refund cannot be created as no Employer bank account is associated with the Claim Invoice Type in Invoice Setup'
            ;
        when erreur then
            x_return_status := 'E';
            x_error_message := l_error_message;
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm(sqlcode);
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end auto_employer_payment;

    procedure create_outideinvestment_claim (
        p_acc_id   number,
        p_amount   number,
        p_user_id  number,
        p_claim_id out number
    ) is

        l_vendor_id     number;
        l_batch_number  number;
        l_address       varchar2(100);
        l_city          varchar2(100);
        l_zip           varchar2(10);
        l_acc_num       varchar2(10);
        l_patient_name  varchar2(300);
        l_vendor_name   varchar2(200);
        l_state         varchar2(2);
        l_return_status varchar2(1);
        l_error_message varchar2(4000);
    begin
        l_vendor_name := 'TD Ameritrade';
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');

-- check if vendor exist.
        select
            max(vendor_id)
        into l_vendor_id
        from
            vendors
        where
            lower(vendor_name) like '%ameritrade%'
            and acc_id = p_acc_id;

        select
            p.address,
            p.city,
            p.state,
            p.zip,
            a.acc_num,
            p.last_name
            || ' '
            || p.middle_name
            || ' '
            || p.first_name
        into
            l_address,
            l_city,
            l_state,
            l_zip,
            l_acc_num,
            l_patient_name
        from
            person  p,
            account a
        where
                a.pers_id = p.pers_id
            and a.acc_id = p_acc_id;

        if l_vendor_id is null
           or l_vendor_id = 0 then
            pc_online.create_vendor(
                p_vendor_name         => 'TD Ameritrade',
                p_vendor_acc_num      => l_acc_num,
                p_address             => l_address,
                p_city                => l_city,
                p_state               => l_state,
                p_zipcode             => l_zip,
                p_acc_num             => l_acc_num,
                p_user_id             => p_user_id,
                p_orig_sys_vendor_ref => l_acc_num,
                x_vendor_id           => l_vendor_id,
                x_return_status       => l_return_status,
                x_error_message       => l_error_message
            );

            pc_log.log_error('PC_CLAIM.CREATE_DISBURSEMENT', 'after PC_ONLINE.CREATE_VENDOR '
                                                             || l_return_status
                                                             || ', vendor_id '
                                                             || l_vendor_id);
        end if;

-- create claim FOR OUTISIDE INVESTMENT.
        if l_vendor_id is not null then
            pc_claim.create_new_disbursement(
                p_vendor_id      => l_vendor_id,
                p_provider_name  => 'TD Ameritrade',
                p_address1       => l_address,
                p_address2       => null,
                p_city           => l_city,
                p_state          => l_state,
                p_zipcode        => l_zip,
                p_claim_date     => to_char(sysdate, 'MM/DD/RRRR') --TRUNC(SYSDATE ) -- TO_CHAR(SYSDATE,'MM/DD/YYYY')
                ,
                p_claim_amount   => p_amount,
                p_claim_type     => 'OUTSIDE_INVESTMENT_TRANSFER',
                p_acc_num        => l_acc_num,
                p_note           => null --:P301_NOTE
                ,
                p_dos            => null,
                p_acct_num       => l_acc_num,
                p_patient_name   => l_patient_name,
                p_date_received  => null --TO_DATE(SYSDATE,'MM/DD/RRRR') --TRUNC(SYSDATE ) --TO_DATE(SYSDATE,'MM/DD/YYYY')
                ,
                p_payment_mode   => 'P',
                p_user_id        => p_user_id,
                p_batch_number   => l_batch_number,
                p_termination    => 'N',
                p_reason_code    => 18,
                p_service_status => 2,
                p_claim_source   => 'ONLINE'
            );

            select
                claim_id
            into p_claim_id
            from
                payment_register
            where
                batch_number = l_batch_number;

            if p_claim_id is not null then
                pc_notifications.send_finance_ameritrade_req(l_acc_num, p_claim_id, p_amount);
            end if;

        end if;

    end create_outideinvestment_claim;

-- Added By Jaggi #9775
    function get_trans_fraud_flag (
        p_acc_id in number
    ) return varchar2 is
        l_fraud_flag varchar2(2) default 'N';
        l_event_cnt  number;
        l_bank_cnt   number;
    begin

/* commented by Joshi as discussed with shavee. phone/bank changes need not to be checked.
  FOR X IN (SELECT COUNT(*) Event_cnt
              FROM Event_Notifications
             WHERE Acc_id  = p_acc_id
               AND Event_Name in ('PHONE','EMAIL')
               AND (trunc(creation_date) BETWEEN trunc(sysdate-10) AND trunc(sysdate)
                 OR trunc(last_update_date) BETWEEN trunc(sysdate-10) AND trunc(sysdate)))
  LOOP
    l_Event_cnt := X.Event_cnt;
  END LOOP;

  IF l_event_cnt = 0 THEN
     select count(*) INTO l_event_cnt
       from online_user_security_history
      where user_id  =  ( select o.user_id
                             from online_users o, account a, person p
                            where a.pers_id = p.pers_id
                              and p.ssn = format_ssn(o.tax_id)
                              and a.acc_id = P_ACC_ID )
       AND trunc(creation_date) BETWEEN trunc(sysdate-10) AND trunc(sysdate) ;
   END IF;
 */

        for y in (
            select
                count(*) bank_cnt
            from
                user_bank_acct
            where
                    acc_id = p_acc_id
                and status = 'A'
                and ( trunc(creation_date) between trunc(sysdate - 10) and trunc(sysdate)
                      or trunc(last_update_date) between trunc(sysdate - 10) and trunc(sysdate) )
        ) loop
            l_bank_cnt := y.bank_cnt;
        end loop;

  --IF l_Event_cnt > 0 AND l_Bank_cnt > 0 THEN
        if l_bank_cnt > 0 then
            l_fraud_flag := 'Y';
        end if;
        return l_fraud_flag;
    end get_trans_fraud_flag;

    procedure deny_lsa_disbursement (
        p_claim_id      in number,
        p_claim_status  in varchar2,
        p_denied_reason in varchar2,
        p_user_id       in number,
        p_denied_amount in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        create_error exception;
        l_claim_status varchar2(30);
        l_change_id    number;
    begin
        x_return_status := 'S';
        if nvl(p_denied_reason, '-1') = '-1' then
            x_error_message := 'Denied Reason must be specified ';
            raise create_error;
        end if;

        for x in (
            select
                claim_amount,
                claim_status,
                claim_pending,
                claim_paid,
                pay_reason,
                claim_source
            from
                claimn
            where
                claim_id = p_claim_id
        ) loop
            if
                x.claim_amount <> x.claim_pending
                and x.claim_paid > 0
                and x.claim_status = 'PAID'
            then
                x_error_message := 'Claim is not fully adjusted down to zero, So Adjustment must be done on this claim before attempting to deny it'
                ;
                raise create_error;
            else
                update claimn
                set
                    claim_status = p_claim_status,
                    denied_amount = p_denied_amount --CLAIM_AMOUNT-CLAIM_PAID
                    ,
                    claim_pending = 0 --Added to update the pending amt in case of manual adjustment
                    ,
                    approved_amount = 0,
                    claim_paid = 0,
                    denied_reason = decode(p_denied_reason, '-1', null, p_denied_reason),
                    reviewed_date = sysdate,
                    reviewed_by = p_user_id
                where
                    claim_id = p_claim_id
                returning claim_status into l_claim_status;

                update payment_register
                set
                    cancelled_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    claim_id = p_claim_id;

                pc_log.log_error('PC_CLAIM_DETAIL', 'x.claim_source ' || x.claim_source);
                if x.claim_source = 'ONLINE' then
                    for j in (
                        select
                            c.acc_id,
                            c.check_number
                        from
                            payment_register c
                        where
                            c.claim_id = p_claim_id
                    ) loop
                        l_change_id := j.acc_id || j.check_number;
                    end loop;
                else
                    pc_log.log_error('PC_CLAIM_DETAIL **1 ', 'x.p_claim_id ' || p_claim_id);
                    for k in (
                        select
                            a.change_num
                        from
                            payment a
                        where
                            a.claimn_id = p_claim_id
                    ) loop
                        l_change_id := k.change_num;
                    end loop;

                end if;

                pc_log.log_error('PC_CLAIM_DETAIL', 'x.l_change_id ' || l_change_id);
         /* making the account negative in payment so that if we want to revert we can */
                update balance_register b
                set
                    b.acc_id = - b.acc_id
                where
                    change_id = l_change_id;  --( select c.acc_id||c.check_number from payment_register c where claim_id = p_claim_id);

                update payment
                set
                    claimn_id = - claimn_id
                where
                    claimn_id = p_claim_id;

                if x.pay_reason = 19 then
                    update ach_transfer
                    set
                        status = 9,
                        bankserv_status = 'USER_CANCELLED',
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        claim_id = p_claim_id;

                end if;

                if x.pay_reason in ( 11, 12 ) then
                    update checks
                    set
                        status = 'DENIED'
                    where
                            entity_id = p_claim_id
                        and entity_type = 'LSA_CLAIM';

                end if;

                if
                    p_claim_status = 'DENIED'
                    and p_denied_reason <> 'DUPLICATE_NL'
                then
                    pc_notifications.insert_deny_claim_events(p_claim_id, p_user_id);
                end if;

            end if;
        end loop;

    exception
        when create_error then
            x_return_status := 'E';
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/

    end deny_lsa_disbursement;

-- Added by Joshi for 10320.
    function get_claim_payment_method_for_lsa return varchar2 is
        l_sql          varchar2(3200);
        l_account_type varchar2(20);
    begin
        l_sql := '   SELECT lookup_code,meaning
                     FROM lookups a
                    WHERE lookup_name = ''WEB_REIMBURSEMENT_MODE'' AND lookup_code = ''SUBSCRIBER_ONLINE_ACH''  ';
        return l_sql;
    end get_claim_payment_method_for_lsa;

 -- Added by swamy for Ticket#10399 on 28/09/2021
    procedure process_lsa_disbursement (
        p_claim_id        in number,
        p_claim_status    in varchar2,
        p_approved_amount in number,
        p_denied_amount   in number,
        p_denied_reason   in varchar2,
        p_note            in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_error exception;
        l_claim_status varchar2(30);
    begin
        x_return_status := 'S';
        l_claim_status := p_claim_status;
        if p_approved_amount > 100000 then   -- Added by Swamy for Ticket#9679 by Swamy on 08/04/2021
            x_error_message := 'Claim Amount should not be greater than $1,00,000.00';
            raise l_error;
        end if;
        if p_claim_status in ( 'CANCELLED' ) then
            pc_claim.error_hsa_disbursement(
                p_claim_id      => p_claim_id,
                p_user_id       => p_user_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            if nvl(x_return_status, 'S') <> 'S' then
                raise l_error;
            end if;
        end if;

        if p_claim_status = 'DENIED' then
            pc_claim.deny_lsa_disbursement(
                p_claim_id      => p_claim_id,
                p_claim_status  => p_claim_status,
                p_denied_reason => p_denied_reason,
                p_user_id       => p_user_id,
                p_denied_amount => p_denied_amount,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            if nvl(x_return_status, 'S') <> 'S' then
                raise l_error;
            end if;
        end if;

        if p_claim_status not in ( 'CANCELLED', 'DENIED' ) then
            for x in (
                select
                    claim_amount,
                    claim_status,
                    service_start_date,
                    plan_start_date,
                    plan_end_date,
                    service_type
                from
                    claimn
                where
                    claim_id = p_claim_id
            ) loop
                if
                    p_claim_status in ( 'DENIED', 'ERROR' )
                    and x.claim_status not in ( 'AWAITING_APPROVAL', 'PENDING_DOC', 'PENDING_REVIEW', 'PENDING_OTHER_INSURANCE', 'PENDING_APPROVAL'
                    )
                then
                    x_error_message := 'Cannot deny a claim that has been already processed';
                    raise l_error;
                end if;

                if sign(nvl(p_approved_amount, 0)) = -1 then
                    x_error_message := 'Claim amount cannot be Negative ' || p_approved_amount;
                    raise l_error;
                end if;

                if sign(nvl(p_denied_amount, 0)) = -1 then
                    x_error_message := 'Denied amount cannot be Negative ' || p_denied_amount;
                    raise l_error;
                end if;

                if
                    nvl(p_approved_amount, 0) = 0
                    and nvl(p_denied_amount, 0) <> x.claim_amount
                then
                    x_error_message := 'Denied amount should be equal to claim amount ' || x.claim_amount;
                    raise l_error;
                end if;

                if
                    nvl(p_denied_amount, 0) = 0
                    and nvl(p_approved_amount, 0) <> x.claim_amount
                then
                    x_error_message := 'Approved amount should be equal to claim amount ' || x.claim_amount;
                    raise l_error;
                end if;

            end loop;

            if
                p_denied_amount > 0
                and nvl(p_denied_reason, '-1') = '-1'
            then
                x_error_message := 'Denied Reason must be specified when Claim Status is Denied';
                raise l_error;
            end if;

            update claimn
            set
                claim_status = p_claim_status,
                approved_amount = p_approved_amount,
                denied_amount = p_denied_amount,
                denied_reason = decode(p_denied_reason, '-1', null, p_denied_reason),
                reviewed_date = sysdate,
                approved_date = decode(p_claim_status, 'APPROVED', sysdate, null),
                claim_pending = claim_amount - ( nvl(p_approved_amount, 0) + nvl(p_denied_amount, 0) ),
                reviewed_by = p_user_id,
                claim_paid = 0        -- p_approved_amount replaced with 0 for Ticket#10429
                ,
                note = substr(p_note
                              || ' Reviewed by '
                              || get_user_name(p_user_id),
                              1,
                              4000)
            where
                claim_id = p_claim_id;

            update payment
            set
                amount = p_approved_amount,
                last_updated_date = sysdate,
                last_updated_by = p_user_id
            where
                claimn_id = p_claim_id;

            update checks
            set
                check_amount = p_approved_amount,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    entity_id = p_claim_id
                and entity_type = 'LSA_CLAIM';

   --For partially denied claim, we need to send notifications
            if
                p_claim_status = 'DENIED'
                and p_denied_reason <> 'DUPLICATE_NL'
            then
                pc_notifications.insert_deny_claim_events(p_claim_id, p_user_id);
            elsif p_claim_status = 'APPROVED' then  /* added for Ticket 4286 */
                pc_notifications.insert_approved_claim_events(p_claim_id, p_user_id);
            end if;

        end if;

    exception
        when l_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end process_lsa_disbursement;

 -- Added by swamy for Ticket#10399 on 28/09/2021
    function get_lsa_ach_claim_detail (
        p_trans_from_date in date,
        p_trans_to_date   in date
    ) return ach_claim_t
        pipelined
        deterministic
    is
        l_record ach_claim_row_t;
    begin
        for x in (
            select
                transaction_id,
                a.acc_num,
                b.first_name
                || ' '
                || b.middle_name
                || ' '
                || b.last_name name,
                transaction_date,
                a.total_amount,
                a.acc_id,
                b.pers_id,
                a.error_message,
                c.account_status
                  --, PC_ACCOUNT.ACC_BALANCE(c.ACC_ID) balance
                ,
                d.claim_id,
                a.account_type     -- Added by Swamy for Ticket#9912
                ,
                'PPD'          standard_entry_class_code        -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023  for employee it is PPD
            from
                ach_transfer_v a,
                person         b,
                account        c,
                claimn         d
            where
                    transaction_type = 'D'
                and a.pers_id = b.pers_id
                and a.status in ( 1, 2 )
                and a.acc_id = c.acc_id
                and c.account_type = 'LSA'   -- LSA Added by Swamy for Ticket#9912
                and d.pers_id = b.pers_id
                and c.pers_id = d.pers_id
                and d.claim_status = 'APPROVED'
                and a.claim_id = d.claim_id
                and nvl(trans_fraud_flag, 'N') = 'N'
                and trunc(transaction_date) >= nvl(p_trans_from_date,
                                                   trunc(sysdate))
                and trunc(transaction_date) <= nvl(p_trans_to_date,
                                                   trunc(sysdate))
        ) loop
            l_record.transaction_id := x.transaction_id;
            l_record.acc_num := x.acc_num;
            l_record.name := x.name;
            l_record.transaction_date := x.transaction_date;
            l_record.total_amount := x.total_amount;
            l_record.balance := pc_account.new_acc_balance(x.acc_id);
            l_record.acc_id := x.acc_id;
            l_record.pers_id := x.pers_id;
            l_record.note := x.error_message;
            l_record.account_status := x.account_status;
            l_record.claim_id := x.claim_id;             -- Added By Jaggi #9775
            l_record.account_type := x.account_type;      -- Added by Swamy for Ticket#9912
            l_record.standard_entry_class_code := x.standard_entry_class_code;   -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023

            pipe row ( l_record );
        end loop;
    end get_lsa_ach_claim_detail;

-- Added by Jaggi #10108
    procedure upload_receipts (
        p_receipt_name  in varchar2,
        p_receipt_doc   in blob,
        p_file_type     in varchar2,
        p_mime_type     in varchar2,
        p_user_id       in number,
        p_acc_id        in number,
        p_batch_num     in number,
        x_receipt_id    out varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_receipt_id number;
    begin
        l_receipt_id := receipt_id_seq.nextval;
        insert into claim_receipts (
            receipt_id,
            receipt_name,
            file_type,
            mime_type,
            receipt_doc,
            user_id,
            acc_id,
            batch_num,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( l_receipt_id,
                   p_receipt_name,
                   p_file_type,
                   p_mime_type,
                   p_receipt_doc,
                   p_user_id,
                   p_acc_id,
                   p_batch_num,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id );

        x_receipt_id := l_receipt_id;
        x_return_status := 'S';
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
    end upload_receipts;

    procedure mob_copy_receipts (
        p_claim_id in number,
        p_receipts in pc_online_enrollment.varchar2_tbl,
        p_user_id  in number
    ) is
        l_error_message varchar2(100);
        l_return_status varchar2(100);
    begin
        if p_receipts.count > 0 then
            for i in 1..p_receipts.count loop
                insert into file_attachments (
                    attachment_id,
                    document_name,
                    document_type,
                    attachment,
                    entity_name,
                    entity_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    document_purpose
                )
                    select
                        file_attachments_seq.nextval,
                        receipt_name
                        || '.'
                        || file_type,
                        mime_type,
                        receipt_doc,
                        'CLAIMN',
                        p_claim_id,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        'RECEIPT'
                    from
                        claim_receipts
                    where
                        receipt_id = p_receipts(i);

            end loop;

            if sql%rowcount > 0 then
         -- Delete the claim_receipts data
                mob_delete_receipts(
                    p_receipt_id    => p_receipts,
                    p_user_id       => null,
                    p_employer_id   => null,
                    x_error_message => l_error_message,
                    x_return_status => l_return_status
                );

            end if;

        end if;
    end mob_copy_receipts;

    procedure mob_delete_receipts (
        p_receipt_id    in pc_online_enrollment.varchar2_tbl,
        p_user_id       in number,
        p_employer_id   in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        for i in 1..p_receipt_id.count loop
            delete from claim_receipts
            where
                receipt_id = p_receipt_id(i);

            x_return_status := 'S';
        end loop;
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
    end mob_delete_receipts;

   -- Added by Joshi #10108
    function get_claim_receipts (
        p_user_id in number
    ) return receipt_record_t
        pipelined
        deterministic
    is
        l_record_t receipt_row_t;
    begin
      --pc_log.log_error('P_REPORT_USER_ID==>'||P_REPORT_USER_ID||'  P_USER_ID==>'||P_USER_ID);
        for i in (
            select
                receipt_id,
                replace(receipt_name, ' ', '_') receipt_name,
                receipt_doc,
                creation_date,
                mime_type,
                file_type
            from
                claim_receipts
            where
                user_id = p_user_id
        ) loop
            l_record_t.receipt_id := i.receipt_id;
            l_record_t.receipt_name := i.receipt_name;
            l_record_t.receipt_doc := i.receipt_doc;
            l_record_t.creation_date := i.creation_date;
            l_record_t.mime_type := i.mime_type;
            l_record_t.file_type := i.file_type;
            pipe row ( l_record_t );
        end loop;
    end get_claim_receipts;
  -- Added by Jaggi #10108
    procedure mob_delete_file_attachments (
        p_attachment_id in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        delete from file_attachments
        where
            attachment_id = p_attachment_id;

        x_return_status := 'S';
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
    end mob_delete_file_attachments;

-- Added by Joshi for Ticket#11698)
    procedure process_ach_refund (
        p_transaction_id in number,
        p_note           varchar2,
        p_user_id        in number
    ) is
        l_batch_number varchar2(30);
        l_claim_id     number;
    begin
        pc_log.log_error('PC_CLAIM', 'p_transaction_id ' || p_transaction_id);
        for x in (
            select
                *
            from
                ach_transfer_v
            where
                    transaction_id = p_transaction_id
                and status = 2
        ) loop
            pc_log.log_error('PC_CLAIM', ' x.ACCOUNT_TYPE ' || x.account_type);
            if x.entrp_id is not null then
                update ach_transfer
                set
                    status = 3,
                    claim_id = (
                        select
                            employer_payment_id
                        from
                            employer_payments
                        where
                                check_number = to_char(p_transaction_id)
                            and entrp_id = x.entrp_id
                    ),
                    last_update_date = sysdate,
                    last_updated_by = p_user_id        -- Added by Swamy for Ticket#11556
                where
                    transaction_id = p_transaction_id;

            end if;

        end loop;

    exception
        when others then
           /*pc_log.log_app_error('PC_CLAIM','process_online_hsa_claim',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );*/
            raise;
    end process_ach_refund;

-- Added by Swamy for Ticket#12286 25072024
    function get_service_type (
        p_claim_id in number,
        p_acc_id   in number
    ) return varchar2 is
        l_service_type varchar2(500);
        l_account_type varchar2(500);
    begin
        l_account_type := pc_account.get_account_type(p_acc_id);
        if l_account_type in ( 'FSA', 'HRA' ) then
            for j in (
                select
                    plan_type
                from
                    employer_payments
                where
                    payment_register_id = p_claim_id
            ) loop
                l_service_type := j.plan_type;
            end loop;

        else
            l_service_type := l_account_type;
        end if;

        return nvl(l_service_type, l_account_type);
    end get_service_type;

/* commented by Joshi 12625 
-- Added by Swamy for Ticket#12366
PROCEDURE  process_hsa_refund_Ach(p_entrp_id        IN    NUMBER        
                                , p_pay_code        IN    NUMBER
                                , p_refund_amount   IN    NUMBER
                                , p_emp_payment_id  IN    NUMBER
                                , p_reason_code     IN    VARCHAR2   
                                , p_user_id         IN    NUMBER
                                , x_return_status     OUT VARCHAR2
                                , x_error_message     OUT VARCHAR2)
IS
   l_batch_number        VARCHAR2(30);
   l_vendor_id           NUMBER;
   l_name                VARCHAR2(32000);
   l_address             VARCHAR2(32000);
   l_city                VARCHAR2(32000);
   l_state               VARCHAR2(32000);
   l_zip                 VARCHAR2(32000);
   l_acc_num             VARCHAR2(30);
   l_payment_reg_id      NUMBER;
   l_acc_id              NUMBER;
   l_transaction_id      NUMBER;
   l_bank_acct_id        NUMBER;
   l_account_type        VARCHAR2(30);
   l_error_message       VARCHAR2(300);
   l_erreur              EXCEPTION;
BEGIN
   x_return_status := 'S';
   l_batch_number :=  BATCH_NUM_SEQ.NEXTVAL;

   IF p_entrp_id IS NOT NULL THEN
      SELECT NAME
       , ADDRESS
       , CITY
       , STATE
       , ZIP
       , ACC_NUM
       , ACC_ID
       , account_type 
       INTO  L_NAME,L_ADDRESS,L_CITY,L_STATE,L_ZIP,L_ACC_NUM,L_ACC_ID,l_account_type
       FROM  ENTERPRISE A, ACCOUNT B
      WHERE  A.ENTRP_ID = p_entrp_id
        AND   A.ENTRP_ID = B.ENTRP_ID;
   END IF;

    pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach','p_emp_payment_id '||p_emp_payment_id||' p_entrp_id :='||p_entrp_id||' l_account_type :='||l_account_type);
   IF l_account_type = 'HSA' THEN

    /*
	   FOR X IN ( SELECT VENDOR_ID
					FROM VENDORS
				  WHERE  ACC_NUM = L_ACC_NUM)
	   LOOP
		   L_VENDOR_ID := X.VENDOR_ID;
	   END LOOP;

      IF L_VENDOR_ID IS NULL THEN
		IF L_NAME IS NOT NULL AND L_CITY IS NOT NULL AND L_STATE IS NOT NULL  THEN
		   INSERT INTO VENDORS
			 (VENDOR_ID
			 ,ORIG_SYS_VENDOR_REF
			 ,VENDOR_NAME
			 ,ADDRESS1
			 ,ADDRESS2
			 ,CITY
			 ,STATE
			 ,ZIP
			 ,EXPENSE_ACCOUNT
			 ,ACC_NUM
			 ,ACC_ID
			 ,VENDOR_IN_PEACHTREE
			 ,CREATION_DATE
			 ,CREATED_BY
			 ,LAST_UPDATE_DATE
			 ,LAST_UPDATED_BY)
	      VALUES (VENDOR_SEQ.NEXTVAL
		     , L_ACC_NUM
		     , L_NAME
		     , L_ADDRESS
		     , NULL
		     , L_CITY
		     , L_STATE
		     , L_ZIP
		     , 2400
		     , L_ACC_NUM
		     , L_ACC_ID
		     , 'N'
		     , SYSDATE
		     , 0
		     , SYSDATE
		     , 0) RETURNING VENDOR_ID INTO L_VENDOR_ID;
		ELSE
		  x_error_message := 'Employer /Address information is incomplete, cannot create refund';
		END IF;
      END IF;
      */
     /*
        l_bank_Acct_id := null;

        FOR X IN ( SELECT A.acc_id, u.bank_acct_id 
                          FROM ACCOUNT A, user_bank_acct u
                       WHERE A.entrp_id = p_entrp_id
                           AND A.acc_id = u.acc_id
                           AND u.bank_account_usage = 'ONLINE'
                           AND u.status = 'A')
        LOOP
            l_bank_acct_id := X.bank_acct_id ;
        END LOOP;

        IF l_bank_Acct_id is NULL THEN
           FOR X IN ( SELECT A.acc_id, u.bank_acct_id 
                          FROM ACCOUNT A, user_bank_acct u
                       WHERE A.entrp_id = p_entrp_id
                           AND A.acc_id = u.acc_id
                           AND u.bank_account_usage = 'OFFICE'
                           AND u.status = 'A')
           LOOP
              l_bank_acct_id := X.bank_acct_id ;
           END LOOP;
        END IF; 

       pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach','l_bank_acct_id '||l_bank_acct_id);
       IF l_bank_acct_id IS NOT NULL THEN
          INSERT INTO PAYMENT_REGISTER
                     (PAYMENT_REGISTER_ID
                     ,BATCH_NUMBER
                     ,ENTRP_ID
                     ,ACC_NUM
                     ,PROVIDER_NAME
                     ,VENDOR_ID
                     ,VENDOR_ORIG_SYS
                     ,CLAIM_CODE
                     ,CLAIM_ID
                     ,TRANS_DATE
                     ,GL_ACCOUNT
                     ,CASH_ACCOUNT
                     ,CLAIM_AMOUNT
                     ,NOTE
                     ,CLAIM_TYPE
                     ,PEACHTREE_INTERFACED
                     ,CLAIM_ERROR_FLAG
                     ,INSUFFICIENT_FUND_FLAG
                     ,MEMO
                     ,bank_acct_id     -- Added by Swamy for Ticket#12366
                     ,CREATION_DATE
                     ,CREATED_BY
                     ,LAST_UPDATE_DATE
                     ,LAST_UPDATED_BY   )
           VALUES (PAYMENT_REGISTER_SEQ.NEXTVAL
                    , l_batch_number
                    , p_ENTRP_ID
                    , L_ACC_NUM
                    , L_NAME
                    , L_VENDOR_ID
                    , L_ACC_NUM
                    , SUBSTR(L_NAME,1,4)||p_emp_payment_id
                    , NULL
                    , SYSDATE
                    , (SELECT ACCOUNT_NUM FROM PAYMENT_ACC_INFO WHERE ACCOUNT_TYPE = 'GL_ACCOUNT' AND STATUS = 'A')
                    , (SELECT ACCOUNT_NUM FROM PAYMENT_ACC_INFO WHERE SUBSTR(ACCOUNT_TYPE,1,3) = 'SHA' AND STATUS = 'A')
                    , P_REFUND_AMOUNT
                    , 'Refund created on '||TO_CHAR(SYSDATE,'MM/DD/RRRR')
                    , 'EMPLOYER'
                    , 'N'
                    , 'N'
                    , 'N'
                    , L_NAME
                    ,l_bank_acct_id    -- Added by Swamy for Ticket#12366
                    , SYSDATE
                    , p_user_id
                    , SYSDATE
                    , p_user_id
                     ) RETURNING PAYMENT_REGISTER_ID INTO L_PAYMENT_REG_ID;

          UPDATE EMPLOYER_PAYMENTS
             SET PAYMENT_REGISTER_ID = L_PAYMENT_REG_ID
           WHERE EMPLOYER_PAYMENT_ID = p_emp_payment_id;

           pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach','L_PAYMENT_REG_ID '||L_PAYMENT_REG_ID||' p_emp_payment_id :='||p_emp_payment_id);

		  FOR X IN (SELECT a.payment_register_id
						,C.check_amount
						,D.ACC_ID
				FROM PAYMENT_REGISTER A
				   , EMPLOYER_PAYMENTS C
				   , ACCOUNT D
				WHERE C.EMPLOYER_PAYMENT_ID = p_emp_payment_id
				AND   NVL(A.CANCELLED_FLAG,'N') = 'N'
				AND   NVL(A.CLAIM_ERROR_FLAG,'N') = 'N'
				AND   NVL(A.INSUFFICIENT_FUND_FLAG,'N') = 'N'
				AND   NVL(A.PEACHTREE_INTERFACED,'N') = 'N'
				AND   A.PAYMENT_REGISTER_ID = C.PAYMENT_REGISTER_ID
				AND   A.ACC_NUM = D.ACC_NUM
				AND   A.CLAIM_TYPE = 'EMPLOYER')
		   LOOP
			-- And Cond. added by Swamy for Ticket#5692
			-- When User substantiates, there would be a automatic creation of refund, but for Substantiation reason as PAYROLL,
			-- Check should not be generated. Added condition " and nvl(p_Substantiate_reason,'*') = 'PAYROLL'  "
		   IF X.CHECK_AMOUNT > 0 AND p_reason_code = '25' AND p_pay_code = '5' THEN   
						Pc_ach_transfer.INS_ACH_TRANSFER
												  (p_acc_id             =>  x.acc_id
												  ,p_bank_acct_id      =>  l_BANK_ACCT_ID
												  ,p_transaction_type  => 'D'
												  ,p_amount            => x.check_amount
												  ,p_fee_amount        => 0
												  ,p_transaction_date  => sysdate
												  ,p_reason_code       => p_reason_code
												  ,p_status            => 2
												  ,p_user_id           => p_user_id
												  ,p_pay_code          => p_pay_code
												  ,x_transaction_id    => l_transaction_id
												  ,x_return_status     => x_return_status
												  ,x_error_message     => x_error_message
												);

			    UPDATE ach_transfer
				   SET claim_id = L_PAYMENT_REG_ID
				 WHERE transaction_id = l_transaction_id;

			    UPDATE EMPLOYER_PAYMENTS
			       SET check_number = l_transaction_id
			          ,bank_acct_id = l_BANK_ACCT_ID   -- Added by Swamy for Ticket#12366
			    WHERE  EMPLOYER_PAYMENT_ID = p_emp_payment_id;	   
                pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach','l_transaction_id '||l_transaction_id||' L_PAYMENT_REG_ID :='||L_PAYMENT_REG_ID);
		   END IF;
          END LOOP;
        ELSE
          l_error_message := 'Refund cannot be created as the Employer has no active bank account associated with the usage ONLINE/OFFICE';
          RAISE l_erreur;
        END IF;             
   ELSE
      l_error_message := 'Refund with edeposit can be processed only for HSA';
     RAISE l_erreur;
   END IF;              

EXCEPTION
    WHEN l_erreur THEN
         x_return_status := 'E';
		 x_error_message  := l_error_message ;
           pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach l_erreur','x_error_message '||x_error_message);
    WHEN OTHERS THEN
         x_return_status := 'E';
         x_error_message := SQLERRM;
         pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach others ','SQLERRM '||SQLERRM);
END process_hsa_refund_Ach;
*/

-- Added by Joshi for Ticket#12625 
    procedure process_refund_by_ach (
        p_entrp_id       in number,
        p_pay_code       in number,
        p_refund_amount  in number,
        p_emp_payment_id in number,
        p_bank_acct_id   in number,
        p_reason_code    in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is

        l_batch_number   varchar2(30);
        l_vendor_id      number;
        l_name           varchar2(32000);
        l_address        varchar2(32000);
        l_city           varchar2(32000);
        l_state          varchar2(32000);
        l_zip            varchar2(32000);
        l_acc_num        varchar2(30);
        l_payment_reg_id number;
        l_acc_id         number;
        l_transaction_id number;
        l_bank_acct_id   number;
        l_account_type   varchar2(30);
        l_error_message  varchar2(300);
        l_erreur exception;
    begin
        x_return_status := 'S';
        l_batch_number := batch_num_seq.nextval;
        if p_entrp_id is not null then
            select
                name,
                address,
                city,
                state,
                zip,
                acc_num,
                acc_id,
                account_type
            into
                l_name,
                l_address,
                l_city,
                l_state,
                l_zip,
                l_acc_num,
                l_acc_id,
                l_account_type
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id;

        end if;

        pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach', 'p_emp_payment_id '
                                                            || p_emp_payment_id
                                                            || ' p_entrp_id :='
                                                            || p_entrp_id
                                                            || ' l_account_type :='
                                                            || l_account_type);

        pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach', 'p_bank_Acct_id ' || p_bank_acct_id);
        if p_bank_acct_id is not null then
            insert into payment_register (
                payment_register_id,
                batch_number,
                entrp_id,
                acc_num,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                memo,
                bank_acct_id     -- Added by Swamy for Ticket#12366
                ,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( payment_register_seq.nextval,
                       l_batch_number,
                       p_entrp_id,
                       l_acc_num,
                       l_name,
                       l_vendor_id,
                       l_acc_num,
                       substr(l_name, 1, 4)
                       || p_emp_payment_id,
                       null,
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
                       (
                           select
                               account_num
                           from
                               payment_acc_info
                           where
                                   substr(account_type, 1, 3) = 'SHA'
                               and status = 'A'
                       ),
                       p_refund_amount,
                       'Refund created on ' || to_char(sysdate, 'MM/DD/RRRR'),
                       'EMPLOYER',
                       'N',
                       'N',
                       'N',
                       l_name,
                       p_bank_acct_id    -- Added by Swamy for Ticket#12366
                       ,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id ) returning payment_register_id into l_payment_reg_id;

            update employer_payments
            set
                payment_register_id = l_payment_reg_id
            where
                employer_payment_id = p_emp_payment_id;

            pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach', 'L_PAYMENT_REG_ID '
                                                                || l_payment_reg_id
                                                                || ' p_emp_payment_id :='
                                                                || p_emp_payment_id);
            for x in (
                select
                    a.payment_register_id,
                    c.check_amount,
                    d.acc_id
                from
                    payment_register  a,
                    employer_payments c,
                    account           d
                where
                        c.employer_payment_id = p_emp_payment_id
                    and nvl(a.cancelled_flag, 'N') = 'N'
                    and nvl(a.claim_error_flag, 'N') = 'N'
                    and nvl(a.insufficient_fund_flag, 'N') = 'N'
                    and nvl(a.peachtree_interfaced, 'N') = 'N'
                    and a.payment_register_id = c.payment_register_id
                    and a.acc_num = d.acc_num
                    and a.claim_type = 'EMPLOYER'
            ) loop
                -- And Cond. added by Swamy for Ticket#5692
                -- When User substantiates, there would be a automatic creation of refund, but for Substantiation reason as PAYROLL,
                -- Check should not be generated. Added condition " and nvl(p_Substantiate_reason,'*') = 'PAYROLL'  "
                if
                    x.check_amount > 0
                    and p_reason_code = '25'
                    and p_pay_code = '5'
                then
                    pc_ach_transfer.ins_ach_transfer(
                        p_acc_id           => x.acc_id,
                        p_bank_acct_id     => p_bank_acct_id,
                        p_transaction_type => 'D',
                        p_amount           => x.check_amount,
                        p_fee_amount       => 0,
                        p_transaction_date => sysdate,
                        p_reason_code      => p_reason_code,
                        p_status           => 2,
                        p_user_id          => p_user_id,
                        p_pay_code         => p_pay_code,
                        x_transaction_id   => l_transaction_id,
                        x_return_status    => x_return_status,
                        x_error_message    => x_error_message
                    );

                    update ach_transfer
                    set
                        claim_id = l_payment_reg_id
                    where
                        transaction_id = l_transaction_id;

                    update employer_payments
                    set
                        check_number = l_transaction_id,
                        bank_acct_id = p_bank_acct_id   -- Added by Swamy for Ticket#12366
                    where
                        employer_payment_id = p_emp_payment_id;

                    pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach', 'l_transaction_id '
                                                                        || l_transaction_id
                                                                        || ' L_PAYMENT_REG_ID :='
                                                                        || l_payment_reg_id);
                end if;
            end loop;

        else
            if l_account_type = 'HSA' then
                l_error_message := 'Refund cannot be created as the Employer has no active bank account associated with the usage ONLINE/OFFICE'
                ;
            elsif l_account_type in ( 'HRA', 'FSA' ) then
                l_error_message := 'Refund cannot be created as the Employer has no active bank account associated with the usage CLAIM'
                ;
            else
                l_error_message := 'Refund cannot be created as the Employer has no active bank account associated with the usage ONLINE'
                ;
            end if;

            raise l_erreur;
        end if;             
 --  ELSE
  --    l_error_message := 'Refund with edeposit can be processed only for HSA';
  --   RAISE l_erreur;
  -- END IF;              

    exception
        when l_erreur then
            x_return_status := 'E';
            x_error_message := l_error_message;
            pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach l_erreur', 'x_error_message ' || x_error_message);
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_CLAIM.process_hsa_refund_Ach others ', 'SQLERRM ' || sqlerrm);
    end process_refund_by_ach;

end pc_claim;
/

