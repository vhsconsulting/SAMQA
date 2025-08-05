create or replace force editionable view samqa.fsa_plan_info_v (
    plan_start_date,
    plan_end_date,
    runout_period_days,
    ben_plan_name,
    ben_plan_number,
    grace_period,
    acc_num,
    acc_id,
    er_acc_num,
    annual_election,
    maximum_election,
    minimum_election,
    reimbursement_type,
    er_name,
    plan_type,
    ee_plan_status,
    er_plan_status,
    claim_reimbursement,
    acc_balance,
    er_note,
    ben_plan_id,
    er_ben_plan_id,
    termination_date
) as
    select
        er.plan_start_date,
        er.plan_end_date,
        er.runout_period_days,
        er.ben_plan_name,
        er.ben_plan_number,
        er.grace_period,
        ee.acc_num,
        ee.acc_id,
        era.acc_num                                                                                                           er_acc_num
        ,
        ee_plan.annual_election,
        er.maximum_election,
        er.minimum_election,
        ee_plan.reimbursement_type,
        pc_entrp.get_entrp_name(era.entrp_id)                                                                                 er_name
        ,
        ee_plan.plan_type,
        ee_plan.status                                                                                                        ee_plan_status
        ,
        er.status                                                                                                             er_plan_status
        ,
        ee_plan.claim_reimbursement,
        pc_account.acc_balance(ee.acc_id, ee_plan.plan_start_date, ee_plan.plan_end_date, ee.account_type, ee_plan.plan_type) acc_balance
        ,
        er.note                                                                                                               er_note
        ,
        ee_plan.ben_plan_id,
        er.ben_plan_id                                                                                                        er_ben_plan_id
        ,
        ee_plan.effective_end_date                                                                                            termination_date
    from
        account                   ee,
        person                    pers,
        ben_plan_enrollment_setup ee_plan,
        account                   era,
        ben_plan_enrollment_setup er
    where
            ee.pers_id = pers.pers_id
        and ee_plan.acc_id = ee.acc_id
        and pers.entrp_id = era.entrp_id
        and ee_plan.plan_type = er.plan_type
        and ee_plan.ben_plan_id_main = er.ben_plan_id
        and era.acc_id = er.acc_id;


-- sqlcl_snapshot {"hash":"cc9158b4ef9a72bd0623262add748e4045e19f18","type":"VIEW","name":"FSA_PLAN_INFO_V","schemaName":"SAMQA","sxml":""}