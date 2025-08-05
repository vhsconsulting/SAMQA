create or replace force editionable view samqa.employees_v (
    entrp_id,
    name,
    first_name,
    last_name,
    acc_num,
    acc_id,
    start_date,
    acc_status,
    pers_id,
    er_acc_num,
    er_acc_id,
    account_status,
    signature_on_file,
    account_type,
    employer_name,
    hsa_effective_date,
    plan_code,
    complete_flag,
    ssn
) as
    select
        a.entrp_id,
        a.first_name
        || ' '
        || a.last_name                              name,
        a.first_name,
        a.last_name,
        b.acc_num,
        b.acc_id,
        b.start_date,
        c.meaning                                   acc_status,
        a.pers_id,
        d.acc_num                                   er_acc_num,
        d.acc_id                                    er_acc_id,
        b.account_status,
        upper(b.signature_on_file)                  signature_on_file,
        b.account_type,
        pc_entrp.get_entrp_name(a.entrp_id)         employer_name,
        to_char(b.hsa_effective_date, 'MM/DD/YYYY') hsa_effective_date,
        b.plan_code,
        decode(b.complete_flag, 0, 'No', 'Yes')     complete_flag,
        a.ssn
    from
        person  a,
        account b,
        lookups c,
        account d
    where
            a.pers_id = b.pers_id
        and b.account_status = c.lookup_code
        and a.entrp_id = d.entrp_id
        and c.lookup_name = 'ACCOUNT_STATUS';


-- sqlcl_snapshot {"hash":"f1248a6aa3355828daf69306fb5e79adbe4d7815","type":"VIEW","name":"EMPLOYEES_V","schemaName":"SAMQA","sxml":""}