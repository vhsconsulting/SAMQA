-- liquibase formatted sql
-- changeset SAMQA:1754374028182 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_eob_utility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_eob_utility.sql:null:28b3d9e95f9aa210e99460d8260be168a4af0949:create

create or replace package body samqa.pc_eob_utility is

    function get_eob_info (
        p_user_id in number,
        p_acc_id  in number,
        p_ssn     in varchar2
    ) return eob_t
        pipelined
        deterministic
    is
  --This function returns eob data if exists for the account id, user_id and ssn passed --
        l_eob_rec eob_rec_t;
        v_count   number;
    begin
        for x in (
            select
                eb.claim_number      eob_ref_no,
                nvl((eb.patient_first_name
                     || ' '
                     || eb.patient_last_name),(p.first_name
                                               || ' '
                                               || p.last_name))     patient_name,
                eb.description       provider_name,
                eb.source            eob_source -- "Claim Source"
                ,
                eb.eob_status_code   eob_status -- "Claim Status"
                ,
                eb.service_date_from service_date_from -- "Service Start Date"
                ,
                eb.claim_id -- "Claim Number"
                ,
                p.pers_id,
                eb.eob_id
            from
                account      acc,
                person       p,
                online_users ou,
                eob_header   eb --, eob_detail ed
            where
                    acc.acc_id = nvl(p_acc_id, acc.acc_id)
                and acc.pers_id = p.pers_id
                and p.ssn = nvl(
                    format_ssn(p_ssn),
                    p.ssn
                )
                and format_ssn(ou.tax_id) = p.ssn
                and eb.user_id = nvl(p_user_id, ou.user_id)
                and ou.user_status = 'A'
                and ( ( case
                            when eb.claim_id is not null then
                                p_acc_id
                        end = eb.acc_id )
                      or eb.claim_id is null )
        ) loop
            l_eob_rec.eob_ref_no := x.eob_ref_no;
            l_eob_rec.patient_name := x.patient_name;
            l_eob_rec.provider_name := x.provider_name;
            l_eob_rec.eob_source := x.eob_source;
            l_eob_rec.eob_status := x.eob_status;
            l_eob_rec.eob_id := x.eob_id;
            for xx in (
                select
                    max(received_date)  received_date,
                    max(processed_date) processed_date,
                    nvl(
                        sum(charged_amt),
                        0
                    )                   charged_amt,
                    nvl(
                        sum(cost_of_service_amt),
                        0
                    )                   eob_balance
                from
                    table ( get_eob_detail_info(x.eob_ref_no) )
            ) loop
                l_eob_rec.received_date := xx.received_date;
                l_eob_rec.processed_date := xx.processed_date;
                l_eob_rec.charged_amt := xx.charged_amt;
                l_eob_rec.eob_balance := xx.eob_balance;
            end loop;

            l_eob_rec.service_date_from := x.service_date_from;
            l_eob_rec.claim_id := x.claim_id;
            l_eob_rec.disbursement_date := null;
            dbms_output.put_line('In loop');
            if x.claim_id is not null then
                begin
                    select
                        to_char(claim_date, 'MM/DD/YYYY')
                    into l_eob_rec.disbursement_date
                    from
                        claimn cl
                    where
                        cl.claim_id = x.claim_id;

                exception
                    when others then
                        l_eob_rec.disbursement_date := null;
                end;
            end if;

            v_count := 0;
            select
                count(*)
            into v_count
            from
                eob_detail
            where
                eob_id = x.eob_id;

            if v_count > 1 then
                l_eob_rec.service := 'Multiple';
            else
                begin
                    select
                        benefit_type
                    into l_eob_rec.service
                    from
                        eob_detail
                    where
                        eob_id = x.eob_id;

                exception
                    when others then
                        l_eob_rec.service := null;
                end;
            end if;

            pipe row ( l_eob_rec );
        end loop;
    end get_eob_info;

    function get_disburse_info (
        p_acc_id   in number,
        p_claim_id in number
    ) return eob_t
        pipelined
        deterministic
    is
