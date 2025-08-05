-- liquibase formatted sql
-- changeset SAMQA:1754374167132 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\account_preference_ee_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/account_preference_ee_v.sql:null:5b03c37ce78a9babedfb4384cd691af847305aa5:create

create or replace force editionable view samqa.account_preference_ee_v (
    claim_payment_method,
    autopay_ind,
    acc_id,
    pers_id,
    entrp_id,
    er_acc_id,
    er_acc_num,
    ee_acc_num
) as
    select
        er.claim_payment_method,
        er.autopay_ind,
        eeacc.acc_id,
        c.pers_id,
        eracc.entrp_id,
        eracc.acc_id  er_acc_id,
        eracc.acc_num er_acc_num,
        eeacc.acc_num ee_acc_num
    from
        account_preference er,
        account            eracc,
        person             c,
        account            eeacc
    where
            er.acc_id = eracc.acc_id
        and eracc.entrp_id = c.entrp_id
        and c.pers_id = eeacc.pers_id
        and er.status = 'A';

