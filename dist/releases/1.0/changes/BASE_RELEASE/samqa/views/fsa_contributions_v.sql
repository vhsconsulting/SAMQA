-- liquibase formatted sql
-- changeset SAMQA:1754374173738 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_contributions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_contributions_v.sql:null:38342329517ba19b97a7c3f51a45c6165df22b9a:create

create or replace force editionable view samqa.fsa_contributions_v (
    acc_id,
    mon,
    plan_type,
    entrp_id,
    fsa_amt,
    dca_amt,
    trn_amt,
    pkg_amt,
    lpf_amt,
    ua1_amt
) as
    select
        acc_id,
        mon,
        plan_type,
        pc_person.get_entrp_id(acc_id) entrp_id,
        sum(fsa_amt)                   fsa_amt,
        sum(dca_amt)                   dca_amt,
        sum(trn_amt)                   trn_amt,
        sum(pkg_amt)                   pkg_amt,
        sum(lpf_amt)                   lpf_amt,
        sum(ua1_amt)                   ua1_amt
    from
        (
            select
                inc.acc_id,
                to_char(inc.fee_date, 'MON') mon,
                to_char(inc.fee_date, 'MM')  mm,
                ben.plan_type,
                case
                    when ben.plan_type = 'FSA' then
                        sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0))
                    else
                        0
                end                          fsa_amt,
                case
                    when ben.plan_type = 'DCA' then
                        sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0))
                    else
                        0
                end                          dca_amt,
                case
                    when ben.plan_type = 'TRN' then
                        sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0))
                    else
                        0
                end                          trn_amt,
                case
                    when ben.plan_type = 'PKG' then
                        sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0))
                    else
                        0
                end                          pkg_amt,
                case
                    when ben.plan_type = 'LPF' then
                        sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0))
                    else
                        0
                end                          lpf_amt,
                case
                    when ben.plan_type = 'UA1' then
                        sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0))
                    else
                        0
                end                          ua1_amt
            from
                income                    inc,
                ben_plan_enrollment_setup ben
            where
                    inc.acc_id = ben.acc_id
                and inc.plan_type = ben.plan_type
                and ben.status in ( 'A', 'I' )
            group by
                inc.acc_id,
                to_char(inc.fee_date, 'MON'),
                to_char(inc.fee_date, 'MM'),
                ben.plan_type
        )
    group by
        acc_id,
        mon,
        plan_type,
        mm,
        pc_person.get_entrp_id(acc_id)
    order by
        mm;

