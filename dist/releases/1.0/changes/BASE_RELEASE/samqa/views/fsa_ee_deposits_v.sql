-- liquibase formatted sql
-- changeset SAMQA:1754374173785 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_ee_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_ee_deposits_v.sql:null:93f43653890ea068f4cd6254cd25af097a64b77b:create

create or replace force editionable view samqa.fsa_ee_deposits_v (
    list_bill,
    fee_date,
    fsa_amt,
    dca_amt,
    lpf_amt,
    pkg_amt,
    trn_amt,
    ua_amt,
    acc_num,
    account_type
) as
    select
        list_bill,
        fee_date,
        sum(
            case
                when plan_type = 'FSA' then
                    nvl(amount, 0) + nvl(amount_add, 0)
                else
                    0
            end
        ) fsa_amt,
        sum(
            case
                when plan_type = 'DCA' then
                    nvl(amount, 0) + nvl(amount_add, 0)
                else
                    0
            end
        ) dca_amt,
        sum(
            case
                when plan_type = 'LPF' then
                    nvl(amount, 0) + nvl(amount_add, 0)
                else
                    0
            end
        ) lpf_amt,
        sum(
            case
                when plan_type = 'PKG' then
                    nvl(amount, 0) + nvl(amount_add, 0)
                else
                    0
            end
        ) pkg_amt,
        sum(
            case
                when plan_type = 'TRN' then
                    nvl(amount, 0) + nvl(amount_add, 0)
                else
                    0
            end
        ) trn_amt,
        sum(
            case
                when plan_type = 'UA1' then
                    nvl(amount, 0) + nvl(amount_add, 0)
                else
                    0
            end
        ) ua_amt,
        acc_num,
        account_type
    from
        income  a,
        account b
    where
            nvl(fee_code, 4) <> 40
        and a.acc_id = b.acc_id
    group by
        list_bill,
        fee_date,
        acc_num,
        account_type
    order by
        fee_date desc;