---- This function returns eob data if exists for the account id and claim id passed ----
        l_disburse_rec eob_rec_t;
    begin
        for x in (
            select
                eb.claim_number      eob_ref_no,
                p.first_name
                || ' '
                || p.last_name       patient_name,
                eb.description       provider_name,
                eb.source            eob_source -- "Claim source"
                ,
                eb.eob_status_code   eob_status   --"Claim Status "
                ,
                eb.service_date_from service_date_from -- "Service Start Date"
                  -- , EB.EOB_ID
            from
                account    acc,
                person     p,
                insure     i,
                eob_header eb --ONLINE_USERS u
            where
                    acc.acc_id = nvl(p_acc_id, acc.acc_id)
                and acc.pers_id = p.pers_id
                and i.pers_id = p.pers_id
                and eb.member_id = i.insurance_member_id
                and eb.claim_id = nvl(p_claim_id, eb.claim_id)
            union all
            select
                eb.claim_number         eob_ref_no,
                eb.patient_first_name
                || ' '
                || eb.patient_last_name patient_name,
                eb.description          provider_name,
                eb.source               eob_source -- "Claim source"
                ,
                eb.eob_status_code      eob_status   --"Claim Status "
                ,
                eb.service_date_from    service_date_from -- "Service Start Date"
            from
                account      acc,
                person       p,
                eob_header   eb,
                online_users ou
            where
                    acc.acc_id = nvl(p_acc_id, acc.acc_id)
                and format_ssn(ou.tax_id) = p.ssn--OU.TAX_ID = REPLACE(P.SSN,'-')
                and acc.pers_id = p.pers_id
                and eb.user_id = ou.user_id
                and ou.user_status = 'A'
                and ( ( case
                            when eb.claim_id is not null then
                                p_acc_id
                        end = eb.acc_id )
                      or eb.claim_id is null )
                and eb.claim_id = nvl(p_claim_id, eb.claim_id)
        ) loop
            l_disburse_rec.eob_ref_no := x.eob_ref_no;
            l_disburse_rec.patient_name := x.patient_name;
            l_disburse_rec.provider_name := x.provider_name;
            l_disburse_rec.eob_source := x.eob_source;
            l_disburse_rec.eob_status := x.eob_status;
            l_disburse_rec.service_date_from := x.service_date_from;
            for xx in (
                select
                    max(received_date)  received_date,
                    max(processed_date) processed_date,
                    nvl(
                        sum(cost_of_service_amt),
                        0
                    )                   eob_balance
                from
                    table ( get_eob_detail_info(x.eob_ref_no) )
            ) loop
                l_disburse_rec.received_date := xx.received_date;
                l_disburse_rec.processed_date := xx.processed_date;
                l_disburse_rec.eob_balance := xx.eob_balance;
            end loop;

            l_disburse_rec.claim_id := null;
            l_disburse_rec.disbursement_date := null;
            l_disburse_rec.charged_amt := null;
            l_disburse_rec.service := null;
            pipe row ( l_disburse_rec );
        end loop;
    end get_disburse_info;

    function get_eob_detail_info (
        p_eob_id in varchar2
    ) return eob_detail_t
        pipelined
        deterministic
    is
