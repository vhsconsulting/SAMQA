-- liquibase formatted sql
-- changeset SAMQA:1754374173928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_er_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_er_deposits_v.sql:null:e525f06f00cc2315c92dd97f240e065c9af7d691:create

create or replace force editionable view samqa.fsa_er_deposits_v (
    list_bill,
    check_date,
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
        check_date,
        sum(
            case
                when plan_type = 'FSA' then
                    check_amount
                else
                    0
            end
        ) fsa_amt,
        sum(
            case
                when plan_type = 'DCA' then
                    check_amount
                else
                    0
            end
        ) dca_amt,
        sum(
            case
                when plan_type = 'LPF' then
                    check_amount
                else
                    0
            end
        ) lpf_amt,
        sum(
            case
                when plan_type = 'PKG' then
                    check_amount
                else
                    0
            end
        ) pkg_amt,
        sum(
            case
                when plan_type = 'TRN' then
                    check_amount
                else
                    0
            end
        ) trn_amt,
        sum(
            case
                when plan_type = 'UA1' then
                    check_amount
                else
                    0
            end
        ) ua_amt,
        acc_num,
        account_type
    from
        employer_deposits_v
    where
        nvl(reason_code, 4) <> 40
    group by
        list_bill,
        check_date,
        acc_num,
        account_type
    order by
        check_date desc;

