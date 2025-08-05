create or replace force editionable view samqa.acc_user_profile_v (
    acc_num,
    person_name,
    birth_date,
    address,
    city,
    state,
    zip,
    phone_day,
    email,
    plan_name,
    fee_setup,
    fee_maint,
    name,
    effective_date,
    data_entry_date,
    employer_name,
    broker_name,
    deductible,
    start_date,
    plan_type,
    plan_type_code,
    card_exists,
    card_allowed,
    pers_id,
    acc_id,
    broker_id,
    insur_id,
    plan_sign,
    user_name,
    account_status,
    bank_name,
    account_number,
    routing_number,
    division_code,
    tax_id,
    entrp_id,
    end_date,
    plan_code
) as
    select
        b.acc_num,
        a.first_name
        || decode(a.middle_name, null, ' ', ' '
                                            || a.middle_name
                                            || ' ')
        || a.last_name                                                 person_name,
        a.birth_date,
        a.address,
        a.city,
        a.state,
        a.zip,
        a.phone_day,
        pc_users.get_email_from_user_id(pc_users.get_user(a.ssn, 'S')) email,
        c.plan_name,
        pc_plan.fsetup(b.plan_code)                                    fee_setup,
        case
            when b.plan_code in ( 1, 2 ) then
                pc_plan.fmonth(b.plan_code)
            when b.plan_code = 8 then
                b.fee_maint  -- added by Joshi for 5363
            else
                pc_plan.fannual(b.plan_code)
        end                                                            fee_maint,
        d.name,
        b.start_date                                                   effective_date,
        b.reg_date                                                     data_entry_date,
        pc_lookups.get_employer(a.entrp_id)                            employer_name,
        pc_lookups.get_broker(b.broker_id)                             broker_name,
        e.deductible,
        e.start_date                                                   start_date,
        pc_lookups.get_plan_type(e.plan_type)                          plan_type,
        e.plan_type                                                    plan_type_code,
        nvl((
            select
                'Y'
            from
                card_debit
            where
                    card_id = a.pers_id
                and status <> 3
        ), 'N')                                                        card_exists,
        nvl(
            pc_person.card_allowed(a.pers_id),
            0
        )                                                              card_allowed,
        a.pers_id,
        b.acc_id,
        b.broker_id,
        e.insur_id,
        c.plan_sign,
        pc_users.get_user_name(pc_users.get_user(a.ssn, 'S'))          user_name,
        b.account_status,
        j.bank_name,
        j.bank_acct_num                                                account_number,
        j.bank_routing_num                                             routing_number,
        a.division_code,
        replace(a.ssn, '-')                                            tax_id,
        a.entrp_id,
        b.end_date,
        c.plan_code
    from
        person         a,
        account        b,
        plans          c,
        myhealthplan   d,
        insure         e,
        user_bank_acct j
    where
            a.pers_id = b.pers_id
        and b.plan_code = c.plan_code
        and e.insur_id = d.entrp_id (+)
        and e.pers_id (+) = a.pers_id
        and j.acc_id (+) = b.acc_id;


-- sqlcl_snapshot {"hash":"825b8d7d32715ff04c123575eb0e04f91b5c81ce","type":"VIEW","name":"ACC_USER_PROFILE_V","schemaName":"SAMQA","sxml":""}