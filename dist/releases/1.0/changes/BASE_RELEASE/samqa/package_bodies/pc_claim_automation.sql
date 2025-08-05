-- liquibase formatted sql
-- changeset SAMQA:1754373982125 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_claim_automation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_claim_automation.sql:null:9517a45f672b084fea93af530f9ff5a2f544f6a5:create

create or replace package body samqa.pc_claim_automation as

    procedure batch_release_claim (
        p_entrp_id in number
    ) is
        l_batch_number number;
        l_claim_id_tbl number_tbl := number_tbl();
    begin
        l_batch_number := batch_num_seq.nextval;
        write_claim_log_file('batch_release_claim'
                             || 'l_batch_number '
                             || l_batch_number);
        new_auto_release_claim(p_entrp_id, l_batch_number);
  --   commit;
/*
     write_released_claim_file(l_claim_id_tbl,l_batch_number);
     write_no_claim_inv_setup_file(l_batch_number);
     write_bank_exception_file(l_batch_number);
     write_unreleased_claim_file(l_batch_number);
     write_released_claim_details(l_batch_number);

     IF FILE_EXISTS('claim_report'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR')='TRUE' THEN
           email_files('claim_report'||to_char(sysdate,'mmddyyyy')||'.csv','Claim Report file (Before releasing Claims)');
       END IF;
       IF FILE_EXISTS('claim_error'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR')='TRUE' THEN
          email_files('claim_error'||to_char(sysdate,'mmddyyyy')||'.csv','Claim Error file ');
       END IF;
       IF FILE_EXISTS('released_claim_file_'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR')='TRUE' THEN
          email_files('released_claim_file_'||to_char(sysdate,'mmddyyyy')||'.csv','Released Claim File ');
       END IF;
       IF FILE_EXISTS('claim_unreleased_'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR')='TRUE' THEN
          email_files('claim_unreleased_'||to_char(sysdate,'mmddyyyy')||'.csv','Claim Unreleased file ');
       END IF;
       IF FILE_EXISTS('no_claim_inv_setup'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR')='TRUE' THEN
          email_files('no_claim_inv_setup'||to_char(sysdate,'mmddyyyy')||'.csv','Groups Missing Claim Invoice Setup');
       END IF;
       IF FILE_EXISTS('incorrect_bank_setup'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR')='TRUE' THEN
          email_files('incorrect_bank_setup'||to_char(sysdate,'mmddyyyy')||'.csv','Groups with Inactive/No bank account in Claim Invoice Setup ');
       END IF;
     IF FILE_EXISTS('released_claim_report_'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR')='TRUE' THEN
           email_files('released_claim_report_'||to_char(sysdate,'mmddyyyy')||'.csv','Claim Report file (After releasing Claims)');
       END IF;
*/

        commit;
        for x in (
            select distinct
                entrp_id
            from
                claim_auto_process
            where
                batch_number = l_batch_number
        ) loop
            pc_employer_fin.create_employer_payment(x.entrp_id);
            commit;
        end loop;

    end;

    procedure email_invoiced_claim_file is
    begin
        if file_exists('released_claim_file_'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv',
                       'CLAIM_DIR') = 'TRUE' then
            pc_claim_automation.email_files('released_claim_file_'
                                            || to_char(sysdate, 'mmddyyyy')
                                            || '.csv',
                                            'Released Claim File  ');

        end if;
    end email_invoiced_claim_file;

    procedure auto_release_claim (
        p_entrp_id     in number,
        p_batch_number in number
    ) is

        l_claim_id_tbl          number_tbl := number_tbl();
        l_acc_num_tbl           varchar2_tbl := varchar2_tbl();
        l_entrp_id_tbl          number_tbl := number_tbl();
        l_released_claim_id_tbl number_tbl := number_tbl();
        l_claim_amount_tbl      number_tbl := number_tbl();
        l_er_balance_rem_tbl    number_tbl := number_tbl();
        l_acc_balance_tbl       number_tbl := number_tbl();
        l_invoice_id_tbl        number_tbl := number_tbl();
        l_er_balance_remaining  number := 0;
        l_partial_unrelease_amt number := 0;
        l_unrelease_amt         number := 0;
        l_nsf_amount            number := 0;
        l_return_status         varchar2(3200);
        l_error_message         varchar2(3200);
        l_limit                 number := 500;
        error_code              number := sqlcode;
        l_error_msg             varchar2(500) := sqlerrm;
        l_app_inv_count         number := 0;
        l_error_count           number := 0;
        j                       number := 0;
        ex_dml_errors exception;
        l_employer_balance      number := 0;
        l_remaining_claim       number := 0;
        l_invoice_id            number;
        l_beg_employer_balance  number := 0;
        pragma exception_init ( ex_dml_errors, -24381 );
        cursor c_cursor (
            c_entrp_id     number,
            p_product_type in varchar2
        ) is
        select
            claim_id,
            acc_num,
            entrp_id,
            balance,
            ee_balance
        from
            (
                select
                    x.claim_id,
                    x.acc_num,
                    x.entrp_id,
                    x.balance,
                    x.balance + ( pc_account.new_acc_balance(acc_id, plan_start_date, plan_end_date, 'FSA', service_type) - sum(balance
                    )
                                                                                                                            over(partition
                                                                                                                            by acc_id
                                                                                                                            , plan_start_date
                                                                                                                            , plan_end_date
                                                                                                                            , 'FSA', service_type
                                                                                                                                order
                                                                                                                                by
                                                                                                                                    claim_id
                                                                                                                            ) ) ee_balance
                from
                    (
                        select
                            claim_id,
                            plan_start_date,
                            plan_end_date,
                            service_type,
                            a.pers_id,
                            a.entrp_id,
                            b.acc_id,
                            b.acc_num,
                            pc_lookups.get_meaning(service_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                            least(
                                pc_account.new_acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, 'FSA', a.service_type),
                                (a.approved_amount - nvl(
                                    pc_claim.claim_paid(a.claim_id),
                                    0
                                ))
                            )                                                           balance
                        from
                            claimn  a,
                            account b
                        where
                                a.claim_status = 'APPROVED_FOR_CHEQUE'
                            and a.pers_id = b.pers_id
                            and a.claim_amount > 0
                            and a.entrp_id = c_entrp_id
                            and b.account_type in ( 'HRA', 'FSA' )
                    ) x
                where
                    x.product_type = p_product_type
                order by
                    x.claim_id asc
            )
        where
            balance > 0;

        cursor c_partial_cursor (
            c_entrp_id     number,
            c_er_balance   number,
            p_product_type in varchar2
        ) is
        select
            claim_id,
            acc_num,
            entrp_id,
            balance,
            invoice_id,
            ee_balance
        from
            (
                select
                    x.claim_id,
                    x.acc_num,
                    x.entrp_id--,balance claim_to_be_paid
                    ,
                    x.invoice_id,
                    x.balance,
                    x.balance + ( pc_account.new_acc_balance(acc_id, plan_start_date, plan_end_date, 'FSA', service_type) - sum(balance
                    )
                                                                                                                            over(partition
                                                                                                                            by acc_id
                                                                                                                            , plan_start_date
                                                                                                                            , plan_end_date
                                                                                                                            , 'FSA', service_type
                                                                                                                                order
                                                                                                                                by
                                                                                                                                    claim_id
                                                                                                                            ) ) ee_balance
                from
                    (
                        select
                            claim_id,
                            plan_start_date,
                            plan_end_date,
                            service_type,
                            a.pers_id,
                            a.entrp_id,
                            b.acc_id,
                            b.acc_num,
                            pc_lookups.get_meaning(service_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                            least(
                                pc_account.new_acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, 'FSA', a.service_type),
                                (a.approved_amount - nvl(
                                    pc_claim.claim_paid(a.claim_id),
                                    0
                                ))
                            )                                                           balance,
                            (
                                select
                                    max(ids.invoice_id)
                                from
                                    invoice_distribution_summary ids,
                                    ar_invoice                   ar
                                where
                                        ids.entity_id = a.claim_id
                                    and ids.entity_type = 'CLAIMN'
                                    and ids.invoice_id = ar.invoice_id
                                    and ar.status in ( 'PROCESSED', 'POSTED' )
                            )                                                           invoice_id
                        from
                            claimn  a,
                            account b
                        where
                                a.claim_status = 'APPROVED_FOR_CHEQUE'
                            and a.pers_id = b.pers_id
                            and a.claim_amount > 0
                            and a.entrp_id = c_entrp_id
                            and b.account_type in ( 'HRA', 'FSA' )
                    ) x
                where
                    x.product_type = p_product_type
                order by
                    nvl(x.invoice_id, -1) desc,
                    x.claim_id asc
            )
        where
            balance > 0;

       --   AND   PC_ACCOUNT.ACC_BALANCE(a.ACC_ID, x.PLAN_START_DATE, x.PLAN_END_DATE, a.ACCOUNT_TYPE, x.SERVICE_TYPE) > 0;
    begin
        write_claim_report_file;

       /*  FOR X IN ( SELECT  A.ENTRP_ID,PC_ENTRP.GET_ENTRP_NAME(A.ENTRP_ID) er_name
                       , COUNT(A.CLAIM_ID) NO_OF_CLAIMS
                       ,  SUM(LEAST(NVL(A.APPROVED_AMOUNT-NVL(PC_CLAIM.F_CLAIM_PAID(A.CLAIM_ID),0),0)
                              ,PC_ACCOUNT.NEW_ACC_BALANCE(B.ACC_ID,A.PLAN_START_DATE,A.PLAN_END_DATE,B.ACCOUNT_TYPE, A.SERVICE_TYPE
                                ,A.PLAN_START_DATE,A.PLAN_END_DATE))
                            )  CLAIM_AMOUNT
                       ,  PC_EMPLOYER_FIN.GET_EMPLOYER_BALANCE(A.ENTRP_ID,SYSDATE
                            ,  PC_LOOKUPS.GET_MEANING( A.service_type,'FSA_HRA_PRODUCT_MAP')) EMPLOYER_BALANCE
                       , PC_LOOKUPS.GET_MEANING( A.service_type,'FSA_HRA_PRODUCT_MAP') product_type
                    FROM   CLAIMN A , ACCOUNT B
                     WHERE  A.claim_status = 'APPROVED_FOR_CHEQUE'
                      AND   A.claim_amount > 0 AND A.SERVICE_TYPE IS NOT NULL
                      AND   A.PERS_ID = B.PERS_ID
                     GROUP BY A.ENTRP_ID,PC_LOOKUPS.GET_MEANING( A.service_type,'FSA_HRA_PRODUCT_MAP')
                     ORDER BY A.ENTRP_ID
                 )*/
        for x in (
            select
                entrp_id,
                pc_entrp.get_entrp_name(entrp_id) er_name,
                count(claim_id)                   no_of_claims,
                sum(balance)                      claim_amount,
                product_type
            from
                (
                    select
                        x.claim_id,
                        x.acc_num,
                        x.entrp_id,
                        x.balance,
                        x.balance + ( pc_account.new_acc_balance(acc_id, plan_start_date, plan_end_date, 'FSA', service_type) - sum(balance
                        )
                                                                                                                                over(
                                                                                                                                partition
                                                                                                                                by acc_id
                                                                                                                                , plan_start_date
                                                                                                                                , plan_end_date
                                                                                                                                , 'FSA'
                                                                                                                                , service_type
                                                                                                                                    order
                                                                                                                                    by
                                                                                                                                        claim_id
                                                                                                                                ) )                                                         ee_balance
                                                                                                                                ,
                        pc_lookups.get_meaning(service_type, 'FSA_HRA_PRODUCT_MAP') product_type
                    from
                        (
                            select
                                claim_id,
                                plan_start_date,
                                plan_end_date,
                                service_type,
                                acc_id,
                                a.pers_id,
                                a.entrp_id,
                                b.acc_num,
                                pc_lookups.get_meaning(service_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                                least(
                                    pc_account.new_acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, 'FSA', a.service_type),
                                    (a.approved_amount - nvl(
                                        pc_claim.claim_paid(a.claim_id),
                                        0
                                    ))
                                )                                                           balance
                            from
                                claimn  a,
                                account b
                            where
                                    a.claim_status = 'APPROVED_FOR_CHEQUE'
                                and a.pers_id = b.pers_id
                                and a.claim_amount > 0
                                and a.entrp_id = nvl(p_entrp_id, a.entrp_id)
                                and b.account_type in ( 'HRA', 'FSA' )
                        ) x
                    order by
                        x.claim_id asc
                )
            where
                ee_balance > 0
            group by
                entrp_id,
                product_type
            order by
                entrp_id
        ) loop
            l_beg_employer_balance := 0;
            l_beg_employer_balance := pc_employer_fin.get_employer_balance(x.entrp_id, sysdate + 1, x.product_type);

            write_claim_log_file('auto_release_claim'
                                 || 'Employer Name '
                                 || x.er_name);
            write_claim_log_file('auto_release_claim'
                                 || 'EMPLOYER_BALANCE '
                                 || l_beg_employer_balance);
            write_claim_log_file('auto_release_claim'
                                 || 'CLAIM_AMOUNT '
                                 || x.claim_amount);
            write_claim_log_file('auto_release_claim'
                                 || 'product_type '
                                 || x.product_type);
            l_return_status := 'S';
            if l_beg_employer_balance >= x.claim_amount then
                l_claim_id_tbl := number_tbl();
                l_acc_num_tbl := varchar2_tbl();
                l_entrp_id_tbl := number_tbl();
                l_released_claim_id_tbl := number_tbl();
                l_claim_amount_tbl := number_tbl();
                open c_cursor(x.entrp_id, x.product_type);
                loop
                    fetch c_cursor
                    bulk collect into
                        l_claim_id_tbl,
                        l_acc_num_tbl,
                        l_entrp_id_tbl,
                        l_claim_amount_tbl,
                        l_acc_balance_tbl
                    limit l_limit;
                    write_claim_log_file('auto_release_claim'
                                         || 'No of claims to release'
                                         || l_claim_id_tbl.count);
                    if l_claim_id_tbl.count > 0 then
                        for i in l_claim_id_tbl.first..l_claim_id_tbl.last loop
                            write_claim_log_file('auto_release_claim'
                                                 || 'l_claim_id_tbl('
                                                 || i
                                                 || ')'
                                                 || l_claim_id_tbl(i));

                            pc_claim.process_finance_claim(
                                p_claim_id      => l_claim_id_tbl(i),
                                p_claim_status  => 'READY_TO_PAY',
                                p_user_id       => 0,
                                x_return_status => l_return_status,
                                x_error_message => l_error_message
                            );

                            write_claim_log_file('process_finance_claim'
                                                 || 'l_return_status'
                                                 || l_return_status);
                            write_claim_log_file('process_finance_claim'
                                                 || 'l_error_message'
                                                 || l_error_message);
                            if l_return_status <> 'S' then
                                write_claim_error_file(
                                    l_acc_num_tbl(i),
                                    l_claim_id_tbl(i),
                                    l_error_message
                                );
                            else
                                for xx in (
                                    select
                                        claim_status
                                    from
                                        claimn
                                    where
                                        claim_id = l_claim_id_tbl(i)
                                ) loop
                                    write_claim_log_file('auto_release_claim'
                                                         || 'insert process '
                                                         || l_claim_id_tbl(i));
                                    if xx.claim_status not in ( 'READY_TO_PAY', 'PAID', 'PARTIALLY_PAID' ) then
                                        insert_process(
                                            l_claim_id_tbl(i),
                                            'UNRELEASED',
                                            x.entrp_id,
                                            x.product_type,
                                            l_claim_amount_tbl(i),
                                            l_beg_employer_balance,
                                            xx.claim_status,
                                            p_batch_number
                                        );

                                    else
                                        insert_process(
                                            l_claim_id_tbl(i),
                                            'RELEASED',
                                            x.entrp_id,
                                            x.product_type,
                                            l_claim_amount_tbl(i),
                                            l_beg_employer_balance,
                                            xx.claim_status,
                                            p_batch_number
                                        );
                                    end if;

                                end loop;
                            end if;

                        end loop;
                    end if;

                    exit when c_cursor%notfound;
                end loop;

                close c_cursor;
            elsif
                l_beg_employer_balance > 0
                and l_beg_employer_balance < x.claim_amount
                and x.no_of_claims > 1
            then
                l_claim_id_tbl := number_tbl();
                l_acc_num_tbl := varchar2_tbl();
                l_entrp_id_tbl := number_tbl();
                l_released_claim_id_tbl := number_tbl();
                l_claim_amount_tbl := number_tbl();
                open c_partial_cursor(x.entrp_id, l_beg_employer_balance, x.product_type);
                loop
                    fetch c_partial_cursor
                    bulk collect into
                        l_claim_id_tbl,
                        l_acc_num_tbl,
                        l_entrp_id_tbl,
                        l_claim_amount_tbl,
                        l_invoice_id_tbl,
                        l_acc_balance_tbl
                    limit l_limit;

                    if l_claim_id_tbl.count > 0 then
                        write_claim_log_file('Partial release of claims ');
                        j := 0;
                        l_released_claim_id_tbl := number_tbl();
                        l_remaining_claim := x.claim_amount;
                        l_nsf_amount := 0;
                        l_er_balance_remaining := l_beg_employer_balance;
                        for i in l_claim_id_tbl.first..l_claim_id_tbl.last loop
                           --  pc_employer_fin.CREATE_EMPLOYER_PAYMENT(X.ENTRP_ID,SYSDATE);
                           --  l_er_balance_remaining := PC_EMPLOYER_FIN.GET_EMPLOYER_BALANCE(x.ENTRP_ID,SYSDATE+1,x.product_type) ;

                            write_claim_log_file('****employer balance remaining' || l_er_balance_remaining);
                            write_claim_log_file('****remaining claim ' || l_remaining_claim);
                            write_claim_log_file('****l_claim_id_tbl('
                                                 || i
                                                 || ')'
                                                 || l_claim_id_tbl(i));
                            write_claim_log_file('****claim amount ('
                                                 || i
                                                 || ')'
                                                 || l_claim_amount_tbl(i));
                            write_claim_log_file('****Account Balance ('
                                                 || i
                                                 || ')'
                                                 || l_acc_balance_tbl(i));
                            write_claim_log_file('****Account Number ('
                                                 || i
                                                 || ')'
                                                 || l_acc_num_tbl(i));
                            if
                                l_claim_amount_tbl(i) > 0
                                and l_er_balance_remaining >= l_claim_amount_tbl(i)
                                and l_acc_balance_tbl(i) > 0
                            then
                                write_claim_log_file('partial auto_release_claim'
                                                     || 'releasing claim id '
                                                     || l_claim_id_tbl(i));
                                pc_claim.process_finance_claim(
                                    p_claim_id      => l_claim_id_tbl(i),
                                    p_claim_status  => 'READY_TO_PAY',
                                    p_user_id       => 0,
                                    x_return_status => l_return_status,
                                    x_error_message => l_error_message
                                );

                                if l_return_status <> 'S' then
                                    write_claim_error_file(
                                        l_acc_num_tbl(i),
                                        l_claim_id_tbl(i),
                                        l_error_message
                                    );
                                else
                                    for xx in (
                                        select
                                            claim_status
                                        from
                                            claimn
                                        where
                                            claim_id = l_claim_id_tbl(i)
                                    ) loop
                                        write_claim_log_file('partial auto_release_claim'
                                                             || 'insert process '
                                                             || l_claim_id_tbl(i));
                                        if xx.claim_status not in ( 'READY_TO_PAY', 'PAID', 'PARTIALLY_PAID' ) then
                                            l_nsf_amount := l_nsf_amount + l_claim_amount_tbl(i);
                                            insert_process(
                                                l_claim_id_tbl(i),
                                                'UNRELEASED',
                                                x.entrp_id,
                                                x.product_type,
                                                l_claim_amount_tbl(i),
                                                l_er_balance_remaining,
                                                xx.claim_status,
                                                p_batch_number
                                            );

                                        else
                                            insert_process(
                                                l_claim_id_tbl(i),
                                                'PARTIAL_RELEASE',
                                                x.entrp_id,
                                                x.product_type,
                                                l_claim_amount_tbl(i),
                                                l_er_balance_remaining,
                                                xx.claim_status,
                                                p_batch_number
                                            );
                                        end if;

                                    end loop;
                                end if;

                                l_remaining_claim := l_remaining_claim - l_claim_amount_tbl(i);
                                l_er_balance_remaining := l_er_balance_remaining - l_claim_amount_tbl(i);
                                write_claim_log_file('partial auto_release_claim'
                                                     || 'l_remaining_claim'
                                                     || l_remaining_claim);
                            else
                                write_claim_log_file('partial auto_release_claim'
                                                     || 'insert process '
                                                     || l_claim_id_tbl(i));
                                if l_acc_balance_tbl(i) > 0 then
                                    write_claim_log_file('****Account Number ('
                                                         || i
                                                         || ')'
                                                         || l_acc_num_tbl(i));
                                    write_claim_log_file('****Account Balance ('
                                                         || i
                                                         || ')'
                                                         || l_acc_balance_tbl(i));
                                    write_claim_log_file('****Account Balance ('
                                                         || i
                                                         || ')'
                                                         || l_claim_amount_tbl(i));
                                    insert_process(
                                        l_claim_id_tbl(i),
                                        'UNRELEASED',
                                        x.entrp_id,
                                        x.product_type,
                                        case
                                                when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                    l_claim_amount_tbl(i)
                                                when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                    l_acc_balance_tbl(i)
                                            end,
                                        l_er_balance_remaining,
                                        case
                                                when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                    'APPROVED_FOR_CHEQUE'
                                                when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                    'APPROVED_FOR_CHEQUE'
                                                when l_acc_balance_tbl(i) = 0 then
                                                    'APPROVED_NO_FUNDS'
                                            end,
                                        p_batch_number
                                    );

                                end if;

                            end if;

                        end loop;
                     --   write_unreleased_claim_file(X.ENTRP_ID,l_remaining_claim ,l_er_balance_remaining,X.PRODUCT_TYPE);
                        write_claim_log_file('write released claim ' || l_released_claim_id_tbl.count);
                    end if;

                    exit when c_partial_cursor%notfound;
                end loop;

                close c_partial_cursor;
            else
                open c_cursor(x.entrp_id, x.product_type);
                loop
                    fetch c_cursor
                    bulk collect into
                        l_claim_id_tbl,
                        l_acc_num_tbl,
                        l_entrp_id_tbl,
                        l_claim_amount_tbl,
                        l_acc_balance_tbl
                    limit l_limit;
                    if l_claim_id_tbl.count > 0 then
                        for i in l_claim_id_tbl.first..l_claim_id_tbl.last loop
                            if l_acc_balance_tbl(i) > 0 then
                                write_claim_log_file('****Account Number ('
                                                     || i
                                                     || ')'
                                                     || l_acc_num_tbl(i));
                                write_claim_log_file('****Account Balance ('
                                                     || i
                                                     || ')'
                                                     || l_acc_balance_tbl(i));
                                write_claim_log_file('****Claim Amount ('
                                                     || i
                                                     || ')'
                                                     || l_claim_amount_tbl(i));
                                insert_process(
                                    l_claim_id_tbl(i),
                                    'UNRELEASED',
                                    x.entrp_id,
                                    x.product_type,
                                    case
                                            when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                l_claim_amount_tbl(i)
                                            when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                l_acc_balance_tbl(i)
                                        end,
                                    l_beg_employer_balance,
                                    case
                                            when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                'APPROVED_FOR_CHEQUE'
                                            when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                'APPROVED_FOR_CHEQUE'
                                            when l_acc_balance_tbl(i) = 0 then
                                                'APPROVED_NO_FUNDS'
                                        end,
                                    p_batch_number
                                );

                            end if;
                        end loop;

                    end if;

                    exit when c_cursor%notfound;
                end loop;

                close c_cursor;
               --write_unreleased_claim_file(X.ENTRP_ID,X.CLAIM_AMOUNT ,X.EMPLOYER_BALANCE,X.PRODUCT_TYPE);

            end if;

            l_invoice_id := null;
            select
                count(*)
            into l_app_inv_count
            from
                ar_invoice
            where
                    entity_id = x.entrp_id
                and ( plan_type is null
                      or plan_type = x.product_type )
                and entity_type = 'EMPLOYER'
                and status = 'PROCESSED'
                and invoice_reason = 'CLAIM';
          -- Vanitha: Pay what we invoice enhancements
           -- AND STATUS IN ('PROCESSED','PARTIALLY_POSTED') and INVOICE_REASON = 'CLAIM';
            if l_app_inv_count = 0 then
         --  pc_employer_fin.CREATE_EMPLOYER_PAYMENT(X.ENTRP_ID,SYSDATE);
                pc_invoice.generate_claim_invoice(
                    p_start_date    => sysdate,
                    p_end_date      => sysdate,
                    p_billing_date  => sysdate,
                    p_entrp_id      => x.entrp_id,
                    p_product_type  => x.product_type,
                    x_error_status  => l_return_status,
                    x_error_message => l_error_message
                );

                if l_return_status <> 'S' then
                    write_claim_error_file(null, null, ' Error creating invoice '
                                                       || l_error_message
                                                       || ' for entrp_id '
                                                       || x.entrp_id);

                end if;

            else
                update claim_auto_process
                set
                    process_status = 'INV_OUTSTANDING'
                where
                        batch_number = p_batch_number
                    and claim_status in ( 'APPROVED_FOR_CHEQUE' )
                    and invoice_status = 'NOT_PROCESSED'
                    and entrp_id = x.entrp_id
                    and product_type = x.product_type;

            end if;

        end loop;

    exception
        when others then
            write_claim_error_file(null, null, ' auto release claim : Message: ' || sqlerrm());

          --COMMIT;
    end auto_release_claim;

    procedure write_claim_log_file (
        p_message in varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'claim_log'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'a');

        l_line := p_message;
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        utl_file.fclose(file => l_utl_id);
    end write_claim_log_file;

    procedure write_claim_error_file (
        p_acc_num  in varchar2,
        p_claim_id in number,
        p_message  in varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'claim_error'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'w');

        if file_exists('claim_error'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv',
                       'CLAIM_DIR') = 'TRUE' then
            null;
        else
            l_line := 'Claim Id,Account Number, Error Message';
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        l_line := p_claim_id
                  || ','
                  || p_claim_id
                  || ','
                  || p_message;
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        utl_file.fclose(file => l_utl_id);
    end write_claim_error_file;

    procedure write_claim_report_file is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'claim_report'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'w');
       /*  IF FILE_EXISTS('claim_report'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR') = 'TRUE' THEN
             NULL;
         ELSE*/
        l_line := 'Claim Id,Employee Name,Account Number,Employer Name,Employer Account Number,Account Balance,'
                  || 'Provider Name,Claim Amount,Deductible Amount,Approved Amount,Denied Amount,Payment Amount,'
                  || 'Plan Start Date, Plan End Date, Reimbursement Method,'
                  || 'Claim Status,Service Start Date,Service Type,Reviewed Date';
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );

      --   END IF;

        for x in (
            select
                a.claim_id,
                pc_person.get_person_name(a.pers_id)                                                                 person_name,
                pc_person.get_entrp_name(a.pers_id)                                                                  employer_name,
                pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance,
                a.prov_name,
                a.claim_amount,
                a.denied_amount,
                pc_lookups.get_reason_name(d.pay_reason)                                                             reimbursement_method
                ,
                pc_lookups.get_claim_status(a.claim_status)                                                          claim_status,
                a.service_start_date,
                a.service_type,
                a.reviewed_date,
                a.doc_flag,
                a.approved_amount,
                a.deductible_amount,
                to_char(a.plan_start_date, 'MM/DD/YYYY')                                                             plan_start_date,
                to_char(a.plan_end_date, 'MM/DD/YYYY')                                                               plan_end_date,
                least(
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type),
                    (a.approved_amount - nvl(
                        pc_claim.claim_paid(a.claim_id),
                        0
                    ))
                )                                                                                                    balance,
                b.acc_num,
                d.claim_type,
                a.pers_id,
                b.acc_id
            from
                claimn           a,
                account          b,
                payment_register d
            where
                    claim_status = 'APPROVED_FOR_CHEQUE'
                and a.pers_id = b.pers_id
                and d.claim_id = a.claim_id
                and d.acc_num = b.acc_num
                and a.claim_amount > 0
                and a.entrp_id is not null
                and nvl(a.takeover, 'N') = 'N'
            order by
                a.entrp_id
        ) loop
            l_line := x.claim_id
                      || ',"'
                      || x.person_name
                      || '","'
                      || x.acc_num
                      || '","'
                      || x.employer_name
                      || '",'
                      || x.er_acc_num
                      || ',"'
                      || x.account_balance
                      || '","'
                      || x.prov_name
                      || '",'
                      || x.claim_amount
                      || ','
                      || x.deductible_amount
                      || ','
                      || x.approved_amount
                      || ','
                      || x.denied_amount
                      || ','
                      || x.balance
                      || ','
                      || x.plan_start_date
                      || ','
                      || x.plan_end_date
                      || ','
                      || x.reimbursement_method
                      || ','
                      || x.claim_status
                      || ','
                      || to_char(x.service_start_date, 'MM/DD/YYYY')
                      || ','
                      || x.service_type
                      || ','
                      || to_char(x.reviewed_date, 'MM/DD/YYYY');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_claim_report_file;
 /*  PROCEDURE write_unreleased_claim_file (p_entrp_id IN NUMBER, p_claim_amount IN NUMBER
   , p_er_balance IN NUMBER,p_product_type IN VARCHAR2,p_batch_number IN NUMBER)*/
    procedure write_unreleased_claim_file (
        p_batch_number in number
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        if file_exists('claim_unreleased_'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv',
                       'CLAIM_DIR') = 'TRUE' then
            null;
        else
            l_line := 'Employer Name,Account Number,Employer Balance, Invoice #,Invoice Amount,Product Type';
        end if;

        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'claim_unreleased_'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'a');

        if l_line is not null then
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for x in (
            select
                pc_entrp.get_entrp_name(a.entrp_id)                                         entrp_name,
                b.acc_num,
                pc_employer_fin.get_employer_balance(a.entrp_id, sysdate + 1, product_type) er_balance,
                claim_amount,
                product_type,
                invoice_id
            from
                (
                    select
                        a.entrp_id,
                        a.product_type,
                        sum(a.payment_amount) claim_amount,
                        a.invoice_id
                    from
                        claim_auto_process a,
                        claimn             b
                    where
                            a.process_status = 'UNRELEASED'
                        and a.claim_status <> 'APPROVED_NO_FUNDS'
                        and a.batch_number = p_batch_number
                        and a.claim_id = b.claim_id
                        and nvl(b.takeover, 'N') = 'N'
                    group by
                        a.entrp_id,
                        a.product_type,
                        a.invoice_id
                )       a,
                account b
            where
                a.entrp_id = b.entrp_id
        ) loop
            l_line := '"'
                      || x.entrp_name
                      || '",'
                      || x.acc_num
                      || ','
                      || x.er_balance
                      || ','
                      || x.invoice_id
                      || ','
                      || x.claim_amount
                      || ','
                      || x.invoice_id
                      || ','
                      || x.product_type;

     --  l_line := '"'||pc_entrp.get_entrp_name(p_entrp_id)||'",'||pc_entrp.get_acc_num(p_entrp_id)||','||p_er_balance||','||p_claim_amount||','||p_product_type;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_unreleased_claim_file;

    procedure write_invoiced_claim_file (
        p_invoice_id in number
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
         /*    IF FILE_EXISTS('invoiced_claim_file_'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR') = 'TRUE' THEN
                NULL;
             ELSE
                     l_line :='Employer Name,Employer Balance,Account Number,Plan Type,Payment Method,Claim #,Invoice #,Invoiced Amount,Transaction #'||
                              ',Paid Amount, Paid Date,Release Status';
             END IF;

             l_utl_id := utl_file.fopen( 'CLAIM_DIR', 'invoiced_claim_file_'||to_char(sysdate,'mmddyyyy')||'.csv', 'a' );
             IF l_line IS NOT NULL THEN
                UTL_FILE.PUT_LINE( file => l_utl_id , buffer => l_line);
             END IF;
             FOR x IN (SELECT  pc_entrp.get_entrp_name(b.entrp_id) entrp_name,
                         c.acc_num,b.service_type, a.claim_id, a.invoice_id
                       , a.payment_amount invoiced_amount
                       , nvl(a.transaction_id,a.change_num) transaction_id
                       , CASE WHEN a.transaction_id IS NOT NULL THEN 'ACH'
                              WHEN A.CHANGE_NUM IS NOT NULL THEN 'CHECK'
                              ELSE '' END PAYMENT_METHOD
                       , a.paid_amount, a.pay_date
                       , decode(a.POSTING_STATUS, 'NOT_POSTED','Not Paid','POSTED','Paid') RELEASE_STATUS
                       , PC_EMPLOYER_FIN.GET_EMPLOYER_BALANCE(b.ENTRP_ID,SYSDATE+1
                                       ,PC_LOOKUPS.GET_MEANING( b.service_type,'FSA_HRA_PRODUCT_MAP')) EMPLOYER_BALANCE
                 FROM claim_invoice_posting a, claimn b,account c
                 WHERE  a.claim_id= b.claim_id
                  AND   b.pers_id = c.pers_id
                  AND   a.invoice_id = p_invoice_id)

             LOOP
                l_line := '"'||X.entrp_name||'",'||x.employer_balance||',"'||X.acc_num||'",'||X.service_type||','||x.payment_method||','||X.claim_id||','
                ||x.invoice_id||','||x.invoiced_amount||','||x.transaction_id||','
                ||x.paid_amount||','||x.pay_date||','||x.release_status;

                UTL_FILE.PUT_LINE( file => l_utl_id , buffer => l_line);
             END LOOP;
             UTL_FILE.FCLOSE(file => l_utl_id);
             */

        if file_exists('released_claim_file_'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv',
                       'CLAIM_DIR') = 'TRUE' then
            null;
        else
            l_line := 'Claim Id,Employee Name,Account Number,Employer Name,Employer Account Number,Account Balance,'
                      || 'Provider Name,Claim Amount,Deductible Amount,Approved Amount,Denied Amount,Payment Amount,Check/ACH #,'
                      || 'Plan Start Date, Plan End Date, Reimbursement Method,'
                      || 'Claim Status,Service Start Date,Service Type,Reviewed Date';
        end if;

        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'released_claim_file_'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'a');

        if l_line is not null then
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for xx in (
            select
                claim_id
            from
                claim_invoice_posting
            where
                invoice_id = p_invoice_id
        ) loop
            write_claim_log_file('write released claim ' || xx.claim_id);
            for x in (
                select
                    a.claim_id,
                    pc_person.get_person_name(a.pers_id)                                                                 person_name,
                    pc_person.get_entrp_name(a.pers_id)                                                                  employer_name
                    ,
                    pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance
                    ,
                    a.prov_name,
                    a.claim_amount,
                    a.denied_amount,
                    pc_lookups.get_reason_name(d.pay_reason)                                                             reimbursement_method
                    ,
                    pc_lookups.get_claim_status(a.claim_status)                                                          claim_status
                    ,
                    a.claim_status                                                                                       claim_status_code
                    ,
                    a.service_start_date,
                    a.service_type,
                    a.reviewed_date,
                    a.doc_flag,
                    a.approved_amount,
                    a.deductible_amount,
                    a.plan_start_date                                                                                    plan_start_date
                    ,
                    a.plan_end_date                                                                                      plan_end_date
                    ,
                    n.amount                                                                                             balance,
                    b.acc_num,
                    d.claim_type,
                    a.pers_id,
                    b.acc_id,
                    n.change_num,
                    n.reason_code,
                    ck.check_number
                from
                    claimn           a,
                    account          b,
                    payment_register d,
                    payment          n,
                    checks           ck
                where
                        a.claim_id = xx.claim_id
                    and a.pers_id = b.pers_id
                    and d.claim_id = a.claim_id
                    and a.claim_id = n.claimn_id
                    and b.acc_id = n.acc_id
                    and trunc(ck.check_date) >= trunc(sysdate)
                    and trunc(n.creation_date) >= trunc(sysdate)
                    and ck.entity_type = 'CLAIMN'
                    and ck.status = 'READY'
                    and ck.entity_id = a.claim_id
                    and d.acc_num = b.acc_num
                    and a.claim_amount > 0
                union
                select
                    a.claim_id,
                    pc_person.get_person_name(a.pers_id)                                                                 person_name,
                    pc_person.get_entrp_name(a.pers_id)                                                                  employer_name
                    ,
                    pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance
                    ,
                    a.prov_name,
                    a.claim_amount,
                    a.denied_amount,
                    pc_lookups.get_reason_name(d.pay_reason)                                                             reimbursement_method
                    ,
                    pc_lookups.get_claim_status(a.claim_status)                                                          claim_status
                    ,
                    a.claim_status                                                                                       claim_status_code
                    ,
                    a.service_start_date,
                    a.service_type,
                    a.reviewed_date,
                    a.doc_flag,
                    a.approved_amount,
                    a.deductible_amount,
                    a.plan_start_date                                                                                    plan_start_date
                    ,
                    a.plan_end_date                                                                                      plan_end_date
                    ,
                    n.total_amount                                                                                       balance,
                    b.acc_num,
                    d.claim_type,
                    a.pers_id,
                    b.acc_id,
                    n.transaction_id,
                    d.pay_reason,
                    to_char(n.transaction_id)
                from
                    claimn           a,
                    account          b,
                    payment_register d,
                    ach_transfer     n
                where
                        a.claim_id = xx.claim_id -- p_claim_id_tbl(i)
                    and a.pers_id = b.pers_id
                    and d.claim_id = a.claim_id
                    and a.claim_id = n.claim_id
                    and b.acc_id = n.acc_id
                    and d.acc_num = b.acc_num
                    and a.claim_amount > 0
                    and n.status in ( 1, 2 )
                    and trunc(n.transaction_date) >= trunc(sysdate)
            ) loop
                l_line := x.claim_id
                          || ',"'
                          || x.person_name
                          || '","'
                          || x.acc_num
                          || '","'
                          || x.employer_name
                          || '",'
                          || x.er_acc_num
                          || ',"'
                          || x.account_balance
                          || '","'
                          || x.prov_name
                          || '",'
                          || x.claim_amount
                          || ','
                          || x.deductible_amount
                          || ','
                          || x.approved_amount
                          || ','
                          || x.denied_amount
                          || ','
                          || x.balance
                          || ','
                          || x.check_number
                          || ','
                          || to_char(x.plan_start_date, 'MM/DD/YYYY')
                          || ','
                          || to_char(x.plan_end_date, 'MM/DD/YYYY')
                          || ','
                          || x.reimbursement_method
                          || ','
                          || x.claim_status
                          || ','
                          || to_char(x.service_start_date, 'MM/DD/YYYY')
                          || ','
                          || x.service_type
                          || ','
                          || to_char(x.reviewed_date, 'MM/DD/YYYY');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

        end loop;

        utl_file.fclose(file => l_utl_id);
           --  email_invoiced_claim_file;
    end write_invoiced_claim_file;

    procedure write_released_claim_file (
        p_claim_id_tbl in number_tbl,
        p_batch_number in number
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        if file_exists('released_claim_file_'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv',
                       'CLAIM_DIR') = 'TRUE' then
            null;
        else
            l_line := 'Claim Id,Employee Name,Account Number,Employer Name,Employer Account Number,Account Balance,'
                      || 'Provider Name,Claim Amount,Deductible Amount,Approved Amount,Denied Amount,Payment Amount,Check/ACH #,'
                      || 'Plan Start Date, Plan End Date, Reimbursement Method,'
                      || 'Claim Status,Service Start Date,Service Type,Reviewed Date';
        end if;

        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'released_claim_file_'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'a');

        if l_line is not null then
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for xx in (
            select
                claim_id
            from
                claim_auto_process
            where
                    process_status <> 'UNRELEASED'
                and batch_number = p_batch_number
        ) loop
            write_claim_log_file('write released claim ' || xx.claim_id);
            for x in (
                select
                    a.claim_id,
                    pc_person.get_person_name(a.pers_id)                                                                 person_name,
                    pc_person.get_entrp_name(a.pers_id)                                                                  employer_name
                    ,
                    pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance
                    ,
                    a.prov_name,
                    a.claim_amount,
                    a.denied_amount,
                    pc_lookups.get_reason_name(d.pay_reason)                                                             reimbursement_method
                    ,
                    pc_lookups.get_claim_status(a.claim_status)                                                          claim_status
                    ,
                    a.claim_status                                                                                       claim_status_code
                    ,
                    a.service_start_date,
                    a.service_type,
                    a.reviewed_date,
                    a.doc_flag,
                    a.approved_amount,
                    a.deductible_amount,
                    a.plan_start_date                                                                                    plan_start_date
                    ,
                    a.plan_end_date                                                                                      plan_end_date
                    ,
                    n.amount                                                                                             balance,
                    b.acc_num,
                    d.claim_type,
                    a.pers_id,
                    b.acc_id,
                    n.change_num,
                    n.reason_code,
                    ck.check_number
                from
                    claimn           a,
                    account          b,
                    payment_register d,
                    payment          n,
                    checks           ck
                where
                        a.claim_id = xx.claim_id
                    and a.pers_id = b.pers_id
                    and d.claim_id = a.claim_id
                    and a.claim_id = n.claimn_id
                    and b.acc_id = n.acc_id
                    and trunc(ck.check_date) >= trunc(sysdate)
                    and trunc(n.creation_date) >= trunc(sysdate)
                    and ck.entity_type = 'CLAIMN'
                    and ck.status = 'READY'
                    and ck.entity_id = a.claim_id
                    and d.acc_num = b.acc_num
                    and a.claim_amount > 0
                union
                select
                    a.claim_id,
                    pc_person.get_person_name(a.pers_id)                                                                 person_name,
                    pc_person.get_entrp_name(a.pers_id)                                                                  employer_name
                    ,
                    pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance
                    ,
                    a.prov_name,
                    a.claim_amount,
                    a.denied_amount,
                    pc_lookups.get_reason_name(d.pay_reason)                                                             reimbursement_method
                    ,
                    pc_lookups.get_claim_status(a.claim_status)                                                          claim_status
                    ,
                    a.claim_status                                                                                       claim_status_code
                    ,
                    a.service_start_date,
                    a.service_type,
                    a.reviewed_date,
                    a.doc_flag,
                    a.approved_amount,
                    a.deductible_amount,
                    a.plan_start_date                                                                                    plan_start_date
                    ,
                    a.plan_end_date                                                                                      plan_end_date
                    ,
                    n.total_amount                                                                                       balance,
                    b.acc_num,
                    d.claim_type,
                    a.pers_id,
                    b.acc_id,
                    n.transaction_id,
                    d.pay_reason,
                    to_char(n.transaction_id)
                from
                    claimn           a,
                    account          b,
                    payment_register d,
                    ach_transfer     n
                where
                        a.claim_id = xx.claim_id -- p_claim_id_tbl(i)
                    and a.pers_id = b.pers_id
                    and d.claim_id = a.claim_id
                    and a.claim_id = n.claim_id
                    and b.acc_id = n.acc_id
                    and d.acc_num = b.acc_num
                    and a.claim_amount > 0
                    and n.status in ( 1, 2 )
                    and trunc(n.transaction_date) >= trunc(sysdate)
            ) loop
                update claim_invoice_posting
                set
                    change_num =
                        case
                            when x.reason_code in ( 11, 12 ) then
                                x.change_num
                            else
                                null
                        end,
                    transaction_id =
                        case
                            when x.reason_code = 19 then
                                x.change_num
                            else
                                null
                        end,
                    paid_amount = x.balance,
                    payment_status = x.claim_status_code,
                    posting_status = 'POSTED',
                    pay_date = sysdate
                where
                        claim_id = x.claim_id
                    and posting_status = 'NOT_POSTED'
                    and change_num is null
                    and transaction_id is null
                    and payment_status is null;

                l_line := x.claim_id
                          || ',"'
                          || x.person_name
                          || '","'
                          || x.acc_num
                          || '","'
                          || x.employer_name
                          || '",'
                          || x.er_acc_num
                          || ',"'
                          || x.account_balance
                          || '","'
                          || x.prov_name
                          || '",'
                          || x.claim_amount
                          || ','
                          || x.deductible_amount
                          || ','
                          || x.approved_amount
                          || ','
                          || x.denied_amount
                          || ','
                          || x.balance
                          || ','
                          || x.check_number
                          || ','
                          || to_char(x.plan_start_date, 'MM/DD/YYYY')
                          || ','
                          || to_char(x.plan_end_date, 'MM/DD/YYYY')
                          || ','
                          || x.reimbursement_method
                          || ','
                          || x.claim_status
                          || ','
                          || to_char(x.service_start_date, 'MM/DD/YYYY')
                          || ','
                          || x.service_type
                          || ','
                          || to_char(x.reviewed_date, 'MM/DD/YYYY');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_released_claim_file;

    procedure email_files (
        p_file_name    in varchar2,
        p_report_title in varchar2
    ) is
        l_html_message varchar2(3000);
        l_email        varchar2(4000);
    begin
        l_html_message := '<html>
          <head>
          <title>'
                          || p_report_title
                          || '</title>
          </head>
          <body bgcolor="#FFFFFF" link="#000080">
           <table cellspacing="0" cellpadding="0" width="100%">
           <tr align="LEFT" valign="BASELINE">
           <td width="100%" valign="middle">'
                          || p_report_title
                          || '</td>
           </table>
        </body>
        </html>';
        for x in (
            select -- wm_concat(email)   EMAIL
                listagg(email, ',') within group(
                order by
                    email
                ) email  -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
            from
                sam_users a,
                employee  b
            where
                    contract_user = 'Y'
                and a.status = 'A'
                and a.user_id not in ( 4261, 4461 )
                and a.user_id = b.user_id
        ) loop
            l_email := x.email;
        end loop;

        l_email := nvl(l_email || ',', '')
                   || 'techsupport@sterlingadministration.com'
                   || case
            when p_file_name like 'claim_approval%' then
                ',finance.department@sterlingadministration.com'
            when p_file_name like 'released%' then
                ',finance.department@sterlingadministration.com'
            else ''
        end;

        dbms_output.put_line('email ' || l_email);
        pc_notifications.insert_reports(p_report_title, '/u01/app/oracle/oradata/claim/', p_file_name, null, l_html_message);
        mail_utility.email_files(
            from_name    => 'oracle@sterlingadministration.com',
            to_names     => l_email,
            subject      => p_report_title,
            html_message => l_html_message,
            attach       => samfiles('/u01/app/oracle/oradata/claim/' || p_file_name)
        );

    end email_files;

    procedure write_no_claim_inv_setup_file (
        p_batch_number in number
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'no_claim_inv_setup'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'w');
       /*  IF FILE_EXISTS('claim_report'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR') = 'TRUE' THEN
             NULL;
         ELSE*/
        l_line := 'Employer Name,Employer Account Number';
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );

      --   END IF;

        for x in (
            select distinct
                pc_entrp.get_entrp_name(a.entrp_id) entrp_name,
                pc_entrp.get_acc_num(a.entrp_id)    acc_num
            from
                claim_auto_process a,
                claimn             b
            where
                    a.batch_number = p_batch_number
                and a.claim_status in ( 'APPROVED_FOR_CHEQUE' )
                and a.invoice_status = 'NOT_PROCESSED'
                and a.process_status = 'UNRELEASED'
                and a.invoice_id is null
                and a.claim_id = b.claim_id
                and nvl(b.takeover, 'N') = 'N'
        ) loop
            l_line := '"'
                      || x.entrp_name
                      || '",'
                      || x.acc_num;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_no_claim_inv_setup_file;

    procedure write_bank_exception_file (
        p_batch_number in number
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'incorrect_bank_setup'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'w');
       /*  IF FILE_EXISTS('claim_report'||to_char(sysdate,'mmddyyyy')||'.csv','CLAIM_DIR') = 'TRUE' THEN
             NULL;
         ELSE*/
        l_line := 'Employer Name,Employer Account Number';
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );

      --   END IF;

        for x in (
            select distinct
                pc_entrp.get_entrp_name(a.entrp_id) entrp_name,
                pc_entrp.get_acc_num(a.entrp_id)    acc_num
            from
                claim_auto_process a,
                ar_invoice         b
            where
                    a.batch_number = p_batch_number
                and a.claim_status in ( 'APPROVED_FOR_CHEQUE' )
                and a.process_status = 'UNRELEASED'
                and a.invoice_id = b.invoice_id
                and b.payment_method = 'DIRECT_DEPOSIT'
                and b.bank_acct_id is null
            union
            select distinct
                pc_entrp.get_entrp_name(a.entrp_id) entrp_name,
                pc_entrp.get_acc_num(a.entrp_id)    acc_num
            from
                claim_auto_process a,
                ar_invoice         b,
                user_bank_acct     c
            where
                    a.batch_number = p_batch_number
                and a.claim_status in ( 'APPROVED_FOR_CHEQUE' )
                and a.process_status = 'UNRELEASED'
                and a.invoice_id = b.invoice_id
                and b.payment_method = 'DIRECT_DEPOSIT'
                and b.bank_acct_id = c.bank_acct_id
                and c.status = 'I'
        ) loop
            l_line := '"'
                      || x.entrp_name
                      || '",'
                      || x.acc_num;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_bank_exception_file;

    procedure insert_process (
        p_claim_id       in number,
        p_process_status in varchar2,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_pay_amount     in number,
        p_er_balance     in number,
        p_claim_status   in varchar2,
        p_batch_number   in number
    ) is
    begin
        write_claim_log_file('in'
                             || 'insert process '
                             || p_claim_id);
        write_claim_log_file('insert process:P_CLAIM_ID ' || p_claim_id);
        write_claim_log_file('in'
                             || 'insert process:PROCESS_STATUS '
                             || p_process_status);
        write_claim_log_file('in'
                             || 'insert process:P_ENTRP_ID '
                             || p_entrp_id);
        write_claim_log_file('in'
                             || 'insert process:P_PRODUCT_TYPE '
                             || p_product_type);
        write_claim_log_file('in'
                             || 'insert process:P_PAY_AMOUNT '
                             || p_pay_amount);
        write_claim_log_file('in'
                             || 'insert process:P_ER_BALANCE '
                             || p_er_balance);
        write_claim_log_file('in'
                             || 'insert process:P_CLAIM_STATUS '
                             || p_claim_status);
        insert into claim_auto_process (
            claim_id,
            process_status,
            entrp_id,
            product_type,
            payment_amount,
            employer_balance,
            claim_status,
            invoice_status,
            creation_date,
            batch_number
        )
            select
                p_claim_id,
                p_process_status,
                p_entrp_id,
                p_product_type,
                p_pay_amount,
                p_er_balance,
                p_claim_status,
                'NOT_PROCESSED',
                sysdate,
                p_batch_number
            from
                dual /*WHERE NOT EXISTS ( SELECT * FROM CLAIM_AUTO_PROCESS B
                                   WHERE  B.CLAIM_ID = P_CLAIM_ID
                                    AND   B.CLAIM_STATUS = 'APPROVED_FOR_CHEQUE'
                                    AND   B.PROCESS_STATUS = 'UNRELEASED'
                                    AND   B.INVOICE_ID IS NOT NULL)*/;

    exception
        when others then
            write_claim_log_file('in'
                                 || 'insert process '
                                 || sqlerrm);
    end insert_process;

    procedure write_released_claim_details (
        p_batch_number in number
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        if file_exists('released_claim_report_'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv',
                       'CLAIM_DIR') = 'TRUE' then
            null;
        else
            l_line := 'Claim Id,Account Number,Employer Name,Employer Account Number,Account Balance,'
                      || 'Claim Amount,Payment Amount,Check/ACH #,'
                      || 'Plan Start Date, Plan End Date, Reimbursement Method,Claim Status';
        end if;

        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'released_claim_report_'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'a');

        if l_line is not null then
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for xx in (
            select
                claim_id
            from
                claim_auto_process
            where
                    process_status <> 'UNRELEASED'
                and batch_number = p_batch_number
        ) loop
            for x in (
                select
                    a.claim_id,
                    pc_person.get_entrp_name(a.pers_id)                                                                  employer_name
                    ,
                    pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance
                    ,
                    a.claim_amount,
                    pc_lookups.get_reason_name(d.pay_reason)                                                             reimbursement_method
                    ,
                    pc_lookups.get_claim_status(a.claim_status)                                                          claim_status
                    ,
                    a.service_type,
                    a.plan_start_date                                                                                    plan_start_date
                    ,
                    a.plan_end_date                                                                                      plan_end_date
                    ,
                    n.amount                                                                                             balance,
                    b.acc_num,
                    ck.check_number
                from
                    claimn           a,
                    account          b,
                    payment_register d,
                    payment          n,
                    checks           ck
                where
                        a.claim_id = xx.claim_id
                    and a.pers_id = b.pers_id
                    and d.claim_id = a.claim_id
                    and a.claim_id = n.claimn_id
                    and b.acc_id = n.acc_id
                    and trunc(ck.check_date) >= trunc(sysdate)
                    and trunc(n.pay_date) >= trunc(sysdate)
                    and ck.entity_type = 'CLAIMN'
                    and ck.status = 'READY'
                    and ck.entity_id = a.claim_id
                    and d.acc_num = b.acc_num
                    and a.claim_amount > 0
                union
                select
                    a.claim_id,
                    pc_person.get_entrp_name(a.pers_id)                                                                  employer_name
                    ,
                    pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance
                    ,
                    a.claim_amount,
                    pc_lookups.get_reason_name(d.pay_reason)                                                             reimbursement_method
                    ,
                    pc_lookups.get_claim_status(a.claim_status)                                                          claim_status
                    ,
                    a.service_type,
                    a.plan_start_date                                                                                    plan_start_date
                    ,
                    a.plan_end_date                                                                                      plan_end_date
                    ,
                    n.total_amount                                                                                       balance,
                    b.acc_num,
                    to_char(n.transaction_id)
                from
                    claimn           a,
                    account          b,
                    payment_register d,
                    ach_transfer     n
                where
                        a.claim_id = xx.claim_id -- p_claim_id_tbl(i)
                    and a.pers_id = b.pers_id
                    and d.claim_id = a.claim_id
                    and a.claim_id = n.claim_id
                    and b.acc_id = n.acc_id
                    and d.acc_num = b.acc_num
                    and a.claim_amount > 0
                    and trunc(n.transaction_date) >= trunc(sysdate)
            ) loop
                l_line := x.claim_id
                          || ',"'
                          || x.acc_num
                          || '","'
                          || x.employer_name
                          || '",'
                          || x.er_acc_num
                          || ',"'
                          || x.account_balance
                          || '",'
                          || x.claim_amount
                          || ','
                          || x.balance
                          || ','
                          || x.check_number
                          || ','
                          || to_char(x.plan_start_date, 'MM/DD/YYYY')
                          || ','
                          || to_char(x.plan_end_date, 'MM/DD/YYYY')
                          || ','
                          || x.reimbursement_method
                          || ','
                          || x.claim_status;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;
        end loop;

        for xx in (
            select
                claim_id,
                payment_amount
            from
                claim_auto_process
            where
                    process_status = 'UNRELEASED'
                and batch_number = p_batch_number
                and claim_status <> 'APPROVED_NO_FUNDS'
        ) loop
            for x in (
                select
                    a.claim_id,
                    pc_person.get_entrp_name(a.pers_id)                                                                  employer_name
                    ,
                    pc_entrp.get_acc_num(a.entrp_id)                                                                     er_acc_num,
                    pc_account.acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, b.account_type, a.service_type) account_balance
                    ,
                    a.claim_amount,
                    pc_lookups.get_reason_name(a.pay_reason)                                                             reimbursement_method
                    ,
                    pc_lookups.get_claim_status(a.claim_status)                                                          claim_status
                    ,
                    a.service_type,
                    a.plan_start_date                                                                                    plan_start_date
                    ,
                    a.plan_end_date                                                                                      plan_end_date
                    ,
                    b.acc_num
                from
                    claimn           a,
                    account          b,
                    payment_register d
                where
                        a.claim_id = xx.claim_id
                    and a.pers_id = b.pers_id
                    and d.claim_id = a.claim_id
                    and d.acc_num = b.acc_num
                    and a.claim_amount > 0
                    and nvl(a.takeover, 'N') = 'N'
            ) loop
                l_line := x.claim_id
                          || ',"'
                          || x.acc_num
                          || '","'
                          || x.employer_name
                          || '",'
                          || x.er_acc_num
                          || ',"'
                          || x.account_balance
                          || '",'
                          || x.claim_amount
                          || ','
                          || xx.payment_amount
                          || ',-,'
                          || to_char(x.plan_start_date, 'MM/DD/YYYY')
                          || ','
                          || to_char(x.plan_end_date, 'MM/DD/YYYY')
                          || ','
                          || x.reimbursement_method
                          || ','
                          || x.claim_status;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_released_claim_details;

    procedure new_auto_release_claim (
        p_entrp_id     in number,
        p_batch_number in number
    ) is

        l_claim_id_tbl          number_tbl := number_tbl();
        l_acc_num_tbl           varchar2_tbl := varchar2_tbl();
        l_entrp_id_tbl          number_tbl := number_tbl();
        l_released_claim_id_tbl number_tbl := number_tbl();
        l_claim_amount_tbl      number_tbl := number_tbl();
        l_er_balance_rem_tbl    number_tbl := number_tbl();
        l_acc_balance_tbl       number_tbl := number_tbl();
        l_invoice_id_tbl        number_tbl := number_tbl();
        l_er_balance_remaining  number := 0;
        l_partial_unrelease_amt number := 0;
        l_unrelease_amt         number := 0;
        l_ee_balance_remaining  number := 0;
        l_nsf_amount            number := 0;
        l_return_status         varchar2(3200);
        l_error_message         varchar2(3200);
        l_limit                 number := 500;
        error_code              number := sqlcode;
        l_error_msg             varchar2(500) := sqlerrm;
        l_app_inv_count         number := 0;
        l_error_count           number := 0;
        j                       number := 0;
        ex_dml_errors exception;
        l_employer_balance      number := 0;
        l_remaining_claim       number := 0;
        l_invoice_id            number;
        l_beg_employer_balance  number := 0;
        l_funding_option        varchar2(100);
        l_claim_processed       varchar2(1);
        l_prev_acc_num          varchar2(100);
        l_prev_service_type     varchar2(100);
        l_service_type          varchar2(100);
        l_claim_to_pay          number := 0;
        pragma exception_init ( ex_dml_errors, -24381 );
        l_first_time            integer := 1;
        cursor c_cursor (
            c_entrp_id     number,
            p_product_type in varchar2
        ) is
        select
            x.claim_id,
            x.acc_num,
            x.entrp_id,
            x.claim_to_be_paid balance,
            x.claim_to_be_paid + ee_balance - sum(claim_to_be_paid)
                                              over(partition by acc_id, plan_start_date, plan_end_date, 'FSA', service_type
                                                   order by
                                                       claim_id
                                              )                  ee_balance
        from
            claim_ee_automation_gt x
        where
                entrp_id = c_entrp_id
            and product_type = p_product_type
            and ee_balance > 0
            and to_be_processed = 'Y'
        order by
            claim_id asc;

        cursor c_partial_cursor (
            c_entrp_id     number,
            c_er_balance   number,
            p_product_type in varchar2
        ) is
        select
            x.claim_id,
            x.acc_num,
            x.entrp_id,
            x.claim_to_be_paid balance,
            invoice_id,
            x.claim_to_be_paid + ee_balance - sum(claim_to_be_paid)
                                              over(partition by acc_id, plan_start_date, plan_end_date, 'FSA', service_type
                                                   order by
                                                       claim_id
                                              )                  ee_balance
        from
            claim_ee_automation_gt x
        where
                entrp_id = c_entrp_id
            and product_type = p_product_type
            and ee_balance > 0
            and to_be_processed = 'Y'
        order by
            nvl(invoice_id, -1) desc,
            claim_id asc;

    begin
        write_claim_report_file;
        delete from claim_ee_automation_gt;

        insert into claim_ee_automation_gt (
            claim_id,
            plan_start_date,
            plan_end_date,
            service_type,
            acc_id,
            pers_id,
            entrp_id,
            acc_num,
            product_type,
            ee_balance,
            pending_amount,
            invoice_id,
            processed_inv,
            funding_options
        )
            select
                claim_id,
                a.plan_start_date,
                a.plan_end_date,
                a.service_type,
                b.acc_id,
                a.pers_id,
                a.entrp_id,
                b.acc_num,
                pc_lookups.get_meaning(service_type, 'FSA_HRA_PRODUCT_MAP')                                     product_type,
                pc_account.new_acc_balance(b.acc_id, a.plan_start_date, a.plan_end_date, 'FSA', a.service_type) balance,
                ( a.approved_amount - nvl(
                    pc_claim.claim_paid(a.claim_id),
                    0
                ) )                                                                                             pending_amount,
                (
                    select
                        max(ids.invoice_id)
                    from
                        invoice_distribution_summary ids,
                        ar_invoice                   ar
                    where
                            ids.entity_id = a.claim_id
                        and ids.entity_type = 'CLAIMN'
                        and ids.invoice_id = ar.invoice_id
                        and ar.status in ( 'PROCESSED', 'POSTED' )
                )                                                                                               invoice_id,
                (
                    select
                        count(*)
                    from
                        ar_invoice
                    where
                            entity_id = a.entrp_id
                        and ( plan_type is null
                              or plan_type = pc_lookups.get_meaning(service_type, 'FSA_HRA_PRODUCT_MAP') )
                        and entity_type = 'EMPLOYER'
                        and status = 'PROCESSED'
                        and invoice_reason = 'CLAIM'
                ),
                (
                    select
                        decode(bp.claim_reimbursed_by, 'EMPLOYER', 'CLAIM_INVOICE', 'FUNDING_INVOICE')
                    from
                        ben_plan_enrollment_setup bp,
                        account                   acc
                    where
                            bp.acc_id = acc.acc_id
                        and acc.entrp_id = a.entrp_id
                        and a.service_type = bp.plan_type
                        and a.plan_start_date = bp.plan_start_date
                        and bp.status = 'A'
                        and a.plan_end_date = bp.plan_end_date
                )                                                                                               funding_options -- Added by Joshi for 5691. check invoice group
            from
                claimn  a,
                account b
            where
                    a.claim_status = 'APPROVED_FOR_CHEQUE'
                and a.pers_id = b.pers_id
                and a.claim_amount > 0
                and a.entrp_id = nvl(p_entrp_id, a.entrp_id)
                and a.entrp_id is not null
                and b.account_type in ( 'HRA', 'FSA' );

        update claim_ee_automation_gt
        set
            claim_to_be_paid = least(ee_balance, pending_amount),
            to_be_processed = (
                case
                    when ( funding_options = 'FUNDING_INVOICE' ) then
                        'Y'
                    when ( funding_options = 'CLAIM_INVOICE'
                           and invoice_id is not null ) then
                        'Y'
                    else
                        'N'
                end
            );

        for x in (
            select distinct
                x.entrp_id,
                x.product_type
            from
                claim_ee_automation_gt x
            where
                    ee_balance > 0
                and to_be_processed = 'Y'
        ) loop
            if pc_employer_fin.get_employer_balance(x.entrp_id, sysdate + 1, x.product_type) <= 0 then
                update claim_ee_automation_gt
                set
                    to_be_processed = 'N'
                where
                    entrp_id = x.entrp_id;

            end if;
        end loop;
            -- Added Service type in partition clause by Joshi for ticket 7697.
            -- balance should be considered based on plan type.
        for x in (
            select
                ee_balance - sum(claim_to_be_paid)
                             over(partition by acc_id, service_type
                                  order by
                                      claim_id
                             ) running_bal,
                claim_id,
                acc_id
            from
                claim_ee_automation_gt x
            where
                ee_balance > 0
        ) loop
            update claim_ee_automation_gt
            set
                ee_balance =
                    case
                        when x.running_bal >= 0 then
                            ee_balance
                        else
                            0
                    end
            where
                claim_id = x.claim_id;

        end loop;

        for x in (
            select
                entrp_id,
                pc_entrp.get_entrp_name(entrp_id) er_name,
                count(claim_id)                   no_of_claims,
                sum(balance)                      claim_amount,
                product_type
            from
                (
                    select
                        x.claim_id,
                        x.acc_num,
                        x.entrp_id,
                        x.claim_to_be_paid balance,
                        x.product_type
                    from
                        claim_ee_automation_gt x
                    where
                            ee_balance > 0
                        and to_be_processed = 'Y'
                        -- AND PROCESSED_INV = 0
                    order by
                        claim_id asc
                )
            group by
                entrp_id,
                product_type
            order by
                count(claim_id) desc
        ) loop
            l_beg_employer_balance := 0;
            l_beg_employer_balance := pc_employer_fin.get_employer_balance(x.entrp_id, sysdate + 1, x.product_type);

            write_claim_log_file('auto_release_claim'
                                 || 'Employer Name '
                                 || x.er_name);
            write_claim_log_file('auto_release_claim'
                                 || 'EMPLOYER_BALANCE '
                                 || l_beg_employer_balance);
            write_claim_log_file('auto_release_claim'
                                 || 'CLAIM_AMOUNT '
                                 || x.claim_amount);
            write_claim_log_file('auto_release_claim'
                                 || 'product_type '
                                 || x.product_type);
            l_return_status := 'S';
            if l_beg_employer_balance >= x.claim_amount then
                l_claim_id_tbl := number_tbl();
                l_acc_num_tbl := varchar2_tbl();
                l_entrp_id_tbl := number_tbl();
                l_released_claim_id_tbl := number_tbl();
                l_claim_amount_tbl := number_tbl();
                open c_cursor(x.entrp_id, x.product_type);
                loop
                    fetch c_cursor
                    bulk collect into
                        l_claim_id_tbl,
                        l_acc_num_tbl,
                        l_entrp_id_tbl,
                        l_claim_amount_tbl,
                        l_acc_balance_tbl
                    limit l_limit;
                    write_claim_log_file('auto_release_claim'
                                         || 'No of claims to release'
                                         || l_claim_id_tbl.count);
                    if l_claim_id_tbl.count > 0 then
                        for i in l_claim_id_tbl.first..l_claim_id_tbl.last loop
                            l_claim_processed := 'N';
                            write_claim_log_file('auto_release_claim'
                                                 || 'l_claim_id_tbl('
                                                 || i
                                                 || ')'
                                                 || l_claim_id_tbl(i));

                            pc_claim.process_finance_claim(
                                p_claim_id      => l_claim_id_tbl(i),
                                p_claim_status  => 'READY_TO_PAY',
                                p_user_id       => 0,
                                x_return_status => l_return_status,
                                x_error_message => l_error_message
                            );

                            write_claim_log_file('process_finance_claim'
                                                 || 'l_return_status'
                                                 || l_return_status);
                            write_claim_log_file('process_finance_claim'
                                                 || 'l_error_message'
                                                 || l_error_message);
                            if l_return_status <> 'S' then
                                write_claim_error_file(
                                    l_acc_num_tbl(i),
                                    l_claim_id_tbl(i),
                                    l_error_message
                                );
                            else
                                for xx in (
                                    select
                                        claim_status
                                    from
                                        claimn
                                    where
                                        claim_id = l_claim_id_tbl(i)
                                ) loop
                                    write_claim_log_file('auto_release_claim'
                                                         || 'insert process '
                                                         || l_claim_id_tbl(i));
                                    if xx.claim_status not in ( 'READY_TO_PAY', 'PAID', 'PARTIALLY_PAID' ) then
                                        insert_process(
                                            l_claim_id_tbl(i),
                                            'UNRELEASED',
                                            x.entrp_id,
                                            x.product_type,
                                            l_claim_amount_tbl(i),
                                            l_beg_employer_balance,
                                            xx.claim_status,
                                            p_batch_number
                                        );

                                    else
                                        insert_process(
                                            l_claim_id_tbl(i),
                                            'RELEASED',
                                            x.entrp_id,
                                            x.product_type,
                                            l_claim_amount_tbl(i),
                                            l_beg_employer_balance,
                                            xx.claim_status,
                                            p_batch_number
                                        );
                                    end if;

                                end loop;
                            end if;

                        end loop;
                    end if;

                    exit when c_cursor%notfound;
                end loop;

                close c_cursor;
            elsif
                l_beg_employer_balance > 0
                and l_beg_employer_balance < x.claim_amount
                and x.no_of_claims > 1
            then
                l_claim_id_tbl := number_tbl();
                l_acc_num_tbl := varchar2_tbl();
                l_entrp_id_tbl := number_tbl();
                l_released_claim_id_tbl := number_tbl();
                l_claim_amount_tbl := number_tbl();
                open c_partial_cursor(x.entrp_id, l_beg_employer_balance, x.product_type);
                loop
                    fetch c_partial_cursor
                    bulk collect into
                        l_claim_id_tbl,
                        l_acc_num_tbl,
                        l_entrp_id_tbl,
                        l_claim_amount_tbl,
                        l_invoice_id_tbl,
                        l_acc_balance_tbl
                    limit l_limit;

                    if l_claim_id_tbl.count > 0 then
                        write_claim_log_file('Partial release of claims ');
                        j := 0;
                        l_released_claim_id_tbl := number_tbl();
                        l_remaining_claim := x.claim_amount;
                        l_nsf_amount := 0;
                        l_er_balance_remaining := l_beg_employer_balance;
                        for i in l_claim_id_tbl.first..l_claim_id_tbl.last loop
                            --  pc_employer_fin.CREATE_EMPLOYER_PAYMENT(X.ENTRP_ID,SYSDATE);
                            --  l_er_balance_remaining := PC_EMPLOYER_FIN.GET_EMPLOYER_BALANCE(x.ENTRP_ID,SYSDATE+1,x.product_type) ;

                            write_claim_log_file('****employer balance remaining' || l_er_balance_remaining);
                            write_claim_log_file('****remaining claim ' || l_remaining_claim);
                            write_claim_log_file('****l_claim_id_tbl('
                                                 || i
                                                 || ')'
                                                 || l_claim_id_tbl(i));
                            write_claim_log_file('****claim amount ('
                                                 || i
                                                 || ')'
                                                 || l_claim_amount_tbl(i));
                            write_claim_log_file('****Account Balance ('
                                                 || i
                                                 || ')'
                                                 || l_acc_balance_tbl(i));
                            write_claim_log_file('****Account Number ('
                                                 || i
                                                 || ')'
                                                 || l_acc_num_tbl(i));
                            if
                                l_claim_amount_tbl(i) > 0
                                and l_er_balance_remaining >= l_claim_amount_tbl(i)
                                and l_acc_balance_tbl(i) > 0
                            then
                                write_claim_log_file('partial auto_release_claim'
                                                     || 'releasing claim id '
                                                     || l_claim_id_tbl(i));
                                pc_claim.process_finance_claim(
                                    p_claim_id      => l_claim_id_tbl(i),
                                    p_claim_status  => 'READY_TO_PAY',
                                    p_user_id       => 0,
                                    x_return_status => l_return_status,
                                    x_error_message => l_error_message
                                );

                                if l_return_status <> 'S' then
                                    write_claim_error_file(
                                        l_acc_num_tbl(i),
                                        l_claim_id_tbl(i),
                                        l_error_message
                                    );
                                else
                                    for xx in (
                                        select
                                            claim_status
                                        from
                                            claimn
                                        where
                                            claim_id = l_claim_id_tbl(i)
                                    ) loop
                                        write_claim_log_file('partial auto_release_claim'
                                                             || 'insert process '
                                                             || l_claim_id_tbl(i));
                                        if xx.claim_status not in ( 'READY_TO_PAY', 'PAID', 'PARTIALLY_PAID' ) then
                                            l_nsf_amount := l_nsf_amount + l_claim_amount_tbl(i);
                                            insert_process(
                                                l_claim_id_tbl(i),
                                                'UNRELEASED',
                                                x.entrp_id,
                                                x.product_type,
                                                l_claim_amount_tbl(i),
                                                l_er_balance_remaining,
                                                xx.claim_status,
                                                p_batch_number
                                            );

                                        else
                                            insert_process(
                                                l_claim_id_tbl(i),
                                                'PARTIAL_RELEASE',
                                                x.entrp_id,
                                                x.product_type,
                                                l_claim_amount_tbl(i),
                                                l_er_balance_remaining,
                                                xx.claim_status,
                                                p_batch_number
                                            );
                                        end if;

                                    end loop;
                                end if;

                                l_remaining_claim := l_remaining_claim - l_claim_amount_tbl(i);
                                l_er_balance_remaining := l_er_balance_remaining - l_claim_amount_tbl(i);
                                write_claim_log_file('partial auto_release_claim'
                                                     || 'l_remaining_claim'
                                                     || l_remaining_claim);
                            else
                                write_claim_log_file('partial auto_release_claim'
                                                     || 'insert process '
                                                     || l_claim_id_tbl(i));
                                if l_acc_balance_tbl(i) > 0 then
                                    write_claim_log_file('****Account Number ('
                                                         || i
                                                         || ')'
                                                         || l_acc_num_tbl(i));
                                    write_claim_log_file('****Account Balance ('
                                                         || i
                                                         || ')'
                                                         || l_acc_balance_tbl(i));
                                    write_claim_log_file('****Claim Amount ('
                                                         || i
                                                         || ')'
                                                         || l_claim_amount_tbl(i));
                                    insert_process(
                                        l_claim_id_tbl(i),
                                        'UNRELEASED',
                                        x.entrp_id,
                                        x.product_type,
                                        case
                                                when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                    l_claim_amount_tbl(i)
                                                when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                    l_acc_balance_tbl(i)
                                            end,
                                        l_er_balance_remaining,
                                        case
                                                when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                    'APPROVED_FOR_CHEQUE'
                                                when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                    'APPROVED_FOR_CHEQUE'
                                                when l_acc_balance_tbl(i) = 0 then
                                                    'APPROVED_NO_FUNDS'
                                            end,
                                        p_batch_number
                                    );

                                end if;

                            end if;

                        end loop;
                      --   write_unreleased_claim_file(X.ENTRP_ID,l_remaining_claim ,l_er_balance_remaining,X.PRODUCT_TYPE);
                        write_claim_log_file('write released claim ' || l_released_claim_id_tbl.count);
                    end if;

                    exit when c_partial_cursor%notfound;
                end loop;

                close c_partial_cursor;
                pc_log.log_error('PC_CLAIM_AUTOMATION - NEW AUTO RELEASE : end of if ', l_beg_employer_balance);
            else
                open c_cursor(x.entrp_id, x.product_type);
                loop
                    fetch c_cursor
                    bulk collect into
                        l_claim_id_tbl,
                        l_acc_num_tbl,
                        l_entrp_id_tbl,
                        l_claim_amount_tbl,
                        l_acc_balance_tbl
                    limit l_limit;
                    if l_claim_id_tbl.count > 0 then
                        for i in l_claim_id_tbl.first..l_claim_id_tbl.last loop
                            if l_acc_balance_tbl(i) > 0 then
                                write_claim_log_file('****Account Number ('
                                                     || i
                                                     || ')'
                                                     || l_acc_num_tbl(i));
                                write_claim_log_file('****Account Balance ('
                                                     || i
                                                     || ')'
                                                     || l_acc_balance_tbl(i));
                                write_claim_log_file('****Claim Amount ('
                                                     || i
                                                     || ')'
                                                     || l_claim_amount_tbl(i));
                                insert_process(
                                    l_claim_id_tbl(i),
                                    'UNRELEASED',
                                    x.entrp_id,
                                    x.product_type,
                                    case
                                            when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                l_claim_amount_tbl(i)
                                            when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                l_acc_balance_tbl(i)
                                        end,
                                    l_beg_employer_balance,
                                    case
                                            when l_claim_amount_tbl(i) <= l_acc_balance_tbl(i) then
                                                'APPROVED_FOR_CHEQUE'
                                            when l_claim_amount_tbl(i) > l_acc_balance_tbl(i) then
                                                'APPROVED_FOR_CHEQUE'
                                            when l_acc_balance_tbl(i) = 0 then
                                                'APPROVED_NO_FUNDS'
                                        end,
                                    p_batch_number
                                );

                            end if;
                        end loop;

                    end if;

                    exit when c_cursor%notfound;
                end loop;

                close c_cursor;
                --write_unreleased_claim_file(X.ENTRP_ID,X.CLAIM_AMOUNT ,X.EMPLOYER_BALANCE,X.PRODUCT_TYPE);

            end if;

        end loop;

         -- Added by Joshi for 5691. process non invoiced claims.

         -- this is where the problem is
        for x in (
            select
                claim_id,
                acc_num,
                service_type,
                entrp_id,
                claim_to_be_paid pending_amount -- this should be claim to be paid,CLAIM_TO_BE_PAID
                ,
                product_type,
                ee_balance
            from
                claim_ee_automation_gt x
            where
                    ee_balance > 0
                and to_be_processed = 'N'
            order by
                acc_num,
                service_type,
                claim_id asc
        ) loop
            l_beg_employer_balance := 0;
           --l_ee_balance_remaining := 0;

            if l_first_time = 1 then
                l_ee_balance_remaining := x.ee_balance;
                l_first_time := l_first_time + 1;
                l_prev_acc_num := x.acc_num;
                l_prev_service_type := x.service_type;
            end if;

            l_beg_employer_balance := pc_employer_fin.get_employer_balance(x.entrp_id, sysdate + 1, x.product_type);

            write_claim_log_file('not to be processed '
                                 || 'claim ID '
                                 || x.claim_id);
            write_claim_log_file('not to be processed'
                                 || 'EMPLOYER_BALANCE '
                                 || l_beg_employer_balance);
            write_claim_log_file('not to be processed'
                                 || 'CLAIM_AMOUNT '
                                 || x.pending_amount);
            write_claim_log_file('not to be processed'
                                 || 'product_type '
                                 || x.product_type);
            write_claim_log_file('not to be processed'
                                 || 'EE_BALANCE '
                                 || x.ee_balance);
            write_claim_log_file('not to be processed'
                                 || 'l_ee_balance_remaining '
                                 || l_ee_balance_remaining);
            write_claim_log_file('not to be processed'
                                 || 'l_prev_Service_type '
                                 || l_prev_service_type);
            write_claim_log_file('not to be processed'
                                 || 'l_ee_balance_remaining '
                                 || l_ee_balance_remaining
                                 || ' ee remaining '
                                 || to_char(l_ee_balance_remaining - x.pending_amount));

            if x.acc_num <> l_prev_acc_num then
                l_claim_to_pay := 0;
                l_ee_balance_remaining := x.ee_balance - x.pending_amount;
                insert_process(x.claim_id, 'UNRELEASED', x.entrp_id, x.product_type, x.pending_amount,
                               l_beg_employer_balance, 'APPROVED_FOR_CHEQUE', p_batch_number);

            else
                if x.service_type <> l_prev_service_type then
                    l_claim_to_pay := 0;
                    l_ee_balance_remaining := x.ee_balance - x.pending_amount;
                    insert_process(x.claim_id, 'UNRELEASED', x.entrp_id, x.product_type, x.pending_amount,
                                   l_beg_employer_balance, 'APPROVED_FOR_CHEQUE', p_batch_number);

                else
                    l_claim_to_pay := nvl(l_claim_to_pay, 0) + x.pending_amount;
                    if
                        l_ee_balance_remaining > 0
                        and l_ee_balance_remaining - x.pending_amount < 0
                    then
                        insert_process(x.claim_id, 'UNRELEASED', x.entrp_id, x.product_type, l_ee_balance_remaining,
                                       l_beg_employer_balance, 'APPROVED_FOR_CHEQUE', p_batch_number);

                    end if;

                    if
                        l_ee_balance_remaining > 0
                        and l_ee_balance_remaining - x.pending_amount >= 0
                    then
                        insert_process(x.claim_id, 'UNRELEASED', x.entrp_id, x.product_type, x.pending_amount,
                                       l_beg_employer_balance, 'APPROVED_FOR_CHEQUE', p_batch_number);
                    end if;

                    l_ee_balance_remaining := l_ee_balance_remaining - x.pending_amount;
                end if;
            end if;

            l_prev_acc_num := x.acc_num;
            l_prev_service_type := x.service_type;
        end loop;

         -- Process invoices for each employer.
         -- Added by Joshi for 5691.
        for x in (
            select distinct
                entrp_id,
                product_type
            from
                claim_ee_automation_gt
            where
                    ee_balance > 0
                and funding_options = 'CLAIM_INVOICE'
        ) -- Added by Joshi for PROD issue on 02/02/2022. 10871
         loop
            select
                count(*)
            into l_app_inv_count
            from
                ar_invoice
            where
                    entity_id = x.entrp_id
                and ( plan_type is null
                      or plan_type = x.product_type )
                and entity_type = 'EMPLOYER'
                and status = 'PROCESSED'
                and invoice_reason = 'CLAIM';

            -- Vanitha: Pay what we invoice enhancements
            -- AND STATUS IN ('PROCESSED','PARTIALLY_POSTED') and INVOICE_REASON = 'CLAIM';
            if l_app_inv_count = 0 then

              --  pc_employer_fin.CREATE_EMPLOYER_PAYMENT(X.ENTRP_ID,SYSDATE);
                pc_invoice.generate_claim_invoice(
                    p_start_date    => sysdate,
                    p_end_date      => sysdate,
                    p_billing_date  => sysdate,
                    p_entrp_id      => x.entrp_id,
                    p_product_type  => x.product_type,
                    x_error_status  => l_return_status,
                    x_error_message => l_error_message
                );

                if l_return_status <> 'S' then
                    write_claim_error_file(null, null, ' Error creating invoice '
                                                       || l_error_message
                                                       || ' for entrp_id '
                                                       || x.entrp_id);

                end if;

            else
                update claim_auto_process
                set
                    process_status = 'INV_OUTSTANDING'
                where
                        batch_number = p_batch_number
                    and claim_status in ( 'APPROVED_FOR_CHEQUE' )
                    and invoice_status = 'NOT_PROCESSED'
                    and entrp_id = x.entrp_id
                    and product_type = x.product_type;

            end if;

        end loop;

    exception
        when others then
            write_claim_error_file(null, null, ' auto release claim : Message: ' || sqlerrm());
            pc_log.log_error('pc_claim_automation', sqlerrm);
    end new_auto_release_claim;

end pc_claim_automation;
/