---- This function returns eob detail data if exists for the eob id passed ----
        l_eob_detail_rec eob_detail_rec_t;
    begin
        l_eob_detail_rec.line_no := 0;
        for x in (
            select
                nvl(ed.provider_payee_name, eh.provider_name)           service_provider,
                to_char(ed.service_date_from, 'MM/DD/YYYY')             service_date -- "Service Start Date"
                ,
                to_char(ed.service_date_to, 'MM/DD/YYYY')               service_end -- "Service End Date"
                ,
                nvl(ed.description,(ed.cpt_code
                                    || ed.benefit_type))                                    description_of_service -- "Service Description"
                                    ,
                ( ed.benefit_type
                  || ' - '
                  || ed.provider_payee_name )                             description,
                nvl(ed.amount_charged, 0)                               charged_amt,
                nvl(ed.amount_charged, 0) - nvl(amount_withdiscount, 0) disc_amt,
                nvl(amount_withdiscount, 0)                             discount_amt,
                nvl(ed.amount_excluded, ed.amount_notcovered)           excluded_amt -- " Excluded Amount "
                ,
                nvl(ed.covered_expense, ed.amount_paidbyins)            covered_amt,
                nvl(ed.amount_coinsurance, 0)                           coinsurance,
                nvl(ed.amount_copay, 0)                                 copay,
                nvl(ed.amount_deductible, 0)                            deductible,
                nvl(ed.cob_paid, 0)                                     cob_paid,
                nvl(ed.amount_paidbyins, 0)                             paid_amt,
                to_char(
                    nvl(ed.received_date, eh.creation_date),
                    'MM/DD/YYYY'
                )                                                       date_recd_in_office --"Date Received in Office"
                ,
                to_char(ed.processed_date, 'MM/DD/YYYY')                processed_date,
                ed.final_patient_amount                                 final_patient_amount,
                to_char(eh.creation_date, 'MM/DD/YYYY')                 creation_date,
                ed.patient_responsibility,
                ed.state_tax,
                ed.eob_detail_id,
                eh.eob_id
            from
                eob_header eh,
                eob_detail ed
            where
                    eh.claim_number = p_eob_id
                and eh.eob_id = ed.eob_id
                and eh.eob_id in (
                    select
                        max(eob_id)
                    from
                        eob_header b
                    where
                        eh.claim_number = b.claim_number
                )
        ) loop
            l_eob_detail_rec.line_no := l_eob_detail_rec.line_no + 1;
            l_eob_detail_rec.service_provider := x.service_provider;
            l_eob_detail_rec.service_date_from := x.service_date;
            l_eob_detail_rec.service_date_to := x.service_end;
            l_eob_detail_rec.service_desc := x.description_of_service;
            l_eob_detail_rec.charged_amt := x.charged_amt;
            l_eob_detail_rec.disc_amt := x.disc_amt;
            l_eob_detail_rec.excluded_amt := nvl(x.excluded_amt, 0);
            l_eob_detail_rec.covered_amt := nvl(x.covered_amt, 0);
            l_eob_detail_rec.coinsurance_amt := x.coinsurance;
            l_eob_detail_rec.co_pay_amt := x.copay;
            l_eob_detail_rec.deductible_amt := x.deductible;
            l_eob_detail_rec.cob_paid_amt := x.cob_paid;
            l_eob_detail_rec.paid_amt := x.paid_amt;
            l_eob_detail_rec.discount_amt := x.discount_amt;
            l_eob_detail_rec.cost_of_service_amt := x.final_patient_amount;
            l_eob_detail_rec.received_date := nvl(x.date_recd_in_office, x.creation_date);
            l_eob_detail_rec.processed_date := x.processed_date;
            l_eob_detail_rec.description := x.description;
            l_eob_detail_rec.patient_responsibility := nvl(x.patient_responsibility, x.final_patient_amount);
            l_eob_detail_rec.state_tax := x.state_tax;
            l_eob_detail_rec.eob_detail_id := x.eob_detail_id;
            l_eob_detail_rec.discount_amt := x.discount_amt;
            l_eob_detail_rec.eob_id := x.eob_id;
            pipe row ( l_eob_detail_rec );
        end loop;

    end get_eob_detail_info;

    function get_eob_exists (
        p_acc_id in number
    ) return varchar2 is
 ---- This function returns true if claims are associated for the account id passed  ----

        v_count number;
    begin
        select
            max(cnt)
        into v_count
        from
            (
                select
                    count(*) cnt
                from
                    account    acc,
                    person     p,
                    insure     i,
                    eob_header eb
                where
                        acc.acc_id = p_acc_id
                    and acc.pers_id = p.pers_id
                    and p.pers_id = i.pers_id
                    and i.insurance_member_id = eb.member_id
                    and eb.claim_id is null
                union all
                select
                    count(*) cnt
                from
                    account      acc,
                    person       p,
                    eob_header   eb,
                    online_users ou
                where
                        acc.acc_id = p_acc_id
                    and ou.tax_id = replace(p.ssn, '-')
                    and acc.pers_id = p.pers_id
                    and eb.user_id = ou.user_id
                    and ou.user_status = 'A'
                    and eb.claim_id is null
            );

        if v_count = 0 then
            return 'N';
        else
            return 'Y';
        end if;
    end;

    function get_eob_info (
        p_acc_id in number
    ) return eob_t
        pipelined
        deterministic
    is
