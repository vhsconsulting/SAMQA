-- liquibase formatted sql
-- changeset SAMQA:1754374173690 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_contrib_pivot_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_contrib_pivot_v.sql:null:5d877a1baf6e8cf944d99fb3d87fbc47be1a8b27:create

create or replace force editionable view samqa.fsa_contrib_pivot_v (
    check_date,
    acc_id,
    acc_num,
    fsa_amt,
    dca_amt,
    pdf_amt,
    lpf_amt,
    iip_amt,
    trn_amt,
    pkg_amt,
    ua_amt
) as
    select
        check_date,
        acc_id,
        acc_num,
        fsa_amt,
        dca_amt,
        pdf_amt,
        lpf_amt,
        iip_amt,
        trn_amt,
        pkg_amt,
        ua_amt
    from
        (
            select
                trunc(a.check_date) check_date,
                b.acc_id,
                b.acc_num,
                a.plan_type,
                sum(a.check_amount) check_amount
            from
                employer_deposits a,
                account           b
            where
                    a.entrp_id = b.entrp_id
                and b.account_type = 'FSA'
            group by
                trunc(a.check_date),
                b.acc_id,
                b.acc_num,
                a.plan_type
        ) pivot (
            sum(check_amount)
        as amt
            for plan_type
            in ( 'FSA' as fsa, 'DCA' as dca, 'PDF' as pdf, 'LPF' as lpf, 'IIP' as iip, 'TRN' as trn, 'PKG' as pkg, 'UA1' as ua )
        );

