-- liquibase formatted sql
-- changeset SAMQA:1754373983952 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_cobra_disbursement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_cobra_disbursement.sql:null:7205b17a3923da979e34dadc5038beb1fd944557:create

create or replace package body samqa.pc_cobra_disbursement is

    procedure process_div_cur_month_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_last_end_date in date,
        p_client_id     in number
    ) is
    begin
        insert into cobra_disbursement_staging (
            cobra_disburse_stage_id,
            client_id,
            clientgroup_id,
            client_name,
            division_id,
            division_name,
            memberid,
            qb_first_name,
            qb_last_name,
            carrier_name,
            plan_name,
            policy_number,
            carrier_first_name,
            carrier_last_name,
            carrier_phone,
            carrier_address1,
            carrier_address2,
            carrier_city,
            carrier_state,
            carrier_postal_code,
            active,
            payment_source,
            premium_amount,
            allocated_amount,
            admin_fee,
            premiumduedate,
            premium_start_date,
            premium_end_date,
            deposit_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id,
            postmark_date,
            qbpaymentid
        )
            select
                cobra_disbursement_staging_seq.nextval,
                clientid,
                clientgroupid,
                clientname,
                clientdivisionid,
                divisionname,
                memberid,
                qb_first_name,
                qb_last_name,
                carriername,
                planname,
                policy_number,
                firstname,
                lastname,
                phone,
                address1,
                address2,
                city,
                state,
                postalcode,
                active,
                ord,
                premium,
                allocated,
                adminfee,
                premiumduedate,
                premiumstartdate,
                last_day(premiumstartdate),
                depositdate,
                sysdate,
                0,
                sysdate,
                0,
                get_entrp_id_for_vendor(clientid, 'COBRA'),
                postmarkdate,
                qbpaymentid
            from
                (
                    select distinct
                        c.clientname,
                        'DIVISION'                                                           ord,
                        c.clientid,
                        c.clientgroupid,
                        qb.lastname                                                          qb_last_name,
                        qb.firstname                                                         qb_first_name,
                        a.planname                                                           planname,
                        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
                        round(a.allocatedamount, 2)                                          allocated,
                        round(a.adminfee, 2)                                                 adminfee,
                        cd.divisionname,
                        qb.memberid,
                        cd.clientdivisionid,
                        trunc(a.premiumduedate)                                              premiumduedate,
                        case
                            when cast(premiumduedate as date) < p_start_date then
                                p_start_date
                            else
                                cast(premiumduedate as date)
                        end                                                                  premiumstartdate,
                        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
                        v.carrierplanidentification                                          policy_number,
                        c.clientname                                                         firstname,
                        ''                                                                   lastname,
                        c.phone                                                              phone,
                        c.address1                                                           address1,
                        c.address2                                                           address2,
                        c.city                                                               city,
                        c.state                                                              state,
                        c.postalcode                                                         postalcode,
                        '1'                                                                  active,
                        c.clientname                                                         carriername,
                        a.entereddatetime                                                    depositdate,
                        trunc(a.postmarkdate)                                                postmarkdate,
                        a.qbpaymentid
                    from
                        qbpayment            a,
                        qbplan               b,
                        clientplanqb         v,
                        client               c,
                        clientdivision       cd,
                        clientdivisionqbplan cdq,
                        carrier              cr,
                        qb
                    where
                            c.clientid = nvl(p_client_id, c.clientid)
                        and a.planname = b.planname
                        and a.memberid = b.memberid
                        and qb.clientdivisionid = cd.clientdivisionid
                        and b.clientplanqbid = v.clientplanqbid
                        and cdq.clientdivisionid = cd.clientdivisionid
                        and cr.carrierid = v.carrierid
                        and c.clientid = cd.clientid
                        and a.isvoid = 0
                        and nvl(a.paymentmethod, '-1') <> 'NONCASHNONREMITTED'
		--	AND GREATEST(LEAST(TRUNC(A.DEPOSITDATE),TRUNC(A.POSTMARKDATE))
     -- ,TRUNC(A.PREMIUMDUEDATE)) BETWEEN p_start_date AND p_end_date
                        and greatest(cast(a.entereddatetime as date),
                                     trunc(a.premiumduedate)) between p_start_date and p_end_date
                        and trunc(a.premiumduedate) between p_start_date and last_day(p_start_date)
                        and v.clientid = c.clientid
                        and qb.memberid = a.memberid
                );

    end process_div_cur_month_premium;

    procedure process_div_prev_month_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_last_end_date in date,
        p_client_id     in number
    ) is
    begin
        insert into cobra_disbursement_staging (
            cobra_disburse_stage_id,
            client_id,
            clientgroup_id,
            client_name,
            division_id,
            division_name,
            memberid,
            qb_first_name,
            qb_last_name,
            carrier_name,
            plan_name,
            policy_number,
            carrier_first_name,
            carrier_last_name,
            carrier_phone,
            carrier_address1,
            carrier_address2,
            carrier_city,
            carrier_state,
            carrier_postal_code,
            active,
            payment_source,
            premium_amount,
            allocated_amount,
            admin_fee,
            premiumduedate,
            premium_start_date,
            premium_end_date,
            deposit_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id,
            postmark_date,
            qbpaymentid
        )
            select
                cobra_disbursement_staging_seq.nextval,
                clientid,
                clientgroupid,
                clientname,
                clientdivisionid,
                divisionname,
                memberid,
                qb_first_name,
                qb_last_name,
                carriername,
                planname,
                policy_number,
                firstname,
                lastname,
                phone,
                address1,
                address2,
                city,
                state,
                postalcode,
                active,
                ord,
                premium,
                allocated,
                adminfee,
                premiumduedate,
                premiumstartdate,
                last_day(premiumstartdate),
                depositdate,
                sysdate,
                0,
                sysdate,
                0,
                get_entrp_id_for_vendor(clientid, 'COBRA'),
                postmarkdate,
                qbpaymentid
            from
                (
                    select distinct
                        c.clientname,
                        'DIVISION'                                                           ord,
                        c.clientid,
                        c.clientgroupid,
                        qb.lastname                                                          qb_last_name,
                        qb.firstname                                                         qb_first_name,
                        a.planname                                                           planname,
                        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
                        round(a.allocatedamount, 2)                                          allocated,
                        round(a.adminfee, 2)                                                 adminfee,
                        cd.divisionname,
                        qb.memberid,
                        cd.clientdivisionid,
                        trunc(a.premiumduedate)                                              premiumduedate,
                        case
                            when cast(premiumduedate as date) < p_start_date then
                                p_start_date
                            else
                                cast(premiumduedate as date)
                        end                                                                  premiumstartdate,
                        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
                        v.carrierplanidentification                                          policy_number,
                        c.clientname                                                         firstname,
                        ''                                                                   lastname,
                        c.phone                                                              phone,
                        c.address1                                                           address1,
                        c.address2                                                           address2,
                        c.city                                                               city,
                        c.state                                                              state,
                        c.postalcode                                                         postalcode,
                        '1'                                                                  active,
                        c.clientname                                                         carriername,
                        a.entereddatetime                                                    depositdate,
                        trunc(a.postmarkdate)                                                postmarkdate,
                        a.qbpaymentid
                    from
                        qbpayment            a,
                        qbplan               b,
                        clientplanqb         v,
                        client               c,
                        clientdivision       cd,
                        clientdivisionqbplan cdq,
                        carrier              cr,
                        qb
                    where
                            c.clientid = nvl(p_client_id, c.clientid)
                        and a.planname = b.planname
                        and a.memberid = b.memberid
                        and a.isvoid = 0
                        and nvl(a.paymentmethod, '-1') <> 'NONCASHNONREMITTED'
                        and qb.clientdivisionid = cd.clientdivisionid
                        and b.clientplanqbid = v.clientplanqbid
                        and cdq.clientdivisionid = cd.clientdivisionid
                        and cr.carrierid = v.carrierid
                        and c.clientid = cd.clientid
                        and greatest(cast(a.entereddatetime as date),
                                     trunc(a.premiumduedate)) between p_last_end_date and p_end_date
                        and trunc(a.premiumduedate) < p_start_date
                        and v.clientid = c.clientid
                        and qb.memberid = a.memberid
                );

    end process_div_prev_month_premium;

    procedure process_nodiv_curr_mon_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_last_end_date in date,
        p_client_id     in number
    ) is
    begin
        insert into cobra_disbursement_staging (
            cobra_disburse_stage_id,
            client_id,
            clientgroup_id,
            client_name,
            memberid,
            qb_first_name,
            qb_last_name,
            carrier_name,
            plan_name,
            policy_number,
            carrier_first_name,
            carrier_last_name,
            carrier_phone,
            carrier_address1,
            carrier_address2,
            carrier_city,
            carrier_state,
            carrier_postal_code,
            active,
            payment_source,
            premium_amount,
            allocated_amount,
            admin_fee,
            premiumduedate,
            premium_start_date,
            premium_end_date,
            deposit_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id,
            postmark_date,
            qbpaymentid
        )
            select
                cobra_disbursement_staging_seq.nextval,
                clientid,
                clientgroupid,
                clientname,
                memberid,
                qb_first_name,
                qb_last_name,
                carriername,
                planname,
                policy_number,
                firstname,
                lastname,
                phone,
                address1,
                address2,
                city,
                state,
                postalcode,
                active,
                ord,
                premium,
                allocated,
                adminfee,
                premiumduedate,
                premiumstartdate,
                last_day(premiumstartdate),
                depositdate,
                sysdate,
                0,
                sysdate,
                0,
                get_entrp_id_for_vendor(clientid, 'COBRA'),
                postmarkdate,
                qbpaymentid
            from
                (
                    select distinct
                        c.clientname,
                        'NODIVISION'                                                         ord,
                        c.clientid,
                        c.clientgroupid,
                        qb.lastname                                                          qb_last_name,
                        qb.firstname                                                         qb_first_name,
                        a.planname                                                           planname,
                        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
                        round(a.allocatedamount, 2)                                          allocated,
                        round(a.adminfee, 2)                                                 adminfee,
                        null,
                        qb.memberid,
                        null,
                        trunc(a.premiumduedate)                                              premiumduedate,
                        case
                            when cast(premiumduedate as date) < p_start_date then
                                p_start_date
                            else
                                cast(premiumduedate as date)
                        end                                                                  premiumstartdate,
                        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
                        v.carrierplanidentification                                          policy_number,
                        c.clientname                                                         firstname,
                        ''                                                                   lastname,
                        c.phone                                                              phone,
                        c.address1                                                           address1,
                        c.address2                                                           address2,
                        c.city                                                               city,
                        c.state                                                              state,
                        c.postalcode                                                         postalcode,
                        '1'                                                                  active,
                        c.clientname                                                         carriername,
                        a.entereddatetime                                                    depositdate,
                        trunc(a.postmarkdate)                                                postmarkdate,
                        a.qbpaymentid
                    from
                        qbpayment    a,
                        qbplan       b,
                        clientplanqb v,
                        client       c,
                        carrier      cr,
                        qb
                    where
                            c.clientid = nvl(p_client_id, c.clientid)
                        and greatest(cast(a.entereddatetime as date),
                                     trunc(a.premiumduedate)) between p_start_date and p_end_date
                        and trunc(a.premiumduedate) between p_start_date and last_day(p_start_date)
                        and qb.memberid = a.memberid
                        and a.planname = b.planname
                        and a.memberid = b.memberid
                        and a.isvoid = 0
                        and nvl(a.paymentmethod, '-1') <> 'NONCASHNONREMITTED'
                        and b.clientplanqbid = v.clientplanqbid
                        and cr.carrierid = v.carrierid
                        and v.clientid = c.clientid
                        and not exists (
                            select
                                *
                            from
                                clientdivision       cd,
                                clientdivisionqbplan cdq
                            where
                                    qb.clientdivisionid = cd.clientdivisionid
                                and c.clientid = cd.clientid
                                and cdq.clientdivisionid = cd.clientdivisionid
                        )
                );

    end process_nodiv_curr_mon_premium;

    procedure process_nodiv_prev_mon_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_last_end_date in date,
        p_client_id     in number
    ) is
    begin
        insert into cobra_disbursement_staging (
            cobra_disburse_stage_id,
            client_id,
            clientgroup_id,
            client_name,
            memberid,
            qb_first_name,
            qb_last_name,
            carrier_name,
            plan_name,
            policy_number,
            carrier_first_name,
            carrier_last_name,
            carrier_phone,
            carrier_address1,
            carrier_address2,
            carrier_city,
            carrier_state,
            carrier_postal_code,
            active,
            payment_source,
            premium_amount,
            allocated_amount,
            admin_fee,
            premiumduedate,
            premium_start_date,
            premium_end_date,
            deposit_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id,
            postmark_date,
            qbpaymentid
        )
            select
                cobra_disbursement_staging_seq.nextval,
                clientid,
                clientgroupid,
                clientname,
                memberid,
                qb_first_name,
                qb_last_name,
                carriername,
                planname,
                policy_number,
                firstname,
                lastname,
                phone,
                address1,
                address2,
                city,
                state,
                postalcode,
                active,
                ord,
                premium,
                allocated,
                adminfee,
                premiumduedate,
                premiumstartdate,
                last_day(premiumstartdate),
                depositdate,
                sysdate,
                0,
                sysdate,
                0,
                get_entrp_id_for_vendor(clientid, 'COBRA'),
                postmarkdate,
                qbpaymentid
            from
                (
                    select distinct
                        c.clientname,
                        'NODIVISION'                                                         ord,
                        c.clientid,
                        c.clientgroupid,
                        qb.lastname                                                          qb_last_name,
                        qb.firstname                                                         qb_first_name,
                        a.planname                                                           planname,
                        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
                        round(a.allocatedamount, 2)                                          allocated,
                        round(a.adminfee, 2)                                                 adminfee,
                        null,
                        qb.memberid,
                        null,
                        trunc(a.premiumduedate)                                              premiumduedate,
                        case
                            when cast(premiumduedate as date) < p_start_date then
                                p_start_date
                            else
                                cast(premiumduedate as date)
                        end                                                                  premiumstartdate,
                        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
                        v.carrierplanidentification                                          policy_number,
                        c.clientname                                                         firstname,
                        ''                                                                   lastname,
                        c.phone                                                              phone,
                        c.address1                                                           address1,
                        c.address2                                                           address2,
                        c.city                                                               city,
                        c.state                                                              state,
                        c.postalcode                                                         postalcode,
                        '1'                                                                  active,
                        c.clientname                                                         carriername,
                        a.entereddatetime                                                    depositdate,
                        trunc(a.postmarkdate)                                                postmarkdate,
                        a.qbpaymentid
                    from
                        qbpayment    a,
                        qbplan       b,
                        clientplanqb v,
                        client       c,
                        carrier      cr,
                        qb
                    where
                            c.clientid = nvl(p_client_id, c.clientid)
                        and greatest(cast(a.entereddatetime as date),
                                     trunc(a.premiumduedate)) between p_last_end_date and p_end_date
                        and trunc(a.premiumduedate) < p_start_date
                        and qb.memberid = a.memberid
                        and a.planname = b.planname
                        and a.isvoid = 0
                        and nvl(a.paymentmethod, '-1') <> 'NONCASHNONREMITTED'
                        and a.memberid = b.memberid
                        and b.clientplanqbid = v.clientplanqbid
                        and cr.carrierid = v.carrierid
                        and v.clientid = c.clientid
                        and not exists (
                            select
                                *
                            from
                                clientdivision       cd,
                                clientdivisionqbplan cdq
                            where
                                    qb.clientdivisionid = cd.clientdivisionid
                                and c.clientid = cd.clientid
                                and cdq.clientdivisionid = cd.clientdivisionid
                        )
                );

    end process_nodiv_prev_mon_premium;

    procedure process_sbsdy_curr_mon_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_last_end_date in date,
        p_client_id     in number
    ) is
    begin
        insert into cobra_disbursement_staging (
            cobra_disburse_stage_id,
            client_id,
            clientgroup_id,
            client_name,
            memberid,
            qb_first_name,
            qb_last_name,
            carrier_name,
            plan_name,
            policy_number,
            carrier_first_name,
            carrier_last_name,
            carrier_phone,
            carrier_address1,
            carrier_address2,
            carrier_city,
            carrier_state,
            carrier_postal_code,
            active,
            payment_source,
            premium_amount,
            allocated_amount,
            admin_fee,
            premiumduedate,
            premium_start_date,
            premium_end_date,
            deposit_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id,
            postmark_date,
            qbpaymentid
        )
            select
                cobra_disbursement_staging_seq.nextval,
                clientid,
                clientgroupid,
                clientname,
                memberid,
                qb_first_name,
                qb_last_name,
                carriername,
                planname,
                policy_number,
                firstname,
                lastname,
                phone,
                address1,
                address2,
                city,
                state,
                postalcode,
                active,
                ord,
                premium,
                allocated,
                adminfee,
                premiumduedate,
                premiumstartdate,
                last_day(premiumstartdate),
                depositdate,
                sysdate,
                0,
                sysdate,
                0,
                get_entrp_id_for_vendor(clientid, 'COBRA'),
                postmarkdate,
                qbpaymentid
            from
                (
                    select distinct
                        c.clientname,
                        'SUBSIDY'                                                            ord,
                        c.clientid,
                        c.clientgroupid,
                        qb.lastname                                                          qb_last_name,
                        qb.firstname                                                         qb_first_name,
                        b.planname                                                           planname,
                        round(
                            case
                                when
                                    a.amount like '100%'
                                    and subsidyamounttype = 'PERCENTAGE'
                                then
                                    -d.rate *(to_number(replace(qbpremiumadminfee, '%', '')) / 100)
                            end,
                            2)                                                             premium,
                        round(
                            case
                                when
                                    a.amount like '100%'
                                    and subsidyamounttype = 'PERCENTAGE'
                                then
                                    -d.rate *(to_number(replace(qbpremiumadminfee, '%', '')) / 100)
                            end,
                            2)                                                             allocated,
                        round(
                            case
                                when
                                    a.amount like '100%'
                                    and subsidyamounttype = 'PERCENTAGE'
                                then
                                    -d.rate *(to_number(replace(qbpremiumadminfee, '%', '')) / 100)
                            end,
                            2)                                                             adminfee,
                        null,
                        qb.memberid,
                        null,
                        p_start_date                                                         premiumduedate,
                        p_start_date                                                         premiumstartdate,
                        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
                        v.carrierplanidentification                                          policy_number,
                        c.clientname                                                         firstname,
                        ''                                                                   lastname,
                        c.phone                                                              phone,
                        c.address1                                                           address1,
                        c.address2                                                           address2,
                        c.city                                                               city,
                        c.state                                                              state,
                        c.postalcode                                                         postalcode,
                        '1'                                                                  active,
                        c.clientname                                                         carriername,
                        p_start_date                                                         depositdate,
                        p_start_date                                                         postmarkdate,
                        null                                                                 qbpaymentid
                    from
                        cobrap.qbsubsidyschedule a,
                        qbplan                   b,
                        clientplanqb             v,
                        clientplanqbrate         d,
                        client                   c,
                        qb
                    where
                            c.clientid = nvl(p_client_id, c.clientid)
                        and subsidytype = 'EMPLOYER'
                        and subsidyamounttype = 'PERCENTAGE'
                        and b.terminationdate >= p_start_date
                        and d.billingdate <= p_start_date
                        and a.startdate <= p_start_date
                        and nvl(a.enddate,
                                last_day(p_start_date)) >= last_day(p_start_date)
                        and nvl(d.enddate,
                                last_day(p_start_date)) >= last_day(p_start_date)
                        and b.startdate <= p_start_date
                        and nvl(b.enddate,
                                last_day(p_start_date)) >= last_day(p_start_date)
                        and a.memberid = b.memberid
                        and a.insurancetype = b.insurancetype
                        and b.clientplanqbid = v.clientplanqbid
                        and v.clientplanqbid = d.clientplanqbid
                        and d.qbcoveragelevel = b.coveragelevel
                        and v.clientid = c.clientid
                        and qb.memberid = a.memberid
                        and ( strip_bad(d.memberid) is null
                              or strip_bad(d.memberid) like a.memberid || '%' )
                        and not exists (
                            select
                                *
                            from
                                clientdivision       cd,
                                clientdivisionqbplan cdq
                            where
                                    qb.clientdivisionid = cd.clientdivisionid
                                and c.clientid = cd.clientid
                                and cdq.clientdivisionid = cd.clientdivisionid
                        )
                );

    end process_sbsdy_curr_mon_premium;

    procedure process_sbsdy_prev_mon_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_last_end_date in date,
        p_client_id     in number
    ) is
    begin
        insert into cobra_disbursement_staging (
            cobra_disburse_stage_id,
            client_id,
            clientgroup_id,
            client_name,
            memberid,
            qb_first_name,
            qb_last_name,
            carrier_name,
            plan_name,
            policy_number,
            carrier_first_name,
            carrier_last_name,
            carrier_phone,
            carrier_address1,
            carrier_address2,
            carrier_city,
            carrier_state,
            carrier_postal_code,
            active,
            payment_source,
            premium_amount,
            allocated_amount,
            admin_fee,
            premiumduedate,
            premium_start_date,
            premium_end_date,
            deposit_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id,
            postmark_date,
            qbpaymentid
        )
            select
                cobra_disbursement_staging_seq.nextval,
                clientid,
                clientgroupid,
                clientname,
                memberid,
                qb_first_name,
                qb_last_name,
                carriername,
                planname,
                policy_number,
                firstname,
                lastname,
                phone,
                address1,
                address2,
                city,
                state,
                postalcode,
                active,
                ord,
                premium,
                allocated,
                adminfee,
                premiumduedate,
                premiumstartdate,
                last_day(premiumstartdate),
                depositdate,
                sysdate,
                0,
                sysdate,
                0,
                get_entrp_id_for_vendor(clientid, 'COBRA'),
                postmarkdate,
                qbpaymentid
            from
                (
                    select distinct
                        c.clientname,
                        'SUBSIDY'                                                            ord,
                        c.clientid,
                        c.clientgroupid,
                        qb.lastname                                                          qb_last_name,
                        qb.firstname                                                         qb_first_name,
                        b.planname                                                           planname,
                        round(
                            case
                                when
                                    a.amount like '100%'
                                    and subsidyamounttype = 'PERCENTAGE'
                                then
                                    -d.rate *(to_number(replace(qbpremiumadminfee, '%', '')) / 100)
                            end,
                            2)                                                             premium,
                        round(
                            case
                                when
                                    a.amount like '100%'
                                    and subsidyamounttype = 'PERCENTAGE'
                                then
                                    -d.rate *(to_number(replace(qbpremiumadminfee, '%', '')) / 100)
                            end,
                            2)                                                             allocated,
                        round(
                            case
                                when
                                    a.amount like '100%'
                                    and subsidyamounttype = 'PERCENTAGE'
                                then
                                    -d.rate *(to_number(replace(qbpremiumadminfee, '%', '')) / 100)
                            end,
                            2)                                                             adminfee,
                        null,
                        qb.memberid,
                        null,
                        p_start_date                                                         premiumduedate,
                        p_start_date                                                         premiumstartdate,
                        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
                        v.carrierplanidentification                                          policy_number,
                        c.clientname                                                         firstname,
                        ''                                                                   lastname,
                        c.phone                                                              phone,
                        c.address1                                                           address1,
                        c.address2                                                           address2,
                        c.city                                                               city,
                        c.state                                                              state,
                        c.postalcode                                                         postalcode,
                        '1'                                                                  active,
                        c.clientname                                                         carriername,
                        p_start_date                                                         depositdate,
                        p_start_date                                                         postmarkdate,
                        null                                                                 qbpaymentid
                    from
                        cobrap.qbsubsidyschedule a,
                        qbplan                   b,
                        clientplanqb             v,
                        clientplanqbrate         d,
                        client                   c,
                        qb,
                        clientdivision           cd,
                        clientdivisionqbplan     cdq
                    where
                            c.clientid = nvl(p_client_id, c.clientid)
                        and subsidytype = 'EMPLOYER'
                        and subsidyamounttype = 'PERCENTAGE'
                        and b.terminationdate >= p_start_date
                        and d.billingdate <= p_start_date
                        and a.startdate <= p_start_date
                        and nvl(a.enddate,
                                last_day(p_start_date)) >= last_day(p_start_date)
                        and nvl(d.enddate,
                                last_day(p_start_date)) >= last_day(p_start_date)
                        and b.startdate <= p_start_date
                        and nvl(b.enddate,
                                last_day(p_start_date)) >= last_day(p_start_date)
                        and a.memberid = b.memberid
                        and qb.clientdivisionid = cd.clientdivisionid
                        and cdq.clientdivisionid = cd.clientdivisionid
                        and a.insurancetype = b.insurancetype
                        and b.clientplanqbid = v.clientplanqbid
                        and v.clientplanqbid = d.clientplanqbid
                        and d.qbcoveragelevel = b.coveragelevel
                        and v.clientid = c.clientid
                        and qb.memberid = a.memberid
                        and ( strip_bad(d.memberid) is null
                              or strip_bad(d.memberid) like a.memberid || '%' )
                );

    end process_sbsdy_prev_mon_premium;

    procedure populate_disbursement_staging (
        p_start_date         in date,
        p_end_date           in date,
        p_last_end_date      in date,
        p_report_date        in date,
        p_postmark_date_from in date,
        p_postmark_date_to   in date,
        p_client_id          in number
    ) is
    begin
        process_div_cur_month_premium(p_start_date, p_end_date, p_last_end_date, p_client_id);
        process_div_prev_month_premium(p_start_date, p_end_date, p_last_end_date, p_client_id);
        process_nodiv_curr_mon_premium(p_start_date, p_end_date, p_last_end_date, p_client_id);
        process_nodiv_prev_mon_premium(p_start_date, p_end_date, p_last_end_date, p_client_id);
        process_sbsdy_prev_mon_premium(p_start_date, p_end_date, p_last_end_date, p_client_id);
        process_sbsdy_prev_mon_premium(p_start_date, p_end_date, p_last_end_date, p_client_id);
    exception
        when others then
            raise;
    end populate_disbursement_staging;

    procedure populate_disbursement (
        p_start_date in date,
        p_end_date   in date,
        p_client_id  in number
    ) is
        l_cobra_disbursment_id number;
    begin
        for x in (
            select
                client_id,
                client_name,
                division_id,
                division_name,
                clientgroup_id,
                sum(premium_amount) premium_amount,
                premium_start_date,
                premium_end_date,
                carrier_first_name,
                carrier_last_name,
                carrier_phone,
                carrier_address1,
                carrier_address2,
                carrier_city,
                carrier_state,
                carrier_postal_code,
                entrp_id
            from
                (
                    select distinct
                        client_id,
                        client_name,
                        division_id,
                        division_name,
                        clientgroup_id,
                        premium_amount premium_amount,
                        premium_start_date,
                        premium_end_date,
                        premiumduedate,
                        carrier_first_name,
                        carrier_last_name,
                        carrier_phone,
                        carrier_address1,
                        carrier_address2,
                        carrier_city,
                        carrier_state,
                        carrier_postal_code,
                        a.entrp_id,
                        a.memberid
                    from
                        cobra_disbursement_staging a--,ACCOUNT_PREFERENCE ACC,  ACCOUNT AC
                    where
                            a.client_id = nvl(p_client_id, a.client_id)
                 --AND     A.ENTRP_ID = ACC.ENTRP_ID
                -- AND    AC.ENTRP_ID = ACC.ENTRP_ID
                -- AND    AC.ACCOUNT_STATUS = 1
                -- AND    ACC.CONSOLIDATED_BILLING = 'N'
                        and trunc(a.creation_date) >= trunc(sysdate - 1)
                )
            group by
                client_id,
                client_name,
                division_id,
                division_name,
                clientgroup_id,
                premium_start_date,
                premium_end_date,
                carrier_first_name,
                carrier_last_name,
                carrier_phone,
                carrier_address1,
                carrier_address2,
                carrier_city,
                carrier_state,
                carrier_postal_code,
                entrp_id
        ) loop
            l_cobra_disbursment_id := null;
            if x.premium_amount > 0 then
                insert into cobra_disbursements (
                    cobra_disbursement_id,
                    client_id,
                    clientgroup_id,
                    client_name,
                    division_id,
                    division_name,
                    premium_amount,
                    premium_start_date,
                    premium_end_date,
                    remittance_first_name,
                    remittance_last_name,
                    remittance_phone,
                    remittance_address1,
                    remittance_address2,
                    remittance_city,
                    remittance_state,
                    remittance_postal_code,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    entrp_id,
                    remittance_start_date,
                    remittance_end_date
                ) values ( cobra_disbursements_seq.nextval,
                           x.client_id,
                           x.clientgroup_id,
                           x.client_name,
                           x.division_id,
                           x.division_name,
                           x.premium_amount,
                           x.premium_start_date,
                           x.premium_end_date,
                           x.carrier_first_name,
                           x.carrier_last_name,
                           x.carrier_phone,
                           x.carrier_address1,
                           x.carrier_address2,
                           x.carrier_city,
                           x.carrier_state,
                           x.carrier_postal_code,
                           sysdate,
                           0,
                           sysdate,
                           0,
                           x.entrp_id,
                           p_start_date,
                           p_end_date ) returning cobra_disbursement_id into l_cobra_disbursment_id;

                update cobra_disbursements
                set
                    acc_num = pc_entrp.get_acc_num(entrp_id)
                where
                        creation_date > sysdate - 1
                    and acc_num is null;

                for xx in (
                    select
                        client_id,
                        client_name,
                        division_id,
                        division_name,
                        memberid,
                        qb_first_name,
                        qb_last_name,
                        carrier_name,
                        plan_name,
                        policy_number,
                        carrier_first_name,
                        carrier_last_name,
                        carrier_phone,
                        carrier_address1,
                        carrier_address2,
                        carrier_city,
                        carrier_state,
                        carrier_postal_code,
                        active,
                        payment_source,
                        premium_amount,
                        allocated_amount,
                        admin_fee,
                        premiumduedate,
                        premium_start_date,
                        premium_end_date,
                        deposit_date
                    from
                        cobra_disbursement_staging
                    where
                            client_id = x.client_id
                        and premium_start_date = x.premium_start_date
                        and premium_end_date = x.premium_end_date
                        and division_id = nvl(x.division_id, division_id)
                    union
                    select
                        client_id,
                        client_name,
                        division_id,
                        division_name,
                        memberid,
                        qb_first_name,
                        qb_last_name,
                        carrier_name,
                        plan_name,
                        policy_number,
                        carrier_first_name,
                        carrier_last_name,
                        carrier_phone,
                        carrier_address1,
                        carrier_address2,
                        carrier_city,
                        carrier_state,
                        carrier_postal_code,
                        active,
                        payment_source,
                        premium_amount,
                        allocated_amount,
                        admin_fee,
                        premiumduedate,
                        premium_start_date,
                        premium_end_date,
                        deposit_date
                    from
                        cobra_disbursement_staging
                    where
                            client_id = x.client_id
                        and premium_start_date = x.premium_start_date
                        and premium_end_date = x.premium_end_date
                        and division_id is null
                ) loop
                    insert into cobra_disbursement_detail (
                        cobra_disburse_det_id,
                        client_id,
                        client_name,
                        division_id,
                        division_name,
                        memberid,
                        qb_first_name,
                        qb_last_name,
                        carrier_name,
                        plan_name,
                        policy_number,
                        carrier_first_name,
                        carrier_last_name,
                        carrier_phone,
                        carrier_address1,
                        carrier_address2,
                        carrier_city,
                        carrier_state,
                        carrier_postal_code,
                        active,
                        payment_source,
                        premium_amount,
                        allocated_amount,
                        admin_fee,
                        premium_due_date,
                        premium_start_date,
                        premium_end_date,
                        deposit_date,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        cobra_disbursement_id
                    ) values ( cobra_disbursement_detail_seq.nextval,
                               xx.client_id,
                               xx.client_name,
                               xx.division_id,
                               xx.division_name,
                               xx.memberid,
                               xx.qb_first_name,
                               xx.qb_last_name,
                               xx.carrier_name,
                               xx.plan_name,
                               xx.policy_number,
                               xx.carrier_first_name,
                               xx.carrier_last_name,
                               xx.carrier_phone,
                               xx.carrier_address1,
                               xx.carrier_address2,
                               xx.carrier_city,
                               xx.carrier_state,
                               xx.carrier_postal_code,
                               xx.active,
                               xx.payment_source,
                               xx.premium_amount,
                               xx.allocated_amount,
                               xx.admin_fee,
                               xx.premiumduedate,
                               xx.premium_start_date,
                               xx.premium_end_date,
                               xx.deposit_date,
                               sysdate,
                               0,
                               sysdate,
                               0,
                               l_cobra_disbursment_id );

                end loop;

            end if;

        end loop;
    end populate_disbursement;

    function get_disbursement_report (
        p_cobra_disbursement_id in number
    ) return qb_statement_tbl
        pipelined
    is
        l_record qb_statement_rec;
    begin
        for x in (
            select distinct
                a.premium_start_date,
                a.premium_end_date,
                a.entrp_id,
                a.acc_num,
                b.division_name,
                b.memberid,
                b.carrier_first_name
                || ' '
                || b.carrier_last_name                    carrier,
                b.plan_name,
                a.client_id,
                b.premium_amount,
                b.qb_first_name
                || ', '
                || b.qb_last_name                         qb_name,
                to_char(b.premium_due_date, 'MM/DD/YYYY') premium_due_date
                   --   ,  b.deposit_date
            from
                cobra_disbursements       a,
                cobra_disbursement_detail b
            where
                    a.cobra_disbursement_id = b.cobra_disbursement_id
                and a.cobra_disbursement_id = p_cobra_disbursement_id
        ) loop
            l_record.billing_period := to_char(x.premium_start_date, 'Month YYYY');
            l_record.division_name := x.division_name;
            l_record.carrier := x.carrier;
            l_record.benefit_plan := x.plan_name;
            l_record.qb_name := x.qb_name;
            l_record.premium_amount := x.premium_amount;
            l_record.premium_due_date := x.premium_due_date;
       --  l_record.DEPOSIT_DATE  := x.DEPOSIT_DATE;
            l_record.client_id := x.client_id;
            l_record.qb_member_id := x.memberid;
            l_record.acc_num := x.acc_num;
            l_record.entrp_id := x.entrp_id;
            pipe row ( l_record );
        end loop;
    end get_disbursement_report;

    function get_disbursement_header (
        p_cobra_disbursement_id in number
    ) return cobra_address_tbl
        pipelined
    is
        l_record cobra_address_rec;
    begin
        l_record.from_name := 'Sterling Health Services Administration';
        l_record.from_address1 := 'PO Box 71107';
        l_record.from_address2 := 'COBRA Administration Dept';
        l_record.from_address3 := 'Oakland , CA 94612';
        for x in (
            select
                client_name,
                'Attn:'
                || remittance_first_name
                || ' '
                || remittance_last_name              remit_attn,
                remittance_address1,
                remittance_city
                || ' '
                || remittance_state
                || ','
                || remittance_postal_code            remit_address2,
                to_char(creation_date, 'MM/DD/YYYY') check_date,
                to_char(premium_start_date, 'Month YYYY')
                || ' Disbursement'                   check_note,
                client_id,
                entrp_id,
                acc_num
            from
                cobra_disbursements
            where
                cobra_disbursement_id = p_cobra_disbursement_id
        ) loop
            l_record.remit_name := x.client_name;
            l_record.remit_attn := x.remit_attn;
            l_record.remit_address1 := x.remittance_address1;
            l_record.remit_address2 := x.remit_address2;
            l_record.check_date := x.check_date;
            l_record.check_note := x.check_note;
            l_record.client_id := x.client_id;
            l_record.entrp_id := x.entrp_id;
            l_record.acc_num := x.acc_num;
            pipe row ( l_record );
        end loop;

    end get_disbursement_header;

    procedure run_cobra_disbursement (
        p_client_id     in number,
        p_end_date      in date,
        p_last_end_date in date
    ) is
        p_start_date     date;
   --  p_end_date   DATE;
        p_reprt_end_date date;
    begin

  /*    pc_cobra_disbursement.populate_disbursement_staging
         (p_start_date         => '01-APR-2017'
         ,p_end_date           => '07-MAY-2017'
         ,p_report_date        => SYSDATE
         ,p_postmark_date_from => '01-APR-2017'
         ,p_postmark_date_to   => '07-MAY-2017'
         );

      pc_cobra_disbursement.populate_disbursement  (p_start_date  => '01-APR-2017'
                                        ,p_end_date    => '30-APR-2017',p_client_id=>null);

     */
   --  p_start_date := TRUNC(TRUNC(SYSDATE,'MM')-1,'MM');
        p_start_date := '01-JUL-2023';
    -- p_last_end_date :=SYSDATE;
   --  p_END_date := '30-JUN-2023';

        p_reprt_end_date := trunc(sysdate, 'MM') - 1;
  --   p_reprt_end_date  := '30-NOV-2022';
  --   p_end_date := '08-JUL-2019';
     -- running on 7th june for 8th may

        pc_cobra_disbursement.populate_disbursement_staging(
            p_start_date         => p_start_date,
            p_end_date           => '31-JUL-2023' --p_end_date
            ,
            p_last_end_date      => sysdate --p_last_end_date
            ,
            p_report_date        => sysdate,
            p_postmark_date_from => p_start_date,
            p_postmark_date_to   => p_end_date,
            p_client_id          => p_client_id
        );

        pc_cobra_disbursement.populate_disbursement(
            p_start_date => p_start_date,
            p_end_date   => p_reprt_end_date,
            p_client_id  => p_client_id
        );

    exception
        when others then
            raise;
    end run_cobra_disbursement;

    procedure create_vendor_from_client is
    begin
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
        )
            select
                vendor_seq.nextval,
                client_id,
                nvl(division_name, client_name),
                remittance_address1,
                remittance_address2,
                remittance_city,
                remittance_state,
                remittance_postal_code,
                2400,
                acc_num,
                'N',
                sysdate,
                0,
                sysdate,
                0
            from
                cobra_disbursements;

    end create_vendor_from_client;

    function get_cobra_ach_claim_detail (
        p_trans_from_date in date,
        p_trans_to_date   in date
    ) return pc_claim.ach_claim_t
        pipelined
        deterministic
    is
        l_record pc_claim.ach_claim_row_t;
    begin
        for x in (
            select
                transaction_id,
                a.acc_num,
                b.name    name,
                transaction_date,
                a.total_amount,
                a.acc_id,
                b.entrp_id,
                a.error_message,
                c.account_status,
                nvl((
                    select
                        transaction_source
                    from
                        employer_payments
                    where
                        employer_payment_id = a.claim_id
                ), 'WEX') claim_source,
                'CCD'     standard_entry_class_code -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023  for employer it is CCD
                ,
                (
                    select
                        max(premium_start_date)
                    from
                        employer_payments ep,
                        cobra_payments    c
                    where
                            ep.employer_payment_id = a.claim_id
                        and ep.entrp_id = b.entrp_id
                        and c.cobra_payment_id = ep.cobra_disbursement_id
                )         premium_date                          --Added by Karthe on 09/26/2024
            from
                ach_transfer_v a,
                enterprise     b,
                account        c
            where
                    transaction_type = 'D'
                and a.acc_id = c.acc_id
                and a.status in ( 1, 2, 4 )    -- 4 Added by Swamy for Cobrapoint 02/11/2022
                and c.entrp_id = b.entrp_id
                and c.account_type = 'COBRA'
                and trunc(transaction_date) >= nvl(p_trans_from_date,
                                                   trunc(sysdate))
                and trunc(transaction_date) <= nvl(p_trans_to_date,
                                                   trunc(sysdate))
            union
            select
                transaction_id,
                a.acc_num,
                b.full_name name,
                transaction_date,
                a.total_amount,
                a.acc_id,
                b.pers_id,
                a.error_message,
                c.account_status,
                'Sterling',
                'PPD'       standard_entry_class_code        -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023  for employee it is PPD
                ,
                (
                    select
                        start_date
                    from
                        ar_invoice
                    where
                        invoice_id = a.invoice_id
                )           premium_date                     --Added by Karthe on 09/26/2024
            from
                ach_transfer_v a,
                person         b,
                account        c
            where
                    transaction_type = 'D'
                and a.acc_id = c.acc_id
                and a.status in ( 1, 2, 4 )     -- 4 Added by Swamy for Cobrapoint 02/11/2022
                and c.pers_id = b.pers_id
                and c.account_type = 'COBRA'
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
            l_record.acc_id := x.acc_id;
            l_record.note := x.error_message;
            l_record.account_status := x.account_status;
            l_record.claim_source := x.claim_source;
            l_record.standard_entry_class_code := x.standard_entry_class_code;   -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023
            l_record.premium_date := x.premium_date;                           -- Added by Karthe on 09/26/2024

            pipe row ( l_record );
        end loop;
    end get_cobra_ach_claim_detail;

    procedure process_cobra_disbursement (
        p_entrp_id       in number,
        p_reason_code    in number,
        p_claim_amount   in number,
        p_emp_payment_id in number,
        p_vendor_id      in number,
        p_bank_acct_id   in number,
        p_note           in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
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
        l_acc_id         number;
        l_check_number   number;
        l_transaction_id number;
        l_ach_trans_id   ach_transfer.transaction_id%type;  -- Added by Swamy for Cobra Duplicate issue
        l_claim_type     varchar2(150);    -- Added by Joshi for 11603
        l_claim_type_missing_excp exception; -- Added by Joshi for 11603
        l_status         varchar2(30);
    begin
        x_return_status := 'S';
        l_batch_number := batch_num_seq.nextval;
        pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement', 'p_emp_payment_id ' || p_emp_payment_id);
        pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement', 'p_bank_acct_id ' || p_bank_acct_id);
        pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement', 'p_reason_code ' || p_reason_code);
        pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement', 'p_vendor_id ' || p_vendor_id);

        -- Added by Joshi for #11603
       -- IF p_vendor_id  IS NOT NULL THEN
        for x in (
            select
                transaction_source,
                cobra_disbursement_id
            from
                employer_payments
            where
                employer_payment_id = p_emp_payment_id
        ) loop
            if x.transaction_source = 'STERLING' then
                l_claim_type := 'COBRA_PAYMENTS';
                    --Added by Karthe on 08/16/2024 
                     --Return Disbursement for Reason Codes 19-ePayment
                if p_reason_code = 29 then --Added by Karthe on 03-Oct-2024 for Returned ACH            
                    insert into employer_payments (
                        employer_payment_id,
                        entrp_id,
                        check_date,
                        check_number,
                        transaction_date,
                        reason_code,
                        check_amount,
                        plan_type,
                        show_online_flag,
                        note,
                        bank_acct_id,
                        memo,
                        cobra_disbursement_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        payment_register_id,
                        transaction_source,
                        payment_status
                    )
                        select
                            employer_payments_seq.nextval,
                            entrp_id,
                            sysdate,
                            p_emp_payment_id,
                            sysdate,
                            29,
                            - check_amount,
                            'COBRA',
                            'Y',
                            'ACH Return the payment for '
                            || sysdate
                            || ',cobra payment id'
                            || cobra_disbursement_id,
                            bank_acct_id,
                            'ACH Return the payment for '
                            || sysdate
                            || ',cobra payment id'
                            || cobra_disbursement_id,
                            cobra_disbursement_id,
                            sysdate,
                            p_user_id,
                            sysdate,
                            p_user_id,
                            payment_register_id,
                            'STERLING',
                            'PROCESSED'
                        from
                            employer_payments
                        where
                            employer_payment_id = p_emp_payment_id;

                    update cobra_payments
                    set
                        transaction_type = 'RETURNED',
                        employer_payment_id = null
                    where
                        cobra_payment_id = x.cobra_disbursement_id;

                end if; --End Added by Karthe on 03-Oct-2024
            elsif x.transaction_source = 'WEX' then
                l_claim_type := 'COBRA_DISBURSEMENT';
            end if;
        end loop;
        --END IF ;
        if p_reason_code <> 29 then
            if
                p_vendor_id is not null
                and l_claim_type is null
            then
                raise l_claim_type_missing_excp;
            end if;
                  -- code ends here  #11603

            if p_vendor_id is not null
               or p_bank_acct_id is not null then
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
                    claim_amount,
                    note,
                    claim_type,
                    peachtree_interfaced,
                    claim_error_flag,
                    insufficient_fund_flag,
                    memo,
                    pay_reason,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( payment_register_seq.nextval,
                           l_batch_number,
                           p_entrp_id,
                           pc_entrp.get_acc_num(p_entrp_id),
                           case
                               when p_vendor_id is not null then
                                   pc_payee.get_payee_name(p_vendor_id)
                               else
                                   pc_entrp.get_entrp_name(p_entrp_id)
                           end,
                           p_vendor_id,
                           p_bank_acct_id,
                           pc_entrp.get_acc_num(p_entrp_id),
                           'COBRA' || p_emp_payment_id,
                           null,
                           sysdate
                    --, P_CLAIM_AMOUNT --Commented by Karthe on 08/16/2024
                    --Added by Karthe on 08/16/2024
                           ,
                           case
                               when p_reason_code = 29 then
                                   - p_claim_amount
                               else
                                   p_claim_amount
                           end  --End Added by Karthe on 08/16/2024
                    --, 'Cobra Disbursement  created on '||TO_CHAR(SYSDATE,'MM/DD/RRRR') --Commented by Karthe on 08/16/2024
                    --Added by Karthe on 08/16/2024
                           ,
                           case
                               when p_reason_code = 29 then
                                   'Adjustment created on ' || to_char(sysdate, 'MM/DD/RRRR')
                               else
                                   'Cobra Disbursement created on ' || to_char(sysdate, 'MM/DD/RRRR')
                           end  --End Added by Karthe on 08/16/2024
                    --, 'COBRA_DISBURSEMENT'
                           ,
                           l_claim_type -- commneted above and added by Joshi for 11603 
                           ,
                           'N',
                           'N',
                           'N',
                           p_note,
                           p_reason_code,
                           sysdate,
                           get_user_id(v('APP_USER')),
                           sysdate,
                           get_user_id(v('APP_USER')) ) returning payment_register_id into l_payment_reg_id;

            end if;

               --Commented and Added below by Karthe on 08/16/2024, Filtering here not to update and updating below later after all the process
            update employer_payments
            set
                payment_register_id = l_payment_reg_id
            where
                employer_payment_id = p_emp_payment_id;

            pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement', 'L_PAYMENT_REG_ID ' || l_payment_reg_id);
            pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement', 'p_emp_payment_id ' || p_emp_payment_id);
            for x in (
                select
                    a.payment_register_id,
                    c.check_amount,
                    c.check_number,
                    d.acc_id,
                    a.pay_reason,
                    a.bank_acct_id,
                    c.entrp_id,
                    c.cobra_disbursement_id
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
                  --  AND   A.CLAIM_TYPE = 'COBRA_DISBURSEMENT')
                    and a.claim_type in ( 'COBRA_DISBURSEMENT', 'COBRA_PAYMENTS' )
            )  -- commneted above and added by Joshi for 11603 
             loop
                if x.pay_reason in ( 11, 12 ) then
                     -- Added by Joshi for ticket 8636. To avoid duplicate check creation.
                    if x.check_number is null then
                        pc_check_process.insert_check(
                            p_claim_id     => x.payment_register_id,
                            p_check_amount => x.check_amount,
                            p_acc_id       => x.acc_id,
                            p_user_id      => get_user_id(v('APP_USER')),
                            p_status       => 'OPEN',
                            p_source       => 'EMPLOYER_PAYMENTS',
                            x_check_number => l_check_number
                        );

                        update employer_payments
                        set
                            check_number = l_check_number,
                            last_update_date = sysdate,
                            last_updated_by = p_user_id
                        where
                            employer_payment_id = p_emp_payment_id; --Added by Karthe on 03-Oct-2024
                    else
                        update checks
                        set
                            check_amount = x.check_amount,
                            last_updated_by = p_user_id,
                            last_update_date = sysdate,
                            entity_id = x.payment_register_id
                        where
                                acc_id = x.acc_id
                            and check_number = x.check_number
                            and entity_type = 'EMPLOYER_PAYMENTS'
                            and status = 'OPEN';

                    end if;
                    -- code ends here by Joshi for ticket 8636. To avoid duplicate check creation.

                end if;

                if x.pay_reason = 19 then
                        -- Start added by swamy for Ticket#8548 duplicate cobra issue
                    for j in (
                        select
                            transaction_id,
                            a.status
                        from
                            ach_transfer      a,
                            employer_payments e
                        where
                                a.claim_id = e.employer_payment_id
                            and a.status not in ( 9, 29 ) --29 added by Karthe on 03-Oct-2024
                            and e.employer_payment_id = p_emp_payment_id
                            and a.acc_id = x.acc_id
                    ) loop
                        l_ach_trans_id := j.transaction_id;
                        l_status := j.status;
                    end loop;

                    if
                        nvl(l_ach_trans_id, 0) <> 0
                        and l_status <> 3
                    then
                        pc_ach_transfer.upd_ach_transfer(
                            p_transaction_id   => l_ach_trans_id,
                            p_transaction_type => 'D',
                            p_amount           => x.check_amount,
                            p_fee_amount       => 0,
                            p_transaction_date => sysdate,
                            p_reason_code      => 1,
                            p_user_id          => p_user_id,
                            x_return_status    => x_return_status,
                            x_error_message    => x_error_message
                        );

                    else   -- End of addition by swamy for Ticket#8548 duplicate cobra issue
                        pc_ach_transfer.ins_ach_transfer(
                            p_acc_id           => x.acc_id,
                            p_bank_acct_id     => x.bank_acct_id,
                            p_transaction_type => 'D',
                            p_amount           => x.check_amount,
                            p_fee_amount       => 0,
                            p_transaction_date => sysdate,
                            p_reason_code      => 1,
                            p_status           => 2,
                            p_user_id          => p_user_id,
                            p_pay_code         => 5,
                            x_transaction_id   => l_transaction_id,
                            x_return_status    => x_return_status,
                            x_error_message    => x_error_message
                        );

                        update employer_payments
                        set
                            check_number = l_transaction_id,
                            last_updated_by = p_user_id,
                            last_update_date = sysdate
                        where
                                employer_payment_id = p_emp_payment_id
                            and entrp_id = x.entrp_id
                            and cobra_disbursement_id = x.cobra_disbursement_id; --Added by Karthe on 03-Oct-2024;

                        update ach_transfer
                        set
                            claim_id = p_emp_payment_id
                        where
                            transaction_id = l_transaction_id;

                    end if; -- Added by swamy for Ticket#8548 duplicate cobra issue
                end if;

             --Added by Karthe on 08/16/2024 
            --Return Disbursement for Reason Codes 19-ePayment
            -- commenting this because we do need history
         /*   IF X.Pay_Reason = 29 THEN -- 29 - Returned ACH
               FOR j IN (SELECT transaction_id 
                           FROM ach_transfer a, employer_payments e 
                          WHERE a.transaction_id = e.check_number 
                            AND a.claim_id = e.employer_payment_id
                            AND a.status <> 9
                            AND a.reason_code != 29  --Added by Karthe on 03-Oct-2024
                            AND e.EMPLOYER_PAYMENT_ID = p_emp_payment_id )  
                LOOP
                     UPDATE ach_transfer
                        SET claim_id = null
                           ,last_updated_by  = p_user_id
                           ,last_update_date = sysdate
                      WHERE transaction_id = j.transaction_id;
                END LOOP;
            END IF;*/
            --End Karthe on 08/16/2024 
            end loop;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement', 'SQLERRM ' || sqlerrm);
    end process_cobra_disbursement;

-- Added by Swamy for Cobrapoint 02/11/2022  -- swamy06
    procedure post_premium_invoice (
        p_transaction_id in number,
        p_user_id        in number
    ) is
        l_employer_payment_id number;
    begin

	/*SELECT EMPLOYER_DEPOSIT_SEQ.NEXTVAL INTO l_list_bill FROM DUAL;

    INSERT INTO EMPLOYER_DEPOSITS
                (EMPLOYER_DEPOSIT_ID
                , ENTRP_ID
                , LIST_BILL
                , CHECK_NUMBER
                , CHECK_AMOUNT
                , CHECK_DATE
                , POSTED_BALANCE
                , REMAINING_BALANCE
                , FEE_BUCKET_BALANCE
                , CREATED_BY
                , CREATION_DATE
                , LAST_UPDATED_BY
                , LAST_UPDATE_DATE
                , NOTE
                , PAY_CODE
                , REASON_CODE
                , PLAN_TYPE
                , INVOICE_ID)
           SELECT l_list_bill
            ,ENTRP_ID
	        ,l_list_bill
            ,'CNB'||transaction_id     -- Added by Swamy for Ticket#7723
            ,TOTAL_AMOUNT
            ,TRANSACTION_DATE
	        ,TOTAL_AMOUNT
            ,0
	        ,FEE_AMOUNT
            ,0
	        ,SYSDATE
	        ,0
            ,SYSDATE
	        ,'Inserted from ACH Process'
            ,PAY_CODE
            ,REASON_CODE
            ,plan_type
            ,INVOICE_ID
        FROM ach_transfer_v x
       WHERE transaction_id = p_transaction_id
         AND entrp_id IS NOT NULL
         AND transaction_type = 'D'
         AND NOT EXISTS ( SELECT *
		                    FROM employer_deposits a
						   WHERE a.invoice_id = x.invoice_id) ;

*/
/*
SELECT EMPLOYER_PAYMENTS_SEQ.NEXTVAL INTO L_EMPLOYER_PAYMENT_ID FROM DUAL;
			           insert into employer_payments
			                                (EMPLOYER_PAYMENT_ID
			                                ,ENTRP_ID
			                                ,CHECK_AMOUNT
			                                ,CREATION_DATE
			                                ,CREATED_BY
			                                ,LAST_UPDATE_DATE
			                                ,LAST_UPDATED_BY
			                                ,CHECK_DATE
			                                ,REASON_CODE
			                                ,TRANSACTION_DATE
			                                ,PLAN_TYPE
			                                ,PAY_CODE
			                                ,invoice_id
			                                ,NOTE,MEMO)
			                 (
			      select          EMPLOYER_PAYMENTS_SEQ.NEXTVAL

            ,ENTRP_ID
            ,TOTAL_AMOUNT
              ,sysdate
			                ,p_user_id
			                ,sysdate
			                ,p_user_id
            ,TRANSACTION_DATE
            ,25
            ,TRANSACTION_DATE
            ,'COBRA'
            ,PAY_CODE
            ,INVOICE_ID
            ,'Inserted from ACH Process'
            ,'Inserted from ACH Process'
        FROM ach_transfer_v x
       WHERE transaction_id = p_transaction_id
         AND entrp_id IS NULL
         AND transaction_type = 'D'
         ) ;
*/

        pc_log.log_error('PC_AUTO_PROCESS', 'Posting to Individuals');
        for x in (
            select
                a.transaction_date,
                a.reason_code,
                a.pay_code,
                a.amount,
                a.invoice_id,
                a.acc_id,
                a.claim_id,
                a.pers_id,
                a.total_amount,
                sum(
                    case
                        when i.rate_code in('91', '93') then
                            i.total_line_amount
                        else
                            0
                    end
                ) p,
                sum(
                    case
                        when i.rate_code in('92') then
                            i.total_line_amount
                        else
                            0
                    end
                ) f
            from
                ach_transfer_v   a,
                account          b,
                ar_invoice_lines i
            where
                    a.status = 4
                and a.reason_code = 132
                and a.transaction_type = 'D'
                and i.rate_code in ( '91', '92', '93' )
                and trunc(a.transaction_date) <= trunc(sysdate)
                and a.invoice_id = i.invoice_id
                and b.account_type = 'COBRA'
                and a.transaction_id = p_transaction_id
                and a.acc_id = b.acc_id
            group by
                a.transaction_date,
                a.reason_code,
                a.pay_code,
                a.amount,
                a.invoice_id,
                a.acc_id,
                a.claim_id,
                a.pers_id,
                a.total_amount
        ) loop
            delete from balance_register
            where
                change_id = x.acc_id || p_transaction_id;

            if x.p > 0 then
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
                    reason_mode,
                    last_updated_date   -- Added by Swamy for Ticket#11556
                    ,
                    last_updated_by    -- Added by Swamy for Ticket#11556
                )
                    select
                        change_seq.nextval,
                        claim_id,
                        claim_date_start,
                        x.p,
                        pay_reason,
                        p_transaction_id,
                        'Generate Disbursement ' || to_char(sysdate, 'YYYYMMDD'),
                        x.acc_id,
                        sysdate,
                        'P',
                        sysdate         -- Added by Swamy for Ticket#11556
                        ,
                        p_user_id       -- Added by Swamy for Ticket#11556
                    from
                        claimn a
                    where
                            a.pers_id = x.pers_id
                        and a.claim_id = x.claim_id
                        and not exists (
                            select
                                1
                            from
                                payment
                            where
                                    claimn_id = a.claim_id
                                and reason_mode = 'P'
                        );

            end if;

            if x.f > 0 then
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
                    reason_mode,
                    last_updated_date    -- Added by Swamy for Ticket#11556
                    ,
                    last_updated_by      -- Added by Swamy for Ticket#11556
                )
                    select
                        change_seq.nextval,
                        claim_id,
                        claim_date_start,
                        x.f,
                        pay_reason,
                        p_transaction_id,
                        'Generate Disbursement ' || to_char(sysdate, 'YYYYMMDD'),
                        x.acc_id,
                        sysdate,
                        'FP',
                        sysdate        -- Added by Swamy for Ticket#11556
                        ,
                        p_user_id      -- Added by Swamy for Ticket#11556
                    from
                        claimn a
                    where
                            a.pers_id = x.pers_id
                        and a.claim_id = x.claim_id
                        and not exists (
                            select
                                1
                            from
                                payment
                            where
                                    claimn_id = a.claim_id
                                and reason_mode = 'FP'
                        );

            end if;

            update claimn
            set
                claim_paid = x.total_amount,
                claim_status = 'PAID',
                claim_pending = claim_amount - x.total_amount,
                last_update_date = sysdate     -- Added by Swamy for Ticket#11556
                ,
                last_updated_by = p_user_id    -- Added by Swamy for Ticket#11556 
            where
                claim_id = x.claim_id;

            pc_log.log_error('PC_AUTO_PROCESS', 'Posting to employer income x.acc_id := ' || x.acc_id);
            update ar_invoice
            set
                status = 'REFUNDED',
                refund_amount = x.total_amount,
                invoice_posted_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                invoice_id = x.invoice_id;

            update ach_transfer
            set
                status = '3',
                processed_date = sysdate,
                plan_type = 'COBRA',
                bankserv_status = 'APPROVED',
                last_update_date = sysdate             -- Added by Swamy for Ticket#11556
                ,
                last_updated_by = p_user_id            -- Added by Swamy for Ticket#11556         
            where
                    transaction_id = p_transaction_id
                and status = 4
                and reason_code = 132;

        end loop;

    exception
        when others then
            raise;
    end post_premium_invoice;

    procedure process_cobra_disbursement_auto is

        l_error_message varchar2(32000);
        l_return_status varchar2(3000);
        l_reason_code   number;
        l_vendor_id     number;
        l_bank_acct_id  number;
    begin  

        -- set status
    /*    update employer_payments
        set    payment_status = 'CANCELLED'--,check_number = null
              ,last_update_date= sysdate
        WHERE employer_payment_id in ( select a.employer_payment_id
        FROM EMPLOYER_PAYMENTS a, account b
        where payment_status = 'PENDING'
        and   reason_code= 19 and plan_type= 'COBRA' 
        and transaction_source= 'STERLING'
        --and a.entrp_id = 25779
        and a.entrp_id = b.entrp_id  
        and 0 = ( select count(*)
                                       from ach_transfer 
                                      where claim_id = a.employer_payment_id
                                        and status  in (1,2,3) 
                                        and acc_id = b.acc_id)
        and 0 < ( select count(*)
                                       from ach_transfer 
                                      where claim_id = a.employer_payment_id
                                        and status = 9
                                        and acc_id = b.acc_id));*/

        for x in (
            select
                a.employer_payment_id,
                a.entrp_id,
                a.transaction_date,
                a.check_amount,
                a.note,
                a.memo,
                a.cobra_disbursement_id
            from
                employer_payments a,
                account           b
            where --payment_status = 'PENDING'           --Commented by Karthe on 09Jan2025 for the STS #INC16682
                payment_status in ( 'PENDING', 'PROCESSING' )  --Added by Karthe on 09Jan2025 for the STS #INC16682
                and reason_code = 19
                and plan_type = 'COBRA'
                and transaction_source = 'STERLING'
                and a.entrp_id = b.entrp_id
                and 0 = (
                    select
                        count(*)
                    from
                        ach_transfer
                    where
                            claim_id = a.employer_payment_id
                        and status in ( 1, 2, 3 )
                        and acc_id = b.acc_id
                )
                and 0 < (
                    select
                        count(*)
                    from
                        ach_transfer
                    where
                            claim_id = a.employer_payment_id
                        and status = 9
                        and acc_id = b.acc_id
                )
        ) loop
            update employer_payments
            set
                payment_status = 'CANCELLED'--,check_number = null
                ,
                last_update_date = sysdate
            where
                employer_payment_id = x.employer_payment_id;

            insert into employer_payments (
                employer_payment_id,
                entrp_id,
                check_date,
                transaction_date,
                reason_code,
                check_amount,
                plan_type,
                note,
                memo,
                cobra_disbursement_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                transaction_source,
                payment_status
            ) values ( employer_payments_seq.nextval,
                       x.entrp_id,
                       sysdate,
                       x.transaction_date,
                       11,
                       x.check_amount,
                       'COBRA',
                       'Reprocessing Cancelled disbursement for employer payment # ' || x.employer_payment_id,
                       x.memo,
                       x.cobra_disbursement_id,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'STERLING',
                       'PENDING' );

        end loop;

        update employer_payments
        set
            payment_status = 'PROCESSED',
            last_update_date = sysdate
        where
            employer_payment_id in (
                select
                    a.employer_payment_id
                from
                    employer_payments a, account           b
                where
                    payment_status in ( 'PENDING', 'PROCESSING' )
                    and reason_code = 19
                    and plan_type = 'COBRA'
                    and transaction_source = 'STERLING'
                    and a.entrp_id = b.entrp_id
                    and (
                        select
                            count(*)
                        from
                            ach_transfer
                        where
                                claim_id = a.employer_payment_id
                            and status = 3
                            and acc_id = b.acc_id
                    ) > 0
                    and 0 = (
                        select
                            count(*)
                        from
                            ach_transfer
                        where
                                claim_id = a.employer_payment_id
                            and status = 9
                            and acc_id = b.acc_id
                    )
            );

        update employer_payments
        set
            payment_status = 'PROCESSED',
            last_update_date = sysdate
        where
            employer_payment_id in (
                select
                    a.employer_payment_id
                from
                    employer_payments a, account           b
                where
                    payment_status in ( 'PENDING', 'PROCESSING' )
                    and reason_code = 11
                    and transaction_source = 'STERLING'
                    and a.entrp_id = b.entrp_id
                    and exists (
                        select
                            'x'
                        from
                            checks
                        where
                                entity_id = a.payment_register_id
                            and entity_type = 'EMPLOYER_PAYMENTS'
                            and acc_id = b.acc_id
                    )
                    and 0 = (
                        select
                            count(*)
                        from
                            ach_transfer
                        where
                                claim_id = a.employer_payment_id
                            and status in ( 1, 2, 3, 9 )
                            and acc_id = b.acc_id
                    )
            );

      --Employer Dont have the bank account for COBRA remittance,and setup the bank account in the Invoice parameters for Auto Payment
        for j in (
            select
                a.employer_payment_id,
                a.cobra_disbursement_id,
                b.entrp_id,
                b.acc_id,
                a.reason_code,
                a.check_amount    premium_to_pay,
                0                 check_autopay,
                'NO_BANK_ACCOUNT' pay_method
            from
                employer_payments a,
                account           b
            where
                a.check_number is null
                and a.payment_status = 'PENDING'
                and b.account_type = 'COBRA'
                and a.transaction_source = 'STERLING'
                and a.entrp_id = b.entrp_id
                and 0 = (
                    select
                        count(*)
                    from
                        ach_transfer
                    where
                            claim_id = a.employer_payment_id
                        and status in ( 1, 2, 3 )
                        and acc_id = b.acc_id
                )
                and not exists (
                    select
                        'x'
                    from
                        checks
                    where
                            entity_id = a.payment_register_id
                        and entity_type = 'EMPLOYER_PAYMENTS'
                        and acc_id = b.acc_id
                )
                and exists (
                    select
                        'x'
                    from
                        bank_accounts ba
                    where
                            ba.entity_id = b.acc_id
                        and ba.entity_type = 'ACCOUNT'
                        and ba.bank_acct_verified = 'Y'
                        and ba.status = 'A'
                        and ba.bank_account_usage = 'COBRA_DISBURSE'
                )
                and b.account_type = 'COBRA'
                and b.account_status in ( 1, 4 )
                 /*  UNION
                   SELECT  a.employer_payment_id, 
                       a.cobra_disbursement_id, 
                       b.entrp_id, 
                       b.acc_id,
                       a.reason_code,
                       a.check_amount premium_to_pay,
                       0 check_autopay,
                       'CANCELLED' pay_method
                  FROM EMPLOYER_PAYMENTS a, account b
                 WHERE a.payment_status = 'CANCELLED'
                   and a.check_number is null 
                   and a.entrp_id = b.entrp_id 
                 AND B.ACCOUNT_TYPE  ='COBRA'
                 AND A.TRANSACTION_SOURCE  = 'STERLING' 
                   and 0 = ( select count(*)
                               from ach_transfer 
                              where claim_id = a.employer_payment_id
                                and status  in (1,2,3) 
                                and acc_id = b.acc_id)
                   and 0 < ( select count(*)
                               from ach_transfer 
                              where claim_id = a.employer_payment_id
                                and status  = 9
                                and acc_id = b.acc_id)
                   and not exists ( select 'x' 
                                      from checks 
                                     where entity_id   = a.payment_register_id 
                                       and entity_type = 'EMPLOYER_PAYMENTS'
                                       and acc_id = b.acc_id)
                   and exists ( select 'x' 
                                  from bank_accounts ba 
                                 where Ba.ENTITY_ID          = b.ACC_ID
                                   AND Ba.ENTITY_TYPE        = 'ACCOUNT' 
                                   and ba.bank_acct_verified = 'Y'
                                   AND ba.STATUS             = 'A'
                                   AND Ba.BANK_ACCOUNT_USAGE = 'COBRA_DISBURSE')
                   AND b.ACCOUNT_TYPE = 'COBRA' 
                   AND b.account_status = 1 */
            union
            select
                a.employer_payment_id,
                a.cobra_disbursement_id,
                b.entrp_id,
                b.acc_id,
                a.reason_code,
                a.check_amount premium_to_pay,
                (
                    select
                        ba.rate_plan_id
                    from
                        invoice_parameters ba
                    where
                            ba.entity_id = b.entrp_id
                        and ba.entity_type = 'EMPLOYER'
                        and ba.invoice_type = 'DISBURSEMENT'
                        and ba.status = 'A'
                        and ba.autopay = 'Y'
                )              rate_plan_id,
                'CHECK'
            from
                employer_payments a,
                account           b
            where
                a.check_number is null
                and b.account_status in ( 1, 4 )
                and a.reason_code = 11
                and a.payment_status = 'PENDING'
                and a.entrp_id = b.entrp_id
                and b.account_type = 'COBRA'
                and a.transaction_source = 'STERLING'
                and 0 = (
                    select
                        count(*)
                    from
                        ach_transfer
                    where
                            claim_id = a.employer_payment_id
                        and status in ( 1, 2, 3 )
                        and acc_id = b.acc_id
                )
                and not exists (
                    select
                        'x'
                    from
                        checks
                    where
                            entity_id = a.payment_register_id
                        and entity_type = 'EMPLOYER_PAYMENTS'
                        and acc_id = b.acc_id
                )
                and b.account_type = 'COBRA'
                and exists (
                    select
                        ba.rate_plan_id
                    from
                        invoice_parameters ba
                    where
                            ba.entity_id = b.entrp_id
                        and ba.entity_type = 'EMPLOYER'
                        and ba.invoice_type = 'DISBURSEMENT'
                        and ba.status = 'A'
                        and ba.autopay = 'Y'
                )
        ) loop
            l_return_status := 'S';
            l_error_message := null;
            l_bank_acct_id := null;
            l_vendor_id := null;
            if j.pay_method <> 'CHECK' then
                for k in (
                    select
                        ba.bank_acct_id
                    from
                        bank_accounts ba
                    where
                            ba.entity_id = j.acc_id
                        and ba.entity_type = 'ACCOUNT'
                        and ba.bank_acct_verified = 'Y'
                        and ba.status = 'A'
                        and ba.bank_account_usage = 'COBRA_DISBURSE'
                ) loop
                    l_bank_acct_id := k.bank_acct_id;
                end loop;

                if l_bank_acct_id is not null then
                    update employer_payments
                    set
                        reason_code = 19,
                        last_update_date = sysdate,
                        last_updated_by = 0,
                        note = 'Auto COBRA Disbursement for '
                               || sysdate
                               || ', cobra payment id'
                               || j.cobra_disbursement_id,
                        memo = 'Auto COBRA Disbursement for '
                               || sysdate
                               || ', cobra payment id'
                               || j.cobra_disbursement_id,
                        bank_acct_id = l_bank_acct_id,
                        payment_status = 'PROCESSING'
                    where
                        employer_payment_id = j.employer_payment_id;

                    pc_cobra_disbursement.process_cobra_disbursement(
                        p_entrp_id       => j.entrp_id,
                        p_reason_code    => 19,
                        p_claim_amount   => j.premium_to_pay,
                        p_emp_payment_id => j.employer_payment_id,
                        p_vendor_id      => null,
                        p_bank_acct_id   => l_bank_acct_id,
                        p_note           => 'Auto COBRA Disbursement for '
                                  || sysdate
                                  || ', cobra payment id'
                                  || j.cobra_disbursement_id,
                        p_user_id        => 0,
                        x_return_status  => l_return_status,
                        x_error_message  => l_error_message
                    );

                end if;

            else
                if j.check_autopay is not null then
                    l_vendor_id := null;
                    for k in (
                        select
                            vendor_id
                        from
                            vendors
                        where
                            acc_id in (
                                select
                                    b.acc_id
                                from
                                    cobra_payments a, account        b
                                where
                                        cobra_payment_id = j.cobra_disbursement_id
                                    and a.entrp_id = b.entrp_id
                                    and b.account_type = 'COBRA'
                            )
                            and nvl(vendor_status, 'A') = 'A'
                    ) loop
                        l_vendor_id := k.vendor_id;
                    end loop;

                    pc_cobra_disbursement.process_cobra_disbursement(
                        p_entrp_id       => j.entrp_id,
                        p_reason_code    => 11,
                        p_claim_amount   => j.premium_to_pay,
                        p_emp_payment_id => j.employer_payment_id,
                        p_vendor_id      => l_vendor_id,
                        p_bank_acct_id   => null,
                        p_note           => 'Auto COBRA Disbursement for '
                                  || sysdate
                                  || ', cobra payment id'
                                  || j.cobra_disbursement_id,
                        p_user_id        => 0,
                        x_return_status  => l_return_status,
                        x_error_message  => l_error_message
                    );

                end if;
            end if;

        end loop;

    exception
        when others then
            l_return_status := 'E';
            l_error_message := sqlerrm;
            pc_log.log_error('pc_cobra_disbursement.process_cobra_disbursement_auto', 'SQLERRM ' || sqlerrm);
    end process_cobra_disbursement_auto;

    procedure auto_release_cobra_payment_by_check is

        l_return_status        varchar2(1);
        l_return_error_message varchar2(4000);
        l_employer_payment_id  number;
        l_vendor_id            number;
        l_acc_id               number;
        l_acc_num              varchar2(30);
    begin
        for x in (
            select
                cp.cobra_payment_id,
                cp.entrp_id,
                cp.entrp_name,
                e.name,
                e.address,
                e.city,
                e.state,
                e.zip,
                pc_payee.get_payee(cp.entrp_acc_id, 'COBRA', e.address, e.city, e.state,
                                   e.zip) vendor_id,
                cp.premium_start_date,
                cp.premium_end_date,
                cp.premium_to_pay,
                cp.transaction_type,
                ep.employer_payment_id,
                (
                    select
                        ba.rate_plan_id
                    from
                        invoice_parameters ba
                    where
                            ba.entity_id = a.entrp_id
                        and ba.entity_type = 'EMPLOYER'
                        and ba.invoice_type = 'DISBURSEMENT'
                        and ba.status = 'A'
                        and ba.payment_method = 'CHECK'
                        and ba.autopay = 'Y'
                )                         rate_plan_id
            from
                cobra_payments    cp,
                enterprise        e,
                account           a,
                employer_payments ep
            where
                    cp.entrp_id = e.entrp_id
                and e.entrp_id = a.entrp_id
                and a.account_status = 4
                and transaction_type = 'PAYMENT'
                and ( ep.payment_status is null
                      or ep.payment_status = 'PENDING' )
                and cp.cobra_payment_id = ep.cobra_disbursement_id (+)
               --and cp.cobra_payment_id = ep.cobra_disbursement_id
               --and ep.reason_code in (11,12) 
                and not exists (
                    select
                        *
                    from
                        checks
                    where
                            acc_id = a.acc_id
                        and entity_type = 'EMPLOYER_PAYMENTS'
                        and ep.payment_register_id = entity_id
                )
                and ep.check_number is null
        ) loop
            if x.rate_plan_id is not null then
             -- Insert into employer payments.
                l_employer_payment_id := null;
                l_vendor_id := x.vendor_id;
                l_acc_id := pc_entrp.get_acc_id(x.entrp_id);
                l_acc_num := pc_account.get_acc_num_from_acc_id(l_acc_id);
                if l_vendor_id is null then
                    pc_payee.add_payee(
                        p_payee_name          => x.entrp_name,
                        p_payee_acc_num       => l_acc_num,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zipcode             => x.zip,
                        p_acc_num             => l_acc_num,
                        p_user_id             => 0,
                        p_orig_sys_vendor_ref => null,
                        p_acc_id              => l_acc_id,
                        p_payee_type          => 'COBRA',
                        p_payee_tax_id        => null,
                        p_payee_nick_name     => null,
                        x_vendor_id           => l_vendor_id,
                        x_return_status       => l_return_status,
                        x_error_message       => l_return_error_message
                    );
                end if;

                pc_log.log_error('pc_cobra_disbursement.auto_release_cobra_payment_by_check', 'x.vendor_id' || l_vendor_id);
                if l_vendor_id is not null then
                    if x.employer_payment_id is null then
                        insert into employer_payments (
                            employer_payment_id,
                            entrp_id,
                            transaction_date,
                            transaction_source,
                            reason_code,
                            check_amount,
                            check_number,
                            vendor_id,
                            plan_type,
                            show_online_flag,
                            note,
                            bank_acct_id,
                            memo,
                            cobra_disbursement_id,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by
                        ) values ( employer_payments_seq.nextval,
                                   x.entrp_id,
                                   sysdate,
                                   'STERLING',
                                   11,
                                   x.premium_to_pay,
                                   null,
                                   l_vendor_id,
                                   'COBRA',
                                   'Y',
                                   ' Client Premium Remittance '
                                   || to_char(x.premium_start_date, 'Mon-yyyy'),
                                   null,
                                   null,
                                   x.cobra_payment_id,
                                   sysdate,
                                   0,
                                   sysdate,
                                   0 ) returning employer_payment_id into l_employer_payment_id;

                    else
                        l_employer_payment_id := x.employer_payment_id;
                        update employer_payments
                        set
                            note = ' Client Premium Remittance '
                                   || to_char(x.premium_start_date, 'Mon-yyyy'),
                            last_update_date = sysdate
                        where
                            employer_payment_id = x.employer_payment_id;

                    end if;

                    if l_employer_payment_id is not null then
                        pc_cobra_disbursement.process_cobra_disbursement(
                            p_entrp_id       => x.entrp_id,
                            p_reason_code    => 11,
                            p_claim_amount   => x.premium_to_pay,
                            p_emp_payment_id => l_employer_payment_id,
                            p_vendor_id      => l_vendor_id,
                            p_bank_acct_id   => null,
                            p_note           => ' Client Premium Remittance '
                                      || to_char(x.premium_start_date, 'Mon-yyyy'),
                            p_user_id        => 0,
                            x_return_status  => l_return_status,
                            x_error_message  => l_return_error_message
                        );

                        update cobra_payments
                        set
                            employer_payment_id = l_employer_payment_id,
                            last_update_date = sysdate
                        where
                            cobra_payment_id = x.cobra_payment_id;

                    end if;

                end if;

            end if;
        end loop;
    exception
        when others then
            l_return_status := 'E';
            l_return_error_message := sqlerrm;
            pc_log.log_error('pc_cobra_disbursement.auto_release_cobra_payment_by_check', 'SQLERRM ' || sqlerrm);
    end auto_release_cobra_payment_by_check;

end;
/