-----This function returns eob data if exists for the account id passed ----
        l_eob_rec eob_rec_t;
        v_count   number;
    begin
        for x in (
            select
                eb.claim_number      eob_ref_no,
                p.first_name
                || ' '
                || p.last_name       patient_name,
                eb.provider_name,
                eb.source            eob_source -- "Claim Source"
                ,
                eb.eob_status_code   eob_status  -- "Claim Status"
                ,
                eb.service_date_from service_date_from -- "Service Start Date"
                ,
                eb.claim_id -- "Claim Number"
                ,
                p.pers_id,
                eb.eob_id,
                eb.description,
                eb.service_amount
            from
                account    acc,
                person     p,
                eob_header eb --, eob_detail ed
            where
                    acc.acc_id = p_acc_id
                and acc.pers_id = p.pers_id
                and eb.ssn = replace(p.ssn, '-')
            union all
            select
                eb.claim_number         eob_ref_no,
                eb.patient_first_name
                || ' '
                || eb.patient_last_name patient_name,
                eb.provider_name,
                eb.source               eob_source -- "Claim Source"
                ,
                eb.eob_status_code      eob_status  -- "Claim Status"
                ,
                eb.service_date_from    service_date_from -- "Service Start Date"
                ,
                eb.claim_id -- "Claim Number"
                ,
                p.pers_id,
                eb.eob_id,
                eb.description,
                eb.service_amount
            from
                account      acc,
                person       p,
                eob_header   eb,
                online_users ou
            where
                    acc.acc_id = p_acc_id
                and ou.tax_id = replace(p.ssn, '-')
                and acc.pers_id = p.pers_id
                and eb.user_id = ou.user_id
                and ou.user_status = 'A'
                and eb.eob_id in (
                    select
                        max(eob_id)
                    from
                        account      acc, person       p, eob_header   eb, online_users ou
                    where
                            acc.acc_id = p_acc_id
                        and ou.tax_id = replace(p.ssn, '-')
                        and acc.pers_id = p.pers_id
                        and eb.user_id = ou.user_id
                        and ou.user_status = 'A'
                    group by
                        acc.pers_id, acc.acc_id, claim_number, service_date_from
                )
        ) loop
            l_eob_rec.eob_ref_no := x.eob_ref_no;
            l_eob_rec.patient_name := x.patient_name;
            l_eob_rec.provider_name := x.provider_name;
            l_eob_rec.eob_source := x.eob_source;
            l_eob_rec.eob_status := x.eob_status;
            l_eob_rec.eob_id := x.eob_id;
            l_eob_rec.description := x.description;
            l_eob_rec.service_amount := x.service_amount;
            for xx in (
                select
                    max(received_date)  received_date,
                    max(processed_date) processed_date,
                    nvl(
                        sum(charged_amt),
                        0
                    )                   charged_amt,
                    nvl(
                        sum(patient_responsibility),
                        0
                    )                   eob_balance
                from
                    table ( pc_eob_utility.get_eob_detail_info(x.eob_ref_no) )
            ) loop
                l_eob_rec.received_date := xx.received_date;
                l_eob_rec.processed_date := xx.processed_date;
                l_eob_rec.charged_amt := xx.charged_amt;
                l_eob_rec.eob_balance := xx.eob_balance;
            end loop;

     /* L_EOB_REC.RECEIVED_DATE := NVL(L_EOB_REC.RECEIVED_DATE,NULL);
          L_EOB_REC.PROCESSED_DATE := NVL(L_EOB_REC.PROCESSED_DATE,NULL);
          L_EOB_REC.CHARGED_AMT := NVL(L_EOB_REC.CHARGED_AMT,0);
          L_EOB_REC.EOB_BALANCE := NVL(L_EOB_REC.EOB_BALANCE,0);
    */
            l_eob_rec.service_date_from := x.service_date_from;
            l_eob_rec.claim_id := x.claim_id;
            l_eob_rec.disbursement_date := null;
            l_eob_rec.service := null;
            dbms_output.put_line('In loop' || x.eob_ref_no);
            pc_eob_upload.log_eob_error('eob_utilitygeteobinfo', x.eob_ref_no || l_eob_rec.charged_amt);
            if x.claim_id is not null then
                begin
                    select
                        to_char(claim_date, 'MM/DD/YYYY')
                    into l_eob_rec.disbursement_date
                    from
                        claimn cl
                    where
                        cl.claim_id = x.claim_id;

                exception
                    when others then
                        l_eob_rec.disbursement_date := null;
                end;
            end if;

            v_count := 0;
            select
                count(*)
            into v_count
            from
                eob_detail
            where
                eob_id = x.eob_id;

            if v_count > 1 then
                l_eob_rec.service := 'Multiple';
            else
                begin
                    select
                        benefit_type
                    into l_eob_rec.service
                    from
                        eob_detail
                    where
                        eob_id = x.eob_id;

                exception
                    when others then
                        l_eob_rec.service := null;
                end;
            end if;

            pipe row ( l_eob_rec );
        end loop;
    exception
        when others then
            pc_eob_upload.log_eob_error('eob_utilitygeteobinfo', sqlerrm);
    end get_eob_info;

    function get_allow_eob (
        p_pers_id in number
    ) return varchar2 is
