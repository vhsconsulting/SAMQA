create or replace package body samqa.pc_claim_detail is

    procedure insert_claim_detail (
        p_claim_id         in number,
        p_serice_provider  in pc_online_enrollment.varchar2_tbl,
        p_service_date     in pc_online_enrollment.varchar2_tbl,
        p_service_end_date in pc_online_enrollment.varchar2_tbl,
        p_service_name     in pc_online_enrollment.varchar2_tbl,
        p_service_price    in pc_online_enrollment.varchar2_tbl,
        p_patient_dep_name in pc_online_enrollment.varchar2_tbl,
        p_medical_code     in pc_online_enrollment.varchar2_tbl,
        p_service_code     in varchar2,
        p_note             in pc_online_enrollment.varchar2_tbl,
        p_provider_tax_id  in pc_online_enrollment.varchar2_tbl,
        p_eob_detail_id    in pc_online_enrollment.varchar2_tbl,
        p_created_by       in number,
        p_creation_date    in date,
        p_last_updated_by  in number,
        p_last_update_date in date,
        p_eob_linked       in pc_online_enrollment.varchar2_tbl  --Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag
        ,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        l_serice_provider     pc_online_enrollment.varchar2_tbl;
        l_service_date        pc_online_enrollment.varchar2_tbl;
        l_service_end_date    pc_online_enrollment.varchar2_tbl;
        l_service_name        pc_online_enrollment.varchar2_tbl;
        l_service_price       pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name    pc_online_enrollment.varchar2_tbl;
        l_note                pc_online_enrollment.varchar2_tbl;
        l_medical_code        pc_online_enrollment.varchar2_tbl;
        l_provider_tax_id     pc_online_enrollment.varchar2_tbl;
        l_eob_detail_id       pc_online_enrollment.varchar2_tbl;
        l_account_type        varchar2(30);
        l_eob_linked          pc_online_enrollment.varchar2_tbl;--Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag
        l_claim_detail_status varchar2(30);
    begin
        x_return_status := 'S';
     /** Claim Detail **/
        pc_log.log_error('INSERT_CLAIM_DETAIL', 'P_CLAIM_ID ' || p_claim_id);
        pc_log.log_error('INSERT_CLAIM_DETAIL', 'P_SERVICE_DATE.COUNT ' || p_service_date.count);
        l_service_date := pc_online_enrollment.array_fill(p_service_date, p_service_date.count);
        l_serice_provider := pc_online_enrollment.array_fill(p_serice_provider, p_service_date.count);
        l_service_end_date := pc_online_enrollment.array_fill(p_service_end_date, p_service_date.count);
        l_service_name := pc_online_enrollment.array_fill(p_service_name, p_service_date.count);
        l_service_price := pc_online_enrollment.array_fill(p_service_price, p_service_date.count);
        l_patient_dep_name := pc_online_enrollment.array_fill(p_patient_dep_name, p_service_date.count);
        l_note := pc_online_enrollment.array_fill(p_note, p_service_date.count);
        l_medical_code := pc_online_enrollment.array_fill(p_medical_code, p_service_date.count);
        l_provider_tax_id := pc_online_enrollment.array_fill(p_provider_tax_id, p_service_date.count);
        l_eob_detail_id := pc_online_enrollment.array_fill(p_eob_detail_id, p_service_date.count);
        pc_log.log_error('INSERT_CLAIM_DETAIL', 'L_SERVICE_NAME.COUNT ' || l_service_name.count);
        l_eob_linked := pc_online_enrollment.array_fill(p_eob_linked, p_service_date.count); --Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag

  /*  -- Added by Swamy for Ticket#11091
    l_claim_detail_status := NULL;
    IF NVL(l_claim_detail_status,'*') = '*' THEN
        FOR k IN (SELECT claim_status
                    FROM claimn
                   WHERE claim_id = P_CLAIM_ID) LOOP
           l_claim_detail_status := k.claim_status;
        END LOOP;
    END IF;
 */

        for i in 1..l_service_price.count loop
            if l_service_price(i) is not null then
                pc_log.log_error('INSERT_CLAIM_DETAIL',
                                 'L_SERVICE_NAME('
                                 || i
                                 || ')'
                                 || l_service_name(i));

                pc_log.log_error('INSERT_CLAIM_DETAIL',
                                 'L_NOTE('
                                 || i
                                 || ')'
                                 || l_note(i)
                                 || ' l_claim_detail_status :='
                                 || l_claim_detail_status);

                insert into claim_detail (
                    claim_detail_id,
                    claim_id
        --	 ,SERVICE_PROVIDER
                    ,
                    service_date,
                    service_end_date,
                    service_name,
                    service_price,
                    service_code,
                    patient_dep_name,
                    note,
                    tax_code,
                    provider_tax_id,
                    eob_detail_id,
                    eob_linked          --Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag
                    ,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    claim_detail_status    -- Added by Swamy for Ticket#11091
                ) values ( claim_detail_seq.nextval,
                           p_claim_id
          -- ,P_SERICE_PROVIDER(i)
                           ,
                           to_date(l_service_date(i),
                                   'MM/DD/YYYY'),
                           to_date(l_service_end_date(i),
                                   'MM/DD/YYYY'),
                           l_service_name(i),
                           l_service_price(i),
                           p_service_code,
                           l_patient_dep_name(i),
                           l_note(i),
                           l_medical_code(i),
                           l_provider_tax_id(i),
                           l_eob_detail_id(i),
                           case
                               when l_eob_linked(i) is null
                                    and l_eob_detail_id(i) is not null then
                                   'Y'
                               else
                                   l_eob_linked(i)
                           end --Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag
                           ,
                           sysdate,
                           p_created_by,
                           sysdate,
                           p_last_updated_by,
                           l_claim_detail_status    -- Added by Swamy for Ticket#11091
                            );

            end if;
        end loop;

        update claim_detail
        set
            state_tax = (
                select
                    state_tax
                from
                    eob_detail
                where
                    eob_detail.eob_detail_id = claim_detail.eob_detail_id
            )
        where
                claim_id = p_claim_id
            and state_tax is null;

    -- For the rows that are added to the EOB
        update claim_detail
        set
            state_tax = (
                select distinct
                    state_tax
                from
                    claim_detail
                where
                        claim_id = p_claim_id
                    and state_tax is not null
            )
        where
                claim_id = p_claim_id
            and state_tax is null;

        update claimn
        set
            claim_source = 'EOB'
        where
                claim_id = p_claim_id
            and exists (
                select
                    *
                from
                    claim_detail
                where
                        claimn.claim_id = claim_detail.claim_id
                    and eob_detail_id is not null
            );


     -- Update Service Dates
        for x in (
            select
                service_start_date,
                service_end_date,
                claim_amount,
                patient_name
            from
                claim_summary_detail_v
            where
                claim_id = p_claim_id
        ) loop
            update claimn
            set
                service_start_date = x.service_start_date,
                service_end_date = x.service_end_date,
                claim_amount = x.claim_amount,
                claim_pending = x.claim_amount - nvl(
                    pc_claim.claim_paid(p_claim_id),
                    0
                )
            where
                claim_id = p_claim_id;

            update payment_register
            set
                claim_amount = x.claim_amount,
                note = substr('('
                              || acc_num
                              || ')'
                              || ' Patient Name: '
                              || x.patient_name
                              || ' DOS:'
                              || to_char(x.service_start_date, 'MM/DD/YYYY')
                              || ' to '
                              || to_char(x.service_end_date, 'MM/DD/YYYY')
                              || ' Provider Name:'
                              || provider_name
                              || ' '
                              ||
                              case
                                  when claim_type in('PROVIDER_ONLINE', 'PROVIDER') then
                                      'Acct#: '
                                      ||(
                                          select
                                              vendor_acc_num
                                          from
                                              vendors
                                          where
                                              vendor_id = payment_register.vendor_id
                                      )
                                  else
                                      ''
                              end
                              || ' '
                              || note,
                              1,
                              2000)
            where
                claim_id = p_claim_id;

        end loop;
    -- Update Plan Dates for online claims
    -- if they are not there
        begin
            for x in (
                select
                    a.claim_id,
                    max(b.service_date),
                    c.acc_id,
                    d.plan_start_date,
                    d.plan_end_date
                from
                    claimn                    a,
                    claim_detail              b,
                    account                   c,
                    ben_plan_enrollment_setup d
                where
                        a.claim_id = p_claim_id
                    and a.claim_id = b.claim_id
                    and a.pers_id = c.pers_id
                    and d.acc_id = c.acc_id
                    and a.service_type = d.plan_type
                    and d.status <> 'R'
                    and a.plan_start_date is null
                    and c.account_type in ( 'HRA', 'FSA' )
                group by
                    a.claim_id,
                    c.acc_id,
                    d.plan_start_date,
                    d.plan_end_date,
                    grace_period
                having max(b.service_date) >= d.plan_start_date
                       and max(b.service_date) <= d.plan_end_date + nvl(grace_period, 0)
            ) loop
                update claimn
                set
                    plan_start_date = x.plan_start_date,
                    plan_end_date = x.plan_end_date
                where
                        claim_id = x.claim_id
                    and plan_start_date is null;

            end loop;
        end;

        l_account_type := null;
        for x in (
            select
                c.claim_id,
                a.plan_start_date,
                a.plan_end_date,
                b.account_type
            from
                ben_plan_enrollment_setup a,
                account                   b,
                claimn                    c
            where
                    trunc(a.plan_start_date) <= trunc(sysdate)
                and trunc(a.plan_end_date) + nvl(grace_period, 0) >= trunc(sysdate)
                and b.pers_id = c.pers_id
                and b.acc_id = a.acc_id
                and c.plan_start_date is null
                and a.status <> 'R'
                and b.account_type in ( 'HRA', 'FSA' )
                and a.plan_type = c.service_type
                and c.claim_id = p_claim_id
        ) loop
            update claimn
            set
                plan_start_date = x.plan_start_date,
                plan_end_date = x.plan_end_date
            where
                    claim_id = x.claim_id
                and plan_start_date is null;

            l_account_type := x.account_type;
        end loop;
        -- IF l_account_type IN ('HRA','FSA') THEN
        pc_claim.validate_transaction_limits(p_claim_id);
      --   END IF;
    exception
        when others then
            x_return_status := 'E';
            pc_log.log_error('PC_CLAIM_DETAIL', 'sqlerrm ' || sqlerrm);

       /* commented by Joshi as value was large and not able to insert website_log table 05/05/2020
	      pc_log.log_app_error('PC_CLAIM_DETAIL','INSERT_CLAIM_DETAIL',DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE ); */

            x_error_message := sqlerrm;
    end insert_claim_detail;

-- Added by Swamy for Ticket#11091
    function get_claim_detail (
        p_claim_id in number
    ) return claim_detail_t
        pipelined
        deterministic
    is
        l_record claim_detail_row_t;
    begin
        for i in (
            select
                case
                    when c.source_claim_id is not null then
                        pc_lookups.get_denied_reason(c.denied_reason)
                        || '# '
                        || c.source_claim_id
                    else
                        pc_lookups.get_denied_reason(c.denied_reason)
                end denied_reason,
                d.tax_code,
                d.claim_id,
                d.service_date,
                d.service_end_date,
                c.claim_status,
                d.note,
                d.patient_dep_name,
                d.service_name,
                d.service_price,
                c.denied_amount,
                d.claim_detail_status
            from
                claimn       c,
                claim_detail d
            where
                    c.claim_id = d.claim_id
                and c.claim_id = p_claim_id
        ) loop
            l_record.claim_id := i.claim_id;
            l_record.service_start_date := to_char(i.service_date, 'mm/dd/yyyy');
            l_record.service_end_date := to_char(i.service_end_date, 'mm/dd/yyyy');
            l_record.claim_status := pc_lookups.get_meaning(i.claim_status, 'CLAIM_STATUS');
            l_record.note := i.note;
            l_record.patient_dep_name := i.patient_dep_name;
            l_record.service_name := i.service_name;
            l_record.service_price := i.service_price;
            l_record.denied_reason := null;
            l_record.denied_amount := i.denied_amount;
            pc_log.log_error('INSERT_CLAIM_DETAIL', 'i.claim_status'
                                                    || i.claim_status
                                                    || 'i.denied_amount :='
                                                    || i.denied_amount);

            for j in (
                select
                    meaning
                from
                    claim_medical_codes
                where
                    lookup_code = i.tax_code
            ) loop
        -- Medical code column in php
                l_record.tax_description := j.meaning;
            end loop;

            l_record.claim_detail_status := pc_lookups.get_meaning(i.claim_detail_status, 'CLAIM_STATUS');
            if nvl(i.claim_detail_status, '*') in ( 'DENIED', 'PARTIALLY_DENIED' ) then
                l_record.denied_reason := nvl(i.denied_reason, i.note);
            end if;

            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_CLAIM_DETAIL.get_claim_detail', sqlerrm);
    end get_claim_detail;

end pc_claim_detail;
/


-- sqlcl_snapshot {"hash":"7af436abedf56d7a06f9562c60ee770735aa1b86","type":"PACKAGE_BODY","name":"PC_CLAIM_DETAIL","schemaName":"SAMQA","sxml":""}