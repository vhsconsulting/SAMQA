create or replace force editionable view samqa.deposit_audit_v (
    deposit_register_id,
    name,
    note,
    acc_num,
    trans_date,
    check_number,
    check_amount,
    posted_amount,
    new_app_flag,
    new_app_amount,
    status,
    the_color,
    type,
    entrp_id,
    acc_id,
    list_bill,
    orig_sys_ref,
    reconciled_flag,
    account_type,
    created_by,
    creation_date
) as
    select
        deposit_register_id,
        name,
        note,
        acc_num,
        trans_date,
        check_number,
        check_amount,
        posted_amount,
        new_app_flag,
        new_app_amount,
        case
            when status = 'Y'                  then
                'Y'
            when nvl(status, 'N') = 'N'        then
                'N'
            when check_amount <> posted_amount then
                'N'
            when posted_amount is null then
                'N'
            when check_amount = posted_amount  then
                'Y'
        end status,
        case
            when check_amount <> posted_amount then
                'red'
            when posted_amount is null then
                'red'
            when check_amount = posted_amount  then
                'black'
        end the_color,
        type,
        entrp_id,
        acc_id,
        list_bill,
        orig_sys_ref,
        reconciled_flag,
        account_type,
        created_by,
        creation_date
    from
        (
            select
                deposit_register_id,
                first_name
                || ' '
                || last_name                      name,
                a.note,
                a.acc_num,
                to_date(trans_date, 'MM/DD/YYYY') trans_date,
                new_app_flag,
                new_app_amount,
                check_number,
                check_amount,
                decode(b.account_type,
                       'HSA',
                       get_check_info(a.acc_id, orig_sys_ref),
                       check_amount)              posted_amount,
                status,
                case
                    when a.entrp_id is not null then
                        'Employer'
                    when a.acc_id is not null then
                        'Individual'
                    else
                        null
                end                               type,
                a.entrp_id,
                a.acc_id,
                list_bill,
                orig_sys_ref,
                reconciled_flag,
                b.account_type,
                a.created_by,
                a.creation_date
            from
                deposit_register a,
                account          b
            where
                    a.acc_num = b.acc_num
                and not exists (
                    select
                        *
                    from
                        employer_deposits
                    where
                            a.list_bill = employer_deposits.list_bill
                        and employer_deposits.reason_code in ( 11, 12 )
                )
        );


-- sqlcl_snapshot {"hash":"c6e41dbb3399957eb2bb5ae6248dfdc9159d7835","type":"VIEW","name":"DEPOSIT_AUDIT_V","schemaName":"SAMQA","sxml":""}