---- This function checks if employer has allowed eob for the passed pers id ----
        l_enterprise_id varchar2(100);
        l_allow_eob     varchar2(100);
    begin
        begin
            select
                entrp_id
            into l_enterprise_id
            from
                person
            where
                pers_id = p_pers_id;

        exception
            when others then
                l_enterprise_id := null;
        end;

        begin
            select distinct
                allow_eob
            into l_allow_eob
            from
                account_preference
            where
                entrp_id = l_enterprise_id;

        exception
            when others then
                l_allow_eob := 'Y';
        end;

        return ( l_allow_eob );
    end get_allow_eob;

    function array_fill (
        p_array       eobrefno_tbl,
        p_array_count number
    ) return eobrefno_tbl is
        l_array eobrefno_tbl;
    begin
        for i in 1..p_array_count loop
            if ( p_array.exists(i) ) then
                l_array(i) := p_array(i);
            else
                l_array(i) := null;
            end if;
        end loop;

        return l_array;
    end array_fill;

    procedure associate_eob (
        p_claimid in number,
        p_accid   in number,
        p_eobref  in eobrefno_tbl
    ) is
--- This procedure associates all the eobs passed to the claimid passed for the account passed ----
---- This procedure is used to perform the action online -----
        l_eobno_rec eobrefno_tbl;
        l_status    varchar2(100);
    begin
        l_eobno_rec := array_fill(p_eobref, p_eobref.count);
        begin
            select
                nvl(claim_status, null)
            into l_status
            from
                claimn c
            where
                c.claim_id = p_claimid;

        exception
            when no_data_found then
                l_status := null;
            when others then
                null;
        end;

        if l_status in ( 'PENDING', 'APPROVED_FOR_CHEQUE', 'PENDING_DOC', 'PENDING_REVIEW', 'PENDING_APPROVAL',
                         'APPROVED_NO_FUNDS', 'READY_TO_PAY' ) then
            l_status := 'PENDING';
        elsif l_status in ( 'PAID', 'PARTIALLY_PAID' ) then
            l_status := 'PAID';
        else
            l_status := 'NEW';
        end if;

        for i in 1..l_eobno_rec.count loop
            update eob_header
            set
                claim_id = p_claimid,
                acc_id = p_accid,
           --  USER_ID = P_USERID,
                eob_status_code = l_status,
                eob_status = pc_lookups.get_claim_status(l_status),
                last_update_date = sysdate,
                last_updated_by = 0
            where
                claim_number = l_eobno_rec(i);

            insert into file_attachments (
                attachment_id,
                document_name,
                document_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entity_name,
                entity_id,
                attachment
            )
                select
                    file_attachments_seq.nextval,
                    document_name,
                    document_type,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    'CLAIMN',
                    to_char(p_claimid),
                    attachment
                from
                    file_attachments
                where
                        entity_id = l_eobno_rec(i)
                    and entity_name = 'EOB';

        end loop;

        pc_claim.update_claim_to_review(p_claimid, 0);
        commit;
    exception
        when others then
            pc_eob_upload.log_eob_error('ASSOCIATE EOB ONLINE ', sqlerrm);
    end associate_eob;

    procedure reassociate_eob (
        p_claimid in number
    ) is
--- This procedure de-associates all the eobs associated from the claimid passed ----
---- This procedure is used to perform the action online -----
    begin
        update eob_header
        set
            claim_id = null,
            acc_id = null,
            -- USER_ID = NULL,
            eob_status = 'NEW',
            eob_status_code = 'NEW',
            last_update_date = sysdate
        where
            claim_id = p_claimid;

        commit;
    exception
        when others then
            pc_eob_upload.log_eob_error('REASSOCIATE EOB ONLINE ', sqlerrm);
    end reassociate_eob;

    procedure update_eob_status is
/* This is a nightly process used to update eob status same as claim status
     for all the eobs associated to any claims. EOB Status would be either updated
     to NEW, PENDING OR PAID accordingly. */
        l_status varchar2(100);
    begin
        for x in (
            select
                b.claim_id,
                e.eob_status_code,
                b.claim_status,
                e.source,
                e.eob_id
            from
                eob_header e,
                claimn     b
            where
                    e.claim_id = b.claim_id
                and e.eob_status_code <> b.claim_status
                and e.source in ( 'CARRIER_FEED', 'HEALTH_EXPENSE' )
        ) loop
            if x.claim_status in ( 'PENDING', 'APPROVED_FOR_CHEQUE', 'PENDING_DOC', 'PENDING_REVIEW', 'PENDING_APPROVAL',
                                   'APPROVED_NO_FUNDS', 'READY_TO_PAY' ) then
                l_status := 'PENDING';
                update eob_header
                set
                    eob_status = pc_lookups.get_claim_status(l_status),
                    eob_status_code = l_status,
                    last_update_date = sysdate
                where
                    claim_id = x.claim_id;

            elsif x.claim_status in ( 'PAID', 'PARTIALLY_PAID' ) then
                l_status := 'PAID';
                update eob_header
                set
                    eob_status = pc_lookups.get_claim_status(l_status),
                    eob_status_code = l_status,
                    last_update_date = sysdate
                where
                    claim_id = x.claim_id;

            elsif x.claim_status = 'CANCELLED' then
                l_status := 'NEW';
                update eob_header
                set
                    claim_id = null,
                    acc_id = null,
                    user_id = null,
                    eob_status = l_status,
                    eob_status_code = l_status,
                    last_update_date = sysdate
                where
                    claim_id = x.claim_id;

            end if;

            if x.source = 'HEALTH_EXPENSE' then
                update eob_detail
                set
                    processed_date = sysdate
                where
                    eob_id = x.eob_id;

            end if;

        end loop;

        commit;
    exception
        when others then
            pc_eob_upload.log_eob_error('UPDATE EOB STATUS ', sqlerrm);
    end update_eob_status;

    procedure update_eob_userid is
/* This is a nightly process used to update user id for all the eobs based on the
   member_id->persid->ssn accordingly. */
    begin
        for x in (
            select
                e.member_id,
                e.eob_id
            from
                eob_header e
            where
                e.claim_id is null
                and e.source = 'SEECHANGE_FEED'
        ) loop
            update eob_header
            set
                user_id = (
                    select
                        user_id
                    from
                        insure       m,
                        person       p,
                        online_users u
                    where
                            m.insurance_member_id = x.member_id
                        and m.pers_id = p.pers_id
                        and format_ssn(u.tax_id) = p.ssn
                        and user_status = 'A'
                        and rownum = 1
                ),
                last_update_date = sysdate
            where
                eob_id = x.eob_id;

        end loop;

        commit;
    exception
        when others then
            pc_eob_upload.log_eob_error('UPDATE EOB STATUS ', sqlerrm);
    end update_eob_userid;

end pc_eob_utility;
/

